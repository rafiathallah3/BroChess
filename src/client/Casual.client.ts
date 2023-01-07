import { Players, ReplicatedStorage, TweenService, StarterGui, Workspace, TeleportService, ServerScriptService } from "@rbxts/services";
import { Color, Move, PieceSymbol, Promosi, Posisi, Square, TipePemain, Chess, TipeGameSelesai, TipeMode, TipeRatingPemain } from "shared/chess";
import Draggable from "shared/draggable";

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
const Loading_UI = (script.Parent?.Parent as StarterGui).WaitForChild("Loading") as StarterGui["Loading"];
const Menang_UI = (script.Parent?.Parent as StarterGui).WaitForChild("Menang") as StarterGui["Menang"];
const Event = ReplicatedStorage.remote;

const Pemain = Players.LocalPlayer;
const Karakter = Pemain.Character || Pemain.CharacterAdded.Wait();
const Humanoid = Karakter.WaitForChild("Humanoid") as Player["Character"]["Humanoid"];
const Kamera = Workspace.CurrentCamera!;
const Mouse = Pemain.GetMouse();

const ListDariCheckFrame: Frame[] = [];
const SetelahTarukList: Frame[] = [];
const ListBulatanKlikKanan: ImageLabel[] = [];
const ListArrow: Frame[] = []
const PosisiCatur: { [posisi: string]: { fungsiDrag: Draggable, warna: Color, Object: ImageLabel, gerakan: Move[], potongan: PieceSymbol } } = {};
let Papan: latar_belakang_putih | latar_belakang_hitam;
let PromosiFrame: Frame;
let NungguPromosi: { promosi?: Promosi, boleh: boolean };
let PapanFrame: Frame;
let FrameTaruk: Frame;

// Sumber https://devforum.roblox.com/t/converting-secs-to-hsec/146352 25/12/2022 22:53
function convertToHMS(Seconds: number) {
	const decimal = tonumber(string.format("%.1f", math.modf(Seconds)[1]))!;
	if(Seconds <= 30) {
		return string.format("%02i:%02i.%s", Seconds/60%60, Seconds%60, decimal*10)
	}
		
	return string.format("%02i:%02i", Seconds/60%60, Seconds%60);
}

