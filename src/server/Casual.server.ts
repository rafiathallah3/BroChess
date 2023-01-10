import { Players, ReplicatedStorage, StarterGui, TeleportService, Workspace } from "@rbxts/services";
import { ContohKematian, DapatinFungsiDariString } from "shared/ListKematian";
import { Chess, Square, Move, PieceSymbol, Color, Posisi, Promosi, TipeMode, AlasanDraw } from '../shared/chess';

const http = game.GetService("HttpService");
const DDS = game.GetService("DataStoreService");
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

const InfoValue = ReplicatedStorage.InfoValue;
const Event = ReplicatedStorage.remote;
const Pemain: Player[] = [];
let CaturGame: Chess;

/*
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
Point tidak akurat dengan lobby sama match      (Sudah?)
Win atau kalah ditambah dua untuk strugon       (Sudah?)
Player left match otomatis selesai              (Sudah)
sering Menolak draw dari opponent chat banyak   
Fix size ui nomor a4, a3, thing                 (Sudah)
persentase menang gk nampak                     (Sudah)
Random Error, Kalau SelesaiGame ndk muncul Pemenangan UI
*/

/* 
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
*/

/*
Yang harus dilakukan
Kalau gamenya diabandond apakah harus ditambahin ke history?                (no, sudah dilakukan)
Kalau playernya lost connection apakah harus diabandon atau rematch?        (Diabandon)
Tambahin Uang                                                               (Sudah)
*/

type TipeHistory = {
    Pemain1: { warna: Color, point: number, nama: string },
    Pemain2: { warna: Color, point: number, nama: string },
    YangMenang: Color | "seri",
    Alasan: AlasanDraw | "skakmat" | "waktuhabis" | "menyerah" | "keluar game",
    Tanggal: string,
    Gerakan: string,
}

