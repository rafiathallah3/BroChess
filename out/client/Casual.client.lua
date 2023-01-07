-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local TweenService = _services.TweenService
local StarterGui = _services.StarterGui
local Workspace = _services.Workspace
local Draggable = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "draggable")
local MAX_RETRIES = 8
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
do
	local i = 1
	local _shouldIncrement = false
	while true do
		if _shouldIncrement then
			i += 1
		else
			_shouldIncrement = true
		end
		if not (i < MAX_RETRIES) then
			break
		end
		local bisa, err = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end)
		if bisa then
			break
		end
		RunService.Stepped:Wait()
	end
end
local _result = script.Parent
if _result ~= nil then
	_result = _result.Parent
end
local CaturUI = (_result:WaitForChild("Catur")).BackgroundCatur
local _result_1 = script.Parent
if _result_1 ~= nil then
	_result_1 = _result_1.Parent
end
local Komponen_UI = _result_1:WaitForChild("Komponen_UI")
local _result_2 = script.Parent
if _result_2 ~= nil then
	_result_2 = _result_2.Parent
end
local Loading_UI = _result_2:WaitForChild("Loading")
local _result_3 = script.Parent
if _result_3 ~= nil then
	_result_3 = _result_3.Parent
end
local Menang_UI = _result_3:WaitForChild("Menang")
local Event = ReplicatedStorage.remote
local Pemain = Players.LocalPlayer
local Karakter = Pemain.Character or { Pemain.CharacterAdded:Wait() }
local Humanoid = Karakter:WaitForChild("Humanoid")
local Kamera = Workspace.CurrentCamera
local Mouse = Pemain:GetMouse()
local ListDariCheckFrame = {}
local SetelahTarukList = {}
local ListBulatanKlikKanan = {}
local ListArrow = {}
local PosisiCatur = {}
local Papan
local PromosiFrame
local NungguPromosi
local PapanFrame
local FrameTaruk
-- Sumber https://devforum.roblox.com/t/converting-secs-to-hsec/146352 25/12/2022 22:53
local function convertToHMS(Seconds)
	local decimal = tonumber(string.format("%.1f", (select(2, math.modf(Seconds)))))
	if Seconds <= 30 then
		return string.format("%02i:%02i.%s", Seconds / 60 % 60, Seconds % 60, decimal * 10)
	end
	return string.format("%02i:%02i", Seconds / 60 % 60, Seconds % 60)
