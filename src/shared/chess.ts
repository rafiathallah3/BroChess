/*
 * Copyright (c) 2022, Jeff Hlywa (jhlywa@gmail.com)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 *----------------------------------------------------------------------------*/
import { Players, ReplicatedStorage } from "@rbxts/services"
import { Glicko2, PlayerGlicko } from "./glicko2";

const Event = ReplicatedStorage.remote;

const WHITE = 'w'
const BLACK = 'b'

const PAWN = 'p'
const KNIGHT = 'n'
const BISHOP = 'b'
const ROOK = 'r'
const QUEEN = 'q'
const KING = 'k'

export type Color = 'w' | 'b'
export type PieceSymbol = 'p' | 'n' | 'b' | 'r' | 'q' | 'k'

// prettier-ignore
export type Square =
    'a8' | 'b8' | 'c8' | 'd8' | 'e8' | 'f8' | 'g8' | 'h8' |
    'a7' | 'b7' | 'c7' | 'd7' | 'e7' | 'f7' | 'g7' | 'h7' |
    'a6' | 'b6' | 'c6' | 'd6' | 'e6' | 'f6' | 'g6' | 'h6' |
    'a5' | 'b5' | 'c5' | 'd5' | 'e5' | 'f5' | 'g5' | 'h5' |
    'a4' | 'b4' | 'c4' | 'd4' | 'e4' | 'f4' | 'g4' | 'h4' |
    'a3' | 'b3' | 'c3' | 'd3' | 'e3' | 'f3' | 'g3' | 'h3' |
    'a2' | 'b2' | 'c2' | 'd2' | 'e2' | 'f2' | 'g2' | 'h2' |
    'a1' | 'b1' | 'c1' | 'd1' | 'e1' | 'f1' | 'g1' | 'h1'

export type Promosi = 'q' | 'n' | 'r' | 'b';

const DEFAULT_POSITION =
  'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

type Piece = {
  color: Color
  type: PieceSymbol
}

type InternalMove = {
  color: Color
  from: number
  to: number
  piece: PieceSymbol
  captured?: PieceSymbol
  promotion?: PieceSymbol
  flags: number
}

interface History {
	move: InternalMove
	kings: Record<Color, number>
	turn: Color
	castling: Record<Color, number>
	epSquare: number
	halfMoves: number
	moveNumber: number
}

export type Move = {
	color: Color
	from: Square
	to: Square
	piece: PieceSymbol
	captured?: PieceSymbol
	promotion?: PieceSymbol
	flags: string
	san: string
}

export type Posisi = {
	square: Square,
	type: PieceSymbol,
	color: Color
}

export type TipePemain = {
	Pemain: Player,
	warna: Color,
	waktu: number,
	SudahGerak: boolean,
	WaktuAFK: number,
	uang: number
}

export type TipeRatingPemain = { 
	Menang: { rating: number, rd: number, vol: number, SelisihRating: number },
	Seri: { rating: number, rd: number, vol: number, SelisihRating: number },
	Kalah: { rating: number, rd: number, vol: number, SelisihRating: number },
	warna: Color, 
	prediksi: number,
	JumlahKalah: number,
	JumlahMenang: number,
	JumlahMain: number,
}

export type TipeGameSelesai = [boolean, "draw" | "skakmat" | "waktuhabis" | "menyerah" | "keluar game" | undefined, Color | AlasanDraw | undefined];

export type TipeMode = "komputer" | "player" | "analisis";

export type AlasanDraw = "Stalemate" | "Insufficient Material" | "Repetition" | "Draw" | "Accept Draw" | "Game Ended";

const EMPTY = -1

const FLAGS: Record<string, string> = {
	NORMAL: 'n',
	CAPTURE: 'c',
	BIG_PAWN: 'b',
	EP_CAPTURE: 'e',
	PROMOTION: 'p',
	KSIDE_CASTLE: 'k',
	QSIDE_CASTLE: 'q',
}

// prettier-ignore
const SQUARES: Square[] = [
  'a8', 'b8', 'c8', 'd8', 'e8', 'f8', 'g8', 'h8',
  'a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7',
  'a6', 'b6', 'c6', 'd6', 'e6', 'f6', 'g6', 'h6',
  'a5', 'b5', 'c5', 'd5', 'e5', 'f5', 'g5', 'h5',
  'a4', 'b4', 'c4', 'd4', 'e4', 'f4', 'g4', 'h4',
  'a3', 'b3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3',
  'a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2',
  'a1', 'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1'
]


const BITS: ReadonlyMap<string, number> = new ReadonlyMap<string, number>([
    ["NORMAL", 1],
    ["CAPTURE", 2],
    ["BIG_PAWN", 4],
    ["EP_CAPTURE", 8],
    ["PROMOTION", 16],
	["KSIDE_CASTLE", 32],
    ["QSIDE_CASTLE", 64]
])
// const BITS: Record<string, number> = {
//     NORMAL: 1,
//     CAPTURE: 2,
//     BIG_PAWN: 4,
//     EP_CAPTURE: 8,
//     PROMOTION: 16,
//     KSIDE_CASTLE: 32,
//     QSIDE_CASTLE: 64,
// }

const Ox88: Record<Square, number> = {
  a8:   0, b8:   1, c8:   2, d8:   3, e8:   4, f8:   5, g8:   6, h8:   7,
  a7:  16, b7:  17, c7:  18, d7:  19, e7:  20, f7:  21, g7:  22, h7:  23,
  a6:  32, b6:  33, c6:  34, d6:  35, e6:  36, f6:  37, g6:  38, h6:  39,
  a5:  48, b5:  49, c5:  50, d5:  51, e5:  52, f5:  53, g5:  54, h5:  55,
  a4:  64, b4:  65, c4:  66, d4:  67, e4:  68, f4:  69, g4:  70, h4:  71,
  a3:  80, b3:  81, c3:  82, d3:  83, e3:  84, f3:  85, g3:  86, h3:  87,
  a2:  96, b2:  97, c2:  98, d2:  99, e2: 100, f2: 101, g2: 102, h2: 103,
  a1: 112, b1: 113, c1: 114, d1: 115, e1: 116, f1: 117, g1: 118, h1: 119
}

const PAWN_OFFSETS = {
  b: [16, 32, 17, 15],
  w: [-16, -32, -17, -15],
}

const PIECE_OFFSETS = {
  n: [-18, -33, -31, -14, 18, 33, 31, 14],
  b: [-17, -15, 17, 15],
  r: [-16, 1, 16, -1],
  q: [-17, -16, -15, 1, 17, 16, 15, -1],
  k: [-17, -16, -15, 1, 17, 16, 15, -1],
}

const ATTACKS = [
  20, 0, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0, 0,20, 0,
   0,20, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0,20, 0, 0,
   0, 0,20, 0, 0, 0, 0, 24,  0, 0, 0, 0,20, 0, 0, 0,
   0, 0, 0,20, 0, 0, 0, 24,  0, 0, 0,20, 0, 0, 0, 0,
   0, 0, 0, 0,20, 0, 0, 24,  0, 0,20, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0,20, 2, 24,  2,20, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 2,53, 56, 53, 2, 0, 0, 0, 0, 0, 0,
  24,24,24,24,24,24,56,  0, 56,24,24,24,24,24,24, 0,
   0, 0, 0, 0, 0, 2,53, 56, 53, 2, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0,20, 2, 24,  2,20, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0,20, 0, 0, 24,  0, 0,20, 0, 0, 0, 0, 0,
   0, 0, 0,20, 0, 0, 0, 24,  0, 0, 0,20, 0, 0, 0, 0,
   0, 0,20, 0, 0, 0, 0, 24,  0, 0, 0, 0,20, 0, 0, 0,
   0,20, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0,20, 0, 0,
  20, 0, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0, 0,20
];

const RAYS = [
   17,  0,  0,  0,  0,  0,  0, 16,  0,  0,  0,  0,  0,  0, 15, 0,
    0, 17,  0,  0,  0,  0,  0, 16,  0,  0,  0,  0,  0, 15,  0, 0,
    0,  0, 17,  0,  0,  0,  0, 16,  0,  0,  0,  0, 15,  0,  0, 0,
    0,  0,  0, 17,  0,  0,  0, 16,  0,  0,  0, 15,  0,  0,  0, 0,
    0,  0,  0,  0, 17,  0,  0, 16,  0,  0, 15,  0,  0,  0,  0, 0,
    0,  0,  0,  0,  0, 17,  0, 16,  0, 15,  0,  0,  0,  0,  0, 0,
    0,  0,  0,  0,  0,  0, 17, 16, 15,  0,  0,  0,  0,  0,  0, 0,
    1,  1,  1,  1,  1,  1,  1,  0, -1, -1,  -1,-1, -1, -1, -1, 0,
    0,  0,  0,  0,  0,  0,-15,-16,-17,  0,  0,  0,  0,  0,  0, 0,
    0,  0,  0,  0,  0,-15,  0,-16,  0,-17,  0,  0,  0,  0,  0, 0,
    0,  0,  0,  0,-15,  0,  0,-16,  0,  0,-17,  0,  0,  0,  0, 0,
    0,  0,  0,-15,  0,  0,  0,-16,  0,  0,  0,-17,  0,  0,  0, 0,
    0,  0,-15,  0,  0,  0,  0,-16,  0,  0,  0,  0,-17,  0,  0, 0,
    0,-15,  0,  0,  0,  0,  0,-16,  0,  0,  0,  0,  0,-17,  0, 0,
  -15,  0,  0,  0,  0,  0,  0,-16,  0,  0,  0,  0,  0,  0,-17
];

const PIECE_MASKS = { p: 0x1, n: 0x2, b: 0x4, r: 0x8, q: 0x10, k: 0x20 }

const SYMBOLS = 'pnbrqkPNBRQK'

const PROMOTIONS: PieceSymbol[] = [KNIGHT, BISHOP, ROOK, QUEEN]

