local infile = arg[1]
if not infile then
    print("Usage: lua switch_case_blankline.lua <filename>")
    os.exit(1)
end

local lines = {}
for l in io.lines(infile) do
    table.insert(lines, l)
end

local function is_case_line(s)
    return s:match("^%s*case[%w%s_'\"%(%)]*:%s*$")
end
local function is_default_line(s)
    return s:match("^%s*default%s*:%s*$")
end
local function is_case_or_default_line(s)
    return is_case_line(s) or is_default_line(s)
end
local function is_switch_start(s)
    return s:match("^%s*switch")
end
local function is_block_end(s)
    return s:match("^%s*}%s*$")
end
local function is_break_like(s)
    return s:match("^%s*break%s*;") or s:match("^%s*return") or s:match("^%s*continue%s*;") or s:match("^%s*goto%s+")
end

-- main
local out = {}
local i = 1
local in_switch = false
while i <= #lines do
    local line = lines[i]
    local stripped = line:match("^%s*(.-)%s*$") or ""

    if is_switch_start(stripped) then
        in_switch = true
    end

    table.insert(out, line)

    -- Inside switch block
    if in_switch and is_break_like(stripped) then
        -- Check lines until next non-empty
        local j = i + 1
        local blanks = 0
        while lines[j] and lines[j]:match("^%s*$") do
            blanks = blanks + 1
            j = j + 1
        end

        if lines[j] and is_case_or_default_line(lines[j]) then
            -- Ensure exactly one blank line present
            if blanks ~= 1 then
                -- Remove all blank lines
                while out[#out] and out[#out]:match("^%s*$") do
                    table.remove(out)
                end
                -- Add a single blank line
                table.insert(out, "")
            end
        end
    end

    if in_switch and is_block_end(stripped) then
        in_switch = false
    end

    i = i + 1
end

local f = io.open(infile, "w")
for _, l in ipairs(out) do
    f:write(l.."\n")
end
f:close()
