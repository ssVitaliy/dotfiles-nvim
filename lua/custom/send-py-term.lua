local M = {}

M.config = {
	pane_id = nil,
}

local buff_id = 0
local anchor = "##"

local PY_SUITE_CONTINUATION_PATTERNS = {
	"^elif%s",
	"^else%s*:$",
	"^except%s",
	"^except%s*:$",
	"^finally%s*:$",
	"^case%s",
}

local PY_PROMPT_PATTERNS = {
	">>>%s*$",
	"In %[%d+%]:%s*$", -- IPython
}

local function notify_err(msg)
	vim.notify(msg, vim.log.levels.ERROR)
end

local function notify_warn(msg)
	vim.notify(msg, vim.log.levels.WARN)
end

local function trim(s)
	return vim.trim(s or "")
end

local function system_call(argv)
	local result = vim.fn.system(argv)
	if vim.v.shell_error ~= 0 then
		return nil, trim(result)
	end
	return result, nil
end

local function wezterm_cli(args)
	local argv = { "wezterm" }
	vim.list_extend(argv, args)

	local out, err = system_call(argv)
	if not out then
		notify_err("WezTerm command failed: " .. table.concat(argv, " ") .. (err ~= "" and ("\n" .. err) or ""))
		return nil
	end

	return out
end

local function wezterm_send_text(pane_id, text, no_paste)
	local args = {
		"cli",
		"send-text",
		"--pane-id",
		tostring(pane_id),
	}
	if no_paste then
		table.insert(args, "--no-paste")
	end
	table.insert(args, text)

	return wezterm_cli(args) ~= nil
end

local function parse_pane_id(value)
	local n = tonumber(trim(value))
	if not n then
		return nil
	end
	return n
end

local function is_python_prompt(text)
	local cleaned = trim(text)
	for _, pattern in ipairs(PY_PROMPT_PATTERNS) do
		if cleaned:match(pattern) then
			return true
		end
	end
	return false
end

local function is_suite_continuation_line(line)
	local stripped = line:gsub("^%s+", "")
	for _, pattern in ipairs(PY_SUITE_CONTINUATION_PATTERNS) do
		if stripped:match(pattern) then
			return true
		end
	end
	return false
end

local function get_bounded_lines()
	local lines = vim.api.nvim_buf_get_lines(buff_id, 0, -1, false)
	if #lines == 0 then
		return {}
	end

	local cursor_pos = vim.fn.getpos(".")[2]
	local start_mark = 1
	local end_mark = #lines

	for i = cursor_pos, 1, -1 do
		if vim.startswith(lines[i], anchor) then
			start_mark = i
			break
		end
	end

	for i = cursor_pos, #lines do
		if vim.startswith(lines[i], anchor) then
			end_mark = i - 1
			break
		end
	end

	if end_mark < start_mark then
		return {}
	end

	return vim.api.nvim_buf_get_lines(buff_id, start_mark - 1, end_mark, false)
end