function SelesaiGameDanKematian() {
    const [ApakahSelesai, StatusSelesai, SiapaPemenang] = CaturGame.ApakahGameSelesai();
    if(ApakahSelesai) {
        const Pemain1 = CaturGame.DapatinPemainDariWarna("w")!;
        const Pemain2 = CaturGame.DapatinPemainDariWarna("b")!;

        const DataPemain1 = Pemain1.Pemain.DataPemain;
        const DataPemain2 = Pemain2.Pemain.DataPemain;

        const RatingPemain1 = CaturGame.RatingPemain1?.warna === Pemain1.warna ? CaturGame.RatingPemain1 : CaturGame.RatingPemain2;
        const RatingPemain2 = CaturGame.RatingPemain2?.warna === Pemain2.warna ? CaturGame.RatingPemain2 : CaturGame.RatingPemain1;
        
        const PointPemain1 = DataPemain1.DataPoint.Point.Value;
        const PointPemain2 = DataPemain2.DataPoint.Point.Value;
        const UangPemain1 = DataPemain1.Uang.Value;
        const UangPemain2 = DataPemain2.Uang.Value;
        DataPemain1.Uang.Value += Pemain1.uang;
        DataPemain2.Uang.Value += Pemain2.uang;

        //Kita perlu ini untuk tunjukkin point client
        if(StatusSelesai !== "draw" && SiapaPemenang === "w" || SiapaPemenang === "b") {
            const PemainMenang = CaturGame.DapatinPemainDariWarna(SiapaPemenang!)!.Pemain;
            const PemainKalah = CaturGame.DapatinPemainDariWarna(SiapaPemenang! === "w" ? "b" : "w")!.Pemain;

            if(SiapaPemenang === "w") {
                DataPemain1.DataPoint.Point.Value = RatingPemain1!.Menang.rating;
                DataPemain1.DataPoint.RatingDeviation.Value = RatingPemain1!.Menang.rd;
                DataPemain1.DataPoint.Volatility.Value = RatingPemain1!.Menang.vol;
                DataPemain1.DataStatus.Menang.Value = RatingPemain1!.JumlahMenang;
                DataPemain1.Uang.Value += 50;

                if(RatingPemain2!.Kalah.rating > 200) {
                    DataPemain2.DataPoint.Point.Value = RatingPemain2!.Kalah.rating;
                } else {
                    DataPemain2.DataPoint.Point.Value = 200;
                }

                DataPemain2.DataPoint.RatingDeviation.Value = RatingPemain2!.Kalah.rd;
                DataPemain2.DataPoint.Volatility.Value = RatingPemain2!.Kalah.vol;
                DataPemain2.DataStatus.Kalah.Value = RatingPemain2!.JumlahKalah;
            } else {
                if(RatingPemain1!.Kalah.rating > 200) {
                    DataPemain1.DataPoint.Point.Value = RatingPemain1!.Kalah.rating;
                } else {
                    DataPemain1.DataPoint.Point.Value = 200;
                }
                DataPemain1.DataPoint.RatingDeviation.Value = RatingPemain1!.Kalah.rd;
                DataPemain1.DataPoint.Volatility.Value = RatingPemain1!.Kalah.vol;
                DataPemain1.DataStatus.Kalah.Value = RatingPemain1!.JumlahKalah;

                DataPemain2.DataPoint.Point.Value = RatingPemain2!.Menang.rating;
                DataPemain2.DataPoint.RatingDeviation.Value = RatingPemain2!.Menang.rd;
                DataPemain2.DataPoint.Volatility.Value = RatingPemain2!.Menang.vol;
                DataPemain2.DataStatus.Menang.Value = RatingPemain2!.JumlahMenang;
                DataPemain2.Uang.Value += 50;
            }

            wait(4);

            if(StatusSelesai !== "keluar game") {
                const FungsiKematian = DapatinFungsiDariString(PemainMenang.DataPemain.DataBarang.kematian.Value as ContohKematian)
                if(FungsiKematian !== undefined) {
                    FungsiKematian(Workspace.Tempat.meja_kursi.chairs.FindFirstChild(PemainKalah.Name as "kursi1" | "kursi2") as Workspace["Tempat"]["meja_kursi"]["chairs"]["kursi1"], PemainKalah.Character || PemainKalah.CharacterAdded.Wait()[0]);
                }
            }
        } else {
            if(SiapaPemenang !== "Game Ended") {
                DataPemain1.DataPoint.Point.Value = RatingPemain1!.Seri.rating;
                DataPemain1.DataPoint.RatingDeviation.Value = RatingPemain1!.Seri.rd;
                DataPemain1.DataPoint.Volatility.Value = RatingPemain1!.Seri.vol;
    
                DataPemain2.DataPoint.Point.Value = RatingPemain2!.Seri.rating;
                DataPemain2.DataPoint.RatingDeviation.Value = RatingPemain2!.Seri.rd;
                DataPemain2.DataPoint.Volatility.Value = RatingPemain2!.Seri.vol;
            }
        }

        if(SiapaPemenang !== "Game Ended") {
            DataPemain1.DataStatus.JumlahMain.Value = RatingPemain1!.JumlahMain;
            DataPemain2.DataStatus.JumlahMain.Value = RatingPemain2!.JumlahMain;
        }
        
        task.wait(3);
        const DataYangPerlu = [
            { p1: CaturGame.p1, p2: CaturGame.p2 },
            CaturGame.ApakahGameSelesai(),
        ]

        Event.TunjukkinMenangUI.FireClient(
            DataPemain1.Parent as Player,
            "w",
            StatusSelesai === "draw" ? SiapaPemenang === "Game Ended" ? 0 : RatingPemain1!.Seri.SelisihRating : SiapaPemenang === "w" ? RatingPemain1!.Menang.SelisihRating : RatingPemain1!.Kalah.SelisihRating,
            PointPemain1,
            DataPemain1.Uang.Value - UangPemain1,
            UangPemain1,
            ...DataYangPerlu
        );

        Event.TunjukkinMenangUI.FireClient(
            DataPemain2.Parent as Player,
            "b",
            StatusSelesai === "draw" ? SiapaPemenang === "Game Ended" ? 0 : RatingPemain2!.Seri.SelisihRating : SiapaPemenang === "b" ? RatingPemain2!.Menang.SelisihRating : RatingPemain2!.Kalah.SelisihRating,
            PointPemain2,
            DataPemain2.Uang.Value - UangPemain2,
            UangPemain2,
            ...DataYangPerlu
        );
    }
}

