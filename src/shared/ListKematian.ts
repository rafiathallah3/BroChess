import { ReplicatedStorage, Workspace } from "@rbxts/services";

const Tween = game.GetService("TweenService");

const Kematian: { [Nama: string]: { NamaLain: string, Harga: number } } = {
    meledak: {
        NamaLain: "Explode",
        Harga: 150,
    },
    kembang_api: {
        NamaLain: "Firework",
        Harga: 200
    },
    ditelan_kegelapan: {
        NamaLain: "Into the darkness",
        Harga: 150
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

const Ditelan_Kegelapan = (kursi: Model & { Seat: Seat, utama: BasePart }, KarakterPemain: Player["Character"]) => {
    const Bulatan = ReplicatedStorage.komponenKematian.bulat.Clone();
    Bulatan.Position = kursi.utama.Position.add(new Vector3(0, -2, 0));
    Bulatan.Parent = kursi;

    const Batas = new Instance("Part");
    Batas.CFrame = KarakterPemain.HumanoidRootPart.CFrame.mul(new CFrame(0, -10, 0));
    Batas.Size = new Vector3(15, .2, 15);
    Batas.Transparency = 1;
    Batas.Parent = kursi

    const TweenBulataan = Tween.Create(Bulatan, new TweenInfo(1.5), { Size: new Vector3(0.1, 6, 6) });
    TweenBulataan.Play();
    TweenBulataan.Completed.Wait();

    KarakterPemain.HumanoidRootPart.Anchored = true;
    wait(.5);

    const TweenPemain = Tween.Create(KarakterPemain.HumanoidRootPart, new TweenInfo(3), { CFrame: KarakterPemain.HumanoidRootPart.CFrame.mul(new CFrame(0, -6, 0)) })
    TweenPemain.Play();
    TweenPemain.Completed.Wait();
    wait(.2);

    const TweenTutup = Tween.Create(Bulatan, new TweenInfo(1.5), { Size: new Vector3(0.1, 0.01, 0.01) })
    TweenTutup.Play();
    TweenTutup.Completed.Connect(() => { Bulatan.Destroy() });
}

const Dilempar_Kaleng = (kursi: Model & { Seat: Seat, utama: BasePart }, KarakterPemain: Player["Character"]) => {
    const DariLempar = ReplicatedStorage.komponenKematian.DariKaleng.Clone();
    DariLempar.Parent = Workspace;

    const arah = KarakterPemain.Head.Position.sub(DariLempar.Position);
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

export function DapatinFungsiDariString(tipe: ContohKematian) {
    if(tipe === "meledak") return Meledak;
    if(tipe === "kembang_api") return Kembang_Api;
    if(tipe === "ditelan_kegelapan") return Ditelan_Kegelapan;
    if(tipe === "dilempar_kaleng") return Dilempar_Kaleng;
    return Meledak;
}

export default Kematian;