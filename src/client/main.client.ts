import { Players, ReplicatedStorage, StarterGui, TweenService } from '@rbxts/services';
import { Color, Move, Square, Posisi, Promosi, PieceSymbol, TipeMode } from 'shared/chess';
import Draggable from '../shared/draggable';

const MAX_RETRIES = 8

const RunService = game.GetService('RunService');
const UIS = game.GetService("UserInputService");

for(let i = 1; i < MAX_RETRIES; i++) {
	const [bisa, err] = pcall(() => {
		StarterGui.SetCore("ResetButtonCallback", false);
	});
	if(bisa) break;
	RunService.Stepped.Wait();
}
const CaturUI = ((script.Parent?.Parent as StarterGui).WaitForChild("Catur") as StarterGui["Catur"]).BackgroundCatur;
const Komponen_UI = (script.Parent?.Parent as StarterGui).WaitForChild("Komponen_UI") as Komponen_UI;
const Menu_UI = (script.Parent?.Parent as StarterGui).WaitForChild("Menu") as StarterGui["Menu"];
const Loading_UI = (script.Parent?.Parent as StarterGui).WaitForChild("Loading") as StarterGui["Loading"];
const Event = ReplicatedStorage.remote;
const Pemain = Players.LocalPlayer;
const Karakter = Pemain.Character || Pemain.CharacterAdded.Wait()[0];
const DataPemain = Pemain.WaitForChild("DataPemain") as Player["DataPemain"];

//Data catur thing
const KoneksiPapan: RBXScriptConnection[] = [];
const ListDariCheckFrame: Frame[] = [];
const SetelahTarukList: Frame[] = [];
const PosisiCatur: { [posisi: string]: { fungsiDrag: Draggable, warna: Color, Object: ImageLabel, gerakan: Move[], potongan: PieceSymbol } } = {};
let Papan: latar_belakang_putih | latar_belakang_hitam;
let PromosiFrame: Frame;
let NungguPromosi: { promosi?: Promosi, boleh: boolean };

const ConvertWarnaKeColor: { putih: Color, hitam: Color } = {
	putih: "w",
	hitam: "b"
}

Event.KirimSemuaGerakan.OnClientEvent.Connect((AwalTujuanPosisi: { awalPosisi: Square, tujuanPosisi: Square }, PosisiServer: Posisi[], gerakan: Map<Square, Move[]>, duluan: Color, apakahCheck?: { warna: Color, check: boolean }, skakmat?: { warna: Color, skak: boolean }, apakahSeri = false) => {
	PosisiCatur[AwalTujuanPosisi.tujuanPosisi] = PosisiCatur[AwalTujuanPosisi.awalPosisi];
	
	Papan[AwalTujuanPosisi.tujuanPosisi].GetChildren().forEach((v) => {
		if(v.GetAttribute("warna") === duluan) {
			v.Destroy();
			StarterGui.Suara.Ambil.Play();
		}
	});

	PosisiCatur[AwalTujuanPosisi.tujuanPosisi].Object.Parent = Papan[AwalTujuanPosisi.tujuanPosisi];
	delete PosisiCatur[AwalTujuanPosisi.awalPosisi];

	const KeysPosisiCaturClient: Square[] = []
	for(const [kunci, _] of pairs(PosisiCatur)) {
		KeysPosisiCaturClient.push(kunci as Square);
	}

	PosisiServer.forEach((v) => {
		if(KeysPosisiCaturClient.includes(v.square)) {
			KeysPosisiCaturClient.remove(KeysPosisiCaturClient.findIndex(d => d === v.square));
		}
	})

	const KeysPosisiServer: Square[] = PosisiServer.map((v) => v.square);
	for(const [tempat, _] of pairs(PosisiCatur)) {
		if(KeysPosisiServer.includes(tempat as Square)) {
			KeysPosisiServer.remove(KeysPosisiServer.findIndex(d => d === tempat));
		}
	}

	if(KeysPosisiServer.size() !== 0 && KeysPosisiServer.size() === KeysPosisiCaturClient.size()) {
		KeysPosisiCaturClient.forEach((v, i) => {
			PosisiCatur[KeysPosisiServer[i]] = PosisiCatur[v];
			PosisiCatur[KeysPosisiServer[i]].Object.Parent = Papan[KeysPosisiServer[i]];
			delete PosisiCatur[v];
		});
	}

	ListDariCheckFrame.forEach((v) => {
		v.Destroy();
	})
	ListDariCheckFrame.clear();

	for(const [posisi, dataPosisi] of pairs(PosisiCatur)) {
		if(dataPosisi.warna === duluan) {
			dataPosisi.fungsiDrag.Enable();
		} else {
			dataPosisi.fungsiDrag.Disable();
		}
		
		if(dataPosisi.warna === duluan && apakahCheck?.check && dataPosisi.potongan === "k") {
			const CheckFrame = ReplicatedStorage.komponen.CheckFrame.Clone();
			CheckFrame.Parent = dataPosisi.Object.Parent;
			ListDariCheckFrame.push(CheckFrame);
		}

		dataPosisi.gerakan = gerakan.get(posisi as Square)!;
	}

	if(apakahSeri) {
		CaturUI.SiapaDuluan.Text = "Draw!";
		CaturUI.SiapaDuluan.TextColor3 = new Color3(0, 0, 0);
		StarterGui.Suara.Mulai.Play();
	} else {
		if(skakmat?.skak) {
			CaturUI.SiapaDuluan.Text = skakmat.warna === "w" ? "White wins!" : "Black wins!";
			CaturUI.SiapaDuluan.TextColor3 = skakmat.warna === "w" ? new Color3(255, 255, 255) : new Color3(0, 0, 0);
	
			StarterGui.Suara.Mulai.Play();
		} else {
			CaturUI.SiapaDuluan.Text = duluan === "w" ? "White turns" : "Black turns";
			CaturUI.SiapaDuluan.TextColor3 = duluan === "w" ? new Color3(255, 255, 255) : new Color3(0, 0, 0);
		}
	}

	// UpdateUICatur(Posisi, gerakan, duluan, apakahCheck, skakmat, apakahSeri);
});

