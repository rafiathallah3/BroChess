import { Players, ReplicatedStorage } from "@rbxts/services";
import { Chess, Square, Move, PieceSymbol, Color, Posisi, Promosi, TipeMode, AlasanDraw } from '../shared/chess';
import Kematian, { Kursi, SemuaKematian, SemuaKursi, SkinPiece } from "shared/ListKematian";

const DDS = game.GetService("DataStoreService");
const TeleportService = game.GetService("TeleportService");
const memoryStore = game.GetService("MemoryStoreService");
const MarketplaceService = game.GetService("MarketplaceService");
const queue = memoryStore.GetSortedMap("Queue");

const DDS_Settings = DDS.GetDataStore("DDS_Settings");
const DDS_Uang = DDS.GetDataStore("DDS_Uang");
const DDS_Barang = DDS.GetDataStore("DDS_Barang");
const DDS_Rating = DDS.GetDataStore("DDS_Rating");
const DDS_History = DDS.GetDataStore("DDS_History_2");
const DDS_Status = DDS.GetDataStore("DDS_Status");
const DDS_Ban = DDS.GetDataStore("DDS_Ban");
const DDS_VIPBonus = DDS.GetDataStore("DDS_VIPBonus");
// const DDS_Match = DDS.GetDataStore("DDS_Match");

const DDS_Point_Ordered = DDS.GetOrderedDataStore("DDS_Point_Ordered_1");
const DDS_Menang_Ordered = DDS.GetOrderedDataStore("DDS_Menang_Ordered_1");
const DDS_Kalah_Ordered = DDS.GetOrderedDataStore("DDS_Kalah_Ordered_1");
const DDS_JumlahMain_Ordered = DDS.GetOrderedDataStore("DDS_JumlahMain_Ordered_1");

const Event = ReplicatedStorage.remote;
const InfoValue = ReplicatedStorage.InfoValue;
const SiapaOwner = ["Friskyman321", "Reset26714667", "Player1"];
const SiapaAdmin = ["Strugon", "WreDsa", "Player2"];
let CaturGame: Chess;

type TipeHistory = {
    Pemain1: { warna: Color, point: number, nama: string },
    Pemain2: { warna: Color, point: number, nama: string },
    YangMenang: Color | "seri",
    Alasan: AlasanDraw | "skakmat" | "waktuhabis" | "menyerah",
    Tanggal: string,
    Gerakan: string,
}

const VIP_Id = 121883073

function RandomBarang() {
    const ItemBarang: string[] = [];
    for(let i = 0; i < 3; i++) {
        while(true) {
            const RandomKematian = SemuaKematian[math.random(0, SemuaKematian.size() - 1)];
            if(ItemBarang.find((v) => RandomKematian === v))
                continue
            else {
                ItemBarang.push(RandomKematian);
                break;
            }
        }
    }
    
    for(let i = 0; i < 2; i++) {
        while(true) {
            const RandomBarnag = SemuaKursi[math.random(0, SemuaKursi.size() - 1)];
            if(ItemBarang.find((v) => RandomBarnag === v))
                continue
            else {
                ItemBarang.push(RandomBarnag);
                break;
            }
        }
    }

    return ItemBarang
}
let BarangItem: string[] = RandomBarang();

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

Event.BeliBarang.OnServerInvoke = (pemain, BarangDiBeli: string) => {
    if(BarangItem.find((v) => v === BarangDiBeli)) {
        if(SemuaKematian.find((v) => v === BarangDiBeli)) {
            const DataKematian = Kematian[BarangDiBeli];
            if(DataKematian.Harga <= pemain.DataPemain.Uang.Value && !pemain.DataPemain.DataBarang.BarangKematian.FindFirstChild(BarangDiBeli)) {
                const BarangKematian = new Instance("StringValue");
                BarangKematian.Name = BarangDiBeli;
                BarangKematian.Value = BarangDiBeli;
                BarangKematian.Parent = pemain.DataPemain.DataBarang.BarangKematian;
                pemain.DataPemain.Uang.Value -= DataKematian.Harga;
                return "Sudah Beli";
            }

            return "Tidak cukup";
        }

        if(SemuaKursi.find((v) => v === BarangDiBeli)) {
            const DataKursi = Kursi[BarangDiBeli];
            if(DataKursi.Harga <= pemain.DataPemain.Uang.Value && !pemain.DataPemain.DataBarang.BarangKursi.FindFirstChild(BarangDiBeli)) {
                const BarangKursi = new Instance("StringValue");
                BarangKursi.Name = BarangDiBeli;
                BarangKursi.Value = BarangDiBeli;
                BarangKursi.Parent = pemain.DataPemain.DataBarang.BarangKursi;
                pemain.DataPemain.Uang.Value -= DataKursi.Harga;
                return "Sudah Beli";
            }

            return "Tidak cukup";
        }
        
        return "Tidak ada";
    }
};