local function prepare_lines(lines)
	if type(lines) ~= "table" or #lines == 0 then
		return nil
	end

	local base_indent = nil
	local block_start = nil

	for i, line in ipairs(lines) do
		if line:match("%S") and not line:match("^%s*#") then
			base_indent = #(line:match("^%s*") or "")
			block_start = i
			break
		end
	end

	if not base_indent or not block_start then
		return nil
	end

	local result = {}
	local prev_indent = nil
	local prev_was_empty = false

	for i = block_start, #lines do
		local line = lines[i]

		if not line:match("%S") then
			table.insert(result, "")
			prev_was_empty = true
		else
			local current_indent = #(line:match("^%s*") or "")
			if current_indent < base_indent then
				-- outside selected logical block
			else
				local normalized = line:sub(base_indent + 1)
				local normalized_indent = #(normalized:match("^%s*") or "")

				if
					prev_indent
					and normalized_indent < prev_indent
					and current_indent == 0
					and not prev_was_empty
					and not is_suite_continuation_line(normalized)
				then
					table.insert(result, "")
				end

				table.insert(result, normalized)
				prev_indent = normalized_indent
				prev_was_empty = false
			end
		end
	end

	while #result > 0 and result[#result] == "" do
		table.remove(result)
	end

	if #result == 0 then
		return nil
	end

	local last = result[#result]
	if last:match("^%s+") then
		table.insert(result, "")
	end

	return result
end

local function term_send_one_line(line)
	if type(line) ~= "string" then
		return false
	end
	if not M.config.pane_id then
		notify_warn("Target pane is not set")
		return false
	end

	local ok = wezterm_send_text(M.config.pane_id, line, true)
	if not ok then
		return false
	end

	return wezterm_send_text(M.config.pane_id, "\r", true)
end

local function term_send_lines(lines)
	if type(lines) ~= "table" or #lines == 0 then
		return false
	end

	for _, line in ipairs(lines) do
		local ok = term_send_one_line(line)
		if not ok then
			return false
		end
	end

	return true
end

local function run_wezterm_command(cmd)
	local full_cmd = { "sh", "-c", "wezterm " .. cmd }
	local result = vim.fn.system(full_cmd)

	if vim.v.shell_error ~= 0 then
		notify_err("WezTerm command failed: wezterm " .. cmd)
		return nil
	end

	return result
end

local function get_non_active_pane_ids_list()
	local result = wezterm_cli({ "cli", "list", "--format", "json" })
	if not result then
		return nil
	end

	local ok, panes = pcall(vim.json.decode, result)
	if not ok or type(panes) ~= "table" then
		notify_err("Failed to decode WezTerm pane list")
		return nil
	end

	local non_active_panes = {}

	for _, pane in ipairs(panes) do
		if pane and not pane.is_active and pane.pane_id then
			table.insert(non_active_panes, pane.pane_id)
		end
	end

	return non_active_panes
end

local function find_pypane(pane_ids_list)
	if type(pane_ids_list) ~= "table" or #pane_ids_list == 0 then
		return nil
	end

	for _, pane_id in ipairs(pane_ids_list) do
		local pane_text = wezterm_cli({
			"cli",
			"get-text",
			"--pane-id",
			tostring(pane_id),
		})

		if pane_text and is_python_prompt(pane_text) then
			return tonumber(pane_id)
		end
	end

	return nil
end

local function create_pypane()
	local current_dir = vim.fn.getcwd()
	local pane_id = wezterm_cli({
		"cli",
		"split-pane",
		"--percent",
		"30",
		"--cwd",
		current_dir,
	})

	return parse_pane_id(pane_id)
end

local function activate_venv_in_pane(pane_id)
	local cwd = vim.fn.getcwd()

	local candidates = {
		{ path = cwd .. "/.venv/bin/activate", cmd = "source .venv/bin/activate" },
		{ path = cwd .. "/.venv/Scripts/activate", cmd = "source .venv/Scripts/activate" },
		{ path = cwd .. "/.venv/Scripts/activate.bat", cmd = ".venv\\Scripts\\activate.bat" },
	}

	for _, item in ipairs(candidates) do
		if vim.fn.filereadable(item.path) == 1 then
			term_send_one_line(item.cmd:gsub("^", "")) -- pane_id already set later
			return true
		end
	end

	return false
end

local function get_pypane()
	local pane_id = find_pypane(get_non_active_pane_ids_list())
	if pane_id then
		return pane_id
	end

	pane_id = create_pypane()
	if not pane_id then
		return nil
	end

	local old_pane_id = M.config.pane_id
	M.config.pane_id = pane_id
	activate_venv_in_pane(pane_id)
	M.config.pane_id = old_pane_id

	return pane_id
end

function M.send_selected()
	local start_line = vim.fn.getpos("v")[2] - 1
	local end_line = vim.fn.getpos(".")[2]

	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local lines = vim.api.nvim_buf_get_lines(buff_id, start_line, end_line, false)
	local prepared = prepare_lines(lines)
	if not prepared or #prepared == 0 then
		return
	end

	term_send_lines(prepared)
end

function M.send_line()
	local line = vim.api.nvim_get_current_line():match("%S+.*")
	if not line then
		return
	end

	term_send_one_line(line)
end

function M.send_bounded()
	local prepared = prepare_lines(get_bounded_lines())
	if not prepared or #prepared == 0 then
		return
	end

	term_send_lines(prepared)
end

function M.set_pane_id(args)
	M.config.pane_id = nil

	if args and args.fargs and #args.fargs == 1 then
		M.config.pane_id = tonumber(args.fargs[1])
	else
		M.config.pane_id = get_pypane()
	end

	if M.config.pane_id then
		print("Config done. Target pane =", M.config.pane_id)
	else
		notify_warn("Failed to resolve target pane")
	end
end

local function find_or_create_pyout_window()
	local buf_handle = nil
	local win_handle = nil

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(buf)
		if buf_name == "pyout" or buf_name:match("pyout$") then
			buf_handle = buf
			break
		end
	end

	if buf_handle then
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == buf_handle then
				return buf_handle, win
			end
		end
	end

	vim.cmd("vsplit")
	win_handle = vim.api.nvim_get_current_win()

	if not buf_handle then
		buf_handle = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf_handle, "pyout")
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf_handle })
		vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf_handle })
		vim.api.nvim_set_option_value("swapfile", false, { buf = buf_handle })
		vim.api.nvim_set_option_value("filetype", "text", { buf = buf_handle })
	end

	vim.api.nvim_win_set_buf(win_handle, buf_handle)
	return buf_handle, win_handle
