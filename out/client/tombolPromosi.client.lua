-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local Event = ReplicatedStorage.remote;
(script.Parent).MouseButton1Click:Connect(function()
	local _fn = Event.KirimPromosiCatur
	local _result = script.Parent
	if _result ~= nil then
		_result = _result.Name
	end
	_fn:Fire(_result)
end)
