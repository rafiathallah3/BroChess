interface ReplicatedStorage extends Folder {
    remote: Folder & {
		Mulai: RemoteEvent;
		KirimCaturUIKePemain: RemoteEvent;
		GerakanCatur: RemoteEvent;
		CaturUIKeplayer: RemoteEvent;
		KirimSemuaGerakan: RemoteEvent;
		KirimDataWarnaBoard: RemoteEvent;
		TeleportUndanganKeGame: RemoteEvent;
		KirimPemulaianCaturUIKePemain: RemoteEvent;
		KirimWaktuCaturKePemain: RemoteEvent;
		KirimCaturPemenang: RemoteEvent;
		TunjukkinMenangUI: RemoteEvent;
		TeleportKeLobby: RemoteEvent;
		KirimRematch: RemoteEvent;
		KirimRematchKePemainUI: RemoteEvent;
		KirimUndanganTutupUIKePemain: RemoteEvent;
		TambahinUndangan: RemoteEvent;
		KirimTerimaTolakUndanganUI: RemoteEvent;
		StatusRematch: RemoteEvent;
		TunjukkinRematchStatus: RemoteEvent;
		TeleportBalikKeGame: RemoteEvent;
		UpdateLeaderboard: RemoteEvent;
		Lapor: RemoteEvent;
		Seri: RemoteEvent;
		Menyerah: RemoteEvent;
		KeLobby: RemoteEvent;
		KirimPromosiCatur: BindableEvent;
		KirimWarnaBoard: BindableEvent;
	},
	Tempat: Folder & {
		StasiunAngkasa: Folder & {
			TempatScript: Script;
		},
		Laut: Folder & {
			TempatScript: Script;
		}
	}
	komponenKematian: Folder & {
		PartikelKembangApi: ParticleEmitter;
		bulat: Part;
		DariKaleng: Part;
		Kaleng: Part;
	}
	InfoValue: Folder & {
		SudahDimulai: BoolValue;
	}
	komponen: Folder & {
		bulat: Frame & {
			UICorner: UICorner;
		};
		border: Folder & {
			bawah: Frame;
			kanan: Frame;
			kiri: Frame;
			atas: Frame;
		};
		CheckFrame: Frame;
		MakanFrame: Frame;
		Potongan: Folder & {
			Kn_itam1: ImageLabel;
			P_itam1: ImageLabel;
			P_putih3: ImageLabel;
			Kn_putih: ImageLabel;
			B_putih1: ImageLabel;
			R_putih: ImageLabel;
			Q_putih: ImageLabel;
			B_itam1: ImageLabel;
			B_itam: ImageLabel;
			P_putih7: ImageLabel;
			P_itam5: ImageLabel;
			P_itam4: ImageLabel;
			P_itam: ImageLabel;
			P_itam2: ImageLabel;
			P_itam7: ImageLabel;
			P_putih4: ImageLabel;
			P_putih2: ImageLabel;
			K_itam: ImageLabel;
			Kn_itam: ImageLabel;
			P_putih: ImageLabel;
			R_putih1: ImageLabel;
			B_putih: ImageLabel;
			P_putih5: ImageLabel;
			R_itam1: ImageLabel;
			R_itam: ImageLabel;
			P_putih1: ImageLabel;
			P_itam3: ImageLabel;
			Q_itam: ImageLabel;
			K_putih: ImageLabel;
			P_itam6: ImageLabel;
			Kn_putih1: ImageLabel;
			P_putih6: ImageLabel;
		};
	}
	
}

