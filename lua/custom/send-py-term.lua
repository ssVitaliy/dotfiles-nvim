local M = {}

--== Dev Stuff
-- vim.keymap.set("n", "<F9>", function()
-- 	package.loaded["funcs.tmp.spt"] = nil
-- 	require("funcs.tmp.spt").send_bounded()
-- end)

-- package.loaded['funcs.tmp.spt'] = nil
-- vim.fn.systemlist('wezterm cli send-text --pane-id 1 --no-paste "n\'i"')

local pane_id = 1
local buff_id = 0
local anchor = "#-"

-- NICE but need in optimization
local function get_bounded_lines()
	local lines = vim.api.nvim_buf_get_lines(buff_id, 0, -1, false)
	local start_mark = 1
	local end_mark = #lines
	local cursor_pos = vim.fn.getpos(".")[2]

	for i = cursor_pos, 1, -1 do
		if vim.startswith(lines[i], anchor) then
			start_mark = i
			break
		end
	end

	for i = cursor_pos, end_mark, 1 do
		if vim.startswith(lines[i], anchor) then
			end_mark = i - 1
			break
		end
	end
	return vim.api.nvim_buf_get_lines(buff_id, start_mark - 1, end_mark, false)
end

-- GOOD
local function escape_line(line)
	return line:gsub("'", "'\\''")
end

-- GOOD
local function term_send_line(line)
	-- stylua: ignore
	local cli_prefix = string.format(
		"wezterm cli send-text --pane-id %s --no-paste ", pane_id)
	local cli_enter = cli_prefix .. "$'\\r'"
	local cmd = cli_prefix .. "'" .. escape_line(line) .. "'"

	vim.fn.systemlist(cmd)
	vim.fn.systemlist(cli_enter)
end

-- GOOD
local function get_selected_lines()
	local start_line = vim.fn.getpos("'<")[2] - 1
	local end_line = vim.fn.getpos("'>")[2]

	return vim.api.nvim_buf_get_lines(buff_id, start_line, end_line, false)
end

-- GOOD
function M.send_selected()
	local lines = get_selected_lines()
	for _, line in ipairs(lines) do
		term_send_line(line)
	end
end

-- GOOD
function M.send_line()
	local line = vim.api.nvim_get_current_line()
	term_send_line(line)
end

function M.send_bounded()
	for _, line in ipairs(get_bounded_lines()) do
		-- print(line)
		term_send_line(line)
	end
end

function M.send_whole_file()
	term_send_line("python " .. vim.fn.expand("%:p"))
end

function M.setup()
	-- Keymap only for Python buffers
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function(args)
			vim.keymap.set("n", "<leader>el", function()
				M.send_line()
			end, { buffer = args.buf, desc = "py line" })

			vim.keymap.set("n", "<leader>ev", function()
				M.send_selected()
			end, { buffer = args.buf, desc = "py selected" })

			vim.keymap.set("n", "<leader>eb", function()
				M.send_bounded()
			end, { buffer = args.buf, desc = "py bounded" })

			vim.keymap.set("n", "<leader>ef", function()
				vim.cmd("w")
				M.send_whole_file()
			end, { buffer = args.buf, desc = "PY whole file" })
		end,
	})
end

return M