function UpdateCaturUI(warna: Color, Posisi: Posisi[], gerakan: Map<Square, Move[]>, duluan: Color, apakahCheck?: { warna: Color, check: boolean }, pemain2?: { Pemain: Player, warna: Color, point: number }): void {
	Papan.GetDescendants().forEach((v) => {
		if(v.IsA("ImageLabel")) {
			v.Destroy();
		}
	});

	const Potongan = ReplicatedStorage.komponen.Potongan.Clone();
	const Bulatan: Instance[] = [];
	let BuahCatur: ImageLabel;

	function PindahPosisi(bagian: ImageLabel, FrameDrag: Draggable, AwalPosisi: Frame, TujuanPosisi: Frame) {
		if(gerakan.get(AwalPosisi!.Name as Square) !== undefined) {
			if(gerakan.get(AwalPosisi!.Name as Square)!.map((v) => v.to)?.includes(TujuanPosisi.Name as Square)) {
				const PotonganCatur = TujuanPosisi.FindFirstChildWhichIsA("ImageLabel")
				if(PotonganCatur !== undefined) {
					const ClonePotonganCatur = ReplicatedStorage.komponen.Potongan.FindFirstChild(PotonganCatur!.Name)?.Clone();
					PotonganCatur!.Destroy();
					if(ClonePotonganCatur !== undefined) {
						ClonePotonganCatur.Parent = (CaturUI.FindFirstChild(Pemain.Name) as StarterGui["Catur"]["BackgroundCatur"]["Pemain1"]).Makan;
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
				
				FrameDrag.Disable();

				Bulatan.forEach((bulat) => {
					bulat.Destroy();
				});
				Bulatan.clear();

				Event.GerakanCatur.FireServer(AwalPosisi?.Name, TujuanPosisi.Name, NungguPromosi?.promosi);
			}
		}
		
		if(AwalPosisi.Name !== TujuanPosisi.Name) {
			Bulatan.forEach((bulat) => {
				bulat.Destroy();
			});
			Bulatan.clear();
		}
	}

	Posisi.forEach((v) => {
		let bagian: ImageLabel;
		if(v.type === "p") {
			bagian = v.color === "w" ? Potongan.P_putih.Clone() : Potongan.P_itam.Clone();
		} else if(v.type === "b") {
			bagian = v.color === "w" ? Potongan.B_putih.Clone() : Potongan.B_itam.Clone();
		} else if(v.type === "k") {
			bagian = v.color === "w" ? Potongan.K_putih.Clone() : Potongan.K_itam.Clone();
			if(apakahCheck !== undefined && apakahCheck.warna === v.color && apakahCheck.check) {
				const CheckFrame = ReplicatedStorage.komponen.CheckFrame.Clone();
				CheckFrame.Parent = Papan[v.square];
				ListDariCheckFrame.push(CheckFrame);
			}
		} else if(v.type === "n") {
			bagian = v.color === "w" ? Potongan.Kn_putih.Clone() : Potongan.Kn_itam.Clone();
		} else if(v.type === "q") {
			bagian = v.color === "w" ? Potongan.Q_putih.Clone() : Potongan.Q_itam.Clone();
		} else if(v.type === "r") {
			bagian = v.color === "w" ? Potongan.R_putih.Clone() : Potongan.R_itam.Clone();
		}

		const FrameDrag = new Draggable(bagian!);

		PosisiCatur[v.square] = { fungsiDrag: FrameDrag, Object: bagian!, warna: v.color, gerakan: gerakan.get(v.square)!, potongan: v.type };
		bagian!.Parent = Papan[v.square];

		FrameDrag.DragStarted = function () {
			Bulatan.forEach((bulat) => {
				bulat.Destroy();
			});
			Bulatan.clear();

			if(gerakan.get(bagian!.Parent?.Name as Square) !== undefined) {
				gerakan.get(bagian?.Parent?.Name as Square)!.forEach((gerakan_piece) => {
					if(!Papan[gerakan_piece.to].FindFirstChild("bulat")) {
						let FrameBulatan: Frame; 
						if(Papan[gerakan_piece.to].FindFirstChildWhichIsA("ImageLabel")) {
							FrameBulatan = ReplicatedStorage.komponen.MakanFrame.Clone();
						} else {
							FrameBulatan = ReplicatedStorage.komponen.bulat.Clone();
						}

						FrameBulatan.InputBegan.Connect((v) => {
							if(v.UserInputType === Enum.UserInputType.MouseButton1 || v.UserInputType === Enum.UserInputType.Touch) {
								const AwalPosisi = bagian.Parent! as Frame;
								const TujuanPosisi = FrameBulatan.Parent! as Frame;
								
								PindahPosisi(bagian!, FrameDrag, AwalPosisi, TujuanPosisi);
							}
						})

						FrameBulatan.Parent = Papan[gerakan_piece.to];
						Bulatan.push(FrameBulatan);
					}
				});
			}
			
			if(FrameTaruk !== undefined) {
				FrameTaruk.Destroy();
			}
			if(!bagian?.Parent?.FindFirstChild("SetelahTaruk")) {
				FrameTaruk = Komponen_UI.SetelahTaruk.Clone();
				FrameTaruk.Parent = bagian?.Parent;
			}

			bagian!.ZIndex += 1;
			BuahCatur = bagian!;
		}

		FrameDrag.DragEnded = function() {
			if(PapanFrame !== undefined) {
				const AwalPosisi = bagian.Parent as Frame;
				const TujuanPosisi = PapanFrame as Frame;

				bagian!.Position = new UDim2(0.5, 0, 0.5, 0);
				bagian!.ZIndex -= 1;

				PindahPosisi(bagian, FrameDrag, AwalPosisi, TujuanPosisi);
			}
		}

		if(v.color === warna && warna === duluan) {
			FrameDrag.Enable();
		}
	});

	Potongan.Destroy();
}

function drawLineFromTwoPoints(pointA: Vector2, pointB: Vector2) {
	const lineFrame = new Instance("Frame")
	lineFrame.BackgroundColor3 = new Color3(0.25098, 0.639216, 1)

	lineFrame.Size = UDim2.fromOffset(
		math.sqrt((pointA.X - pointB.X) ** 2 + (pointA.Y - pointB.Y) ** 2), 
		12
	)
	lineFrame.Position = UDim2.fromOffset(
		(pointA.X + pointB.X) / 2, 
		(pointA.Y + pointB.Y) / 2 + 35
	)
	lineFrame.Rotation = math.deg(math.atan2(
		(pointA.Y - pointB.Y), (pointA.X - pointB.X)
	))

	lineFrame.AnchorPoint = new Vector2(.5, .5)
	lineFrame.BorderSizePixel = 1
	lineFrame.Parent = CaturUI;
	
	const Panah = new Instance("ImageLabel");
	Panah.BackgroundTransparency = 1;
	Panah.Size = new UDim2(0, 40, 0, 30);
	Panah.Position = new UDim2(0, -30, 0, -10);
	Panah.Image = "rbxassetid://788089696";
	Panah.Rotation = -90;
	Panah.ImageColor3 = new Color3(0.25098, 0.639216, 1);
	Panah.Parent = lineFrame
	
	const uicorner = new Instance("UICorner");
	uicorner.CornerRadius = new UDim(1, 0);
	uicorner.Parent = lineFrame;

	return lineFrame
}

function drawLineUI(Posisi1: Frame, Posisi2: Frame) {
	const posA = Posisi1.AbsolutePosition.add((Posisi1.AbsoluteSize.mul(new Vector2(.5, .5))));
	const posB = Posisi2.AbsolutePosition.add((Posisi2.AbsoluteSize.mul(new Vector2(.5, .5))));
	// const posB = new Vector2(Mouse.X, Mouse.Y);

	return drawLineFromTwoPoints(posA, posB)
}

/*
local pemain = game.Players.LocalPlayer;
local mouse = pemain:GetMouse();

local gui = script.Parent

local Atan2 = math.atan2
local Pi = math.pi
local Abs = math.abs
local Sqrt = math.sqrt
local Deg = math.deg

local VECTOR2_HALF = Vector2.new(0.5, 0.5)
local lineFrame;

local function drawLineFromTwoPoints(pointA, pointB)
	-- These found from: https://devforum.roblox.com/t/drawing-a-line-between-two-points-in-2d/717808/2
	-- Size: sqrt((x1-x2)^2+(y1-y2)^2)
	-- Pos: ((x1+x2)/2,(y1+y2)/2)
	
	lineFrame = Instance.new("Frame")
	lineFrame.BackgroundColor3 = Color3.new(0.25098, 0.639216, 1)

	lineFrame.Size = UDim2.fromOffset(
		Sqrt((pointA.X - pointB.X) ^ 2 + (pointA.Y - pointB.Y) ^ 2), 
		12
	)
	lineFrame.Position = UDim2.fromOffset(
		(pointA.X + pointB.X) / 2, 
		(pointA.Y + pointB.Y) / 2
	)
	lineFrame.Rotation = Deg(Atan2(
		(pointA.Y - pointB.Y), (pointA.X - pointB.X)
		))

	lineFrame.AnchorPoint = VECTOR2_HALF
	lineFrame.BorderSizePixel = 1
	lineFrame.Parent = script.Parent
	
	local Panah = Instance.new("ImageLabel");
	Panah.BackgroundTransparency = 1;
	Panah.Size = UDim2.new(0, 40, 0, 30);
	Panah.Position = UDim2.new(0, -30, 0, -10);
	Panah.Image = "rbxassetid://788089696";
	Panah.Rotation = -90;
	Panah.ImageColor3 = Color3.new(0.25098, 0.639216, 1);
	Panah.Parent = lineFrame
	
	local uicorner = Instance.new("UICorner");
	uicorner.CornerRadius = UDim.new(1, 0);
	uicorner.Parent = lineFrame;
end

function drawLineUI(obj1, obj2)
	-- Get center regardless of anchor point
	local posA = obj1.AbsolutePosition + (obj1.AbsoluteSize * VECTOR2_HALF)
	local posB = Vector2.new(mouse.X, mouse.Y);
	--local posB = obj2.AbsolutePosition + (obj2.AbsoluteSize * VECTOR2_HALF)

	return drawLineFromTwoPoints(posA, posB)
end

mouse.Move:Connect(function()
	if(lineFrame) then	
		lineFrame:Destroy();
	end
	drawLineUI(script.Parent.Frame1);
end)
--drawLineUI(script.Parent.Frame1, script.Parent.Frame2)

--task.wait(3);
--print(mouse.X, mouse.Y);
*/

Event.KirimPemulaianCaturUIKePemain.OnClientEvent.Connect((RatingPemain: TipeRatingPemain) => {
	StarterGui.SetCore("ChatMakeSystemMessage", {
		Text: `Win: ${RatingPemain.Menang.SelisihRating} Draw: ${RatingPemain.Seri.SelisihRating} Lose: ${RatingPemain.Kalah.SelisihRating}`
	});
	StarterGui.SetCore("ChatMakeSystemMessage", {
		Text: `If your opponent hasn't moved in 60 seconds, The match automatically ended`
	});

    let TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 1) })
    TweenHitam.Play();
    TweenHitam.Completed.Wait();

    Loading_UI.LoadingFrame.Visible = false;
    wait(1);

    TweenHitam = TweenService.Create(Loading_UI.ScreenHITAM, new TweenInfo(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size: UDim2.fromScale(1, 0) })
    TweenHitam.Play();
    TweenHitam.Completed.Wait();

    Loading_UI.Enabled = false;
    Loading_UI.LoadingFrame.LocalScript.Enabled = false;
    Loading_UI.LoadingFrame.Visible = true;

	CaturUI.Menyerah.MouseButton1Click.Connect(() => {
		Event.Menyerah.FireServer();
	});

	CaturUI.Seri.MouseButton1Click.Connect(() => {
		Event.Seri.FireServer("ajak seri");
	});

	wait(2);

	const TweenCatur = TweenService.Create(CaturUI, new TweenInfo(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position: UDim2.fromScale(0, 0) })
	TweenCatur.Play();
	TweenCatur.Completed.Wait();

	wait(.5)
	CaturUI.prediksi.Text = `You have ${RatingPemain.prediksi}% chances to win`
});