end
local function UpdateCaturUI(warna, Posisi, gerakan, duluan, apakahCheck, pemain2)
	local _exp = Papan:GetDescendants()
	local _arg0 = function(v)
		if v:IsA("ImageLabel") then
			v:Destroy()
		end
	end
	for _k, _v in _exp do
		_arg0(_v, _k - 1, _exp)
	end
	local Potongan = ReplicatedStorage.komponen.Potongan:Clone()
	local Bulatan = {}
	local BuahCatur
	local function PindahPosisi(bagian, FrameDrag, AwalPosisi, TujuanPosisi)
		local _gerakan = gerakan
		local _name = AwalPosisi.Name
		if _gerakan[_name] ~= nil then
			local _gerakan_1 = gerakan
			local _name_1 = AwalPosisi.Name
			local _exp_1 = _gerakan_1[_name_1]
			local _arg0_1 = function(v)
				return v.to
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#_exp_1)
			for _k, _v in _exp_1 do
				_newValue[_k] = _arg0_1(_v, _k - 1, _exp_1)
			end
			-- ▲ ReadonlyArray.map ▲
			local _result_4 = _newValue
			if _result_4 ~= nil then
				local _name_2 = TujuanPosisi.Name
				_result_4 = table.find(_result_4, _name_2) ~= nil
			end
			if _result_4 then
				local PotonganCatur = TujuanPosisi:FindFirstChildWhichIsA("ImageLabel")
				if PotonganCatur ~= nil then
					local _ClonePotonganCatur = ReplicatedStorage.komponen.Potongan:FindFirstChild(PotonganCatur.Name)
					if _ClonePotonganCatur ~= nil then
						_ClonePotonganCatur = _ClonePotonganCatur:Clone()
					end
					local ClonePotonganCatur = _ClonePotonganCatur
					PotonganCatur:Destroy()
					if ClonePotonganCatur ~= nil then
						ClonePotonganCatur.Parent = (CaturUI:FindFirstChild(Pemain.Name)).Makan
					end
					StarterGui.Suara.Ambil:Play()
				else
					StarterGui.Suara.Gerak:Play()
				end
				local ApakahMauPromosi = false
				if string.lower((bagian:GetAttribute("panggilan"))) == "p" then
					if duluan == "w" and string.sub(TujuanPosisi.Name, 2, 2) == "8" then
						PromosiFrame = Komponen_UI.PromosiPutih:Clone()
						PromosiFrame.Parent = TujuanPosisi
						ApakahMauPromosi = true
						NungguPromosi = {
							boleh = true,
						}
					elseif duluan == "b" and string.sub(TujuanPosisi.Name, 2, 2) == "1" then
						PromosiFrame = Komponen_UI.PromosiHitam:Clone()
						PromosiFrame.Parent = TujuanPosisi
						ApakahMauPromosi = true
						NungguPromosi = {
							boleh = true,
						}
					end
				end
				if ApakahMauPromosi then
					-- Kenapa ada return??? tapi ya ndk papalah 14:25 13/12/2022
					local hasilpromosi = Event.KirimPromosiCatur.Event:Wait()
					if hasilpromosi == "q" then
						bagian.ImageRectOffset = if duluan == "w" then ReplicatedStorage.komponen.Potongan.Q_putih.ImageRectOffset else ReplicatedStorage.komponen.Potongan.Q_itam.ImageRectOffset
					elseif hasilpromosi == "b" then
						bagian.ImageRectOffset = if duluan == "w" then ReplicatedStorage.komponen.Potongan.B_putih.ImageRectOffset else ReplicatedStorage.komponen.Potongan.B_itam.ImageRectOffset
					elseif hasilpromosi == "n" then
						bagian.ImageRectOffset = if duluan == "w" then ReplicatedStorage.komponen.Potongan.Kn_putih.ImageRectOffset else ReplicatedStorage.komponen.Potongan.Kn_itam.ImageRectOffset
					elseif hasilpromosi == "r" then
						bagian.ImageRectOffset = if duluan == "w" then ReplicatedStorage.komponen.Potongan.R_putih.ImageRectOffset else ReplicatedStorage.komponen.Potongan.R_itam.ImageRectOffset
					end
					local _object = {}
					for _k, _v in NungguPromosi do
						_object[_k] = _v
					end
					_object.promosi = hasilpromosi
					NungguPromosi = _object
				end
				bagian.Parent = TujuanPosisi
				FrameDrag:Disable()
				local _arg0_2 = function(bulat)
					bulat:Destroy()
				end
				for _k, _v in Bulatan do
					_arg0_2(_v, _k - 1, Bulatan)
				end
				table.clear(Bulatan)
				local _fn = Event.GerakanCatur
				local _result_5 = AwalPosisi
				if _result_5 ~= nil then
					_result_5 = _result_5.Name
				end
				local _exp_2 = TujuanPosisi.Name
				local _result_6 = NungguPromosi
				if _result_6 ~= nil then
					_result_6 = _result_6.promosi
				end
				_fn:FireServer(_result_5, _exp_2, _result_6)
			end
		end
		if AwalPosisi.Name ~= TujuanPosisi.Name then
			local _arg0_1 = function(bulat)
				bulat:Destroy()
			end
			for _k, _v in Bulatan do
				_arg0_1(_v, _k - 1, Bulatan)
			end
			table.clear(Bulatan)
		end
	end
	local _posisi = Posisi
	local _arg0_1 = function(v)
		local bagian
		if v.type == "p" then
			bagian = if v.color == "w" then Potongan.P_putih:Clone() else Potongan.P_itam:Clone()
		elseif v.type == "b" then
			bagian = if v.color == "w" then Potongan.B_putih:Clone() else Potongan.B_itam:Clone()
		elseif v.type == "k" then
			bagian = if v.color == "w" then Potongan.K_putih:Clone() else Potongan.K_itam:Clone()
			if apakahCheck ~= nil and (apakahCheck.warna == v.color and apakahCheck.check) then
				local CheckFrame = ReplicatedStorage.komponen.CheckFrame:Clone()
				CheckFrame.Parent = Papan[v.square]
				table.insert(ListDariCheckFrame, CheckFrame)
			end
		elseif v.type == "n" then
			bagian = if v.color == "w" then Potongan.Kn_putih:Clone() else Potongan.Kn_itam:Clone()
		elseif v.type == "q" then
			bagian = if v.color == "w" then Potongan.Q_putih:Clone() else Potongan.Q_itam:Clone()
		elseif v.type == "r" then
			bagian = if v.color == "w" then Potongan.R_putih:Clone() else Potongan.R_itam:Clone()
		end
		local FrameDrag = Draggable.new(bagian)
		local _object = {
			fungsiDrag = FrameDrag,
			Object = bagian,
			warna = v.color,
		}
		local _left = "gerakan"
		local _gerakan = gerakan
		local _square = v.square
		_object[_left] = _gerakan[_square]
		_object.potongan = v.type
		PosisiCatur[v.square] = _object
		bagian.Parent = Papan[v.square]
		FrameDrag.DragStarted = function()
			local _arg0_2 = function(bulat)
				bulat:Destroy()
			end
			for _k, _v in Bulatan do
				_arg0_2(_v, _k - 1, Bulatan)
			end
			table.clear(Bulatan)
			local _gerakan_1 = gerakan
			local _result_4 = bagian.Parent
			if _result_4 ~= nil then
				_result_4 = _result_4.Name
			end
			if _gerakan_1[_result_4] ~= nil then
				local _gerakan_2 = gerakan
				local _result_5 = bagian
				if _result_5 ~= nil then
					_result_5 = _result_5.Parent
					if _result_5 ~= nil then
						_result_5 = _result_5.Name
					end
				end
				local _exp_1 = _gerakan_2[_result_5]
				local _arg0_3 = function(gerakan_piece)
					if not Papan[gerakan_piece.to]:FindFirstChild("bulat") then
						local FrameBulatan
						if Papan[gerakan_piece.to]:FindFirstChildWhichIsA("ImageLabel") then
							FrameBulatan = ReplicatedStorage.komponen.MakanFrame:Clone()
						else
							FrameBulatan = ReplicatedStorage.komponen.bulat:Clone()
						end
						FrameBulatan.InputBegan:Connect(function(v)
							if v.UserInputType == Enum.UserInputType.MouseButton1 or v.UserInputType == Enum.UserInputType.Touch then
								local AwalPosisi = bagian.Parent
								local TujuanPosisi = FrameBulatan.Parent
								PindahPosisi(bagian, FrameDrag, AwalPosisi, TujuanPosisi)
							end
						end)
						FrameBulatan.Parent = Papan[gerakan_piece.to]
						local _frameBulatan = FrameBulatan
						table.insert(Bulatan, _frameBulatan)
					end
				end
				for _k, _v in _exp_1 do
					_arg0_3(_v, _k - 1, _exp_1)
				end
			end
			if FrameTaruk ~= nil then
				FrameTaruk:Destroy()
			end
			local _result_5 = bagian
			if _result_5 ~= nil then
				_result_5 = _result_5.Parent
				if _result_5 ~= nil then
					_result_5 = _result_5:FindFirstChild("SetelahTaruk")
				end
			end
			if not _result_5 then
				FrameTaruk = Komponen_UI.SetelahTaruk:Clone()
				local _result_6 = bagian
				if _result_6 ~= nil then
					_result_6 = _result_6.Parent
				end
				FrameTaruk.Parent = _result_6
			end
			bagian.ZIndex += 1
			BuahCatur = bagian
		end
		FrameDrag.DragEnded = function()
			if PapanFrame ~= nil then
				local AwalPosisi = bagian.Parent
				local TujuanPosisi = PapanFrame
				bagian.Position = UDim2.new(0.5, 0, 0.5, 0)
				bagian.ZIndex -= 1
				PindahPosisi(bagian, FrameDrag, AwalPosisi, TujuanPosisi)
			end
		end
		if v.color == warna and warna == duluan then
			FrameDrag:Enable()
		end
	end
	for _k, _v in _posisi do
		_arg0_1(_v, _k - 1, _posisi)
	end
	Potongan:Destroy()
