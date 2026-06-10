local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")


local M = {}

port = { value = nil }
local left_port = { value = nil }
local right_port = { value = nil }

local ToggleTerminal = require("toggleterm.terminal")
local Terminal = require("toggleterm.terminal").Terminal

local CustomTerm = {}
CustomTerm.__index = CustomTerm
setmetatable(CustomTerm, {__index = Terminal})

function CustomTerm:new(cterm)
	local instance = Terminal.new(self, cterm)
	setmetatable(instance, CustomTerm)
	instance.mode = cterm.mode
	instance.isExecutingMonitor = false
	return instance
end

function CustomTerm:open(size, direction)
	Terminal.open(self, size, direction)
	Terminal.set_mode(self, self.mode)
end

function CustomTerm:toggle(size, direction)
	if not Terminal.is_open(self) then
		Terminal.open(self, size, direction)
		Terminal.set_mode(self, self.mode)
	else
		self:close()
	end
end

function CustomTerm:switch_direction( direction)
	if self:is_open() then
		self:close()
	end

	self:open(size, direction)
end


function CustomTerm:exec(args)
	local command = args.command
	local isMonitoring = args.isMonitoring
	local on_done_callback = args.on_done_callback

	if on_done_callback or isMonitoring then
		command = string.format(
			[[%s; nvim --server $NVIM --remote-send \
			"<cmd>lua require('workflow')._trigger_callback(%d, $?)<cr>"]],
			command,
			self.id
		)
		if type(on_done_callback) == "function" then
			self.on_done_callback = on_done_callback
		end
	end

	if self.isExecutingMonitor then
		self.monitoring_callback = function(self)
			print(tostring(self.id))
			
			vim.defer_fn(function()
				self:send(command)
				if isMonitoring then
					self.isExecutingMonitor = true
				end

			end, 900)
		end
		self:send("\x1d")

	else
		self:send(command)
		if isMonitoring then
			self.isExecutingMonitor = true
		end
	end
	
	if not self:is_open() then
		self:open()
	end

end

local MC = CustomTerm:new({
					cmd = "idf.py menuconfig",
					hidden = true ,
					direction = "float",
					mode = 'i',
					float_opts = { border = "curved" },
				})

local LG = CustomTerm:new({
					cmd = "lazygit",
					hidden = true,
					direction = "float",
					mode = 'i',
					float_opts = { border = "curved" },
				})

local BFM = CustomTerm:new({
					hidden = true,
					direction = "float",
					mode = 'n',
					float_opts = { border = "curved" },
				})

local multi_mode = false
local devices = {}

M.setup = function()
	MC:spawn()
	LG:spawn()
	BFM:spawn()
end

M.setNumberOfDevices = function(n)
	for i, device in ipairs(devices) do
		device.term:shutdown()
	end

	devices = {}

	if n <= 1 then
		multi_mode = false
	else
		multi_mode = true

		for i = 1, n do
			local direction = "horizontal"
			if i % 3 == 1 then
				direction = "tab"
			end

			table.insert(
				devices,
				{
					port = { value = nil },
					term = CustomTerm:new({
						hidden = true,
						direction = direction,
						mode = "n"
					})
				}
			)
			devices[i].term:spawn()

			if i % 3 == 1 then
				vim.t.tabpage_name = "Devices"
			end
		end
	end
end

vim.api.nvim_create_user_command(
	'Wf',
	function(opts)
		local arg = opts.args

		local nombre = tonumber(arg)

		if nombre then
			M.setNumberOfDevices(nombre)
		end
	end,
	{
		nargs = 1,
	}
)

M.getDevicesUnsetPort = function()
	for i, device in ipairs(devices) do
		if not device.port.value then
			return device.port
		end
	end
	return nil
end

M._trigger_callback = function(terminalID, exit_code)
	term = ToggleTerminal.get(terminalID, true)

	if term then
		if term.isExecutingMonitor then
			term.isExecutingMonitor = false
			
			if term.monitoring_callback then
				term:monitoring_callback()
				term.monitoring_callback = nil
			end
			
		elseif type(term.on_done_callback) == "function" then
			term:on_done_callback(exit_code)
			term.on_done_callback = nil

		end
	else
		print("terminal not found " .. tostring(terminalID))
	end