interface StarterGui extends Folder {
    Komponen_UI: Komponen_UI,
	Suara: Folder & {
		Gerak: Sound,
		Ambil: Sound,
		Mulai: Sound,
		Tombol: Sound,
		Klik: Sound,
		Menang: Sound,
		SpamTambahan: Sound,
		SuaraBelakang: Folder & {
			Pertama: Sound,
			Kedua: Sound,
			Ketiga: Sound
		},
		WaktuMauHabis: Folder & {
			Sound: Sound
			Sound1: Sound;
			Sound2: Sound;
			Sound3: Sound;
		}
	},
	Mulai: ScreenGui & {
		mulai: TextButton;
	},
	Menu: ScreenGui & {
		MenuFrame: Frame & {
			TeleportKeGame: Frame & {
				masuk: TextButton;
			},
			TombolFrame: Frame & {
				Undang: TextButton;
				MainBot: TextButton;
				Toko: TextButton;
				Analisis: TextButton;
				Profile: TextButton;
				Settings: TextButton;
				Leaderboard: TextButton;
			},
			UndanganMenu: Frame & {
				UICorner: UICorner;
				judul: TextLabel;
				TempatPemain: ScrollingFrame & {
					UIListLayout: UIListLayout;
				};
			},
			LeaderboardMenu: Frame & {
				TempatPemain: ScrollingFrame,
				TempatKalah: ScrollingFrame,
				TempatJumlahMain: ScrollingFrame,
				TempatMenang: ScrollingFrame,
				MainPalingBanyak: TextButton;
				PointPalingBanyak: TextButton;
				WinPalingBanyak: TextButton;
				LosePalingBanyak: TextButton;
			},
			ProfileMenu: Frame & {
				TempatHistory: ScrollingFrame,
				JumlahMain: TextLabel;
				Kalah: TextLabel;
				Menang: TextLabel;
				Nama: TextLabel;
				Point: TextLabel;
				Gambar: ImageLabel;
			}
			SettingsMenu: Frame & {
				UICorner: UICorner;
				Frame: Frame & {
					Warna1: Frame & {
						warna: TextLabel;
						Warna: ImageButton & {
							UICorner: UICorner;
						};
					};
					Warna2: Frame & {
						warna: TextLabel;
						Warna: ImageButton & {
							UICorner: UICorner;
						};
					};
				};
				judul: TextLabel;
			},
			TokoMenu: Frame & {
				
			}
			TerimaUndangan: Frame;
		},
		Profile: Frame & {
			Gambar: ImageLabel;
			Nama: TextLabel,
			Point: TextLabel;
			Menang: TextLabel;
			Kalah: TextLabel;
		}
		GerakanFrame: Frame & {
			Folder: Folder & {
				UIGridLayout: UIGridLayout,
				hitam: Frame,
				putih: Frame
			},
			berikut: Frame & {
				UIGridLayout: UIGridLayout,
				hitam: Frame,
				putih: Frame
			}
		},
	}
	Catur: ScreenGui & {
		BackgroundCatur: Frame & {
			SeriUI: Frame & {
				Terima: TextButton,
				Tolak: TextButton,
				text: TextLabel
			};
			Pemain2: Frame & {
				Point: TextLabel;
				Foto: ImageLabel;
				Nama: TextLabel;
				Waktu: TextLabel;
			};
			Frame: Frame;
			SiapaDuluan: TextLabel;
			Pemain1: Frame & {
				Makan: Frame;
				Foto: ImageLabel;
				Nama: TextLabel;
				Waktu: TextLabel;
			};
			prediksi: TextLabel;
			Menyerah: TextButton;
			Seri: TextButton;
		}
	}
	Loading: ScreenGui & {
		ScreenHITAM: Frame,
		LoadingFrame: Frame & {
			LocalScript: LocalScript;
			pion: ImageLabel;
			ProgressBg: Frame & {
				Progress: Frame;
			};
			judul: TextLabel;
		};
	},
	Menang: ScreenGui & {
		Frame: Frame & {
			Point: TextLabel;
			vs: TextLabel;
			UICorner: UICorner;
			PointsText: TextLabel;
			Rematch: TextButton & {
				UICorner: UICorner;
			};
			RematchFrame: Frame & {
				Terima: TextButton;
				Tolak: TextButton;
				TextRematch: TextLabel;
			}
			GambarPemain1: ImageButton;
			KeLobby: TextButton & {
				UICorner: UICorner;
			};
			PointTambahKurang: TextLabel;
			Status: Frame & {
				UICorner: UICorner;
				Alasan: TextLabel;
				Menang_Kalah: TextLabel;
			};
			NamaPemain1: TextLabel;
			GambarPemain2: ImageButton;
			NamaPemain2: TextLabel;
			TextTeleport: TextLabel;
			Lapor: TextButton;
		};
		LaporUI: Frame & {
			Tutup: TextButton;
			Kirim: TextButton;
			penjelasan: TextBox;
			textLapor: TextLabel;
			deskripsiLapor: TextLabel
		}
	}
}

interface Workspace extends WorldRoot {
	Tempat: Model & {
		meja_kursi: Model & {
			chairs: Model & {
				kursi1: Model & {
					Seat: Seat;
					utama: Part;
				},
				kursi2: Model & {
					Seat: Seat;
					utama: Part;
				}
			}
		}
		Kamera: BasePart;
	}
}

