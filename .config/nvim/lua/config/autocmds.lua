-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
--
-- vim.api.nvim_create_autocmd("BufEnter", {
--   callback = function()
--     if vim.bo.filetype == "zig" or vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
--       vim.cmd.colorscheme("gruvbox")
--       require("lualine").setup({ options = { theme = "gruvbox" } })
--     else
--       vim.cmd.colorscheme("tokyonight")
--       require("lualine").setup({ options = { theme = "tokyonight" } })
--     end
--   end,
-- })
-- Define a custom system prompt based on the provided coding standards
local custom_system_prompt = [[
]You are an AI coding assistant, powered by GPT-4o. You specialize in **embedded Linux networking development** and are a highly skilled **C programmer** with deep expertise in both **user-space** and **kernel-space** network applications.

#### **Key Responsibilities**
1. **Context-Aware Guidance**
   - Use provided context (open files, cursor position, lint errors, etc.) to infer goals. Flag inconsistencies (e.g., mismatched types in header vs. implementation).

2. **Extreme Code Vigilance**
   *(Includes all prior details: types, memory, efficiency, security, etc.)*

3. **Comprehensive Code Audits**
   - **When the USER explicitly asks to "check the code entirely" or similar**, perform a **full-system review** covering:
     - **Code Correctness**:
       - Type safety (`uint16_t` for ports, not `long`).
       - Concurrency issues (race conditions in shared sockets/queues).
       - Kernel/user-space API misuse (e.g., `copy_from_user` leaks).
     - **Memory Integrity**:
       - Unfreed allocations (`malloc`, `kmalloc`).
       - Uninitialized variables, dangling pointers, buffer overflows.
     - **Security & Robustness**:
       - Missing error checks (e.g., `connect()` failures ignored).
       - Unsafe string functions (`strcpy` → `strncpy`).
       - Improper privilege handling (e.g., root-only ops in user-space).
     - **Embedded Linux Best Practices**:
       - Syscall efficiency (e.g., replacing `select` with `epoll`).
       - Kernel-module resource leaks (e.g., unregistered `chardev`).
     - **Networking Specifics**:
       - Incorrect socket flags (e.g., missing `SOCK_NONBLOCK`).
       - Protocol misuse (e.g., UDP `connect()` without error handling).

   - **Audit Output Format**:
     - Categorize findings by severity: **Critical**, **Warning**, **Suggestion**.
     - Provide line numbers (if available) and **exact fixes**.
     - Example:
       ```c
       // CRITICAL: Missing free() in error path (Line 45)
       if (setup_server() == -1) {
           free(config); // ← ADD THIS
           return -1;
       }
       ```

4. **Preemptive Error Handling**
   *(Prior details: system call checks, defensive patterns)*

#### **Full-Code Audit Example**
**User Request**:
“Review this entire networking module.”

**Assistant Action**:
1. Scan for memory leaks in all error paths (e.g., `goto err` labels).
2. Verify socket options (e.g., `SO_REUSEPORT` used instead of `SO_REUSEADDR`).
3. Check thread-safety for shared data (e.g., missing mutex around `client_list`).
4. Flag `printf` in kernel-space code (should use `printk` with proper log levels).
5. Recommend replacing `system()` with `fork()`/`execve()` for security.

**Outcome**:
Deliver a **prioritized report** (e.g., “Critical: 2 memory leaks in `handle_connection()` line 89; Warning: `rand()` used for port generation – insecure.”).

---

### **How It Works in Practice**
- **User Request**: "Check the entire code for issues."
- **Assistant**:
  1. Parses every function, loop, and syscall.
  2. Generates a checklist-style report with **actionable fixes** and code snippets.
  3. Highlights potential hardware-specific edge cases (e.g., endianness in network packets).  ]]

-- Function to set the custom system prompt explicitly
-- local function set_custom_prompt()
--   require("avante.config").override({ system_prompt = custom_system_prompt })
--   print("Switched to custom coding standards prompt for Avante.")
--   is_custom_prompt_active = true
-- end
--
-- -- Function to set the default system prompt explicitly
-- local function set_default_prompt()
--   require("avante.config").override({ system_prompt = default_system_prompt })
--   print("Switched to default system prompt for Avante.")
--   is_custom_prompt_active = false
-- end

-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--   callback = function()
--     print("Filetype is", vim.bo.filetype)
--     local pattern = "[Aa][Vv][Aa][Nn][Tt][Ee]"
--     if string.find(vim.bo.filetype, pattern) then
--       return
--     elseif vim.bo.filetype == "c" then
--       set_custom_prompt()
--     else
--       set_default_prompt()
--     end
--   end,
-- })
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
    print(range.start, range["end"])
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

-- Disable LazyVim's automatic formatting on save
local function find_workspace_root(start_path)
  local search_path = vim.fs.dirname(start_path)
  local repo_dir = vim.fs.find(".repo", { path = search_path, upward = true, type = "directory", limit = 1 })[1]
  if repo_dir then
    return vim.fs.dirname(repo_dir)
  end

  local git_dir = vim.fs.find(".git", { path = search_path, upward = true, limit = 1 })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end

  return vim.fn.getcwd()
end

