-- Compiled with roblox-ts v2.0.4
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
--[[
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
	*----------------------------------------------------------------------------
]]
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local Glicko2 = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "glicko2").Glicko2
local Event = ReplicatedStorage.remote
local WHITE = "w"
local BLACK = "b"
local PAWN = "p"
local KNIGHT = "n"
local BISHOP = "b"
local ROOK = "r"
local QUEEN = "q"
local KING = "k"
-- prettier-ignore
local DEFAULT_POSITION = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
local EMPTY = -1
local FLAGS = {
	NORMAL = "n",
	CAPTURE = "c",
	BIG_PAWN = "b",
	EP_CAPTURE = "e",
	PROMOTION = "p",
	KSIDE_CASTLE = "k",
	QSIDE_CASTLE = "q",
}
-- prettier-ignore
local SQUARES = { "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8", "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7", "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6", "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5", "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4", "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3", "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2", "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1" }
local BITS = {
	NORMAL = 1,
	CAPTURE = 2,
	BIG_PAWN = 4,
	EP_CAPTURE = 8,
	PROMOTION = 16,
	KSIDE_CASTLE = 32,
	QSIDE_CASTLE = 64,
}
-- const BITS: Record<string, number> = {
-- NORMAL: 1,
-- CAPTURE: 2,
-- BIG_PAWN: 4,
-- EP_CAPTURE: 8,
-- PROMOTION: 16,
-- KSIDE_CASTLE: 32,
-- QSIDE_CASTLE: 64,
-- }
local Ox88 = {
	a8 = 0,
	b8 = 1,
	c8 = 2,
	d8 = 3,
	e8 = 4,
	f8 = 5,
	g8 = 6,
	h8 = 7,
	a7 = 16,
	b7 = 17,
	c7 = 18,
	d7 = 19,
	e7 = 20,
	f7 = 21,
	g7 = 22,
	h7 = 23,
	a6 = 32,
	b6 = 33,
	c6 = 34,
	d6 = 35,
	e6 = 36,
	f6 = 37,
	g6 = 38,
	h6 = 39,
	a5 = 48,
	b5 = 49,
	c5 = 50,
	d5 = 51,
	e5 = 52,
	f5 = 53,
	g5 = 54,
	h5 = 55,
	a4 = 64,
	b4 = 65,
	c4 = 66,
	d4 = 67,
	e4 = 68,
	f4 = 69,
	g4 = 70,
	h4 = 71,
	a3 = 80,
	b3 = 81,
	c3 = 82,
	d3 = 83,
	e3 = 84,
	f3 = 85,
	g3 = 86,
	h3 = 87,
	a2 = 96,
	b2 = 97,
	c2 = 98,
	d2 = 99,
	e2 = 100,
	f2 = 101,
	g2 = 102,
	h2 = 103,
	a1 = 112,
	b1 = 113,
	c1 = 114,
	d1 = 115,
	e1 = 116,
	f1 = 117,
	g1 = 118,
	h1 = 119,
}
local PAWN_OFFSETS = {
	b = { 16, 32, 17, 15 },
	w = { -16, -32, -17, -15 },
}
local PIECE_OFFSETS = {
	n = { -18, -33, -31, -14, 18, 33, 31, 14 },
	b = { -17, -15, 17, 15 },
	r = { -16, 1, 16, -1 },
	q = { -17, -16, -15, 1, 17, 16, 15, -1 },
	k = { -17, -16, -15, 1, 17, 16, 15, -1 },
}
local ATTACKS = { 20, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 20, 0, 0, 20, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 20, 0, 0, 0, 0, 24, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 24, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 24, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 2, 24, 2, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 53, 56, 53, 2, 0, 0, 0, 0, 0, 0, 24, 24, 24, 24, 24, 24, 56, 0, 56, 24, 24, 24, 24, 24, 24, 0, 0, 0, 0, 0, 0, 2, 53, 56, 53, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 2, 24, 2, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 24, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 24, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 24, 0, 0, 0, 0, 20, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 20, 0, 0, 20, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 20 }
local RAYS = { 17, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 15, 0, 0, 17, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 17, 0, 0, 0, 0, 16, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 16, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 16, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 16, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 16, 15, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, -15, -16, -17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -15, 0, -16, 0, -17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -15, 0, 0, -16, 0, 0, -17, 0, 0, 0, 0, 0, 0, 0, 0, -15, 0, 0, 0, -16, 0, 0, 0, -17, 0, 0, 0, 0, 0, 0, -15, 0, 0, 0, 0, -16, 0, 0, 0, 0, -17, 0, 0, 0, 0, -15, 0, 0, 0, 0, 0, -16, 0, 0, 0, 0, 0, -17, 0, 0, -15, 0, 0, 0, 0, 0, 0, -16, 0, 0, 0, 0, 0, 0, -17 }
local PIECE_MASKS = {
	p = 0x1,
	n = 0x2,
	b = 0x4,
	r = 0x8,
	q = 0x10,
	k = 0x20,
}
local SYMBOLS = "pnbrqkPNBRQK"
local PROMOTIONS = { KNIGHT, BISHOP, ROOK, QUEEN }
local RANK_1 = 7
local RANK_2 = 6
local RANK_7 = 1
local RANK_8 = 0
local ROOKS = {
	w = { {
		square = Ox88.a1,
		flag = BITS.QSIDE_CASTLE,
	}, {
		square = Ox88.h1,
		flag = BITS.KSIDE_CASTLE,
	} },
	b = { {
		square = Ox88.a8,
		flag = BITS.QSIDE_CASTLE,
	}, {
		square = Ox88.h8,
		flag = BITS.KSIDE_CASTLE,
	} },
}
local NomorKeStatus = {
	[1] = "Menang",
	[.5] = "Seri",
	[0] = "Kalah",
}
local SECOND_RANK = {
	b = RANK_7,
	w = RANK_2,
}
local TERMINATION_MARKERS = { "1-0", "0-1", "1/2-1/2", "*" }
local function reverse(array)
	local output = {}
	while true do
		local _value = #array
		if not (_value ~= 0 and (_value == _value and _value)) then
			break
		end
		-- ▼ Array.pop ▼
		local _length = #array
		local _result = array[_length]
		array[_length] = nil
		-- ▲ Array.pop ▲
		table.insert(output, _result)
	end
	return output