end

local function pick_python_executable()
	local candidates = {
		"./.venv/bin/python",
		"./.venv/Scripts/python.exe",
		"python",
	}

	for _, exe in ipairs(candidates) do
		if exe == "python" or vim.fn.filereadable(exe) == 1 then
			return exe
		end
	end

	return "python"
end

local function run_python_to_split()
	local current_file = vim.fn.expand("%:p")
	local python_exec = pick_python_executable()

	local output, err = system_call({ python_exec, current_file })
	if not output then
		output = err or ""
	end

	local origin_win = vim.api.nvim_get_current_win()
	local buf_handle, win_handle = find_or_create_pyout_window()

	local current_lines = vim.api.nvim_buf_get_lines(buf_handle, 0, -1, false)
	local new_lines = {}

	if #current_lines > 0 and current_lines[#current_lines] ~= "" then
		table.insert(new_lines, "")
	end

	table.insert(
		new_lines,
		"─── " .. os.date("%H:%M:%S") .. " ─── " .. vim.fn.fnamemodify(current_file, ":t") .. " ───"
	)
	table.insert(new_lines, "")

	for _, line in ipairs(vim.split(output, "\n", { plain = true })) do
		table.insert(new_lines, line)
	end

	vim.api.nvim_buf_set_lines(buf_handle, -1, -1, false, new_lines)

	local last_line = vim.api.nvim_buf_line_count(buf_handle)
	vim.api.nvim_win_set_cursor(win_handle, { last_line, 0 })

	if vim.api.nvim_win_is_valid(origin_win) then
		vim.api.nvim_set_current_win(origin_win)
	end
end

function M.setup()
	vim.api.nvim_create_user_command("SendPyTermBuffer", M.set_pane_id, { nargs = "?" })

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function(args)
			buff_id = args.buf

			vim.keymap.set("n", "<F5>", M.set_pane_id, {
				buffer = args.buf,
				desc = "Set python terminal pane",
			})

			vim.keymap.set("n", "<leader>el", function()
				M.send_line()
			end, {
				buffer = args.buf,
				desc = "Send current line to python REPL",
			})

			vim.keymap.set("v", "<leader>er", M.send_selected, {
				buffer = args.buf,
				desc = "Send selected range to python REPL",
			})

			vim.keymap.set("n", "<leader>er", function()
				M.send_bounded()
			end, {
				buffer = args.buf,
				desc = "Send bounded block to python REPL",
			})

			vim.keymap.set("n", "<leader>ef", function()
				vim.cmd("write")
				run_python_to_split()
			end, {
				buffer = args.buf,
				desc = "Run whole file and append output to split",
			})
		end,
	})
end

return M
