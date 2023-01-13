-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Debris = _services.Debris
local ReplicatedStorage = _services.ReplicatedStorage
local Workspace = _services.Workspace
local Tween = game:GetService("TweenService")
local SemuaKematian = { "meledak", "kembang_api", "ditelan_kegelapan", "dilempar_kaleng" }
local SemuaKursi = { "kursi_plastik", "kursi_kerja" }
local SemuaSkinPiece = { "anime" }
local Kematian = {
	kematian_biasa = {
		NamaLain = "No Effect",
		Harga = 0,
		Gambar = "rbxassetid://8516027328",
	},
	meledak = {
		NamaLain = "Explode",
		Harga = 1500,
		Gambar = "rbxassetid://9571787764",
	},
	kembang_api = {
		NamaLain = "Firework",
		Harga = 1800,
		Gambar = "rbxassetid://1369782576",
	},
	ditelan_kegelapan = {
		NamaLain = "Into the darkness",
		Harga = 1500,
		Gambar = "rbxassetid://153700391",
	},
	dilempar_kaleng = {
		NamaLain = "Bloxycola",
		Harga = 2000,
		Gambar = "rbxassetid://914656783",
	},
	kematian_vip = {
		NamaLain = "VIP Effect",
		Harga = 0,
		Gambar = "",
	},
}
local Kursi = {
	kursi_biasa = {
		NamaLain = "Normal",
		Harga = 0,
		Kursi = ReplicatedStorage.kursi.kursi_biasa,
	},
	kursi_plastik = {
		NamaLain = "White plastic",
		Harga = 1500,
		Kursi = ReplicatedStorage.kursi.kursi_plastik,
	},
	kursi_kerja = {
		NamaLain = "Office chair",
		Harga = 1500,
		Kursi = ReplicatedStorage.kursi.kursi_kerja,
	},
	kursi_vip = {
		NamaLain = "VIP Chair",
		Harga = 0,
		Kursi = ReplicatedStorage.kursi.kursi_vip,
	},
}
local SkinPiece = {
	skin_biasa = {
		NamaLain = "Normal",
		Harga = 0,
		Gambar = "rbxassetid://12113047759",
	},
	anime = {
		NamaLain = "Anime pieces",
		Harga = 1750,
		Gambar = "rbxassetid://12113545854",
	},
}
local Meledak = function(kursi)
	local SuaraLedak = Instance.new("Sound")
	SuaraLedak.SoundId = "rbxasset://sounds/collide.wav"
	SuaraLedak.Parent = kursi
	SuaraLedak:Play()
	local Peledak = Instance.new("Explosion")
	Peledak.BlastPressure = 0
	Peledak.BlastRadius = 0
	Peledak.DestroyJointRadiusPercent = 0
	Peledak.Position = kursi.utama.Position
	Peledak.Parent = kursi.utama
	kursi.utama.AssemblyLinearVelocity = Vector3.new(0, 100, -30)
	kursi.utama.AssemblyAngularVelocity = Vector3.new(0, 10, 5)
end
local Kembang_Api = function(kursi)
	local KembangApi = ReplicatedStorage.komponenKematian.PartikelKembangApi:Clone()
	local SuaraKembangApi = Instance.new("Sound")
	SuaraKembangApi.SoundId = "rbxasset://sounds//Rocket shot.wav"
	SuaraKembangApi.Parent = Workspace
	SuaraKembangApi:Play()
	kursi.utama.AssemblyLinearVelocity = Vector3.new(0, 200, -100)
	kursi.utama.AssemblyAngularVelocity = Vector3.new(0, 10, 15)
	KembangApi.Parent = kursi.utama
	wait(2)
	local SuaraLedak = Instance.new("Sound")
	SuaraLedak.SoundId = "rbxasset://sounds/collide.wav"
	SuaraLedak.Parent = Workspace
	SuaraLedak:Play()
	SuaraKembangApi:Destroy()
	local Peledak = Instance.new("Explosion")
	Peledak.BlastPressure = 0
	Peledak.BlastRadius = 0
	Peledak.DestroyJointRadiusPercent = 0
	Peledak.Position = kursi.utama.Position
	Peledak.Parent = kursi.utama
	kursi.utama.AssemblyLinearVelocity = Vector3.new(50, 100, 0)
	kursi.utama.AssemblyAngularVelocity = Vector3.new(0, 10, 5)
	wait(.3)
	KembangApi:Destroy()
