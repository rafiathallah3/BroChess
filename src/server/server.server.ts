import { Players, ReplicatedStorage, StarterGui, TweenService } from "@rbxts/services";
import { Chess, Square, Move, PieceSymbol, Color, Posisi, Promosi, TipeMode, AlasanDraw } from '../shared/chess';

const http = game.GetService("HttpService");
const DDS = game.GetService("DataStoreService");
const TeleportService = game.GetService("TeleportService");

const DDS_Settings = DDS.GetDataStore("DDS_Settings");
const DDS_Uang = DDS.GetDataStore("DDS_Uang");
const DDS_Barang = DDS.GetDataStore("DDS_Barang");
const DDS_Rating = DDS.GetDataStore("DDS_Rating");
const DDS_History = DDS.GetDataStore("DDS_History_2");
const DDS_Status = DDS.GetDataStore("DDS_Status");
// const DDS_Match = DDS.GetDataStore("DDS_Match");

const DDS_Point_Ordered = DDS.GetOrderedDataStore("DDS_Point_Ordered");
const DDS_Menang_Ordered = DDS.GetOrderedDataStore("DDS_Menang_Ordered");
const DDS_Kalah_Ordered = DDS.GetOrderedDataStore("DDS_Kalah_Ordered");
const DDS_JumlahMain_Ordered = DDS.GetOrderedDataStore("DDS_JumlahMain_Ordered");

const Event = ReplicatedStorage.remote;
const InfoValue = ReplicatedStorage.InfoValue;
let CaturGame: Chess;

type TipeHistory = {
    Pemain1: { warna: Color, point: number, nama: string },
    Pemain2: { warna: Color, point: number, nama: string },
    YangMenang: Color | "seri",
    Alasan: AlasanDraw | "skakmat" | "waktuhabis" | "menyerah",
    Tanggal: string,
    Gerakan: string,
}