Event.KirimCaturUIKePemain.OnClientEvent.Connect((warna: Color, mode: TipeMode, Posisi: Posisi[], gerakan: Map<Square, Move[]>, duluan: Color, pemain2?: { Pemain: Player, warna: Color, point: number }, waktu?: number) => {
	const latar_belakang = warna === "b" ? Komponen_UI.latar_belakang_hitam : Komponen_UI.latar_belakang_putih;
	const FramePemain1 = CaturUI.Pemain1;
	const FramePemain2 = CaturUI.Pemain2;

	if(mode === "analisis") {
		FramePemain1.Visible = false;
		FramePemain2.Visible = false;
	}

	FramePemain1.Name = Pemain.Name;
    FramePemain1.Nama.Text = `${Pemain.Name} (${Pemain.DataPemain.DataPoint.Point.Value})`;
	if(waktu)
		FramePemain1.Waktu.Text = convertToHMS(waktu);
	
    if(pemain2 !== undefined) {
		FramePemain2.Name = pemain2.Pemain.Name;
		FramePemain2.Nama.Text = `${pemain2.Pemain.Name} (${pemain2.Pemain.DataPemain.DataPoint.Point.Value})`;
		if(waktu)
			FramePemain2.Waktu.Text = convertToHMS(waktu);
    }
    
    latar_belakang.GetChildren().forEach((v) => {
        if(v.IsA("Frame")) {
            v.BackgroundColor3 = v.GetAttribute("warna") === "hitam" ? Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard1.Value) : Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard2.Value); 
			v.GetChildren().forEach((d) => {
				if(d.IsA("TextLabel")) {
					d.TextColor3 = v.GetAttribute("warna") === "hitam" ? Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard2.Value) : Color3.fromHex(Pemain.DataPemain.DataSettings.WarnaBoard1.Value);
				}
			});
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
	let AwalMulaArrow: Frame;
	let ApakahArrow = false;
	let BulatKlikKanan: ImageLabel | undefined;
	let Arrow: Frame | undefined;

	Papan.GetChildren().forEach((element) => {
		if(element.IsA("Frame")) {
			element.InputBegan.Connect((input) => {
				if(input.UserInputType === Enum.UserInputType.MouseButton2) {
					ApakahArrow = true;
					AwalMulaArrow = element;

					if(!PapanFrame.FindFirstChild("BulatKlikKanan")) {
						BulatKlikKanan = Komponen_UI.BulatKlikKanan.Clone();
						BulatKlikKanan.Parent = PapanFrame;
						ListBulatanKlikKanan.push(BulatKlikKanan);
					} else {
						PapanFrame.FindFirstChild("BulatKlikKanan")?.Destroy();
					}
				}

				if(input.UserInputType === Enum.UserInputType.MouseButton1) {
					if(!ApakahArrow) {
						if(BulatKlikKanan) {
							BulatKlikKanan.Destroy();
							BulatKlikKanan = undefined;
						}
						ListBulatanKlikKanan.forEach((v) => {
							v.Destroy();
						});
						ListBulatanKlikKanan.clear();

						ListArrow.forEach((v) => {
							v.Destroy();
						});
						ListArrow.clear();
					}
				}
			});

			element.InputEnded.Connect((input) => {
				if(input.UserInputType === Enum.UserInputType.MouseButton2) {
					ApakahArrow = false;
					if(Arrow) {
						ListArrow.push(Arrow);
						Arrow = undefined;
					}
					// if(BulatKlikKanan) {
					// 	BulatKlikKanan.Destroy();
					// 	BulatKlikKanan = undefined;
					// }
				}
			});

			element.MouseEnter.Connect(() => {
				PapanFrame = element;
				
				if(ApakahArrow) {
					if(Arrow) {
						Arrow.Destroy();
					}
					if(BulatKlikKanan) {
						if(AwalMulaArrow.Name !== element.Name) {
							BulatKlikKanan.Visible = false;
						} else {
							BulatKlikKanan.Visible = true;
						}
					}

					if(AwalMulaArrow.Name !== element.Name)
						Arrow = drawLineUI(AwalMulaArrow, element);
				}
			});
		}
	});

	CaturUI.SiapaDuluan.Visible = true;
	StarterGui.Suara.Mulai.Play();

	CaturUI.SiapaDuluan.Text = duluan === "w" ? "White turns" : "Black turns";

	UpdateCaturUI(warna, Posisi, gerakan, duluan, undefined, pemain2);

	Papan.Parent = CaturUI.Frame;
});

