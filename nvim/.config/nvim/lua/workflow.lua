local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")


local M = {}

local port = { value = nil }
local left_port = { value = nil }
local right_port = { value = nil }

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


function CustomTerm:exec(cmd, on_done_callback)
	if on_done_callback then
		self.on_done_callback = on_done_callback
	end

	if self.isExecutingMonitor then
		self:send("\x1d")
		self.isExecutingMonitor = false
		vim.defer_fn(function ()
			self:send(cmd)
		end, 300)
	else
		self:send(cmd)
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

local BFM_LEFT = CustomTerm:new({
					hidden = true,
					direction = "tab",
					mode = 'n',
				})

local BFM_RIGHT = CustomTerm:new({
					hidden = true,
					direction = "horizontal",
					mode = 'n',
				})

local multi_mode = false
local devices = {}

M.setup = function()
	MC:spawn()
	LG:spawn()
	BFM:spawn()
	BFM_LEFT:spawn()
	BFM_RIGHT:spawn()
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
			if i == 1 then
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

M._trigger_callback = function(exit_code)
	if BFM.on_done_callback then
		BFM.on_done_callback(exit_code)
		BFM.on_done_callback = nil
	end
end

M.execBuildFlash = function ()
	if not multi_mode then
		if not port.value then
			M.selectPort(M.execBuildFlash, port)
		else
			BFM:exec("idf.py"  .. " --port " .. port.value .. " flash")
		end
	else
		local unsetDevicePort = M.getDevicesUnsetPort()

		if unsetDevicePort then
			M.selectPort(M.execBuildFlash, unsetDevicePort)
		else
			BFM:exec(
				[[idf.py build; nvim --server $NVIM --remote-send \
				"<cmd>lua require('workflow')._trigger_callback($?)<cr>"]],
				
				function(exit_code)
					if exit_code == 0 then
						BFM:close()

						for i, device in ipairs(devices) do
							device.term:exec(
								"idf.py --port " .. device.port.value .. " flash"
							)
						end
					else
						print("error " .. tostring( exit_code))
					end

					vim.t.tabpage_name = "Multi Flash"
				end
			)
		end
	end
end

M.execMonitor = function ()
	if not multi_mode then
		if not port.value then
			M.selectPort(M.execMonitor, port)
		else
			BFM:exec("idf.py "  .. " --port " .. port.value .. " monitor")
			BFM.isExecutingMonitor = true
		end
	else
		if not left_port.value then
			M.selectPort(M.dualMonitor, left_port)
		end

		if not right_port.value then
			M.selectPort(M.dualMonitor, right_port)
		end

		if left_port.value and right_port.value then
			BFM_LEFT:exec("idf.py "  .. " --port " .. left_port.value .. " monitor")
			BFM_LEFT.isExecutingMonitor = true
			BFM_RIGHT:exec("idf.py "  .. " --port " .. right_port.value .. " monitor")
			BFM_RIGHT.isExecutingMonitor = true
			vim.t.tabpage_name = "Dual Monitor"
		end
	end
end

M.execBuildFlashMonitor = function ()
	if not multi_mode then
		if not port.value then
			M.selectPort(M.execBuildFlashMonitor, port)
		else

			BFM:exec("idf.py "  .. " --port " .. port.value .. " flash monitor")
			BFM.isExecutingMonitor = true
		end
	else
		if not left_port.value then
			M.selectPort(M.dualMonitor, left_port)
		end

		if not right_port.value then
			M.selectPort(M.dualMonitor, right_port)
		end

		if left_port.value and right_port.value then
			BFM_LEFT:exec(
				"idf.py "  .. " --port " .. left_port.value .. " flash monitor"
			)
			BFM_LEFT.isExecutingMonitor = true
			BFM_RIGHT:exec(
				"idf.py "  .. " --port " .. right_port.value .. " flash monitor"
			)
			BFM_LEFT.isExecutingMonitor = true
			vim.t.tabpage_name = "Dual Monitor"
		end
	end
end

M.execFullClean = function ()
	BFM:exec("idf.py fullclean")
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
		M.selectPort(port)

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
