-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local StarterGui = _services.StarterGui
local TweenService = _services.TweenService
local _ListKematian = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "ListKematian")
local Kematian = _ListKematian.Kematian
local Kursi = _ListKematian.Kursi
local SemuaKematian = _ListKematian.SemuaKematian
local SemuaKursi = _ListKematian.SemuaKursi
local SkinPiece = _ListKematian.SkinPiece
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
local Menu_UI = _result_2:WaitForChild("Menu")
local _result_3 = script.Parent
if _result_3 ~= nil then
	_result_3 = _result_3.Parent
end
local Loading_UI = _result_3:WaitForChild("Loading")
local Event = ReplicatedStorage.remote
local Pemain = Players.LocalPlayer
local Karakter = Pemain.Character or (Pemain.CharacterAdded:Wait())
local DataPemain = Pemain:WaitForChild("DataPemain")
-- Data catur thing
local KoneksiPapan = {}
local ListDariCheckFrame = {}
local SetelahTarukList = {}
local PosisiCatur = {}
local Papan
local PromosiFrame
local NungguPromosi
local ConvertWarnaKeColor = {
	putih = "w",
	hitam = "b",
}
local function toMS(waktu)
	local _arg0 = waktu / 60 % 60
	local _arg1 = waktu % 60
	return string.format("%02i:%02i", _arg0, _arg1)
end
local function toHMS(waktu)
	local _arg0 = waktu / 60 ^ 2
	local _arg1 = waktu / 60 % 60
	local _arg2 = waktu % 60
	return string.format("%02i:%02i:%02i", _arg0, _arg1, _arg2)
end
local function UpdateInventoryMenu(data)
	local DataBarang = {
		kursi = Kursi,
		kematian = Kematian,
		skin = SkinPiece,
	}
	local DataValue = {
		kursi = DataPemain.DataBarang.kursi,
		kematian = DataPemain.DataBarang.kematian,
		skin = DataPemain.DataBarang.skinpiece,
	}
	local TipeLain = {
		kursi = "Chair",
		kematian = "Effect",
		skin = "Skin",
	}
	local _exp = Menu_UI.MenuFrame.InventoryMenu.Inventory.TempatInventory:GetChildren()
	local _arg0 = function(v)
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	for _k, _v in _exp do
		_arg0(_v, _k - 1, _exp)
	end
	Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.Visible = false
	Menu_UI.MenuFrame.InventoryMenu.Inventory.Visible = true
	local _exp_1 = data.tempatBarang:GetChildren()
	local _arg0_1 = function(v)
		local DataKursi = DataBarang[data.tipe][v.Name]
		local Item = Komponen_UI.ItemEffect:Clone()
		Item.Name = v.Name
		Item.Nama.Text = DataKursi.NamaLain
		Item.Tipe.Text = TipeLain[data.tipe]
		if data.tipe == "kursi" then
			Item.ViewportFrame.Visible = true
		elseif data.tipe == "kematian" or data.tipe == "skin" then
			Item.Gambar.Image = DataKursi.Gambar
			Item.Gambar.Visible = true
		end
		if DataValue[data.tipe].Value == v.Name then
			Item.Beli.Text = "Equipped"
		else
			Item.Beli.Text = "Equip"
		end
		Item.Beli.MouseButton1Click:Connect(function()
			Event.PakeBarang:FireServer(v.Name, if data.tipe == "kursi" then "Kursi" elseif data.tipe == "kematian" then "Effect" else "Skin")
			local _exp_2 = (Menu_UI.MenuFrame.InventoryMenu.Inventory.TempatInventory:GetChildren())
			local _arg0_2 = function(j)
				if j:IsA("Frame") then
					j.Beli.Text = "Equip"
				end
			end
			for _k, _v in _exp_2 do
				_arg0_2(_v, _k - 1, _exp_2)
			end
			Item.Beli.Text = "Equipped"
		end)
		if data.tipe == "kursi" then
			local ModulKursi = DataKursi.Kursi:Clone()
			ModulKursi.Parent = Item.ViewportFrame
		end
		Item.Parent = Menu_UI.MenuFrame.InventoryMenu.Inventory.TempatInventory
	end
	for _k, _v in _exp_1 do
		_arg0_1(_v, _k - 1, _exp_1)
	end