end
local function drawLineFromTwoPoints(pointA, pointB)
	local lineFrame = Instance.new("Frame")
	lineFrame.BackgroundColor3 = Color3.new(0.25098, 0.639216, 1)
	lineFrame.Size = UDim2.fromOffset(math.sqrt((pointA.X - pointB.X) ^ 2 + (pointA.Y - pointB.Y) ^ 2), 12)
	lineFrame.Position = UDim2.fromOffset((pointA.X + pointB.X) / 2, (pointA.Y + pointB.Y) / 2 + 35)
	lineFrame.Rotation = math.deg(math.atan2((pointA.Y - pointB.Y), (pointA.X - pointB.X)))
	lineFrame.AnchorPoint = Vector2.new(.5, .5)
	lineFrame.BorderSizePixel = 1
	lineFrame.Parent = CaturUI
	local Panah = Instance.new("ImageLabel")
	Panah.BackgroundTransparency = 1
	Panah.Size = UDim2.new(0, 40, 0, 30)
	Panah.Position = UDim2.new(0, -30, 0, -10)
	Panah.Image = "rbxassetid://788089696"
	Panah.Rotation = -90
	Panah.ImageColor3 = Color3.new(0.25098, 0.639216, 1)
	Panah.Parent = lineFrame
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(1, 0)
	uicorner.Parent = lineFrame
	return lineFrame
end
local function drawLineUI(Posisi1, Posisi2)
	local _absolutePosition = Posisi1.AbsolutePosition
	local _absoluteSize = Posisi1.AbsoluteSize
	local _vector2 = Vector2.new(.5, .5)
	local posA = _absolutePosition + ((_absoluteSize * _vector2))
	local _absolutePosition_1 = Posisi2.AbsolutePosition
	local _absoluteSize_1 = Posisi2.AbsoluteSize
	local _vector2_1 = Vector2.new(.5, .5)
	local posB = _absolutePosition_1 + ((_absoluteSize_1 * _vector2_1))
	-- const posB = new Vector2(Mouse.X, Mouse.Y);
	return drawLineFromTwoPoints(posA, posB)
