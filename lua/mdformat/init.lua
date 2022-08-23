local python_fence = vim.treesitter.parse_query(
"markdown",
[[
(fenced_code_block
  (info_string) @info (#eq? @info "python")
  (code_fence_content) @python
) 
  ]]
)


local get_root = function(bufnr)
    local parser = vim.treesitter.get_parser(bufnr, 'markdown', {})
    local tree = parser:parse()[1]
    return tree:root()
end

local format_python = function(text)
    local handle = io.popen('black -c "' .. text:gsub('"', '\\"') .. '" 2>/dev/null', 'r')
    local formatted_text = handle:read('*a')
    local close = handle:close()
    if formatted_text == "" then
        return nil
    end
    lines = {}
    for s in formatted_text:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    return lines
end

local md_format = function(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()

      if vim.bo[bufnr].filetype ~= 'markdown' then
          vim.notify "can only be used in python"
          return
      end

    local root = get_root(bufnr)
    local changes = {}
    for id, node in python_fence:iter_captures(root, bufnr, 0, -1) do
        local name = python_fence.captures[id]
        if name == 'python' then

            local range  = { node:range() }
            local indentation = string.rep(" ", range[2])


            local formatted = format_python(vim.treesitter.get_node_text(node, bufnr))
            if formatted ~= nil then
                for idx, line in ipairs(formatted) do
                    formatted[idx] = indentation .. line
                end

                table.insert(changes, 1, {
                    start = range[1],
                    final = range[3],
                    formatted = formatted,
                })
            end
        end
    end

    for _, change in ipairs(changes) do
        vim.api.nvim_buf_set_lines(bufnr, change.start, change.final, false, change.formatted)
    end
end

vim.api.nvim_create_user_command('MdFormat', function()
    md_format()
end, {})
    
vim.api.nvim_create_augroup("mdformat", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = "mdformat",
    pattern = { "*.md", },
    command = "MdFormat",
})
