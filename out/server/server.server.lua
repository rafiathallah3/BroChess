-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local Chess = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "chess").Chess
local _ListKematian = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "ListKematian")
local Kematian = _ListKematian.default
local Kursi = _ListKematian.Kursi
local SemuaKematian = _ListKematian.SemuaKematian
local SemuaKursi = _ListKematian.SemuaKursi
local DDS = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
local memoryStore = game:GetService("MemoryStoreService")
local queue = memoryStore:GetSortedMap("Queue")
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
local BarangItem = {}
local CaturGame
do
	local i = 0
	local _shouldIncrement = false
	while true do
		if _shouldIncrement then
			i += 1
		else
			_shouldIncrement = true
		end
		if not (i < 3) then
			break
		end
		while true do
			local RandomKematian = SemuaKematian[math.random(0, #SemuaKematian - 1) + 1]
			local _arg0 = function(v)
				return RandomKematian == v
			end
			-- ▼ ReadonlyArray.find ▼
			local _result
			for _i, _v in BarangItem do
				if _arg0(_v, _i - 1, BarangItem) == true then
					_result = _v
					break
				end
			end
			-- ▲ ReadonlyArray.find ▲
			if _result ~= "" and _result then
				continue
			else
				table.insert(BarangItem, RandomKematian)
				break
			end
		end
	end
end
do
	local i = 0
	local _shouldIncrement = false
	while true do
		if _shouldIncrement then
			i += 1
		else
			_shouldIncrement = true
		end
		if not (i < 2) then
			break
		end
		while true do
			local RandomBarnag = SemuaKursi[math.random(0, #SemuaKursi - 1) + 1]
			local _arg0 = function(v)
				return RandomBarnag == v
			end
			-- ▼ ReadonlyArray.find ▼
			local _result
			for _i, _v in BarangItem do
				if _arg0(_v, _i - 1, BarangItem) == true then
					_result = _v
					break
				end
			end
			-- ▲ ReadonlyArray.find ▲
			if _result ~= "" and _result then
				continue
			else
				table.insert(BarangItem, RandomBarnag)
				break
			end
		end
	end
end
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
Event.BeliBarang.OnServerInvoke = function(pemain, BarangDiBeli)
	local _arg0 = function(v)
		return v == BarangDiBeli
	end
	-- ▼ ReadonlyArray.find ▼
	local _result
	for _i, _v in BarangItem do
		if _arg0(_v, _i - 1, BarangItem) == true then
			_result = _v
			break
		end
	end
	-- ▲ ReadonlyArray.find ▲
	if _result ~= "" and _result then
		local _arg0_1 = function(v)
			return v == BarangDiBeli
		end
		-- ▼ ReadonlyArray.find ▼
		local _result_1
		for _i, _v in SemuaKematian do
			if _arg0_1(_v, _i - 1, SemuaKematian) == true then
				_result_1 = _v
				break
			end
		end
		-- ▲ ReadonlyArray.find ▲
		if _result_1 ~= "" and _result_1 then
			local DataKematian = Kematian[BarangDiBeli]
			if DataKematian.Harga <= pemain.DataPemain.Uang.Value and not pemain.DataPemain.DataBarang.BarangKematian:FindFirstChild(BarangDiBeli) then
				local BarangKematian = Instance.new("StringValue")
				BarangKematian.Name = BarangDiBeli
				BarangKematian.Value = BarangDiBeli
				BarangKematian.Parent = pemain.DataPemain.DataBarang.BarangKematian
				pemain.DataPemain.Uang.Value -= DataKematian.Harga
				return "Sudah Beli"
			end
			return "Tidak cukup"
		end
		local _arg0_2 = function(v)
			return v == BarangDiBeli
		end
		-- ▼ ReadonlyArray.find ▼
		local _result_2
		for _i, _v in SemuaKursi do
			if _arg0_2(_v, _i - 1, SemuaKursi) == true then
				_result_2 = _v
				break
			end
		end
		-- ▲ ReadonlyArray.find ▲
		if _result_2 ~= "" and _result_2 then
			local DataKursi = Kursi[BarangDiBeli]
			if DataKursi.Harga <= pemain.DataPemain.Uang.Value and not pemain.DataPemain.DataBarang.BarangKursi:FindFirstChild(BarangDiBeli) then
				local BarangKursi = Instance.new("StringValue")
				BarangKursi.Name = BarangDiBeli
				BarangKursi.Value = BarangDiBeli
				BarangKursi.Parent = pemain.DataPemain.DataBarang.BarangKursi
				pemain.DataPemain.Uang.Value -= DataKursi.Harga
				return "Sudah Beli"
			end
			return "Tidak cukup"
		end
		return "Tidak ada"
	end
end
Event.PakeBarang.OnServerEvent:Connect(function(pemain, NamaBarang, tipe)
	if tipe == "Kursi" and (pemain.DataPemain.DataBarang.BarangKursi:FindFirstChild(NamaBarang) and Kursi[NamaBarang] ~= nil) then
		pemain.DataPemain.DataBarang.kursi.Value = NamaBarang
	end
	if tipe == "Effect" and (pemain.DataPemain.DataBarang.BarangKematian:FindFirstChild(NamaBarang) and Kematian[NamaBarang] ~= nil) then
		pemain.DataPemain.DataBarang.kematian.Value = NamaBarang
	end
end)
Event.KirimDataWarnaBoard.OnServerEvent:Connect(function(pemain, PilihWarna, warna)
	if PilihWarna == "hitam" then
		pemain.DataPemain.DataSettings.WarnaBoard1.Value = warna:ToHex()
	else
		pemain.DataPemain.DataSettings.WarnaBoard2.Value = warna:ToHex()
	end
end)
local cooldown = {}
Event.TambahinQueue.OnServerEvent:Connect(function(pemain, StatusQueue)
	if cooldown[pemain.Name] then
		return nil
	end
	cooldown[pemain.Name] = true
	if StatusQueue == "DALAM QUEUE" then
		pcall(function()
			queue:SetAsync(tostring(pemain.UserId), pemain.UserId, 2592000)
		end)
	elseif StatusQueue == "QUEUE" then
		pcall(function()
			queue:RemoveAsync(tostring(pemain.UserId))
		end)
	end
	task.wait(1)
	cooldown[pemain.Name] = false
end)
Event.TeleportBalikKeGame.OnServerEvent:Connect(function(pemain, Kode)
	TeleportService:TeleportToPrivateServer(11878754615, Kode, { pemain })
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
	local Meledak = Instance.new("StringValue")
	Meledak.Name = "meledak"
	Meledak.Value = "meledak"
	Meledak.Parent = BarangKematian
	local Kursi = Instance.new("StringValue")
	Kursi.Name = "kursi"
	Kursi.Value = "kursi_biasa"
	Kursi.Parent = FolderBarang
	local KursiBiasa = Instance.new("StringValue")
	KursiBiasa.Name = "kursi_biasa"
	KursiBiasa.Value = "kursi_biasa"
	KursiBiasa.Parent = BarangKursi
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
		print(HasilDataSettingan)
		if HasilDataSettingan ~= nil then
			WarnaBoard1.Value = HasilDataSettingan.WarnaBoard1
			WarnaBoard2.Value = HasilDataSettingan.WarnaBoard2
		end
		local HasilUang = DDS_Uang:GetAsync(tostring(pemain.UserId))
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
		local HasilDataBarang = DDS_Barang:GetAsync(tostring(pemain.UserId))
		print(HasilDataBarang)
		if HasilDataBarang ~= nil then
			Kematian.Value = HasilDataBarang.kematian
			SkinPiece.Value = HasilDataBarang.skin
			Kursi.Value = HasilDataBarang.kursi
			local _barangKematian = HasilDataBarang.BarangKematian
			local _arg0 = function(v)
				if not BarangKematian:FindFirstChild(v) then
					local DataKematian = Instance.new("StringValue")
					DataKematian.Name = v
					DataKematian.Value = v
					DataKematian.Parent = BarangKematian
				end
			end
			for _k, _v in _barangKematian do
				_arg0(_v, _k - 1, _barangKematian)
			end
			local _barangSkinPiece = HasilDataBarang.BarangSkinPiece
			local _arg0_1 = function(v)
				if not BarangSkinPiece:FindFirstChild(v) then
					local DataSkinPiece = Instance.new("StringValue")
					DataSkinPiece.Name = v
					DataSkinPiece.Value = v
					DataSkinPiece.Parent = BarangSkinPiece
				end
			end
			for _k, _v in _barangSkinPiece do
				_arg0_1(_v, _k - 1, _barangSkinPiece)
			end
			local _barangKursi = HasilDataBarang.BarangKursi
			local _arg0_2 = function(v)
				if not BarangKursi:FindFirstChild(v) then
					local DataKursi = Instance.new("StringValue")
					DataKursi.Name = v
					DataKursi.Value = v
					DataKursi.Parent = BarangKursi
				end
			end
			for _k, _v in _barangKursi do
				_arg0_2(_v, _k - 1, _barangKursi)
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
	Event.KirimItemShop:FireClient(pemain, BarangItem)
end)
Players.PlayerRemoving:Connect(function(pemain)
	queue:RemoveAsync(tostring(pemain.UserId))
	local succ, err = pcall(function()
		print("What de hell")
		DDS_Settings:SetAsync(tostring(pemain.UserId) .. "-settingan", {
			WarnaBoard1 = pemain.DataPemain.DataSettings.WarnaBoard1.Value,
			WarnaBoard2 = pemain.DataPemain.DataSettings.WarnaBoard2.Value,
		})
		print("roblox")
		DDS_Uang:SetAsync(tostring(pemain.UserId), pemain.DataPemain.Uang.Value)
		print("ooomg")
		local _exp = pemain.DataPemain.DataBarang.BarangKematian:GetChildren()
		local _arg0 = function(v)
			return v.Name
		end
		-- ▼ ReadonlyArray.map ▼
		local _newValue = table.create(#_exp)
		for _k, _v in _exp do
			_newValue[_k] = _arg0(_v, _k - 1, _exp)
		end
		-- ▲ ReadonlyArray.map ▲
		local BarangKematian = _newValue
		local _exp_1 = pemain.DataPemain.DataBarang.BarangKursi:GetChildren()
		local _arg0_1 = function(v)
			return v.Name
		end
		-- ▼ ReadonlyArray.map ▼
		local _newValue_1 = table.create(#_exp_1)
		for _k, _v in _exp_1 do
			_newValue_1[_k] = _arg0_1(_v, _k - 1, _exp_1)
		end
		-- ▲ ReadonlyArray.map ▲
		local BarangKursi = _newValue_1
		print({
			kematian = pemain.DataPemain.DataBarang.kematian.Value,
			skin = pemain.DataPemain.DataBarang.skinpiece.Value,
			kursi = pemain.DataPemain.DataBarang.kursi.Value,
			BarangKematian = BarangKematian,
			BarangSkinPiece = {},
			BarangKursi = BarangKursi,
		})
		DDS_Barang:SetAsync(tostring(pemain.UserId), {
			kematian = pemain.DataPemain.DataBarang.kematian.Value,
			skin = pemain.DataPemain.DataBarang.skinpiece.Value,
			kursi = pemain.DataPemain.DataBarang.kursi.Value,
			BarangKematian = BarangKematian,
			BarangSkinPiece = {},
			BarangKursi = BarangKursi,
		})
	end)
	print(err)
end)
coroutine.wrap(function()
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
end)()
local lastOverMin = tick()
while true do
	task.wait(1)
	local success, queuedPlayers = pcall(function()
		return queue:GetRangeAsync(Enum.SortDirection.Descending, 2)
	end)
	if success then
		local amountQueued = #queuedPlayers
		if amountQueued < 2 then
			lastOverMin = tick()
		end
		local timeOverMin = tick() - lastOverMin
		if timeOverMin >= 20 or amountQueued == 2 then
			print("Ada")
			local ListPemain = {}
			local _arg0 = function(v)
				local pemain = Players:GetPlayerByUserId(tonumber(v.value))
				if pemain then
					table.insert(ListPemain, pemain)
				end
			end
			for _k, _v in queuedPlayers do
				_arg0(_v, _k - 1, queuedPlayers)
			end
			local success, err = pcall(function()
				local Kode = TeleportService:ReserveServer(11878754615)
				TeleportService:TeleportToPrivateServer(11878754615, Kode, ListPemain)
			end)
			print(success)
			spawn(function()
				if success then
					task.wait(1)
					print("WHAT")
					pcall(function()
						local _arg0_1 = function(v)
							if Players:FindFirstChild(v.Name) then
								Event.TambahinUndangan:FireClient(v, "terima invite")
							end
							queue:RemoveAsync(tostring(v.UserId))
						end
						for _k, _v in ListPemain do
							_arg0_1(_v, _k - 1, ListPemain)
						end
						table.clear(ListPemain)
					end)
				end
			end)
		end
	end
end
