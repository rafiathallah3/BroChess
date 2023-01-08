-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local TeleportService = _services.TeleportService
local Workspace = _services.Workspace
local DapatinFungsiDariString = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "ListKematian").DapatinFungsiDariString
local Chess = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "chess").Chess
local http = game:GetService("HttpService")
local DDS = game:GetService("DataStoreService")
local DDS_Settings = DDS:GetDataStore("DDS_Settings")
local DDS_Uang = DDS:GetDataStore("DDS_Uang")
local DDS_Barang = DDS:GetDataStore("DDS_Barang")
local DDS_Rating = DDS:GetDataStore("DDS_Rating")
local DDS_History = DDS:GetDataStore("DDS_History_2")
local DDS_Status = DDS:GetDataStore("DDS_Status")
-- const DDS_Match = DDS.GetDataStore("DDS_Match");
local DDS_Point_Ordered = DDS:GetOrderedDataStore("DDS_Point_Ordered")
local DDS_Menang_Ordered = DDS:GetOrderedDataStore("DDS_Menang_Ordered")
local DDS_Kalah_Ordered = DDS:GetOrderedDataStore("DDS_Kalah_Ordered")
local DDS_JumlahMain_Ordered = DDS:GetOrderedDataStore("DDS_JumlahMain_Ordered")
local InfoValue = ReplicatedStorage.InfoValue
local Event = ReplicatedStorage.remote
local Pemain = {}
local CaturGame
--[[
	Bugs
	1. Point tidak benar                            (Sudah)
	2. Promosi pawn belum di ganti                  (Sudah?)
	3. Pawn tiba tiba menghilang saat mau Promosi   (Sudah)
	4. PGN pawn makan piece error                   (Sudah?)
	5. Invite player jadi banyak,                   (Sudah)
	6. Fix kuning kuning,                           (Sudah)
	7. Posisi tempat makan salah                    (Sudah)
	8. REport salah                                 (Sudah)
	Kau rematch, Aku back to lobby, Abis itu aku tekan back to lobby gk
	Posisi arrow bisa ke semula                     (Sudah)
	Kamera tidak lcok                               (Sudah?)
	Point tidak berubah                             (Sudah?)
	Point tidak akurat dengan lobby sama match
	Win atau kalah ditambah dua untuk strugon       (Sudah?)
	Player left match otomatis selesai              (Sudah)
	sering Menolak draw dari opponent chat banyak
	Fix size ui nomor a4, a3, thing                 (Sudah)
	persentase menang gk nampak                     (Sudah)
	Random Error, Kalau SelesaiGame ndk muncul Pemenangan UI
]]
--[[
	Suggestion
	Tambahin map part 7
	Mati Ditabrak truk dan bis
	Tidak perlu klik dan tahan untuk menggerakan piece, hanya klik juga bisa    (Sudah)
	Bloxy cola death                                                            (Sudah need to test)
	Tambahin HIstory Match                                                      (Sudah)
	Tambahin Profile                                                            (Sudah)
	Tambahin Leaderboard, Paling banyak menang, kalah, point, main game         (Sudah)
	Membuat Arrow                                                               (Sudah)
	Premove?
	Diusahakan Save rating sesudah game selesai tanpa cutscene                  (Sudah)
	Tambahin Ban sistem
	Tambahin Spectator mode
]]
--[[
	Yang harus dilakukan
	Kalau gamenya diabandond apakah harus ditambahin ke history?                (no, sudah dilakukan)
	Kalau playernya lost connection apakah harus diabandon atau rematch?        (Diabandon)
	Tambahin Uang
]]
local function SelesaiGameDanKematian()
	local _binding = CaturGame:ApakahGameSelesai()
	local ApakahSelesai = _binding[1]
	local StatusSelesai = _binding[2]
	local SiapaPemenang = _binding[3]
	if ApakahSelesai then
		local Pemain1 = CaturGame:DapatinPemainDariWarna("w")
		local Pemain2 = CaturGame:DapatinPemainDariWarna("b")
		local DataPemain1 = Pemain1.Pemain.DataPemain
		local DataPemain2 = Pemain2.Pemain.DataPemain
		local _result = CaturGame.RatingPemain1
		if _result ~= nil then
			_result = _result.warna
		end
		local RatingPemain1 = if _result == Pemain1.warna then CaturGame.RatingPemain1 else CaturGame.RatingPemain2
		local _result_1 = CaturGame.RatingPemain2
		if _result_1 ~= nil then
			_result_1 = _result_1.warna
		end
		local RatingPemain2 = if _result_1 == Pemain2.warna then CaturGame.RatingPemain2 else CaturGame.RatingPemain1
		local PointPemain1 = DataPemain1.DataPoint.Point.Value
		local PointPemain2 = DataPemain2.DataPoint.Point.Value
		local UangPemain1 = DataPemain1.Uang.Value
		local UangPemain2 = DataPemain2.Uang.Value
		DataPemain1.Uang.Value += Pemain1.uang
		DataPemain2.Uang.Value += Pemain2.uang
		-- Kita perlu ini untuk tunjukkin point client
		if StatusSelesai ~= "draw" and SiapaPemenang == "w" or SiapaPemenang == "b" then
			local PemainMenang = CaturGame:DapatinPemainDariWarna(SiapaPemenang).Pemain
			local PemainKalah = CaturGame:DapatinPemainDariWarna(if SiapaPemenang == "w" then "b" else "w").Pemain
			if SiapaPemenang == "w" then
				DataPemain1.DataPoint.Point.Value = RatingPemain1.Menang.rating
				DataPemain1.DataPoint.RatingDeviation.Value = RatingPemain1.Menang.rd
				DataPemain1.DataPoint.Volatility.Value = RatingPemain1.Menang.vol
				DataPemain1.DataStatus.Menang.Value = RatingPemain1.JumlahMenang
				DataPemain1.Uang.Value += 20
				if RatingPemain2.Kalah.rating > 200 then
					DataPemain2.DataPoint.Point.Value = RatingPemain2.Kalah.rating
				else
					DataPemain2.DataPoint.Point.Value = 200
				end
				DataPemain2.DataPoint.RatingDeviation.Value = RatingPemain2.Kalah.rd
				DataPemain2.DataPoint.Volatility.Value = RatingPemain2.Kalah.vol
				DataPemain2.DataStatus.Kalah.Value = RatingPemain2.JumlahKalah
			else
				if RatingPemain1.Kalah.rating > 200 then
					DataPemain1.DataPoint.Point.Value = RatingPemain1.Kalah.rating
				else
					DataPemain1.DataPoint.Point.Value = 200
				end
				DataPemain1.DataPoint.RatingDeviation.Value = RatingPemain1.Kalah.rd
				DataPemain1.DataPoint.Volatility.Value = RatingPemain1.Kalah.vol
				DataPemain1.DataStatus.Kalah.Value = RatingPemain1.JumlahKalah
				DataPemain2.DataPoint.Point.Value = RatingPemain2.Menang.rating
				DataPemain2.DataPoint.RatingDeviation.Value = RatingPemain2.Menang.rd
				DataPemain2.DataPoint.Volatility.Value = RatingPemain2.Menang.vol
				DataPemain2.DataStatus.Menang.Value = RatingPemain2.JumlahMenang
				DataPemain2.Uang.Value += 20
			end
			wait(4)
			if StatusSelesai ~= "keluar game" then
				local FungsiKematian = DapatinFungsiDariString(PemainMenang.DataPemain.DataBarang.kematian.Value)
				if FungsiKematian ~= nil then
					FungsiKematian(Workspace.Tempat.meja_kursi.chairs:FindFirstChild(PemainKalah.Name), PemainKalah.Character or (PemainKalah.CharacterAdded:Wait()))
				end
			end
		else
			if SiapaPemenang ~= "Game Ended" then
				DataPemain1.DataPoint.Point.Value = RatingPemain1.Seri.rating
				DataPemain1.DataPoint.RatingDeviation.Value = RatingPemain1.Seri.rd
				DataPemain1.DataPoint.Volatility.Value = RatingPemain1.Seri.vol
				DataPemain2.DataPoint.Point.Value = RatingPemain2.Seri.rating
				DataPemain2.DataPoint.RatingDeviation.Value = RatingPemain2.Seri.rd
				DataPemain2.DataPoint.Volatility.Value = RatingPemain2.Seri.vol
			end
		end
		if SiapaPemenang ~= "Game Ended" then
			DataPemain1.DataStatus.JumlahMain.Value = RatingPemain1.JumlahMain
			DataPemain2.DataStatus.JumlahMain.Value = RatingPemain2.JumlahMain
		end
		task.wait(3)
		local DataYangPerlu = { {
			p1 = CaturGame.p1,
			p2 = CaturGame.p2,
		}, CaturGame:ApakahGameSelesai() }
		Event.TunjukkinMenangUI:FireClient(DataPemain1.Parent, "w", if StatusSelesai == "draw" then if SiapaPemenang == "Game Ended" then 0 else RatingPemain1.Seri.SelisihRating elseif SiapaPemenang == "w" then RatingPemain1.Menang.SelisihRating else RatingPemain1.Kalah.SelisihRating, PointPemain1, DataPemain1.Uang.Value - UangPemain1, UangPemain1, unpack(DataYangPerlu))
		Event.TunjukkinMenangUI:FireClient(DataPemain2.Parent, "b", if StatusSelesai == "draw" then if SiapaPemenang == "Game Ended" then 0 else RatingPemain2.Seri.SelisihRating elseif SiapaPemenang == "b" then RatingPemain2.Menang.SelisihRating else RatingPemain2.Kalah.SelisihRating, PointPemain2, DataPemain2.Uang.Value - UangPemain2, UangPemain2, unpack(DataYangPerlu))
	end