interface Player extends Players {
	DataPemain: Folder & {
		DataPoint: Folder & {
			Point: NumberValue,
			RatingDeviation: NumberValue,
			Volatility: NumberValue,
		}
		Uang: NumberValue,
		DataSettings: Folder & {
			WarnaBoard1: StringValue,
			WarnaBoard2: StringValue,
		},
		DataBarang: Folder & {
			BarangKematian: Folder;
			BarangSkinPiece: Folder;
			kematian: StringValue;
			skinpiece: StringValue;
		},
		DataStatus: Folder & {
			Menang: NumberValue,
			Kalah: NumberValue,
			JumlahMain: NumberValue,
			History: Folder & {
				Pemain1: Folder &{
					nama: StringValue,
					warna: StringValue,
					point: NumberValue,
				},
				Pemain2: Folder & {
					nama: StringValue,
					warna: StringValue,
					point: NumberValue,
				},
				Alasan: StringValue,
				YangMenang: StringValue,
				Tanggal: StringValue;
				Gerakan: StringValue;
			},
		}
	},
	BerapaKaliDraw: NumberValue,
	Character: Model & {
		Humanoid: Humanoid & {
			Animator: Animator;
		},
		HumanoidRootPart: Part;
		Animate: LocalScript & {
			sit: StringValue & {
				SitAnim: Animation;
			}
		},
		Head: Part;
	}
}

type Komponen_UI = Folder & {
	latar_belakang_putih: latar_belakang_putih,
	latar_belakang_hitam: latar_belakang_hitam,
	SetelahTaruk: Frame;
	BulatKlikKanan: ImageLabel;
	PemainLeaderboard: Frame & {
		Profile: ImageLabel,
		Nama: TextLabel,
		Nomor: TextLabel,
		Point: TextLabel
	},
	PemainProfile: Frame & {
		NamaPemain1: TextLabel;
		NamaPemain2: TextLabel;
		Status: TextLabel;
		Tanggal: TextLabel;
	},
	KartuPemain: Frame & {
		Pemain2: ImageLabel;
		NamaPemain1: TextLabel;
		NamaPemain2: TextLabel;
		vs: TextLabel;
		Undang: TextButton & {
			UICorner: UICorner;
		};
		Pemain1: ImageLabel;
		Nonton: TextButton & {
			UICorner: UICorner;
		};
	},
	KartuUndangan: Frame & {
		Terima: TextButton & {
			UICorner: UICorner;
		};
		Waktu: Frame;
		ProfileOrang: ImageLabel;
		Text: TextLabel;
		Menolak: TextButton & {
			UICorner: UICorner;
		};
		NamaOrang: TextLabel;
	},
	PromosiPutih: Frame & {
		bishop: ImageLabel;
		UIGridLayout: UIGridLayout;
		knight: ImageLabel;
		queen: ImageLabel;
		rook: ImageLabel;
	},
	PromosiHitam: Frame & {
		bishop: ImageLabel;
		UIGridLayout: UIGridLayout;
		knight: ImageLabel;
		queen: ImageLabel;
		rook: ImageLabel;
	}
	ColorPickers: Frame & {
		Vertical: Frame & {
			UICorner: UICorner;
			ColorPickerArea: Frame & {
				UICorner: UICorner;
				Picker: Frame & {
					UICorner: UICorner;
				};
				UIGradent: UIGradient;
			};
			ColorShower: Frame & {
				UICorner: UICorner;
				UIAspectRatioConstraint: UIAspectRatioConstraint;
			};
		};
		Batal: TextButton & {
			UICorner: UICorner;
		};
		RGBInput: Frame & {
			UICorner: UICorner;
			B: Frame & {
				ColorName: TextLabel;
				ValueBox: TextBox & {
					UICorner: UICorner;
				};
			};
			G: Frame & {
				ColorName: TextLabel;
				ValueBox: TextBox & {
					UICorner: UICorner;
				};
			};
			R: Frame & {
				ColorName: TextLabel;
				ValueBox: TextBox & {
					UICorner: UICorner;
				};
			};
		};
		UICorner: UICorner;
		Horizontal: Frame & {
			UICorner: UICorner;
			ColorPickerArea: Frame & {
				UICorner: UICorner;
				Picker: Frame & {
					UICorner: UICorner;
				};
				Rainbow: UIGradient;
			};
		};
		Simpan: TextButton & {
			UICorner: UICorner;
		};
		ColorPickerLocal: LocalScript & {
			GetOnGradientSlider: ModuleScript;
		};
	}
}

