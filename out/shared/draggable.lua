-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UserInputService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").UserInputService
local Draggable
do
	Draggable = setmetatable({}, {
		__tostring = function()
			return "Draggable"
		end,
	})
	Draggable.__index = Draggable
	function Draggable.new(...)
		local self = setmetatable({}, Draggable)
		return self:constructor(...) or self
	end
	function Draggable:constructor(Object)
		self.Object = Object
		self.Dragging = false
	end
	function Draggable:Enable()
		local object = self.Object
		local dragInput
		local dragStart
		local startPos
		local preparingToDrag = false
		local update = function(input)
			local _position = input.Position
			local _dragStart = dragStart
			local delta = _position - _dragStart
			local newPosisi = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			object.Position = newPosisi
			return newPosisi
		end
		self.InputBegan = object.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				preparingToDrag = true
				local pos = UserInputService:GetMouseLocation()
				object.Position = UDim2.fromOffset(pos.X - (object.Parent).AbsolutePosition.X, pos.Y - (object.Parent).AbsolutePosition.Y - 35)
				if self.DragStarted then
					self.DragStarted()
				end
				local connection
				connection = (input.Changed):Connect(function()
					if input.UserInputState == Enum.UserInputState.End and (self.Dragging or preparingToDrag) then
						self.Dragging = false
						connection:Disconnect()
						-- if(this.DragEnded && !preparingToDrag) {
						-- this.DragEnded();
						-- }
						preparingToDrag = false
					end
				end)
			end
		end)
		self.InputEnded = object.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				self.Dragging = false
				if self.DragEnded then
					self.DragEnded()
				end
				preparingToDrag = false
			end
		end)
		self.InputChanged = object.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		self.InputChanged2 = UserInputService.InputChanged:Connect(function(input)
			if object.Parent == nil then
				self:Disable()
				return nil
			end
			if preparingToDrag then
				preparingToDrag = false
				self.Dragging = true
				dragStart = input.Position
				startPos = object.Position
			end
			if input == dragInput and self.Dragging then
				local newPosisi = update(input)
				if self.Dragged then
					self.Dragged(newPosisi)
				end
			end
		end)
		self.Object:GetPropertyChangedSignal("Parent"):Connect(function()
			if not self.Object.Parent then
				local _result = self.InputChanged2
				if _result ~= nil then
					_result:Disconnect()
				end
			end
		end)
	end
	function Draggable:Disable()
		local _result = self.InputBegan
		if _result ~= nil then
			_result:Disconnect()
		end
		local _result_1 = self.InputChanged
		if _result_1 ~= nil then
			_result_1:Disconnect()
		end
		local _result_2 = self.InputChanged2
		if _result_2 ~= nil then
			_result_2:Disconnect()
		end
		local _result_3 = self.InputEnded
		if _result_3 ~= nil then
			_result_3:Disconnect()
		end
		if self.Dragging then
			self.Dragging = false
			if self.DragEnded then
				self.DragEnded()
			end
		end
	end
end
return Draggable