end
Event.GerakanCatur.OnServerEvent:Connect(function(p, awalPosisi, tujuanPosisi, promosi)
	local _exp = (CaturGame:moves({
		square = awalPosisi,
		verbose = true,
		warna = CaturGame:turn(),
	}))
	local _arg0 = function(v)
		return v.to
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#_exp)
	for _k, _v in _exp do
		_newValue[_k] = _arg0(_v, _k - 1, _exp)
	end
	-- ▲ ReadonlyArray.map ▲
	local GerakanPosisi = _newValue
	local WarnaPemain = CaturGame:DapatinWarnaDariPlayer(p)
	local DataPemain = CaturGame:DapatinPemainDariWarna(WarnaPemain)
	local _tujuanPosisi = tujuanPosisi
	local _condition = table.find(GerakanPosisi, _tujuanPosisi) ~= nil
	if _condition then
		_condition = WarnaPemain == CaturGame:turn()
	end
	if _condition then
		local HasilMove = CaturGame:move({
			from = awalPosisi,
			to = tujuanPosisi,
			promotion = promosi,
		})
		local _result = HasilMove
		if _result ~= nil then
			_result = _result.flags
		end
		if _result == "c" then
			local Uang = {
				p = 5,
				b = 10,
				n = 10,
				r = 15,
				q = 25,
				k = 0,
			}
			DataPemain.uang += Uang[HasilMove.captured]
		end
		if not DataPemain.SudahGerak then
			DataPemain.SudahGerak = true
		end
		local BoardNew = {}
		local _exp_1 = CaturGame:board()
		local _arg0_1 = function(v)
			local _v = v
			local _arg0_2 = function(j)
				local _j = j
				table.insert(BoardNew, _j)
			end
			for _k, _v_1 in _v do
				_arg0_2(_v_1, _k - 1, _v)
			end
		end
		for _k, _v in _exp_1 do
			_arg0_1(_v, _k - 1, _exp_1)
		end
		local DataCaturRaw = CaturGame:moves({
			verbose = true,
		})
		local DataGerakanCatur = {}
		local _arg0_2 = function(element)
			local _from = element.from
			if DataGerakanCatur[_from] == nil then
				local _from_1 = element.from
				local _arg1 = { element }
				DataGerakanCatur[_from_1] = _arg1
			else
				local _from_1 = element.from
				local _result_1 = DataGerakanCatur[_from_1]
				if _result_1 ~= nil then
					local _element = element
					table.insert(_result_1, _element)
				end
			end
		end
		for _k, _v in DataCaturRaw do
			_arg0_2(_v, _k - 1, DataCaturRaw)
		end
		local DataPengiriman = { {
			awalPosisi = awalPosisi,
			tujuanPosisi = tujuanPosisi,
		}, BoardNew, DataGerakanCatur, CaturGame:turn(), CaturGame:ApakahGameSelesai(), {
			warna = CaturGame:turn(),
			check = CaturGame:isCheck(),
		} }
		Event.KirimSemuaGerakan:FireClient(CaturGame.p1.Pemain, CaturGame.p1.warna, CaturGame.p2, unpack(DataPengiriman))
		if CaturGame.mode == "player" and CaturGame.p2 ~= nil then
			Event.KirimSemuaGerakan:FireClient(CaturGame.p2.Pemain, CaturGame.p2.warna, CaturGame.p1, unpack(DataPengiriman))
		end
		SelesaiGameDanKematian()
	end
end)
Event.Lapor.OnServerEvent:Connect(function(pemain, kontentLaporan, yangDiReport)
	if not pemain:FindFirstChild("SudahLapor") then
		local SudahLapor = Instance.new("StringValue")
		SudahLapor.Name = "SudahLapor"
		SudahLapor.Parent = pemain
		http:PostAsync("https://webhook.newstargeted.com/api/webhooks/1058334097241542716/BUBFPyom7_55TeuQXr0ishS0Ar6C7ydAuNTgmpS5s3I5TTawnYq5NpTm0C8uI0SxVQ5C", http:JSONEncode({
			embeds = { {
				author = {
					name = pemain.Name .. (" melaporkan " .. yangDiReport.Name),
				},
				description = "Status Selesai: " .. (tostring(CaturGame:ApakahGameSelesai()[2]) .. ("\n" .. (kontentLaporan .. ("\n" .. http:JSONEncode(CaturGame:header()))))),
				type = "rich",
				color = tonumber(0xffffff),
			}, {
				author = {
					name = "Gerakan",
				},
				description = CaturGame:DapatinPGN(),
				type = "rich",
				color = tonumber(0xffffff),
			} },
		}))
	end
end)
Event.Menyerah.OnServerEvent:Connect(function(pemain)
	local Warna = CaturGame:DapatinWarnaDariPlayer(pemain)
	if Warna ~= nil then
		local _condition = CaturGame.p1.SudahGerak
		if _condition then
			local _result = CaturGame.p2
			if _result ~= nil then
				_result = _result.SudahGerak
			end
			_condition = _result
		end
		if _condition then
			CaturGame:Menyerah(Warna)
			Event.KirimCaturPemenang:FireClient(CaturGame.p1.Pemain, if Warna == "w" then "b" else "w")
			Event.KirimCaturPemenang:FireClient(CaturGame.p2.Pemain, if Warna == "w" then "b" else "w")
		else
			CaturGame:SetAlasanSeri("Game Ended")
			Event.KirimCaturPemenang:FireClient(CaturGame.p1.Pemain, "seri")
			Event.KirimCaturPemenang:FireClient(CaturGame.p2.Pemain, "seri")
		end
		SelesaiGameDanKematian()
	end
end)
Event.Seri.OnServerEvent:Connect(function(pemain, instruksi, SiapaYangNgeDraw)
	if instruksi == "ajak seri" then
		if pemain.BerapaKaliDraw.Value <= 3 then
			pemain.BerapaKaliDraw.Value += 1
			local Warna = CaturGame:DapatinWarnaDariPlayer(pemain)
			local yangMauDiDraw = CaturGame:DapatinPemainDariWarna(if Warna == "w" then "b" else "w").Pemain
			local SeriValue = Instance.new("StringValue")
			SeriValue.Name = yangMauDiDraw.Name
			SeriValue.Parent = pemain
			Event.Seri:FireClient(yangMauDiDraw, "tunjukkin", pemain)
		end
	elseif instruksi == "terima seri" then
		if SiapaYangNgeDraw:FindFirstChild(pemain.Name) then
			local _result = SiapaYangNgeDraw:FindFirstChild(pemain.Name)
			if _result ~= nil then
				_result:Destroy()
			end
			CaturGame:SetAlasanSeri("Accept Draw")
			Event.Seri:FireClient(pemain, "terima seri")
			Event.Seri:FireClient(SiapaYangNgeDraw, "terima seri")
			Event.KirimCaturPemenang:FireClient(CaturGame.p1.Pemain, "seri")
			Event.KirimCaturPemenang:FireClient(CaturGame.p2.Pemain, "seri")
			SelesaiGameDanKematian()
		end
	elseif instruksi == "tolak seri" then
		Event.Seri:FireClient(SiapaYangNgeDraw, "tolak seri")
	end
end)
local TotalYangDiInvite = 1
Event.KirimRematch.OnServerEvent:Connect(function(pemain, yangDiInvite)
	if not pemain.DataPemain:FindFirstChild("LagiInvite") and TotalYangDiInvite < 3 then
		local LagiInvite = Instance.new("BoolValue")
		LagiInvite.Name = "LagiInvite"
		LagiInvite.Parent = pemain.DataPemain
		local LagiInvite2 = Instance.new("BoolValue")
		LagiInvite2.Name = "LagiInvite"
		LagiInvite2.Parent = yangDiInvite.DataPemain
		Event.KirimRematchKePemainUI:FireClient(yangDiInvite, pemain)
		LagiInvite:Destroy()
		TotalYangDiInvite += 1
	end
end)
Event.StatusRematch.OnServerEvent:Connect(function(pemain, siapainvite, status)
	if pemain.DataPemain:FindFirstChild("LagiInvite") then
		Event.TunjukkinRematchStatus:FireClient(siapainvite, status)
		if status == "terima" then
			TeleportService:TeleportToPrivateServer(11878754615, TeleportService:ReserveServer(11878754615), { pemain, siapainvite })
		end
	end
end)
Event.TeleportKeLobby.OnServerEvent:Connect(function(pemain)
	TeleportService:TeleportAsync(11738872153, { pemain })
end)
Players.PlayerAdded:Connect(function(pemain)
	local FolderDataPemain = Instance.new("Folder")
	FolderDataPemain.Name = "DataPemain"
	FolderDataPemain.Parent = pemain
	local DataPoint = Instance.new("Folder")
	DataPoint.Name = "DataPoint"
	DataPoint.Parent = FolderDataPemain
	local BerapaPoint = Instance.new("NumberValue")
	BerapaPoint.Name = "Point"
	BerapaPoint.Value = 1000
	BerapaPoint.Parent = DataPoint
	local BerapaRatingDeviation = Instance.new("NumberValue")
	BerapaRatingDeviation.Name = "RatingDeviation"
	BerapaRatingDeviation.Value = 100
	BerapaRatingDeviation.Parent = DataPoint
	local BerapaVolatility = Instance.new("NumberValue")
	BerapaVolatility.Name = "Volatility"
	BerapaVolatility.Value = 0.06
	BerapaVolatility.Parent = DataPoint
	local BerapaUang = Instance.new("NumberValue")
	BerapaUang.Name = "Uang"
	BerapaUang.Value = 0
	BerapaUang.Parent = FolderDataPemain
	local FolderSettings = Instance.new("Folder")
	FolderSettings.Name = "DataSettings"
	FolderSettings.Parent = FolderDataPemain
	local WarnaBoard1 = Instance.new("StringValue")
	WarnaBoard1.Name = "WarnaBoard1"
	WarnaBoard1.Value = Color3.fromRGB(170, 216, 124):ToHex()
	WarnaBoard1.Parent = FolderSettings
	local WarnaBoard2 = Instance.new("StringValue")
	WarnaBoard2.Name = "WarnaBoard2"
	WarnaBoard2.Value = Color3.fromRGB(255, 255, 255):ToHex()
	WarnaBoard2.Parent = FolderSettings
	local FolderBarang = Instance.new("Folder")
	FolderBarang.Name = "DataBarang"
	FolderBarang.Parent = FolderDataPemain
	local BarangKematian = Instance.new("Folder")
	BarangKematian.Name = "BarangKematian"
	BarangKematian.Parent = FolderBarang
	local BarangSkinPiece = Instance.new("Folder")
	BarangSkinPiece.Name = "BarangSkinPiece"
	BarangSkinPiece.Parent = FolderBarang
	local BarangKursi = Instance.new("Folder")
	BarangKursi.Name = "BarangKursi"
	BarangKursi.Parent = FolderBarang
	local SkinPiece = Instance.new("StringValue")
	SkinPiece.Name = "skinpiece"
	SkinPiece.Parent = FolderBarang
	local Kematian = Instance.new("StringValue")
	Kematian.Name = "kematian"
	Kematian.Value = "meledak"
	Kematian.Parent = FolderBarang
	local Kursi = Instance.new("StringValue")
	Kursi.Name = "kursi"
	Kursi.Value = "kursi_biasa"
	Kursi.Parent = FolderBarang
	local FolderStatus = Instance.new("Folder")
	FolderStatus.Name = "DataStatus"
	FolderStatus.Parent = FolderDataPemain
	local BerapaMenang = Instance.new("NumberValue")
	BerapaMenang.Name = "Menang"
	BerapaMenang.Parent = FolderStatus
	local BerapaKalah = Instance.new("NumberValue")
	BerapaKalah.Name = "Kalah"
	BerapaKalah.Parent = FolderStatus
	local BerapaMain = Instance.new("NumberValue")
	BerapaMain.Name = "JumlahMain"
	BerapaMain.Parent = FolderStatus
	local DataHistory = Instance.new("Folder")
	DataHistory.Name = "History"
	DataHistory.Parent = FolderStatus
	local BerapaKaliDraw = Instance.new("NumberValue")
	BerapaKaliDraw.Name = "BerapaKaliDraw"
	BerapaKaliDraw.Value = 1
	BerapaKaliDraw.Parent = pemain
	local success, err = pcall(function()
		local HasilDataSettingan = DDS_Settings:GetAsync(tostring(pemain.UserId) .. "-settingan")
		if HasilDataSettingan ~= nil then
			local DataWarna = http:JSONDecode(HasilDataSettingan)
			WarnaBoard1.Value = DataWarna.WarnaBoard1
			WarnaBoard2.Value = DataWarna.WarnaBoard2
		end
		local HasilUang = DDS_Uang:GetAsync(tostring(pemain.UserId) .. "-uang")
		if HasilUang ~= nil then
			local _condition = tonumber(HasilUang)
			if not (_condition ~= 0 and (_condition == _condition and _condition)) then
				_condition = 0
			end
			BerapaUang.Value = _condition
		end
		local HasilDataPoint = DDS_Rating:GetAsync(tostring(pemain.UserId) .. "-rating")
		if HasilDataPoint ~= nil then
			BerapaPoint.Value = HasilDataPoint.point
			BerapaRatingDeviation.Value = HasilDataPoint.ratingDeviation
			BerapaVolatility.Value = HasilDataPoint.volatility
		end
		local HasilDataBarang = DDS_Barang:GetAsync(tostring(pemain.UserId) .. "-barang")
		if HasilDataBarang ~= nil then
			Kematian.Value = HasilDataBarang.kematian
			SkinPiece.Value = HasilDataBarang.skin
			Kursi.Value = HasilDataBarang.kursi
			local _barangKematian = HasilDataBarang.BarangKematian
			local _arg0 = function(v)
				local DataKematian = Instance.new("StringValue")
				DataKematian.Name = v
				DataKematian.Value = v
				DataKematian.Parent = BarangKematian
			end
			for _k, _v in _barangKematian do
				_arg0(_v, _k - 1, _barangKematian)
			end
			local _barangSkinPiece = HasilDataBarang.BarangSkinPiece
			local _arg0_1 = function(v)
				local DataSkinPiece = Instance.new("StringValue")
				DataSkinPiece.Name = v
				DataSkinPiece.Value = v
				DataSkinPiece.Parent = BarangSkinPiece
			end
			for _k, _v in _barangSkinPiece do
				_arg0_1(_v, _k - 1, _barangSkinPiece)
			end
			local _barangSkinPiece_1 = HasilDataBarang.BarangSkinPiece
			local _arg0_2 = function(v)
				local DataKursi = Instance.new("StringValue")
				DataKursi.Name = v
				DataKursi.Value = v
				DataKursi.Parent = BarangKursi
			end
			for _k, _v in _barangSkinPiece_1 do
				_arg0_2(_v, _k - 1, _barangSkinPiece_1)
			end
		end
		local HasilDataStatus = DDS_Status:GetAsync(tostring(pemain.UserId))
		if HasilDataStatus ~= nil then
			BerapaMenang.Value = HasilDataStatus.Menang
			BerapaKalah.Value = HasilDataStatus.Kalah
			BerapaMain.Value = HasilDataStatus.JumlahMain
		end
		local HasilHistory = DDS_History:GetAsync(tostring(pemain.UserId))
		if HasilHistory then
			local _arg0 = function(v, i)
				local FolderMatch = Instance.new("Folder")
				FolderMatch.Name = "Match " .. tostring(i + 1)
				FolderMatch.Parent = DataHistory
				local FolderPemain1 = Instance.new("Folder")
				FolderPemain1.Name = "Pemain1"
				FolderPemain1.Parent = FolderMatch
				local Nama1 = Instance.new("StringValue")
				Nama1.Name = "nama"
				Nama1.Value = v.Pemain1.nama
				Nama1.Parent = FolderPemain1
				local Warna1 = Instance.new("StringValue")
				Warna1.Name = "warna"
				Warna1.Value = v.Pemain1.warna
				Warna1.Parent = FolderPemain1
				local Point1 = Instance.new("NumberValue")
				Point1.Name = "point"
				Point1.Value = v.Pemain1.point
				Point1.Parent = FolderPemain1
				local FolderPemain2 = Instance.new("Folder")
				FolderPemain2.Name = "Pemain2"
				FolderPemain2.Parent = FolderMatch
				local Nama2 = Instance.new("StringValue")
				Nama2.Name = "nama"
				Nama2.Value = v.Pemain2.nama
				Nama2.Parent = FolderPemain2
				local Warna2 = Instance.new("StringValue")
				Warna2.Name = "warna"
				Warna2.Value = v.Pemain2.warna
				Warna2.Parent = FolderPemain2
				local Point2 = Instance.new("NumberValue")
				Point2.Name = "point"
				Point2.Value = v.Pemain2.point
				Point2.Parent = FolderPemain2
				local YangMenang = Instance.new("StringValue")
				YangMenang.Name = "YangMenang"
				YangMenang.Value = v.YangMenang or ""
				YangMenang.Parent = FolderMatch
				local Alasan = Instance.new("StringValue")
				Alasan.Name = "Alasan"
				Alasan.Value = v.Alasan or ""
				Alasan.Parent = FolderMatch
				local Tanggal = Instance.new("StringValue")
				Tanggal.Name = "Tanggal"
				Tanggal.Value = v.Tanggal
				Tanggal.Parent = FolderMatch
				local Gerakan = Instance.new("StringValue")
				Gerakan.Name = "Gerakan"
				Gerakan.Value = v.Gerakan
				Gerakan.Parent = FolderMatch
			end
			for _k, _v in HasilHistory do
				_arg0(_v, _k - 1, HasilHistory)
			end
		end
	end)
	if err ~= 0 and (err == err and (err ~= "" and err)) then
		print("Ada error")
		warn(err)
	end
	if game:GetService("RunService"):IsStudio() then
		if pemain.Name == "Player1" then
			BerapaPoint.Value = 1053
			BerapaRatingDeviation.Value = 99.95
			Kursi.Value = "kursi_kerja"
		end
		if pemain.Name == "Player2" then
			BerapaPoint.Value = 1012
			BerapaRatingDeviation.Value = 99.63
			Kursi.Value = "kursi_plastik"
		end
	end
	local _pemain = pemain
	table.insert(Pemain, _pemain)
end)
Players.PlayerRemoving:Connect(function(pemain)
	if CaturGame ~= nil then
		-- if(InfoValue.SudahDimulai.Value) {
		-- DDS_Match.SetAsync(tostring(pemain.UserId), game.PrivateServerId);
		-- }
		local WarnaPemain = CaturGame:DapatinWarnaDariPlayer(pemain)
		local DataPemain = CaturGame:DapatinPemainDariWarna(WarnaPemain)
		local _result = CaturGame.RatingPemain1
		if _result ~= nil then
			_result = _result.warna
		end
		local RatingPemain = if _result == WarnaPemain then CaturGame.RatingPemain1 else CaturGame.RatingPemain2
		local _binding = CaturGame:ApakahGameSelesai()
		local ApakahSelesai = _binding[1]
		local StatusSelesai = _binding[2]
		local SiapaPemenang = _binding[3]
		if ApakahSelesai then
			if StatusSelesai ~= "draw" and SiapaPemenang == "w" or SiapaPemenang == "b" then
				if SiapaPemenang == WarnaPemain then
					pemain.DataPemain.DataPoint.Point.Value = RatingPemain.Menang.rating
					pemain.DataPemain.DataPoint.RatingDeviation.Value = RatingPemain.Menang.rd
					pemain.DataPemain.DataPoint.Volatility.Value = RatingPemain.Menang.vol
					pemain.DataPemain.DataStatus.Menang.Value = RatingPemain.JumlahMenang
					DDS_Menang_Ordered:SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.Menang.Value)
				else
					if RatingPemain.Kalah.rating > 200 then
						pemain.DataPemain.DataPoint.Point.Value = RatingPemain.Kalah.rating
					else
						pemain.DataPemain.DataPoint.Point.Value = 200
					end
					pemain.DataPemain.DataPoint.RatingDeviation.Value = RatingPemain.Kalah.rd
					pemain.DataPemain.DataPoint.Volatility.Value = RatingPemain.Kalah.vol
					pemain.DataPemain.DataStatus.Kalah.Value = RatingPemain.JumlahKalah
					DDS_Kalah_Ordered:SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.Kalah.Value)
				end
				DDS_Point_Ordered:SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataPoint.Point.Value)
			end
			if SiapaPemenang ~= "Game Ended" then
				pemain.DataPemain.DataStatus.JumlahMain.Value = RatingPemain.JumlahMain
				pemain.DataPemain.Uang.Value = DataPemain.uang
				DDS_JumlahMain_Ordered:SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.JumlahMain.Value)
				pcall(function()
					local PemainPutih = CaturGame:DapatinPemainDariWarna("w")
					local PemainHitam = CaturGame:DapatinPemainDariWarna("b")
					local HistoryData = DDS_History:GetAsync(tostring(pemain.UserId)) or {}
					local _arg0 = {
						Pemain1 = {
							warna = "w",
							point = PemainPutih.Pemain.DataPemain.DataPoint.Point.Value,
							nama = PemainPutih.Pemain.Name,
						},
						Pemain2 = {
							warna = "b",
							point = PemainHitam.Pemain.DataPemain.DataPoint.Point.Value,
							nama = PemainHitam.Pemain.Name,
						},
						YangMenang = if StatusSelesai == "draw" then "seri" else SiapaPemenang,
						Alasan = if StatusSelesai == "draw" then SiapaPemenang else StatusSelesai,
						Tanggal = os.date("%d/%m/%y %X"),
						Gerakan = CaturGame:DapatinPGN(),
					}
					table.insert(HistoryData, _arg0)
					DDS_History:SetAsync(tostring(pemain.UserId), HistoryData)
					-- DDS_Match.SetAsync(tostring(pemain.UserId), '');
				end)
			end
			DDS_Status:SetAsync(tostring(pemain.UserId), {
				Menang = pemain.DataPemain.DataStatus.Menang.Value,
				Kalah = pemain.DataPemain.DataStatus.Kalah.Value,
				JumlahMain = pemain.DataPemain.DataStatus.JumlahMain.Value,
			})
		else
			if CaturGame.mode == "player" then
				if CaturGame.p1.SudahGerak and CaturGame.p2.SudahGerak then
					local WarnaPemain = CaturGame:DapatinWarnaDariPlayer(pemain)
					CaturGame:KeluarDariGame(WarnaPemain)
					if RatingPemain.Kalah.rating > 200 then
						pemain.DataPemain.DataPoint.Point.Value = RatingPemain.Kalah.rating
					else
						pemain.DataPemain.DataPoint.Point.Value = 200
					end
					pemain.DataPemain.DataPoint.RatingDeviation.Value = RatingPemain.Kalah.rd
					pemain.DataPemain.DataPoint.Volatility.Value = RatingPemain.Kalah.vol
					pemain.DataPemain.DataStatus.Kalah.Value = RatingPemain.JumlahKalah
					pemain.DataPemain.DataStatus.JumlahMain.Value = RatingPemain.JumlahMain
					pcall(function()
						local PemainPutih = CaturGame:DapatinPemainDariWarna("w")
						local PemainHitam = CaturGame:DapatinPemainDariWarna("b")
						DDS_Kalah_Ordered:SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.Kalah.Value)
						DDS_Point_Ordered:SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataPoint.Point.Value)
						DDS_JumlahMain_Ordered:SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.JumlahMain.Value)
						local HistoryData = DDS_History:GetAsync(tostring(pemain.UserId)) or {}
						local _arg0 = {
							Pemain1 = {
								warna = "w",
								point = PemainPutih.Pemain.DataPemain.DataPoint.Point.Value,
								nama = PemainPutih.Pemain.Name,
							},
							Pemain2 = {
								warna = "b",
								point = PemainHitam.Pemain.DataPemain.DataPoint.Point.Value,
								nama = PemainHitam.Pemain.Name,
							},
							YangMenang = if StatusSelesai == "draw" then "seri" else SiapaPemenang,
							Alasan = if StatusSelesai == "draw" then SiapaPemenang else StatusSelesai,
							Tanggal = os.date("%d/%m/%y %X"),
							Gerakan = CaturGame:DapatinPGN(),
						}
						table.insert(HistoryData, _arg0)
						DDS_History:SetAsync(tostring(pemain.UserId), HistoryData)
						-- DDS_Match.SetAsync(tostring(pemain.UserId), '');
					end)
					Event.KirimCaturPemenang:FireClient(CaturGame.p1.Pemain, if WarnaPemain == "w" then "b" else "w")
					Event.KirimCaturPemenang:FireClient(CaturGame.p2.Pemain, if WarnaPemain == "w" then "b" else "w")
				else
					CaturGame:SetAlasanSeri("Game Ended")
					Event.KirimCaturPemenang:FireClient(CaturGame.p1.Pemain, "seri")
					Event.KirimCaturPemenang:FireClient(CaturGame.p2.Pemain, "seri")
				end
				print("Selesai gamenya")
				SelesaiGameDanKematian()
			end
		end
	end
	-- Kalau player left dalam mid game maka kurangin pointnya atau reconnect game
	DDS_Uang:SetAsync(tostring(pemain.UserId) .. "-uang", pemain.DataPemain.Uang.Value)
	DDS_Rating:SetAsync(tostring(pemain.UserId) .. "-rating", {
		point = pemain.DataPemain.DataPoint.Point.Value,
		ratingDeviation = pemain.DataPemain.DataPoint.RatingDeviation.Value,
		volatility = pemain.DataPemain.DataPoint.Volatility.Value,
	})
