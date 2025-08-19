local M = {}

-- package.loaded['funcs.tmp.spt'] = nil
-- vim.fn.systemlist('wezterm cli send-text --pane-id 1 --no-paste "n\'i"')

M.config = {}
M.config.pane_id = 1
local buff_id = 0
local anchor = "#-"

-- NICE but need in optimization
-- Now we get whole buffer. This method not optimal, if buffer have many lines (>200).
-- Much better to store bounds, on each call check changes, update if necessary.
-- Also we can load buffer by parts, by 100 lines for example.
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

local function prepare_lines(lines)
	-- Determine indent by the first non-blank line, unindent whole block
	local result_lines = {}
	local effective_line_pos = nil
	local block_start = 1

	for n, line in ipairs(lines) do
		if line:sub(1, 1) ~= "#" then
			local finder = line:find("[^%s]")
			if finder then
				effective_line_pos = finder
				block_start = n
				break
			end
		end
	end

	if not effective_line_pos then
		return nil
	end

	for i = block_start, #lines do
		local line = lines[i]
		-- break on lines with something on indent area
		if line:sub(1, effective_line_pos - 1):find("[^%s]") then
			break
		else
			table.insert(result_lines, line:sub(effective_line_pos, -1))
		end
	end

	-- if last line not empty then add <CR> (empty line) to eval block
	if result_lines[#result_lines]:match("^%s") then
		table.insert(result_lines, "")
	end

	return result_lines
end

local function term_send_one_line(line)
	-- stylua: ignore
	local cli_prefix = string.format(
		"wezterm cli send-text --pane-id %s --no-paste ", M.config.pane_id)
	local cmd_enter = cli_prefix .. "$'\\r'"

	local cmd = cli_prefix .. "'" .. escape_line(line) .. "'"
	-- system call: send to term
	vim.fn.systemlist(cmd)
	vim.fn.systemlist(cmd_enter)
	-- print(cmd)
end

local function term_send_lines(lines)
	for _, line in ipairs(lines) do
		term_send_one_line(line)
	end
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
	lines = prepare_lines(lines)
	term_send_lines(lines)
end

-- GOOD
function M.send_line()
	local line = vim.api.nvim_get_current_line()
	term_send_one_line(line)
	print("line sended")
end

function M.send_bounded()
	-- term_send_lines(prepare_lines(get_bounded_lines()))

	local bounds = get_bounded_lines()
	for _, line in ipairs(bounds) do
		print(line)
	end
	print("len bounds:", #bounds)
	local prepared = prepare_lines(bounds)
	print(prepared)

	term_send_lines(prepared)
end

function M.send_whole_file()
	term_send_one_line("python " .. vim.fn.expand("%:p"))
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
