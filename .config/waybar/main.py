from RealtimeSTT import AudioToTextRecorder
import os
import subprocess
import socket
import threading
import signal
import sys

class VoiceTyper:
    def __init__(self):
        self.processed_texts = []
        self.last_partial_text = ""
        self.is_active = False  
        self.is_listening = False  
        self.recorder = None
        self.socket_thread = None
        self.socket_server = None
        self.socket_path = "/tmp/voice_typer.sock"
        
        # Initialize recorder config
        self.recorder_config = {
            'spinner': False,
            'model': 'tiny',  
            'language': 'en',
            'silero_sensitivity': 0.2,  
            'webrtc_sensitivity': 3,    
            'post_speech_silence_duration': 0.2,  
            'min_length_of_recording': 0,
            'min_gap_between_recordings': 0,
            'enable_realtime_transcription': True,
            'realtime_processing_pause': 0.1,  
        }
        
    def clear_console(self):
        os.system('clear' if os.name == 'posix' else 'cls')

    def send_to_ydotool(self, text):
        # Check if this text has already been processed
        if text and text not in self.processed_texts:
            try:
                # Use ydotool to type the text
                print(f"Typing: '{text}'")
                subprocess.run(['ydotool', 'type','--key-delay=0', '--', text + " "], check=True)  
                self.processed_texts.append(text)
            except subprocess.CalledProcessError as e:
                print(f"Error using ydotool: {e}")

    def process_text(self, text, is_partial=False):
        # Only process text if active (typing mode is on)
        if not self.is_active:
            if not is_partial:
                print(f"Heard (not typing): '{text}'")
            return
            
        # Handle partial transcriptions
        if is_partial:
            # Process partial text immediately without waiting for completion
            if text != self.last_partial_text:
                # Only type the new part of the text
                if text.startswith(self.last_partial_text):
                    new_text = text[len(self.last_partial_text):]
                    if new_text.strip():
                        try:
                            print(f"Typing partial: '{new_text}'")
                            subprocess.run(['ydotool', 'type','--key-delay=0', '--', new_text], check=True)
                        except subprocess.CalledProcessError as e:
                            print(f"Error using ydotool: {e}")
                else:
                    # If the text doesn't start with the previous partial, type it all
                    # This can happen if the model corrects its transcription
                    try:
                        print(f"Typing new partial: '{text}'")
                        subprocess.run(['ydotool', 'type','--key-delay=0', '--', text], check=True)
                    except subprocess.CalledProcessError as e:
                        print(f"Error using ydotool: {e}")
                self.last_partial_text = text
        else:
            # For final transcriptions, reset the partial text tracker
            self.last_partial_text = ""
            # Only process non-empty text
            if text.strip():
                # Send the completed sentence to ydotool
                self.send_to_ydotool(text.strip())

    def start_listening(self):
        """Start the background listening process"""
        if self.is_listening:
            print("Already listening!")
            return
            
        self.is_listening = True
        self.recorder = AudioToTextRecorder(**self.recorder_config)
        
        print("Voice typer is now listening in the background.")
        
        # Start recording in a separate thread
        self.listening_thread = threading.Thread(target=self.listening_loop)
        self.listening_thread.daemon = True
        self.listening_thread.start()

    def listening_loop(self):
        """Main loop that's always running and transcribing"""
        while self.is_listening:
            try:
                # Use the realtime parameter to get partial transcriptions
                self.recorder.text(self.process_text)
            except Exception as e:
                print(f"Error in listening: {e}")
                self.is_listening = False
                break

    def activate_typing(self):
        """Activate typing mode - text will be sent to ydotool"""
        if self.is_active:
            print("Already active!")
            return
            
        self.is_active = True
        self.clear_console()
        print("Voice typing activated. Speak clearly and your words will be typed using ydotool.")
        print("Send 'TOGGLE' command to stop typing.")
        
        # Update status file for Waybar
        with open("/tmp/voice_typer_status", "w") as f:
            f.write("active")

    def deactivate_typing(self):
        """Deactivate typing mode - still listening but not typing"""
        if not self.is_active:
            print("Not currently active!")
            return
            
        self.is_active = False
        print("Voice typing deactivated. Still listening but not typing.")
        
        # Update status file for Waybar
        with open("/tmp/voice_typer_status", "w") as f:
            f.write("inactive")

    def stop_listening(self):
        """Stop the background listening process completely"""
        if not self.is_listening:
            print("Not currently listening!")
            return
            
        self.is_listening = False
        self.is_active = False
        print("Voice typer stopped listening.")
        
        # Update status file for Waybar
        with open("/tmp/voice_typer_status", "w") as f:
            f.write("stopped")

    def setup_socket(self):
        # Remove socket if it already exists
        if os.path.exists(self.socket_path):
            os.unlink(self.socket_path)
            
        # Create socket server
        self.socket_server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.socket_server.bind(self.socket_path)
        self.socket_server.listen(1)
        
        # Set socket permissions so other users can connect
        os.chmod(self.socket_path, 0o777)
        
        # Create status file for Waybar
        with open("/tmp/voice_typer_status", "w") as f:
            f.write("inactive")
        
        # Start socket thread
        self.socket_thread = threading.Thread(target=self.socket_loop)
        self.socket_thread.daemon = True
        self.socket_thread.start()
        
    def socket_loop(self):
        while True:
            conn, addr = self.socket_server.accept()
            try:
                data = conn.recv(1024)
                if data:
                    command = data.decode('utf-8').strip()
                    if command == "TOGGLE":
                        if self.is_active:
                            self.deactivate_typing()
                        else:
                            self.activate_typing()
                    elif command == "STATUS":
                        status = "active" if self.is_active else "inactive"
                        conn.sendall(status.encode('utf-8'))
            except Exception as e:
                print(f"Socket error: {e}")
            finally:
                conn.close()

    def cleanup(self):
        # Stop listening if active
        if self.is_listening:
            self.stop_listening()
            
        # Close socket
        if self.socket_server:
            self.socket_server.close()
            
        # Remove socket file
        if os.path.exists(self.socket_path):
            os.unlink(self.socket_path)
            
        # Remove status file
        if os.path.exists("/tmp/voice_typer_status"):
            os.unlink("/tmp/voice_typer_status")

def signal_handler(sig, frame):
    print("\nShutting down voice typer...")
    if 'voice_typer' in globals():
        voice_typer.cleanup()
    sys.exit(0)

if __name__ == '__main__':
    print("Initializing Voice Typing with ydotool...")
    
    # Create voice typer instance
    voice_typer = VoiceTyper()
    
    # Set up signal handlers for clean shutdown
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Set up socket for external control
    voice_typer.setup_socket()
    
    # Start background listening immediately
    voice_typer.start_listening()
    
    print("Voice typer initialized and ready.")
    print("Always listening in the background.")
    print("Use the toggle script or Waybar to activate/deactivate typing.")
    
    # Keep main thread alive
    try:
        signal.pause()
    except AttributeError:
        # signal.pause() not available on Windows
        while True:
            pass