Event.KirimCaturUIKePemain.OnClientEvent.Connect((warna: "putih" | "hitam", mode: TipeMode, Posisi: Posisi[], gerakan: Map<Square, Move[]>, duluan: Color, pemain2?: { Pemain: Player, warna: Color, point: number }) => {
	const latar_belakang = warna === "hitam" ? Komponen_UI.latar_belakang_hitam : Komponen_UI.latar_belakang_putih;
	const FramePemain1 = CaturUI.Pemain1;
	const FramePemain2 = CaturUI.Pemain2;

	if(mode === "analisis") {
		FramePemain1.Visible = false;
		FramePemain2.Visible = false;
	}

	FramePemain1.Name = Pemain.Name;
    FramePemain1.Nama.Text = `${Pemain.Name} (${Pemain.DataPemain.DataPoint.Point.Value})`;
	
    if(pemain2 !== undefined) {
		FramePemain2.Name = pemain2.Pemain.Name;
		FramePemain2.Nama.Text = `${pemain2.Pemain.Name} (${pemain2.Pemain.DataPemain.DataPoint.Point.Value})`;
    }
    
    latar_belakang.GetChildren().forEach((v) => {
        if(v.IsA("Frame")) {
            v.BackgroundColor3 = v.GetAttribute("warna") === "hitam" ? Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard1.Value) : Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard2.Value); 
        }
    });
    
    const [GambarPemain1, apakahSiap1] = Players.GetUserThumbnailAsync(Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
    if(apakahSiap1) {
        FramePemain1.Foto.Image = GambarPemain1;
    }

    if(pemain2 !== undefined) {
        const [GambarPemain2, apakahSiap2] = Players.GetUserThumbnailAsync(pemain2?.Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
        if(apakahSiap2) {
            FramePemain2.Foto.Image = GambarPemain2;
        }
    }

	Papan = latar_belakang.Clone();
    // Papan = warna === "putih" ? Komponen_UI.latar_belakang_putih.Clone() : Komponen_UI.latar_belakang_hitam.Clone();
	CaturUI.SiapaDuluan.Visible = true;
	StarterGui.Suara.Mulai.Play();

	CaturUI.SiapaDuluan.Text = duluan === "w" ? "White turns" : "Black turns";

	const Potongan = ReplicatedStorage.komponen.Potongan.Clone();
	const FrameTaruk = Komponen_UI.SetelahTaruk.Clone();
    let PapanFrame: Frame;

	Posisi.forEach((v) => {
		let bagian: ImageLabel | undefined;
		if(v.type === "p") {
			bagian = v.color === "w" ? Potongan.P_putih.Clone() : Potongan.P_itam.Clone();
		} else if(v.type === "b") {
			bagian = v.color === "w" ? Potongan.B_putih.Clone() : Potongan.B_itam.Clone();
		} else if(v.type === "k") {
			bagian = v.color === "w" ? Potongan.K_putih.Clone() : Potongan.K_itam.Clone();
		} else if(v.type === "n") {
			bagian = v.color === "w" ? Potongan.Kn_putih.Clone() : Potongan.Kn_itam.Clone();
		} else if(v.type === "q") {
			bagian = v.color === "w" ? Potongan.Q_putih.Clone() : Potongan.Q_itam.Clone();
		} else if(v.type === "r") {
			bagian = v.color === "w" ? Potongan.R_putih.Clone() : Potongan.R_itam.Clone();
		}

		const FrameDrag = new Draggable(bagian!);
		const Bulatan: Instance[] = [];

		PosisiCatur[v.square] = { fungsiDrag: FrameDrag, Object: bagian!, warna: v.color, gerakan: gerakan.get(v.square)!, potongan: v.type };
		bagian!.Parent = Papan[v.square];

		FrameDrag.DragStarted = function () {
			if(PosisiCatur[FrameDrag.Object.Parent?.Name as Square].gerakan !== undefined) {
				PosisiCatur[FrameDrag.Object.Parent?.Name as Square].gerakan.forEach((gerakan_piece) => {
					if(!Papan[gerakan_piece.to].FindFirstChild("bulat")) {
						let FrameBulatan; 
						if(Papan[gerakan_piece.to].FindFirstChildWhichIsA("ImageLabel")) {
							FrameBulatan = ReplicatedStorage.komponen.MakanFrame.Clone();
						} else {
							FrameBulatan = ReplicatedStorage.komponen.bulat.Clone();
						}

						FrameBulatan.Parent = Papan[gerakan_piece.to];
						Bulatan.push(FrameBulatan);
					}
				});
			}
			
			FrameTaruk.Parent = bagian!.Parent;

			bagian!.ZIndex += 1;
		}

		FrameDrag.DragEnded = function() {
			if(PapanFrame !== undefined) {
				const AwalPosisi = bagian!.Parent;
				const TujuanPosisi = PapanFrame;

				bagian!.Position = new UDim2(0.5, 0, 0.5, 0);
				bagian!.ZIndex -= 1;
				
				if(PosisiCatur[FrameDrag.Object.Parent?.Name as Square].gerakan !== undefined) {
					if(PosisiCatur[FrameDrag.Object.Parent?.Name as Square].gerakan.map((v) => v.to)?.includes(TujuanPosisi.Name as Square)) {
						const PotonganCatur = TujuanPosisi.FindFirstChildWhichIsA("ImageLabel")
						if(PotonganCatur !== undefined) {
							const ClonePotonganCatur = ReplicatedStorage.komponen.Potongan.FindFirstChild(PotonganCatur!.Name)?.Clone();
							PotonganCatur!.Destroy();
							if(ClonePotonganCatur !== undefined && pemain2 !== undefined) {
								ClonePotonganCatur.Parent = (CaturUI.FindFirstChild(pemain2.Pemain.Name) as StarterGui["Catur"]["BackgroundCatur"]["Pemain1"]).Makan;
							}

							StarterGui.Suara.Ambil.Play();
						} else {
							StarterGui.Suara.Gerak.Play();
						}

						let ApakahMauPromosi = false;
						if((bagian!.GetAttribute("panggilan") as string).lower() === "p") {
							if(duluan === "w" && TujuanPosisi.Name.sub(2, 2) === "8") {
								PromosiFrame = Komponen_UI.PromosiPutih.Clone();
								PromosiFrame.Parent = TujuanPosisi;
								ApakahMauPromosi = true;
								NungguPromosi = { boleh: true };
							} else if(duluan === "b" && TujuanPosisi.Name.sub(2, 2) === "1") {
								PromosiFrame = Komponen_UI.PromosiHitam.Clone();
								PromosiFrame.Parent = TujuanPosisi;
								ApakahMauPromosi = true;
								NungguPromosi = { boleh: true };
							}
						}

						if(ApakahMauPromosi) {
							//Kenapa ada return??? tapi ya ndk papalah 14:25 13/12/2022
							const hasilpromosi = Event.KirimPromosiCatur.Event.Wait() as unknown as Promosi;

							if(hasilpromosi === "q") {
								bagian!.ImageRectOffset = duluan === "w" ? ReplicatedStorage.komponen.Potongan.Q_putih.ImageRectOffset : ReplicatedStorage.komponen.Potongan.Q_itam.ImageRectOffset;
							} else if(hasilpromosi === "b") {
								bagian!.ImageRectOffset = duluan === "w" ? ReplicatedStorage.komponen.Potongan.B_putih.ImageRectOffset : ReplicatedStorage.komponen.Potongan.B_itam.ImageRectOffset;
							} else if(hasilpromosi === "n") {
								bagian!.ImageRectOffset = duluan === "w" ? ReplicatedStorage.komponen.Potongan.Kn_putih.ImageRectOffset : ReplicatedStorage.komponen.Potongan.Kn_itam.ImageRectOffset;
							} else if(hasilpromosi === "r") {
								bagian!.ImageRectOffset = duluan === "w" ? ReplicatedStorage.komponen.Potongan.R_putih.ImageRectOffset : ReplicatedStorage.komponen.Potongan.R_itam.ImageRectOffset;
							}

							NungguPromosi = {...NungguPromosi, promosi: hasilpromosi }
						}

						bagian!.Parent = TujuanPosisi;
						
						for(const [_, dataPosisi] of pairs(PosisiCatur)) {
							dataPosisi.fungsiDrag.Disable();
						}

						if(SetelahTarukList.size() >= 2) {
							SetelahTarukList.shift()?.Destroy();
							SetelahTarukList.shift()?.Destroy();
						}
						
						const FrameTarukSelesai = StarterGui.Komponen_UI.SetelahTaruk.Clone();
						FrameTarukSelesai.Parent = TujuanPosisi;
						SetelahTarukList.push(FrameTarukSelesai);

						Event.GerakanCatur.FireServer(AwalPosisi?.Name, TujuanPosisi.Name, NungguPromosi?.promosi);
					}
				}
				
				Bulatan.forEach((bulat) => {
					bulat.Destroy();
				});
				Bulatan.clear();
			}
		}

		if(mode === "analisis") {
			if(v.color === duluan) {
				FrameDrag.Enable();
			}
		} else {
			if(v.color === ConvertWarnaKeColor[warna] && ConvertWarnaKeColor[warna] === duluan) {
				FrameDrag.Enable();
			}
		}
	});

	Papan.GetChildren().forEach((element) => {
		if(element.IsA("Frame")) {
			KoneksiPapan.push(element.MouseEnter.Connect(function(x, y) {
				PapanFrame = element;
			}));
		}
	});

	Papan.Parent = CaturUI.Frame;
	Potongan.Destroy();
});