Event.KirimSemuaGerakan.OnClientEvent.Connect((WarnaPemain: Color, Pemain2: TipePemain | undefined, AwalTujuanPosisi: { awalPosisi: Square, tujuanPosisi: Square }, PosisiServer: Posisi[], gerakan: Map<Square, Move[]>, duluan: Color, ApakahGameSelesai: [boolean, "draw" | "skakmat" | "waktuhabis" | undefined, "w" | "b" | undefined], apakahCheck: { warna: Color, check: boolean }) => {
	if(FrameTaruk) FrameTaruk.Destroy();
	SetelahTarukList.forEach((v) => {
		v.Destroy();
	});
	SetelahTarukList.clear();

	const FrameTaruk1 = Komponen_UI.SetelahTaruk.Clone();
	const FrameTaruk2 = Komponen_UI.SetelahTaruk.Clone();
	FrameTaruk1.Parent = Papan[AwalTujuanPosisi.awalPosisi];
	FrameTaruk2.Parent = Papan[AwalTujuanPosisi.tujuanPosisi];
	SetelahTarukList.push(FrameTaruk1);
	SetelahTarukList.push(FrameTaruk2);

	ListDariCheckFrame.forEach((v) => {
		v.Destroy();
	})
	ListDariCheckFrame.clear();
	
	if(Pemain2 !== undefined) {
		Papan[AwalTujuanPosisi.tujuanPosisi].GetChildren().forEach((v) => {
			if(v.GetAttribute("warna") === duluan) {
				const PotonganCatur = ReplicatedStorage.komponen.Potongan.FindFirstChild(v.Name)?.Clone();
				if(PotonganCatur !== undefined) {
					PotonganCatur.Parent = (CaturUI.FindFirstChild(Pemain2?.Pemain.Name) as StarterGui["Catur"]["BackgroundCatur"]["Pemain1"]).Makan;
				}
	
				v.Destroy();
				StarterGui.Suara.Ambil.Play();
			}
		});
	}

	UpdateCaturUI(WarnaPemain, PosisiServer, gerakan, duluan, apakahCheck);

	const [ApakahSelesai, StatusSelesai, SiapaMenang] = ApakahGameSelesai;
	if(ApakahSelesai) {
		if(StatusSelesai === "draw") {
			CaturUI.SiapaDuluan.Text = "Draw!";
			CaturUI.SiapaDuluan.TextColor3 = Color3.fromRGB(70, 70, 70);
		} else if(StatusSelesai === "skakmat") {
			CaturUI.SiapaDuluan.Text = SiapaMenang === "w" ? "White wins!" : "Black wins!";
			CaturUI.SiapaDuluan.TextColor3 = SiapaMenang === "w" ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(0, 0, 0);
		}

		StarterGui.Suara.Mulai.Play();

		wait(3);

		const TweenCatur = TweenService.Create(CaturUI, new TweenInfo(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position: UDim2.fromScale(0, 1) })
		TweenCatur.Play();
		TweenCatur.Completed.Wait();
	} else {
		CaturUI.SiapaDuluan.Text = duluan === "w" ? "White turns" : "Black turns";
		CaturUI.SiapaDuluan.TextColor3 = duluan === "w" ? new Color3(255, 255, 255) : new Color3(0, 0, 0);
	}
});