end
Event.KirimSemuaGerakan.OnClientEvent:Connect(function(AwalTujuanPosisi, PosisiServer, gerakan, duluan, apakahCheck, skakmat, apakahSeri)
	if apakahSeri == nil then
		apakahSeri = false
	end
	PosisiCatur[AwalTujuanPosisi.tujuanPosisi] = PosisiCatur[AwalTujuanPosisi.awalPosisi]
	local _exp = Papan[AwalTujuanPosisi.tujuanPosisi]:GetChildren()
	local _arg0 = function(v)
		if v:GetAttribute("warna") == duluan then
			v:Destroy()
			StarterGui.Suara.Ambil:Play()
		end
	end
	for _k, _v in _exp do
		_arg0(_v, _k - 1, _exp)
	end
	PosisiCatur[AwalTujuanPosisi.tujuanPosisi].Object.Parent = Papan[AwalTujuanPosisi.tujuanPosisi]
	PosisiCatur[AwalTujuanPosisi.awalPosisi] = nil
	local KeysPosisiCaturClient = {}
	for kunci, _ in pairs(PosisiCatur) do
		table.insert(KeysPosisiCaturClient, kunci)
	end
	local _posisiServer = PosisiServer
	local _arg0_1 = function(v)
		local _square = v.square
		if table.find(KeysPosisiCaturClient, _square) ~= nil then
			local _arg0_2 = function(d)
				return d == v.square
			end
			-- ▼ ReadonlyArray.findIndex ▼
			local _result_4 = -1
			for _i, _v in KeysPosisiCaturClient do
				if _arg0_2(_v, _i - 1, KeysPosisiCaturClient) == true then
					_result_4 = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			table.remove(KeysPosisiCaturClient, _result_4 + 1)
		end
	end
	for _k, _v in _posisiServer do
		_arg0_1(_v, _k - 1, _posisiServer)
	end
	local _posisiServer_1 = PosisiServer
	local _arg0_2 = function(v)
		return v.square
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#_posisiServer_1)
	for _k, _v in _posisiServer_1 do
		_newValue[_k] = _arg0_2(_v, _k - 1, _posisiServer_1)
	end
	-- ▲ ReadonlyArray.map ▲
	local KeysPosisiServer = _newValue
	for tempat, _ in pairs(PosisiCatur) do
		if table.find(KeysPosisiServer, tempat) ~= nil then
			local _arg0_3 = function(d)
				return d == tempat
			end
			-- ▼ ReadonlyArray.findIndex ▼
			local _result_4 = -1
			for _i, _v in KeysPosisiServer do
				if _arg0_3(_v, _i - 1, KeysPosisiServer) == true then
					_result_4 = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			table.remove(KeysPosisiServer, _result_4 + 1)
		end
	end
	if #KeysPosisiServer ~= 0 and #KeysPosisiServer == #KeysPosisiCaturClient then
		local _arg0_3 = function(v, i)
			PosisiCatur[KeysPosisiServer[i + 1]] = PosisiCatur[v]
			PosisiCatur[KeysPosisiServer[i + 1]].Object.Parent = Papan[KeysPosisiServer[i + 1]]
			PosisiCatur[v] = nil
		end
		for _k, _v in KeysPosisiCaturClient do
			_arg0_3(_v, _k - 1, KeysPosisiCaturClient)
		end
	end
	local _arg0_3 = function(v)
		v:Destroy()
	end
	for _k, _v in ListDariCheckFrame do
		_arg0_3(_v, _k - 1, ListDariCheckFrame)
	end
	table.clear(ListDariCheckFrame)
	for posisi, dataPosisi in pairs(PosisiCatur) do
		if dataPosisi.warna == duluan then
			dataPosisi.fungsiDrag:Enable()
		else
			dataPosisi.fungsiDrag:Disable()
		end
		local _condition = dataPosisi.warna == duluan
		if _condition then
			local _result_4 = apakahCheck
			if _result_4 ~= nil then
				_result_4 = _result_4.check
			end
			_condition = _result_4
			if _condition then
				_condition = dataPosisi.potongan == "k"
			end
		end
		if _condition then
			local CheckFrame = ReplicatedStorage.komponen.CheckFrame:Clone()
			CheckFrame.Parent = dataPosisi.Object.Parent
			table.insert(ListDariCheckFrame, CheckFrame)
		end
		dataPosisi.gerakan = gerakan[posisi]
	end
	if apakahSeri ~= 0 and (apakahSeri == apakahSeri and (apakahSeri ~= "" and apakahSeri)) then
		CaturUI.SiapaDuluan.Text = "Draw!"
		CaturUI.SiapaDuluan.TextColor3 = Color3.new(0, 0, 0)
		StarterGui.Suara.Mulai:Play()
	else
		local _result_4 = skakmat
		if _result_4 ~= nil then
			_result_4 = _result_4.skak
		end
		if _result_4 then
			CaturUI.SiapaDuluan.Text = if skakmat.warna == "w" then "White wins!" else "Black wins!"
			CaturUI.SiapaDuluan.TextColor3 = if skakmat.warna == "w" then Color3.new(255, 255, 255) else Color3.new(0, 0, 0)
			StarterGui.Suara.Mulai:Play()
		else
			CaturUI.SiapaDuluan.Text = if duluan == "w" then "White turns" else "Black turns"
			CaturUI.SiapaDuluan.TextColor3 = if duluan == "w" then Color3.new(255, 255, 255) else Color3.new(0, 0, 0)
		end
	end
	-- UpdateUICatur(Posisi, gerakan, duluan, apakahCheck, skakmat, apakahSeri);
end)
Event.KirimCaturUIKePemain.OnClientEvent:Connect(function(warna, mode, Posisi, gerakan, duluan, pemain2) end)
Event.KirimWarnaBoard.Event:Connect(function(Nama, warna)
	Menu_UI.MenuFrame.SettingsMenu.Frame[Nama].Warna.BackgroundColor3 = warna
	local _exp = Menu_UI.GerakanFrame.Folder:GetChildren()
	local _arg0 = function(v)
		if v:IsA("Frame") then
			repeat
				if Nama == "Warna1" then
					v.BackgroundColor3 = if v.Name == "hitam" then warna else Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value)
					break
				end
				if Nama == "Warna2" then
					v.BackgroundColor3 = if v.Name == "hitam" then Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) else warna
					break
				end
			until true
		end
	end
	for _k, _v in _exp do
		_arg0(_v, _k - 1, _exp)
	end
	local _exp_1 = Menu_UI.GerakanFrame.berikut:GetChildren()
	local _arg0_1 = function(v)
		if v:IsA("Frame") then
			repeat
				if Nama == "Warna1" then
					v.BackgroundColor3 = if v.Name == "hitam" then warna else Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value)
					break
				end
				if Nama == "Warna2" then
					v.BackgroundColor3 = if v.Name == "hitam" then Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) else warna
					break
				end
			until true
		end
	end
	for _k, _v in _exp_1 do
		_arg0_1(_v, _k - 1, _exp_1)
	end
	Event.KirimDataWarnaBoard:FireServer(if Nama == "Warna1" then "hitam" else "putih", warna)