Event.KirimWarnaBoard.Event.Connect((Nama: "Warna1" | "Warna2", warna: Color3) => {
	Menu_UI.MenuFrame.SettingsMenu.Frame[Nama].Warna.BackgroundColor3  = warna;
	Menu_UI.GerakanFrame.Folder.GetChildren().forEach((v) => {
		if(v.IsA("Frame")) {
			switch(Nama) {
				case "Warna1":
					v.BackgroundColor3 = v.Name === "hitam" ? warna : Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
					break;
				case "Warna2":
					v.BackgroundColor3 = v.Name === "hitam" ? Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) : warna;
					break;
			}
		}
	});
	
	Menu_UI.GerakanFrame.berikut.GetChildren().forEach((v) => {
		if(v.IsA("Frame")) {
			switch(Nama) {
				case "Warna1":
					v.BackgroundColor3 = v.Name === "hitam" ? warna : Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
					break;
				case "Warna2":
					v.BackgroundColor3 = v.Name === "hitam" ? Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) : warna;
					break;
			}
		}
	});

	Event.KirimDataWarnaBoard.FireServer(Nama === "Warna1" ? "hitam" : "putih", warna);
});

Event.KirimTerimaTolakUndanganUI.OnClientEvent.Connect((SiapaInvite: Player) => {
	// const KartuUndangan = Komponen_UI.KartuUndangan.Clone();
	// KartuUndangan.Position = new UDim2(1, 0, 1, 0);
	// KartuUndangan.NamaOrang.Text = SiapaInvite.Name;
	// KartuUndangan.Text.Text = `${SiapaInvite.Name} challenges to 1v1 classic game`;
	// KartuUndangan.ProfileOrang.Image = Players.GetUserThumbnailAsync(SiapaInvite.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)[0];

	// Menu_UI.MenuFrame.TerimaUndangan.GetChildren().forEach((undangan_element) => {
	// 	if(undangan_element.IsA("Frame")) {
	// 		const pos = UDim2.fromScale(0, undangan_element.Position.Y.Scale - .155);
	// 		TweenService.Create(undangan_element, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: pos }).Play();
	// 	}
	// });

	// KartuUndangan.Parent = Menu_UI.MenuFrame.TerimaUndangan;

	// KartuUndangan.Menolak.MouseButton1Click.Connect(() => {
	// 	const TweenHilang = TweenService.Create(KartuUndangan, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: new UDim2(1, 0, KartuUndangan.Position.Y.Scale + .1, 0) });
	// 	TweenHilang.Play();
	// 	TweenHilang.Completed.Connect(() => {
	// 		KartuUndangan.Destroy();
	// 	});
	// });

	// KartuUndangan.Terima.MouseButton1Click.Connect(() => {
	// 	print(Pemain,SiapaInvite);
	// 	Event.TeleportUndanganKeGame.FireServer(Pemain, SiapaInvite);
	// 	KartuUndangan.Destroy();
	// });

	// TweenService.Create(KartuUndangan, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: new UDim2(0, 0, .8, 0) }).Play();
	// const WaktuTween = TweenService.Create(KartuUndangan.Waktu, new TweenInfo(15, Enum.EasingStyle.Linear), { Size: new UDim2(0, 0, .05, 0) });
	// WaktuTween.Play();
	// WaktuTween.Completed.Wait()
	
	// const TweenHilang = TweenService.Create(KartuUndangan, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: new UDim2(1, 0, KartuUndangan.Position.Y.Scale + .1, 0) });
	// TweenHilang.Play();
	// TweenHilang.Completed.Connect(() => {
	// 	KartuUndangan.Destroy();
	// });
});

