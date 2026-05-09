local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")


local M = {}

local port = nil

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


function CustomTerm:exec(cmd)
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
					mode = 'i'
				})

local LG = CustomTerm:new({
					cmd = "lazygit",
					hidden = true,
					direction = "float",
					mode = 'i',
				})

local BFM = CustomTerm:new({
					hidden = true,
					direction = "horizontal",
					mode = 'n'
				})

M.setup = function()
	MC:spawn()
	LG:spawn()
	BFM:spawn()
end

M.execBuildFlash = function ()
	if not port then
		M.selectPort(M.execBuildFlash)
	else
		BFM:exec("idf.py"  .. " --port " .. port .. " flash")
	end
end

M.execMonitor = function ()
	if not port then
		M.selectPort(M.execMonitor)
	else
		BFM:exec("idf.py "  .. " --port " .. port .. " monitor")
		BFM.isExecutingMonitor = true
	end
end

M.execBuildFlashMonitor = function ()
	if not port then
		M.selectPort(M.execBuildFlashMonitor)
	else

		BFM:exec("idf.py "  .. " --port " .. port .. " flash monitor")
		BFM.isExecutingMonitor = true
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

M.selectPort = function(action)

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
					port = selection.value

				end

				if action then
					action()
				end
			end)
			return true
		end,
	}):find()
end



return M