end)
Event.TambahinUndangan.OnClientEvent:Connect(function(indikasi, SiapaInvite)
	if indikasi == "kirim invite" then
		local KartuUndangan = Komponen_UI.KartuUndangan:Clone()
		KartuUndangan.Position = UDim2.new(1, 0, 1, 0)
		KartuUndangan.NamaOrang.Text = SiapaInvite.Name
		KartuUndangan.Text.Text = SiapaInvite.Name .. " challenges to 1v1 classic game"
		KartuUndangan.ProfileOrang.Image = (Players:GetUserThumbnailAsync(SiapaInvite.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420))
		local _exp = Menu_UI.MenuFrame.TerimaUndangan:GetChildren()
		local _arg0 = function(undangan_element)
			if undangan_element:IsA("Frame") then
				local pos = UDim2.fromScale(0, undangan_element.Position.Y.Scale - .155)
				TweenService:Create(undangan_element, TweenInfo.new(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
					Position = pos,
				}):Play()
			end
		end
		for _k, _v in _exp do
			_arg0(_v, _k - 1, _exp)
		end
		KartuUndangan.Parent = Menu_UI.MenuFrame.TerimaUndangan
		KartuUndangan.Menolak.MouseButton1Click:Connect(function()
			Event.TambahinUndangan:FireServer("tolak invite", SiapaInvite)
			local TweenHilang = TweenService:Create(KartuUndangan, TweenInfo.new(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
				Position = UDim2.new(1, 0, KartuUndangan.Position.Y.Scale + .1, 0),
			})
			TweenHilang:Play()
			TweenHilang.Completed:Connect(function()
				KartuUndangan:Destroy()
				Event.TambahinUndangan:FireServer("tolak invite", SiapaInvite)
			end)
		end)
		KartuUndangan.Terima.MouseButton1Click:Connect(function()
			print(Pemain, SiapaInvite)
			Event.TambahinUndangan:FireServer("terima invite", SiapaInvite)
			KartuUndangan:Destroy()
		end)
		TweenService:Create(KartuUndangan, TweenInfo.new(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			Position = UDim2.new(0, 0, .8, 0),
		}):Play()
		local WaktuTween = TweenService:Create(KartuUndangan.Waktu, TweenInfo.new(15, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, .05, 0),
		})
		WaktuTween:Play()
		WaktuTween.Completed:Wait()
		local TweenHilang = TweenService:Create(KartuUndangan, TweenInfo.new(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			Position = UDim2.new(1, 0, KartuUndangan.Position.Y.Scale + .1, 0),
		})
		TweenHilang:Play()
		TweenHilang.Completed:Connect(function()
			KartuUndangan:Destroy()
		end)
	elseif indikasi == "terima invite" then
		Loading_UI.Enabled = true
		Loading_UI.LoadingFrame.LocalScript.Enabled = true
		Loading_UI.LoadingFrame.Visible = false
		Loading_UI.LoadingFrame.judul.Text = "Teleporting please wait..."
		local TweenHitam = TweenService:Create(Loading_UI.ScreenHITAM, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.fromScale(1, 1),
		})
		TweenHitam:Play()
		TweenHitam.Completed:Wait()
		Loading_UI.LoadingFrame.Visible = true
		wait(.5)
		TweenHitam = TweenService:Create(Loading_UI.ScreenHITAM, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.fromScale(1, 0),
		})
		TweenHitam:Play()
		TweenHitam.Completed:Wait()
	elseif indikasi == "tolak invite" then
		local TemplatePemain = Menu_UI.MenuFrame.UndanganMenu.TempatPemain:FindFirstChild(SiapaInvite.Name)
		if TemplatePemain then
			TemplatePemain.Undang.Text = "Invite"
		end
	end
end)
Event.TeleportBalikKeGame.OnClientEvent:Connect(function(kode)
	Menu_UI.MenuFrame.TeleportKeGame.masuk.MouseButton1Click:Connect(function()
		Event.TeleportBalikKeGame:FireServer(kode)
	end)
	TweenService:Create(Menu_UI.MenuFrame.TeleportKeGame, TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(.425, .85),
	}):Play()
