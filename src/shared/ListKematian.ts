import { Debris, ReplicatedStorage, Workspace } from "@rbxts/services";

const Tween = game.GetService("TweenService");

export const SemuaKematian = ["meledak", "kembang_api", "ditelan_kegelapan", "dilempar_kaleng"];
export const SemuaKursi = ["kursi_plastik", "kursi_kerja"];
export const SemuaSkinPiece = ["anime"]

export const Kematian: { [Nama in typeof SemuaKematian[number]]: { NamaLain: string, Harga: number, Gambar: string } } = {
    kematian_biasa: {
        NamaLain: "No Effect",
        Harga: 0,
        Gambar: "rbxassetid://8516027328"
    },
    meledak: {
        NamaLain: "Explode",
        Harga: 1500,
        Gambar: "rbxassetid://9571787764"
    },
    kembang_api: {
        NamaLain: "Firework",
        Harga: 1800,
        Gambar: "rbxassetid://1369782576"
    },
    ditelan_kegelapan: {
        NamaLain: "Into the darkness",
        Harga: 1500,
        Gambar: "rbxassetid://153700391"
    },
    dilempar_kaleng: {
        NamaLain: "Bloxycola",
        Harga: 2000,
        Gambar: "rbxassetid://914656783"
    },
    kematian_vip: {
        NamaLain: "VIP Effect",
        Harga: 0,
        Gambar: "",
    }
}

export const Kursi: { [Nama in typeof SemuaKursi[number]]: { NamaLain: string, Harga: number, Kursi: Model } } = {
    kursi_biasa: {
        NamaLain: "Normal",
        Harga: 0,
        Kursi: ReplicatedStorage.kursi.kursi_biasa,
    },
    kursi_plastik: {
        NamaLain: "White plastic",
        Harga: 1500,
        Kursi: ReplicatedStorage.kursi.kursi_plastik
    },
    kursi_kerja: {
        NamaLain: "Office chair",
        Harga: 1500,
        Kursi: ReplicatedStorage.kursi.kursi_kerja
    },
    kursi_vip: {
        NamaLain: "VIP Chair",
        Harga: 0,
        Kursi: ReplicatedStorage.kursi.kursi_vip
    }
}

export const SkinPiece: { [Nama in typeof SemuaSkinPiece[number]]: { NamaLain: string, Harga: number, Gambar: string } } = {
    skin_biasa: {
        NamaLain: "Normal",
        Harga: 0,
        Gambar: "rbxassetid://12113047759"
    },
    anime: {
        NamaLain: "Anime pieces",
        Harga: 1750,
        Gambar: "rbxassetid://12113545854"
    }
}

export type ContohKematian = "meledak" | "kembang_api" | "ditelan_kegelapan";

const Meledak = (kursi: Model & { Seat: Seat, utama: BasePart }) => {
    const SuaraLedak = new Instance("Sound");
    SuaraLedak.SoundId = "rbxasset://sounds/collide.wav";
    SuaraLedak.Parent = kursi;

    SuaraLedak.Play();

    const Peledak = new Instance("Explosion");
    Peledak.BlastPressure = 0;
    Peledak.BlastRadius = 0;
    Peledak.DestroyJointRadiusPercent = 0;
    Peledak.Position = kursi.utama.Position;
    Peledak.Parent = kursi.utama;

    kursi.utama.AssemblyLinearVelocity = new Vector3(0, 100, -30);
    kursi.utama.AssemblyAngularVelocity = new Vector3(0, 10, 5);
}

const Kembang_Api = (kursi: Model & { Seat: Seat, utama: BasePart }) => {
    const KembangApi = ReplicatedStorage.komponenKematian.PartikelKembangApi.Clone();

    const SuaraKembangApi = new Instance("Sound");
    SuaraKembangApi.SoundId = "rbxasset://sounds//Rocket shot.wav";
    SuaraKembangApi.Parent = Workspace;

    SuaraKembangApi.Play();

    kursi.utama.AssemblyLinearVelocity = new Vector3(0, 200, -100);
    kursi.utama.AssemblyAngularVelocity = new Vector3(0, 10, 15);

    KembangApi.Parent = kursi.utama;
    wait(2);

    const SuaraLedak = new Instance("Sound");
    SuaraLedak.SoundId = "rbxasset://sounds/collide.wav";
    SuaraLedak.Parent = Workspace;

    SuaraLedak.Play();
    SuaraKembangApi.Destroy();

    const Peledak = new Instance("Explosion");
    Peledak.BlastPressure = 0;
    Peledak.BlastRadius = 0;
    Peledak.DestroyJointRadiusPercent = 0;
    Peledak.Position = kursi.utama.Position;
    Peledak.Parent = kursi.utama;

    kursi.utama.AssemblyLinearVelocity = new Vector3(50, 100, 0);
    kursi.utama.AssemblyAngularVelocity = new Vector3(0, 10, 5);
    wait(.3);

    KembangApi.Destroy();
}