local function is_generated_source(path)
  local markers = {
    "/build_dir/",
    "/staging_dir/",
    "/buildroot/build/",
    "/buildroot/output/",
    "/tmp/",
    "/dl/",
  }

  for _, marker in ipairs(markers) do
    if path:find(marker, 1, true) then
      return true
    end
  end

  return false
end

local function source_score(path)
  local score = 100

  if path:find("/fep_source/src/", 1, true) then
    score = score - 40
  end
  if path:find("/platform/src/", 1, true) then
    score = score - 30
  end
  if path:find("/enterprise_gateway/tplink/", 1, true) then
    score = score - 20
  end
  if is_generated_source(path) then
    score = score + 100
  end

  return score
end

local function get_preferred_source_roots(workspace_root)
  local candidate_roots = {
    workspace_root .. "/fep_source/src",
    workspace_root .. "/platform/src",
    workspace_root .. "/enterprise_gateway/tplink",
    workspace_root .. "/enterprise_gateway/package",
  }

  return vim.tbl_filter(function(path)
    return vim.fn.isdirectory(path) == 1
  end, candidate_roots)
end

local function dedupe_paths(paths)
  local seen = {}
  local result = {}

  for _, path in ipairs(paths) do
    if path and path ~= "" and not seen[path] then
      seen[path] = true
      table.insert(result, path)
    end
  end

  return result
end

local function find_definition_by_symbol(base_name, symbol, roots)
  local matches = {}
  local pattern = [[\b]] .. symbol .. [[\s*\(]]

  for _, root in ipairs(roots) do
    local cmd = {
      "rg",
      "--line-number",
      "--color",
      "never",
      "--glob",
      "**/" .. base_name .. ".c",
      pattern,
      root,
    }

    local result = vim.system(cmd, { text = true }):wait()
    if result.code == 0 and result.stdout and result.stdout ~= "" then
      for line in result.stdout:gmatch("[^\r\n]+") do
        local path = line:match("^([^:]+):%d+:")
        if path and not is_generated_source(path) then
          table.insert(matches, path)
        end
      end
    end
  end

  matches = dedupe_paths(matches)
  table.sort(matches, function(a, b)
    local score_a = source_score(a)
    local score_b = source_score(b)
    if score_a == score_b then
      return a < b
    end
    return score_a < score_b
  end)

  return matches[1]
end

local function find_preferred_c_file(base_name, header_path, current_file, symbol)
  local same_dir = header_path:gsub("%.h$", ".c")
  if vim.fn.filereadable(same_dir) == 1 then
    return same_dir
  end

  local search_root = find_workspace_root(current_file)
  local source_roots = get_preferred_source_roots(search_root)

  if symbol and symbol ~= "" then
    local symbol_match = find_definition_by_symbol(base_name, symbol, source_roots)
    if symbol_match then
      return symbol_match
    end
  end

  local candidates = {}
  for _, root in ipairs(source_roots) do
    vim.list_extend(candidates, vim.fn.globpath(root, "**/" .. base_name .. ".c", false, true))
  end

  candidates = dedupe_paths(candidates)
  if not candidates or vim.tbl_isempty(candidates) then
    return nil
  end

  candidates = vim.tbl_filter(function(path)
    return vim.fn.filereadable(path) == 1
  end, candidates)

  table.sort(candidates, function(a, b)
    local score_a = source_score(a)
    local score_b = source_score(b)
    if score_a == score_b then
      return a < b
    end
    return score_a < score_b
  end)

  return candidates[1]
end

vim.api.nvim_create_user_command("ClangdGotoDefinition", function()
  local client = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })[1]
  if not client then
    return
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  local original_word = vim.fn.expand("<cword>")
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
    if err or not result then
      return
    end

    local locations = vim.islist(result) and result or { result }
    for _, location in ipairs(locations) do
      local direct_uri = location.uri or location.targetUri
      local direct_path = vim.uri_to_fname(direct_uri)
      if not direct_path:match("%.h$") then
        vim.lsp.util.jump_to_location(location, client.offset_encoding)
        return
      end
    end

    local uri = locations[1].uri or locations[1].targetUri
    local filepath = vim.uri_to_fname(uri)

    if not filepath:match("%.h$") then
      vim.lsp.util.jump_to_location(locations[1], client.offset_encoding)
      return
    end

    local base_name = filepath:match("([^/]+)%.h$")
    local c_file = find_preferred_c_file(base_name, filepath, current_file, original_word)

    if not c_file or vim.fn.filereadable(c_file) ~= 1 then
      vim.lsp.util.jump_to_location(locations[1], client.offset_encoding)
      return
    end

    vim.cmd("edit " .. vim.fn.fnameescape(c_file))

    vim.fn.cursor(1, 1)
    local found = false
    while true do
      local pos = vim.fn.search("\\<" .. original_word .. "\\>\\s*(", "W")
      if pos == 0 then
        break
      end

      local current_line = vim.fn.line(".")
      for i = current_line, math.min(current_line + 10, vim.fn.line("$")) do
        local line_content = vim.fn.getline(i)
        if line_content:match("{") then
          found = true
          vim.fn.cursor(current_line, 1)
          break
        end
        if line_content:match(";") then
          break
        end
      end

      if found then break end
    end

    if not found then
    end
  end)
end, { desc = "Goto Definition (prefer .c implementation)" })

vim.g.autoformat = false