Event.GerakanCatur.OnServerEvent.Connect((p: Player, awalPosisi: Square, tujuanPosisi: Square, promosi?: Promosi) => {
    const GerakanPosisi = (CaturGame.moves({ square: awalPosisi, verbose: true, warna: CaturGame.turn() }) as Move[]).map((v) => v.to);
    const WarnaPemain = CaturGame.DapatinWarnaDariPlayer(p);
    const DataPemain = CaturGame.DapatinPemainDariWarna(WarnaPemain!)!;

    if(GerakanPosisi.includes(tujuanPosisi) && WarnaPemain === CaturGame.turn()) {
        const HasilMove = CaturGame.move({ from: awalPosisi, to: tujuanPosisi, promotion: promosi });
        if(HasilMove?.flags === "c") {
            const Uang = {
                p: 5,
                b: 15,
                n: 15,
                r: 20,
                q: 25,
                k: 0
            }
            
            DataPemain.uang += Uang[HasilMove.captured!];
        }

        if(!DataPemain.SudahGerak) DataPemain.SudahGerak = true;

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
            CaturGame.ApakahGameSelesai(),
            { warna: CaturGame.turn(), check: CaturGame.isCheck() },
        ]

        Event.KirimSemuaGerakan.FireClient(
            CaturGame.p1.Pemain,
            CaturGame.p1.warna,
            CaturGame.p2,
            ...DataPengiriman,
        );
        if(CaturGame.mode === "player" && CaturGame.p2 !== undefined) {
            Event.KirimSemuaGerakan.FireClient(
                CaturGame.p2.Pemain,
                CaturGame.p2.warna,
                CaturGame.p1,
                ...DataPengiriman
            );
        }

        SelesaiGameDanKematian();
    }
});

Event.Lapor.OnServerEvent.Connect((pemain: Player, kontentLaporan: string, yangDiReport: Player) => {
    if(!pemain.FindFirstChild("SudahLapor")) {
        const SudahLapor = new Instance("StringValue");
        SudahLapor.Name = "SudahLapor";
        SudahLapor.Parent = pemain;

        http.PostAsync("https://webhook.newstargeted.com/api/webhooks/1058334097241542716/BUBFPyom7_55TeuQXr0ishS0Ar6C7ydAuNTgmpS5s3I5TTawnYq5NpTm0C8uI0SxVQ5C", http.JSONEncode({
            embeds: [{
                author: {
                    name: `${pemain.Name} melaporkan ${yangDiReport.Name}`
                },
                description: `Status Selesai: ${CaturGame.ApakahGameSelesai()[1]}\n${kontentLaporan}\n${http.JSONEncode(CaturGame.header())}`,
                type: 'rich',
                color: tonumber(0xffffff)
            }, {
                author: {
                    name: `Gerakan`
                },
                description: CaturGame.DapatinPGN(),
                type: 'rich',
                color: tonumber(0xffffff)
            }]
        }));
    }
});

Event.Menyerah.OnServerEvent.Connect((pemain: Player) => {
    const Warna = CaturGame.DapatinWarnaDariPlayer(pemain);
    if(Warna !== undefined) {
        if(CaturGame.p1.SudahGerak && CaturGame.p2?.SudahGerak) {
            CaturGame.Menyerah(Warna);
            Event.KirimCaturPemenang.FireClient(CaturGame.p1.Pemain, Warna === "w" ? "b" : "w");
            Event.KirimCaturPemenang.FireClient(CaturGame.p2!.Pemain, Warna === "w" ? "b" : "w");
        } else {
            CaturGame.SetAlasanSeri("Game Ended");
            Event.KirimCaturPemenang.FireClient(CaturGame.p1.Pemain, "seri");
            Event.KirimCaturPemenang.FireClient(CaturGame.p2!.Pemain, "seri");
        }

        SelesaiGameDanKematian();
    }
});