end)
Event.KirimItemShop.OnClientEvent:Connect(function(BarangItem)
	local _exp = Menu_UI.MenuFrame.TokoMenu.TempatBayaran:GetChildren()
	local _arg0 = function(v)
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	for _k, _v in _exp do
		_arg0(_v, _k - 1, _exp)
	end
	local _barangItem = BarangItem
	local _arg0_1 = function(v)
		local Item = Komponen_UI.ItemEffect:Clone()
		local _arg0_2 = function(j)
			return j == v
		end
		-- ▼ ReadonlyArray.find ▼
		local _result_4
		for _i, _v in SemuaKematian do
			if _arg0_2(_v, _i - 1, SemuaKematian) == true then
				_result_4 = _v
				break
			end
		end
		-- ▲ ReadonlyArray.find ▲
		if _result_4 ~= "" and _result_4 then
			local DataKematian = Kematian[v]
			Item.Nama.Text = DataKematian.NamaLain
			Item.Tipe.Text = "Effect"
			Item.Gambar.Image = DataKematian.Gambar
			Item.Gambar.Visible = true
			if DataPemain.DataBarang.BarangKematian:FindFirstChild(v) then
				Item.Beli.Text = "Owned"
			else
				Item.Beli.Text = "$" .. tostring(DataKematian.Harga)
				local Koneksi
				Koneksi = Item.Beli.MouseButton1Click:Connect(function()
					local Status = Event.BeliBarang:InvokeServer(v)
					repeat
						if Status == "Sudah Beli" then
							Item.Beli.Text = "Owned"
							Koneksi:Disconnect()
							break
						end
						if Status == "Tidak cukup" then
							Item.Beli.Text = "Not enough money"
							wait(1)
							Item.Beli.Text = "$" .. tostring(DataKematian.Harga)
							break
						end
					until true
				end)
			end
		else
			local _arg0_3 = function(j)
				return j == v
			end
			-- ▼ ReadonlyArray.find ▼
			local _result_5
			for _i, _v in SemuaKursi do
				if _arg0_3(_v, _i - 1, SemuaKursi) == true then
					_result_5 = _v
					break
				end
			end
			-- ▲ ReadonlyArray.find ▲
			if _result_5 ~= "" and _result_5 then
				local DataKursi = Kursi[v]
				Item.Nama.Text = DataKursi.NamaLain
				Item.Beli.Text = "$" .. tostring(DataKursi.Harga)
				Item.Tipe.Text = "Chair"
				Item.ViewportFrame.Visible = true
				if DataPemain.DataBarang.BarangKursi:FindFirstChild(v) then
					Item.Beli.Text = "Owned"
				else
					Item.Beli.Text = "$" .. tostring(DataKursi.Harga)
					local Koneksi
					Koneksi = Item.Beli.MouseButton1Click:Connect(function()
						local Status = Event.BeliBarang:InvokeServer(v)
						repeat
							if Status == "Sudah Beli" then
								Item.Beli.Text = "Owned"
								Koneksi:Disconnect()
								break
							end
							if Status == "Tidak cukup" then
								Item.Beli.Text = "Not enough money"
								wait(1)
								Item.Beli.Text = "$" .. tostring(DataKursi.Harga)
								break
							end
						until true
					end)
				end
				local ModulKursi = DataKursi.Kursi:Clone()
				ModulKursi.Parent = Item.ViewportFrame
			end
		end
		Item.Parent = Menu_UI.MenuFrame.TokoMenu.TempatBayaran
	end
	for _k, _v in _barangItem do
		_arg0_1(_v, _k - 1, _barangItem)
	end
end)
Event.UpdateWaktuShop.OnClientEvent:Connect(function(waktu)
	Menu_UI.MenuFrame.TokoMenu.waktuGanti.Text = toHMS(waktu)
end)
Event.UpdateLeaderboard.OnClientEvent:Connect(function(Data)
	local TempatStatus = {
		Point = Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain,
		Menang = Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang,
		Kalah = Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah,
		JumlahMain = Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain,
	}
	for Status, Informasi in pairs(Data) do
		local _exp = TempatStatus[Status]:GetChildren()
		local _arg0 = function(v)
			if v:IsA("Frame") and v.Name ~= "PemainLeaderboard" then
				v:Destroy()
			end
		end
		for _k, _v in _exp do
			_arg0(_v, _k - 1, _exp)
		end
		local i = 1
		local _arg0_1 = function(v)
			if tonumber(v.key) > 1 then
				local NamaPemain = Players:GetNameFromUserIdAsync(tonumber(v.key))
				if not TempatStatus[Status]:FindFirstChild(NamaPemain) then
					local ContohLeaderboard = Komponen_UI.PemainLeaderboard:Clone()
					ContohLeaderboard.Nama.Text = NamaPemain
					ContohLeaderboard.Nomor.Text = tostring(i)
					ContohLeaderboard.Point.Text = tostring(v.value)
					ContohLeaderboard.Name = NamaPemain
					ContohLeaderboard.Parent = TempatStatus[Status]
					i += 1
				end
			end
		end
		for _k, _v in Informasi do
			_arg0_1(_v, _k - 1, Informasi)
		end
	end
end)
local PosisiSemula = {
	TombolUndang = Menu_UI.MenuFrame.TombolFrame.Undang.Position,
	TombolBot = Menu_UI.MenuFrame.TombolFrame.MainBot.Position,
	TombolAnalisis = Menu_UI.MenuFrame.TombolFrame.Analisis.Position,
	TombolToko = Menu_UI.MenuFrame.TombolFrame.Toko.Position,
	TombolProfile = Menu_UI.MenuFrame.TombolFrame.Profile.Position,
	TombolLeaderboard = Menu_UI.MenuFrame.TombolFrame.Leaderboard.Position,
	TombolQuickPlay = Menu_UI.MenuFrame.TombolFrame.QuickPlay.Position,
	TombolInventory = Menu_UI.MenuFrame.TombolFrame.Inventory.Position,
	TombolFrame = Menu_UI.MenuFrame.TombolFrame.Position,
	UndanganMenu = Menu_UI.MenuFrame.UndanganMenu.Position,
	LeaderboardMenu = Menu_UI.MenuFrame.LeaderboardMenu.Position,
	SettingsMenu = Menu_UI.MenuFrame.SettingsMenu.Position,
	TokoMenu = Menu_UI.MenuFrame.TokoMenu.Position,
	InventoryMenu = Menu_UI.MenuFrame.InventoryMenu.Position,
	ProfileMenu = Menu_UI.MenuFrame.ProfileMenu.Position,
	GerakanFrame = Menu_UI.GerakanFrame.Position,
}
local apakahDimenu = true
local PilihanMenu = nil
local ColorPickerDipilih
-- Tombol Quickplay
local ApakahDalamQueue = false
local WaktuDalamQueue = 0
Menu_UI.MenuFrame.TombolFrame.QuickPlay.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	Event.TambahinQueue:FireServer("DALAM QUEUE")
	ApakahDalamQueue = true
	TweenService:Create(Menu_UI.MenuFrame.QueueMenu, TweenInfo.new(.3, Enum.EasingStyle.Sine), {
		Position = UDim2.new(0, 0, .9, 0),
	}):Play()
	coroutine.wrap(function()
		while ApakahDalamQueue do
			WaktuDalamQueue += 1
			Menu_UI.MenuFrame.QueueMenu.Waktu.Text = toMS(WaktuDalamQueue)
			task.wait(1)
		end
	end)()
