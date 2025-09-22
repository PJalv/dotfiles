return {
  'milanglacier/minuet-ai.nvim',
  config = function()
    require('minuet').setup {
      provider = 'openai_compatible',
      request_timeout = 2.5,
      throttle = 1500, -- Increase to reduce costs and avoid rate limits
      debounce = 600,  -- Increase to reduce costs and avoid rate limits
      provider_options = {
        openai_compatible = {
          api_key = 'OPENROUTER_API_KEY',
          end_point = 'https://openrouter.ai/api/v1/chat/completions',
          model = 'google/gemini-2.5-flash',
          name = 'Openrouter',
          optional = {
            max_tokens = 56,
            top_p = 0.9,
            provider = {
              -- Prioritize throughput for faster completion
              sort = 'throughput',
            },
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { 'c' },
        keymap = {
          -- accept whole completion
          accept = '<C-A>',
          -- accept one line
          accept_line = '<C-a>',
          -- accept n lines (prompts for number)
          -- e.g. "C-z 2 CR" will accept 2 lines
          accept_n_lines = '<C-z>',
          -- Cycle to prev completion item, or manually invoke completion
          prev = '<C-[>',
          -- Cycle to next completion item, or manually invoke completion
          next = '<C-]>',
          dismiss = '<C-e>',
        },
        show_on_completion_menu = true, }
    }
  end
}
