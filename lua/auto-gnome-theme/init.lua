local M = {}
local job_id = nil

-- Default configuration
local config = {
	theme = nil, -- Fallback theme (used if specific light/dark not set)
	dark_theme = nil, -- Specific theme for dark mode
	light_theme = nil, -- Specific theme for light mode
}

-- Helper: Determine which colorscheme name to use
local function get_theme(mode)
	local theme = nil
	if mode == "dark" then
		theme = config.dark_theme
	elseif mode == "light" then
		theme = config.light_theme
	end

	return theme or config.theme or "default"
end

-- Job Handler: Process gsettings output
local function on_event(_, data, _)
	local output = table.concat(data, "")
	-- Clean whitespace
	output = output:gsub("%s+", "")

	vim.schedule(function()
		if string.find(output, "dark") then
			vim.o.background = "dark"
			if config.dark_theme then
				vim.cmd("colorscheme " .. config.dark_theme)
			end
		else
			vim.o.background = "light"
			if config.light_theme then
				vim.cmd("colorscheme " .. config.light_theme)
			end
		end
	end)
end

function M.setup(user_opts)
	-- Merge user config
	config = vim.tbl_deep_extend("force", config, user_opts or {})

	-- Sanity check: is gsettings installed?
	if vim.fn.executable("gsettings") == 0 then
		vim.notify("gnome-theme: gsettings not found. Auto-switching disabled.", vim.log.levels.WARN)
		return
	end

	if vim.fn.executable("gnome_system_theme") == 0 then
		vim.notify("gnome-theme: gnome-system-theme not found. Auto-switching disabled.", vim.log.levels.WARN)
		return
	end

	-- 1. INITIAL STATE: Get current setting synchronously
	local mode = vim.fn.system("gnome_system_theme"):gsub("%s+", "")
	local theme = get_theme(mode)
	vim.cmd("colorscheme " .. theme)
	vim.o.background = mode

	-- 2. MONITOR: Start background job
	if job_id then
		vim.fn.jobstop(job_id)
	end

	job_id = vim.fn.jobstart({ "gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme" }, {
		on_stdout = on_event,
		on_stderr = function() end,
		detach = true,
	})
end

return M
