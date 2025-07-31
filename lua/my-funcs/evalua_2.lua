local M = {}

function M.setup()
    -- Create user command
    vim.api.nvim_create_user_command('LuaEvalAppend', M.eval_and_append, { range = true })

    -- Set up key mappings
    vim.keymap.set({ 'n', 'v' }, '<leader>ee', M.eval_and_append, {
        desc = "Evaluate Lua and append result as comment"
    })
end

function M.eval_and_append()
    -- Selection handling
    local mode = vim.fn.mode()
    local has_visual = mode:match('[vV]')
    local start_line, end_line, start_col, end_col

    if has_visual then
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        start_line, end_line = start_pos[2], end_pos[2]
        start_col, end_col = start_pos[3], end_pos[3]
    else
        start_line = vim.fn.line('.')
        end_line = start_line
        start_col, end_col = 1, #vim.fn.getline(start_line)
    end

    -- Extract selected text
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
    else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
    local selected_text = table.concat(lines, '\n')

    -- Evaluation logic
    local result, output = nil, {}
    local chunk, err = loadstring('return ' .. selected_text) or loadstring(selected_text)

    if chunk then
        local success, eval_result = pcall(chunk)
        if success then
            result = eval_result
        else
            output = { '-- [Runtime Error] ' .. eval_result }
        end
    else
        output = { '-- [Syntax Error] ' .. err }
    end

    -- Format output
    if result ~= nil then
        output = type(result) == 'table'
            and vim.split(vim.inspect(result), '\n')
            or { tostring(result) }
        for i, line in ipairs(output) do
            output[i] = '-- ' .. line
        end
    end

    -- Insert results if any
    if #output > 0 then
        if vim.api.nvim_buf_get_lines(0, end_line, end_line + 1, false)[1] ~= '' then
            table.insert(output, 1, '')
        end
        vim.api.nvim_buf_set_lines(0, end_line, end_line, false, output)
        vim.defer_fn(function()
            vim.api.nvim_win_set_cursor(0, { end_line + 1, 0 })
        end, 10)
    end
end

return M