const RANK_1 = 7
const RANK_2 = 6
const RANK_7 = 1
const RANK_8 = 0

const ROOKS = {
	w: [
		{ square: Ox88.a1, flag: BITS.get("QSIDE_CASTLE") },
		{ square: Ox88.h1, flag: BITS.get("KSIDE_CASTLE") },
	],
	b: [
		{ square: Ox88.a8, flag: BITS.get("QSIDE_CASTLE") },
		{ square: Ox88.h8, flag: BITS.get("KSIDE_CASTLE") },
	],
}

const NomorKeStatus = {
    1: "Menang",
    .5: "Seri",
    0: "Kalah"
}

const SECOND_RANK = { b: RANK_7, w: RANK_2 }

const TERMINATION_MARKERS = ['1-0', '0-1', '1/2-1/2', '*']

function reverse(array: number[][]) {
	const output = [];
	while (array.size()) {
		output.push(array.pop());
	}
	
	return output;
}


function reverseArray(array: number[][]) {
	//javascript, Kalau kamu mengubah variable array di dalam function, di globalnya juga berubah 15/12/2022 00:19
	const TemplateArray = [...array];
	return reverse(TemplateArray);
} 

function rank(square: number): number {
    return square >> 4
}

function file(square: number): number {
    return square & 0xf
}

function isDigit(c: string): boolean {
    return c === "" ? false : string.find('0123456789', c)[0] !== undefined;
    // return '0123456789'.indexOf(c) !== -1
}

function algebraic(square: number): Square {
  const f = file(square)
  const r = rank(square)
  return ('abcdefgh'.sub(f + 1, f + 1) +
    '87654321'.sub(r + 1, r + 1)) as Square
}

function swapColor(color: Color): Color {
  return color === WHITE ? BLACK : WHITE
}

function trimString(str: string): string {
    const c = string.match(str, "^%s*(.-)%s*$")
    return c === undefined ? c : str;
}

type DataMove = { from: string; to: string; promotion?: string }