end

M.selectDevicesPortBeforeAction = function(action, cmd)
	local unsetDevicePort = M.getDevicesUnsetPort()

	if unsetDevicePort then
		M.selectPort(action, unsetDevicePort)
		return false
	else
		return true
	end
end

M.executeCommandOnDevices = function(args)
	local commandToFormat = args.command
	for i, device in ipairs(devices) do
		args.command = string.format(commandToFormat, device.port.value)
		device.term:exec(args)
	end
end

M.execBuildFlash = function ()
	if not multi_mode then
		if not port.value then
			M.selectPort(M.execBuildFlash, port)
		else
			BFM:exec({ command = "idf.py --port " .. port.value .. " flash"})
		end

	elseif M.selectDevicesPortBeforeAction(M.execBuildFlash) then
		BFM:exec({
			command = "idf.py build",
			on_done_callback = function(self, exit_code)
				if exit_code == 0 then
					M.executeCommandOnDevices({
						command = "idf.py --port %s flash"
					})
				else
					print("error " .. tostring( exit_code))
				end
			end
		})
	end
end

M.execMonitor = function ()
	if not multi_mode then
		if not port.value then
			M.selectPort(M.execMonitor, port)
		else
			BFM:exec({
				command = "idf.py --port " .. port.value .. " monitor",
				isMonitoring = true
			})
		end
	elseif M.selectDevicesPortBeforeAction(M.execMonitor) then
		M.executeCommandOnDevices({
			command = "idf.py --port %s monitor",
			isMonitoring = true
		})
	end
end

M.execBuildFlashMonitor = function ()
	if not multi_mode then
		if not port.value then
			M.selectPort(M.execBuildFlashMonitor, port)
		else

			BFM:exec({
				command = "idf.py --port " .. port.value .. " flash monitor",
				isMonitoring = true
			})
		end
	elseif M.selectDevicesPortBeforeAction(M.execBuildFlashMonitor) then
		BFM:exec({
			command = "idf.py build",
			on_done_callback = function(self, exit_code)
				if exit_code == 0 then
					M.executeCommandOnDevices({
						command = "idf.py --port %s flash monitor",
						isMonitoring = true
					})
				else
					print("error" .. tostring(exit_code))
				end
			end
		})
	end
end

M.execFullClean = function ()
	BFM:exec({ command = "idf.py fullclean" })
end


M.toggleBFM = function ()
	BFM:toggle()
end

M.toggleMC = function ()
	MC:toggle()
end

M.toggleLG = function()
	LG:toggle()	
end

M.closeActive = function(force)
	if BFM:is_open() then
		BFM:close()
	end

	if MC:is_open() then
		MC:close()
	end

	if LG:is_open() and force then
		LG:close()
	end
end

M.moveLGFloat = function()
	LG:switch_direction('float')
end

M.moveLGHori = function()
	LG:switch_direction('horizontal')
end

M.moveLGVert = function()
	LG:switch_direction('vertical')
end

M.moveMCFloat = function()
	MC:switch_direction("float")
end

M.moveMCHori = function()
	MC:switch_direction("horizontal")
end

M.moveMCVert = function()
	MC:switch_direction("vertical")
end

M.moveBFMFloat = function()
	BFM:switch_direction('float')
end

M.moveBFMHori = function()
	BFM:switch_direction('horizontal')
end

M.moveBFMVert = function()
	BFM:switch_direction('vertical')
end

M.selectPort = function(action, portToChoose)

	pickers.new({}, {
		prompt_title = "Choose port:",
		theme = nil,
		finder = finders.new_oneshot_job(
			{ "sh", "-c", "fd ttyACM /dev && fd ttyUSB /dev"}
		),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()

				if selection then
					portToChoose.value = selection.value

				end

				if action then
					action()
				end
			end)
			return true
		end,
	}):find()
end

M.choosePort = function()
	if not multi_mode then
		M.selectPort(nil, port)

	else
		M.selectPort(left_port)
		M.selectPort(right_port)

	end
end

M.toggleDualMode = function()
	multi_mode = not multi_mode
end

M.printMode = function()
	if multi_mode then
		return "Multi"
	else
		return "Mono"
	end
end

return M