Event.PakeBarang.OnServerEvent.Connect((pemain, NamaBarang: string, tipe: "Kursi" | "Effect" | "Skin") => {
    if(tipe === "Kursi" && pemain.DataPemain.DataBarang.BarangKursi.FindFirstChild(NamaBarang) && Kursi[NamaBarang] !== undefined) {
        pemain.DataPemain.DataBarang.kursi.Value = NamaBarang;
    }
    
    if(tipe === "Effect" && pemain.DataPemain.DataBarang.BarangKematian.FindFirstChild(NamaBarang) && Kematian[NamaBarang] !== undefined) {
        pemain.DataPemain.DataBarang.kematian.Value = NamaBarang;
    }

    if(tipe === "Skin" && pemain.DataPemain.DataBarang.BarangSkinPiece.FindFirstChild(NamaBarang) && SkinPiece[NamaBarang] !== undefined) {
        pemain.DataPemain.DataBarang.skinpiece.Value = NamaBarang;
    }
});

Event.BanOrang.OnServerEvent.Connect((pemain, userid: string) => {
    if(!pemain.DataPemain.Admin.Value && !pemain.DataPemain.Owner.Value) {
        pcall(() => {
            DDS_Ban.SetAsync(userid, (DDS_Ban.GetAsync(userid) as unknown) === undefined ? true : false);
            Players.GetPlayers().forEach((v) => {
                if(tonumber(userid) === v.UserId) {
                    pemain.Kick("You are banned")
                }
            });
        })
    }
});

Event.KirimDataWarnaBoard.OnServerEvent.Connect((pemain, PilihWarna: "hitam" | "putih", warna: Color3) => {
    if(PilihWarna === "hitam")
        pemain.DataPemain.DataSettings.WarnaBoard1.Value = warna.ToHex();
    else
        pemain.DataPemain.DataSettings.WarnaBoard2.Value = warna.ToHex();
});

const cooldown: { [Pemain: string]: boolean } = {};
Event.TambahinQueue.OnServerEvent.Connect((pemain, StatusQueue: "DALAM QUEUE" | "QUEUE") => {
    if(cooldown[pemain.Name]) return;
    cooldown[pemain.Name] = true;

    if(StatusQueue === "DALAM QUEUE") {
        pcall(() => {
            queue.SetAsync(tostring(pemain.UserId), pemain.UserId, 2592000);
        });
    } else if(StatusQueue === "QUEUE") {
        pcall(() => {
            queue.RemoveAsync(tostring(pemain.UserId));
        });
    }

    task.wait(1);
    cooldown[pemain.Name] = false;
});

Event.TeleportBalikKeGame.OnServerEvent.Connect((pemain, Kode: string) => {
    TeleportService.TeleportToPrivateServer(11878754615, Kode, [pemain]);
});