Event.Seri.OnServerEvent.Connect((pemain: Player, instruksi: "ajak seri" | "terima seri" | "tolak seri", SiapaYangNgeDraw: Player) => {
    if(instruksi === "ajak seri") {
        if(pemain.BerapaKaliDraw.Value <= 3) {
            pemain.BerapaKaliDraw.Value += 1;
        
            const Warna = CaturGame.DapatinWarnaDariPlayer(pemain);
            const yangMauDiDraw = CaturGame.DapatinPemainDariWarna(Warna === "w" ? "b" : "w")!.Pemain;
        
            const SeriValue = new Instance("StringValue");
            SeriValue.Name = yangMauDiDraw.Name;
            SeriValue.Parent = pemain;
        
            Event.Seri.FireClient(yangMauDiDraw, "tunjukkin", pemain);
        }
    } else if(instruksi === "terima seri") {
        if(SiapaYangNgeDraw.FindFirstChild(pemain.Name)) {
            SiapaYangNgeDraw.FindFirstChild(pemain.Name)?.Destroy();

            CaturGame.SetAlasanSeri("Accept Draw");
            Event.Seri.FireClient(pemain, "terima seri");
            Event.Seri.FireClient(SiapaYangNgeDraw, "terima seri");
    
            Event.KirimCaturPemenang.FireClient(CaturGame.p1.Pemain, "seri");
            Event.KirimCaturPemenang.FireClient(CaturGame.p2!.Pemain, "seri");
    
            SelesaiGameDanKematian();
        }
    } else if(instruksi === "tolak seri") {
        Event.Seri.FireClient(SiapaYangNgeDraw, "tolak seri");
    }
});

let TotalYangDiInvite = 1;
Event.KirimRematch.OnServerEvent.Connect((pemain, yangDiInvite: Player) => {
    if(!pemain.DataPemain.FindFirstChild("LagiInvite") && TotalYangDiInvite < 3) {
        const LagiInvite = new Instance("BoolValue");
        LagiInvite.Name = "LagiInvite";
        LagiInvite.Parent = pemain.DataPemain;

        const LagiInvite2 = new Instance("BoolValue");
        LagiInvite2.Name = "LagiInvite";
        LagiInvite2.Parent = yangDiInvite.DataPemain;
        
        Event.KirimRematchKePemainUI.FireClient(yangDiInvite, pemain);

        LagiInvite.Destroy();
        TotalYangDiInvite++;
    }
});

Event.StatusRematch.OnServerEvent.Connect((pemain, siapainvite: Player, status: "terima" | "tolak") => {
    if(pemain.DataPemain.FindFirstChild("LagiInvite")) {
        Event.TunjukkinRematchStatus.FireClient(siapainvite, status);   

        if(status === "terima") {
            TeleportService.TeleportToPrivateServer(11878754615, TeleportService.ReserveServer(11878754615) as unknown as string, [pemain, siapainvite]);
        }
    }
})

