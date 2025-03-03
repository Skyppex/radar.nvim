local M = {}

M.ip = "127.0.0.1:4293"

M.server_job = nil

local function start_server()
	if M.server_job then
		vim.notify("Server is already running!", vim.log.levels.WARN)
		return
	end

	M.server_job = vim.fn.jobstart({ "radard" }, {
		on_stdout = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" then
					vim.notify("Radar daemon: " .. line, vim.log.levels.ERROR)
				end
			end
		end,
		on_stderr = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" then
					vim.notify("Radar daemon error: " .. line, vim.log.levels.ERROR)
				end
			end
		end,
		on_exit = function()
			M.server_job = nil
			vim.notify("Radar daemon stopped")
		end,
	})

	if M.server_job == 0 or M.server_job == -1 then
		vim.notify("Failed to start radar daemon", vim.log.levels.ERROR)
		M.server_job = nil
	else
		vim.fn.serverstart(M.ip)
		vim.notify("Radar daemon started")
	end
end

local function stop_server()
	vim.fn.serverstop(M.ip)

	if M.server_job then
		vim.fn.jobstop(M.server_job)
		M.server_job = nil
	else
		vim.notify("Radar daemon is not running!", vim.log.levels.WARN)
	end
end

function M.setup()
	vim.api.nvim_create_user_command("RadarStart", function()
		start_server()
	end, { desc = "Starts the nvim server and the radar daemon" })

	vim.api.nvim_create_user_command("RadarStop", function()
		stop_server()
	end, { desc = "Kills the radar daemon" })
end

return M