end
--[[
	local pemain = game.Players.LocalPlayer;
	local mouse = pemain:GetMouse();
	local gui = script.Parent
	local Atan2 = math.atan2
	local Pi = math.pi
	local Abs = math.abs
	local Sqrt = math.sqrt
	local Deg = math.deg
	local VECTOR2_HALF = Vector2.new(0.5, 0.5)
	local lineFrame;
	local function drawLineFromTwoPoints(pointA, pointB)
	-- These found from: https://devforum.roblox.com/t/drawing-a-line-between-two-points-in-2d/717808/2
	-- Size: sqrt((x1-x2)^2+(y1-y2)^2)
	-- Pos: ((x1+x2)/2,(y1+y2)/2)
	lineFrame = Instance.new("Frame")
	lineFrame.BackgroundColor3 = Color3.new(0.25098, 0.639216, 1)
	lineFrame.Size = UDim2.fromOffset(
	Sqrt((pointA.X - pointB.X) ^ 2 + (pointA.Y - pointB.Y) ^ 2),
	12
	)
	lineFrame.Position = UDim2.fromOffset(
	(pointA.X + pointB.X) / 2,
	(pointA.Y + pointB.Y) / 2
	)
	lineFrame.Rotation = Deg(Atan2(
	(pointA.Y - pointB.Y), (pointA.X - pointB.X)
	))
	lineFrame.AnchorPoint = VECTOR2_HALF
	lineFrame.BorderSizePixel = 1
	lineFrame.Parent = script.Parent
	local Panah = Instance.new("ImageLabel");
	Panah.BackgroundTransparency = 1;
	Panah.Size = UDim2.new(0, 40, 0, 30);
	Panah.Position = UDim2.new(0, -30, 0, -10);
	Panah.Image = "rbxassetid://788089696";
	Panah.Rotation = -90;
	Panah.ImageColor3 = Color3.new(0.25098, 0.639216, 1);
	Panah.Parent = lineFrame
	local uicorner = Instance.new("UICorner");
	uicorner.CornerRadius = UDim.new(1, 0);
	uicorner.Parent = lineFrame;
	end
	function drawLineUI(obj1, obj2)
	-- Get center regardless of anchor point
	local posA = obj1.AbsolutePosition + (obj1.AbsoluteSize * VECTOR2_HALF)
	local posB = Vector2.new(mouse.X, mouse.Y);
	--local posB = obj2.AbsolutePosition + (obj2.AbsoluteSize * VECTOR2_HALF)
	return drawLineFromTwoPoints(posA, posB)
	end
	mouse.Move:Connect(function()
	if(lineFrame) then
	lineFrame:Destroy();
	end
	drawLineUI(script.Parent.Frame1);
	end)
	--drawLineUI(script.Parent.Frame1, script.Parent.Frame2)
	--task.wait(3);
	--print(mouse.X, mouse.Y);
]]
Event.KirimPemulaianCaturUIKePemain.OnClientEvent:Connect(function(RatingPemain)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "Win: " .. (tostring(RatingPemain.Menang.SelisihRating) .. (" Draw: " .. (tostring(RatingPemain.Seri.SelisihRating) .. (" Lose: " .. tostring(RatingPemain.Kalah.SelisihRating))))),
	})
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "If your opponent hasn't moved in 60 seconds, The match automatically ended",
	})
	local TweenHitam = TweenService:Create(Loading_UI.ScreenHITAM, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = UDim2.fromScale(1, 1),
	})
	TweenHitam:Play()
	TweenHitam.Completed:Wait()
	Loading_UI.LoadingFrame.Visible = false
	wait(1)
	TweenHitam = TweenService:Create(Loading_UI.ScreenHITAM, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = UDim2.fromScale(1, 0),
	})
	TweenHitam:Play()
	TweenHitam.Completed:Wait()
	Loading_UI.Enabled = false
	Loading_UI.LoadingFrame.LocalScript.Enabled = false
	Loading_UI.LoadingFrame.Visible = true
	CaturUI.Menyerah.MouseButton1Click:Connect(function()
		Event.Menyerah:FireServer()
	end)
	CaturUI.Seri.MouseButton1Click:Connect(function()
		Event.Seri:FireServer("ajak seri")
	end)
	wait(2)
	local TweenCatur = TweenService:Create(CaturUI, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0, 0),
	})
	TweenCatur:Play()
	TweenCatur.Completed:Wait()
	wait(.5)
	CaturUI.prediksi.Text = "You have " .. (tostring(RatingPemain.prediksi) .. "% chances to win")