Event.TambahinUndangan.OnClientEvent.Connect((indikasi: string, SiapaInvite: Player) => {
	if(indikasi === "kirim invite") {
		const KartuUndangan = Komponen_UI.KartuUndangan.Clone();
		KartuUndangan.Position = new UDim2(1, 0, 1, 0);
		KartuUndangan.NamaOrang.Text = SiapaInvite.Name;
		KartuUndangan.Text.Text = `${SiapaInvite.Name} challenges to 1v1 classic game`;
		KartuUndangan.ProfileOrang.Image = Players.GetUserThumbnailAsync(SiapaInvite.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)[0];
	
		Menu_UI.MenuFrame.TerimaUndangan.GetChildren().forEach((undangan_element) => {
			if(undangan_element.IsA("Frame")) {
				const pos = UDim2.fromScale(0, undangan_element.Position.Y.Scale - .155);
				TweenService.Create(undangan_element, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: pos }).Play();
			}
		});
	
		KartuUndangan.Parent = Menu_UI.MenuFrame.TerimaUndangan;
	
		KartuUndangan.Menolak.MouseButton1Click.Connect(() => {
			Event.TambahinUndangan.FireServer("tolak invite", SiapaInvite)

			const TweenHilang = TweenService.Create(KartuUndangan, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: new UDim2(1, 0, KartuUndangan.Position.Y.Scale + .1, 0) });
			TweenHilang.Play();
			TweenHilang.Completed.Connect(() => {
				KartuUndangan.Destroy();
				Event.TambahinUndangan.FireServer("tolak invite", SiapaInvite)
			});
		});
	
		KartuUndangan.Terima.MouseButton1Click.Connect(() => {
			print(Pemain,SiapaInvite);
			// Event.TeleportUndanganKeGame.FireServer(Pemain, SiapaInvite);
			Event.TambahinUndangan.FireServer("terima invite", SiapaInvite);
			KartuUndangan.Destroy();
		});
	
		TweenService.Create(KartuUndangan, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: new UDim2(0, 0, .8, 0) }).Play();
		const WaktuTween = TweenService.Create(KartuUndangan.Waktu, new TweenInfo(15, Enum.EasingStyle.Linear), { Size: new UDim2(0, 0, .05, 0) });
		WaktuTween.Play();
		WaktuTween.Completed.Wait()
		
		const TweenHilang = TweenService.Create(KartuUndangan, new TweenInfo(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position: new UDim2(1, 0, KartuUndangan.Position.Y.Scale + .1, 0) });
		TweenHilang.Play();
		TweenHilang.Completed.Connect(() => {
			KartuUndangan.Destroy();
		});
	} else if(indikasi === "terima invite") {
		Loading_UI.Enabled = true;
		Loading_UI.LoadingFrame.LocalScript.Enabled = true;
		Loading_UI.LoadingFrame.Visible = false;
		Loading_UI.LoadingFrame.judul.Text = "Teleporting please wait...";

		let TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 1) })
		TweenHitam.Play();
		TweenHitam.Completed.Wait();
		
		Loading_UI.LoadingFrame.Visible = true;
		wait(.5)

		TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 0) })
		TweenHitam.Play();
		TweenHitam.Completed.Wait();
	} else if(indikasi === "tolak invite") {
		const TemplatePemain = Menu_UI.MenuFrame.UndanganMenu.TempatPemain.FindFirstChild(SiapaInvite.Name)! as Komponen_UI["KartuPemain"];
		if(TemplatePemain) {
			TemplatePemain.Undang.Text = "Invite";
		}
	}
});

Event.TeleportBalikKeGame.OnClientEvent.Connect((kode: string) => {
	Menu_UI.MenuFrame.TeleportKeGame.masuk.MouseButton1Click.Connect(() => {
		Event.TeleportBalikKeGame.FireServer(kode);
	});

	TweenService.Create(Menu_UI.MenuFrame.TeleportKeGame, new TweenInfo(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position: UDim2.fromScale(.425, .85) }).Play();
});

// Event.KirimUndanganTutupUIKePemain.OnClientEvent.Connect(() => {
// 	Loading_UI.Enabled = true;
// 	Loading_UI.LoadingFrame.LocalScript.Enabled = true;
// 	Loading_UI.LoadingFrame.Visible = false;
// 	Loading_UI.LoadingFrame.judul.Text = "Teleporting please wait...";

// 	let TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 1) })
// 	TweenHitam.Play();
// 	TweenHitam.Completed.Wait();
	
// 	Loading_UI.LoadingFrame.Visible = true;
// 	wait(.5)

// 	TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 0) })
// 	TweenHitam.Play();
// 	TweenHitam.Completed.Wait();
// });