end)
Menu_UI.MenuFrame.QueueMenu.Batalin.MouseButton1Click:Connect(function()
	Event.TambahinQueue:FireServer("QUEUE")
	ApakahDalamQueue = false
	WaktuDalamQueue = 0
	TweenService:Create(Menu_UI.MenuFrame.QueueMenu, TweenInfo.new(.3, Enum.EasingStyle.Sine), {
		Position = UDim2.new(0, 0, 1, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.QuickPlay.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.QuickPlay, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolQuickPlay.X.Scale + .08, 0, PosisiSemula.TombolQuickPlay.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.QuickPlay.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.QuickPlay, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolQuickPlay.X.Scale, 0, PosisiSemula.TombolQuickPlay.Y.Scale, 0),
	}):Play()
end)
-- Tombol Undangan
Menu_UI.MenuFrame.TombolFrame.Undang.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	if PilihanMenu then
		if PilihanMenu.Name == "UndanganMenu" then
			TweenService:Create(Menu_UI.MenuFrame.UndanganMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.UndanganMenu.X.Scale + .65, 0, PosisiSemula.UndanganMenu.Y.Scale, 0),
			}):Play()
			TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
			}):Play()
			PilihanMenu = nil
			return nil
		else
			local TweenLainnya = TweenService:Create(PilihanMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0),
			})
			TweenLainnya:Play()
			TweenLainnya.Completed:Wait()
		end
	end
	PilihanMenu = Menu_UI.MenuFrame.UndanganMenu
	TweenService:Create(Menu_UI.MenuFrame.UndanganMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.UndanganMenu.X.Scale - .65, 0, PosisiSemula.UndanganMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Undang.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Undang, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolUndang.X.Scale + .08, 0, PosisiSemula.TombolUndang.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Undang.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Undang, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolUndang.X.Scale, 0, PosisiSemula.TombolUndang.Y.Scale, 0),
	}):Play()
end)
-- Tombol Mainbot
Menu_UI.MenuFrame.TombolFrame.MainBot.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.75, Enum.EasingStyle.Back), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .5, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.UndanganMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.UndanganMenu.X.Scale, 0, PosisiSemula.UndanganMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.GerakanFrame, TweenInfo.new(.25, Enum.EasingStyle.Linear), {
		Position = UDim2.new(PosisiSemula.GerakanFrame.X.Scale, 0, -.5, 0),
	}):Play()
	apakahDimenu = false
	Event.Mulai:FireServer("komputer")
end)
Menu_UI.MenuFrame.TombolFrame.MainBot.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.MainBot, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolBot.X.Scale + .08, 0, PosisiSemula.TombolBot.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.MainBot.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.MainBot, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolBot.X.Scale, 0, PosisiSemula.TombolBot.Y.Scale, 0),
	}):Play()
end)
-- Tombol Analisis
Menu_UI.MenuFrame.TombolFrame.Analisis.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.75, Enum.EasingStyle.Back), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .5, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.UndanganMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.UndanganMenu.X.Scale, 0, PosisiSemula.UndanganMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.GerakanFrame, TweenInfo.new(.25, Enum.EasingStyle.Linear), {
		Position = UDim2.new(PosisiSemula.GerakanFrame.X.Scale, 0, -.5, 0),
	}):Play()
	if PilihanMenu then
		TweenService:Create(PilihanMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
			Position = UDim2.new(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0),
		}):Play()
		PilihanMenu = nil
	end
	apakahDimenu = false
	TweenService:Create(CaturUI, TweenInfo.new(.3), {
		Position = UDim2.fromScale(0, 0),
	}):Play()
	Event.Mulai:FireServer("analisis")
end)
Menu_UI.MenuFrame.TombolFrame.Analisis.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Analisis, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolAnalisis.X.Scale + .08, 0, PosisiSemula.TombolAnalisis.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Analisis.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Analisis, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolAnalisis.X.Scale, 0, PosisiSemula.TombolAnalisis.Y.Scale, 0),
	}):Play()
end)
-- Tombol Leaderboard
Menu_UI.MenuFrame.TombolFrame.Leaderboard.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	if PilihanMenu then
		if PilihanMenu.Name == "LeaderboardMenu" then
			TweenService:Create(Menu_UI.MenuFrame.LeaderboardMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.LeaderboardMenu.X.Scale + .65, 0, PosisiSemula.LeaderboardMenu.Y.Scale, 0),
			}):Play()
			TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
			}):Play()
			PilihanMenu = nil
			return nil
		else
			local TweenLainnya = TweenService:Create(PilihanMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0),
			})
			TweenLainnya:Play()
			TweenLainnya.Completed:Wait()
		end
	end
	PilihanMenu = Menu_UI.MenuFrame.LeaderboardMenu
	TweenService:Create(Menu_UI.MenuFrame.LeaderboardMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.LeaderboardMenu.X.Scale - .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Leaderboard.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Leaderboard, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolLeaderboard.X.Scale + .08, 0, PosisiSemula.TombolLeaderboard.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Leaderboard.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Leaderboard, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolLeaderboard.X.Scale, 0, PosisiSemula.TombolLeaderboard.Y.Scale, 0),
	}):Play()