end)
Event.KirimCaturUIKePemain.OnClientEvent:Connect(function(warna, mode, Posisi, gerakan, duluan, pemain2, waktu)
	local latar_belakang = if warna == "b" then Komponen_UI.latar_belakang_hitam else Komponen_UI.latar_belakang_putih
	local FramePemain1 = CaturUI.Pemain1
	local FramePemain2 = CaturUI.Pemain2
	if mode == "analisis" then
		FramePemain1.Visible = false
		FramePemain2.Visible = false
	end
	FramePemain1.Name = Pemain.Name
	FramePemain1.Nama.Text = Pemain.Name .. (" (" .. (tostring(Pemain.DataPemain.DataPoint.Point.Value) .. ")"))
	if waktu ~= 0 and (waktu == waktu and waktu) then
		FramePemain1.Waktu.Text = convertToHMS(waktu)
	end
	if pemain2 ~= nil then
		FramePemain2.Name = pemain2.Pemain.Name
		FramePemain2.Nama.Text = pemain2.Pemain.Name .. (" (" .. (tostring(pemain2.Pemain.DataPemain.DataPoint.Point.Value) .. ")"))
		if waktu ~= 0 and (waktu == waktu and waktu) then
			FramePemain2.Waktu.Text = convertToHMS(waktu)
		end
	end
	local _exp = latar_belakang:GetChildren()
	local _arg0 = function(v)
		if v:IsA("Frame") then
			v.BackgroundColor3 = if v:GetAttribute("warna") == "hitam" then Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard1.Value) else Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard2.Value)
			local _exp_1 = v:GetChildren()
			local _arg0_1 = function(d)
				if d:IsA("TextLabel") then
					d.TextColor3 = if v:GetAttribute("warna") == "hitam" then Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard2.Value) else Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard1.Value)
				end
			end
			for _k, _v in _exp_1 do
				_arg0_1(_v, _k - 1, _exp_1)
			end
		end
	end
	for _k, _v in _exp do
		_arg0(_v, _k - 1, _exp)
	end
	local GambarPemain1, apakahSiap1 = Players:GetUserThumbnailAsync(Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	if apakahSiap1 then
		FramePemain1.Foto.Image = GambarPemain1
	end
	if pemain2 ~= nil then
		local _fn = Players
		local _result_4 = pemain2
		if _result_4 ~= nil then
			_result_4 = _result_4.Pemain.UserId
		end
		local GambarPemain2, apakahSiap2 = _fn:GetUserThumbnailAsync(_result_4, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		if apakahSiap2 then
			FramePemain2.Foto.Image = GambarPemain2
		end
	end
	Papan = latar_belakang:Clone()
	local AwalMulaArrow
	local ApakahArrow = false
	local BulatKlikKanan
	local Arrow
	local _exp_1 = Papan:GetChildren()
	local _arg0_1 = function(element)
		if element:IsA("Frame") then
			element.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					ApakahArrow = true
					AwalMulaArrow = element
					if not PapanFrame:FindFirstChild("BulatKlikKanan") then
						BulatKlikKanan = Komponen_UI.BulatKlikKanan:Clone()
						BulatKlikKanan.Parent = PapanFrame
						local _bulatKlikKanan = BulatKlikKanan
						table.insert(ListBulatanKlikKanan, _bulatKlikKanan)
					else
						local _result_4 = PapanFrame:FindFirstChild("BulatKlikKanan")
						if _result_4 ~= nil then
							_result_4:Destroy()
						end
					end
				end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if not ApakahArrow then
						if BulatKlikKanan then
							BulatKlikKanan:Destroy()
							BulatKlikKanan = nil
						end
						local _arg0_2 = function(v)
							v:Destroy()
						end
						for _k, _v in ListBulatanKlikKanan do
							_arg0_2(_v, _k - 1, ListBulatanKlikKanan)
						end
						table.clear(ListBulatanKlikKanan)
						local _arg0_3 = function(v)
							v:Destroy()
						end
						for _k, _v in ListArrow do
							_arg0_3(_v, _k - 1, ListArrow)
						end
						table.clear(ListArrow)
					end
				end
			end)
			element.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					ApakahArrow = false
					if Arrow then
						local _arrow = Arrow
						table.insert(ListArrow, _arrow)
						Arrow = nil
					end
					-- if(BulatKlikKanan) {
					-- BulatKlikKanan.Destroy();
					-- BulatKlikKanan = undefined;
					-- }
				end
			end)
			element.MouseEnter:Connect(function()
				PapanFrame = element
				if ApakahArrow then
					if Arrow then
						Arrow:Destroy()
					end
					if BulatKlikKanan then
						if AwalMulaArrow.Name ~= element.Name then
							BulatKlikKanan.Visible = false
						else
							BulatKlikKanan.Visible = true
						end
					end
					if AwalMulaArrow.Name ~= element.Name then
						Arrow = drawLineUI(AwalMulaArrow, element)
					end
				end
			end)
		end
	end
	for _k, _v in _exp_1 do
		_arg0_1(_v, _k - 1, _exp_1)
	end
	CaturUI.SiapaDuluan.Visible = true
	StarterGui.Suara.Mulai:Play()
	CaturUI.SiapaDuluan.Text = if duluan == "w" then "White turns" else "Black turns"
	UpdateCaturUI(warna, Posisi, gerakan, duluan, nil, pemain2)
	Papan.Parent = CaturUI.Frame
