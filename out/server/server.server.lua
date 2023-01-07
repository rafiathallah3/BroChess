-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local Chess = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "chess").Chess
local http = game:GetService("HttpService")
local DDS = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
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
local Event = ReplicatedStorage.remote
local InfoValue = ReplicatedStorage.InfoValue
local CaturGame
Event.Mulai.OnServerEvent:Connect(function(p, mode)
	if not InfoValue.SudahDimulai.Value then
		-- rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
		-- 7k/8/8/8/8/8/2P5/5K2 w - - 0 1
		-- 8/2p5/3p4/KP5r/1R3p1k/8/4P1P/8 w - - 0 1
		CaturGame = Chess.new({
			Pemain = p,
			warna = "w",
		}, mode, nil, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
		InfoValue.SudahDimulai.Value = true
	end
end)
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
	local _tujuanPosisi = tujuanPosisi
	if table.find(GerakanPosisi, _tujuanPosisi) ~= nil then
		local SebelumDuluan = CaturGame:turn()
		CaturGame:move({
			from = awalPosisi,
			to = tujuanPosisi,
			promotion = promosi,
		})
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
				local _result = DataGerakanCatur[_from_1]
				if _result ~= nil then
					local _element = element
					table.insert(_result, _element)
				end
			end
		end
		for _k, _v in DataCaturRaw do
			_arg0_2(_v, _k - 1, DataCaturRaw)
		end
		local DataPengiriman = { {
			awalPosisi = awalPosisi,
			tujuanPosisi = tujuanPosisi,
		}, BoardNew, DataGerakanCatur, CaturGame:turn(), {
			warna = CaturGame:turn(),
			check = CaturGame:isCheck(),
		}, {
			warna = SebelumDuluan,
			skak = CaturGame:isCheckmate(),
		}, (CaturGame:isStalemate() or (CaturGame:isDraw() or (CaturGame:isThreefoldRepetition() or CaturGame:isInsufficientMaterial()))) }
		Event.KirimSemuaGerakan:FireClient(p, unpack(DataPengiriman))
		if CaturGame.mode == "player" and CaturGame.p2 ~= nil then
			Event.KirimSemuaGerakan:FireClient(CaturGame.p2.Pemain, unpack(DataPengiriman))
		end
	end
	if CaturGame.mode == "komputer" and CaturGame:turn() == CaturGame.WarnaKomputer then
		local _pergerakanBagus = CaturGame.AICatur
		if _pergerakanBagus ~= nil then
			_pergerakanBagus = _pergerakanBagus:minimaxRoot(2, CaturGame, true)
		end
		local pergerakanBagus = _pergerakanBagus
		local pergerakan = CaturGame:move(pergerakanBagus)
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
				local _result = DataGerakanCatur[_from_1]
				if _result ~= nil then
					local _element = element
					table.insert(_result, _element)
				end
			end
		end
		for _k, _v in DataCaturRaw do
			_arg0_2(_v, _k - 1, DataCaturRaw)
		end
		local _object = {}
		local _left = "awalPosisi"
		local _result = pergerakan
		if _result ~= nil then
			_result = _result.from
		end
		_object[_left] = _result
		local _left_1 = "tujuanPosisi"
		local _result_1 = pergerakan
		if _result_1 ~= nil then
			_result_1 = _result_1.to
		end
		_object[_left_1] = _result_1
		local DataPengiriman = { _object, BoardNew, DataGerakanCatur, CaturGame:turn(), {
			warna = CaturGame:turn(),
			check = CaturGame:isCheck(),
		}, {
			warna = CaturGame:turn(),
			skak = CaturGame:isCheckmate(),
		}, (CaturGame:isStalemate() or (CaturGame:isDraw() or (CaturGame:isThreefoldRepetition() or CaturGame:isInsufficientMaterial()))) }
		Event.KirimSemuaGerakan:FireClient(p, unpack(DataPengiriman))
	end
end)
Event.TambahinUndangan.OnServerEvent:Connect(function(pemain, indikasi, yangDiInvite)
	if indikasi == "kirim invite" then
		if not pemain:FindFirstChild(yangDiInvite.Name) then
			local UndanganValue = Instance.new("StringValue")
			UndanganValue.Name = yangDiInvite.Name
			UndanganValue.Parent = pemain
			Event.TambahinUndangan:FireClient(yangDiInvite, "kirim invite", pemain)
			-- Event.KirimTerimaTolakUndanganUI.FireClient(yangDiInvite, pemain);
		end
	elseif indikasi == "terima invite" then
		if yangDiInvite:FindFirstChild(pemain.Name) then
			Event.TambahinUndangan:FireClient(pemain, "terima invite")
			Event.TambahinUndangan:FireClient(yangDiInvite, "terima invite")
			-- Event.KirimUndanganTutupUIKePemain.FireClient(yangDiInvite);
			-- Event.KirimUndanganTutupUIKePemain.FireClient(pemain);
			local Kode = TeleportService:ReserveServer(11878754615)
			-- pcall(() => {
			-- DDS_Match.SetAsync(tostring(YangInvite.UserId), Kode);
			-- DDS_Match.SetAsync(tostring(SiapaInvite.UserId), Kode);
			-- });
			TeleportService:TeleportToPrivateServer(11878754615, Kode, { yangDiInvite, pemain })
		end
	elseif indikasi == "tolak invite" then
		if yangDiInvite:FindFirstChild(pemain.Name) then
			local _result = yangDiInvite:FindFirstChild(pemain.Name)
			if _result ~= nil then
				_result:Destroy()
			end
		end
		Event.TambahinUndangan:FireClient(yangDiInvite, "tolak invite", pemain)
	end
end)
Event.KirimDataWarnaBoard.OnServerEvent:Connect(function(pemain, PilihWarna, warna)
	if PilihWarna == "hitam" then
		pemain.DataPemain.DataSettings.WarnaBoard1.Value = warna:ToHex()
	else
		pemain.DataPemain.DataSettings.WarnaBoard2.Value = warna:ToHex()
	end
end)
Event.TeleportBalikKeGame.OnServerEvent:Connect(function(pemain, Kode)
	TeleportService:TeleportToPrivateServer(11878754615, Kode, { pemain })
end)
Event.TeleportUndanganKeGame.OnServerEvent:Connect(function(_, YangInvite, SiapaInvite)
	if SiapaInvite:FindFirstChild(YangInvite.Name) then
		Event.KirimUndanganTutupUIKePemain:FireClient(YangInvite)
		Event.KirimUndanganTutupUIKePemain:FireClient(SiapaInvite)
		local Kode = TeleportService:ReserveServer(11878754615)
		-- pcall(() => {
		-- DDS_Match.SetAsync(tostring(YangInvite.UserId), Kode);
		-- DDS_Match.SetAsync(tostring(SiapaInvite.UserId), Kode);
		-- });
		TeleportService:TeleportToPrivateServer(11878754615, Kode, { YangInvite, SiapaInvite })
	end
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
	local SkinPiece = Instance.new("StringValue")
	SkinPiece.Name = "skinpiece"
	SkinPiece.Parent = FolderBarang
	local Kematian = Instance.new("StringValue")
	Kematian.Name = "kematian"
	Kematian.Parent = FolderBarang
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
	local Data = {
		DataSettings = {
			WarnaBoard1 = Color3.fromRGB(170, 216, 124):ToHex(),
			WarnaBoard2 = Color3.fromRGB(255, 255, 255):ToHex(),
		},
		DataBarang = {
			kematian = "meledak",
			skin = "normal",
			BarangKematian = {},
			BarangSkinPiece = {},
		},
		DataRating = {
			Point = BerapaPoint.Value,
			RatingDeviation = BerapaRatingDeviation.Value,
			Volatility = BerapaVolatility.Value,
		},
		Uang = BerapaUang.Value,
	}
	local success, err = pcall(function()
		local HasilDataSettingan = DDS_Settings:GetAsync(tostring(pemain.UserId) .. "-settingan")
		if HasilDataSettingan ~= nil then
			Data.DataSettings = http:JSONDecode(HasilDataSettingan)
		end
		local HasilUang = DDS_Uang:GetAsync(tostring(pemain.UserId) .. "-uang")
		if HasilUang ~= nil then
			Data.Uang = tonumber(HasilUang)
		end
		local HasilDataPoint = DDS_Rating:GetAsync(tostring(pemain.UserId) .. "-rating")
		if HasilDataPoint ~= nil then
			Data.DataRating.Point = HasilDataPoint.point
			Data.DataRating.RatingDeviation = HasilDataPoint.ratingDeviation
			Data.DataRating.Volatility = HasilDataPoint.volatility
		end
		local HasilDataBarang = DDS_Barang:GetAsync(tostring(pemain.UserId) .. "-barang")
		if HasilDataBarang ~= nil then
			Data.DataBarang.kematian = HasilDataBarang.kematian
			Data.DataBarang.skin = HasilDataBarang.skin
			Data.DataBarang.BarangKematian = HasilDataBarang.BarangKematian
			Data.DataBarang.BarangSkinPiece = HasilDataBarang.BarangSkinPiece
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
				YangMenang.Value = v.YangMenang
				YangMenang.Parent = FolderMatch
				local Alasan = Instance.new("StringValue")
				Alasan.Name = "Alasan"
				Alasan.Value = v.Alasan
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
	pcall(function()
		local DataPoint = DDS_Point_Ordered:GetSortedAsync(false, 50)
		local PointPage = DataPoint:GetCurrentPage()
		local DataMenang = DDS_Menang_Ordered:GetSortedAsync(false, 50)
		local MenangPage = DataMenang:GetCurrentPage()
		local DataKalah = DDS_Kalah_Ordered:GetSortedAsync(false, 50)
		local KalahPage = DataKalah:GetCurrentPage()
		local DataJumlahMain = DDS_JumlahMain_Ordered:GetSortedAsync(false, 50)
		local JumlahMainPage = DataJumlahMain:GetCurrentPage()
		Event.UpdateLeaderboard:FireClient(pemain, {
			Point = PointPage,
			Menang = MenangPage,
			Kalah = KalahPage,
			JumlahMain = JumlahMainPage,
		})
	end)
	if success then
		WarnaBoard1.Value = Data.DataSettings.WarnaBoard1
		WarnaBoard2.Value = Data.DataSettings.WarnaBoard2
		BerapaUang.Value = Data.Uang
		Kematian.Value = Data.DataBarang.kematian
		SkinPiece.Value = Data.DataBarang.skin
		local _barangKematian = Data.DataBarang.BarangKematian
		local _arg0 = function(v)
			local Barang = Instance.new("StringValue")
			Barang.Name = v
			Barang.Parent = BarangKematian
		end
		for _k, _v in _barangKematian do
			_arg0(_v, _k - 1, _barangKematian)
		end
		local _barangSkinPiece = Data.DataBarang.BarangSkinPiece
		local _arg0_1 = function(v)
			local Barang = Instance.new("StringValue")
			Barang.Name = v
			Barang.Parent = BarangSkinPiece
		end
		for _k, _v in _barangSkinPiece do
			_arg0_1(_v, _k - 1, _barangSkinPiece)
		end
		BerapaPoint.Value = Data.DataRating.Point
		BerapaRatingDeviation.Value = Data.DataRating.RatingDeviation
		BerapaVolatility.Value = Data.DataRating.Volatility
	else
		print("Ada error")
		warn(err)
	end
end)
Players.PlayerRemoving:Connect(function(pemain)
	DDS_Settings:SetAsync(tostring(pemain.UserId) .. "-settingan", http:JSONEncode({
		WarnaBoard1 = pemain.DataPemain.DataSettings.WarnaBoard1.Value,
		WarnaBoard2 = pemain.DataPemain.DataSettings.WarnaBoard2.Value,
	}))
end)
wait(5)
while true do
	pcall(function()
		local DataPoint = DDS_Point_Ordered:GetSortedAsync(false, 50)
		local PointPage = DataPoint:GetCurrentPage()
		local DataMenang = DDS_Menang_Ordered:GetSortedAsync(false, 50)
		local MenangPage = DataMenang:GetCurrentPage()
		local DataKalah = DDS_Kalah_Ordered:GetSortedAsync(false, 50)
		local KalahPage = DataKalah:GetCurrentPage()
		local DataJumlahMain = DDS_JumlahMain_Ordered:GetSortedAsync(false, 50)
		local JumlahMainPage = DataJumlahMain:GetCurrentPage()
		Event.UpdateLeaderboard:FireAllClients({
			Point = PointPage,
			Menang = MenangPage,
			Kalah = KalahPage,
			JumlahMain = JumlahMainPage,
		})
	end)
	task.wait(120)
end
