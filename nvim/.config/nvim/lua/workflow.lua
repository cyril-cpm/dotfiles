local M = {}

local Terminal = require("toggleterm.terminal").Terminal

local CustomTerm = {}
CustomTerm.__index = CustomTerm
setmetatable(CustomTerm, {__index = Terminal})

function CustomTerm:new(cterm)
	local instance = Terminal.new(self, cterm)
	setmetatable(instance, CustomTerm)
	instance.mode = cterm.mode
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
	self:send(cmd)

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
	BFM:exec("idf.py flash")
end

M.execMonitor = function ()
	BFM:exec("idf.py monitor")
end

M.execBuildFlashMonitor = function ()
	BFM:exec("idf.py flash monitor")
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

return M