Event.Mulai.OnServerEvent.Connect((p: Player, mode: TipeMode) => {
    if(!InfoValue.SudahDimulai.Value) {
        //rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
        //7k/8/8/8/8/8/2P5/5K2 w - - 0 1
        //8/2p5/3p4/KP5r/1R3p1k/8/4P1P/8 w - - 0 1
        CaturGame = new Chess({ Pemain: p, warna: "w" }, mode, undefined, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

        InfoValue.SudahDimulai.Value = true;
    }
});

Event.GerakanCatur.OnServerEvent.Connect((p: Player, awalPosisi: Square, tujuanPosisi: Square, promosi?: Promosi) => {
    const GerakanPosisi = (CaturGame.moves({ square: awalPosisi, verbose: true, warna: CaturGame.turn() }) as Move[]).map((v) => v.to);
    if(GerakanPosisi.includes(tujuanPosisi)) {
        const SebelumDuluan = CaturGame.turn();

        CaturGame.move({ from: awalPosisi, to: tujuanPosisi, promotion: promosi });

        const BoardNew: Posisi[] = [];
        CaturGame.board().forEach((v) => {
            (v as { square: Square, type: PieceSymbol, color: Color }[]).forEach((j) => {
                BoardNew.push(j);
            })
        });

        const DataCaturRaw = CaturGame.moves({ verbose: true }) as Move[];
        const DataGerakanCatur: Map<Square, Move[]> = new Map<Square, Move[]>();
		DataCaturRaw.forEach((element: Move) => {
			if(DataGerakanCatur.get(element.from) === undefined) {
				DataGerakanCatur.set(element.from, [element]);
			} else {
				DataGerakanCatur.get(element.from)?.push(element);
			}
		});
        
        const DataPengiriman = [
            { awalPosisi, tujuanPosisi },
            BoardNew,
            DataGerakanCatur,
            CaturGame.turn(),
            { warna: CaturGame.turn(), check: CaturGame.isCheck() },
            { warna: SebelumDuluan, skak: CaturGame.isCheckmate() },
            (CaturGame.isStalemate() || CaturGame.isDraw() || CaturGame.isThreefoldRepetition() || CaturGame.isInsufficientMaterial()),
        ]
        Event.KirimSemuaGerakan.FireClient(
            p,
            ...DataPengiriman
        );
        if(CaturGame.mode === "player" && CaturGame.p2 !== undefined) {
            Event.KirimSemuaGerakan.FireClient(
                CaturGame.p2.Pemain,
                ...DataPengiriman
            );
        }
    }

    if(CaturGame.mode === "komputer" && CaturGame.turn() === CaturGame.WarnaKomputer) {
        const pergerakanBagus = CaturGame.AICatur?.minimaxRoot(2, CaturGame, true);
        const pergerakan = CaturGame.move(pergerakanBagus as Square);

        const BoardNew: Posisi[] = [];
        CaturGame.board().forEach((v) => {
            (v as { square: Square, type: PieceSymbol, color: Color }[]).forEach((j) => {
                BoardNew.push(j);
            })
        });

        const DataCaturRaw = CaturGame.moves({ verbose: true }) as Move[];
        const DataGerakanCatur: Map<Square, Move[]> = new Map<Square, Move[]>();
		DataCaturRaw.forEach((element: Move) => {
			if(DataGerakanCatur.get(element.from) === undefined) {
				DataGerakanCatur.set(element.from, [element]);
			} else {
				DataGerakanCatur.get(element.from)?.push(element);
			}
		});
        
        const DataPengiriman = [
            { awalPosisi: pergerakan?.from, tujuanPosisi: pergerakan?.to },
            BoardNew,
            DataGerakanCatur,
            CaturGame.turn(),
            { warna: CaturGame.turn(), check: CaturGame.isCheck() },
            { warna: CaturGame.turn(), skak: CaturGame.isCheckmate() },
            (CaturGame.isStalemate() || CaturGame.isDraw() || CaturGame.isThreefoldRepetition() || CaturGame.isInsufficientMaterial())
        ]
        Event.KirimSemuaGerakan.FireClient(
            p,
            ...DataPengiriman
        );
    }
});

Event.TambahinUndangan.OnServerEvent.Connect((pemain, indikasi: string, yangDiInvite: Player) => {
    if(indikasi === "kirim invite") {
        if(!pemain.FindFirstChild(yangDiInvite.Name)) {
            const UndanganValue = new Instance("StringValue");
            UndanganValue.Name = yangDiInvite.Name;
            UndanganValue.Parent = pemain;
        
            Event.TambahinUndangan.FireClient(yangDiInvite, "kirim invite", pemain);
            // Event.KirimTerimaTolakUndanganUI.FireClient(yangDiInvite, pemain);
        }
    } else if(indikasi === "terima invite") {
        if(yangDiInvite.FindFirstChild(pemain.Name)) {
            Event.TambahinUndangan.FireClient(pemain, "terima invite");
            Event.TambahinUndangan.FireClient(yangDiInvite, "terima invite");
            // Event.KirimUndanganTutupUIKePemain.FireClient(yangDiInvite);
            // Event.KirimUndanganTutupUIKePemain.FireClient(pemain);
            const Kode = TeleportService.ReserveServer(11878754615) as unknown as string;
            // pcall(() => {
            //     DDS_Match.SetAsync(tostring(YangInvite.UserId), Kode);
            //     DDS_Match.SetAsync(tostring(SiapaInvite.UserId), Kode);
            // });
            TeleportService.TeleportToPrivateServer(11878754615, Kode, [yangDiInvite, pemain]);
        }
    } else if(indikasi === "tolak invite") {
        if(yangDiInvite.FindFirstChild(pemain.Name)) {
            yangDiInvite.FindFirstChild(pemain.Name)?.Destroy();
        }
        Event.TambahinUndangan.FireClient(yangDiInvite, "tolak invite", pemain);
    }
});

Event.KirimDataWarnaBoard.OnServerEvent.Connect((pemain, PilihWarna: "hitam" | "putih", warna: Color3) => {
    if(PilihWarna === "hitam")
        pemain.DataPemain.DataSettings.WarnaBoard1.Value = warna.ToHex();
    else
        pemain.DataPemain.DataSettings.WarnaBoard2.Value = warna.ToHex();
});

Event.TeleportBalikKeGame.OnServerEvent.Connect((pemain, Kode: string) => {
    TeleportService.TeleportToPrivateServer(11878754615, Kode, [pemain]);
});

Event.TeleportUndanganKeGame.OnServerEvent.Connect((_: Player, YangInvite: Player, SiapaInvite: Player) => {
    if(SiapaInvite.FindFirstChild(YangInvite.Name)) {
        Event.KirimUndanganTutupUIKePemain.FireClient(YangInvite);
        Event.KirimUndanganTutupUIKePemain.FireClient(SiapaInvite);
        const Kode = TeleportService.ReserveServer(11878754615) as unknown as string;
        // pcall(() => {
        //     DDS_Match.SetAsync(tostring(YangInvite.UserId), Kode);
        //     DDS_Match.SetAsync(tostring(SiapaInvite.UserId), Kode);
        // });
        TeleportService.TeleportToPrivateServer(11878754615, Kode, [YangInvite, SiapaInvite]);
    }
});

Players.PlayerAdded.Connect((pemain) => {
    const FolderDataPemain = new Instance("Folder");
    FolderDataPemain.Name = "DataPemain";
    FolderDataPemain.Parent = pemain;
    
    const DataPoint = new Instance("Folder");
    DataPoint.Name = "DataPoint";
    DataPoint.Parent = FolderDataPemain;

    const BerapaPoint = new Instance("NumberValue");
    BerapaPoint.Name = "Point";
    BerapaPoint.Value = 1000;
    BerapaPoint.Parent = DataPoint;

    const BerapaRatingDeviation = new Instance("NumberValue");
    BerapaRatingDeviation.Name = "RatingDeviation";
    BerapaRatingDeviation.Value = 100;
    BerapaRatingDeviation.Parent = DataPoint;

    const BerapaVolatility = new Instance("NumberValue");
    BerapaVolatility.Name = "Volatility";
    BerapaVolatility.Value = 0.06;
    BerapaVolatility.Parent = DataPoint;

    const BerapaUang = new Instance("NumberValue");
    BerapaUang.Name = "Uang";
    BerapaUang.Value = 0;
    BerapaUang.Parent = FolderDataPemain;

    const FolderSettings = new Instance("Folder");
    FolderSettings.Name = "DataSettings";
    FolderSettings.Parent = FolderDataPemain;

    const WarnaBoard1 = new Instance("StringValue");
    WarnaBoard1.Name = `WarnaBoard1`;
    WarnaBoard1.Value = Color3.fromRGB(170, 216, 124).ToHex();
    WarnaBoard1.Parent = FolderSettings;

    const WarnaBoard2 = new Instance("StringValue");
    WarnaBoard2.Name = `WarnaBoard2`;
    WarnaBoard2.Value = Color3.fromRGB(255, 255, 255).ToHex();
    WarnaBoard2.Parent = FolderSettings;

    const FolderBarang = new Instance("Folder");
    FolderBarang.Name = "DataBarang";
    FolderBarang.Parent = FolderDataPemain;

    const BarangKematian = new Instance("Folder");
    BarangKematian.Name = "BarangKematian";
    BarangKematian.Parent = FolderBarang;

    const BarangSkinPiece = new Instance("Folder");
    BarangSkinPiece.Name = "BarangSkinPiece";
    BarangSkinPiece.Parent = FolderBarang;

    const SkinPiece = new Instance("StringValue");
    SkinPiece.Name = "skinpiece";
    SkinPiece.Parent = FolderBarang;

    const Kematian = new Instance("StringValue");
    Kematian.Name = "kematian";
    Kematian.Parent = FolderBarang;

    const FolderStatus = new Instance("Folder");
    FolderStatus.Name = "DataStatus";
    FolderStatus.Parent = FolderDataPemain;

    const BerapaMenang = new Instance("NumberValue");
    BerapaMenang.Name = "Menang";
    BerapaMenang.Parent = FolderStatus;

    const BerapaKalah = new Instance("NumberValue");
    BerapaKalah.Name = "Kalah";
    BerapaKalah.Parent = FolderStatus;

    const BerapaMain = new Instance("NumberValue");
    BerapaMain.Name = "JumlahMain";
    BerapaMain.Parent = FolderStatus;

    const DataHistory = new Instance("Folder");
    DataHistory.Name = "History";
    DataHistory.Parent = FolderStatus;

    const BerapaKaliDraw = new Instance("NumberValue");
    BerapaKaliDraw.Name = "BerapaKaliDraw";
    BerapaKaliDraw.Value = 1;
    BerapaKaliDraw.Parent = pemain;

    const Data: { DataSettings: { WarnaBoard1: string, WarnaBoard2: string }, DataBarang: { kematian: string, skin: string, BarangKematian: string[], BarangSkinPiece: string[] }, DataRating: { Point: number, RatingDeviation: number, Volatility: number }, Uang: number } = {
        DataSettings: {
            WarnaBoard1: Color3.fromRGB(170, 216, 124).ToHex(),
            WarnaBoard2: Color3.fromRGB(255, 255, 255).ToHex()
        },
        DataBarang: {
            kematian: "meledak",
            skin: "normal",
            BarangKematian: [],
            BarangSkinPiece: []
        },
        DataRating: {
            Point: BerapaPoint.Value,
            RatingDeviation: BerapaRatingDeviation.Value,
            Volatility: BerapaVolatility.Value
        },
        Uang: BerapaUang.Value
    }

    const [success, err] = pcall(() => {
        const HasilDataSettingan = DDS_Settings.GetAsync(`${pemain.UserId}-settingan`) as unknown as string | undefined;
        if(HasilDataSettingan !== undefined) {
            Data.DataSettings = http.JSONDecode(HasilDataSettingan) as { WarnaBoard1: string, WarnaBoard2: string };
        }

        const HasilUang = DDS_Uang.GetAsync(`${pemain.UserId}-uang`) as unknown as string | undefined;
        if(HasilUang !== undefined) {
            Data.Uang = tonumber(HasilUang)!;
        }

        const HasilDataPoint = DDS_Rating.GetAsync(`${pemain.UserId}-rating`) as unknown as { point: number, ratingDeviation: number, volatility: number };
        if(HasilDataPoint !== undefined) {
            Data.DataRating.Point = HasilDataPoint.point;
            Data.DataRating.RatingDeviation = HasilDataPoint.ratingDeviation;
            Data.DataRating.Volatility = HasilDataPoint.volatility;
        }

        const HasilDataBarang = DDS_Barang.GetAsync(`${pemain.UserId}-barang`) as unknown as { kematian: string, skin: string, BarangKematian: string[], BarangSkinPiece: string[] } | undefined;
        if(HasilDataBarang !== undefined) {
            Data.DataBarang.kematian = HasilDataBarang.kematian;
            Data.DataBarang.skin = HasilDataBarang.skin;
            Data.DataBarang.BarangKematian = HasilDataBarang.BarangKematian;
            Data.DataBarang.BarangSkinPiece = HasilDataBarang.BarangSkinPiece;
        }

        const HasilDataStatus = DDS_Status.GetAsync(tostring(pemain.UserId)) as unknown as { Menang: number, Kalah: number, JumlahMain: number };
        if(HasilDataStatus !== undefined) {
            BerapaMenang.Value = HasilDataStatus.Menang;
            BerapaKalah.Value = HasilDataStatus.Kalah;
            BerapaMain.Value = HasilDataStatus.JumlahMain;
        }

        const HasilHistory = DDS_History.GetAsync(tostring(pemain.UserId)) as unknown as TipeHistory[];
        if(HasilHistory) {
            HasilHistory.forEach((v, i) => {
                const FolderMatch = new Instance("Folder");
                FolderMatch.Name = `Match ${i+1}`;
                FolderMatch.Parent = DataHistory;

                const FolderPemain1 = new Instance("Folder");
                FolderPemain1.Name = "Pemain1";
                FolderPemain1.Parent = FolderMatch;

                const Nama1 = new Instance("StringValue");
                Nama1.Name = "nama";
                Nama1.Value = v.Pemain1.nama;
                Nama1.Parent = FolderPemain1;

                const Warna1 = new Instance("StringValue");
                Warna1.Name = "warna";
                Warna1.Value = v.Pemain1.warna;
                Warna1.Parent = FolderPemain1;

                const Point1 = new Instance("NumberValue");
                Point1.Name = "point";
                Point1.Value = v.Pemain1.point;
                Point1.Parent = FolderPemain1;

                const FolderPemain2 = new Instance("Folder");
                FolderPemain2.Name = "Pemain2";
                FolderPemain2.Parent = FolderMatch;

                const Nama2 = new Instance("StringValue");
                Nama2.Name = "nama";
                Nama2.Value = v.Pemain2.nama;
                Nama2.Parent = FolderPemain2;

                const Warna2 = new Instance("StringValue");
                Warna2.Name = "warna";
                Warna2.Value = v.Pemain2.warna;
                Warna2.Parent = FolderPemain2;

                const Point2 = new Instance("NumberValue");
                Point2.Name = "point";
                Point2.Value = v.Pemain2.point;
                Point2.Parent = FolderPemain2;

                const YangMenang = new Instance("StringValue");
                YangMenang.Name = "YangMenang";
                YangMenang.Value = v.YangMenang;
                YangMenang.Parent = FolderMatch;

                const Alasan = new Instance("StringValue");
                Alasan.Name = "Alasan";
                Alasan.Value = v.Alasan;
                Alasan.Parent = FolderMatch;

                const Tanggal = new Instance("StringValue");
                Tanggal.Name = "Tanggal";
                Tanggal.Value = v.Tanggal;
                Tanggal.Parent = FolderMatch;

                const Gerakan = new Instance("StringValue");
                Gerakan.Name = "Gerakan";
                Gerakan.Value = v.Gerakan;
                Gerakan.Parent = FolderMatch;
            });
        }
    });

    pcall(() => {
        const DataPoint = DDS_Point_Ordered.GetSortedAsync(false, 50);
        const PointPage = DataPoint.GetCurrentPage();

        const DataMenang = DDS_Menang_Ordered.GetSortedAsync(false, 50);
        const MenangPage = DataMenang.GetCurrentPage();

        const DataKalah = DDS_Kalah_Ordered.GetSortedAsync(false, 50);
        const KalahPage = DataKalah.GetCurrentPage();

        const DataJumlahMain = DDS_JumlahMain_Ordered.GetSortedAsync(false, 50);
        const JumlahMainPage = DataJumlahMain.GetCurrentPage();
        
        Event.UpdateLeaderboard.FireClient(pemain, { "Point": PointPage, "Menang": MenangPage, "Kalah": KalahPage, "JumlahMain": JumlahMainPage });
    });

    if(success) {
        WarnaBoard1.Value = Data.DataSettings.WarnaBoard1;
        WarnaBoard2.Value = Data.DataSettings.WarnaBoard2;

        BerapaUang.Value = Data.Uang;

        Kematian.Value = Data.DataBarang.kematian;
        SkinPiece.Value = Data.DataBarang.skin;
        Data.DataBarang.BarangKematian.forEach((v) => {
            const Barang = new Instance("StringValue");
            Barang.Name = v;
            Barang.Parent = BarangKematian;
        });
        Data.DataBarang.BarangSkinPiece.forEach((v) => {
            const Barang = new Instance("StringValue");
            Barang.Name = v;
            Barang.Parent = BarangSkinPiece;
        });

        BerapaPoint.Value = Data.DataRating.Point;
        BerapaRatingDeviation.Value = Data.DataRating.RatingDeviation;
        BerapaVolatility.Value = Data.DataRating.Volatility;
    } else {
        print("Ada error");
        warn(err);
    }
});

Players.PlayerRemoving.Connect((pemain) => {
    DDS_Settings.SetAsync(`${pemain.UserId}-settingan`, http.JSONEncode({ WarnaBoard1: pemain.DataPemain.DataSettings.WarnaBoard1.Value, WarnaBoard2: pemain.DataPemain.DataSettings.WarnaBoard2.Value }));
});

wait(5)
while(true) {
    pcall(() => {
        const DataPoint = DDS_Point_Ordered.GetSortedAsync(false, 50);
        const PointPage = DataPoint.GetCurrentPage();

        const DataMenang = DDS_Menang_Ordered.GetSortedAsync(false, 50);
        const MenangPage = DataMenang.GetCurrentPage();

        const DataKalah = DDS_Kalah_Ordered.GetSortedAsync(false, 50);
        const KalahPage = DataKalah.GetCurrentPage();

        const DataJumlahMain = DDS_JumlahMain_Ordered.GetSortedAsync(false, 50);
        const JumlahMainPage = DataJumlahMain.GetCurrentPage();
        
        Event.UpdateLeaderboard.FireAllClients({ "Point": PointPage, "Menang": MenangPage, "Kalah": KalahPage, "JumlahMain": JumlahMainPage });
    });
    task.wait(120);
}