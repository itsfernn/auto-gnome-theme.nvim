local M = {}

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
local function on_event(_, data)
	vim.schedule(function()
		if string.find(data, "dark") then
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

	-- 1. INITIAL STATE: Get current setting synchronously
	local mode = vim.fn.systemlist({"gsettings", "get", "org.gnome.desktop.interface", "color-scheme"})[1]
	mode = mode == "'prefer-dark'" and "dark" or "light"
	local theme = get_theme(mode)
	vim.cmd("colorscheme " .. theme)
	vim.o.background = mode

	-- 2. MONITOR: Start background job
	if M.sysObj then
		M.sysObj:kill("sigterm")
	end

	M.sysObj = vim.system({ "gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme" }, {
		stdout = on_event,
	})
end

return M