const pawnEvalWhite = [
	[0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
	[5.0,  5.0,  5.0,  5.0,  5.0,  5.0,  5.0,  5.0],
	[1.0,  1.0,  2.0,  3.0,  3.0,  2.0,  1.0,  1.0],
	[0.5,  0.5,  1.0,  2.5,  2.5,  1.0,  0.5,  0.5],
	[0.0,  0.0,  0.0,  2.0,  2.0,  0.0,  0.0,  0.0],
	[0.5, -0.5, -1.0,  0.0,  0.0, -1.0, -0.5,  0.5],
	[0.5,  1.0, 1.0,  -2.0, -2.0,  1.0,  1.0,  0.5],
	[0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0]
];

const pawnEvalBlack = reverseArray(pawnEvalWhite);

const knightEval = [
	[-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0],
	[-4.0, -2.0,  0.0,  0.0,  0.0,  0.0, -2.0, -4.0],
	[-3.0,  0.0,  1.0,  1.5,  1.5,  1.0,  0.0, -3.0],
	[-3.0,  0.5,  1.5,  2.0,  2.0,  1.5,  0.5, -3.0],
	[-3.0,  0.0,  1.5,  2.0,  2.0,  1.5,  0.0, -3.0],
	[-3.0,  0.5,  1.0,  1.5,  1.5,  1.0,  0.5, -3.0],
	[-4.0, -2.0,  0.0,  0.5,  0.5,  0.0, -2.0, -4.0],
	[-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0]
];

const bishopEvalWhite = [
    [ -2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0],
    [ -1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -1.0],
    [ -1.0,  0.0,  0.5,  1.0,  1.0,  0.5,  0.0, -1.0],
    [ -1.0,  0.5,  0.5,  1.0,  1.0,  0.5,  0.5, -1.0],
    [ -1.0,  0.0,  1.0,  1.0,  1.0,  1.0,  0.0, -1.0],
    [ -1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0, -1.0],
    [ -1.0,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5, -1.0],
    [ -2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0]
];

const bishopEvalBlack = reverseArray(bishopEvalWhite);

const rookEvalWhite = [
    [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [  0.5,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  0.5],
    [ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
    [ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
    [ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
    [ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
    [ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
    [  0.0,   0.0, 0.0,  0.5,  0.5,  0.0,  0.0,  0.0]
];

const rookEvalBlack = reverseArray(rookEvalWhite);

const evalQueen = [
    [ -2.0, -1.0, -1.0, -0.5, -0.5, -1.0, -1.0, -2.0],
    [ -1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -1.0],
    [ -1.0,  0.0,  0.5,  0.5,  0.5,  0.5,  0.0, -1.0],
    [ -0.5,  0.0,  0.5,  0.5,  0.5,  0.5,  0.0, -0.5],
    [  0.0,  0.0,  0.5,  0.5,  0.5,  0.5,  0.0, -0.5],
    [ -1.0,  0.5,  0.5,  0.5,  0.5,  0.5,  0.0, -1.0],
    [ -1.0,  0.0,  0.5,  0.0,  0.0,  0.0,  0.0, -1.0],
    [ -2.0, -1.0, -1.0, -0.5, -0.5, -1.0, -1.0, -2.0]
];

const kingEvalWhite = [
    [ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
    [ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
    [ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
    [ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
    [ -2.0, -3.0, -3.0, -4.0, -4.0, -3.0, -3.0, -2.0],
    [ -1.0, -2.0, -2.0, -2.0, -2.0, -2.0, -2.0, -1.0],
    [  2.0,  2.0,  0.0,  0.0,  0.0,  0.0,  2.0,  2.0 ],
    [  2.0,  3.0,  1.0,  0.0,  0.0,  1.0,  3.0,  2.0 ]
];

const kingEvalBlack = reverseArray(kingEvalWhite);

export function validateFen(fen: string) {
    const errors = []
    errors[0] = 'No errors.'
    errors[1] = 'FEN string must contain six space-delimited fields.'
    errors[2] = '6th field (move number) must be a positive integer.'
    errors[3] = '5th field (half move counter) must be a non-negative integer.'
    errors[4] = '4th field (en-passant square) is invalid.'
    errors[5] = '3rd field (castling availability) is invalid.'
    errors[6] = '2nd field (side to move) is invalid.'
    errors[7] = "1st field (piece positions) does not contain 8 '/'-delimited rows."
    errors[8] = '1st field (piece positions) is invalid [consecutive numbers].'
    errors[9] = '1st field (piece positions) is invalid [invalid piece].'
    errors[10] = '1st field (piece positions) is invalid [row too large].'
    errors[11] = 'Illegal en-passant square'

    /* 1st criterion: 6 space-seperated fields? */
    const tokens = fen.split(" ");
    if (tokens.size() !== 6) {
        return { valid: false, errorNumber: 1, error: errors[1] }
    }

    /* 2nd criterion: move number field is a integer value > 0? */
    const moveNumber = tonumber(tokens[5], 10)!
    if (tostring(moveNumber) === "nan" || moveNumber <= 0) {
        return { valid: false, errorNumber: 2, error: errors[2] }
    }

    /* 3rd criterion: half move counter is an integer >= 0? */
    const halfMoves = tonumber(tokens[4], 10)!
    if (tostring(halfMoves) === "nan" || halfMoves < 0) {
        return { valid: false, errorNumber: 3, error: errors[3] }
    }

    /* 4th criterion: 4th field is a valid e.p.-string? */
    if(!(string.match(tokens[3], '^([abcdefgh][36])$') !== undefined || string.match(tokens[3], '-') !== undefined)) {
        return { valid: false, errorNumber: 4, error: errors[4] }
    }
    // if (!/^(-|[abcdefgh][36])$/.test(tokens[3])) {
    //     return { valid: false, errorNumber: 4, error: errors[4] }
    // }

    /* 5th criterion: 3th field is a valid castle-string? */
    // if(!( string.match(tokens[2], 'KQ') !== undefined || ))
    // if (!/^(KQ?k?q?|Qk?q?|kq?|q|-)$/.test(tokens[2])) {
    //     return { valid: false, errorNumber: 5, error: errors[5] }
    // }

    /* 6th criterion: 2nd field is "w" (white) or "b" (black)? */
    if(!(string.match(tokens[1], '^[wb]$') !== undefined)) {
        return { valid: false, errorNumber: 6, error: errors[6] }
    }
    // if (!/^(w|b)$/.test(tokens[1])) {
    //     return { valid: false, errorNumber: 6, error: errors[6] }
    // }

    /* 7th criterion: 1st field contains 8 rows? */
    const rows = tokens[0].split('/')
    if (rows.size() !== 8) {
        return { valid: false, errorNumber: 7, error: errors[7] }
    }

    /* 8th criterion: every row is valid? */
    for (let i = 0; i < rows.size(); i++) {
        /* check for right sum of fields AND not two numbers in succession */
        let sumFields = 0
        let previousWasNumber = false
        for (let k = 0; k < rows[i].size(); k++) {
            if (isDigit(rows[i].sub(k+1, k+1))) {
                if (previousWasNumber) {
                    return { valid: false, errorNumber: 8, error: errors[8] }
                }
                sumFields += tonumber(rows[i].sub(k+1, k+1), 10)!
                previousWasNumber = true
            } else {
                if (string.match(rows[i].sub(k+1, k+1), "^[prnbqkPRNBQK]$") === undefined) {
                    return { valid: false, errorNumber: 9, error: errors[9] }
                }
                sumFields += 1
                previousWasNumber = false
            }
        }
        if (sumFields !== 8) {
            return { valid: false, errorNumber: 10, error: errors[10] }
        }
    }

    //Ubahin ke 2 kalau tidak bisa, lua moment
    if (
        (tokens[3].sub(1, 1) === '3' && tokens[1] === 'w') ||
        (tokens[3].sub(1, 1) === '6' && tokens[1] === 'b')
    ) {
        return { valid: false, errorNumber: 11, error: errors[11] }
    }

  /* everything's okay! */
  return { valid: true, errorNumber: 0, error: errors[0] }
}

/* this function is used to uniquely identify ambiguous moves */
function getDisambiguator(move: InternalMove, moves: InternalMove[]) {
	const from = move.from
	const to = move.to
	const piece = move.piece

	let ambiguities = 0
	let sameRank = 0
	let sameFile = 0

	for (let i = 0, len = moves.size(); i < len; i++) {
		const ambigFrom = moves[i].from
		const ambigTo = moves[i].to
		const ambigPiece = moves[i].piece

		/* if a move of the same piece type ends on the same to square, we'll
		* need to add a disambiguator to the algebraic notation
		*/
		if (piece === ambigPiece && from !== ambigFrom && to === ambigTo) {
			ambiguities++

			if (rank(from) === rank(ambigFrom)) {
				sameRank++
			}

			if (file(from) === file(ambigFrom)) {
				sameFile++
			}
		}
	}

	if (ambiguities > 0) {
		/* if there exists a similar moving piece on the same rank and file
		as the move in question, use the square as the disambiguator
		*/

		if (sameRank > 0 && sameFile > 0) {
			return algebraic(from)
		} else if (sameFile > 0) {
		/* if the moving piece rests on the same file, use the rank symbol
			as the disambiguator
		*/
			return algebraic(from).sub(2, 2)
		} else {
		/* else use the file symbol */
			return algebraic(from).sub(1, 1)
		}
	}

	return ''
}

function addMove(
	moves: InternalMove[],
	color: Color,
	from: number,
	to: number,
	piece: PieceSymbol,
	captured: PieceSymbol | undefined = undefined,
	flags: number = BITS.get("NORMAL")!
) {
	const r = rank(to)

	if (piece === PAWN && (r === RANK_1 || r === RANK_8)) {
		for (let i = 0; i < PROMOTIONS.size(); i++) {
			const promotion = PROMOTIONS[i]
			moves.push({
				color,
				from,
				to,
				piece,
				captured,
				promotion,
				flags: flags | BITS.get("PROMOTION")!,
			})
		}
	} else {
		moves.push({
			color,
			from,
			to,
			piece,
			captured,
			promotion: undefined,
			flags,
		})
	}
}

function inferPieceType(san: string) {
	let pieceType = san.sub(0, 0)
	if (pieceType >= 'a' && pieceType <= 'h') {
		const matches = san.match("[a-h]%d.*[a-h]%d") !== undefined;
		if (matches) {
			return undefined
		}
		return PAWN
	}
	pieceType = pieceType.lower()
	if (pieceType === 'o') {
		return KING
	}
	return pieceType as PieceSymbol
}

function strippedSan(move: string): string {
    //probably bug
    return move.gsub("=", '')[0].gsub('[+#]$', '')[0];
}

export class CaturAI {
	chess: Chess | undefined;

	minimaxRoot(depth: number, chess: Chess, apakahMaximisingPemain: boolean) {
		this.chess = chess;
		const Pergerakan = chess.moves();
		let bestMove = -9999;
		let bestMoveFound;
	
		for(let i = 0; i < Pergerakan.size(); i++) {
			chess.move(Pergerakan[i]);
			const value = this.minimax(depth - 1, -10000, 10000, !apakahMaximisingPemain);
			chess.undo();
			if(value >= bestMove) {
				bestMove = value;
				bestMoveFound = Pergerakan[i];
			}
		}
		return bestMoveFound;
	}
  
	minimax(depth: number, alpha: number, beta: number, apakahMaximisingPemain: boolean) {
		if(this.chess === undefined) return 0;
		if(depth === 0) return -this.evaluateBoard(this.chess.board());
	
		const Pergerakan = this.chess.moves();
	
		if(apakahMaximisingPemain) {
			let bestMove = -9999;
			for(let i = 0; i < Pergerakan.size(); i++) {
				this.chess.move(Pergerakan[i]);
				bestMove = math.max(bestMove, this.minimax(depth - 1, alpha, beta, !apakahMaximisingPemain));
				this.chess.undo();
				alpha = math.max(alpha, bestMove);
				if(beta <= alpha) {
					return bestMove;
				}
			}
	
			return bestMove;
		}
  
		let bestMove = 9999;
		for (let i = 0; i < Pergerakan.size(); i++) {
			this.chess.move(Pergerakan[i]);
			bestMove = math.min(bestMove, this.minimax(depth - 1, alpha, beta, !apakahMaximisingPemain));
			this.chess.undo();
			beta = math.min(beta, bestMove);
			if (beta <= alpha) {
				return bestMove;
			}
		}
	
		return bestMove;
	}
  
	evaluateBoard(papan: ({ square: Square, type: PieceSymbol, color: Color } | undefined)[][]) {
		let totalEvaluation = 0;
		for (let i = 0; i < 8; i++) {
			for (let j = 0; j < 8; j++) {
				totalEvaluation = totalEvaluation + this.dapatinPieceValue(i, j, papan[i][j]);
			}
		}
		return totalEvaluation;
	}
	
	dapatinPieceValue(x: number, y: number, piece?: Piece) {
		if(piece === undefined) return 0;
	
		const dapatinAbsoluteValue = function(piece: Piece, apakahPutih: boolean, x: number, y: number) {
			if(piece.type === "p") {
				return 10 + (apakahPutih ? pawnEvalWhite[y][x] : pawnEvalBlack[y]![x]);
			}
			if(piece.type === "r") {
				return 50 + (apakahPutih ? rookEvalWhite[y][x] : rookEvalBlack[y]![x]);
			}
			if (piece.type === 'n') {
				return 30 + knightEval[y][x];
			} 
			if (piece.type === 'b') {
				return 30 + ( apakahPutih ? bishopEvalWhite[y][x] : bishopEvalBlack[y]![x] );
			}
			if (piece.type === 'q') {
				return 90 + evalQueen[y][x];
			}
			if (piece.type === 'k') {
				return 900 + ( apakahPutih ? kingEvalWhite[y][x] : kingEvalBlack[y]![x] );
			}
	
			return 0;
		}
	
		const absoluteValue = dapatinAbsoluteValue(piece, piece.color === 'w' , x, y);
		return piece.color === 'w' ? absoluteValue : -absoluteValue;
	}
}

export class Chess {
	private _board = new Array<Piece>(128)
	private _turn: Color = WHITE
	private _header: Map<string, string> = new Map<string, string>();
	private _kings: Record<Color, number> = { w: EMPTY, b: EMPTY }
	private _epSquare = -1
	private _halfMoves = 0
	private _moveNumber = 0
	private _history: History[] = []
	private _comments: Map<string, string> = new Map<string, string>();
	private _castling: Record<Color, number> = { w: 0, b: 0 }
	private _menyerah: Color | undefined;
	private _keluarGame: Color | undefined;
	private ranking: Glicko2;
	private _alasanSeri: AlasanDraw | undefined
	public p1: TipePemain;
	public p2?: TipePemain;
	public RatingPemain1?: TipeRatingPemain;
	public RatingPemain2?: TipeRatingPemain;
	public PerluWaktu = false;
	public mode: TipeMode;
	public WarnaKomputer: Color | undefined;
	public AICatur: CaturAI | undefined;

	constructor(p1: { Pemain: Player, warna: Color }, mode: TipeMode, p2?: { Pemain: Player, warna: Color }, fen = DEFAULT_POSITION, PerluWaktu = false, waktu = 600) {
		this.p1 = { ...p1, waktu, SudahGerak: false, uang: p1.Pemain.DataPemain.Uang.Value, WaktuAFK: 0 };
		if(p2) {
			this.p2 = { ...p2, waktu, SudahGerak: false, uang: p2.Pemain.DataPemain.Uang.Value, WaktuAFK: 0 };
		}

		this.PerluWaktu = PerluWaktu;

		if(p2 !== undefined)
			this.mode = "player"
		else
			this.mode = mode;
			
		if(this.mode === "komputer") {
			this.AICatur = new CaturAI();
			this.WarnaKomputer = swapColor(p1.warna);
		}

		this.ranking = new Glicko2({
			tau: .5,
			rating: 1500,
			rd: 200,
			vol: .06
		});

		this.load(fen);
		
		// TEST PGN
		// this.move({ from: "f2", to: "f3" })
        // this.move({ from: "e7", to: "e5" })
        // this.move({ from: "g2", to: "g4" })

		// [
		// 	'e4',   'e5',   'Nf3',   'Nc6',
		// 	'd4',   'exd4', 'Nxd4',  'Nxd4',
		// 	'Qxd4', 'Nf6',  'e5',    'Nh5',
		// 	'e6',   'dxe6', 'Qxd8+', 'Kxd8',
		// 	'Bg5+', 'Be7',  'Bxe7+', 'Kxe7',
		// 	'Nc3',  'Rd8',  'g4',    'Nf4',
		// 	'Bc4',  'g5'
		// ].forEach((v) => {
		// 	this.move(v);
		// })

		// this.move({ from: "e2", to: "e4" });
		// this.move({ from: "e7", to: "e5" });
		// this.move({ from: "g1", to: "f3" });
		// this.move({ from: "g8", to: "f6" });
		// this.move({ from: "f3", to: "e5" });
		// this.move({ from: "f6", to: "e4" });
		// this.move({ from: "d1", to: "e2" });
		// this.move({ from: "d8", to: "e7" });
		// this.move({ from: "e2", to: "e4" });
		// this.move({ from: "d7", to: "d6" });
		// this.move({ from: "b1", to: "c3" });

		if(this.mode === "player") {
			this.RatingPemain1 = this.KalkulasiMenangKalah({ 
				point: p1.Pemain.DataPemain.DataPoint.Point.Value,
				rd: p1.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol: p1.Pemain.DataPemain.DataPoint.Volatility.Value,
				warna: p1.warna,
				Kalah: p1.Pemain.DataPemain.DataStatus.Kalah.Value,
				Menang: p1.Pemain.DataPemain.DataStatus.Menang.Value,
				Main: p1.Pemain.DataPemain.DataStatus.JumlahMain.Value,
			}, {
				point: p2!.Pemain.DataPemain.DataPoint.Point.Value,
				rd: p2!.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol: p2!.Pemain.DataPemain.DataPoint.Volatility.Value
			});

			this.RatingPemain2 = this.KalkulasiMenangKalah({ 
				point: p2!.Pemain.DataPemain.DataPoint.Point.Value,
				rd: p2!.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol: p2!.Pemain.DataPemain.DataPoint.Volatility.Value,
				warna: p2!.warna,
				Kalah: p2!.Pemain.DataPemain.DataStatus.Kalah.Value,
				Menang: p2!.Pemain.DataPemain.DataStatus.Menang.Value,
				Main: p2!.Pemain.DataPemain.DataStatus.JumlahMain.Value,
			}, {
				point: p1.Pemain.DataPemain.DataPoint.Point.Value,
				rd: p1.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol: p1.Pemain.DataPemain.DataPoint.Volatility.Value
			});
		}

		const DataCaturRaw = this.moves({ verbose: true }) as Move[];
		const DataCatur: Map<Square, Move[]> = new Map<Square, Move[]>();
		DataCaturRaw.forEach((element) => {
			if(DataCatur.get(element.from) === undefined) {
				DataCatur.set(element.from, [element]);
			} else {
				DataCatur.get(element.from)?.push(element);
			}
		});

		const BoardNew: Posisi[] = [];
        this.board().forEach((v) => {
            (v as { square: Square, type: PieceSymbol, color: Color }[]).forEach((j) => {
                BoardNew.push(j);
            })
        });

		Event.KirimCaturUIKePemain.FireClient(p1.Pemain, p1.warna, this.mode, BoardNew, DataCatur, this.turn(), this.mode === "player" ? { ...p2, point: p2?.Pemain.DataPemain.DataPoint.Point.Value } : undefined, waktu);
		if(p2 !== undefined) {
			Event.KirimCaturUIKePemain.FireClient(p2.Pemain, p2.warna, this.mode, BoardNew, DataCatur, this.turn(), this.mode === "player" ? { ...p1, point: p1.Pemain.DataPemain.DataPoint.Point.Value } : undefined, waktu);
		}
	}

	clear(keepHeaders = false) {
		this._board = new Array<Piece>(128)
		this._kings = { w: EMPTY, b: EMPTY }
		this._turn = WHITE
		this._castling = { w: 0, b: 0 }
		this._epSquare = EMPTY
		this._halfMoves = 0
		this._moveNumber = 1
		this._history = []
		this._comments.clear();
		this._header = keepHeaders ? this._header : new Map<string, string>()
		this._updateSetup(this.fen())
	}

	load(fen: string, keepHeaders = false) {
		const tokens = fen.split(" ")
		const position = tokens[0]
		let square = 0

		if (!validateFen(fen).valid) {
			return false
		}

		this.clear(keepHeaders)

		for (let i = 1; i <= position.size(); i++) {
			const piece = position.sub(i, i);

			if (piece === '/') {
				square += 8
			} else if (isDigit(piece)) {
				square += tonumber(piece, 10)!
			} else {
				const color = piece < 'a' ? WHITE : BLACK
				this.put(
					{ type: piece.lower() as PieceSymbol, color },
					algebraic(square)
				)
				square++
			}
		}

		this._turn = tokens[1] as Color
		
		if (tokens[2].find("K")[0] !== undefined && tokens[2].find("K")[0]! > -1) {
			this._castling.w |= BITS.get("KSIDE_CASTLE")!
		}
		if (tokens[2].find("Q")[0] !== undefined && tokens[2].find('Q')[0]! > -1) {
			this._castling.w |= BITS.get("QSIDE_CASTLE")!
		}
		if (tokens[2].find("k")[0] !== undefined && tokens[2].find('k')[0]! > -1) {
			this._castling.b |= BITS.get("KSIDE_CASTLE")!
		}
		if (tokens[2].find("q")[0] !== undefined && tokens[2].find('q')[0]! > -1) {
			this._castling.b |= BITS.get("QSIDE_CASTLE")!
		}

		this._epSquare = tokens[3] === '-' ? EMPTY : Ox88[tokens[3] as Square]
		this._halfMoves = tonumber(tokens[4], 10)!
		this._moveNumber = tonumber(tokens[5], 10)!

		this._updateSetup(this.fen())

		return true
	}

	fen() {
		let empty = 0
		let fen = ''

		for (let i = Ox88.a8; i <= Ox88.h1; i++) {
		if (this._board[i]) {
			if (empty > 0) {
				fen += empty
				empty = 0
			}
			const { color, type: piece } = this._board[i]

			fen += color === WHITE ? piece.upper() : piece.lower()
		} else {
			empty++
		}
		
		if(bit32.band((i + 1) & 0x88) !== 0) {
			if (empty > 0) {
				fen += empty
			}

			if (i !== Ox88.h1) {
				fen += '/'
			}

			empty = 0
			i += 8
		}
		}

		let cflags = ''
		if (bit32.band(this._castling[WHITE] & BITS.get("KSIDE_CASTLE")!) !== 0) {
			cflags += 'K'
		}
		if (bit32.band(this._castling[WHITE] & BITS.get("QSIDE_CASTLE")!) !== 0) {
			cflags += 'Q'
		}
		if (bit32.band(this._castling[BLACK] & BITS.get("KSIDE_CASTLE")!) !== 0) {
			cflags += 'k'
		}
		if (bit32.band(this._castling[BLACK] & BITS.get("QSIDE_CASTLE")!) !== 0) {
			cflags += 'q'
		}

		/* do we have an empty castling flag? */
		cflags = cflags || '-'

		const epflags = this._epSquare === EMPTY ? '-' : algebraic(this._epSquare)

		return [
			fen,
			this._turn,
			cflags,
			epflags,
			this._halfMoves,
			this._moveNumber,
		].join(' ')
	}

	/* Called when the initial board setup is changed with put() or remove().
	* modifies the SetUp and FEN properties of the header object.  if the FEN
	* is equal to the default position, the SetUp and FEN are deleted the setup
	* is only updated if history.length is zero, ie moves haven't been  made.
	*/
	private _updateSetup(fen: string) {
		if (this._history.size() > 0) return

		if (fen !== DEFAULT_POSITION) {
			this._header.set("SetUp", '1');
			this._header.set("FEN", fen);
		} else {
			this._header.delete("SetUp");
			this._header.delete("FEN");
		}
	}

	reset() {
		this.load(DEFAULT_POSITION)
	}

	get(square: Square) {
		return this._board[Ox88[square]] || false
	}

	put(data: { type: PieceSymbol; color: Color }, square: Square) {
		/* check for piece */
		if (SYMBOLS.find(data.type.lower())[0] === -1) {
			return false
		}

		/* check for valid square */
		if (!(square in Ox88)) {
			return false
		}

		const sq = Ox88[square]

		/* don't let the user place more than one king */
		if (
			data.type === KING &&
		!(this._kings[data.color] === EMPTY || this._kings[data.color] === sq)
		) {
			return false
		}

		this._board[sq] = { type: data.type as PieceSymbol, color: data.color as Color }

		if (data.type === KING) {
			this._kings[data.color] = sq
		}

		this._updateSetup(this.fen())

		return true
	}

	remove(square: Square) {
		const piece = this.get(square)
		delete this._board[Ox88[square]]
		if (piece && piece.type === KING) {
		this._kings[piece.color] = EMPTY
		}

		this._updateSetup(this.fen())

		return piece
	}

	_attacked(color: Color, square: number) {
		for (let i = Ox88.a8; i <= Ox88.h1; i++) {
			/* did we run off the end of the board */
			if (i & 0x88) {
				i += 7
				continue
			}

			/* if empty square or wrong color */
			if (this._board[i] === undefined || this._board[i].color !== color) {
				continue
			}

			const piece = this._board[i]
			const difference = i - square
			const index = difference + 119

			if (ATTACKS[index] & PIECE_MASKS[piece.type]) {
				if (piece.type === PAWN) {
					if (difference > 0) {
						if (piece.color === WHITE) return true
					} else {
						if (piece.color === BLACK) return true
					}
					continue
				}

				/* if the piece is a knight or a king */
				if (piece.type === 'n' || piece.type === 'k') return true

				const offset = RAYS[index]
				let j = i + offset

				let blocked = false
				while (j !== square) {
					if (this._board[j] !== undefined) {
						blocked = true
						break
					}
					j += offset
				}

				if (!blocked) return true
			}
		}

		return false
	}

	private _isKingAttacked(color: Color) {
		return this._attacked(swapColor(color), this._kings[color])
	}

	isCheck() {
		return this._isKingAttacked(this._turn)
	}

	inCheck() {
		return this.isCheck()
	}

	isCheckmate() {
		return this.isCheck() && this._moves().size() === 0
	}

	isStalemate() {
		return !this.isCheck() && this._moves().size() === 0
	}

	DapatinWarnaDariPlayer(pemain: Player): Color | undefined {
		if(this.mode === "player") {
			return this.p1.Pemain.Name === pemain.Name ? this.p1.warna : this.p2!.warna;
		}

		return undefined;
	}

	DapatinPemainDariWarna(warna: Color): TipePemain | undefined {
		if(warna === this.p1.warna) return this.p1;
		if(this.p2 !== undefined && warna === this.p2.warna) return this.p2;

		return undefined;
	}

	SetAlasanSeri(alasan: AlasanDraw) {
		this._alasanSeri = alasan;
	}

	DapatinAlasanSeri(): AlasanDraw | undefined {
		if(this._alasanSeri)
			return this._alasanSeri;
		
		if(this.isStalemate())
			return "Stalemate"
		
		if(this.isInsufficientMaterial())
			return "Insufficient Material"
		
		if(this.isThreefoldRepetition())
			return "Repetition"

		if(this.isDraw())
			return "Draw"

		return undefined;
	}

	ApakahGameSelesai(): TipeGameSelesai {
		if(this.DapatinAlasanSeri() !== undefined) {
			return [true, "draw", this.DapatinAlasanSeri()!] //Gk tau mau taru dimana jadi disitu aja 01/01/2023 19:09 [TAHUN BARU!!!];
		}
		
		if(this.isCheckmate()) 
			return [true, "skakmat", this.turn() === "w" ? "b" : "w"];
		

		if(this.mode === "player") {
			if(this._menyerah !== undefined)
				return [true, "menyerah", this._menyerah === "w" ? "b" : "w"];

			if(this._keluarGame !== undefined)
				return [true, "keluar game", this._keluarGame === "w" ? "b" : "w"];

			if(this.p1.waktu <= 0)
				return [true, "waktuhabis", this.turn() === "w" ? "b" : "w"];
			
			if(this.p2!.waktu <=0) 
				return [true, "waktuhabis", this.turn() === "w" ? "b" : "w"];
			
		}

		return [false, undefined, undefined];
	}

	KalkulasiMenangKalah(pemain1: { point: number, rd: number, vol: number, warna: Color, Kalah: number, Menang: number, Main: number }, pemain2: { point: number, rd: number, vol: number }) {
		const Hasil: TipeRatingPemain = {
			Menang: {
				rating: 0,
				rd: 0,
				vol: 0,
				SelisihRating: 0
			},
			Seri: {
				rating: 0,
				rd: 0,
				vol: 0,
				SelisihRating: 0
			},
			Kalah: {
				rating: 0,
				rd: 0,
				vol: 0,
				SelisihRating: 0
			},
			warna: pemain1.warna,
			prediksi: 0,
			JumlahKalah: 0,
			JumlahMenang: 0,
			JumlahMain: 0,
		};
	
		[1, .5, 0].forEach((v) => {
			const RatingPemain1 = this.ranking.makePlayer(pemain1.point, pemain1.rd, pemain1.vol);
			const RatingPemain2 = this.ranking.makePlayer(pemain2.point, pemain2.rd, pemain2.vol);
			Hasil.prediksi = tonumber(string.format("%.1f", this.ranking.predict(RatingPemain1, RatingPemain2) * 100))!;

			this.ranking.updateRatings([
				[RatingPemain1, RatingPemain2, v]
			]);
	

			Hasil[NomorKeStatus[v as 1] as "Menang"] = {
				rating: math.floor(RatingPemain1.getRating()),
				rd: RatingPemain1.getRd(),
				vol: RatingPemain1.getVol(),
				SelisihRating: math.floor(RatingPemain1.getRating() - pemain1.point)
			}
	
			this.ranking.removePlayers();
		});
		Hasil.JumlahKalah = pemain1.Kalah++;
		Hasil.JumlahMenang = pemain1.Menang++;
		Hasil.JumlahMain = pemain1.Main++;
	
		return Hasil;
	}

	Menyerah(warna: Color) {
		this._menyerah = warna;
	}

	KeluarDariGame(warna: Color) {
		this._keluarGame = warna;
	}

	isInsufficientMaterial() {
		const pieces: Record<PieceSymbol, number> = {
			b: 0,
			n: 0,
			r: 0,
			q: 0,
			k: 0,
			p: 0,
		}
		const bishops = []
		let numPieces = 0
		let squareColor = 0

		for (let i = Ox88.a8; i <= Ox88.h1; i++) {
			squareColor = (squareColor + 1) % 2
			if (i & 0x88) {
				i += 7
				continue
		}

		const piece = this._board[i]
		if (piece) {
			pieces[piece.type] = piece.type in pieces ? pieces[piece.type] + 1 : 1
			if (piece.type === BISHOP) {
				bishops.push(squareColor)
			}
			numPieces++
		}
		}

		// k vs. k
		if (numPieces === 2) {
			return true
		} else if (
		// k vs. kn .... or .... k vs. kb
			numPieces === 3 &&
			(pieces[BISHOP] === 1 || pieces[KNIGHT] === 1)
		) {
			return true
		} else if (numPieces === pieces[BISHOP] + 2) {
		// kb vs. kb where any number of bishops are all on the same color
			let sum = 0
			const len = bishops.size()
			for (let i = 0; i < len; i++) {
				sum += bishops[i]
			}
			if (sum === 0 || sum === len) {
				return true
			}
		}

		return false
	}

	isThreefoldRepetition() {
		/* TODO: while this function is fine for casual use, a better
		* implementation would use a Zobrist key (instead of FEN). the
		* Zobrist key would be maintained in the make_move/undo_move
		functions,
		* avoiding the costly that we do below.
		*/
		const moves = []
		const positions: Record<string, number> = {}
		let repetition = false

		while (true) {
			const move = this._undoMove()
			if (!move) break
				moves.push(move)
		}

		while (true) {
			/* remove the last two fields in the FEN string, they're not needed
			* when checking for draw by rep */
			const fen = this.fen().split(" ").filter((v, i) => {
				return i < 4;
			}) .join();
			// const fen = this.fen().split(' ').slice(0, 4).join(' ')

			/* has the position occurred three or move times */
			positions[fen] = fen in positions ? positions[fen] + 1 : 1
			if (positions[fen] >= 3) {
				repetition = true
			}

			const move = moves.pop()

			if (!move) {
				break
			} else {
				this._makeMove(move)
			}
		}

		return repetition
	}

	isDraw() {
		return (
			this._halfMoves >= 100 || // 50 moves per side = 100 half moves
			this.isStalemate() ||
			this.isInsufficientMaterial() ||
			this.isThreefoldRepetition()
		)
	}

	isGameOver() {
		return this.isCheckmate() || this.isStalemate() || this.isDraw()
	}

	moves({
		verbose = false,
		square = undefined,
		piece = undefined,
		warna = undefined
	}: { verbose?: boolean; square?: Square, piece?: PieceSymbol, warna?: Color } = {}): Move[] | Square[] {
		const moves = this._moves({ square, piece, warna })

		if (verbose) {
			return moves.map((move) => this._makePretty(move))
		} else {
			return moves.map((move) => this._moveToSan(move, moves)) as Square[]
		}
	}

	_moves({
		legal = true,
		piece = undefined,
		square = undefined,
		warna = this._turn
	}: {
		legal?: boolean
		piece?: PieceSymbol
		square?: Square,
		warna?: Color,
	} = {}) {
		const forSquare = square ? (square.lower() as Square) : undefined
		const forPiece = piece?.lower()

		const moves: InternalMove[] = []
		const us = warna;
		const them = swapColor(us)

		let firstSquare = Ox88.a8
		let lastSquare = Ox88.h1
		let singleSquare = false

		/* are we generating moves for a single square? */
		if (forSquare) {
		// illegal square, return empty moves
			if (!(forSquare in Ox88)) {
				return []
			} else {
				firstSquare = lastSquare = Ox88[forSquare]
				singleSquare = true
			}
		}

		// print(this._board);
		for (let from = firstSquare; from <= lastSquare; from++) {
			/* did we run off the end of the board */
			if (from & 0x88) {
				from += 7
				continue
			}

			// empty square or opponent, skip
			// print(this._board[from])
			if (!this._board[from] || this._board[from].color === them) {
				continue
			}
			// print(this._board[from], from);
			const piece = this._board[from]

			let to: number
			if (piece.type === PAWN) {
				if (forPiece && forPiece !== piece.type) continue

				/* single square, non-capturing */
				to = from + PAWN_OFFSETS[us][0]
				if (!this._board[to]) {
					addMove(moves, us, from, to, PAWN)

					/* double square */
					to = from + PAWN_OFFSETS[us][1]
					if (SECOND_RANK[us] === rank(from) && !this._board[to]) {
						addMove(moves, us, from, to, PAWN, undefined, BITS.get("BIG_PAWN"))
					}
				}

				/* pawn captures */
				for (let j = 2; j < 4; j++) {
					to = from + PAWN_OFFSETS[us][j]
					if (to & 0x88) continue

					if (this._board[to]?.color === them) {
						addMove(
							moves,
							us,
							from,
							to,
							PAWN,
							this._board[to].type,
							BITS.get("CAPTURE")
						)
					} else if (to === this._epSquare) {
						addMove(moves, us, from, to, PAWN, PAWN, BITS.get("EP_CAPTURE"))
					}
				}
			} else {
				if (forPiece && forPiece !== piece.type) continue

				for (let j = 0, len = PIECE_OFFSETS[piece.type].size(); j < len; j++) {
					const offset = PIECE_OFFSETS[piece.type][j]
					to = from

					while (true) {
						to += offset
						if (to & 0x88) break

						if (!this._board[to]) {
							addMove(moves, us, from, to, piece.type)
						} else {
						// own color, stop loop
						if (this._board[to].color === us) break
							addMove(
								moves,
								us,
								from,
								to,
								piece.type,
								this._board[to].type,
								BITS.get("CAPTURE")
							)
							break
						}

						/* break, if knight or king */
						if (piece.type === KNIGHT || piece.type === KING) break
					}
				}
			}
		}

		/* check for castling if:
		* a) we're generating all moves, or
		* b) we're doing single square move generation on the king's square
		*/
		if (forPiece === undefined || forPiece === KING) {
			if (!singleSquare || lastSquare === this._kings[us]) {
				/* king-side castling */
				if (this._castling[us] & BITS.get("KSIDE_CASTLE")!) {
					const castlingFrom = this._kings[us]
					const castlingTo = castlingFrom + 2

					if (
						!this._board[castlingFrom + 1] &&
						!this._board[castlingTo] &&
						!this._attacked(them, this._kings[us]) &&
						!this._attacked(them, castlingFrom + 1) &&
						!this._attacked(them, castlingTo)
					) {
						addMove(
						moves,
						us,
						this._kings[us],
						castlingTo,
						KING,
						undefined,
						BITS.get("KSIDE_CASTLE")
						)
					}
					}
					/* queen-side castling */
					if (this._castling[us] & BITS.get("QSIDE_CASTLE")!) {
					const castlingFrom = this._kings[us]
					const castlingTo = castlingFrom - 2

					if (
						!this._board[castlingFrom - 1] &&
						!this._board[castlingFrom - 2] &&
						!this._board[castlingFrom - 3] &&
						!this._attacked(them, this._kings[us]) &&
						!this._attacked(them, castlingFrom - 1) &&
						!this._attacked(them, castlingTo)
					) {
						addMove(
							moves,
							us,
							this._kings[us],
							castlingTo,
							KING,
							undefined,
							BITS.get("QSIDE_CASTLE")
						)
					}
				}
			}
		}

		/* return all pseudo-legal moves (this includes moves that allow the king
		* to be captured) */
		if (!legal) {
			return moves
		}

		/* filter out illegal moves */
		const legalMoves = []

		for (let i = 0, len = moves.size(); i < len; i++) {
			this._makeMove(moves[i])
			if (!this._isKingAttacked(us)) {
				legalMoves.push(moves[i])
			}
			this._undoMove()
		}

		return legalMoves
	}

	move(
		move: string | DataMove,
		{ sloppy = false }: { sloppy?: boolean } = {}
	) 	{
		/* The move function can be called with in the following parameters:
			*
			* .move('Nxb7')      <- where 'move' is a case-sensitive SAN string
			*
			* .move({ from: 'h7', <- where the 'move' is a move object
			(additional
			*         to :'h8',      fields are ignored)
			*         promotion: 'q',
			*      })
			*/

		// sloppy parser allows the move parser to work around over disambiguation
		// bugs in Fritz and Chessbase

		let moveObj = undefined
		
		if (typeOf(move) === 'string') {
			moveObj = this._moveFromSan(move as string, sloppy);
		} else if (typeOf(move) !== "string") {
			const moves = this._moves()

			/* convert the pretty move object to an ugly move object */
			for (let i = 0, len = moves.size(); i < len; i++) {
				if (
					// eslint-disable-next-line
					(move as any).from === algebraic(moves[i].from) &&
					// eslint-disable-next-line
					(move as any).to === algebraic(moves[i].to) &&
					// eslint-disable-next-line
					(!('promotion' in moves[i]) || (move as any).promotion === moves[i].promotion)
				) {
					moveObj = moves[i]
					break
				}
			}
		}

		/* failed to find move */
		if (!moveObj) {
			return undefined
		}

		/* need to make a copy of move because we can't generate SAN after
		the move is made */
		const prettyMove = this._makePretty(moveObj)

		this._makeMove(moveObj)

		return prettyMove
	}

	_push(move: InternalMove) {
		this._history.push({
			move,
			kings: { b: this._kings.b, w: this._kings.w },
			turn: this._turn,
			castling: { b: this._castling.b, w: this._castling.w },
			epSquare: this._epSquare,
			halfMoves: this._halfMoves,
			moveNumber: this._moveNumber,
		})
	}

	private _makeMove(move: InternalMove) {
		const us = this._turn
		const them = swapColor(us)
		this._push(move)

		this._board[move.to] = this._board[move.from]
		delete this._board[move.from]

		/* if ep capture, remove the captured pawn */
		if (move.flags & BITS.get("EP_CAPTURE")!) {
			if (this._turn === BLACK) {
				delete this._board[move.to - 16]
			} else {
				delete this._board[move.to + 16]
			}
		}

		/* if pawn promotion, replace with new piece */
		if (move.promotion) {
			this._board[move.to] = { type: move.promotion, color: us }
		}

		/* if we moved the king */
		if (this._board[move.to].type === KING) {
			this._kings[us] = move.to

			/* if we castled, move the rook next to the king */
			if (move.flags & BITS.get("KSIDE_CASTLE")!) {
				const castlingTo = move.to - 1
				const castlingFrom = move.to + 1
				this._board[castlingTo] = this._board[castlingFrom]
				delete this._board[castlingFrom]
			} else if (move.flags & BITS.get("QSIDE_CASTLE")!) {
				const castlingTo = move.to + 1
				const castlingFrom = move.to - 2
				this._board[castlingTo] = this._board[castlingFrom]
				delete this._board[castlingFrom]
			}

			/* turn off castling */
			this._castling[us] = 0
		}

		/* turn off castling if we move a rook */
		if (this._castling[us]) {
			for (let i = 0, len = ROOKS[us].size(); i < len; i++) {
				if (
					move.from === ROOKS[us][i].square &&
					this._castling[us] & ROOKS[us][i].flag!
				) {
					this._castling[us] ^= ROOKS[us][i].flag!
					break
				}
			}
		}

		/* turn off castling if we capture a rook */
		if (this._castling[them]) {
			for (let i = 0, len = ROOKS[them].size(); i < len; i++) {
				if (
					move.to === ROOKS[them][i].square &&
					this._castling[them] & ROOKS[them][i].flag!
				) {
					this._castling[them] ^= ROOKS[them][i].flag!
					break
				}
			}
		}

		/* if big pawn move, update the en passant square */
		if (move.flags & BITS.get("BIG_PAWN")!) {
		if (us === BLACK) {
			this._epSquare = move.to - 16
		} else {
			this._epSquare = move.to + 16
		}
		} else {
			this._epSquare = EMPTY
		}

		/* reset the 50 move counter if a pawn is moved or a piece is captured */
		if (move.piece === PAWN) {
			this._halfMoves = 0
		} else if (move.flags & (BITS.get("CAPTURE")! | BITS.get("EP_CAPTURE")!)) {
			this._halfMoves = 0
		} else {
			this._halfMoves++
		}

		if (us === BLACK) {
			this._moveNumber++
		}

		this._turn = them
	}

	undo() {
		const move = this._undoMove()
		return move ? this._makePretty(move) : undefined
	}

	private _undoMove() {
		const old = this._history.pop()
		if (old === undefined) {
			return undefined
		}

		const move = old.move

		this._kings = old.kings
		this._turn = old.turn
		this._castling = old.castling
		this._epSquare = old.epSquare
		this._halfMoves = old.halfMoves
		this._moveNumber = old.moveNumber

		const us = this._turn
		const them = swapColor(us)

		this._board[move.from] = this._board[move.to]
		this._board[move.from].type = move.piece // to undo any promotions
		delete this._board[move.to]

		if (move.captured) {
			if (move.flags & BITS.get("EP_CAPTURE")!) {
				// en passant capture
				let index: number
				if (us === BLACK) {
					index = move.to - 16
				} else {
					index = move.to + 16
				}
				this._board[index] = { type: PAWN, color: them }
			} else {
				// regular capture
				this._board[move.to] = { type: move.captured, color: them }
			}
		}

		if (move.flags & (BITS.get("KSIDE_CASTLE")! | BITS.get("QSIDE_CASTLE")!)) {
			let castlingTo: number, castlingFrom: number
			if (move.flags & BITS.get("KSIDE_CASTLE")!) {
				castlingTo = move.to + 1
				castlingFrom = move.to - 1
			} else {
				castlingTo = move.to - 2
				castlingFrom = move.to + 1
			}

			this._board[castlingTo] = this._board[castlingFrom]
			delete this._board[castlingFrom]
		}

		return move
	}

	DapatinPGN() {
		return this.pgn().gsub("{nil}", "")[0].gsub('%s+', ' ')[0].gsub("^%s+", "")[0]
	}

	pgn({
		newline = '\n',
		maxWidth = 0,
	}: { newline?: string; maxWidth?: number } = {}) {
		/* using the specification from http://www.chessclub.com/help/PGN-spec
		* example for html usage: .pgn({ max_width: 72, newline_char: "<br />" })
		*/
		const result: string[] = []
		let headerExists = false

		/* add the PGN header information */
		this._header.forEach((v, k) => {
			result.push('[' + k + ' "' + v + '"]' + newline);
			headerExists = true;
		})
		// for (const i in this._header) {
		//   result.push('[' + i + ' "' + this._header[i] + '"]' + newline)
		//   headerExists = true
		// }

		if (headerExists && this._history.size()) {
			result.push(newline)
		}

		const appendComment = (moveString: string) => {
			const comment = this._comments.get(this.fen())
			if (typeOf(comment) !== undefined) {
				const delimiter = moveString.size() > 0 ? ' ' : '';
				moveString = `${moveString}${delimiter}{${comment}}`
			}
			return moveString
		}

		/* pop all of history onto reversed_history */
		const reversedHistory: InternalMove[] = []
		while (this._history.size() > 0) {
			reversedHistory.push(this._undoMove()!)
		}

		const moves = []
		let moveString = ''

		/* special case of a commented starting position with no moves */
		if (reversedHistory.size() === 0) {
			moves.push(appendComment(''))
		}
		/* build the list of moves.  a move_string looks like: "3. e3 e6" */
		while (reversedHistory.size() > 0) {
			moveString = appendComment(moveString)
			const move = reversedHistory.pop()!
			// make TypeScript stop complaining about move being undefined
			if (!move) {
				break
			}

			/* if the position started with black to move, start PGN with #. ... */
			if (!this._history.size() && move.color === 'b') {
				const prefix = `${this._moveNumber}. ...`
				/* is there a comment preceding the first move? */
				moveString = moveString ? `${moveString} ${prefix}` : prefix
			} else if (move.color === 'w') {
				/* store the previous generated move_string if we have one */
				if (moveString.size()) {
					moves.push(moveString)
				}
				moveString = this._moveNumber + '.'
			}

			moveString = moveString + ' ' + this._moveToSan(move, this._moves({ legal: true }))
			this._makeMove(move)
		}

			/* are there any other leftover moves? */
		if (moveString.size()) {
			moves.push(appendComment(moveString))
		}

			/* is there a result? */
		if (typeOf(this._header.get("Result")) !== undefined) {
			moves.push(this._header.get("Result")!)
		}

		/* history should be back to what it was before we started generating PGN,
		* so join together moves
		*/
		if (maxWidth === 0) {
			return result.join('') + moves.join(' ')
		}

			// JAH: huh?
		const strip = function () {
			if (result.size() > 0 && result[result.size() - 1] === ' ') {
				result.pop()
				return true
			}
			return false
		}

			/* NB: this does not preserve comment whitespace. */
		const wrapComment = function (width: number, move: string) {
			for (const token of move.split(' ')) {
				if (!token) {
					continue
				}
				if (width + token.size() > maxWidth) {
					while (strip()) {
						width--
					}
					result.push(newline)
					width = 0
				}
				result.push(token)
				width += token.size()
				result.push(' ')
				width++
			}
			if (strip()) {
				width--
			}
			return width
		}

			/* wrap the PGN output at max_width */
		let currentWidth = 0
		for (let i = 0; i < moves.size(); i++) {
			if (currentWidth + moves[i].size() > maxWidth) {
				if (moves[i].find('{') !== undefined) {
					currentWidth = wrapComment(currentWidth, moves[i])
					continue
				}
			}
			/* if the current move will push past max_width */
			if (currentWidth + moves[i].size() > maxWidth && i !== 0) {
				/* don't end the line with whitespace */
				if (result[result.size() - 1] === ' ') {
					result.pop()
				}

				result.push(newline)
				currentWidth = 0
			} else if (i !== 0) {
				result.push(' ')
				currentWidth++
			}
			result.push(moves[i])
			currentWidth += moves[i].size()
		}

		return result.join('')
	}

	header(...args: string[]) {
		for (let i = 0; i < args.size(); i += 2) {
			if (typeOf(args[i]) === 'string' && typeOf(args[i + 1]) === 'string') {
				this._header.set(args[i], args[i + 1])
			}
		}
		return this._header
	}

	loadPgn(
		pgn: string,
		{
		sloppy = false,
		newlineChar = '\r?\n',
		}: { sloppy?: boolean; newlineChar?: string } = {}
	) {
		// option sloppy=true
		// allow the user to specify the sloppy move parser to work around over
		// disambiguation bugs in Fritz and Chessbase

		function mask(str: string): string {
			return str.gsub('\\', '\\\\')[0];
		}

		function parsePgnHeader(header: string): { [key: string]: string } {
			const headerObj: Record<string, string> = {}
			const headers = header.split(mask(newlineChar));
			let key = ''
			let value = ''

			for (let i = 0; i < headers.size(); i++) {
				const regex = `^%s*[([A-Za-z]+)%s*"(.*)"%s*]%s*$`
				key = headers[i].gsub(regex, '$1')[0];
				value = headers[i].gsub(regex, '$2')[0];
				if (trimString(key).size() > 0) {
					headerObj[key] = value
				}
			}

			return headerObj
		}

		// strip whitespace from head/tail of PGN block
		pgn = trimString(pgn)

		// RegExp to split header. Takes advantage of the fact that header and movetext
		// will always have a blank line between them (ie, two newline_char's).
		// With default newline_char, will equal: /^(\[((?:\r?\n)|.)*\])(?:\s*\r?\n){2}/
		const headerRegex = '^(\\[((?:' + mask(newlineChar) + ')|.)*\\])' + '(?:\\s*' + mask(newlineChar) + '){2}'

		// If no header given, begin with moves.
		const headerRegexResults: string = headerRegex.match(pgn)[0] as string
		const headerString = headerRegexResults
		? headerRegexResults.size() >= 2
			? headerRegexResults.sub(1, 1)
			: ''
		: ''

		// Put the board in the starting position
		this.reset()

		/* parse PGN header */
		const headers = parsePgnHeader(headerString)
		let fen = ''
		
		for(const key_val of pairs(headers)) {
			if((key_val[0] as string).lower() === "fen") {
				fen = headers[key_val[0]];
			}

			this.header(key_val[0] as string, headers[key_val[0]]);
		}
		// for (const key in headers) {
		//   if (key.toLowerCase() === 'fen') {
		//     fen = headers[key]
		//   }

		//   this.header(key, headers[key])
		// }

		/* sloppy parser should attempt to load a fen tag, even if it's
		* the wrong case and doesn't include a corresponding [SetUp "1"] tag */
		if (sloppy) {
		if (fen) {
			if (!this.load(fen, true)) {
			return false
			}
		}
		} else {
		/* strict parser - load the starting position indicated by [Setup '1']
		* and [FEN position] */
		if (headers['SetUp'] === '1') {
			if (!('FEN' in headers && this.load(headers['FEN'], true))) {
			// second argument to load: don't clear the headers
			return false
			}
		}
		}

		/* NB: the regexes below that delete move numbers, recursive
		* annotations, and numeric annotation glyphs may also match
		* text in comments. To prevent this, we transform comments
		* by hex-encoding them in place and decoding them again after
		* the other tokens have been deleted.
		*
		* While the spec states that PGN files should be ASCII encoded,
		* we use {en,de}codeURIComponent here to support arbitrary UTF8
		* as a convenience for modern users */

		function encodeURIComponent(str: string): string {
			const char_to_hex = function(d: string) {
				return string.format("%%%02X", string.byte(d)[0])
			}
			
			str = str.gsub("\n", "\r\n")[0]
			str = str.gsub("([^%w ])", char_to_hex)[0]
			str = str.gsub(" ", "+")[0]
			return str
		}

		function decodeURIComponent(str: string): string {
			const hex_to_char = function(x: string) {
				return string.char(tonumber(x, 16)!)
			}
			
			str = str.gsub("+", "")[0];
			str = str.gsub("%%(%x%x)", hex_to_char)[0];
			return str;
		}

		function toHex(s: string): string {
			return s.split('')
				.map(function (c) {
				/* encodeURI doesn't transform most ASCII characters,
				* so we handle these ourselves */
				return c.sub(0, 0).byte()[0] < 128
					? c.format("%X", tostring(c.sub(0, 0).byte()[0]))
					: encodeURIComponent(c).gsub("%", '')[0].lower()
				})
				.join('')
		}

		function fromHex(s: string): string {
			return s.size() === 0
				? ''
				: decodeURIComponent('%' + ((s.match(".{1,2}")[0] as string).split("") || []).join('%'))
		}

		const encodeComment = function (s: string) {
			s = s.gsub(mask(newlineChar), ' ')[0];
			return `{${toHex(s.split("").filter((v, i) => {
				return i >= 1 && i < s.size() - 1;
			}).join())}}`
		}

		const decodeComment = function (s: string) {
			if (s.sub(0, 0) === "{" && s.sub(s.size()-1, s.size()-1) === "}") {
				return fromHex(s.split("").filter((v, i) => {
					return i >= 1 && i < s.size() - 1;
				}).join())
			}
		}

		/* delete header to get the moves */
		let ms = pgn
		.gsub(headerString, '')[0]
		//   .gsub(
		//     /* encode comments so they don't get deleted below */
		//     new RegExp(`({[^}]*})+?|;([^${mask(newlineChar)}]*)`, 'g'),
		//     function (_match, bracket, semicolon) {
		//       return bracket !== undefined
		//         ? encodeComment(bracket)
		//         : ' ' + encodeComment(`{${semicolon.slice(1)}}`)
		//     }
		//   )[0]
		.gsub(mask(newlineChar), ' ')[0]

		/* delete recursive annotation variations */
		const ravRegex = "([^()]+)+?"
		// const ravRegex = /(\([^()]+\))+?/g
		while (ms.match(ravRegex)[0]) {
			ms = ms.gsub(ravRegex, '')[0]
		}

		/* delete move numbers */
		ms = ms.gsub("%d+.(..)", '')[0]

		/* delete ... indicating black to move */
		ms = ms.gsub("...", '')[0]

		/* delete numeric annotation glyphs */
		ms = ms.gsub("%d+", '')[0]

		/* trim and get array of moves */
		let moves = trimString(ms).split(" ")

		/* delete empty entries */
		moves = moves.join(',').gsub("[,,+]", ',')[0].split(',')

		let result = ''

		for (let halfMove = 0; halfMove < moves.size(); halfMove++) {
			const comment = decodeComment(moves[halfMove])
			if (comment !== undefined) {
				this._comments.set(this.fen(), comment)
				continue
			}

			const move = this._moveFromSan(moves[halfMove], sloppy)

			/* invalid move */
			if (move === undefined) {
				/* was the move an end of game marker */
				if (TERMINATION_MARKERS.indexOf(moves[halfMove]) > -1) {
					result = moves[halfMove]
				} else {
					return false
				}
			} else {
				/* reset the end of game marker if making a valid move */
				result = ''
				this._makeMove(move)
			}
		}

		/* Per section 8.2.6 of the PGN spec, the Result tag pair must match
	* match the termination marker. Only do this when headers are
			present,
			* but the result tag is missing
			*/
		if (result && this._header.size() && !this._header.get("Result")) {
			this.header('Result', result)
		}

		return true
	}

  /* convert a move from 0x88 coordinates to Standard Algebraic Notation
    * (SAN)
    *
    * @param {boolean} sloppy Use the sloppy SAN generator to work around
    over
    * disambiguation bugs in Fritz and Chessbase.  See below:
    *
    * r1bqkbnr/ppp2ppp/2n5/1B1pP3/4P3/8/PPPP2PP/RNBQK1NR b KQkq - 2 4
    * 4. ... Nge7 is overly disambiguated because the knight on c6 is pinned
    * 4. ... Ne7 is technically the valid SAN
    */
	private _moveToSan(move: InternalMove, moves: InternalMove[]) {
		let output = ''

		if (move.flags & BITS.get("KSIDE_CASTLE")!) {
			output = 'O-O'
		} else if (move.flags & BITS.get("QSIDE_CASTLE")!) {
			output = 'O-O-O'
		} else {
			if (move.piece !== PAWN) {
				const disambiguator = getDisambiguator(move, moves)
				output += move.piece.upper() + disambiguator
			}

			if (move.flags & (BITS.get("CAPTURE")! | BITS.get("EP_CAPTURE")!)) {
				if (move.piece === PAWN) {
					output += algebraic(move.from).sub(1, 1);
				}
				output += 'x'
			}

			output += algebraic(move.to)

			if (move.promotion) {
				output += '=' + move.promotion.upper()
			}
		}

		this._makeMove(move)
		if (this.isCheck()) {
			if (this.isCheckmate()) {
				output += '#'
			} else {
				output += '+'
			}
		}
		this._undoMove()

		return output
	}

  // convert a move from Standard Algebraic Notation (SAN) to 0x88
  // coordinates
  private _moveFromSan(move: string, sloppy = false): InternalMove | undefined {
    // strip off any move decorations: e.g Nf3+?! becomes Nf3
    const cleanMove = strippedSan(move)

    let pieceType = inferPieceType(cleanMove)
    let moves = this._moves({ legal: true, piece: pieceType })

    // strict parser
    for (let i = 0, len = moves.size(); i < len; i++) {
		if (cleanMove === strippedSan(this._moveToSan(moves[i], moves))) {
			return moves[i]
		}
    }

    // strict parser failed and the sloppy parser wasn't used, return null
    if (!sloppy) {
      return undefined
    }

    let piece = undefined
    let matches = undefined
    let from = undefined
    let to = undefined
    let promotion = undefined

    // The sloppy parser allows the user to parse non-standard chess
    // notations. This parser is opt-in (by specifying the
    // '{ sloppy: true }' setting) and is only run after the Standard
    // Algebraic Notation (SAN) parser has failed.
    //
    // When running the sloppy parser, we'll run a regex to grab the piece,
    // the to/from square, and an optional promotion piece. This regex will
    // parse common non-standard notation like: Pe2-e4, Rc1c4, Qf3xf7,
    // f7f8q, b1c3

    // NOTE: Some positions and moves may be ambiguous when using the
    // sloppy parser. For example, in this position:
    // 6k1/8/8/B7/8/8/8/BN4K1 w - - 0 1, the move b1c3 may be interpreted
    // as Nc3 or B1c3 (a disambiguated bishop move). In these cases, the
    // sloppy parser will default to the most most basic interpretation
    // (which is b1c3 parsing to Nc3).

    // FIXME: these var's are hoisted into function scope, this will need
    // to change when switching to const/let

    let overlyDisambiguated = false
    
    // matches = cleanMove.match('([pnbrqkPNBRQK])?([a-h][1-8])x?-?([a-h][1-8])([qrbnQRBN])')
    matches = cleanMove.match("([pnbrqkPNBRQK])")
    matches = cleanMove.match(
      "([pnbrqkPNBRQK])?([a-h][1-8])x?-?([a-h][1-8])([qrbnQRBN])?"
      //     piece         from              to       promotion
    )

    if (matches[0]) {
        piece = matches[1]
        from = matches[2] as Square
        to = matches[3] as Square
        promotion = matches[4]

        if (from.size() === 1) {
            overlyDisambiguated = true
        }
    } else {
      // The [a-h]?[1-8]? portion of the regex below handles moves that may
      // be overly disambiguated (e.g. Nge7 is unnecessary and non-standard
      // when there is one legal knight move to e7). In this case, the value
      // of 'from' variable will be a rank or file, not a square.
        matches = cleanMove.match(
            "([pnbrqkPNBRQK])?([a-h]?[1-8]?)x?-?([a-h][1-8])([qrbnQRBN])?"
        )

        if(matches[0]) {
            piece = matches[1]
            from = matches[2] as Square
            to = matches[3] as Square
            promotion = matches[4]

            if (from.size() === 1) {
                overlyDisambiguated = true
            }
        }
    }

    pieceType = inferPieceType(cleanMove)
    moves = this._moves({
      legal: true,
      piece: piece ? (piece as PieceSymbol) : pieceType,
    })

    for (let i = 0, len = moves.size(); i < len; i++) {
      if (from && to) {
        // hand-compare move properties with the results from our sloppy
        // regex
        if (
          (!piece || (piece as string).lower() === moves[i].piece) &&
          Ox88[from] === moves[i].from &&
          Ox88[to] === moves[i].to &&
          (!promotion || (promotion as string).lower() === moves[i].promotion)
        ) {
          return moves[i]
        } else if (overlyDisambiguated) {
          // SPECIAL CASE: we parsed a move string that may have an
          // unneeded rank/file disambiguator (e.g. Nge7).  The 'from'
          // variable will

          const square = algebraic(moves[i].from)
          if (
            (!piece || (piece as string).lower() === moves[i].piece) &&
            Ox88[to] === moves[i].to &&
            (from === square.sub(1, 1) || from === square.sub(2, 2)) &&
            (!promotion || (promotion as string).lower() === moves[i].promotion)
          ) {
            return moves[i]
          }
        }
      }
    }

    return undefined
  }

  ascii() {
    let s = '   +------------------------+\n'
    for (let i = Ox88.a8; i <= Ox88.h1; i++) {
      /* display the rank */
      if (file(i) === 0) {
        const ranking = rank(i)
        s += ' ' + '87654321'.sub(ranking, ranking) + ' |'
      }

      if (this._board[i]) {
        const piece = this._board[i].type
        const color = this._board[i].color
        const symbol =
          color === WHITE ? piece.upper() : piece.lower()
        s += ' ' + symbol + ' '
      } else {
        s += ' . '
      }

      if ((i + 1) & 0x88) {
        s += '|\n'
        i += 8
      }
    }
    s += '   +------------------------+\n'
    s += '     a  b  c  d  e  f  g  h'

    return s
  }

  perft(depth: number) {
    const moves = this._moves({ legal: false })
    let nodes = 0
    const color = this._turn

    for (let i = 0, len = moves.size(); i < len; i++) {
      this._makeMove(moves[i])
      if (!this._isKingAttacked(color)) {
        if (depth - 1 > 0) {
          nodes += this.perft(depth - 1)
        } else {
          nodes++
        }
      }
      this._undoMove()
    }

    return nodes
  }

  private _makePretty(uglyMove: InternalMove): Move {
    const { color, piece, from, to, flags, captured, promotion } = uglyMove

    let prettyFlags = ''

    BITS.forEach((v, k) => {
        if(v & flags) {
            prettyFlags += FLAGS[k];
        }
    })
    // for (const flag in BITS) {
    //   if (BITS[flag] & flags) {
    //     prettyFlags += FLAGS[flag]
    //   }
    // }

    const move: Move = {
      color,
      piece,
      from: algebraic(from),
      to: algebraic(to),
      san: this._moveToSan(uglyMove, this._moves({ legal: true })),
      flags: prettyFlags,
    }

    if (captured) {
      move.captured = captured
    }
    if (promotion) {
      move.promotion = promotion
    }

    return move
  }

	turn() {
		return this._turn
	}

	GantiTurn(warna: Color) {
		this._turn = warna;
		return this._turn;
	}

  board() {
    const output = []
    let row = []

    for (let i = Ox88.a8; i <= Ox88.h1; i++) {
      if (this._board[i] === undefined) {
        row.push(undefined)
      } else {
        row.push({
          square: algebraic(i),
          type: this._board[i].type,
          color: this._board[i].color,
        })
      }
      if ((i + 1) & 0x88) {
        output.push(row)
        row = []
        i += 8
      }
    }

    return output
  }

  squareColor(square: Square) {
    if (square in Ox88) {
      const sq = Ox88[square]
      return (rank(sq) + file(sq)) % 2 === 0 ? 'light' : 'dark'
    }

    return undefined
  }

  history({ verbose = false }: { verbose?: boolean } = {}) {
    const reversedHistory = []
    const moveHistory = []

    while (this._history.size() > 0) {
      reversedHistory.push(this._undoMove())
    }

    while (true) {
      const move = (reversedHistory as InternalMove[]).pop()
      if (!move) {
        break
      }

      if (verbose) {
        moveHistory.push(this._makePretty(move))
      } else {
        moveHistory.push(this._moveToSan(move, this._moves()))
      }
      this._makeMove(move)
    }

    return moveHistory
  }

  private _pruneComments() {
    const reversedHistory: InternalMove[] = []
    const currentComments: Map<string, string> = new Map<string, string>();

    const copyComment = (fen: string) => {
      if (fen in this._comments) {
        currentComments.set("fen", this._comments.get('fen')!);
      }
    }

    while (this._history.size() > 0) {
      reversedHistory.push(this._undoMove()!)
    }

    copyComment(this.fen())

    while (true) {
      const move = reversedHistory.pop()
      if (!move) {
        break
      }
      this._makeMove(move)
      copyComment(this.fen())
    }
    this._comments = currentComments
  }

  getComment() {
    return this._comments.get(this.fen())
  }

  setComment(comment: string) {
    this._comments.set(this.fen(), comment.gsub('{', '[')[0].gsub('}', ']')[0]);
  }

  deleteComment() {
    const comment = this._comments.get(this.fen());
    this._comments.delete(this.fen());
    return comment
  }

  getComments() {
    this._pruneComments()
    const data: { fen: string, comment: string }[] = [];
    this._comments.forEach((v, k) => {
        data.push({
            fen: k,
            comment: v
        })
    })

    // return Object.keys(this._comments).map((fen: string) => {
    //   return { fen: fen, comment: this._comments[fen] }
    // })

    return data;
  }

  deleteComments() {
    this._pruneComments()
    this._comments

    const data: { fen: string, comment: string }[] = [];
    this._comments.forEach((v, k) => {
        data.push({
            fen: k,
            comment: v
        })
        this._comments.delete(k);
    })

    return data;

    // return Object.keys(this._comments).map((fen) => {
    //     const comment = this._comments[fen]
    //     delete this._comments[fen]
    //     return { fen: fen, comment: comment }
    // })
  }
}