Event.UpdateLeaderboard.OnClientEvent.Connect((Data: { Point: { key: string, value: unknown }[], Menang: { key: string, value: unknown }[], Kalah: { key: string, value: unknown }[], JumlahMain: { key: string, value: unknown }[] }) => {
	const TempatStatus = {
		Point: Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain,
		Menang: Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang,
		Kalah: Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah,
		JumlahMain: Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain,
	}

	for(const [Status, Informasi] of pairs(Data)) {
		TempatStatus[Status].GetChildren().forEach((v) => {
			if(v.IsA("Frame") && v.Name !== "PemainLeaderboard") {
				v.Destroy();
			}
		});

		let i = 1;
		Informasi.forEach((v) => {
			if(tonumber(v.key)! > 1) {
				const NamaPemain = Players.GetNameFromUserIdAsync(tonumber(v.key)!);
				
				if(!TempatStatus[Status].FindFirstChild(NamaPemain)) {
					const ContohLeaderboard = Komponen_UI.PemainLeaderboard.Clone();
					ContohLeaderboard.Nama.Text = NamaPemain;
					ContohLeaderboard.Nomor.Text = `${i}`;
					ContohLeaderboard.Point.Text = tostring(v.value);
					ContohLeaderboard.Name = NamaPemain;
					ContohLeaderboard.Parent = TempatStatus[Status];
					i++;
				}
			}
		});
	}
	// let i = 1;
	// Data.forEach((v) => {
	// 	if(tonumber(v.key)! > 1) {
	// 		const NamaPemain = Players.GetNameFromUserIdAsync(tonumber(v.key)!);
			
	// 		const ContohLeaderboard = Komponen_UI.PemainLeaderboard.Clone();
	// 		ContohLeaderboard.Nama.Text = NamaPemain;
	// 		ContohLeaderboard.Nomor.Text = `${i}`;
	// 		ContohLeaderboard.Point.Text = tostring(v.value);
	// 		ContohLeaderboard.Name = NamaPemain;
	// 		ContohLeaderboard.Parent = Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain;
	// 		i++;
	// 	}
	// });
});

const PosisiSemula: { [PosisiFrame: string]: UDim2 } = {
	TombolUndang: Menu_UI.MenuFrame.TombolFrame.Undang.Position,
	TombolBot: Menu_UI.MenuFrame.TombolFrame.MainBot.Position,
	TombolAnalisis: Menu_UI.MenuFrame.TombolFrame.Analisis.Position,
	TombolToko: Menu_UI.MenuFrame.TombolFrame.Toko.Position,
	TombolProfile: Menu_UI.MenuFrame.TombolFrame.Profile.Position,
	TombolSettings: Menu_UI.MenuFrame.TombolFrame.Settings.Position,
	TombolLeaderboard: Menu_UI.MenuFrame.TombolFrame.Leaderboard.Position,
	TombolFrame: Menu_UI.MenuFrame.TombolFrame.Position,
	UndanganMenu: Menu_UI.MenuFrame.UndanganMenu.Position,
	LeaderboardMenu: Menu_UI.MenuFrame.LeaderboardMenu.Position,
	SettingsMenu: Menu_UI.MenuFrame.SettingsMenu.Position,
	TokoMenu: Menu_UI.MenuFrame.TokoMenu.Position,
	ProfileMenu: Menu_UI.MenuFrame.ProfileMenu.Position,
	GerakanFrame: Menu_UI.GerakanFrame.Position
}

let apakahDimenu = true;
let PilihanMenu: Frame | undefined = undefined;
let ColorPickerDipilih: Frame | undefined;

//Tombol Undangan
Menu_UI.MenuFrame.TombolFrame.Undang.MouseButton1Click.Connect(() => {
	StarterGui.Suara.Klik.Play();
	if(PilihanMenu) {
		if(PilihanMenu.Name === "UndanganMenu") {
			TweenService.Create(Menu_UI.MenuFrame.UndanganMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.UndanganMenu.X.Scale + .65, 0, PosisiSemula.UndanganMenu.Y.Scale, 0,) }).Play();
			TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
			PilihanMenu = undefined;
			return;
		} else {
			const TweenLainnya = TweenService.Create(PilihanMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0,) });
			TweenLainnya.Play();
			TweenLainnya.Completed.Wait();
		}
	}

	PilihanMenu = Menu_UI.MenuFrame.UndanganMenu;
	TweenService.Create(Menu_UI.MenuFrame.UndanganMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.UndanganMenu.X.Scale - .65, 0, PosisiSemula.UndanganMenu.Y.Scale, 0,) }).Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();

});

Menu_UI.MenuFrame.TombolFrame.Undang.MouseEnter.Connect(() => {
	StarterGui.Suara.Tombol.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Undang, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolUndang.X.Scale + .08, 0, PosisiSemula.TombolUndang.Y.Scale, 0) }).Play();
});

Menu_UI.MenuFrame.TombolFrame.Undang.MouseLeave.Connect(() => {
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Undang, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolUndang.X.Scale, 0, PosisiSemula.TombolUndang.Y.Scale, 0) }).Play();
});

//Tombol Mainbot
Menu_UI.MenuFrame.TombolFrame.MainBot.MouseButton1Click.Connect(() => {
	StarterGui.Suara.Klik.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.75, Enum.EasingStyle.Back), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale - .5, 0, PosisiSemula.TombolFrame.Y.Scale, 0)}).Play();
	TweenService.Create(Menu_UI.MenuFrame.UndanganMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.UndanganMenu.X.Scale, 0, PosisiSemula.UndanganMenu.Y.Scale, 0) }).Play();
	TweenService.Create(Menu_UI.GerakanFrame, new TweenInfo(.25, Enum.EasingStyle.Linear), { Position: new UDim2(PosisiSemula.GerakanFrame.X.Scale, 0, -.5, 0) }).Play();
	apakahDimenu = false;
	Event.Mulai.FireServer("komputer");
});