end)
-- Tombol Profile
Menu_UI.MenuFrame.TombolFrame.Profile.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	if PilihanMenu then
		if PilihanMenu.Name == "ProfileMenu" then
			TweenService:Create(Menu_UI.MenuFrame.ProfileMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.ProfileMenu.X.Scale + .65, 0, PosisiSemula.ProfileMenu.Y.Scale, 0),
			}):Play()
			TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
			}):Play()
			PilihanMenu = nil
			return nil
		else
			local TweenLainnya = TweenService:Create(PilihanMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0),
			})
			TweenLainnya:Play()
			TweenLainnya.Completed:Wait()
		end
	end
	PilihanMenu = Menu_UI.MenuFrame.ProfileMenu
	TweenService:Create(Menu_UI.MenuFrame.ProfileMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.ProfileMenu.X.Scale - .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Profile.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Profile, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolProfile.X.Scale + .08, 0, PosisiSemula.TombolProfile.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Profile.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Profile, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolProfile.X.Scale, 0, PosisiSemula.TombolProfile.Y.Scale, 0),
	}):Play()
end)
-- Tombol Settings
Menu_UI.MenuFrame.Settings.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	if PilihanMenu then
		if PilihanMenu.Name == "SettingsMenu" then
			TweenService:Create(Menu_UI.MenuFrame.SettingsMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.SettingsMenu.X.Scale + .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0),
			}):Play()
			TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
			}):Play()
			PilihanMenu = nil
			return nil
		else
			local TweenLainnya = TweenService:Create(PilihanMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0),
			})
			TweenLainnya:Play()
			TweenLainnya.Completed:Wait()
		end
	end
	PilihanMenu = Menu_UI.MenuFrame.SettingsMenu
	TweenService:Create(Menu_UI.MenuFrame.SettingsMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.SettingsMenu.X.Scale - .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
end)
-- Tombol Toko
Menu_UI.MenuFrame.TombolFrame.Toko.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	if PilihanMenu then
		if PilihanMenu.Name == "TokoMenu" then
			TweenService:Create(Menu_UI.MenuFrame.TokoMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.TokoMenu.X.Scale + .65, 0, PosisiSemula.TokoMenu.Y.Scale, 0),
			}):Play()
			TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
			}):Play()
			PilihanMenu = nil
			return nil
		else
			local TweenLainnya = TweenService:Create(PilihanMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0),
			})
			TweenLainnya:Play()
			TweenLainnya.Completed:Wait()
		end
	end
	PilihanMenu = Menu_UI.MenuFrame.TokoMenu
	TweenService:Create(Menu_UI.MenuFrame.TokoMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TokoMenu.X.Scale - .65, 0, PosisiSemula.TokoMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Toko.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Toko, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolToko.X.Scale + .08, 0, PosisiSemula.TombolToko.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Toko.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Toko, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolToko.X.Scale, 0, PosisiSemula.TombolToko.Y.Scale, 0),
	}):Play()
end)
-- Tombol Inventory
Menu_UI.MenuFrame.TombolFrame.Inventory.MouseButton1Click:Connect(function()
	StarterGui.Suara.Klik:Play()
	if PilihanMenu then
		if PilihanMenu.Name == "InventoryMenu" then
			TweenService:Create(Menu_UI.MenuFrame.InventoryMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.InventoryMenu.X.Scale + .65, 0, PosisiSemula.InventoryMenu.Y.Scale, 0),
			}):Play()
			TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
			}):Play()
			PilihanMenu = nil
			return nil
		else
			local TweenLainnya = TweenService:Create(PilihanMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
				Position = UDim2.new(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0),
			})
			TweenLainnya:Play()
			TweenLainnya.Completed:Wait()
		end
	end
	PilihanMenu = Menu_UI.MenuFrame.InventoryMenu
	TweenService:Create(Menu_UI.MenuFrame.InventoryMenu, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.InventoryMenu.X.Scale - .65, 0, PosisiSemula.InventoryMenu.Y.Scale, 0),
	}):Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame, TweenInfo.new(.5, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Inventory.MouseEnter:Connect(function()
	StarterGui.Suara.Tombol:Play()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Inventory, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolInventory.X.Scale + .08, 0, PosisiSemula.TombolInventory.Y.Scale, 0),
	}):Play()
end)
Menu_UI.MenuFrame.TombolFrame.Inventory.MouseLeave:Connect(function()
	TweenService:Create(Menu_UI.MenuFrame.TombolFrame.Inventory, TweenInfo.new(.12, Enum.EasingStyle.Sine), {
		Position = UDim2.new(PosisiSemula.TombolInventory.X.Scale, 0, PosisiSemula.TombolInventory.Y.Scale, 0),
	}):Play()
end)
-- Tombol Warna
Menu_UI.MenuFrame.SettingsMenu.Frame.Warna1.Warna.MouseButton1Click:Connect(function()
	if ColorPickerDipilih then
		ColorPickerDipilih:Destroy()
	end
	Menu_UI.MenuFrame.SettingsMenu.Frame.Warna2.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value)
	local PilihWarna = Komponen_UI.ColorPickers:Clone()
	PilihWarna.ColorPickerLocal.Enabled = true
	PilihWarna.Name = "Warna1"
	PilihWarna.Parent = Menu_UI.MenuFrame.SettingsMenu
	ColorPickerDipilih = PilihWarna
end)
Menu_UI.MenuFrame.SettingsMenu.Frame.Warna2.Warna.MouseButton1Click:Connect(function()
	if ColorPickerDipilih then
		ColorPickerDipilih:Destroy()
	end
	Menu_UI.MenuFrame.SettingsMenu.Frame.Warna1.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value)
	local PilihWarna = Komponen_UI.ColorPickers:Clone()
	PilihWarna.ColorPickerLocal.Enabled = true
	PilihWarna.Name = "Warna2"
	PilihWarna.Parent = Menu_UI.MenuFrame.SettingsMenu
	ColorPickerDipilih = PilihWarna
