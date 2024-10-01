-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
opt.signcolumn = "no"
opt.shell = "zsh"
local function upload_file(file_path, remote_path)
  local cmd = string.format("scp %s debian@pjalv.com:%s", file_path, remote_path)
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    print("Error uploading file: " .. result)
    return nil
  end
  return remote_path -- Return the remote path if upload was successful
end

-- Function to get the image URL based on the uploaded file path
local function get_image_url(file_path)
  -- Adjust this function based on how your server handles file paths
  local base_url = "https://pjalv.com/file/" -- Base URL for your server
  return base_url .. vim.fn.fnamemodify(file_path, ":t")
end

-- Function to insert the HTML snippet into the buffer
local function insert_html_template(url, id)
  -- Ensure id is either a string or number
  assert(type(id) == "number" or type(id) == "string", "id must be a number or a string")

  local html_template = string.format(
    [[
<figure>
    <a id="ref%d"class="postImg" href="#" onclick="openModal(event, '%s')">
        <img src="%s" alt="Image">
    </a>
    <figcaption> <a  href="#fn%d"><sup>[%d]</sup></a> </figcaption>
</figure>

%d - <a href=""></a> <a id="fn%d" href="#ref%d">↩</a>

]],
    url,
    url,
    id,
    id,
    id,
    id,
    id,
    id
  )

  -- Get the current line number
  local line_number = vim.fn.line(".")

  -- Split the string into lines
  local lines = vim.split(html_template, "\n")

  -- Append the lines after the current line
  vim.fn.append(line_number, lines)
end

-- Main function to handle the entire process
local function handle_clipboard_file(number)
  -- Step 1: Read the clipboard content
  local file_path = vim.fn.getreg("+")

  if not file_path or file_path == "" then
    print("Clipboard is empty or does not contain a file path.")
    return
  end

  -- Define remote path (adjust as necessary)
  local remote_path = "/home/debian/website/static/" .. vim.fn.fnamemodify(file_path, ":t")

  -- Step 2: Upload the file
  local uploaded_path = upload_file(file_path, remote_path)
  if not uploaded_path then
    return
  end

  -- Step 3: Get the complete URL
  local image_url = get_image_url(uploaded_path)

  -- Step 4: Insert HTML template
  insert_html_template(image_url, tonumber(number))
end

-- Bind the function to a Neovim command
vim.api.nvim_create_user_command("UploadAndInsertImage", function(opts)
  handle_clipboard_file(tonumber(opts.args))
end, { nargs = 1 })


vim.g.root_spec = {"cwd"}