end
local Ditelan_Kegelapan = function(kursi, KarakterPemainKalah)
	local Bulatan = ReplicatedStorage.komponenKematian.bulat:Clone()
	local _position = kursi.utama.Position
	local _vector3 = Vector3.new(0, -2, 0)
	Bulatan.Position = _position + _vector3
	Bulatan.Parent = kursi
	local Batas = Instance.new("Part")
	local _cFrame = KarakterPemainKalah.HumanoidRootPart.CFrame
	local _cFrame_1 = CFrame.new(0, -10, 0)
	Batas.CFrame = _cFrame * _cFrame_1
	Batas.Size = Vector3.new(15, .2, 15)
	Batas.Transparency = 1
	Batas.Parent = kursi
	local TweenBulataan = Tween:Create(Bulatan, TweenInfo.new(1.5), {
		Size = Vector3.new(0.1, 6, 6),
	})
	TweenBulataan:Play()
	TweenBulataan.Completed:Wait()
	KarakterPemainKalah.HumanoidRootPart.Anchored = true
	wait(.5)
	local _fn = Tween
	local _exp = KarakterPemainKalah.HumanoidRootPart
	local _exp_1 = TweenInfo.new(3)
	local _object = {}
	local _left = "CFrame"
	local _cFrame_2 = KarakterPemainKalah.HumanoidRootPart.CFrame
	local _cFrame_3 = CFrame.new(0, -6, 0)
	_object[_left] = _cFrame_2 * _cFrame_3
	local TweenPemain = _fn:Create(_exp, _exp_1, _object)
	TweenPemain:Play()
	TweenPemain.Completed:Wait()
	wait(.2)
	local TweenTutup = Tween:Create(Bulatan, TweenInfo.new(1.5), {
		Size = Vector3.new(0.1, 0.01, 0.01),
	})
	TweenTutup:Play()
	TweenTutup.Completed:Connect(function()
		Bulatan:Destroy()
	end)
end
local Dilempar_Kaleng = function(kursi, KarakterPemainKalah)
	local DariLempar = ReplicatedStorage.komponenKematian.DariKaleng:Clone()
	DariLempar.Parent = Workspace
	local _position = KarakterPemainKalah.Head.Position
	local _position_1 = DariLempar.Position
	local arah = _position - _position_1
	local durasi = math.log(1.001 + arah.Magnitude * 0.01)
	local _exp = arah / durasi
	local _vector3 = Vector3.new(0, Workspace.Gravity * durasi * .5, 0)
	local gaya = _exp + _vector3
	local SuaraMinum = Instance.new("Sound")
	SuaraMinum.SoundId = "rbxassetid://10722059"
	SuaraMinum.Volume = 2
	SuaraMinum.Parent = Workspace
	SuaraMinum:Play()
	SuaraMinum.Ended:Wait()
	wait(1)
	local Kaleng = ReplicatedStorage.komponenKematian.Kaleng:Clone()
	Kaleng.Position = DariLempar.Position
	Kaleng.Parent = Workspace
	local _fn = Kaleng
	local _assemblyMass = Kaleng.AssemblyMass
	_fn:ApplyImpulse(gaya * _assemblyMass)
	Kaleng:SetNetworkOwner(nil)
	wait(durasi + .15)
	local SuaraKena = Instance.new("Sound")
	SuaraKena.SoundId = "rbxassetid://2303101209"
	SuaraKena.Volume = 2
	SuaraKena.Parent = Workspace
	SuaraKena:Play()
	kursi.utama.AssemblyLinearVelocity = Vector3.new(30, 0, 3)
end
local KematianVIP = function(kursi, KarakterPemainKalah, KarakterPemainMenang)
	local PistolClone = ReplicatedStorage.komponenKematian.Pistol:Clone()
	local SuaraEquip = PistolClone.Handle.GunEquip
	SuaraEquip.Parent = Workspace
	SuaraEquip:Play()
	PistolClone.Parent = KarakterPemainMenang
	SuaraEquip.Ended:Wait()
	wait(1)
	local Tembakan = Instance.new("Part", Workspace)
	Tembakan.BrickColor = BrickColor.new("New Yeller")
	Tembakan.Transparency = .25
	Tembakan.Anchored = true
	Tembakan.CanCollide = false
	local _position = PistolClone.TempatTembak.Position
	local _position_1 = KarakterPemainKalah.Head.Position
	local Distansi = (_position - _position_1).Magnitude
	Tembakan.Size = Vector3.new(.1, .1, Distansi)
	local _cFrame = CFrame.new(PistolClone.TempatTembak.Position, KarakterPemainKalah.Head.Position)
	local _cFrame_1 = CFrame.new(0, 0, -Distansi / 2)
	Tembakan.CFrame = _cFrame * _cFrame_1
	local SuaraTembak = PistolClone.Handle.GunFire
	SuaraTembak.Parent = Workspace
	SuaraTembak:Play()
	Debris:AddItem(Tembakan, .2)
	kursi.utama.AssemblyLinearVelocity = Vector3.new(60, 50, 0)
end
local function DapatinFungsiDariString(tipe)
	if tipe == "meledak" then
		return Meledak
	end
	if tipe == "kembang_api" then
		return Kembang_Api
	end
	if tipe == "ditelan_kegelapan" then
		return Ditelan_Kegelapan
	end
	if tipe == "dilempar_kaleng" then
		return Dilempar_Kaleng
	end
	if tipe == "kematian_vip" then
		return KematianVIP
	end
	return Meledak
end
local default = Kematian
return {
	DapatinFungsiDariString = DapatinFungsiDariString,
	SemuaKematian = SemuaKematian,
	SemuaKursi = SemuaKursi,
	SemuaSkinPiece = SemuaSkinPiece,
	Kematian = Kematian,
	Kursi = Kursi,
	SkinPiece = SkinPiece,
	default = default,
}