Menu_UI.MenuFrame.TombolFrame.MainBot.MouseEnter.Connect(() => {
	StarterGui.Suara.Tombol.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.MainBot, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolBot.X.Scale + .08, 0, PosisiSemula.TombolBot.Y.Scale, 0) }).Play()
});

Menu_UI.MenuFrame.TombolFrame.MainBot.MouseLeave.Connect(() => {
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.MainBot, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolBot.X.Scale, 0, PosisiSemula.TombolBot.Y.Scale, 0) }).Play()
});

//Tombol Analisis
Menu_UI.MenuFrame.TombolFrame.Analisis.MouseButton1Click.Connect(() => {
	StarterGui.Suara.Klik.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.75, Enum.EasingStyle.Back), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale - .5, 0, PosisiSemula.TombolFrame.Y.Scale, 0)}).Play();
	TweenService.Create(Menu_UI.MenuFrame.UndanganMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.UndanganMenu.X.Scale, 0, PosisiSemula.UndanganMenu.Y.Scale, 0) }).Play();
	TweenService.Create(Menu_UI.GerakanFrame, new TweenInfo(.25, Enum.EasingStyle.Linear), { Position: new UDim2(PosisiSemula.GerakanFrame.X.Scale, 0, -.5, 0) }).Play();
	if(PilihanMenu) {
		TweenService.Create(PilihanMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0,) }).Play();
		PilihanMenu = undefined;
	}
	apakahDimenu = false;

	TweenService.Create(CaturUI, new TweenInfo(.3), { Position: UDim2.fromScale(0, 0) }).Play();
	Event.Mulai.FireServer("analisis");
});

Menu_UI.MenuFrame.TombolFrame.Analisis.MouseEnter.Connect(() => {
	StarterGui.Suara.Tombol.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Analisis, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolAnalisis.X.Scale + .08, 0, PosisiSemula.TombolAnalisis.Y.Scale, 0) }).Play()
});

Menu_UI.MenuFrame.TombolFrame.Analisis.MouseLeave.Connect(() => {
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Analisis, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolAnalisis.X.Scale, 0, PosisiSemula.TombolAnalisis.Y.Scale, 0) }).Play()
});

//Tombol Leaderboard
Menu_UI.MenuFrame.TombolFrame.Leaderboard.MouseButton1Click.Connect(() => {
	StarterGui.Suara.Klik.Play();
	if(PilihanMenu) {
		if(PilihanMenu.Name === "LeaderboardMenu") {
			TweenService.Create(Menu_UI.MenuFrame.LeaderboardMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.LeaderboardMenu.X.Scale + .65, 0, PosisiSemula.LeaderboardMenu.Y.Scale, 0,) }).Play();
			TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
			PilihanMenu = undefined;
			return;
		} else {
			const TweenLainnya = TweenService.Create(PilihanMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0,) });
			TweenLainnya.Play();
			TweenLainnya.Completed.Wait();
		}
	}

	PilihanMenu = Menu_UI.MenuFrame.LeaderboardMenu;
	TweenService.Create(Menu_UI.MenuFrame.LeaderboardMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.LeaderboardMenu.X.Scale - .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0) }).Play()
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
});

Menu_UI.MenuFrame.TombolFrame.Leaderboard.MouseEnter.Connect(() => {
	StarterGui.Suara.Tombol.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Leaderboard, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolLeaderboard.X.Scale + .08, 0, PosisiSemula.TombolLeaderboard.Y.Scale, 0) }).Play()
});

Menu_UI.MenuFrame.TombolFrame.Leaderboard.MouseLeave.Connect(() => {
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Leaderboard, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolLeaderboard.X.Scale, 0, PosisiSemula.TombolLeaderboard.Y.Scale, 0) }).Play()
});

//Tombol Profile
Menu_UI.MenuFrame.TombolFrame.Profile.MouseButton1Click.Connect(() => {
	StarterGui.Suara.Klik.Play();
	if(PilihanMenu) {
		if(PilihanMenu.Name === "ProfileMenu") {
			TweenService.Create(Menu_UI.MenuFrame.ProfileMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.ProfileMenu.X.Scale + .65, 0, PosisiSemula.ProfileMenu.Y.Scale, 0,) }).Play();
			TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
			PilihanMenu = undefined;
			return;
		} else {
			const TweenLainnya = TweenService.Create(PilihanMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0,) });
			TweenLainnya.Play();
			TweenLainnya.Completed.Wait();
		}
	}

	PilihanMenu = Menu_UI.MenuFrame.ProfileMenu;
	TweenService.Create(Menu_UI.MenuFrame.ProfileMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.ProfileMenu.X.Scale - .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0) }).Play()
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
});

Menu_UI.MenuFrame.TombolFrame.Profile.MouseEnter.Connect(() => {
	StarterGui.Suara.Tombol.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Profile, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolProfile.X.Scale + .08, 0, PosisiSemula.TombolProfile.Y.Scale, 0) }).Play()
});

Menu_UI.MenuFrame.TombolFrame.Profile.MouseLeave.Connect(() => {
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Profile, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolProfile.X.Scale, 0, PosisiSemula.TombolProfile.Y.Scale, 0) }).Play()
});

//Tombol Settings
Menu_UI.MenuFrame.TombolFrame.Settings.MouseButton1Click.Connect(() => {
	StarterGui.Suara.Klik.Play();
	if(PilihanMenu) {
		if(PilihanMenu.Name === "SettingsMenu") {
			TweenService.Create(Menu_UI.MenuFrame.SettingsMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.SettingsMenu.X.Scale + .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0) }).Play();
			TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
			PilihanMenu = undefined;
			return;
		} else {
			const TweenLainnya = TweenService.Create(PilihanMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0,) });
			TweenLainnya.Play();
			TweenLainnya.Completed.Wait();
		}
	}

	PilihanMenu = Menu_UI.MenuFrame.SettingsMenu;

	TweenService.Create(Menu_UI.MenuFrame.SettingsMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.SettingsMenu.X.Scale - .65, 0, PosisiSemula.SettingsMenu.Y.Scale, 0) }).Play()
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
});