end
local function reverseArray(array)
	-- javascript, Kalau kamu mengubah variable array di dalam function, di globalnya juga berubah 15/12/2022 00:19
	local _array = {}
	local _length = #_array
	table.move(array, 1, #array, _length + 1, _array)
	local TemplateArray = _array
	return reverse(TemplateArray)
end
local function rank(square)
	return bit32.arshift(square, 4)
end
local function file(square)
	return bit32.band(square, 0xf)
end
local function isDigit(c)
	return if c == "" then false else (string.find("0123456789", c)) ~= nil
	-- return '0123456789'.indexOf(c) !== -1
end
local function algebraic(square)
	local f = file(square)
	local r = rank(square)
	local _arg0 = f + 1
	local _arg1 = f + 1
	local _exp = string.sub("abcdefgh", _arg0, _arg1)
	local _arg0_1 = r + 1
	local _arg1_1 = r + 1
	return _exp .. string.sub("87654321", _arg0_1, _arg1_1)
end
local function swapColor(color)
	return if color == WHITE then BLACK else WHITE
end
local function trimString(str)
	local c = { string.match(str, "^%s*(.-)%s*$") }
	return if c == nil then c else str
end
local pawnEvalWhite = { { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }, { 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0 }, { 1.0, 1.0, 2.0, 3.0, 3.0, 2.0, 1.0, 1.0 }, { 0.5, 0.5, 1.0, 2.5, 2.5, 1.0, 0.5, 0.5 }, { 0.0, 0.0, 0.0, 2.0, 2.0, 0.0, 0.0, 0.0 }, { 0.5, -0.5, -1.0, 0.0, 0.0, -1.0, -0.5, 0.5 }, { 0.5, 1.0, 1.0, -2.0, -2.0, 1.0, 1.0, 0.5 }, { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 } }
local pawnEvalBlack = reverseArray(pawnEvalWhite)
local knightEval = { { -5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0 }, { -4.0, -2.0, 0.0, 0.0, 0.0, 0.0, -2.0, -4.0 }, { -3.0, 0.0, 1.0, 1.5, 1.5, 1.0, 0.0, -3.0 }, { -3.0, 0.5, 1.5, 2.0, 2.0, 1.5, 0.5, -3.0 }, { -3.0, 0.0, 1.5, 2.0, 2.0, 1.5, 0.0, -3.0 }, { -3.0, 0.5, 1.0, 1.5, 1.5, 1.0, 0.5, -3.0 }, { -4.0, -2.0, 0.0, 0.5, 0.5, 0.0, -2.0, -4.0 }, { -5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0 } }
local bishopEvalWhite = { { -2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0 }, { -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0 }, { -1.0, 0.0, 0.5, 1.0, 1.0, 0.5, 0.0, -1.0 }, { -1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, -1.0 }, { -1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, -1.0 }, { -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0 }, { -1.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, -1.0 }, { -2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0 } }
local bishopEvalBlack = reverseArray(bishopEvalWhite)
local rookEvalWhite = { { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }, { 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5 }, { -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5 }, { -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5 }, { -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5 }, { -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5 }, { -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5 }, { 0.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0 } }
local rookEvalBlack = reverseArray(rookEvalWhite)
local evalQueen = { { -2.0, -1.0, -1.0, -0.5, -0.5, -1.0, -1.0, -2.0 }, { -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0 }, { -1.0, 0.0, 0.5, 0.5, 0.5, 0.5, 0.0, -1.0 }, { -0.5, 0.0, 0.5, 0.5, 0.5, 0.5, 0.0, -0.5 }, { 0.0, 0.0, 0.5, 0.5, 0.5, 0.5, 0.0, -0.5 }, { -1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.0, -1.0 }, { -1.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, -1.0 }, { -2.0, -1.0, -1.0, -0.5, -0.5, -1.0, -1.0, -2.0 } }
local kingEvalWhite = { { -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0 }, { -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0 }, { -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0 }, { -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0 }, { -2.0, -3.0, -3.0, -4.0, -4.0, -3.0, -3.0, -2.0 }, { -1.0, -2.0, -2.0, -2.0, -2.0, -2.0, -2.0, -1.0 }, { 2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0 }, { 2.0, 3.0, 1.0, 0.0, 0.0, 1.0, 3.0, 2.0 } }
local kingEvalBlack = reverseArray(kingEvalWhite)
local function validateFen(fen)
	local errors = {}
	errors[1] = "No errors."
	errors[2] = "FEN string must contain six space-delimited fields."
	errors[3] = "6th field (move number) must be a positive integer."
	errors[4] = "5th field (half move counter) must be a non-negative integer."
	errors[5] = "4th field (en-passant square) is invalid."
	errors[6] = "3rd field (castling availability) is invalid."
	errors[7] = "2nd field (side to move) is invalid."
	errors[8] = "1st field (piece positions) does not contain 8 '/'-delimited rows."
	errors[9] = "1st field (piece positions) is invalid [consecutive numbers]."
	errors[10] = "1st field (piece positions) is invalid [invalid piece]."
	errors[11] = "1st field (piece positions) is invalid [row too large]."
	errors[12] = "Illegal en-passant square"
	-- 1st criterion: 6 space-seperated fields?
	local tokens = string.split(fen, " ")
	if #tokens ~= 6 then
		return {
			valid = false,
			errorNumber = 1,
			error = errors[2],
		}
	end
	-- 2nd criterion: move number field is a integer value > 0?
	local moveNumber = tonumber(tokens[6], 10)
	if tostring(moveNumber) == "nan" or moveNumber <= 0 then
		return {
			valid = false,
			errorNumber = 2,
			error = errors[3],
		}
	end
	-- 3rd criterion: half move counter is an integer >= 0?
	local halfMoves = tonumber(tokens[5], 10)
	if tostring(halfMoves) == "nan" or halfMoves < 0 then
		return {
			valid = false,
			errorNumber = 3,
			error = errors[4],
		}
	end
	-- 4th criterion: 4th field is a valid e.p.-string?
	if not ({ string.match(tokens[4], "^([abcdefgh][36])$") } ~= nil or { string.match(tokens[4], "-") } ~= nil) then
		return {
			valid = false,
			errorNumber = 4,
			error = errors[5],
		}
	end
	-- if (!/^(-|[abcdefgh][36])$/.test(tokens[3])) {
	-- return { valid: false, errorNumber: 4, error: errors[4] }
	-- }
	-- 5th criterion: 3th field is a valid castle-string?
	-- if(!( string.match(tokens[2], 'KQ') !== undefined || ))
	-- if (!/^(KQ?k?q?|Qk?q?|kq?|q|-)$/.test(tokens[2])) {
	-- return { valid: false, errorNumber: 5, error: errors[5] }
	-- }
	-- 6th criterion: 2nd field is "w" (white) or "b" (black)?
	if not ({ string.match(tokens[2], "^[wb]$") } ~= nil) then
		return {
			valid = false,
			errorNumber = 6,
			error = errors[7],
		}
	end
	-- if (!/^(w|b)$/.test(tokens[1])) {
	-- return { valid: false, errorNumber: 6, error: errors[6] }
	-- }
	-- 7th criterion: 1st field contains 8 rows?
	local rows = string.split(tokens[1], "/")
	if #rows ~= 8 then
		return {
			valid = false,
			errorNumber = 7,
			error = errors[8],
		}
	end
	-- 8th criterion: every row is valid?
	do
		local i = 0
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				i += 1
			else
				_shouldIncrement = true
			end
			if not (i < #rows) then
				break
			end
			-- check for right sum of fields AND not two numbers in succession
			local sumFields = 0
			local previousWasNumber = false
			do
				local k = 0
				local _shouldIncrement_1 = false
				while true do
					if _shouldIncrement_1 then
						k += 1
					else
						_shouldIncrement_1 = true
					end
					if not (k < #rows[i + 1]) then
						break
					end
					local _exp = rows[i + 1]
					local _arg0 = k + 1
					local _arg1 = k + 1
					if isDigit(string.sub(_exp, _arg0, _arg1)) then
						if previousWasNumber then
							return {
								valid = false,
								errorNumber = 8,
								error = errors[9],
							}
						end
						local _exp_1 = rows[i + 1]
						local _arg0_1 = k + 1
						local _arg1_1 = k + 1
						sumFields += tonumber(string.sub(_exp_1, _arg0_1, _arg1_1), 10)
						previousWasNumber = true
					else
						local _fn = string
						local _exp_1 = rows[i + 1]
						local _arg0_1 = k + 1
						local _arg1_1 = k + 1
						if { _fn.match(string.sub(_exp_1, _arg0_1, _arg1_1), "^[prnbqkPRNBQK]$") } == nil then
							return {
								valid = false,
								errorNumber = 9,
								error = errors[10],
							}
						end
						sumFields += 1
						previousWasNumber = false
					end
				end
			end
			if sumFields ~= 8 then
				return {
					valid = false,
					errorNumber = 10,
					error = errors[11],
				}
			end
		end
	end
	-- Ubahin ke 2 kalau tidak bisa, lua moment
	if (string.sub(tokens[4], 1, 1) == "3" and tokens[2] == "w") or (string.sub(tokens[4], 1, 1) == "6" and tokens[2] == "b") then
		return {
			valid = false,
			errorNumber = 11,
			error = errors[12],
		}
	end
	-- everything's okay!
	return {
		valid = true,
		errorNumber = 0,
		error = errors[1],
	}
end
-- this function is used to uniquely identify ambiguous moves
local function getDisambiguator(move, moves)
	local from = move.from
	local to = move.to
	local piece = move.piece
	local ambiguities = 0
	local sameRank = 0
	local sameFile = 0
	do
		local i = 0
		local len = #moves
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				i += 1
			else
				_shouldIncrement = true
			end
			if not (i < len) then
				break
			end
			local ambigFrom = moves[i + 1].from
			local ambigTo = moves[i + 1].to
			local ambigPiece = moves[i + 1].piece
			--[[
				if a move of the same piece type ends on the same to square, we'll
				* need to add a disambiguator to the algebraic notation
			]]
			if piece == ambigPiece and (from ~= ambigFrom and to == ambigTo) then
				ambiguities += 1
				if rank(from) == rank(ambigFrom) then
					sameRank += 1
				end
				if file(from) == file(ambigFrom) then
					sameFile += 1
				end
			end
		end
	end
	if ambiguities > 0 then
		--[[
			if there exists a similar moving piece on the same rank and file
			as the move in question, use the square as the disambiguator
		]]
		if sameRank > 0 and sameFile > 0 then
			return algebraic(from)
		elseif sameFile > 0 then
			--[[
				if the moving piece rests on the same file, use the rank symbol
				as the disambiguator
			]]
			return string.sub(algebraic(from), 2, 2)
		else
			-- else use the file symbol
			return string.sub(algebraic(from), 1, 1)
		end
	end
	return ""
end
local function addMove(moves, color, from, to, piece, captured, flags)
	if captured == nil then
		captured = nil
	end
	if flags == nil then
		flags = BITS.NORMAL
	end
	local r = rank(to)
	if piece == PAWN and (r == RANK_1 or r == RANK_8) then
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < #PROMOTIONS) then
					break
				end
				local promotion = PROMOTIONS[i + 1]
				local _moves = moves
				local _arg0 = {
					color = color,
					from = from,
					to = to,
					piece = piece,
					captured = captured,
					promotion = promotion,
					flags = bit32.bor(flags, BITS.PROMOTION),
				}
				table.insert(_moves, _arg0)
			end
		end
	else
		local _moves = moves
		local _arg0 = {
			color = color,
			from = from,
			to = to,
			piece = piece,
			captured = captured,
			promotion = nil,
			flags = flags,
		}
		table.insert(_moves, _arg0)
	end
end
local function inferPieceType(san)
	local pieceType = string.sub(san, 0, 0)
	if pieceType >= "a" and pieceType <= "h" then
		local matches = { string.match(san, "[a-h]%d.*[a-h]%d") } ~= nil
		if matches then
			return nil
		end
		return PAWN
	end
	pieceType = string.lower(pieceType)
	if pieceType == "o" then
		return KING
	end
	return pieceType
end
local function strippedSan(move)
	-- probably bug
	return (string.gsub((string.gsub(move, "=", "")), "[+#]$", ""))
end
local CaturAI
do
	CaturAI = setmetatable({}, {
		__tostring = function()
			return "CaturAI"
		end,
	})
	CaturAI.__index = CaturAI
	function CaturAI.new(...)
		local self = setmetatable({}, CaturAI)
		return self:constructor(...) or self
	end
	function CaturAI:constructor()
	end
	function CaturAI:minimaxRoot(depth, chess, apakahMaximisingPemain)
		self.chess = chess
		local Pergerakan = chess:moves()
		local bestMove = -9999
		local bestMoveFound
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < #Pergerakan) then
					break
				end
				chess:move(Pergerakan[i + 1])
				local value = self:minimax(depth - 1, -10000, 10000, not apakahMaximisingPemain)
				chess:undo()
				if value >= bestMove then
					bestMove = value
					bestMoveFound = Pergerakan[i + 1]
				end
			end
		end
		return bestMoveFound
	end
	function CaturAI:minimax(depth, alpha, beta, apakahMaximisingPemain)
		if self.chess == nil then
			return 0
		end
		if depth == 0 then
			return -self:evaluateBoard(self.chess:board())
		end
		local Pergerakan = self.chess:moves()
		if apakahMaximisingPemain then
			local bestMove = -9999
			do
				local i = 0
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i += 1
					else
						_shouldIncrement = true
					end
					if not (i < #Pergerakan) then
						break
					end
					self.chess:move(Pergerakan[i + 1])
					bestMove = math.max(bestMove, self:minimax(depth - 1, alpha, beta, not apakahMaximisingPemain))
					self.chess:undo()
					alpha = math.max(alpha, bestMove)
					if beta <= alpha then
						return bestMove
					end
				end
			end
			return bestMove
		end
		local bestMove = 9999
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < #Pergerakan) then
					break
				end
				self.chess:move(Pergerakan[i + 1])
				bestMove = math.min(bestMove, self:minimax(depth - 1, alpha, beta, not apakahMaximisingPemain))
				self.chess:undo()
				beta = math.min(beta, bestMove)
				if beta <= alpha then
					return bestMove
				end
			end
		end
		return bestMove
	end
	function CaturAI:evaluateBoard(papan)
		local totalEvaluation = 0
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < 8) then
					break
				end
				do
					local j = 0
					local _shouldIncrement_1 = false
					while true do
						if _shouldIncrement_1 then
							j += 1
						else
							_shouldIncrement_1 = true
						end
						if not (j < 8) then
							break
						end
						totalEvaluation = totalEvaluation + self:dapatinPieceValue(i, j, papan[i + 1][j + 1])
					end
				end
			end
		end
		return totalEvaluation
	end
	function CaturAI:dapatinPieceValue(x, y, piece)
		if piece == nil then
			return 0
		end
		local dapatinAbsoluteValue = function(piece, apakahPutih, x, y)
			if piece.type == "p" then
				return 10 + (if apakahPutih then pawnEvalWhite[y + 1][x + 1] else pawnEvalBlack[y + 1][x + 1])
			end
			if piece.type == "r" then
				return 50 + (if apakahPutih then rookEvalWhite[y + 1][x + 1] else rookEvalBlack[y + 1][x + 1])
			end
			if piece.type == "n" then
				return 30 + knightEval[y + 1][x + 1]
			end
			if piece.type == "b" then
				return 30 + (if apakahPutih then bishopEvalWhite[y + 1][x + 1] else bishopEvalBlack[y + 1][x + 1])
			end
			if piece.type == "q" then
				return 90 + evalQueen[y + 1][x + 1]
			end
			if piece.type == "k" then
				return 900 + (if apakahPutih then kingEvalWhite[y + 1][x + 1] else kingEvalBlack[y + 1][x + 1])
			end
			return 0
		end
		local absoluteValue = dapatinAbsoluteValue(piece, piece.color == "w", x, y)
		return if piece.color == "w" then absoluteValue else -absoluteValue
	end
end
local Chess
do
	Chess = setmetatable({}, {
		__tostring = function()
			return "Chess"
		end,
	})
	Chess.__index = Chess
	function Chess.new(...)
		local self = setmetatable({}, Chess)
		return self:constructor(...) or self
	end
	function Chess:constructor(p1, mode, p2, fen, PerluWaktu, waktu)
		if fen == nil then
			fen = DEFAULT_POSITION
		end
		if PerluWaktu == nil then
			PerluWaktu = false
		end
		if waktu == nil then
			waktu = 600
		end
		self._board = table.create(128)
		self._turn = WHITE
		self._header = {}
		self._kings = {
			w = EMPTY,
			b = EMPTY,
		}
		self._epSquare = -1
		self._halfMoves = 0
		self._moveNumber = 0
		self._history = {}
		self._comments = {}
		self._castling = {
			w = 0,
			b = 0,
		}
		self.PerluWaktu = false
		local _object = {}
		for _k, _v in p1 do
			_object[_k] = _v
		end
		_object.waktu = waktu
		_object.SudahGerak = false
		_object.WaktuAFK = 0
		self.p1 = _object
		if p2 then
			local _object_1 = {}
			for _k, _v in p2 do
				_object_1[_k] = _v
			end
			_object_1.waktu = waktu
			_object_1.SudahGerak = false
			_object_1.WaktuAFK = 0
			self.p2 = _object_1
		end
		self.PerluWaktu = PerluWaktu
		if p2 ~= nil then
			self.mode = "player"
		else
			self.mode = mode
		end
		if self.mode == "komputer" then
			self.AICatur = CaturAI.new()
			self.WarnaKomputer = swapColor(p1.warna)
		end
		self.ranking = Glicko2.new({
			tau = .5,
			rating = 1500,
			rd = 200,
			vol = .06,
		})
		self:load(fen)
		-- TEST PGN
		-- this.move({ from: "f2", to: "f3" })
		-- this.move({ from: "e7", to: "e5" })
		-- this.move({ from: "g2", to: "g4" })
		-- [
		-- 'e4',   'e5',   'Nf3',   'Nc6',
		-- 'd4',   'exd4', 'Nxd4',  'Nxd4',
		-- 'Qxd4', 'Nf6',  'e5',    'Nh5',
		-- 'e6',   'dxe6', 'Qxd8+', 'Kxd8',
		-- 'Bg5+', 'Be7',  'Bxe7+', 'Kxe7',
		-- 'Nc3',  'Rd8',  'g4',    'Nf4',
		-- 'Bc4',  'g5'
		-- ].forEach((v) => {
		-- this.move(v);
		-- })
		-- this.move({ from: "e2", to: "e4" });
		-- this.move({ from: "e7", to: "e5" });
		-- this.move({ from: "g1", to: "f3" });
		-- this.move({ from: "g8", to: "f6" });
		-- this.move({ from: "f3", to: "e5" });
		-- this.move({ from: "f6", to: "e4" });
		-- this.move({ from: "d1", to: "e2" });
		-- this.move({ from: "d8", to: "e7" });
		-- this.move({ from: "e2", to: "e4" });
		-- this.move({ from: "d7", to: "d6" });
		-- this.move({ from: "b1", to: "c3" });
		if self.mode == "player" then
			self.RatingPemain1 = self:KalkulasiMenangKalah({
				point = p1.Pemain.DataPemain.DataPoint.Point.Value,
				rd = p1.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol = p1.Pemain.DataPemain.DataPoint.Volatility.Value,
				warna = p1.warna,
				Kalah = p1.Pemain.DataPemain.DataStatus.Kalah.Value,
				Menang = p1.Pemain.DataPemain.DataStatus.Menang.Value,
				Main = p1.Pemain.DataPemain.DataStatus.JumlahMain.Value,
			}, {
				point = p2.Pemain.DataPemain.DataPoint.Point.Value,
				rd = p2.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol = p2.Pemain.DataPemain.DataPoint.Volatility.Value,
			})
			self.RatingPemain2 = self:KalkulasiMenangKalah({
				point = p2.Pemain.DataPemain.DataPoint.Point.Value,
				rd = p2.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol = p2.Pemain.DataPemain.DataPoint.Volatility.Value,
				warna = p2.warna,
				Kalah = p2.Pemain.DataPemain.DataStatus.Kalah.Value,
				Menang = p2.Pemain.DataPemain.DataStatus.Menang.Value,
				Main = p2.Pemain.DataPemain.DataStatus.JumlahMain.Value,
			}, {
				point = p1.Pemain.DataPemain.DataPoint.Point.Value,
				rd = p1.Pemain.DataPemain.DataPoint.RatingDeviation.Value,
				vol = p1.Pemain.DataPemain.DataPoint.Volatility.Value,
			})
		end
		local DataCaturRaw = self:moves({
			verbose = true,
		})
		local DataCatur = {}
		local _arg0 = function(element)
			local _from = element.from
			if DataCatur[_from] == nil then
				local _from_1 = element.from
				local _arg1 = { element }
				DataCatur[_from_1] = _arg1
			else
				local _from_1 = element.from
				local _result = DataCatur[_from_1]
				if _result ~= nil then
					local _element = element
					table.insert(_result, _element)
				end
			end
		end
		for _k, _v in DataCaturRaw do
			_arg0(_v, _k - 1, DataCaturRaw)
		end
		local BoardNew = {}
		local _exp = self:board()
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
		for _k, _v in _exp do
			_arg0_1(_v, _k - 1, _exp)
		end
		local _fn = Event.KirimCaturUIKePemain
		local _exp_1 = p1.Pemain
		local _exp_2 = p1.warna
		local _exp_3 = self.mode
		local _exp_4 = self:turn()
		local _result
		if self.mode == "player" then
			local _object_1 = {}
			if type(p2) == "table" then
				for _k, _v in p2 do
					_object_1[_k] = _v
				end
			end
			local _left = "point"
			local _result_1 = p2
			if _result_1 ~= nil then
				_result_1 = _result_1.Pemain.DataPemain.DataPoint.Point.Value
			end
			_object_1[_left] = _result_1
			_result = _object_1
		else
			_result = nil
		end
		_fn:FireClient(_exp_1, _exp_2, _exp_3, BoardNew, DataCatur, _exp_4, _result, waktu)
		if p2 ~= nil then
			local _fn_1 = Event.KirimCaturUIKePemain
			local _exp_5 = p2.Pemain
			local _exp_6 = p2.warna
			local _exp_7 = self.mode
			local _exp_8 = self:turn()
			local _result_1
			if self.mode == "player" then
				local _object_1 = {}
				for _k, _v in p1 do
					_object_1[_k] = _v
				end
				_object_1.point = p1.Pemain.DataPemain.DataPoint.Point.Value
				_result_1 = _object_1
			else
				_result_1 = nil
			end
			_fn_1:FireClient(_exp_5, _exp_6, _exp_7, BoardNew, DataCatur, _exp_8, _result_1, waktu)
		end
	end
	function Chess:clear(keepHeaders)
		if keepHeaders == nil then
			keepHeaders = false
		end
		self._board = table.create(128)
		self._kings = {
			w = EMPTY,
			b = EMPTY,
		}
		self._turn = WHITE
		self._castling = {
			w = 0,
			b = 0,
		}
		self._epSquare = EMPTY
		self._halfMoves = 0
		self._moveNumber = 1
		self._history = {}
		table.clear(self._comments)
		self._header = if keepHeaders then self._header else {}
		self:_updateSetup(self:fen())
	end
	function Chess:load(fen, keepHeaders)
		if keepHeaders == nil then
			keepHeaders = false
		end
		local tokens = string.split(fen, " ")
		local position = tokens[1]
		local square = 0
		if not validateFen(fen).valid then
			return false
		end
		self:clear(keepHeaders)
		do
			local i = 1
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= #position) then
					break
				end
				local _i = i
				local _i_1 = i
				local piece = string.sub(position, _i, _i_1)
				if piece == "/" then
					square += 8
				elseif isDigit(piece) then
					square += tonumber(piece, 10)
				else
					local color = if piece < "a" then WHITE else BLACK
					self:put({
						type = string.lower(piece),
						color = color,
					}, algebraic(square))
					square += 1
				end
			end
		end
		self._turn = tokens[2]
		if (string.find(tokens[3], "K")) ~= nil and (string.find(tokens[3], "K")) > -1 then
			local _exp = self._castling
			_exp.w = bit32.bor(_exp.w, BITS.KSIDE_CASTLE)
		end
		if (string.find(tokens[3], "Q")) ~= nil and (string.find(tokens[3], "Q")) > -1 then
			local _exp = self._castling
			_exp.w = bit32.bor(_exp.w, BITS.QSIDE_CASTLE)
		end
		if (string.find(tokens[3], "k")) ~= nil and (string.find(tokens[3], "k")) > -1 then
			local _exp = self._castling
			_exp.b = bit32.bor(_exp.b, BITS.KSIDE_CASTLE)
		end
		if (string.find(tokens[3], "q")) ~= nil and (string.find(tokens[3], "q")) > -1 then
			local _exp = self._castling
			_exp.b = bit32.bor(_exp.b, BITS.QSIDE_CASTLE)
		end
		self._epSquare = if tokens[4] == "-" then EMPTY else Ox88[tokens[4]]
		self._halfMoves = tonumber(tokens[5], 10)
		self._moveNumber = tonumber(tokens[6], 10)
		self:_updateSetup(self:fen())
		return true
	end
	function Chess:fen()
		local empty = 0
		local fen = ""
		do
			local _i = Ox88.a8
			local _shouldIncrement = false
			while true do
				local i = _i
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= Ox88.h1) then
					break
				end
				if self._board[i + 1] then
					if empty > 0 then
						fen ..= tostring(empty)
						empty = 0
					end
					local _binding = self._board[i + 1]
					local color = _binding.color
					local piece = _binding.type
					fen ..= if color == WHITE then string.upper(piece) else string.lower(piece)
				else
					empty += 1
				end
				if bit32.band(bit32.band((i + 1), 0x88)) ~= 0 then
					if empty > 0 then
						fen ..= tostring(empty)
					end
					if i ~= Ox88.h1 then
						fen ..= "/"
					end
					empty = 0
					i += 8
				end
				_i = i
			end
		end
		local cflags = ""
		if bit32.band(bit32.band(self._castling[WHITE], BITS.KSIDE_CASTLE)) ~= 0 then
			cflags ..= "K"
		end
		if bit32.band(bit32.band(self._castling[WHITE], BITS.QSIDE_CASTLE)) ~= 0 then
			cflags ..= "Q"
		end
		if bit32.band(bit32.band(self._castling[BLACK], BITS.KSIDE_CASTLE)) ~= 0 then
			cflags ..= "k"
		end
		if bit32.band(bit32.band(self._castling[BLACK], BITS.QSIDE_CASTLE)) ~= 0 then
			cflags ..= "q"
		end
		-- do we have an empty castling flag?
		local _condition = cflags
		if not (_condition ~= "" and _condition) then
			_condition = "-"
		end
		cflags = _condition
		local epflags = if self._epSquare == EMPTY then "-" else algebraic(self._epSquare)
		return table.concat({ fen, self._turn, cflags, epflags, self._halfMoves, self._moveNumber }, " ")
	end
	function Chess:_updateSetup(fen)
		if #self._history > 0 then
			return nil
		end
		if fen ~= DEFAULT_POSITION then
			self._header.SetUp = "1"
			local __header = self._header
			local _fen = fen
			__header.FEN = _fen
		else
			self._header.SetUp = nil
			self._header.FEN = nil
		end
	end
	function Chess:reset()
		self:load(DEFAULT_POSITION)
	end
	function Chess:get(square)
		return self._board[Ox88[square] + 1] or false
	end
	function Chess:put(data, square)
		-- check for piece
		local _arg0 = string.lower(data.type)
		if (string.find(SYMBOLS, _arg0)) == -1 then
			return false
		end
		-- check for valid square
		if not (Ox88[square] ~= nil) then
			return false
		end
		local sq = Ox88[square]
		-- don't let the user place more than one king
		if data.type == KING and not (self._kings[data.color] == EMPTY or self._kings[data.color] == sq) then
			return false
		end
		self._board[sq + 1] = {
			type = data.type,
			color = data.color,
		}
		if data.type == KING then
			self._kings[data.color] = sq
		end
		self:_updateSetup(self:fen())
		return true
	end
	function Chess:remove(square)
		local piece = self:get(square)
		self._board[Ox88[square] + 1] = nil
		if piece and piece.type == KING then
			self._kings[piece.color] = EMPTY
		end
		self:_updateSetup(self:fen())
		return piece
	end
	function Chess:_attacked(color, square)
		do
			local _i = Ox88.a8
			local _shouldIncrement = false
			while true do
				local i = _i
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= Ox88.h1) then
					break
				end
				-- did we run off the end of the board
				local _value = bit32.band(i, 0x88)
				if _value ~= 0 and (_value == _value and _value) then
					i += 7
					_i = i
					continue
				end
				-- if empty square or wrong color
				if self._board[i + 1] == nil or self._board[i + 1].color ~= color then
					_i = i
					continue
				end
				local piece = self._board[i + 1]
				local difference = i - square
				local index = difference + 119
				local _value_1 = bit32.band(ATTACKS[index + 1], PIECE_MASKS[piece.type])
				if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
					if piece.type == PAWN then
						if difference > 0 then
							if piece.color == WHITE then
								return true
							end
						else
							if piece.color == BLACK then
								return true
							end
						end
						_i = i
						continue
					end
					-- if the piece is a knight or a king
					if piece.type == "n" or piece.type == "k" then
						return true
					end
					local offset = RAYS[index + 1]
					local j = i + offset
					local blocked = false
					while j ~= square do
						if self._board[j + 1] ~= nil then
							blocked = true
							break
						end
						j += offset
					end
					if not blocked then
						return true
					end
				end
				_i = i
			end
		end
		return false
	end
	function Chess:_isKingAttacked(color)
		return self:_attacked(swapColor(color), self._kings[color])
	end
	function Chess:isCheck()
		return self:_isKingAttacked(self._turn)
	end
	function Chess:inCheck()
		return self:isCheck()
	end
	function Chess:isCheckmate()
		return self:isCheck() and #self:_moves() == 0
	end
	function Chess:isStalemate()
		return not self:isCheck() and #self:_moves() == 0
	end
	function Chess:DapatinWarnaDariPlayer(pemain)
		if self.mode == "player" then
			return if self.p1.Pemain.Name == pemain.Name then self.p1.warna else self.p2.warna
		end
		return nil
	end
	function Chess:DapatinPemainDariWarna(warna)
		if warna == self.p1.warna then
			return self.p1
		end
		if self.p2 ~= nil and warna == self.p2.warna then
			return self.p2
		end
		return nil
	end
	function Chess:SetAlasanSeri(alasan)
		self._alasanSeri = alasan
	end
	function Chess:DapatinAlasanSeri()
		if self._alasanSeri then
			return self._alasanSeri
		end
		if self:isStalemate() then
			return "Stalemate"
		end
		if self:isInsufficientMaterial() then
			return "Insufficient Material"
		end
		if self:isThreefoldRepetition() then
			return "Repetition"
		end
		if self:isDraw() then
			return "Draw"
		end
		return nil
	end
	function Chess:ApakahGameSelesai()
		if self:DapatinAlasanSeri() ~= nil then
			return { true, "draw", self:DapatinAlasanSeri() }
		end
		if self:isCheckmate() then
			return { true, "skakmat", if self:turn() == "w" then "b" else "w" }
		end
		if self.mode == "player" then
			if self._menyerah ~= nil then
				return { true, "menyerah", if self._menyerah == "w" then "b" else "w" }
			end
			print(self._keluarGame)
			if self._keluarGame ~= nil then
				return { true, "keluar game", if self._keluarGame == "w" then "b" else "w" }
			end
			if self.p1.waktu <= 0 then
				return { true, "waktuhabis", if self:turn() == "w" then "b" else "w" }
			end
			if self.p2.waktu <= 0 then
				return { true, "waktuhabis", if self:turn() == "w" then "b" else "w" }
			end
		end
		return { false, nil, nil }
	end
	function Chess:KalkulasiMenangKalah(pemain1, pemain2)
		local Hasil = {
			Menang = {
				rating = 0,
				rd = 0,
				vol = 0,
				SelisihRating = 0,
			},
			Seri = {
				rating = 0,
				rd = 0,
				vol = 0,
				SelisihRating = 0,
			},
			Kalah = {
				rating = 0,
				rd = 0,
				vol = 0,
				SelisihRating = 0,
			},
			warna = pemain1.warna,
			prediksi = 0,
			JumlahKalah = 0,
			JumlahMenang = 0,
			JumlahMain = 0,
		}
		local _arg0 = function(v)
			local RatingPemain1 = self.ranking:makePlayer(pemain1.point, pemain1.rd, pemain1.vol)
			local RatingPemain2 = self.ranking:makePlayer(pemain2.point, pemain2.rd, pemain2.vol)
			Hasil.prediksi = tonumber(string.format("%.1f", self.ranking:predict(RatingPemain1, RatingPemain2) * 100))
			self.ranking:updateRatings({ { RatingPemain1, RatingPemain2, v } })
			Hasil[NomorKeStatus[v]] = {
				rating = math.floor(RatingPemain1:getRating()),
				rd = RatingPemain1:getRd(),
				vol = RatingPemain1:getVol(),
				SelisihRating = math.floor(RatingPemain1:getRating() - pemain1.point),
			}
			self.ranking:removePlayers()
		end
		local _exp = { 1, .5, 0 }
		for _k, _v in _exp do
			_arg0(_v, _k - 1, _exp)
		end
		local _original = pemain1.Kalah
		pemain1.Kalah += 1
		Hasil.JumlahKalah = _original
		local _original_1 = pemain1.Menang
		pemain1.Menang += 1
		Hasil.JumlahMenang = _original_1
		local _original_2 = pemain1.Main
		pemain1.Main += 1
		Hasil.JumlahMain = _original_2
		return Hasil
	end
	function Chess:Menyerah(warna)
		self._menyerah = warna
	end
	function Chess:KeluarDariGame(warna)
		self._keluarGame = warna
	end
	function Chess:isInsufficientMaterial()
		local pieces = {
			b = 0,
			n = 0,
			r = 0,
			q = 0,
			k = 0,
			p = 0,
		}
		local bishops = {}
		local numPieces = 0
		local squareColor = 0
		do
			local _i = Ox88.a8
			local _shouldIncrement = false
			while true do
				local i = _i
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= Ox88.h1) then
					break
				end
				squareColor = (squareColor + 1) % 2
				local _value = bit32.band(i, 0x88)
				if _value ~= 0 and (_value == _value and _value) then
					i += 7
					_i = i
					continue
				end
				local piece = self._board[i + 1]
				if piece then
					pieces[piece.type] = if pieces[piece.type] ~= nil then pieces[piece.type] + 1 else 1
					if piece.type == BISHOP then
						local _squareColor = squareColor
						table.insert(bishops, _squareColor)
					end
					numPieces += 1
				end
				_i = i
			end
		end
		-- k vs. k
		if numPieces == 2 then
			return true
		elseif numPieces == 3 and (pieces[BISHOP] == 1 or pieces[KNIGHT] == 1) then
			return true
		elseif numPieces == pieces[BISHOP] + 2 then
			-- kb vs. kb where any number of bishops are all on the same color
			local sum = 0
			local len = #bishops
			do
				local i = 0
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i += 1
					else
						_shouldIncrement = true
					end
					if not (i < len) then
						break
					end
					sum += bishops[i + 1]
				end
			end
			if sum == 0 or sum == len then
				return true
			end
		end
		return false
	end
	function Chess:isThreefoldRepetition()
		--[[
			TODO: while this function is fine for casual use, a better
			* implementation would use a Zobrist key (instead of FEN). the
			* Zobrist key would be maintained in the make_move/undo_move
			functions,
			* avoiding the costly that we do below.
		]]
		local moves = {}
		local positions = {}
		local repetition = false
		while true do
			local move = self:_undoMove()
			if not move then
				break
			end
			table.insert(moves, move)
		end
		while true do
			--[[
				remove the last two fields in the FEN string, they're not needed
				* when checking for draw by rep
			]]
			local _exp = string.split(self:fen(), " ")
			local _arg0 = function(v, i)
				return i < 4
			end
			-- ▼ ReadonlyArray.filter ▼
			local _newValue = {}
			local _length = 0
			for _k, _v in _exp do
				if _arg0(_v, _k - 1, _exp) == true then
					_length += 1
					_newValue[_length] = _v
				end
			end
			-- ▲ ReadonlyArray.filter ▲
			local fen = table.concat(_newValue, ", ")
			-- const fen = this.fen().split(' ').slice(0, 4).join(' ')
			-- has the position occurred three or move times
			positions[fen] = if positions[fen] ~= nil then positions[fen] + 1 else 1
			if positions[fen] >= 3 then
				repetition = true
			end
			-- ▼ Array.pop ▼
			local _length_1 = #moves
			local _result = moves[_length_1]
			moves[_length_1] = nil
			-- ▲ Array.pop ▲
			local move = _result
			if not move then
				break
			else
				self:_makeMove(move)
			end
		end
		return repetition
	end
	function Chess:isDraw()
		return self._halfMoves >= 100 or (self:isStalemate() or (self:isInsufficientMaterial() or self:isThreefoldRepetition()))
	end
	function Chess:isGameOver()
		return self:isCheckmate() or (self:isStalemate() or self:isDraw())
	end
	function Chess:moves(_param)
		if _param == nil then
			_param = {}
		end
		local verbose = _param.verbose
		if verbose == nil then
			verbose = false
		end
		local square = _param.square
		if square == nil then
			square = nil
		end
		local piece = _param.piece
		if piece == nil then
			piece = nil
		end
		local warna = _param.warna
		if warna == nil then
			warna = nil
		end
		local moves = self:_moves({
			square = square,
			piece = piece,
			warna = warna,
		})
		if verbose then
			local _arg0 = function(move)
				return self:_makePretty(move)
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#moves)
			for _k, _v in moves do
				_newValue[_k] = _arg0(_v, _k - 1, moves)
			end
			-- ▲ ReadonlyArray.map ▲
			return _newValue
		else
			local _arg0 = function(move)
				return self:_moveToSan(move, moves)
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#moves)
			for _k, _v in moves do
				_newValue[_k] = _arg0(_v, _k - 1, moves)
			end
			-- ▲ ReadonlyArray.map ▲
			return _newValue
		end
	end
	function Chess:_moves(_param)
		if _param == nil then
			_param = {}
		end
		local legal = _param.legal
		if legal == nil then
			legal = true
		end
		local piece = _param.piece
		if piece == nil then
			piece = nil
		end
		local square = _param.square
		if square == nil then
			square = nil
		end
		local warna = _param.warna
		if warna == nil then
			warna = self._turn
		end
		local forSquare = if square then (string.lower(square)) else nil
		local _forPiece = piece
		if _forPiece ~= nil then
			_forPiece = string.lower(_forPiece)
		end
		local forPiece = _forPiece
		local moves = {}
		local us = warna
		local them = swapColor(us)
		local firstSquare = Ox88.a8
		local lastSquare = Ox88.h1
		local singleSquare = false
		-- are we generating moves for a single square?
		if forSquare then
			-- illegal square, return empty moves
			if not (Ox88[forSquare] ~= nil) then
				return {}
			else
				lastSquare = Ox88[forSquare]
				firstSquare = lastSquare
				singleSquare = true
			end
		end
		-- print(this._board);
		do
			local _from = firstSquare
			local _shouldIncrement = false
			while true do
				local from = _from
				if _shouldIncrement then
					from += 1
				else
					_shouldIncrement = true
				end
				if not (from <= lastSquare) then
					break
				end
				-- did we run off the end of the board
				local _value = bit32.band(from, 0x88)
				if _value ~= 0 and (_value == _value and _value) then
					from += 7
					_from = from
					continue
				end
				-- empty square or opponent, skip
				-- print(this._board[from])
				if not self._board[from + 1] or self._board[from + 1].color == them then
					_from = from
					continue
				end
				-- print(this._board[from], from);
				local piece = self._board[from + 1]
				local to
				if piece.type == PAWN then
					local _condition = forPiece
					if _condition ~= "" and _condition then
						_condition = forPiece ~= piece.type
					end
					if _condition ~= "" and _condition then
						_from = from
						continue
					end
					-- single square, non-capturing
					to = from + PAWN_OFFSETS[us][1]
					if not self._board[to + 1] then
						addMove(moves, us, from, to, PAWN)
						-- double square
						to = from + PAWN_OFFSETS[us][2]
						if SECOND_RANK[us] == rank(from) and not self._board[to + 1] then
							addMove(moves, us, from, to, PAWN, nil, BITS.BIG_PAWN)
						end
					end
					-- pawn captures
					do
						local j = 2
						local _shouldIncrement_1 = false
						while true do
							if _shouldIncrement_1 then
								j += 1
							else
								_shouldIncrement_1 = true
							end
							if not (j < 4) then
								break
							end
							to = from + PAWN_OFFSETS[us][j + 1]
							local _value_1 = bit32.band(to, 0x88)
							if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
								continue
							end
							local _result = self._board[to + 1]
							if _result ~= nil then
								_result = _result.color
							end
							if _result == them then
								addMove(moves, us, from, to, PAWN, self._board[to + 1].type, BITS.CAPTURE)
							elseif to == self._epSquare then
								addMove(moves, us, from, to, PAWN, PAWN, BITS.EP_CAPTURE)
							end
						end
					end
				else
					local _condition = forPiece
					if _condition ~= "" and _condition then
						_condition = forPiece ~= piece.type
					end
					if _condition ~= "" and _condition then
						_from = from
						continue
					end
					do
						local j = 0
						local len = #PIECE_OFFSETS[piece.type]
						local _shouldIncrement_1 = false
						while true do
							if _shouldIncrement_1 then
								j += 1
							else
								_shouldIncrement_1 = true
							end
							if not (j < len) then
								break
							end
							local offset = PIECE_OFFSETS[piece.type][j + 1]
							to = from
							while true do
								to += offset
								local _value_1 = bit32.band(to, 0x88)
								if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
									break
								end
								if not self._board[to + 1] then
									addMove(moves, us, from, to, piece.type)
								else
									-- own color, stop loop
									if self._board[to + 1].color == us then
										break
									end
									addMove(moves, us, from, to, piece.type, self._board[to + 1].type, BITS.CAPTURE)
									break
								end
								-- break, if knight or king
								if piece.type == KNIGHT or piece.type == KING then
									break
								end
							end
						end
					end
				end
				_from = from
			end
		end
		--[[
			check for castling if:
			* a) we're generating all moves, or
			* b) we're doing single square move generation on the king's square
		]]
		if forPiece == nil or forPiece == KING then
			if not singleSquare or lastSquare == self._kings[us] then
				-- king-side castling
				local _value = bit32.band(self._castling[us], BITS.KSIDE_CASTLE)
				if _value ~= 0 and (_value == _value and _value) then
					local castlingFrom = self._kings[us]
					local castlingTo = castlingFrom + 2
					if not self._board[castlingFrom + 1 + 1] and (not self._board[castlingTo + 1] and (not self:_attacked(them, self._kings[us]) and (not self:_attacked(them, castlingFrom + 1) and not self:_attacked(them, castlingTo)))) then
						addMove(moves, us, self._kings[us], castlingTo, KING, nil, BITS.KSIDE_CASTLE)
					end
				end
				-- queen-side castling
				local _value_1 = bit32.band(self._castling[us], BITS.QSIDE_CASTLE)
				if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
					local castlingFrom = self._kings[us]
					local castlingTo = castlingFrom - 2
					if not self._board[castlingFrom - 1 + 1] and (not self._board[castlingFrom - 2 + 1] and (not self._board[castlingFrom - 3 + 1] and (not self:_attacked(them, self._kings[us]) and (not self:_attacked(them, castlingFrom - 1) and not self:_attacked(them, castlingTo))))) then
						addMove(moves, us, self._kings[us], castlingTo, KING, nil, BITS.QSIDE_CASTLE)
					end
				end
			end
		end
		--[[
			return all pseudo-legal moves (this includes moves that allow the king
			* to be captured)
		]]
		if not legal then
			return moves
		end
		-- filter out illegal moves
		local legalMoves = {}
		do
			local i = 0
			local len = #moves
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < len) then
					break
				end
				self:_makeMove(moves[i + 1])
				if not self:_isKingAttacked(us) then
					local _arg0 = moves[i + 1]
					table.insert(legalMoves, _arg0)
				end
				self:_undoMove()
			end
		end
		return legalMoves
	end
	function Chess:move(move, _param)
		if _param == nil then
			_param = {}
		end
		local sloppy = _param.sloppy
		if sloppy == nil then
			sloppy = false
		end
		--[[
			The move function can be called with in the following parameters:
			*
			* .move('Nxb7')      <- where 'move' is a case-sensitive SAN string
			*
			* .move({ from: 'h7', <- where the 'move' is a move object
			(additional
			*         to :'h8',      fields are ignored)
			*         promotion: 'q',
			*      })
		]]
		-- sloppy parser allows the move parser to work around over disambiguation
		-- bugs in Fritz and Chessbase
		local moveObj = nil
		local _move = move
		if typeof(_move) == "string" then
			moveObj = self:_moveFromSan(move, sloppy)
		else
			local _move_1 = move
			if typeof(_move_1) ~= "string" then
				local moves = self:_moves()
				-- convert the pretty move object to an ugly move object
				do
					local i = 0
					local len = #moves
					local _shouldIncrement = false
					while true do
						if _shouldIncrement then
							i += 1
						else
							_shouldIncrement = true
						end
						if not (i < len) then
							break
						end
						if move.from == algebraic(moves[i + 1].from) and (move.to == algebraic(moves[i + 1].to) and (not (moves[i + 1].promotion ~= nil) or move.promotion == moves[i + 1].promotion)) then
							moveObj = moves[i + 1]
							break
						end
					end
				end
			end
		end
		-- failed to find move
		if not moveObj then
			return nil
		end
		--[[
			need to make a copy of move because we can't generate SAN after
			the move is made
		]]
		local prettyMove = self:_makePretty(moveObj)
		self:_makeMove(moveObj)
		return prettyMove
	end
	function Chess:_push(move)
		local __history = self._history
		local _arg0 = {
			move = move,
			kings = {
				b = self._kings.b,
				w = self._kings.w,
			},
			turn = self._turn,
			castling = {
				b = self._castling.b,
				w = self._castling.w,
			},
			epSquare = self._epSquare,
			halfMoves = self._halfMoves,
			moveNumber = self._moveNumber,
		}
		table.insert(__history, _arg0)
	end
	function Chess:_makeMove(move)
		local us = self._turn
		local them = swapColor(us)
		self:_push(move)
		self._board[move.to + 1] = self._board[move.from + 1]
		self._board[move.from + 1] = nil
		-- if ep capture, remove the captured pawn
		local _value = bit32.band(move.flags, BITS.EP_CAPTURE)
		if _value ~= 0 and (_value == _value and _value) then
			if self._turn == BLACK then
				self._board[move.to - 16 + 1] = nil
			else
				self._board[move.to + 16 + 1] = nil
			end
		end
		-- if pawn promotion, replace with new piece
		if move.promotion then
			self._board[move.to + 1] = {
				type = move.promotion,
				color = us,
			}
		end
		-- if we moved the king
		if self._board[move.to + 1].type == KING then
			self._kings[us] = move.to
			-- if we castled, move the rook next to the king
			local _value_1 = bit32.band(move.flags, BITS.KSIDE_CASTLE)
			if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
				local castlingTo = move.to - 1
				local castlingFrom = move.to + 1
				self._board[castlingTo + 1] = self._board[castlingFrom + 1]
				self._board[castlingFrom + 1] = nil
			else
				local _value_2 = bit32.band(move.flags, BITS.QSIDE_CASTLE)
				if _value_2 ~= 0 and (_value_2 == _value_2 and _value_2) then
					local castlingTo = move.to + 1
					local castlingFrom = move.to - 2
					self._board[castlingTo + 1] = self._board[castlingFrom + 1]
					self._board[castlingFrom + 1] = nil
				end
			end
			-- turn off castling
			self._castling[us] = 0
		end
		-- turn off castling if we move a rook
		local _value_1 = self._castling[us]
		if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
			do
				local i = 0
				local len = #ROOKS[us]
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i += 1
					else
						_shouldIncrement = true
					end
					if not (i < len) then
						break
					end
					local _value_2 = move.from == ROOKS[us][i + 1].square and bit32.band(self._castling[us], ROOKS[us][i + 1].flag)
					if _value_2 ~= 0 and (_value_2 == _value_2 and _value_2) then
						local _exp = self._castling
						_exp[us] = bit32.bxor(_exp[us], ROOKS[us][i + 1].flag)
						break
					end
				end
			end
		end
		-- turn off castling if we capture a rook
		local _value_2 = self._castling[them]
		if _value_2 ~= 0 and (_value_2 == _value_2 and _value_2) then
			do
				local i = 0
				local len = #ROOKS[them]
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i += 1
					else
						_shouldIncrement = true
					end
					if not (i < len) then
						break
					end
					local _value_3 = move.to == ROOKS[them][i + 1].square and bit32.band(self._castling[them], ROOKS[them][i + 1].flag)
					if _value_3 ~= 0 and (_value_3 == _value_3 and _value_3) then
						local _exp = self._castling
						_exp[them] = bit32.bxor(_exp[them], ROOKS[them][i + 1].flag)
						break
					end
				end
			end
		end
		-- if big pawn move, update the en passant square
		local _value_3 = bit32.band(move.flags, BITS.BIG_PAWN)
		if _value_3 ~= 0 and (_value_3 == _value_3 and _value_3) then
			if us == BLACK then
				self._epSquare = move.to - 16
			else
				self._epSquare = move.to + 16
			end
		else
			self._epSquare = EMPTY
		end
		-- reset the 50 move counter if a pawn is moved or a piece is captured
		if move.piece == PAWN then
			self._halfMoves = 0
		else
			local _value_4 = bit32.band(move.flags, (bit32.bor(BITS.CAPTURE, BITS.EP_CAPTURE)))
			if _value_4 ~= 0 and (_value_4 == _value_4 and _value_4) then
				self._halfMoves = 0
			else
				self._halfMoves += 1
			end
		end
		if us == BLACK then
			self._moveNumber += 1
		end
		self._turn = them
	end
	function Chess:undo()
		local move = self:_undoMove()
		return if move then self:_makePretty(move) else nil
	end
	function Chess:_undoMove()
		local _exp = self._history
		-- ▼ Array.pop ▼
		local _length = #_exp
		local _result = _exp[_length]
		_exp[_length] = nil
		-- ▲ Array.pop ▲
		local old = _result
		if old == nil then
			return nil
		end
		local move = old.move
		self._kings = old.kings
		self._turn = old.turn
		self._castling = old.castling
		self._epSquare = old.epSquare
		self._halfMoves = old.halfMoves
		self._moveNumber = old.moveNumber
		local us = self._turn
		local them = swapColor(us)
		self._board[move.from + 1] = self._board[move.to + 1]
		self._board[move.from + 1].type = move.piece
		self._board[move.to + 1] = nil
		if move.captured then
			local _value = bit32.band(move.flags, BITS.EP_CAPTURE)
			if _value ~= 0 and (_value == _value and _value) then
				-- en passant capture
				local index
				if us == BLACK then
					index = move.to - 16
				else
					index = move.to + 16
				end
				self._board[index + 1] = {
					type = PAWN,
					color = them,
				}
			else
				-- regular capture
				self._board[move.to + 1] = {
					type = move.captured,
					color = them,
				}
			end
		end
		local _value = bit32.band(move.flags, (bit32.bor(BITS.KSIDE_CASTLE, BITS.QSIDE_CASTLE)))
		if _value ~= 0 and (_value == _value and _value) then
			local castlingTo
			local castlingFrom
			local _value_1 = bit32.band(move.flags, BITS.KSIDE_CASTLE)
			if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
				castlingTo = move.to + 1
				castlingFrom = move.to - 1
			else
				castlingTo = move.to - 2
				castlingFrom = move.to + 1
			end
			self._board[castlingTo + 1] = self._board[castlingFrom + 1]
			self._board[castlingFrom + 1] = nil
		end
		return move
	end
	function Chess:DapatinPGN()
		return (string.gsub((string.gsub((string.gsub(self:pgn(), "{nil}", "")), "%s+", " ")), "^%s+", ""))
	end
	function Chess:pgn(_param)
		if _param == nil then
			_param = {}
		end
		local newline = _param.newline
		if newline == nil then
			newline = "\n"
		end
		local maxWidth = _param.maxWidth
		if maxWidth == nil then
			maxWidth = 0
		end
		--[[
			using the specification from http://www.chessclub.com/help/PGN-spec
			* example for html usage: .pgn({ max_width: 72, newline_char: "<br />" })
		]]
		local result = {}
		local headerExists = false
		-- add the PGN header information
		local __header = self._header
		local _arg0 = function(v, k)
			local _arg0_1 = "[" .. k .. ' "' .. v .. '"]' .. newline
			table.insert(result, _arg0_1)
			headerExists = true
		end
		for _k, _v in __header do
			_arg0(_v, _k, __header)
		end
		-- for (const i in this._header) {
		-- result.push('[' + i + ' "' + this._header[i] + '"]' + newline)
		-- headerExists = true
		-- }
		if headerExists and #self._history then
			table.insert(result, newline)
		end
		local appendComment = function(moveString)
			local __comments = self._comments
			local _arg0_1 = self:fen()
			local comment = __comments[_arg0_1]
			if typeof(comment) ~= nil then
				local delimiter = if #moveString > 0 then " " else ""
				moveString = moveString .. (delimiter .. ("{" .. (tostring(comment) .. "}")))
			end
			return moveString
		end
		-- pop all of history onto reversed_history
		local reversedHistory = {}
		while #self._history > 0 do
			local _arg0_1 = self:_undoMove()
			table.insert(reversedHistory, _arg0_1)
		end
		local moves = {}
		local moveString = ""
		-- special case of a commented starting position with no moves
		if #reversedHistory == 0 then
			local _arg0_1 = appendComment("")
			table.insert(moves, _arg0_1)
		end
		-- build the list of moves.  a move_string looks like: "3. e3 e6"
		while #reversedHistory > 0 do
			moveString = appendComment(moveString)
			-- ▼ Array.pop ▼
			local _length = #reversedHistory
			local _result = reversedHistory[_length]
			reversedHistory[_length] = nil
			-- ▲ Array.pop ▲
			local move = _result
			-- make TypeScript stop complaining about move being undefined
			if not move then
				break
			end
			-- if the position started with black to move, start PGN with #. ...
			local _value = #self._history
			local _condition = not (_value ~= 0 and (_value == _value and _value))
			if _condition then
				_condition = move.color == "b"
			end
			if _condition then
				local prefix = tostring(self._moveNumber) .. ". ..."
				-- is there a comment preceding the first move?
				moveString = if moveString ~= "" and moveString then moveString .. (" " .. prefix) else prefix
			elseif move.color == "w" then
				-- store the previous generated move_string if we have one
				local _value_1 = #moveString
				if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
					local _moveString = moveString
					table.insert(moves, _moveString)
				end
				moveString = tostring(self._moveNumber) .. "."
			end
			moveString = moveString .. " " .. self:_moveToSan(move, self:_moves({
				legal = true,
			}))
			self:_makeMove(move)
		end
		-- are there any other leftover moves?
		local _value = #moveString
		if _value ~= 0 and (_value == _value and _value) then
			local _arg0_1 = appendComment(moveString)
			table.insert(moves, _arg0_1)
		end
		-- is there a result?
		local _arg0_1 = self._header.Result
		if typeof(_arg0_1) ~= nil then
			local _arg0_2 = self._header.Result
			table.insert(moves, _arg0_2)
		end
		--[[
			history should be back to what it was before we started generating PGN,
			* so join together moves
		]]
		if maxWidth == 0 then
			return table.concat(result, "") .. table.concat(moves, " ")
		end
		-- JAH: huh?
		local strip = function()
			if #result > 0 and result[#result - 1 + 1] == " " then
				result[#result] = nil
				return true
			end
			return false
		end
		-- NB: this does not preserve comment whitespace.
		local wrapComment = function(width, move)
			for _, token in string.split(move, " ") do
				if not (token ~= "" and token) then
					continue
				end
				if width + #token > maxWidth then
					while strip() do
						width -= 1
					end
					table.insert(result, newline)
					width = 0
				end
				table.insert(result, token)
				width += #token
				table.insert(result, " ")
				width += 1
			end
			if strip() then
				width -= 1
			end
			return width
		end
		-- wrap the PGN output at max_width
		local currentWidth = 0
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < #moves) then
					break
				end
				if currentWidth + #moves[i + 1] > maxWidth then
					if { string.find(moves[i + 1], "{") } ~= nil then
						currentWidth = wrapComment(currentWidth, moves[i + 1])
						continue
					end
				end
				-- if the current move will push past max_width
				if currentWidth + #moves[i + 1] > maxWidth and i ~= 0 then
					-- don't end the line with whitespace
					if result[#result - 1 + 1] == " " then
						result[#result] = nil
					end
					table.insert(result, newline)
					currentWidth = 0
				elseif i ~= 0 then
					table.insert(result, " ")
					currentWidth += 1
				end
				local _arg0_2 = moves[i + 1]
				table.insert(result, _arg0_2)
				currentWidth += #moves[i + 1]
			end
		end
		return table.concat(result, "")
	end
	function Chess:header(...)
		local args = { ... }
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 2
				else
					_shouldIncrement = true
				end
				if not (i < #args) then
					break
				end
				local _arg0 = args[i + 1]
				local _condition = typeof(_arg0) == "string"
				if _condition then
					local _arg0_1 = args[i + 1 + 1]
					_condition = typeof(_arg0_1) == "string"
				end
				if _condition then
					local __header = self._header
					local _arg0_1 = args[i + 1]
					local _arg1 = args[i + 1 + 1]
					__header[_arg0_1] = _arg1
				end
			end
		end
		return self._header
	end
	function Chess:loadPgn(pgn, _param)
		if _param == nil then
			_param = {}
		end
		local sloppy = _param.sloppy
		if sloppy == nil then
			sloppy = false
		end
		local newlineChar = _param.newlineChar
		if newlineChar == nil then
			newlineChar = "\r?\n"
		end
		-- option sloppy=true
		-- allow the user to specify the sloppy move parser to work around over
		-- disambiguation bugs in Fritz and Chessbase
		local function mask(str)
			return (string.gsub(str, "\\", "\\\\"))
		end
		local function parsePgnHeader(header)
			local headerObj = {}
			local _header = header
			local _arg0 = mask(newlineChar)
			local headers = string.split(_header, _arg0)
			local key = ""
			local value = ""
			do
				local i = 0
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i += 1
					else
						_shouldIncrement = true
					end
					if not (i < #headers) then
						break
					end
					local regex = '^%s*[([A-Za-z]+)%s*"(.*)"%s*]%s*$'
					key = (string.gsub(headers[i + 1], regex, "$1"))
					value = (string.gsub(headers[i + 1], regex, "$2"))
					if #trimString(key) > 0 then
						headerObj[key] = value
					end
				end
			end
			return headerObj
		end
		-- strip whitespace from head/tail of PGN block
		pgn = trimString(pgn)
		-- RegExp to split header. Takes advantage of the fact that header and movetext
		-- will always have a blank line between them (ie, two newline_char's).
		-- With default newline_char, will equal: /^(\[((?:\r?\n)|.)*\])(?:\s*\r?\n){2}/
		local headerRegex = "^(\\[((?:" .. mask(newlineChar) .. ")|.)*\\])" .. "(?:\\s*" .. mask(newlineChar) .. "){2}"
		-- If no header given, begin with moves.
		local _pgn = pgn
		local headerRegexResults = (string.match(headerRegex, _pgn))
		local headerString = if headerRegexResults ~= "" and headerRegexResults then if #headerRegexResults >= 2 then string.sub(headerRegexResults, 1, 1) else "" else ""
		-- Put the board in the starting position
		self:reset()
		-- parse PGN header
		local headers = parsePgnHeader(headerString)
		local fen = ""
		for _element, _element_1 in pairs(headers) do
			local key_val = { _element, _element_1 }
			if string.lower((key_val[1])) == "fen" then
				fen = headers[key_val[1]]
			end
			self:header(key_val[1], headers[key_val[1]])
		end
		-- for (const key in headers) {
		-- if (key.toLowerCase() === 'fen') {
		-- fen = headers[key]
		-- }
		-- this.header(key, headers[key])
		-- }
		--[[
			sloppy parser should attempt to load a fen tag, even if it's
			* the wrong case and doesn't include a corresponding [SetUp "1"] tag
		]]
		if sloppy then
			if fen ~= "" and fen then
				if not self:load(fen, true) then
					return false
				end
			end
		else
			--[[
				strict parser - load the starting position indicated by [Setup '1']
				* and [FEN position]
			]]
			if headers.SetUp == "1" then
				if not (headers.FEN ~= nil and self:load(headers.FEN, true)) then
					-- second argument to load: don't clear the headers
					return false
				end
			end
		end
		--[[
			NB: the regexes below that delete move numbers, recursive
			* annotations, and numeric annotation glyphs may also match
			* text in comments. To prevent this, we transform comments
			* by hex-encoding them in place and decoding them again after
			* the other tokens have been deleted.
			*
			* While the spec states that PGN files should be ASCII encoded,
			* we use {en,de}codeURIComponent here to support arbitrary UTF8
			* as a convenience for modern users
		]]
		local function encodeURIComponent(str)
			local char_to_hex = function(d)
				return string.format("%%%02X", (string.byte(d)))
			end
			str = (string.gsub(str, "\n", "\r\n"))
			str = (string.gsub(str, "([^%w ])", char_to_hex))
			str = (string.gsub(str, " ", "+"))
			return str
		end
		local function decodeURIComponent(str)
			local hex_to_char = function(x)
				return string.char(tonumber(x, 16))
			end
			str = (string.gsub(str, "+", ""))
			str = (string.gsub(str, "%%(%x%x)", hex_to_char))
			return str
		end
		local function toHex(s)
			local _exp = string.split(s, "")
			local _arg0 = function(c)
				--[[
					encodeURI doesn't transform most ASCII characters,
					* so we handle these ourselves
				]]
				local _result
				if (string.byte(string.sub(c, 0, 0))) < 128 then
					local _c = c
					local _arg1 = tostring((string.byte(string.sub(c, 0, 0))))
					_result = string.format(_c, "%X", _arg1)
				else
					_result = string.lower((string.gsub(encodeURIComponent(c), "%", "")))
				end
				return _result
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#_exp)
			for _k, _v in _exp do
				_newValue[_k] = _arg0(_v, _k - 1, _exp)
			end
			-- ▲ ReadonlyArray.map ▲
			return table.concat(_newValue, "")
		end
		local function fromHex(s)
			return if #s == 0 then "" else decodeURIComponent("%" .. table.concat((string.split(((string.match(s, ".{1,2}"))), "") or {}), "%"))
		end
		local encodeComment = function(s)
			local _s = s
			local _arg0 = mask(newlineChar)
			s = (string.gsub(_s, _arg0, " "))
			local _exp = string.split(s, "")
			local _arg0_1 = function(v, i)
				return i >= 1 and i < #s - 1
			end
			-- ▼ ReadonlyArray.filter ▼
			local _newValue = {}
			local _length = 0
			for _k, _v in _exp do
				if _arg0_1(_v, _k - 1, _exp) == true then
					_length += 1
					_newValue[_length] = _v
				end
			end
			-- ▲ ReadonlyArray.filter ▲
			return "{" .. (toHex(table.concat(_newValue, ", ")) .. "}")
		end
		local decodeComment = function(s)
			local _condition = string.sub(s, 0, 0) == "{"
			if _condition then
				local _s = s
				local _arg0 = #s - 1
				local _arg1 = #s - 1
				_condition = string.sub(_s, _arg0, _arg1) == "}"
			end
			if _condition then
				local _exp = string.split(s, "")
				local _arg0 = function(v, i)
					return i >= 1 and i < #s - 1
				end
				-- ▼ ReadonlyArray.filter ▼
				local _newValue = {}
				local _length = 0
				for _k, _v in _exp do
					if _arg0(_v, _k - 1, _exp) == true then
						_length += 1
						_newValue[_length] = _v
					end
				end
				-- ▲ ReadonlyArray.filter ▲
				return fromHex(table.concat(_newValue, ", "))
			end
		end
		-- delete header to get the moves
		local _exp = (string.gsub(pgn, headerString, ""))
		local _arg0 = mask(newlineChar)
		local ms = (string.gsub(_exp, _arg0, " "))
		-- delete recursive annotation variations
		local ravRegex = "([^()]+)+?"
		-- const ravRegex = /(\([^()]+\))+?/g
		while true do
			local _value = (string.match(ms, ravRegex))
			if not (_value ~= 0 and (_value == _value and (_value ~= "" and _value))) then
				break
			end
			ms = (string.gsub(ms, ravRegex, ""))
		end
		-- delete move numbers
		ms = (string.gsub(ms, "%d+.(..)", ""))
		-- delete ... indicating black to move
		ms = (string.gsub(ms, "...", ""))
		-- delete numeric annotation glyphs
		ms = (string.gsub(ms, "%d+", ""))
		-- trim and get array of moves
		local moves = string.split(trimString(ms), " ")
		-- delete empty entries
		moves = string.split((string.gsub(table.concat(moves, ","), "[,,+]", ",")), ",")
		local result = ""
		do
			local halfMove = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					halfMove += 1
				else
					_shouldIncrement = true
				end
				if not (halfMove < #moves) then
					break
				end
				local comment = decodeComment(moves[halfMove + 1])
				if comment ~= nil then
					local __comments = self._comments
					local _arg0_1 = self:fen()
					__comments[_arg0_1] = comment
					continue
				end
				local move = self:_moveFromSan(moves[halfMove + 1], sloppy)
				-- invalid move
				if move == nil then
					-- was the move an end of game marker
					local _arg0_1 = moves[halfMove + 1]
					if (table.find(TERMINATION_MARKERS, _arg0_1) or 0) - 1 > -1 then
						result = moves[halfMove + 1]
					else
						return false
					end
				else
					-- reset the end of game marker if making a valid move
					result = ""
					self:_makeMove(move)
				end
			end
		end
		--[[
			Per section 8.2.6 of the PGN spec, the Result tag pair must match
			* match the termination marker. Only do this when headers are
			present,
			* but the result tag is missing
		]]
		local _condition = result
		if _condition ~= "" and _condition then
			-- ▼ ReadonlyMap.size ▼
			local _size = 0
			for _ in self._header do
				_size += 1
			end
			-- ▲ ReadonlyMap.size ▲
			_condition = _size
			if _condition ~= 0 and (_condition == _condition and _condition) then
				local _value = self._header.Result
				_condition = not (_value ~= "" and _value)
			end
		end
		if _condition ~= 0 and (_condition == _condition and (_condition ~= "" and _condition)) then
			self:header("Result", result)
		end
		return true
	end
	function Chess:_moveToSan(move, moves)
		local output = ""
		local _value = bit32.band(move.flags, BITS.KSIDE_CASTLE)
		if _value ~= 0 and (_value == _value and _value) then
			output = "O-O"
		else
			local _value_1 = bit32.band(move.flags, BITS.QSIDE_CASTLE)
			if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
				output = "O-O-O"
			else
				if move.piece ~= PAWN then
					local disambiguator = getDisambiguator(move, moves)
					output ..= string.upper(move.piece) .. disambiguator
				end
				local _value_2 = bit32.band(move.flags, (bit32.bor(BITS.CAPTURE, BITS.EP_CAPTURE)))
				if _value_2 ~= 0 and (_value_2 == _value_2 and _value_2) then
					if move.piece == PAWN then
						output ..= string.sub(algebraic(move.from), 1, 1)
					end
					output ..= "x"
				end
				output ..= algebraic(move.to)
				if move.promotion then
					output ..= "=" .. string.upper(move.promotion)
				end
			end
		end
		self:_makeMove(move)
		if self:isCheck() then
			if self:isCheckmate() then
				output ..= "#"
			else
				output ..= "+"
			end
		end
		self:_undoMove()
		return output
	end
	function Chess:_moveFromSan(move, sloppy)
		if sloppy == nil then
			sloppy = false
		end
		-- strip off any move decorations: e.g Nf3+?! becomes Nf3
		local cleanMove = strippedSan(move)
		local pieceType = inferPieceType(cleanMove)
		local moves = self:_moves({
			legal = true,
			piece = pieceType,
		})
		-- strict parser
		do
			local i = 0
			local len = #moves
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < len) then
					break
				end
				if cleanMove == strippedSan(self:_moveToSan(moves[i + 1], moves)) then
					return moves[i + 1]
				end
			end
		end
		-- strict parser failed and the sloppy parser wasn't used, return null
		if not sloppy then
			return nil
		end
		local piece = nil
		local matches = nil
		local from = nil
		local to = nil
		local promotion = nil
		-- The sloppy parser allows the user to parse non-standard chess
		-- notations. This parser is opt-in (by specifying the
		-- '{ sloppy: true }' setting) and is only run after the Standard
		-- Algebraic Notation (SAN) parser has failed.
		-- 
		-- When running the sloppy parser, we'll run a regex to grab the piece,
		-- the to/from square, and an optional promotion piece. This regex will
		-- parse common non-standard notation like: Pe2-e4, Rc1c4, Qf3xf7,
		-- f7f8q, b1c3
		-- NOTE: Some positions and moves may be ambiguous when using the
		-- sloppy parser. For example, in this position:
		-- 6k1/8/8/B7/8/8/8/BN4K1 w - - 0 1, the move b1c3 may be interpreted
		-- as Nc3 or B1c3 (a disambiguated bishop move). In these cases, the
		-- sloppy parser will default to the most most basic interpretation
		-- (which is b1c3 parsing to Nc3).
		-- FIXME: these var's are hoisted into function scope, this will need
		-- to change when switching to const/let
		local overlyDisambiguated = false
		-- matches = cleanMove.match('([pnbrqkPNBRQK])?([a-h][1-8])x?-?([a-h][1-8])([qrbnQRBN])')
		matches = { string.match(cleanMove, "([pnbrqkPNBRQK])") }
		matches = { string.match(cleanMove, "([pnbrqkPNBRQK])?([a-h][1-8])x?-?([a-h][1-8])([qrbnQRBN])?") }
		local _value = matches[1]
		if _value ~= 0 and (_value == _value and (_value ~= "" and _value)) then
			piece = matches[2]
			from = matches[3]
			to = matches[4]
			promotion = matches[5]
			if #from == 1 then
				overlyDisambiguated = true
			end
		else
			-- The [a-h]?[1-8]? portion of the regex below handles moves that may
			-- be overly disambiguated (e.g. Nge7 is unnecessary and non-standard
			-- when there is one legal knight move to e7). In this case, the value
			-- of 'from' variable will be a rank or file, not a square.
			matches = { string.match(cleanMove, "([pnbrqkPNBRQK])?([a-h]?[1-8]?)x?-?([a-h][1-8])([qrbnQRBN])?") }
			local _value_1 = matches[1]
			if _value_1 ~= 0 and (_value_1 == _value_1 and (_value_1 ~= "" and _value_1)) then
				piece = matches[2]
				from = matches[3]
				to = matches[4]
				promotion = matches[5]
				if #from == 1 then
					overlyDisambiguated = true
				end
			end
		end
		pieceType = inferPieceType(cleanMove)
		moves = self:_moves({
			legal = true,
			piece = if piece ~= 0 and (piece == piece and (piece ~= "" and piece)) then piece else pieceType,
		})
		do
			local i = 0
			local len = #moves
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < len) then
					break
				end
				if from and to then
					-- hand-compare move properties with the results from our sloppy
					-- regex
					if (not (piece ~= 0 and (piece == piece and (piece ~= "" and piece))) or string.lower(piece) == moves[i + 1].piece) and (Ox88[from] == moves[i + 1].from and (Ox88[to] == moves[i + 1].to and (not (promotion ~= 0 and (promotion == promotion and (promotion ~= "" and promotion))) or string.lower(promotion) == moves[i + 1].promotion))) then
						return moves[i + 1]
					elseif overlyDisambiguated then
						-- SPECIAL CASE: we parsed a move string that may have an
						-- unneeded rank/file disambiguator (e.g. Nge7).  The 'from'
						-- variable will
						local square = algebraic(moves[i + 1].from)
						if (not (piece ~= 0 and (piece == piece and (piece ~= "" and piece))) or string.lower(piece) == moves[i + 1].piece) and (Ox88[to] == moves[i + 1].to and ((from == string.sub(square, 1, 1) or from == string.sub(square, 2, 2)) and (not (promotion ~= 0 and (promotion == promotion and (promotion ~= "" and promotion))) or string.lower(promotion) == moves[i + 1].promotion))) then
							return moves[i + 1]
						end
					end
				end
			end
		end
		return nil
	end
	function Chess:ascii()
		local s = "   +------------------------+\n"
		do
			local _i = Ox88.a8
			local _shouldIncrement = false
			while true do
				local i = _i
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= Ox88.h1) then
					break
				end
				-- display the rank
				if file(i) == 0 then
					local ranking = rank(i)
					s ..= " " .. string.sub("87654321", ranking, ranking) .. " |"
				end
				if self._board[i + 1] then
					local piece = self._board[i + 1].type
					local color = self._board[i + 1].color
					local symbol = if color == WHITE then string.upper(piece) else string.lower(piece)
					s ..= " " .. symbol .. " "
				else
					s ..= " . "
				end
				local _value = bit32.band((i + 1), 0x88)
				if _value ~= 0 and (_value == _value and _value) then
					s ..= "|\n"
					i += 8
				end
				_i = i
			end
		end
		s ..= "   +------------------------+\n"
		s ..= "     a  b  c  d  e  f  g  h"
		return s
	end
	function Chess:perft(depth)
		local moves = self:_moves({
			legal = false,
		})
		local nodes = 0
		local color = self._turn
		do
			local i = 0
			local len = #moves
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < len) then
					break
				end
				self:_makeMove(moves[i + 1])
				if not self:_isKingAttacked(color) then
					if depth - 1 > 0 then
						nodes += self:perft(depth - 1)
					else
						nodes += 1
					end
				end
				self:_undoMove()
			end
		end
		return nodes
	end
	function Chess:_makePretty(uglyMove)
		local _binding = uglyMove
		local color = _binding.color
		local piece = _binding.piece
		local from = _binding.from
		local to = _binding.to
		local flags = _binding.flags
		local captured = _binding.captured
		local promotion = _binding.promotion
		local prettyFlags = ""
		local _arg0 = function(v, k)
			local _value = bit32.band(v, flags)
			if _value ~= 0 and (_value == _value and _value) then
				prettyFlags ..= FLAGS[k]
			end
		end
		for _k, _v in BITS do
			_arg0(_v, _k, BITS)
		end
		-- for (const flag in BITS) {
		-- if (BITS[flag] & flags) {
		-- prettyFlags += FLAGS[flag]
		-- }
		-- }
		local move = {
			color = color,
			piece = piece,
			from = algebraic(from),
			to = algebraic(to),
			san = self:_moveToSan(uglyMove, self:_moves({
				legal = true,
			})),
			flags = prettyFlags,
		}
		if captured then
			move.captured = captured
		end
		if promotion then
			move.promotion = promotion
		end
		return move
	end
	function Chess:turn()
		return self._turn
	end
	function Chess:GantiTurn(warna)
		self._turn = warna
		return self._turn
	end
	function Chess:board()
		local output = {}
		local row = {}
		do
			local _i = Ox88.a8
			local _shouldIncrement = false
			while true do
				local i = _i
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= Ox88.h1) then
					break
				end
				if self._board[i + 1] == nil then
					table.insert(row, nil)
				else
					local _row = row
					local _arg0 = {
						square = algebraic(i),
						type = self._board[i + 1].type,
						color = self._board[i + 1].color,
					}
					table.insert(_row, _arg0)
				end
				local _value = bit32.band((i + 1), 0x88)
				if _value ~= 0 and (_value == _value and _value) then
					local _row = row
					table.insert(output, _row)
					row = {}
					i += 8
				end
				_i = i
			end
		end
		return output
	end
	function Chess:squareColor(square)
		if Ox88[square] ~= nil then
			local sq = Ox88[square]
			return if (rank(sq) + file(sq)) % 2 == 0 then "light" else "dark"
		end
		return nil
	end
	function Chess:history(_param)
		if _param == nil then
			_param = {}
		end
		local verbose = _param.verbose
		if verbose == nil then
			verbose = false
		end
		local reversedHistory = {}
		local moveHistory = {}
		while #self._history > 0 do
			local _arg0 = self:_undoMove()
			table.insert(reversedHistory, _arg0)
		end
		while true do
			-- ▼ Array.pop ▼
			local _length = #reversedHistory
			local _result = reversedHistory[_length]
			reversedHistory[_length] = nil
			-- ▲ Array.pop ▲
			local move = _result
			if not move then
				break
			end
			if verbose then
				local _arg0 = self:_makePretty(move)
				table.insert(moveHistory, _arg0)
			else
				local _arg0 = self:_moveToSan(move, self:_moves())
				table.insert(moveHistory, _arg0)
			end
			self:_makeMove(move)
		end
		return moveHistory
	end
	function Chess:_pruneComments()
		local reversedHistory = {}
		local currentComments = {}
		local copyComment = function(fen)
			if self._comments[fen] ~= nil then
				local _arg1 = self._comments.fen
				currentComments.fen = _arg1
			end
		end
		while #self._history > 0 do
			local _arg0 = self:_undoMove()
			table.insert(reversedHistory, _arg0)
		end
		copyComment(self:fen())
		while true do
			-- ▼ Array.pop ▼
			local _length = #reversedHistory
			local _result = reversedHistory[_length]
			reversedHistory[_length] = nil
			-- ▲ Array.pop ▲
			local move = _result
			if not move then
				break
			end
			self:_makeMove(move)
			copyComment(self:fen())
		end
		self._comments = currentComments
	end
	function Chess:getComment()
		local __comments = self._comments
		local _arg0 = self:fen()
		return __comments[_arg0]
	end
	function Chess:setComment(comment)
		local __comments = self._comments
		local _arg0 = self:fen()
		local _arg1 = (string.gsub((string.gsub(comment, "{", "[")), "}", "]"))
		__comments[_arg0] = _arg1
	end
	function Chess:deleteComment()
		local __comments = self._comments
		local _arg0 = self:fen()
		local comment = __comments[_arg0]
		local __comments_1 = self._comments
		local _arg0_1 = self:fen()
		__comments_1[_arg0_1] = nil
		return comment
	end
	function Chess:getComments()
		self:_pruneComments()
		local data = {}
		local __comments = self._comments
		local _arg0 = function(v, k)
			local _arg0_1 = {
				fen = k,
				comment = v,
			}
			table.insert(data, _arg0_1)
		end
		for _k, _v in __comments do
			_arg0(_v, _k, __comments)
		end
		-- return Object.keys(this._comments).map((fen: string) => {
		-- return { fen: fen, comment: this._comments[fen] }
		-- })
		return data
	end
	function Chess:deleteComments()
		self:_pruneComments()
		local _ = self._comments
		local data = {}
		local __comments = self._comments
		local _arg0 = function(v, k)
			local _arg0_1 = {
				fen = k,
				comment = v,
			}
			table.insert(data, _arg0_1)
			local __comments_1 = self._comments
			local _k = k
			__comments_1[_k] = nil
		end
		for _k, _v in __comments do
			_arg0(_v, _k, __comments)
		end
		return data
		-- return Object.keys(this._comments).map((fen) => {
		-- const comment = this._comments[fen]
		-- delete this._comments[fen]
		-- return { fen: fen, comment: comment }
		-- })
	end
end
return {
	validateFen = validateFen,
	CaturAI = CaturAI,
	Chess = Chess,
}