Event.Seri.OnClientEvent.Connect((isntruksi: "tunjukkin" | "terima seri" | "tolak seri", SiapaYangNgeDraw: Player) => {
	if(isntruksi === "tunjukkin") {
		CaturUI.SeriUI.Visible = true;
	
		CaturUI.SeriUI.Terima.MouseButton1Click.Connect(() => {
			Event.Seri.FireServer("terima seri", SiapaYangNgeDraw);
		});
	
		CaturUI.SeriUI.Tolak.MouseButton1Click.Connect(() => {
			CaturUI.SeriUI.Visible = false;
			Event.Seri.FireServer("tolak seri", SiapaYangNgeDraw);
		});
	} else if(isntruksi === "terima seri") {
		CaturUI.SeriUI.Visible = false;
	} else if(isntruksi === "tolak seri") {
		StarterGui.SetCore("ChatMakeSystemMessage", {
			Text: `Your opponent decline to draw`
		});
	}
});

Event.KirimCaturPemenang.OnClientEvent.Connect((Pemenang: Color | "seri") => {
	CaturUI.SiapaDuluan.Text = Pemenang === "w" ? "White wins!" : Pemenang === "seri" ? "Draw!" : "Black wins!";
	CaturUI.SiapaDuluan.TextColor3 = Pemenang === "w" ? Color3.fromRGB(255, 255, 255) : Pemenang === "seri" ? Color3.fromRGB(70, 70, 70) : Color3.fromRGB(0, 0, 0);

	for(const [_, dataPosisi] of pairs(PosisiCatur)) {
		dataPosisi.fungsiDrag.Disable();
	}

	StarterGui.Suara.Mulai.Play();

	wait(3);

	const TweenCatur = TweenService.Create(CaturUI, new TweenInfo(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position: UDim2.fromScale(0, 1) })
	TweenCatur.Play();
	TweenCatur.Completed.Wait();
});