Event.TeleportKeLobby.OnServerEvent.Connect((pemain) => {
    TeleportService.TeleportAsync(11738872153, [ pemain ]);
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

    const BarangKursi = new Instance("Folder");
    BarangKursi.Name = "BarangKursi";
    BarangKursi.Parent = FolderBarang;

    const SkinPiece = new Instance("StringValue");
    SkinPiece.Name = "skinpiece";
    SkinPiece.Parent = FolderBarang;

    const Kematian = new Instance("StringValue");
    Kematian.Name = "kematian";
    Kematian.Value = "meledak"
    Kematian.Parent = FolderBarang;

    const Kursi = new Instance("StringValue");
    Kursi.Name = "kursi";
    Kursi.Value = "kursi_biasa";
    Kursi.Parent = FolderBarang;

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

    const [success, err] = pcall(() => {
        const HasilDataSettingan = DDS_Settings.GetAsync(`${pemain.UserId}-settingan`) as unknown as { WarnaBoard1: string, WarnaBoard2: string } | undefined;
        print(HasilDataSettingan);
        if(HasilDataSettingan !== undefined) {
            WarnaBoard1.Value = HasilDataSettingan.WarnaBoard1;
            WarnaBoard2.Value = HasilDataSettingan.WarnaBoard2;
        }

        const HasilUang = DDS_Uang.GetAsync(`${pemain.UserId}-uang`) as unknown as string | undefined;
        if(HasilUang !== undefined) {
            BerapaUang.Value = tonumber(HasilUang) || 0;
        }

        const HasilDataPoint = DDS_Rating.GetAsync(`${pemain.UserId}-rating`) as unknown as { point: number, ratingDeviation: number, volatility: number };
        if(HasilDataPoint !== undefined) {
            BerapaPoint.Value = HasilDataPoint.point;
            BerapaRatingDeviation.Value = HasilDataPoint.ratingDeviation;
            BerapaVolatility.Value = HasilDataPoint.volatility;
        }

        const HasilDataBarang = DDS_Barang.GetAsync(`${pemain.UserId}-barang`) as unknown as { kematian: string, skin: string, kursi: string, BarangKematian: string[], BarangSkinPiece: string[], BarangKursi: string[] } | undefined;
        if(HasilDataBarang !== undefined) {
            Kematian.Value = HasilDataBarang.kematian;
            SkinPiece.Value = HasilDataBarang.skin;
            Kursi.Value = HasilDataBarang.kursi; //HasilDataBarang.kursi

            HasilDataBarang.BarangKematian.forEach((v) => {
                const DataKematian = new Instance("StringValue");
                DataKematian.Name = v;
                DataKematian.Value = v;
                DataKematian.Parent = BarangKematian;
            });
            HasilDataBarang.BarangSkinPiece.forEach((v) => {
                const DataSkinPiece = new Instance("StringValue");
                DataSkinPiece.Name = v;
                DataSkinPiece.Value = v;
                DataSkinPiece.Parent = BarangSkinPiece;
            });
            HasilDataBarang.BarangSkinPiece.forEach((v) => {
                const DataKursi = new Instance("StringValue");
                DataKursi.Name = v;
                DataKursi.Value = v;
                DataKursi.Parent = BarangKursi;
            });
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
                YangMenang.Value = v.YangMenang || "";
                YangMenang.Parent = FolderMatch;

                const Alasan = new Instance("StringValue");
                Alasan.Name = "Alasan";
                Alasan.Value = v.Alasan || "";
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

    if(err) {
        print("Ada error");
        warn(err);
    }

    if(game.GetService("RunService").IsStudio()) {
        if(pemain.Name === "Player1") {
            BerapaPoint.Value = 1053;
            BerapaRatingDeviation.Value = 99.95;
            Kursi.Value = "kursi_kerja";
        }
        if(pemain.Name === "Player2") {
            BerapaPoint.Value = 1012;
            BerapaRatingDeviation.Value = 99.63;
            Kursi.Value = "kursi_plastik";
        }
    }

    Pemain.push(pemain);
});

Players.PlayerRemoving.Connect((pemain) => {
    if(CaturGame !== undefined) {
        // if(InfoValue.SudahDimulai.Value) {
        //     DDS_Match.SetAsync(tostring(pemain.UserId), game.PrivateServerId);
        // }
        const WarnaPemain = CaturGame.DapatinWarnaDariPlayer(pemain)!;
        const DataPemain = CaturGame.DapatinPemainDariWarna(WarnaPemain)!;
        const RatingPemain = CaturGame.RatingPemain1?.warna === WarnaPemain ? CaturGame.RatingPemain1 : CaturGame.RatingPemain2;

        const [ApakahSelesai, StatusSelesai, SiapaPemenang] = CaturGame.ApakahGameSelesai();
        if(ApakahSelesai) {
            if(StatusSelesai !== "draw" && SiapaPemenang === "w" || SiapaPemenang === "b") {
                if(SiapaPemenang === WarnaPemain) {
                    pemain.DataPemain.DataPoint.Point.Value = RatingPemain!.Menang.rating;
                    pemain.DataPemain.DataPoint.RatingDeviation.Value = RatingPemain!.Menang.rd;
                    pemain.DataPemain.DataPoint.Volatility.Value = RatingPemain!.Menang.vol;

                    pemain.DataPemain.DataStatus.Menang.Value = RatingPemain!.JumlahMenang;
                    DDS_Menang_Ordered.SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.Menang.Value);
                } else {
                    if(RatingPemain!.Kalah.rating > 200) {
                        pemain.DataPemain.DataPoint.Point.Value = RatingPemain!.Kalah.rating;
                    } else {
                        pemain.DataPemain.DataPoint.Point.Value = 200;
                    }

                    pemain.DataPemain.DataPoint.RatingDeviation.Value = RatingPemain!.Kalah.rd;
                    pemain.DataPemain.DataPoint.Volatility.Value = RatingPemain!.Kalah.vol;

                    pemain.DataPemain.DataStatus.Kalah.Value = RatingPemain!.JumlahKalah;
                    DDS_Kalah_Ordered.SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.Kalah.Value);
                }

                DDS_Point_Ordered.SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataPoint.Point.Value);
            }
            
            if(SiapaPemenang !== "Game Ended") {
                pemain.DataPemain.DataStatus.JumlahMain.Value = RatingPemain!.JumlahMain;
                pemain.DataPemain.Uang.Value = DataPemain.uang;
                DDS_JumlahMain_Ordered.SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.JumlahMain.Value);
                pcall(() => {
                    const PemainPutih = CaturGame.DapatinPemainDariWarna("w")!;
                    const PemainHitam = CaturGame.DapatinPemainDariWarna("b")!;

                    const HistoryData = DDS_History.GetAsync(tostring(pemain.UserId)) as unknown as TipeHistory[] ?? [];
                    HistoryData.push({ 
                        Pemain1: { warna: "w", point: PemainPutih.Pemain.DataPemain.DataPoint.Point.Value, nama: PemainPutih.Pemain.Name },
                        Pemain2: { warna: "b", point: PemainHitam.Pemain.DataPemain.DataPoint.Point.Value, nama: PemainHitam.Pemain.Name },
                        YangMenang: StatusSelesai === "draw" ? "seri" : SiapaPemenang as Color,
                        Alasan: StatusSelesai === "draw" ? SiapaPemenang! as AlasanDraw : StatusSelesai!,
                        Tanggal: os.date("%d/%m/%y %X"),
                        Gerakan: CaturGame.DapatinPGN()
                    })
                    DDS_History.SetAsync(tostring(pemain.UserId), HistoryData);
                    // DDS_Match.SetAsync(tostring(pemain.UserId), '');
                });
            }

            DDS_Status.SetAsync(tostring(pemain.UserId), { Menang: pemain.DataPemain.DataStatus.Menang.Value, Kalah: pemain.DataPemain.DataStatus.Kalah.Value, JumlahMain: pemain.DataPemain.DataStatus.JumlahMain.Value })
        } else {
            if(CaturGame.mode === "player") {
                if(CaturGame.p1.SudahGerak && CaturGame.p2!.SudahGerak) {
                    const WarnaPemain = CaturGame.DapatinWarnaDariPlayer(pemain)!;
                    CaturGame.KeluarDariGame(WarnaPemain);
                    
                    if(RatingPemain!.Kalah.rating > 200) {
                        pemain.DataPemain.DataPoint.Point.Value = RatingPemain!.Kalah.rating;
                    } else {
                        pemain.DataPemain.DataPoint.Point.Value = 200;
                    }

                    pemain.DataPemain.DataPoint.RatingDeviation.Value = RatingPemain!.Kalah.rd;
                    pemain.DataPemain.DataPoint.Volatility.Value = RatingPemain!.Kalah.vol;

                    pemain.DataPemain.DataStatus.Kalah.Value = RatingPemain!.JumlahKalah;
                    pemain.DataPemain.DataStatus.JumlahMain.Value = RatingPemain!.JumlahMain;

                    pcall(() => {
                        const PemainPutih = CaturGame.DapatinPemainDariWarna("w")!;
                        const PemainHitam = CaturGame.DapatinPemainDariWarna("b")!;

                        DDS_Kalah_Ordered.SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.Kalah.Value);
                        DDS_Point_Ordered.SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataPoint.Point.Value);
                        DDS_JumlahMain_Ordered.SetAsync(tostring(pemain.UserId), pemain.DataPemain.DataStatus.JumlahMain.Value);

                        const HistoryData = DDS_History.GetAsync(tostring(pemain.UserId)) as unknown as TipeHistory[] ?? [];
                        HistoryData.push({ 
                            Pemain1: { warna: "w", point: PemainPutih.Pemain.DataPemain.DataPoint.Point.Value, nama: PemainPutih.Pemain.Name },
                            Pemain2: { warna: "b", point: PemainHitam.Pemain.DataPemain.DataPoint.Point.Value, nama: PemainHitam.Pemain.Name },
                            YangMenang: StatusSelesai === "draw" ? "seri" : SiapaPemenang as Color,
                            Alasan: StatusSelesai === "draw" ? SiapaPemenang! as AlasanDraw : StatusSelesai!,
                            Tanggal: os.date("%d/%m/%y %X"),
                            Gerakan: CaturGame.DapatinPGN()
                        })
                        DDS_History.SetAsync(tostring(pemain.UserId), HistoryData);
                        // DDS_Match.SetAsync(tostring(pemain.UserId), '');
                    });

                    Event.KirimCaturPemenang.FireClient(CaturGame.p1.Pemain, WarnaPemain === "w" ? "b" : "w");
                    Event.KirimCaturPemenang.FireClient(CaturGame.p2!.Pemain, WarnaPemain === "w" ? "b" : "w");
                } else {
                    CaturGame.SetAlasanSeri("Game Ended");
                    Event.KirimCaturPemenang.FireClient(CaturGame.p1.Pemain, "seri");
                    Event.KirimCaturPemenang.FireClient(CaturGame.p2!.Pemain, "seri");
                }

                print("Selesai gamenya");
                SelesaiGameDanKematian();
            }
        }
    }
    //Kalau player left dalam mid game maka kurangin pointnya atau reconnect game  
    DDS_Uang.SetAsync(tostring(pemain.UserId), pemain.DataPemain.Uang.Value);
    DDS_Rating.SetAsync(`${pemain.UserId}-rating`, { point: pemain.DataPemain.DataPoint.Point.Value, ratingDeviation: pemain.DataPemain.DataPoint.RatingDeviation.Value, volatility: pemain.DataPemain.DataPoint.Volatility.Value })
});