type latar_belakang_putih = Folder & {
	a6: Frame & {
		["6"]: TextLabel;
	};
	b6: Frame;
	a2: Frame & {
		["2"]: TextLabel;
	};
	b2: Frame;
	c2: Frame;
	g1: Frame & {
		g: TextLabel;
	};
	f1: Frame & {
		f: TextLabel;
	};
	h5: Frame;
	g5: Frame;
	f5: Frame;
	e5: Frame;
	d5: Frame;
	c5: Frame;
	b5: Frame;
	a5: Frame & {
		["5"]: TextLabel;
	};
	c1: Frame & {
		c: TextLabel;
	};
	b1: Frame & {
		b: TextLabel;
	};
	a1: Frame & {
		UICorner: UICorner;
		a: TextLabel;
		["1"]: TextLabel;
	};
	g4: Frame;
	h4: Frame;
	e4: Frame;
	f4: Frame;
	c4: Frame;
	d4: Frame;
	d8: Frame;
	e8: Frame;
	b8: Frame;
	c8: Frame;
	h8: Frame & {
		UICorner: UICorner;
	};
	f8: Frame;
	g8: Frame;
	a8: Frame & {
		UICorner: UICorner;
		["8"]: TextLabel;
	};
	a4: Frame & {
		["4"]: TextLabel;
	};
	b4: Frame;
	e3: Frame;
	d3: Frame;
	g3: Frame;
	f3: Frame;
	d7: Frame;
	h3: Frame;
	f7: Frame;
	e7: Frame;
	UIGridLayout: UIGridLayout;
	b7: Frame;
	a7: Frame & {
		["7"]: TextLabel;
	};
	a3: Frame & {
		["3"]: TextLabel;
	};
	h1: Frame & {
		UICorner: UICorner;
		h: TextLabel;
	};
	c3: Frame;
	b3: Frame;
	g6: Frame;
	h6: Frame;
	f2: Frame;
	g2: Frame;
	c6: Frame;
	d6: Frame;
	e6: Frame;
	f6: Frame;
	e1: Frame & {
		e: TextLabel;
	};
	d1: Frame & {
		d: TextLabel;
	};
	h2: Frame;
	h7: Frame;
	g7: Frame;
	c7: Frame;
	e2: Frame;
	d2: Frame;
};

type latar_belakang_hitam = Folder & {
	a6: Frame;
	b6: Frame;
	a2: Frame;
	b2: Frame;
	c2: Frame;
	g1: Frame;
	f1: Frame;
	e1: Frame;
	g5: Frame;
	f5: Frame;
	e5: Frame;
	d5: Frame;
	c5: Frame;
	b5: Frame;
	a5: Frame;
	c1: Frame;
	b1: Frame;
	a1: Frame & {
		UICorner: UICorner;
	};
	g4: Frame;
	h4: Frame & {
		["4"]: TextLabel;
	};
	e4: Frame;
	f4: Frame;
	c4: Frame;
	d4: Frame;
	d8: Frame & {
		d: TextLabel;
	};
	e8: Frame & {
		e: TextLabel;
	};
	b8: Frame & {
		b: TextLabel;
	};
	c8: Frame & {
		c: TextLabel;
	};
	h8: Frame & {
		UICorner: UICorner;
		["8"]: TextLabel;
		h: TextLabel;
	};
	f8: Frame & {
		f: TextLabel;
	};
	g8: Frame & {
		g: TextLabel;
	};
	a8: Frame & {
		a: TextLabel;
	};
	a4: Frame;
	b4: Frame;
	h7: Frame & {
		["7"]: TextLabel;
	};
	d3: Frame;
	g3: Frame;
	f3: Frame;
	d7: Frame;
	c7: Frame;
	f7: Frame;
	e7: Frame;
	UIGridLayout: UIGridLayout;
	b7: Frame;
	a7: Frame;
	a3: Frame;
	e3: Frame;
	c3: Frame;
	b3: Frame;
	d2: Frame;
	e2: Frame;
	f2: Frame;
	g2: Frame;
	h2: Frame & {
		["2"]: TextLabel;
	};
	d6: Frame;
	e6: Frame;
	f6: Frame;
	h5: Frame & {
		["5"]: TextLabel;
	};
	d1: Frame;
	h3: Frame & {
		["3"]: TextLabel;
	};
	h1: Frame & {
		["1"]: TextLabel;
		UICorner: UICorner;
	};
	g7: Frame;
	c6: Frame;
	g6: Frame;
	h6: Frame & {
		["3"]: TextLabel;
	};
};