end)
-- Tombol Leaderboard
Menu_UI.MenuFrame.LeaderboardMenu.WinPalingBanyak.MouseButton1Click:Connect(function()
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = true
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = false
end)
Menu_UI.MenuFrame.LeaderboardMenu.LosePalingBanyak.MouseButton1Click:Connect(function()
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = true
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = false
end)
Menu_UI.MenuFrame.LeaderboardMenu.MainPalingBanyak.MouseButton1Click:Connect(function()
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = true
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = false
end)
Menu_UI.MenuFrame.LeaderboardMenu.PointPalingBanyak.MouseButton1Click:Connect(function()
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = false
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = true
end)
coroutine.wrap(function()
	local tween = TweenService:Create(Menu_UI.GerakanFrame, TweenInfo.new(20, Enum.EasingStyle.Linear), {
		Position = UDim2.new(-.5, 0, .5, 0),
	})
	while true do
		if apakahDimenu then
			Menu_UI.GerakanFrame.Position = UDim2.new(.5, 0, .5, 0)
			tween:Play()
			tween.Completed:Wait()
		else
			wait(1)
		end
	end
end)()
Loading_UI.Enabled = true
Loading_UI.LoadingFrame.LocalScript.Enabled = true
wait(3)
local TweenHitam = TweenService:Create(Loading_UI.ScreenHITAM, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
	Size = UDim2.fromScale(1, 1),
})
TweenHitam:Play()
TweenHitam.Completed:Wait()
Menu_UI.MenuFrame.SettingsMenu.Frame.Warna1.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value)
Menu_UI.MenuFrame.SettingsMenu.Frame.Warna2.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value)
local _exp = Menu_UI.GerakanFrame.Folder:GetChildren()
local _arg0 = function(v)
	if v:IsA("Frame") then
		v.BackgroundColor3 = if v.Name == "hitam" then Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) else Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value)
	end
end
for _k, _v in _exp do
	_arg0(_v, _k - 1, _exp)
end
local _exp_1 = Menu_UI.GerakanFrame.berikut:GetChildren()
local _arg0_1 = function(v)
	if v:IsA("Frame") then
		v.BackgroundColor3 = if v.Name == "hitam" then Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) else Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value)
	end
end
for _k, _v in _exp_1 do
	_arg0_1(_v, _k - 1, _exp_1)
end
Menu_UI.MenuFrame.ProfileMenu.Gambar.Image = (Players:GetUserThumbnailAsync(Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420))
Menu_UI.MenuFrame.ProfileMenu.Nama.Text = Pemain.Name
Menu_UI.MenuFrame.ProfileMenu.Point.Text = "Points: " .. tostring(Pemain.DataPemain.DataPoint.Point.Value)
Menu_UI.MenuFrame.ProfileMenu.Menang.Text = "Wins: " .. tostring(Pemain.DataPemain.DataStatus.Menang.Value)
Menu_UI.MenuFrame.ProfileMenu.Kalah.Text = "Lose: " .. tostring(Pemain.DataPemain.DataStatus.Kalah.Value)
Menu_UI.MenuFrame.ProfileMenu.JumlahMain.Text = "Total Played: " .. tostring(Pemain.DataPemain.DataStatus.JumlahMain.Value)
Menu_UI.MenuFrame.TokoMenu.uang.Text = "$" .. tostring(DataPemain.Uang.Value)
DataPemain.Uang.Changed:Connect(function(v)
	Menu_UI.MenuFrame.TokoMenu.uang.Text = "$" .. tostring(v)
end)
local KursiModel = ReplicatedStorage.kursi[DataPemain.DataBarang.kursi.Value]:Clone()
KursiModel.Parent = Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.KursiViewport
Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.GantiKursi.MouseButton1Click:Connect(function()
	UpdateInventoryMenu({
		tipe = "kursi",
		tempatBarang = DataPemain.DataBarang.BarangKursi,
	})
end)
local GambarEffect = Kematian[DataPemain.DataBarang.kematian.Value]
Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.GambarKematian.Image = GambarEffect.Gambar
Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.GantiEffect.MouseButton1Click:Connect(function()
	UpdateInventoryMenu({
		tipe = "kematian",
		tempatBarang = DataPemain.DataBarang.BarangKematian,
	})
end)
local GambarSkin = SkinPiece[DataPemain.DataBarang.skinpiece.Value]
print(DataPemain.DataBarang.skinpiece.Value)
Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.GambarSkin.Image = GambarSkin.Gambar
Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.GantiSkin.MouseButton1Click:Connect(function()
	UpdateInventoryMenu({
		tipe = "skin",
		tempatBarang = DataPemain.DataBarang.BarangSkinPiece,
	})
end)
Menu_UI.MenuFrame.InventoryMenu.Inventory.Balik.MouseButton1Click:Connect(function()
	Menu_UI.MenuFrame.InventoryMenu.PilihanInventory.Visible = true
	Menu_UI.MenuFrame.InventoryMenu.Inventory.Visible = false
end)
local ReverseTable = {}
do
	local i = #Pemain.DataPemain.DataStatus.History:GetChildren() - 1
	local _shouldIncrement = false
	while true do
		if _shouldIncrement then
			i -= 1
		else
			_shouldIncrement = true
		end
		if not (i >= 0) then
			break
		end
		local _arg0_2 = Pemain.DataPemain.DataStatus.History:GetChildren()[i + 1]
		table.insert(ReverseTable, _arg0_2)
	end
