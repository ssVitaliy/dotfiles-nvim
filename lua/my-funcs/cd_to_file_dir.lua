local M = {}

--- Change working directory to current file's location
--- @param silent? boolean If true, suppresses notifications
function M.cd_to_file_dir(opts)
	local buf_path = vim.api.nvim_buf_get_name(0)
	local target_dir

	-- Determine target directory
	if buf_path ~= "" then
		target_dir = vim.fs.dirname(buf_path)
	else
		vim.notify("No file in buffer and no fallback path provided", vim.log.levels.WARN)
		return false
	end

	-- Validate directory exists
	if vim.fn.isdirectory(target_dir) == 0 then
		vim.notify(("Directory does not exist: %s"):format(target_dir), vim.log.levels.ERROR)
		return false
	end

	-- Execute CD
	vim.cmd.cd(target_dir)
	if not opts.silent then
		vim.notify(("CD: %s"):format(target_dir), vim.log.levels.INFO)
	end

	return true
end

--- Setup commands and autocommands
function M.setup()
	-- Main command
	vim.api.nvim_create_user_command("Cdf", function(cmd_opts)
		M.cd_to_file_dir({
			silent = not cmd_opts.bang,
		})
	end, {
		bang = true,
		nargs = 0,
		desc = "Change to current file's dir (fallback: arg)",
	})
end

return M
