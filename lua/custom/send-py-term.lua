local M = {}

-- package.loaded['funcs.tmp.spt'] = nil
-- vim.fn.systemlist('wezterm cli send-text --pane-id 1 --no-paste "n\'i"')

M.config = {}
M.config.pane_id = nil
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

-- Pane control funcs: find, create pane

local function run_wezterm_command(cmd)
	local full_cmd = "wezterm " .. cmd
	local result = vim.fn.system(full_cmd)

	if vim.v.shell_error ~= 0 then
		vim.notify("Wezterm command failed: " .. full_cmd, vim.log.levels.ERROR)
		return nil
	end

	return result
end

local function get_non_active_pane_ids_list()
	local result = run_wezterm_command("cli list --format json")
	if not result then
		return nil
	end

	local ok, panes = pcall(vim.json.decode, result)
	if not ok then
		return nil
	end

	local non_active_panes = {}

	for _, pane in ipairs(panes) do
		if not pane.is_active then
			table.insert(non_active_panes, pane.pane_id)
		end
	end

	return #non_active_panes > 0 and non_active_panes or nil
end

local function find_pypane(pane_ids_list)
	if type(pane_ids_list) ~= "table" or #pane_ids_list == 0 then
		return nil
	end

	for _, pane_id in ipairs(pane_ids_list) do
		local pane_text = run_wezterm_command(string.format("cli get-text --pane-id %d", pane_id))

		if pane_text then
			local cleaned = pane_text:gsub("%s*$", "")
			if #cleaned >= 3 and cleaned:sub(-3, -1) == ">>>" then
				return tonumber(pane_id)
			end
		end
	end
	return nil
end

local function create_pypane()
	local current_dir = vim.fn.getcwd()
	local cmd = string.format([[cli split-pane --percent 30 --cwd %s]], current_dir)
	local pane_id = run_wezterm_command(cmd)
	if pane_id then
		return tonumber(pane_id)
	end
	return nil
end

local function get_pypane()
	local pane_id = find_pypane(get_non_active_pane_ids_list())
	if pane_id then
		return pane_id
	end

	pane_id = create_pypane()

	if pane_id then
		-- try to activate venv
		local cmd = string.format([[cli send-text --pane-id %d "source .venv/Scripts/activate"]], pane_id)
		run_wezterm_command(cmd)
		return pane_id
	end
	return nil
end

-- GOOD
function M.send_selected()
	local start_line = vim.fn.getpos("v")[2] - 1
	local end_line = vim.fn.getpos(".")[2]

	-- Ensure correct order
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local lines = vim.api.nvim_buf_get_lines(buff_id, start_line, end_line, false)
	term_send_lines(prepare_lines(lines))
end

-- GOOD
function M.send_line()
	local line = vim.api.nvim_get_current_line():match("%S+.*")
	term_send_one_line(line)
	print("line sended")
end

function M.send_bounded()
	term_send_lines(prepare_lines(get_bounded_lines()))
end

function M.set_pane_id(args)
	M.config.pane_id = nil
	if args and #args.fargs == 1 then
		M.config.pane_id = tonumber(args.fargs[1])
	elseif not args or #args.fargs == 0 then
		M.config.pane_id = get_pypane()
	end
	print("Config done. Target buffer =", M.config.pane_id)
end

local function run_python_to_split()
	-- Create a vertical split with buffer named "pyout"
	-- Append each run's output with timestamp and filename headers
	-- Maintain the buffer across multiple runs
	-- Scroll to the bottom automatically
	-- Return focus to original window
	--
	-- Start with python as default
	-- Check each path in the list for existence
	-- Use the first one that exists
	-- Break out of the loop once found

	local current_file = vim.fn.expand("%:p")
	local python_exec = "python"
	local python_path_list = { "./.venv/bin/python", "./.venv/Scripts/python.exe" }

	for _, path in ipairs(python_path_list) do
		if vim.fn.filereadable(path) == 1 then
			python_exec = path
			break
		end
	end
	local output = vim.fn.system(python_exec .. " '" .. current_file .. "'")

	-- Find or create pyout buffer
	local buf_handle = nil
	local win_handle = nil

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(buf)
		if string.find(buf_name, "pyout") then
			buf_handle = buf
			break
		end
	end

	if not buf_handle then
		-- Create new vertical split
		vim.api.nvim_command("vsplit")
		buf_handle = vim.api.nvim_create_buf(false, true) -- create scratch buffer
		win_handle = vim.api.nvim_get_current_win()

		-- Set buffer options
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf_handle })
		vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf_handle })
		vim.api.nvim_set_option_value("swapfile", false, { buf = buf_handle })
		vim.api.nvim_set_option_value("filetype", "text", { buf = buf_handle })

		vim.api.nvim_buf_set_name(buf_handle, "pyout")
		vim.api.nvim_win_set_buf(win_handle, buf_handle)
	else
		-- Find window showing this buffer or create one
		local found_win = nil
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == buf_handle then
				found_win = win
				break
			end
		end

		if found_win then
			vim.api.nvim_set_current_win(found_win)
			win_handle = found_win
		else
			vim.api.nvim_command("vsplit")
			win_handle = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(win_handle, buf_handle)
		end
	end

	-- Get current content and prepare new output
	local current_lines = vim.api.nvim_buf_get_lines(buf_handle, 0, -1, false)
	local new_lines = {}

	-- Add separator if not empty
	if #current_lines > 0 and current_lines[#current_lines] ~= "" then
		table.insert(new_lines, "")
		table.insert(
			new_lines,
			"─── "
				.. os.date("%H:%M:%S")
				.. " ─── "
				.. vim.fn.fnamemodify(current_file, ":t")
				.. " ───"
		)
		table.insert(new_lines, "")
	else
		table.insert(
			new_lines,
			"─── "
				.. os.date("%H:%M:%S")
				.. " ─── "
				.. vim.fn.fnamemodify(current_file, ":t")
				.. " ───"
		)
		table.insert(new_lines, "")
	end

	-- Add the actual output
	for _, line in ipairs(vim.split(output, "\n")) do
		table.insert(new_lines, line)
	end

	-- Append to buffer
	vim.api.nvim_buf_set_lines(buf_handle, -1, -1, false, new_lines)

	-- Move cursor to end and ensure window is scrolled to bottom
	local last_line = vim.api.nvim_buf_line_count(buf_handle)
	vim.api.nvim_win_set_cursor(win_handle, { last_line, 0 })

	-- Return to original window
	vim.api.nvim_command("wincmd p")
end

function M.setup()
	-- add command
	vim.api.nvim_create_user_command("SendPyTermBuffer", M.set_pane_id, { nargs = "?" })

	-- Keymap only for Python buffers
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function(args)
			vim.keymap.set("n", "<F5>", M.set_pane_id, { buffer = args.buf, desc = "py line" })

			vim.keymap.set("n", "<leader>el", function()
				M.send_line()
			end, { buffer = args.buf, desc = "py line" })

			vim.keymap.set("v", "<leader>er", M.send_selected, { buffer = args.buf, desc = "py Eval selected Range" })

			vim.keymap.set("n", "<leader>er", function()
				M.send_bounded()
			end, { buffer = args.buf, desc = "py Eval bounded Range" })

			vim.keymap.set("n", "<leader>ef", function()
				vim.cmd("w")
				run_python_to_split()
			end, { buffer = args.buf, desc = "py Eval whole File" })
		end,
	})
end

return M