end
local _arg0_2 = function(v)
	local Data = v
	local TemplateHistory = Komponen_UI.PemainProfile:Clone()
	TemplateHistory.NamaPemain1.Text = Data.Pemain1.nama.Value .. (" (" .. (tostring(Data.Pemain1.point.Value) .. ")"))
	TemplateHistory.NamaPemain2.Text = Data.Pemain2.nama.Value .. (" (" .. (tostring(Data.Pemain2.point.Value) .. ")"))
	TemplateHistory.Status.Text = if Data.YangMenang.Value == "w" then "White" elseif Data.YangMenang.Value == "seri" then "Draw" else "Black"
	TemplateHistory.Tanggal.Text = Data.Tanggal.Value
	TemplateHistory.Parent = Menu_UI.MenuFrame.ProfileMenu.TempatHistory
end
for _k, _v in ReverseTable do
	_arg0_2(_v, _k - 1, ReverseTable)
end
Loading_UI.LoadingFrame.Visible = false
wait(1)
TweenHitam = TweenService:Create(Loading_UI.ScreenHITAM, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
	Size = UDim2.fromScale(1, 0),
})
TweenHitam:Play()
TweenHitam.Completed:Wait()
Loading_UI.Enabled = false
Loading_UI.LoadingFrame.LocalScript.Enabled = false
if Pemain.DataPemain.Admin.Value or Pemain.DataPemain.Owner.Value then
	Menu_UI.MenuFrame.TombolFrame.Ban.Visible = true
	local UserId
	Menu_UI.MenuFrame.TombolFrame.Ban.MouseButton1Click:Connect(function()
		Menu_UI.MenuFrame.BanMenu.Visible = not Menu_UI.MenuFrame.BanMenu.Visible
		if Menu_UI.MenuFrame.BanMenu.Visible then
			local _exp_2 = Menu_UI.MenuFrame.BanMenu.Frame.TempatPemain:GetChildren()
			local _arg0_3 = function(v)
				if v:IsA("GuiButton") then
					v:Destroy()
				end
			end
			for _k, _v in _exp_2 do
				_arg0_3(_v, _k - 1, _exp_2)
			end
			local _exp_3 = Players:GetPlayers()
			local _arg0_4 = function(v)
				local BanTempalte = Komponen_UI.PemainBan:Clone()
				local gambar = (Players:GetUserThumbnailAsync(v.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420))
				BanTempalte.nama.Text = v.Name
				BanTempalte.gambar.Image = gambar
				BanTempalte.Parent = Menu_UI.MenuFrame.BanMenu.Frame.TempatPemain
				BanTempalte.MouseButton1Click:Connect(function()
					UserId = v.UserId
					Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.nama.Text = v.Name
					Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.gambar.Image = gambar
					Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.tulisanNama.Text = v.Name
				end)
			end
			for _k, _v in _exp_3 do
				_arg0_4(_v, _k - 1, _exp_3)
			end
		end
	end)
	Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.tulisanNama.FocusLost:Connect(function(enterPressed, input)
		local Text = Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.tulisanNama.Text
		if enterPressed and #Text > 1 then
			local succ, err = pcall(function()
				UserId = Players:GetUserIdFromNameAsync(Text)
			end)
			if succ then
				Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.nama.Text = Text
				Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.gambar.Image = (Players:GetUserThumbnailAsync(tonumber(UserId), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420))
			else
				Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.error.Text = "NAMA TIDAK ADA"
				Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.error.Visible = true
				Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.tulisanNama.Text = ""
				task.wait(1)
				Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.error.Visible = false
			end
		end
	end)
	Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.ban.MouseButton1Click:Connect(function()
		if UserId ~= 0 and (UserId == UserId and UserId) then
			Event.BanOrang:FireServer(UserId)
			Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.ban.Text = "SUDAH DI BAN"
			task.wait(1.5)
			Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.ban.Text = "ban!11!!!!! ATAU UNBAN"
		else
			Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.error.Text = "TIDAK ADA NAMA"
			Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.error.Visible = true
			task.wait(1)
			Menu_UI.MenuFrame.BanMenu.Frame.TempatStatus.error.Visible = false
		end
	end)
end
coroutine.wrap(function()
	while true do
		local _exp_2 = Players:GetPlayers()
		local _arg0_3 = function(v)
			if v.Name ~= Pemain.Name then
				local KartuPemain = Komponen_UI.KartuPemain:Clone()
				local kontentGambar, apakahSiap = Players:GetUserThumbnailAsync(v.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				KartuPemain.Name = v.Name
				KartuPemain.NamaPemain1.Text = v.Name
				KartuPemain.Pemain1.Image = kontentGambar
				KartuPemain.Undang.MouseButton1Click:Connect(function()
					KartuPemain.Undang.Text = "Inviting..."
					Event.TambahinUndangan:FireServer("kirim invite", v)
				end)
				KartuPemain.Parent = Menu_UI.MenuFrame.UndanganMenu.TempatPemain
			end
		end
		for _k, _v in _exp_2 do
			_arg0_3(_v, _k - 1, _exp_2)
		end
		wait(10)
		local _exp_3 = Menu_UI.MenuFrame.UndanganMenu.TempatPemain:GetChildren()
		local _arg0_4 = function(v)
			v:Destroy()
		end
		for _k, _v in _exp_3 do
			_arg0_4(_v, _k - 1, _exp_3)
		end
	end
end)()
local _result_4 = script.Parent
if _result_4 ~= nil then
	_result_4 = _result_4.Parent
end
_result_4.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
UIS.ModalEnabled = true
while true do
	local MusicPertama = StarterGui.Suara.SuaraBelakang.Pertama
	MusicPertama:Play()
	MusicPertama.Ended:Wait()
	wait(3)
	local MusicKedua = StarterGui.Suara.SuaraBelakang.Kedua
	MusicKedua:Play()
	MusicKedua.Ended:Wait()
	wait(3)
	local MusicKetiga = StarterGui.Suara.SuaraBelakang.Ketiga
	MusicKetiga:Play()
	MusicKetiga.Ended:Wait()
	wait(3)
end