Menu_UI.MenuFrame.TombolFrame.Settings.MouseEnter.Connect(() => {
	StarterGui.Suara.Tombol.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Settings, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolSettings.X.Scale + .08, 0, PosisiSemula.TombolSettings.Y.Scale, 0) }).Play()
});

Menu_UI.MenuFrame.TombolFrame.Settings.MouseLeave.Connect(() => {
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Settings, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolSettings.X.Scale, 0, PosisiSemula.TombolSettings.Y.Scale, 0) }).Play()
});

//Tombol Toko
Menu_UI.MenuFrame.TombolFrame.Toko.MouseButton1Click.Connect(() => {
	StarterGui.Suara.Klik.Play();
	if(PilihanMenu) {
		if(PilihanMenu.Name === "TokoMenu") {
			TweenService.Create(Menu_UI.MenuFrame.TokoMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TokoMenu.X.Scale + .65, 0, PosisiSemula.TokoMenu.Y.Scale, 0) }).Play();
			TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
			PilihanMenu = undefined;
			return;
		} else {
			const TweenLainnya = TweenService.Create(PilihanMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula[PilihanMenu.Name].X.Scale + .65, 0, PosisiSemula[PilihanMenu.Name].Y.Scale, 0,) });
			TweenLainnya.Play();
			TweenLainnya.Completed.Wait();
		}
	}

	PilihanMenu = Menu_UI.MenuFrame.TokoMenu;

	TweenService.Create(Menu_UI.MenuFrame.TokoMenu, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TokoMenu.X.Scale - .65, 0, PosisiSemula.TokoMenu.Y.Scale, 0) }).Play()
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame, new TweenInfo(.5, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolFrame.X.Scale - .1, 0, PosisiSemula.TombolFrame.Y.Scale, 0) }).Play();
});

Menu_UI.MenuFrame.TombolFrame.Toko.MouseEnter.Connect(() => {
	StarterGui.Suara.Tombol.Play();
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Toko, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolToko.X.Scale + .08, 0, PosisiSemula.TombolToko.Y.Scale, 0) }).Play()
});

Menu_UI.MenuFrame.TombolFrame.Toko.MouseLeave.Connect(() => {
	TweenService.Create(Menu_UI.MenuFrame.TombolFrame.Toko, new TweenInfo(.12, Enum.EasingStyle.Sine), { Position: new UDim2(PosisiSemula.TombolToko.X.Scale, 0, PosisiSemula.TombolToko.Y.Scale, 0) }).Play()
});

//Tombol Warna
Menu_UI.MenuFrame.SettingsMenu.Frame.Warna1.Warna.MouseButton1Click.Connect(() => {
	if(ColorPickerDipilih)
		ColorPickerDipilih.Destroy();
	const PilihWarna = Komponen_UI.ColorPickers.Clone();
	PilihWarna.ColorPickerLocal.Enabled = true;
	PilihWarna.Name = "Warna1"
	PilihWarna.Parent = Menu_UI.MenuFrame.SettingsMenu;

	ColorPickerDipilih = PilihWarna;
});

Menu_UI.MenuFrame.SettingsMenu.Frame.Warna2.Warna.MouseButton1Click.Connect(() => {
	if(ColorPickerDipilih)
		ColorPickerDipilih.Destroy();
	const PilihWarna = Komponen_UI.ColorPickers.Clone();
	PilihWarna.ColorPickerLocal.Enabled = true;
	PilihWarna.Name = "Warna2"
	PilihWarna.Parent = Menu_UI.MenuFrame.SettingsMenu;
	
	ColorPickerDipilih = PilihWarna;
});

//Tombol Leaderboard
Menu_UI.MenuFrame.LeaderboardMenu.WinPalingBanyak.MouseButton1Click.Connect(() => {
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = true;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = false;
});

Menu_UI.MenuFrame.LeaderboardMenu.LosePalingBanyak.MouseButton1Click.Connect(() => {
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = true;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = false;
});

Menu_UI.MenuFrame.LeaderboardMenu.MainPalingBanyak.MouseButton1Click.Connect(() => {
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = true;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = false;
});

Menu_UI.MenuFrame.LeaderboardMenu.PointPalingBanyak.MouseButton1Click.Connect(() => {
	Menu_UI.MenuFrame.LeaderboardMenu.TempatMenang.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatJumlahMain.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatKalah.Visible = false;
	Menu_UI.MenuFrame.LeaderboardMenu.TempatPemain.Visible = true;
});

coroutine.wrap(() => {
	const tween = TweenService.Create(Menu_UI.GerakanFrame, new TweenInfo(20, Enum.EasingStyle.Linear), { Position: new UDim2(-.5, 0, .5, 0) })
	while(true) {
		if(apakahDimenu) {
			Menu_UI.GerakanFrame.Position = new UDim2(.5, 0, .5, 0);
			tween.Play();
			tween.Completed.Wait();
		} else {
			wait(1);
		}
	}
})();