end)
Event.KirimSemuaGerakan.OnClientEvent:Connect(function(WarnaPemain, Pemain2, AwalTujuanPosisi, PosisiServer, gerakan, duluan, ApakahGameSelesai, apakahCheck)
	if FrameTaruk then
		FrameTaruk:Destroy()
	end
	local _arg0 = function(v)
		v:Destroy()
	end
	for _k, _v in SetelahTarukList do
		_arg0(_v, _k - 1, SetelahTarukList)
	end
	table.clear(SetelahTarukList)
	local FrameTaruk1 = Komponen_UI.SetelahTaruk:Clone()
	local FrameTaruk2 = Komponen_UI.SetelahTaruk:Clone()
	FrameTaruk1.Parent = Papan[AwalTujuanPosisi.awalPosisi]
	FrameTaruk2.Parent = Papan[AwalTujuanPosisi.tujuanPosisi]
	table.insert(SetelahTarukList, FrameTaruk1)
	table.insert(SetelahTarukList, FrameTaruk2)
	local _arg0_1 = function(v)
		v:Destroy()
	end
	for _k, _v in ListDariCheckFrame do
		_arg0_1(_v, _k - 1, ListDariCheckFrame)
	end
	table.clear(ListDariCheckFrame)
	if Pemain2 ~= nil then
		local _exp = Papan[AwalTujuanPosisi.tujuanPosisi]:GetChildren()
		local _arg0_2 = function(v)
			if v:GetAttribute("warna") == duluan then
				local _PotonganCatur = ReplicatedStorage.komponen.Potongan:FindFirstChild(v.Name)
				if _PotonganCatur ~= nil then
					_PotonganCatur = _PotonganCatur:Clone()
				end
				local PotonganCatur = _PotonganCatur
				if PotonganCatur ~= nil then
					local _fn = CaturUI
					local _result_4 = Pemain2
					if _result_4 ~= nil then
						_result_4 = _result_4.Pemain.Name
					end
					PotonganCatur.Parent = (_fn:FindFirstChild(_result_4)).Makan
				end
				v:Destroy()
				StarterGui.Suara.Ambil:Play()
			end
		end
		for _k, _v in _exp do
			_arg0_2(_v, _k - 1, _exp)
		end
	end
	UpdateCaturUI(WarnaPemain, PosisiServer, gerakan, duluan, apakahCheck)
	local _binding = ApakahGameSelesai
	local ApakahSelesai = _binding[1]
	local StatusSelesai = _binding[2]
	local SiapaMenang = _binding[3]
	if ApakahSelesai then
		if StatusSelesai == "draw" then
			CaturUI.SiapaDuluan.Text = "Draw!"
			CaturUI.SiapaDuluan.TextColor3 = Color3.fromRGB(70, 70, 70)
		elseif StatusSelesai == "skakmat" then
			CaturUI.SiapaDuluan.Text = if SiapaMenang == "w" then "White wins!" else "Black wins!"
			CaturUI.SiapaDuluan.TextColor3 = if SiapaMenang == "w" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(0, 0, 0)
		end
		StarterGui.Suara.Mulai:Play()
		wait(3)
		local TweenCatur = TweenService:Create(CaturUI, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.fromScale(0, 1),
		})
		TweenCatur:Play()
		TweenCatur.Completed:Wait()
	else
		CaturUI.SiapaDuluan.Text = if duluan == "w" then "White turns" else "Black turns"
		CaturUI.SiapaDuluan.TextColor3 = if duluan == "w" then Color3.new(255, 255, 255) else Color3.new(0, 0, 0)
	end
end)
Event.Seri.OnClientEvent:Connect(function(isntruksi, SiapaYangNgeDraw)
	if isntruksi == "tunjukkin" then
		CaturUI.SeriUI.Visible = true
		CaturUI.SeriUI.Terima.MouseButton1Click:Connect(function()
			Event.Seri:FireServer("terima seri", SiapaYangNgeDraw)
		end)
		CaturUI.SeriUI.Tolak.MouseButton1Click:Connect(function()
			CaturUI.SeriUI.Visible = false
			Event.Seri:FireServer("tolak seri", SiapaYangNgeDraw)
		end)
	elseif isntruksi == "terima seri" then
		CaturUI.SeriUI.Visible = false
	elseif isntruksi == "tolak seri" then
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "Your opponent decline to draw",
		})
	end
end)
Event.KirimCaturPemenang.OnClientEvent:Connect(function(Pemenang)
	CaturUI.SiapaDuluan.Text = if Pemenang == "w" then "White wins!" elseif Pemenang == "seri" then "Draw!" else "Black wins!"
	CaturUI.SiapaDuluan.TextColor3 = if Pemenang == "w" then Color3.fromRGB(255, 255, 255) elseif Pemenang == "seri" then Color3.fromRGB(70, 70, 70) else Color3.fromRGB(0, 0, 0)
	for _, dataPosisi in pairs(PosisiCatur) do
		dataPosisi.fungsiDrag:Disable()
	end
	StarterGui.Suara.Mulai:Play()
	wait(3)
	local TweenCatur = TweenService:Create(CaturUI, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0, 1),
	})
	TweenCatur:Play()
	TweenCatur.Completed:Wait()