const Ditelan_Kegelapan = (kursi: Model & { Seat: Seat, utama: BasePart }, KarakterPemainKalah: Player["Character"]) => {
    const Bulatan = ReplicatedStorage.komponenKematian.bulat.Clone();
    Bulatan.Position = kursi.utama.Position.add(new Vector3(0, -2, 0));
    Bulatan.Parent = kursi;

    const Batas = new Instance("Part");
    Batas.CFrame = KarakterPemainKalah.HumanoidRootPart.CFrame.mul(new CFrame(0, -10, 0));
    Batas.Size = new Vector3(15, .2, 15);
    Batas.Transparency = 1;
    Batas.Parent = kursi

    const TweenBulataan = Tween.Create(Bulatan, new TweenInfo(1.5), { Size: new Vector3(0.1, 6, 6) });
    TweenBulataan.Play();
    TweenBulataan.Completed.Wait();

    KarakterPemainKalah.HumanoidRootPart.Anchored = true;
    wait(.5);

    const TweenPemain = Tween.Create(KarakterPemainKalah.HumanoidRootPart, new TweenInfo(3), { CFrame: KarakterPemainKalah.HumanoidRootPart.CFrame.mul(new CFrame(0, -6, 0)) })
    TweenPemain.Play();
    TweenPemain.Completed.Wait();
    wait(.2);

    const TweenTutup = Tween.Create(Bulatan, new TweenInfo(1.5), { Size: new Vector3(0.1, 0.01, 0.01) })
    TweenTutup.Play();
    TweenTutup.Completed.Connect(() => { Bulatan.Destroy() });
}

const Dilempar_Kaleng = (kursi: Model & { Seat: Seat, utama: BasePart }, KarakterPemainKalah: Player["Character"]) => {
    const DariLempar = ReplicatedStorage.komponenKematian.DariKaleng.Clone();
    DariLempar.Parent = Workspace;

    const arah = KarakterPemainKalah.Head.Position.sub(DariLempar.Position);
    const durasi = math.log(1.001 + arah.Magnitude * 0.01);
    const gaya = arah.div(durasi).add(new Vector3(0, Workspace.Gravity * durasi * .5, 0));

    const SuaraMinum = new Instance("Sound");
    SuaraMinum.SoundId = "rbxassetid://10722059";
    SuaraMinum.Volume = 2;
    SuaraMinum.Parent = Workspace;
    SuaraMinum.Play();
    SuaraMinum.Ended.Wait();
    wait(1);
    
    const Kaleng = ReplicatedStorage.komponenKematian.Kaleng.Clone();
    Kaleng.Position = DariLempar.Position;
    Kaleng.Parent = Workspace;
    Kaleng.ApplyImpulse(gaya.mul(Kaleng.AssemblyMass));
    Kaleng.SetNetworkOwner(undefined);

    wait(durasi + .15);
    const SuaraKena = new Instance("Sound");
    SuaraKena.SoundId = "rbxassetid://2303101209";
    SuaraKena.Volume = 2;
    SuaraKena.Parent = Workspace;
    SuaraKena.Play();

    kursi.utama.AssemblyLinearVelocity = new Vector3(30, 0, 3);
}

const KematianVIP = (kursi: Model & { Seat: Seat, utama: BasePart }, KarakterPemainKalah: Player["Character"], KarakterPemainMenang: Player["Character"]) => {
    const PistolClone = ReplicatedStorage.komponenKematian.Pistol.Clone();
    const SuaraEquip = PistolClone.Handle.GunEquip;
    SuaraEquip.Parent = Workspace;
    SuaraEquip.Play();

    PistolClone.Parent = KarakterPemainMenang;

    SuaraEquip.Ended.Wait();
    wait(1);
    const Tembakan = new Instance("Part", Workspace);
    Tembakan.BrickColor = new BrickColor("New Yeller");
    Tembakan.Transparency = .25;
    Tembakan.Anchored = true;
    Tembakan.CanCollide = false;

    const Distansi = PistolClone.TempatTembak.Position.sub(KarakterPemainKalah.Head.Position).Magnitude;
    Tembakan.Size = new Vector3(.1, .1, Distansi);
    Tembakan.CFrame = new CFrame(PistolClone.TempatTembak.Position, KarakterPemainKalah.Head.Position).mul(new CFrame(0, 0, -Distansi/2));
    const SuaraTembak = PistolClone.Handle.GunFire;
    SuaraTembak.Parent = Workspace;
    SuaraTembak.Play();

    Debris.AddItem(Tembakan, .2);
    kursi.utama.AssemblyLinearVelocity = new Vector3(60, 50, 0);
}

export function DapatinFungsiDariString(tipe: ContohKematian) {
    if(tipe === "meledak") return Meledak;
    if(tipe === "kembang_api") return Kembang_Api;
    if(tipe === "ditelan_kegelapan") return Ditelan_Kegelapan;
    if(tipe === "dilempar_kaleng") return Dilempar_Kaleng;
    if(tipe === "kematian_vip") return KematianVIP;
    return Meledak;
}

export default Kematian;