// if(!game.GetService("RunService").IsStudio()) {
	Loading_UI.Enabled = true;
	Loading_UI.LoadingFrame.LocalScript.Enabled = true;
	
	wait(3)
	
	let TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 1) })
	TweenHitam.Play();
	TweenHitam.Completed.Wait();
	
	Menu_UI.MenuFrame.SettingsMenu.Frame.Warna1.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value);
	Menu_UI.MenuFrame.SettingsMenu.Frame.Warna2.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
	
	Menu_UI.GerakanFrame.Folder.GetChildren().forEach((v) => {
		if(v.IsA("Frame")) {
			v.BackgroundColor3 = v.Name === "hitam" ? Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) : Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
		}
	});
	
	Menu_UI.GerakanFrame.berikut.GetChildren().forEach((v) => {
		if(v.IsA("Frame")) {
			v.BackgroundColor3 = v.Name === "hitam" ? Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) : Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
		}
	});

	// Menu_UI.Profile.Gambar.Image = Players.GetUserThumbnailAsync(Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)[0];
	// Menu_UI.Profile.Nama.Text = Pemain.Name;
	// Menu_UI.Profile.Point.Text = `Points: ${Pemain.DataPemain.DataPoint.Point.Value}`;
	// Menu_UI.Profile.Menang.Text = `Wins: ${Pemain.DataPemain.DataStatus.Menang.Value}`;
	// Menu_UI.Profile.Kalah.Text = `Lose: ${Pemain.DataPemain.DataStatus.Kalah.Value}`;
	
	Menu_UI.MenuFrame.ProfileMenu.Gambar.Image = Players.GetUserThumbnailAsync(Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)[0];
	Menu_UI.MenuFrame.ProfileMenu.Nama.Text = Pemain.Name;
	Menu_UI.MenuFrame.ProfileMenu.Point.Text = `Points: ${Pemain.DataPemain.DataPoint.Point.Value}`;
	Menu_UI.MenuFrame.ProfileMenu.Menang.Text = `Wins: ${Pemain.DataPemain.DataStatus.Menang.Value}`;
	Menu_UI.MenuFrame.ProfileMenu.Kalah.Text = `Lose: ${Pemain.DataPemain.DataStatus.Kalah.Value}`;
	Menu_UI.MenuFrame.ProfileMenu.JumlahMain.Text = `Total Played: ${Pemain.DataPemain.DataStatus.JumlahMain.Value}`;

	const ReverseTable = [];
	for(let i = Pemain.DataPemain.DataStatus.History.GetChildren().size() - 1; i >= 0; i--) {
		ReverseTable.push(Pemain.DataPemain.DataStatus.History.GetChildren()[i]);
	}

	ReverseTable.forEach((v) => {
		const Data = v as Player["DataPemain"]["DataStatus"]["History"]
		const TemplateHistory = Komponen_UI.PemainProfile.Clone();
		TemplateHistory.NamaPemain1.Text = `${Data.Pemain1.nama.Value} (${Data.Pemain1.point.Value})`;
		TemplateHistory.NamaPemain2.Text = `${Data.Pemain2.nama.Value} (${Data.Pemain2.point.Value})`;
		TemplateHistory.Status.Text = Data.YangMenang.Value === "w" ? "White" : Data.YangMenang.Value === "seri" ? "Draw" : "Black";
		TemplateHistory.Tanggal.Text = Data.Tanggal.Value;
		TemplateHistory.Parent = Menu_UI.MenuFrame.ProfileMenu.TempatHistory;
	});

	Loading_UI.LoadingFrame.Visible = false;
	wait(1);
	
	TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 0) })
	TweenHitam.Play();
	TweenHitam.Completed.Wait();
	
	Loading_UI.Enabled = false;
	Loading_UI.LoadingFrame.LocalScript.Enabled = false;
// } else {
// 	Menu_UI.MenuFrame.SettingsMenu.Frame.Warna1.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value);
// 	Menu_UI.MenuFrame.SettingsMenu.Frame.Warna2.Warna.BackgroundColor3 = Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
	
// 	Menu_UI.Profile.Gambar.Image = Players.GetUserThumbnailAsync(Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)[0];
// 	Menu_UI.Profile.Nama.Text = Pemain.Name;
// 	Menu_UI.Profile.Point.Text = `Points: ${Pemain.DataPemain.DataPoint.Point.Value}`;
// 	Menu_UI.Profile.Menang.Text = `Wins: ${Pemain.DataPemain.DataStatus.Menang.Value}`;
// 	Menu_UI.Profile.Kalah.Text = `Lose: ${Pemain.DataPemain.DataStatus.Kalah.Value}`;

// 	Menu_UI.GerakanFrame.Folder.GetChildren().forEach((v) => {
// 		if(v.IsA("Frame")) {
// 			v.BackgroundColor3 = v.Name === "hitam" ? Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) : Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
// 		}
// 	});
	
// 	Menu_UI.GerakanFrame.berikut.GetChildren().forEach((v) => {
// 		if(v.IsA("Frame")) {
// 			v.BackgroundColor3 = v.Name === "hitam" ? Color3.fromHex(DataPemain.DataSettings.WarnaBoard1.Value) : Color3.fromHex(DataPemain.DataSettings.WarnaBoard2.Value);
// 		}
// 	});
// }

coroutine.wrap(() => {
	while(true) {
		Players.GetPlayers().forEach((v) => {
			if(v.Name !== Pemain.Name) {
				const KartuPemain = Komponen_UI.KartuPemain.Clone();
				const [kontentGambar, apakahSiap] = Players.GetUserThumbnailAsync(v.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
				KartuPemain.Name = v.Name;
				KartuPemain.NamaPemain1.Text = v.Name;
				KartuPemain.Pemain1.Image = kontentGambar;
		
				KartuPemain.Undang.MouseButton1Click.Connect(() => {
					KartuPemain.Undang.Text = "Inviting...";
					Event.TambahinUndangan.FireServer("kirim invite", v);
				});
	
				KartuPemain.Parent = Menu_UI.MenuFrame.UndanganMenu.TempatPemain;
			}
		});

		wait(10);
		Menu_UI.MenuFrame.UndanganMenu.TempatPemain.GetChildren().forEach((v) => {
			v.Destroy();
		})
	}
})();

(script.Parent?.Parent as StarterGui).ScreenOrientation = Enum.ScreenOrientation.LandscapeRight;
UIS.ModalEnabled = true;

while(true) {
	const MusicPertama = StarterGui.Suara.SuaraBelakang.Pertama;
	MusicPertama.Play();
	MusicPertama.Ended.Wait();
	wait(3)

	const MusicKedua = StarterGui.Suara.SuaraBelakang.Kedua;
	MusicKedua.Play();
	MusicKedua.Ended.Wait();
	wait(3)

	const MusicKetiga = StarterGui.Suara.SuaraBelakang.Ketiga;
	MusicKetiga.Play();
	MusicKetiga.Ended.Wait();
	wait(3);
}