end)
Event.TunjukkinMenangUI.OnClientEvent:Connect(function(warna, point, jumlahPoint, CaturPemain, ApakahGameSelesai)
	local _binding = ApakahGameSelesai
	local _ = _binding[1]
	local StatusSelesai = _binding[2]
	local SiapaPemenang = _binding[3]
	Menang_UI.Frame.NamaPemain1.Text = CaturPemain.p1.Pemain.Name
	Menang_UI.Frame.NamaPemain2.Text = CaturPemain.p2.Pemain.Name
	local GambarPemain1, apakahSiap1 = Players:GetUserThumbnailAsync(CaturPemain.p1.Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	if apakahSiap1 then
		Menang_UI.Frame.GambarPemain1.Image = GambarPemain1
	end
	local GambarPemain2, apakahSiap2 = Players:GetUserThumbnailAsync(CaturPemain.p2.Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	if apakahSiap2 then
		Menang_UI.Frame.GambarPemain2.Image = GambarPemain2
	end
	Menang_UI.Frame.GambarPemain1.Name = "Gambar_" .. CaturPemain.p1.warna
	Menang_UI.Frame.GambarPemain2.Name = "Gambar_" .. CaturPemain.p2.warna
	Menang_UI.Frame.Point.Text = tostring(jumlahPoint)
	if StatusSelesai == "draw" then
		Menang_UI.Frame.Status.BackgroundColor3 = Color3.fromRGB(152, 152, 152)
		Menang_UI.Frame.Status.Menang_Kalah.Text = "Draw!"
		Menang_UI.Frame.Status.Alasan.Text = SiapaPemenang
	elseif SiapaPemenang == warna then
		Menang_UI.Frame.Status.BackgroundColor3 = Color3.fromRGB(97, 255, 94)
		Menang_UI.Frame.Status.Menang_Kalah.Text = "You won!"
		Menang_UI.Frame.Status.Alasan.Text = if StatusSelesai == "skakmat" then "By checkmate" elseif StatusSelesai == "waktuhabis" then "No time" elseif StatusSelesai == "menyerah" then "Resignation" else "Player left"
		(Menang_UI.Frame:FindFirstChild("Gambar_" .. warna)).BorderSizePixel = 2
	elseif SiapaPemenang ~= warna then
		Menang_UI.Frame.Status.BackgroundColor3 = Color3.fromRGB(152, 152, 152)
		Menang_UI.Frame.Status.Menang_Kalah.Text = "You lose!"
		Menang_UI.Frame.Status.Alasan.Text = if StatusSelesai == "skakmat" then "By checkmate" elseif StatusSelesai == "waktuhabis" then "No time" elseif StatusSelesai == "menyerah" then "Resignation" else "Player left"
		(Menang_UI.Frame:FindFirstChild("Gambar_" .. tostring(SiapaPemenang))).BorderSizePixel = 2
	end
	if point > 0 then
		Menang_UI.Frame.PointTambahKurang.TextColor3 = Color3.fromRGB(71, 212, 0)
	elseif point < 0 then
		Menang_UI.Frame.PointTambahKurang.TextColor3 = Color3.fromRGB(255, 0, 4)
	elseif point == 0 then
		Menang_UI.Frame.PointTambahKurang.TextColor3 = Color3.fromRGB(127, 127, 127)
	end
	Menang_UI.Frame.PointTambahKurang.Text = tostring(point)
	Menang_UI.Frame.KeLobby.MouseButton1Click:Connect(function()
		Event.TeleportKeLobby:FireServer()
		Menang_UI.Frame.TextTeleport.Visible = true
	end)
	Menang_UI.Frame.Rematch.MouseButton1Click:Connect(function()
		if not Pemain.DataPemain:FindFirstChild("LagiInvite") then
			Menang_UI.Frame.Rematch.Text = "Inviting..."
			Event.KirimRematch:FireServer(if CaturPemain.p1.Pemain.Name ~= Pemain.Name then CaturPemain.p1.Pemain else CaturPemain.p2.Pemain)
		end
	end)
	local KondisiLaporUI = false
	Menang_UI.Frame.Lapor.MouseButton1Click:Connect(function()
		if not KondisiLaporUI then
			TweenService:Create(Menang_UI.LaporUI, TweenInfo.new(.4), {
				Position = UDim2.fromScale(.5, .5),
			}):Play()
			KondisiLaporUI = true
		else
			TweenService:Create(Menang_UI.LaporUI, TweenInfo.new(.4), {
				Position = UDim2.fromScale(.5, 1.2),
			}):Play()
			KondisiLaporUI = false
		end
	end)
	Menang_UI.LaporUI.Tutup.MouseButton1Click:Connect(function()
		TweenService:Create(Menang_UI.LaporUI, TweenInfo.new(.4), {
			Position = UDim2.fromScale(.5, 1.2),
		}):Play()
		KondisiLaporUI = false
	end)
	Menang_UI.LaporUI.Kirim.MouseButton1Click:Connect(function()
		local penjelasan = Menang_UI.LaporUI.penjelasan.Text
		if #Menang_UI.LaporUI.penjelasan.Text > 5 then
			KondisiLaporUI = false
			Menang_UI.LaporUI.penjelasan.Text = "Thank you for the report, We will look for it."
			Event.Lapor:FireServer(penjelasan, if warna == CaturPemain.p1.warna then CaturPemain.p2.Pemain else CaturPemain.p1.Pemain)
			wait(1.5)
			local t = TweenService:Create(Menang_UI.LaporUI, TweenInfo.new(.4), {
				Position = UDim2.fromScale(.5, 1.2),
			})
			t:Play()
			t.Completed:Wait()
			Menang_UI.LaporUI:Destroy()
			Menang_UI.Frame.Lapor:Destroy()
		else
			Menang_UI.LaporUI.penjelasan.Text = "Describe is too short"
			wait(1.5)
			Menang_UI.LaporUI.penjelasan.Text = penjelasan
		end
	end)
	local TweenMenang = TweenService:Create(Menang_UI.Frame, TweenInfo.new(.4), {
		Position = UDim2.fromScale(.5, .5),
	})
	TweenMenang:Play()
	TweenMenang.Completed:Wait()
	if StatusSelesai ~= "draw" then
		StarterGui.Suara.Menang:Play()
	end
	wait(1.5)
	if point > 0 then
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= point) then
					break
				end
				Menang_UI.Frame.Point.Text = tostring(jumlahPoint + i)
				Menang_UI.Frame.PointTambahKurang.Text = tostring(point - i)
				StarterGui.Suara.SpamTambahan:Play()
				wait(.05)
			end
		end
	elseif point < 0 then
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i -= 1
				else
					_shouldIncrement = true
				end
				if not (i >= point) then
					break
				end
				Menang_UI.Frame.Point.Text = tostring(jumlahPoint + i)
				Menang_UI.Frame.PointTambahKurang.Text = tostring(point - i)
				StarterGui.Suara.SpamTambahan:Play()
				wait(.05)
			end
		end
	end
end)
Event.KirimPromosiCatur.Event:Connect(function(Promosi)
	if NungguPromosi.boleh then
		NungguPromosi = {
			boleh = false,
			promosi = Promosi,
		}
		PromosiFrame:Destroy()
	end
end)
Event.KirimRematchKePemainUI.OnClientEvent:Connect(function(siapaInvite)
	Menang_UI.Frame.RematchFrame.TextRematch.Text = siapaInvite.Name .. " wants to have a rematch"
	TweenService:Create(Menang_UI.Frame.RematchFrame, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0, 1.1),
	}):Play()
	Menang_UI.Frame.RematchFrame.Terima.MouseButton1Click:Connect(function()
		Event.StatusRematch:FireServer(siapaInvite, "terima")
		TweenService:Create(Menang_UI.Frame.RematchFrame, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.fromScale(0, 1.8),
		}):Play()
		Menang_UI.Frame.TextTeleport.Visible = true
	end)
	Menang_UI.Frame.RematchFrame.Tolak.MouseButton1Click:Connect(function()
		Event.StatusRematch:FireServer(siapaInvite, "tolak")
		TweenService:Create(Menang_UI.Frame.RematchFrame, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.fromScale(0, 1.8),
		}):Play()
	end)