Event.TunjukkinMenangUI.OnClientEvent.Connect((warna: Color, point: number, jumlahPoint: number, CaturPemain: { p1: TipePemain, p2: TipePemain }, ApakahGameSelesai: TipeGameSelesai) => {
	const [_, StatusSelesai, SiapaPemenang] = ApakahGameSelesai;

	Menang_UI.Frame.NamaPemain1.Text = CaturPemain.p1.Pemain.Name;
	Menang_UI.Frame.NamaPemain2.Text = CaturPemain.p2.Pemain.Name;

	const [GambarPemain1, apakahSiap1] = Players.GetUserThumbnailAsync(CaturPemain.p1.Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
	if(apakahSiap1) {
		Menang_UI.Frame.GambarPemain1.Image = GambarPemain1;
	}

	const [GambarPemain2, apakahSiap2] = Players.GetUserThumbnailAsync(CaturPemain.p2.Pemain.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
	if(apakahSiap2) {
		Menang_UI.Frame.GambarPemain2.Image = GambarPemain2;
	}
	Menang_UI.Frame.GambarPemain1.Name = `Gambar_${CaturPemain.p1.warna}`;
	Menang_UI.Frame.GambarPemain2.Name = `Gambar_${CaturPemain.p2.warna}`;

	Menang_UI.Frame.Point.Text = tostring(jumlahPoint);

	if(StatusSelesai === "draw") {
		Menang_UI.Frame.Status.BackgroundColor3 = Color3.fromRGB(152, 152, 152);
		Menang_UI.Frame.Status.Menang_Kalah.Text = "Draw!";
		Menang_UI.Frame.Status.Alasan.Text = SiapaPemenang!; //Ini sebenarnya untuk alasan draw jadi jangan bingung rafi masa depan 01/01/2023 19:10
	} else if(SiapaPemenang === warna) {
		Menang_UI.Frame.Status.BackgroundColor3 = Color3.fromRGB(97, 255, 94);
		Menang_UI.Frame.Status.Menang_Kalah.Text = "You won!";
		Menang_UI.Frame.Status.Alasan.Text = StatusSelesai === "skakmat" ? "By checkmate" : StatusSelesai === "waktuhabis" ? "No time" : StatusSelesai === "menyerah" ? "Resignation" : "Player left";
		(Menang_UI.Frame.FindFirstChild(`Gambar_${warna}`)! as ImageLabel).BorderSizePixel = 2;
	} else if(SiapaPemenang !== warna) {
		Menang_UI.Frame.Status.BackgroundColor3 = Color3.fromRGB(152, 152, 152);
		Menang_UI.Frame.Status.Menang_Kalah.Text = "You lose!";
		Menang_UI.Frame.Status.Alasan.Text = StatusSelesai === "skakmat" ? "By checkmate" : StatusSelesai === "waktuhabis" ? "No time" : StatusSelesai === "menyerah" ? "Resignation" : "Player left";
		(Menang_UI.Frame.FindFirstChild(`Gambar_${SiapaPemenang}`)! as ImageLabel).BorderSizePixel = 2;
	} 

	if(point > 0 ) 
		Menang_UI.Frame.PointTambahKurang.TextColor3 = Color3.fromRGB(71, 212, 0);
	else if(point < 0)
		Menang_UI.Frame.PointTambahKurang.TextColor3 = Color3.fromRGB(255, 0, 4);
	else if(point === 0)
		Menang_UI.Frame.PointTambahKurang.TextColor3 = Color3.fromRGB(127, 127, 127);

	Menang_UI.Frame.PointTambahKurang.Text = `${point}`;

	Menang_UI.Frame.KeLobby.MouseButton1Click.Connect(() => {
		Event.TeleportKeLobby.FireServer();
		Menang_UI.Frame.TextTeleport.Visible = true;
	});

	Menang_UI.Frame.Rematch.MouseButton1Click.Connect(() => {
		if(!Pemain.DataPemain.FindFirstChild("LagiInvite")) {
			Menang_UI.Frame.Rematch.Text = "Inviting...";
			Event.KirimRematch.FireServer(CaturPemain.p1.Pemain.Name !== Pemain.Name ? CaturPemain.p1.Pemain : CaturPemain.p2.Pemain);
		}
	});

	let KondisiLaporUI = false;
	Menang_UI.Frame.Lapor.MouseButton1Click.Connect(() => {
		if(!KondisiLaporUI) {
			TweenService.Create(Menang_UI.LaporUI, new TweenInfo(.4), { Position: UDim2.fromScale(.5, .5) }).Play();
			KondisiLaporUI = true;
		}  else {
			TweenService.Create(Menang_UI.LaporUI, new TweenInfo(.4), { Position: UDim2.fromScale(.5, 1.2) }).Play();
			KondisiLaporUI = false;
		}
	});

	Menang_UI.LaporUI.Tutup.MouseButton1Click.Connect(() => {
		TweenService.Create(Menang_UI.LaporUI, new TweenInfo(.4), { Position: UDim2.fromScale(.5, 1.2) }).Play();
		KondisiLaporUI = false;
	});

	Menang_UI.LaporUI.Kirim.MouseButton1Click.Connect(() => {
		const penjelasan = Menang_UI.LaporUI.penjelasan.Text;

		if(Menang_UI.LaporUI.penjelasan.Text.size() > 5) {
			KondisiLaporUI = false;
			Menang_UI.LaporUI.penjelasan.Text = "Thank you for the report, We will look for it.";
			Event.Lapor.FireServer(penjelasan, warna === CaturPemain.p1.warna ? CaturPemain.p2.Pemain : CaturPemain.p1.Pemain);
			wait(1.5);
			const t = TweenService.Create(Menang_UI.LaporUI, new TweenInfo(.4), { Position: UDim2.fromScale(.5, 1.2) });
			t.Play();
			t.Completed.Wait();
			Menang_UI.LaporUI.Destroy();
			Menang_UI.Frame.Lapor.Destroy();
		} else {
			Menang_UI.LaporUI.penjelasan.Text = "Describe is too short";
			wait(1.5);
			Menang_UI.LaporUI.penjelasan.Text = penjelasan;
		}
	});

	const TweenMenang = TweenService.Create(Menang_UI.Frame, new TweenInfo(.4), { Position: UDim2.fromScale(.5, .5) });
	TweenMenang.Play();
	TweenMenang.Completed.Wait();

	if(StatusSelesai !== "draw")
		StarterGui.Suara.Menang.Play();

	wait(1.5);
	if(point > 0) {
		for(let i = 0; i <= point; i++) {
			Menang_UI.Frame.Point.Text = `${jumlahPoint+i}`;
			Menang_UI.Frame.PointTambahKurang.Text = `${point - i}`;
			StarterGui.Suara.SpamTambahan.Play();
			wait(.05);
		}
	} else if(point < 0) {
		for(let i = 0; i >= point; i--) {
			Menang_UI.Frame.Point.Text = `${jumlahPoint+i}`;
			Menang_UI.Frame.PointTambahKurang.Text = `${point - i}`;
			StarterGui.Suara.SpamTambahan.Play();
			wait(.05);
		}
	}
});

Event.KirimPromosiCatur.Event.Connect((Promosi: Promosi) => {
	if(NungguPromosi.boleh) {
		NungguPromosi = { boleh: false, promosi: Promosi };
		PromosiFrame.Destroy();
	}
});

Event.KirimRematchKePemainUI.OnClientEvent.Connect((siapaInvite: Player) => {
	Menang_UI.Frame.RematchFrame.TextRematch.Text = `${siapaInvite.Name} wants to have a rematch`;
	TweenService.Create(Menang_UI.Frame.RematchFrame, new TweenInfo(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position: UDim2.fromScale(0, 1.1) }).Play();

	Menang_UI.Frame.RematchFrame.Terima.MouseButton1Click.Connect(() => {
		Event.StatusRematch.FireServer(siapaInvite, "terima");

		TweenService.Create(Menang_UI.Frame.RematchFrame, new TweenInfo(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position: UDim2.fromScale(0, 1.8) }).Play();
		Menang_UI.Frame.TextTeleport.Visible = true;
	});

	Menang_UI.Frame.RematchFrame.Tolak.MouseButton1Click.Connect(() => {
		Event.StatusRematch.FireServer(siapaInvite, "tolak");
		
		TweenService.Create(Menang_UI.Frame.RematchFrame, new TweenInfo(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position: UDim2.fromScale(0, 1.8) }).Play();
	});
});

Event.TunjukkinRematchStatus.OnClientEvent.Connect((status: "terima" | "tolak") => {
	if(status === "terima") {
		Menang_UI.Frame.TextTeleport.Visible = true;
		Menang_UI.Frame.Rematch.Text = "Rematch";
	} else {
		Menang_UI.Frame.Rematch.Text = "Rejected";
	}
})

let SudahAdaSound = false;
Event.KirimWaktuCaturKePemain.OnClientEvent.Connect((waktu: number, PemainLainnya: { Pemain: Player, warna: Color, waktu: number }) => {
	const WaktuPemain = (CaturUI.FindFirstChild(Pemain.Name) as StarterGui["Catur"]["BackgroundCatur"]["Pemain1"]).Waktu
	const WaktuPemainLainnya = (CaturUI.FindFirstChild(PemainLainnya.Pemain.Name) as StarterGui["Catur"]["BackgroundCatur"]["Pemain2"]).Waktu

	if(waktu <= 30) {
		WaktuPemain.TextColor3 = Color3.fromRGB(255, 60, 63);
		if(!SudahAdaSound) {
			SudahAdaSound = true;
			StarterGui.Suara.WaktuMauHabis.Sound.Play();
			wait(.1);
			StarterGui.Suara.WaktuMauHabis.Sound1.Play();
			wait(.1)
			StarterGui.Suara.WaktuMauHabis.Sound2.Play();
			wait(.15);
			StarterGui.Suara.WaktuMauHabis.Sound3.Play();
		}
	}
	if(PemainLainnya.waktu <= 30) {
		WaktuPemainLainnya.TextColor3 = Color3.fromRGB(255, 60, 63);
	}
	
	WaktuPemain.Text = convertToHMS(waktu);
	WaktuPemainLainnya.Text = convertToHMS(PemainLainnya.waktu);
});

(script.Parent?.Parent as StarterGui).ScreenOrientation = Enum.ScreenOrientation.LandscapeRight;
UIS.ModalEnabled = true;

Humanoid.SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
Humanoid.JumpPower = 0;

while(true) {
	Kamera.CameraType = Enum.CameraType.Scriptable;
	if(Kamera.CameraType === Enum.CameraType.Scriptable && game.IsLoaded()) break;
}
print(Kamera.CameraType);

Kamera.CFrame = Workspace.Tempat.Kamera.CFrame;

Workspace.Tempat.Kamera.GetPropertyChangedSignal("CFrame").Connect(() => {
	Kamera.CFrame = Workspace.Tempat.Kamera.CFrame;
})

Loading_UI.Enabled = true;
Loading_UI.LoadingFrame.LocalScript.Enabled = true;