end)
local TempatMap = { "StasiunAngkasa", "Laut" }
while true do
	task.wait(1)
	if not InfoValue.SudahDimulai.Value then
		if #Pemain >= 2 then
			local randomWarna = { "w", "b" }
			do
				local i = #randomWarna - 1
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i -= 1
					else
						_shouldIncrement = true
					end
					if not (i > 0) then
						break
					end
					local j = math.floor(math.random() * (i + 1))
					local _index = i + 1
					local _index_1 = j + 1
					randomWarna[_index], randomWarna[_index_1] = randomWarna[j + 1], randomWarna[i + 1]
				end
			end
			local MapDipilih = TempatMap[math.random(0, #TempatMap - 1) + 1]
			local Map = ReplicatedStorage.Tempat[MapDipilih]:Clone()
			Map.Parent = Workspace
			local Pemain1 = Players:GetPlayers()[1]
			local Pemain2 = Players:GetPlayers()[2]
			local KarakterPemain1 = Pemain1.Character or (Pemain1.CharacterAdded:Wait())
			local KarakterPemain2 = Pemain2.Character or (Pemain2.CharacterAdded:Wait())
			local HumanoidPemain1 = (KarakterPemain1:WaitForChild("Humanoid"))
			local HumanoidPemain2 = (KarakterPemain2:WaitForChild("Humanoid"))
			wait(.5)
			HumanoidPemain1:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			HumanoidPemain2:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			HumanoidPemain1.JumpPower = 0
			HumanoidPemain2.JumpPower = 0
			HumanoidPemain1.WalkSpeed = 0
			HumanoidPemain2.WalkSpeed = 0
			local KursiPemain1 = ReplicatedStorage.kursi[Pemain1.DataPemain.DataBarang.kursi.Value]:Clone()
			KursiPemain1.Name = "kursi1"
			KursiPemain1.Parent = Workspace.Tempat.meja_kursi.chairs
			KursiPemain1.utama.CFrame = Workspace.Tempat.meja_kursi.chairs.Posisi1.CFrame
			local KursiPemain2 = ReplicatedStorage.kursi[Pemain2.DataPemain.DataBarang.kursi.Value]:Clone()
			KursiPemain2.Name = "kursi2"
			KursiPemain2.Parent = Workspace.Tempat.meja_kursi.chairs
			KursiPemain2.utama.CFrame = Workspace.Tempat.meja_kursi.chairs.Posisi2.CFrame
			task.wait(1)
			KursiPemain1.Seat:Sit(HumanoidPemain1)
			KursiPemain2.Seat:Sit(HumanoidPemain2)
			KursiPemain1.Name = KarakterPemain1.Name
			KursiPemain2.Name = KarakterPemain2.Name
			HumanoidPemain1.Animator:LoadAnimation(KarakterPemain1.Animate.sit.SitAnim)
			HumanoidPemain2.Animator:LoadAnimation(KarakterPemain2.Animate.sit.SitAnim)
			task.wait(3)
			-- rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
			-- 7k/8/8/8/8/8/2P5/5K2 w - - 0 1
			-- 8/2p5/3p4/KP5r/1R3p1k/8/4P1P/8 w - - 0 1
			CaturGame = Chess.new({
				Pemain = Players:GetPlayers()[1],
				warna = randomWarna[1],
			}, "player", {
				Pemain = Players:GetPlayers()[2],
				warna = randomWarna[2],
			}, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", true)
			CaturGame:header("White", CaturGame:DapatinPemainDariWarna("w").Pemain.Name)
			CaturGame:header("Black", CaturGame:DapatinPemainDariWarna("b").Pemain.Name)
			CaturGame:header("Date", os.date("%x %X"))
			InfoValue.SudahDimulai.Value = true
			Map.TempatScript.Enabled = true
			Event.KirimPemulaianCaturUIKePemain:FireClient(CaturGame.p1.Pemain, CaturGame.RatingPemain1)
			Event.KirimPemulaianCaturUIKePemain:FireClient(CaturGame.p2.Pemain, CaturGame.RatingPemain2)
			coroutine.wrap(function()
				wait(5)
				while not CaturGame:isGameOver() and (CaturGame.PerluWaktu and CaturGame.mode == "player") do
					local PemainCatur = CaturGame:DapatinPemainDariWarna(CaturGame:turn())
					local _binding = CaturGame:ApakahGameSelesai()
					local SudahSelesai = _binding[1]
					local Status = _binding[2]
					local SiapaPemenang = _binding[3]
					if SudahSelesai then
						break
					end
					if PemainCatur.SudahGerak then
						PemainCatur.waktu -= .1
						-- PemainCatur.waktu--;
						Event.KirimWaktuCaturKePemain:FireClient(CaturGame.p1.Pemain, CaturGame.p1.waktu, CaturGame.p2)
						Event.KirimWaktuCaturKePemain:FireClient(CaturGame.p2.Pemain, CaturGame.p2.waktu, CaturGame.p1)
						if PemainCatur.waktu <= 0 then
							-- Kasi menang disini 25/12/2022 23:06
							local _binding_1 = CaturGame:ApakahGameSelesai()
							local apakahSelesai = _binding_1[1]
							local StatusSelesai = _binding_1[2]
							local SiapaPemenang = _binding_1[3]
							if apakahSelesai and StatusSelesai == "waktuhabis" then
								Event.KirimCaturPemenang:FireClient(CaturGame.p1.Pemain, SiapaPemenang)
								Event.KirimCaturPemenang:FireClient(CaturGame.p2.Pemain, SiapaPemenang)
								SelesaiGameDanKematian()
							end
							break
						end
					else
						if PemainCatur.WaktuAFK >= 60 then
							Event.KirimCaturPemenang:FireClient(CaturGame.p1.Pemain, "seri")
							Event.KirimCaturPemenang:FireClient(CaturGame.p2.Pemain, "seri")
							CaturGame:SetAlasanSeri("Game Ended")
							SelesaiGameDanKematian()
							break
						end
						PemainCatur.WaktuAFK += .1
						-- PemainCatur.WaktuAFK++;
					end
					task.wait(.1)
				end
			end)()
			break
		end
	else
		break
	end
end
