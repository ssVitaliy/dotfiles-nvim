local M = {}

function M.eval_and_append()
    -- Check for visual selection
    local mode = vim.fn.mode()
    local has_visual = mode:match('[vV]') ~= nil
    local start_line, end_line, start_col, end_col

    if has_visual then
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        start_line = start_pos[2]
        end_line = end_pos[2]
        start_col = start_pos[3]
        end_col = end_pos[3]
    else
        -- Use current line if no visual selection
        start_line = vim.fn.line('.')
        end_line = start_line
        start_col = 1
        end_col = #vim.fn.getline(start_line)
    end

    -- Get and prepare the selected text
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
    else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end

    local selected_text = table.concat(lines, '\n')

    -- Evaluation with proper error handling
    local result
    local output = {}
    local chunk, err = loadstring('return ' .. selected_text)
    if not chunk then
        chunk, err = loadstring(selected_text)
    end

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

    -- Format the output if we got a result
    if result ~= nil then
        if type(result) == 'table' then
            output = vim.split(vim.inspect(result), '\n')
        else
            output = { tostring(result) }
        end
        -- Add comment markers
        for i, line in ipairs(output) do
            output[i] = '-- ' .. line
        end
    end

    -- Only insert if we have output
    if next(output) ~= nil then
        -- Add spacing if needed
        local next_line_content = vim.api.nvim_buf_get_lines(0, end_line, end_line + 1, false)[1] or ''
        if next_line_content ~= '' then
            table.insert(output, 1, '')
        end

        -- Insert results
        vim.api.nvim_buf_set_lines(0, end_line, end_line, false, output)

        -- Move cursor to first result line
        vim.defer_fn(function()
            vim.api.nvim_win_set_cursor(0, { end_line + 1, 0 })
        end, 10)
    end
end

-- Create user command
vim.api.nvim_create_user_command('LuaEvalAppend', M.eval_and_append, { range = true })

-- Set up key mappings
vim.keymap.set({ 'n', 'v' }, '<leader>ee', M.eval_and_append, { desc = "Eval Lua and append result" })

return M