Players.PlayerAdded.Connect((pemain) => {
    const FolderDataPemain = new Instance("Folder");
    FolderDataPemain.Name = "DataPemain";
    FolderDataPemain.Parent = pemain;
    
    const ApakahVIP = new Instance("BoolValue");
    ApakahVIP.Name = "ApakahVIP";
    ApakahVIP.Parent = FolderDataPemain;

    const ApakahOwner = new Instance("BoolValue");
    ApakahOwner.Name = "Owner";
    ApakahOwner.Value = SiapaOwner.find((v) => v === pemain.Name) ? true : false;
    ApakahOwner.Parent = FolderDataPemain;

    const ApakahAdmin = new Instance("BoolValue");
    ApakahAdmin.Name = "Admin";
    ApakahAdmin.Value = SiapaAdmin.find((v) => v === pemain.Name) ? true : false;
    ApakahAdmin.Parent = FolderDataPemain;

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
    SkinPiece.Value = "skin_biasa"
    SkinPiece.Parent = FolderBarang;

    const Kematian = new Instance("StringValue");
    Kematian.Name = "kematian";
    Kematian.Value = "kematian_biasa";
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
        const HasilBan = DDS_Ban.GetAsync(tostring(pemain.UserId)) as unknown as boolean;
        if(HasilBan !== undefined && !ApakahOwner.Value && !ApakahAdmin.Value) {
            pemain.Kick("You are banned for using computer engine, You could appeal in our discord link");
        }

        const HasilDataSettingan = DDS_Settings.GetAsync(`${pemain.UserId}-settingan`) as unknown as { WarnaBoard1: string, WarnaBoard2: string } | undefined;
        print(HasilDataSettingan);
        if(HasilDataSettingan !== undefined) {
            WarnaBoard1.Value = HasilDataSettingan.WarnaBoard1;
            WarnaBoard2.Value = HasilDataSettingan.WarnaBoard2;
        }

        const HasilUang = DDS_Uang.GetAsync(tostring(pemain.UserId)) as unknown as string | undefined;
        if(HasilUang !== undefined) {
            BerapaUang.Value = tonumber(HasilUang) || 0;
        }

        const HasilDataPoint = DDS_Rating.GetAsync(`${pemain.UserId}-rating`) as unknown as { point: number, ratingDeviation: number, volatility: number };
        if(HasilDataPoint !== undefined) {
            BerapaPoint.Value = HasilDataPoint.point;
            BerapaRatingDeviation.Value = HasilDataPoint.ratingDeviation;
            BerapaVolatility.Value = HasilDataPoint.volatility;
        }

        const HasilDataBarang = DDS_Barang.GetAsync(tostring(pemain.UserId)) as unknown as { kematian: string, skin: string, kursi: string, BarangKematian: string[], BarangSkinPiece: string[], BarangKursi: string[] } | undefined;
        print(HasilDataBarang);
        if(HasilDataBarang !== undefined) {
            Kematian.Value = HasilDataBarang.kematian || "kematian_biasa";
            SkinPiece.Value = HasilDataBarang.skin || "skin_biasa";
            Kursi.Value = HasilDataBarang.kursi || "kursi_biasa"; //HasilDataBarang.kursi

            HasilDataBarang.BarangKematian.forEach((v) => {
                if(!BarangKematian.FindFirstChild(v)) {
                    const DataKematian = new Instance("StringValue");
                    DataKematian.Name = v;
                    DataKematian.Value = v;
                    DataKematian.Parent = BarangKematian;
                }
            });
            HasilDataBarang.BarangSkinPiece.forEach((v) => {
                if(!BarangSkinPiece.FindFirstChild(v)) {
                    const DataSkinPiece = new Instance("StringValue");
                    DataSkinPiece.Name = v;
                    DataSkinPiece.Value = v;
                    DataSkinPiece.Parent = BarangSkinPiece;
                }
            });
            HasilDataBarang.BarangKursi.forEach((v) => {
                if(!BarangKursi.FindFirstChild(v)) {
                    const DataKursi = new Instance("StringValue");
                    DataKursi.Name = v;
                    DataKursi.Value = v;
                    DataKursi.Parent = BarangKursi;
                }
            });
        } else {
            const SkinBiasa = new Instance("StringValue");
            SkinBiasa.Name = "skin_biasa";
            SkinBiasa.Value = "skin_biasa";
            SkinBiasa.Parent = BarangSkinPiece;

            const KematianBiasa = new Instance("StringValue");
            KematianBiasa.Name = "kematian_biasa";
            KematianBiasa.Value = "kematian_biasa";
            KematianBiasa.Parent = BarangKematian;

            const KursiBiasa = new Instance("StringValue");
            KursiBiasa.Name = "kursi_biasa";
            KursiBiasa.Value = "kursi_biasa";
            KursiBiasa.Parent = BarangKursi;
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

    const [succ, message] = pcall(() => {
        ApakahVIP.Value = MarketplaceService.UserOwnsGamePassAsync(pemain.UserId, VIP_Id);
        const ApakahSudahDapatBonus = DDS_VIPBonus.GetAsync(tostring(pemain.Name)) as unknown as boolean;
        if(ApakahSudahDapatBonus !== undefined && ApakahVIP) {
            if(!ApakahSudahDapatBonus) {
                const KematianVIP = new Instance("StringValue");
                KematianVIP.Name = "kematian_vip";
                KematianVIP.Value = "kematian_vip";
                KematianVIP.Parent = BarangKematian;

                const KursiVIP = new Instance("StringValue");
                KursiVIP.Name = "kursi_vip";
                KursiVIP.Value = "kursi_vip";
                KursiVIP.Parent = BarangKursi;

                BerapaUang.Value += 1500;

                DDS_VIPBonus.SetAsync(tostring(pemain.Name), true);
            }
        }
    });

    if(err) {
        print("Ada error");
        warn(err);
    }

    Event.KirimItemShop.FireClient(pemain, BarangItem);
});

Players.PlayerRemoving.Connect((pemain) => {
    queue.RemoveAsync(tostring(pemain.UserId));
    const [succ, err] = pcall(() => {
        print("What de hell")
        DDS_Settings.SetAsync(`${pemain.UserId}-settingan`, { WarnaBoard1: pemain.DataPemain.DataSettings.WarnaBoard1.Value, WarnaBoard2: pemain.DataPemain.DataSettings.WarnaBoard2.Value });
        print("roblox");
        DDS_Uang.SetAsync(tostring(pemain.UserId), pemain.DataPemain.Uang.Value);
        print("ooomg")
        const BarangKematian = pemain.DataPemain.DataBarang.BarangKematian.GetChildren().map((v) => v.Name);
        const BarangKursi = pemain.DataPemain.DataBarang.BarangKursi.GetChildren().map((v) => v.Name);
        const BarangSkinPiece = pemain.DataPemain.DataBarang.BarangSkinPiece.GetChildren().map((v) => v.Name);
        print({ 
            kematian: pemain.DataPemain.DataBarang.kematian.Value,
            skin: pemain.DataPemain.DataBarang.skinpiece.Value,
            kursi: pemain.DataPemain.DataBarang.kursi.Value,
            BarangKematian: BarangKematian,
            BarangSkinPiece: BarangSkinPiece,
            BarangKursi: BarangKursi
        });
        DDS_Barang.SetAsync(tostring(pemain.UserId), { 
            kematian: pemain.DataPemain.DataBarang.kematian.Value,
            skin: pemain.DataPemain.DataBarang.skinpiece.Value,
            kursi: pemain.DataPemain.DataBarang.kursi.Value,
            BarangKematian: BarangKematian,
            BarangSkinPiece: BarangSkinPiece,
            BarangKursi: BarangKursi
        });
    });
    
    print(err);
});

coroutine.wrap(() => {
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
})();

let lastOverMin = tick();
let SelamaGanti = 60*60;
while(true) {
    SelamaGanti -= 1;
    Event.UpdateWaktuShop.FireAllClients(SelamaGanti);

    if(SelamaGanti <= 0) {
        BarangItem = RandomBarang();
        Event.KirimItemShop.FireAllClients(BarangItem);
        SelamaGanti = 60*60;
    }

    task.wait(1);
    
    const [success, queuedPlayers] = pcall(() => {
        return queue.GetRangeAsync(Enum.SortDirection.Descending, 2);
    }) as LuaTuple<[ boolean, { key: string, value: string }[] ]>;

    if(success) {
        const amountQueued = queuedPlayers.size();

        if(amountQueued < 2) {
            lastOverMin = tick();
        }

        const timeOverMin = tick() - lastOverMin;
        if(timeOverMin >= 20 || amountQueued === 2) {
            const ListPemain: Player[] = []
            queuedPlayers.forEach((v) => {
                const pemain = Players.GetPlayerByUserId(tonumber(v.value)!);

                if(pemain) {
                    ListPemain.push(pemain);                    
                }
            })

            const [success, err] = pcall(() => {
                const Kode = TeleportService.ReserveServer(11878754615) as unknown as string;
                TeleportService.TeleportToPrivateServer(11878754615, Kode, ListPemain);
            });

            spawn(() => {
                if(success) {
                    task.wait(1);
                    pcall(() => {
                        ListPemain.forEach((v) => {
                            if(Players.FindFirstChild(v.Name)) {
                                Event.TambahinUndangan.FireClient(v, "terima invite");
                            }
                            queue.RemoveAsync(tostring(v.UserId));
                        });
                        ListPemain.clear();
                    })
                }
            });
        }
    }
}