const TempatMap = ["StasiunAngkasa", "Laut"];
while(true) {
    task.wait(1);
    if(!InfoValue.SudahDimulai.Value) {
        if(Pemain.size() >= 2) {
            const randomWarna: Color[] = ["w", "b"];

            for (let i = randomWarna.size() - 1; i > 0; i--) {
                const j = math.floor(math.random() * (i + 1));

                [randomWarna[i], randomWarna[j]] = [randomWarna[j], randomWarna[i]];
            }

            const MapDipilih = TempatMap[math.random(0, TempatMap.size()-1)] as "StasiunAngkasa" | "Laut";
            const Map = ReplicatedStorage.Tempat[MapDipilih].Clone();

            Map.Parent = Workspace;

            const Pemain1 = Players.GetPlayers()[0];
            const Pemain2 = Players.GetPlayers()[1];
            const KarakterPemain1 = Pemain1.Character || Pemain1.CharacterAdded.Wait()[0];
            const KarakterPemain2 = Pemain2.Character || Pemain2.CharacterAdded.Wait()[0];
            const HumanoidPemain1 = (KarakterPemain1.WaitForChild("Humanoid") as Player["Character"]["Humanoid"]);
            const HumanoidPemain2 = (KarakterPemain2.WaitForChild("Humanoid") as Player["Character"]["Humanoid"])
            wait(.5);
            HumanoidPemain1.SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
            HumanoidPemain2.SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
            HumanoidPemain1.JumpPower = 0;
            HumanoidPemain2.JumpPower = 0;
            HumanoidPemain1.WalkSpeed = 0;
            HumanoidPemain2.WalkSpeed = 0;

            const KursiPemain1 = ReplicatedStorage.kursi[Pemain1.DataPemain.DataBarang.kursi.Value as "kursi_plastik"].Clone();
            KursiPemain1.Name = "kursi1";
            KursiPemain1.Parent = Workspace.Tempat.meja_kursi.chairs;
            KursiPemain1.utama.CFrame = Workspace.Tempat.meja_kursi.chairs.Posisi1.CFrame;

            const KursiPemain2 = ReplicatedStorage.kursi[Pemain2.DataPemain.DataBarang.kursi.Value as "kursi_plastik"].Clone();
            KursiPemain2.Name = "kursi2";
            KursiPemain2.Parent = Workspace.Tempat.meja_kursi.chairs;
            KursiPemain2.utama.CFrame = Workspace.Tempat.meja_kursi.chairs.Posisi2.CFrame;
            
            task.wait(1);
            KursiPemain1.Seat.Sit(HumanoidPemain1);
            KursiPemain2.Seat.Sit(HumanoidPemain2);
            KursiPemain1.Name = KarakterPemain1.Name;
            KursiPemain2.Name = KarakterPemain2.Name;
            HumanoidPemain1.Animator.LoadAnimation(KarakterPemain1.Animate.sit.SitAnim);
            HumanoidPemain2.Animator.LoadAnimation(KarakterPemain2.Animate.sit.SitAnim);
            
            task.wait(3);
            //rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
            //7k/8/8/8/8/8/2P5/5K2 w - - 0 1
            //8/2p5/3p4/KP5r/1R3p1k/8/4P1P/8 w - - 0 1
            CaturGame = new Chess({ Pemain: Players.GetPlayers()[0], warna: randomWarna[0] }, "player", { Pemain: Players.GetPlayers()[1], warna: randomWarna[1] }, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", true);
            CaturGame.header('White', CaturGame.DapatinPemainDariWarna("w")!.Pemain.Name);
            CaturGame.header('Black', CaturGame.DapatinPemainDariWarna("b")!.Pemain.Name);
            CaturGame.header("Date", os.date("%x %X"));

            InfoValue.SudahDimulai.Value = true;
            Map.TempatScript.Enabled = true;

            Event.KirimPemulaianCaturUIKePemain.FireClient(CaturGame.p1.Pemain, CaturGame.RatingPemain1!);
            Event.KirimPemulaianCaturUIKePemain.FireClient(CaturGame.p2!.Pemain, CaturGame.RatingPemain2!);
            
            coroutine.wrap(() => {
                wait(5);
                while(!CaturGame.isGameOver() && CaturGame.PerluWaktu && CaturGame.mode === "player") {
                    const PemainCatur = CaturGame.DapatinPemainDariWarna(CaturGame.turn())!;
                    const [SudahSelesai, Status, SiapaPemenang] = CaturGame.ApakahGameSelesai();
                    if(SudahSelesai) break;

                    if(PemainCatur.SudahGerak) {
                        PemainCatur.waktu -= .1;
                        // PemainCatur.waktu--;
                        Event.KirimWaktuCaturKePemain.FireClient(CaturGame.p1.Pemain, CaturGame.p1.waktu, CaturGame.p2);
                        Event.KirimWaktuCaturKePemain.FireClient(CaturGame.p2!.Pemain, CaturGame.p2!.waktu, CaturGame.p1);

                        if(PemainCatur.waktu <= 0) {
                            // Kasi menang disini 25/12/2022 23:06
                            const [apakahSelesai, StatusSelesai, SiapaPemenang] = CaturGame.ApakahGameSelesai();
                            if(apakahSelesai && StatusSelesai === "waktuhabis") {
                                Event.KirimCaturPemenang.FireClient(CaturGame.p1.Pemain, SiapaPemenang);
                                Event.KirimCaturPemenang.FireClient(CaturGame.p2!.Pemain, SiapaPemenang);

                                SelesaiGameDanKematian();
                            }
                            break;
                        }
                    } else {
                        if(PemainCatur.WaktuAFK >= 60) {
                            Event.KirimCaturPemenang.FireClient(CaturGame.p1.Pemain, "seri");
                            Event.KirimCaturPemenang.FireClient(CaturGame.p2!.Pemain, "seri");
                            CaturGame.SetAlasanSeri("Game Ended")

                            SelesaiGameDanKematian();
                            break;
                        }

                        PemainCatur.WaktuAFK += .1;
                        // PemainCatur.WaktuAFK++;
                    }
                    task.wait(.1);
                }
            })();

            break;
        }
    } else
        break
}