end)
Event.TunjukkinRematchStatus.OnClientEvent:Connect(function(status)
	if status == "terima" then
		Menang_UI.Frame.TextTeleport.Visible = true
		Menang_UI.Frame.Rematch.Text = "Rematch"
	else
		Menang_UI.Frame.Rematch.Text = "Rejected"
	end
end)
local SudahAdaSound = false
Event.KirimWaktuCaturKePemain.OnClientEvent:Connect(function(waktu, PemainLainnya)
	local WaktuPemain = (CaturUI:FindFirstChild(Pemain.Name)).Waktu
	local WaktuPemainLainnya = (CaturUI:FindFirstChild(PemainLainnya.Pemain.Name)).Waktu
	if waktu <= 30 then
		WaktuPemain.TextColor3 = Color3.fromRGB(255, 60, 63)
		if not SudahAdaSound then
			SudahAdaSound = true
			StarterGui.Suara.WaktuMauHabis.Sound:Play()
			wait(.1)
			StarterGui.Suara.WaktuMauHabis.Sound1:Play()
			wait(.1)
			StarterGui.Suara.WaktuMauHabis.Sound2:Play()
			wait(.15)
			StarterGui.Suara.WaktuMauHabis.Sound3:Play()
		end
	end
	if PemainLainnya.waktu <= 30 then
		WaktuPemainLainnya.TextColor3 = Color3.fromRGB(255, 60, 63)
	end
	WaktuPemain.Text = convertToHMS(waktu)
	WaktuPemainLainnya.Text = convertToHMS(PemainLainnya.waktu)
end)
local _result_4 = script.Parent
if _result_4 ~= nil then
	_result_4 = _result_4.Parent
end
_result_4.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
UIS.ModalEnabled = true
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
Humanoid.JumpPower = 0
while true do
	Kamera.CameraType = Enum.CameraType.Scriptable
	if Kamera.CameraType == Enum.CameraType.Scriptable and game:IsLoaded() then
		break
	end
end
print(Kamera.CameraType)
Kamera.CFrame = Workspace.Tempat.Kamera.CFrame
Workspace.Tempat.Kamera:GetPropertyChangedSignal("CFrame"):Connect(function()
	Kamera.CFrame = Workspace.Tempat.Kamera.CFrame
end)
Loading_UI.Enabled = true
Loading_UI.LoadingFrame.LocalScript.Enabled = true
