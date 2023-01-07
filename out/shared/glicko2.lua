-- Compiled with roblox-ts v2.0.4
-- eslint-disable @typescript-eslint/no-explicit-any
local scallingFactor = 173.7178
local PlayerGlicko
do
	PlayerGlicko = setmetatable({}, {
		__tostring = function()
			return "PlayerGlicko"
		end,
	})
	PlayerGlicko.__index = PlayerGlicko
	function PlayerGlicko.new(...)
		local self = setmetatable({}, PlayerGlicko)
		return self:constructor(...) or self
	end
	function PlayerGlicko:constructor(rating, rd, vol, tau, default_rating, volatility_algorithm, id)
		self._tau = 0.5
		self.defaultRating = 1500
		self._volatility_algorithm = "newprocedure"
		self.id = 0
		self.adv_ranks = {}
		self.adv_rds = {}
		self.outcomes = {}
		self.__rating = 1500
		self.__rd = 350
		self.__vol = 0.06
		self.volatility_algorithms = {
			oldprocedure = function(v, delta)
				local sigma = self.__vol
				local phi = self.__rd
				local tau = self._tau
				local x1
				local x2
				local x3
				local y1
				local y2
				local y3
				local result
				local find_upper_falsep
				local upper = find_upper_falsep(phi, v, delta, tau)
				local a = math.log(math.pow(sigma, 2))
				local equation
				y1 = equation(phi, v, 0, a, tau, delta)
				if y1 > 0 then
					result = upper
				else
					x1 = 0
					x2 = x1
					y2 = y1
					x1 = x1 - 1
					y1 = equation(phi, v, x1, a, tau, delta)
					while y1 < 0 do
						x2 = x1
						y2 = y1
						x1 = x1 - 1
						y1 = equation(phi, v, x1, a, tau, delta)
					end
					do
						local i = 0
						local _shouldIncrement = false
						while true do
							if _shouldIncrement then
								i += 1
							else
								_shouldIncrement = true
							end
							if not (i < 21) then
								break
							end
							x3 = y1 * (x1 - x2) / (y2 - y1) + x1
							y3 = equation(phi, v, x3, a, tau, delta)
							if y3 > 0 then
								x1 = x3
								y1 = y3
							else
								x2 = x3
								y2 = y3
							end
						end
					end
					if math.exp((y1 * (x1 - x2) / (y2 - y1) + x1) / 2) > upper then
						result = upper
					else
						result = math.exp((y1 * (x1 - x2) / (y2 - y1) + x1) / 2)
					end
				end
				return result
			end,
			newprocedure = function(v, delta)
				-- Step 5.1
				local A = math.log(math.pow(self.__vol, 2))
				local f = self:_makef(delta, v, A)
				local epsilon = 0.0000001
				-- Step 5.2
				local B
				local k
				if math.pow(delta, 2) > math.pow(self.__rd, 2) + v then
					B = math.log(math.pow(delta, 2) - math.pow(self.__rd, 2) - v)
				else
					k = 1
					while f(A - k * self._tau) < 0 do
						k = k + 1
					end
					B = A - k * self._tau
				end
				-- Step 5.3
				local fA = f(A)
				local fB = f(B)
				-- Step 5.4
				local C
				local fC
				while math.abs(B - A) > epsilon do
					C = A + (A - B) * fA / (fB - fA)
					fC = f(C)
					if fC * fB <= 0 then
						A = B
						fA = fB
					else
						fA = fA / 2
					end
					B = C
					fB = fC
				end
				-- Step 5.5
				return math.exp(A / 2)
			end,
			newprocedure_mod = function(v, delta)
				-- Step 5.1
				local A = math.log(math.pow(self.__vol, 2))
				local f = self:_makef(delta, v, A)
				local epsilon = 0.0000001
				-- Step 5.2
				local B
				local k
				-- XXX mod
				if delta > math.pow(self.__rd, 2) + v then
					-- XXX mod
					B = math.log(delta - math.pow(self.__rd, 2) - v)
				else
					k = 1
					while f(A - k * self._tau) < 0 do
						k = k + 1
					end
					B = A - k * self._tau
				end
				-- Step 5.3
				local fA = f(A)
				local fB = f(B)
				-- Step 5.4
				local C
				local fC
				while math.abs(B - A) > epsilon do
					C = A + (A - B) * fA / (fB - fA)
					fC = f(C)
					if fC * fB < 0 then
						A = B
						fA = fB
					else
						fA = fA / 2
					end
					B = C
					fB = fC
				end
				-- Step 5.5
				return math.exp(A / 2)
			end,
			oldprocedure_simple = function(v, delta)
				local i = 0
				local a = math.log(math.pow(self.__vol, 2))
				local tau = self._tau
				local x0 = a
				local x1 = 0
				local d
				local h1
				local h2
				while math.abs(x0 - x1) > 0.00000001 do
					-- New iteration, so x(i) becomes x(i-1)
					x0 = x1
					d = math.pow(self.__rating, 2) + v + math.exp(x0)
					h1 = -(x0 - a) / math.pow(tau, 2) - 0.5 * math.exp(x0) / d + 0.5 * math.exp(x0) * math.pow(delta / d, 2)
					h2 = -1 / math.pow(tau, 2) - 0.5 * math.exp(x0) * (math.pow(self.__rating, 2) + v) / math.pow(d, 2) + 0.5 * math.pow(delta, 2) * math.exp(x0) * (math.pow(self.__rating, 2) + v - math.exp(x0)) / math.pow(d, 3)
					x1 = x0 - (h1 / h2)
				end
				return math.exp(x1 / 2)
			end,
		}
		self._tau = tau
		self.defaultRating = default_rating
		self._volatility_algorithm = volatility_algorithm
		self:setRating(rating)
		self:setRd(rd)
		self:setVol(vol)
		self.id = id
		self.adv_ranks = {}
		self.adv_rds = {}
		self.outcomes = {}
	end
	function PlayerGlicko:getRating()
		return self.__rating * scallingFactor + self.defaultRating
	end
	function PlayerGlicko:setRating(rating)
		self.__rating = (rating - self.defaultRating) / scallingFactor
	end
	function PlayerGlicko:getRd()
		return self.__rd * scallingFactor
	end
	function PlayerGlicko:setRd(rd)
		self.__rd = rd / scallingFactor
	end
	function PlayerGlicko:getVol()
		return self.__vol
	end
	function PlayerGlicko:setVol(vol)
		self.__vol = vol
	end
	function PlayerGlicko:addResult(opponent, outcome)
		local _adv_ranks = self.adv_ranks
		local ___rating = opponent.__rating
		table.insert(_adv_ranks, ___rating)
		local _adv_rds = self.adv_rds
		local ___rd = opponent.__rd
		table.insert(_adv_rds, ___rd)
		local _outcomes = self.outcomes
		local _outcome = outcome
		table.insert(_outcomes, _outcome)
	end
	function PlayerGlicko:update_rank()
		if not self:hasPlayed() then
			self:_preRatingRD()
			return nil
		end
		local v = self:_variance()
		local delta = self:_delta(v)
		self.__vol = self.volatility_algorithms[self._volatility_algorithm](v, delta)
		self:_preRatingRD()
		self.__rd = 1 / math.sqrt((1 / math.pow(self.__rd, 2)) + (1 / v))
		local tempSum = 0
		do
			local i = 0
			local len = #self.adv_ranks
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
				tempSum += self:_g(self.adv_rds[i + 1]) * (self.outcomes[i + 1] - self:_E(self.adv_ranks[i + 1], self.adv_rds[i + 1]))
			end
		end
		self.__rating += math.pow(self.__rd, 2) * tempSum
	end
	function PlayerGlicko:hasPlayed()
		return #self.outcomes > 0
	end
	function PlayerGlicko:_preRatingRD()
		self.__rd = math.sqrt(math.pow(self.__rd, 2) + math.pow(self.__vol, 2))
	end
	function PlayerGlicko:_variance()
		local tempSum = 0
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < #self.adv_ranks) then
					break
				end
				local tempE = self:_E(self.adv_ranks[i + 1], self.adv_rds[i + 1])
				tempSum += math.pow(self:_g(self.adv_rds[i + 1]), 2) * tempE * (1 - tempE)
			end
		end
		return 1 / tempSum
	end
	function PlayerGlicko:_E(p2rating, p2RD)
		return 1 / (1 + math.exp(-1 * self:_g(p2RD) * (self.__rating - p2rating)))
	end
	function PlayerGlicko:predict(p2)
		local diffRD = math.sqrt(math.pow(self.__rd, 2) + math.pow(p2.__rd, 2))
		return 1 / (1 + math.exp(-1 * self:_g(diffRD) * (self.__rating - p2.__rating)))
	end
	function PlayerGlicko:_g(RD)
		return 1 / math.sqrt(1 + 3 * math.pow(RD, 2) / math.pow(math.pi, 2))
	end
	function PlayerGlicko:_delta(v)
		local tempSum = 0
		do
			local i = 0
			local len = #self.adv_ranks
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
				tempSum += self:_g(self.adv_rds[i + 1]) * (self.outcomes[i + 1] - self:_E(self.adv_ranks[i + 1], self.adv_rds[i + 1]))
			end
		end
		return v * tempSum
	end
	function PlayerGlicko:_makef(delta, v, a)
		local this__rd = self.__rd
		local this__tau = self._tau
		return function(x)
			return math.exp(x) * (math.pow(delta, 2) - math.pow(this__rd, 2) - v - math.exp(x)) / (2 * math.pow(math.pow(this__rd, 2) + v + math.exp(x), 2)) - (x - a) / math.pow(this__tau, 2)
		end
	end
end
local Glicko2
do
	Glicko2 = setmetatable({}, {
		__tostring = function()
			return "Glicko2"
		end,
	})
	Glicko2.__index = Glicko2
	function Glicko2.new(...)
		local self = setmetatable({}, Glicko2)
		return self:constructor(...) or self
	end
	function Glicko2:constructor(settings)
		self._tau = .5
		self._default_rating = 1500
		self._default_rd = 350
		self._default_vol = 0.06
		self._volatility_algorithm = "newprocedure"
		self.players = {}
		self.players_index = 0
		local _condition = settings.tau
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = self._tau
		end
		self._tau = _condition
		local _condition_1 = settings.rating
		if not (_condition_1 ~= 0 and (_condition_1 == _condition_1 and _condition_1)) then
			_condition_1 = self._default_rating
		end
		self._default_rating = _condition_1
		local _condition_2 = settings.rd
		if not (_condition_2 ~= 0 and (_condition_2 == _condition_2 and _condition_2)) then
			_condition_2 = self._default_rd
		end
		self._default_rd = _condition_2
		local _condition_3 = settings.vol
		if not (_condition_3 ~= 0 and (_condition_3 == _condition_3 and _condition_3)) then
			_condition_3 = self._default_vol
		end
		self._default_vol = _condition_3
		self._volatility_algorithm = settings.volatility_algorithm or "newprocedure"
	end
	function Glicko2:removePlayers()
		self.players = {}
		self.players_index = 0
	end
	function Glicko2:getPlayers()
		return self.players
	end
	function Glicko2:cleanPreviousMatch()
		do
			local i = 0
			local len = #self.players
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
				self.players[i + 1].adv_ranks = {}
				self.players[i + 1].adv_rds = {}
				self.players[i + 1].outcomes = {}
			end
		end
	end
	function Glicko2:calculatePlayersRatings()
		do
			local i = 0
			local len = #self.players
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
				self.players[i + 1]:update_rank()
			end
		end
	end
	function Glicko2:makePlayer(rating, rd, vol)
		return self:_createInternalPlayer(rating, rd, vol)
	end
	function Glicko2:_createInternalPlayer(rating, rd, vol, id)
		if id == nil then
			id = self.players_index
			self.players_index += 1
		else
			local candidate = self.players[id + 1]
			if candidate ~= nil then
				return candidate
			end
		end
		local _condition = rating
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = self._default_rating
		end
		local _condition_1 = rd
		if not (_condition_1 ~= 0 and (_condition_1 == _condition_1 and _condition_1)) then
			_condition_1 = self._default_rd
		end
		local _condition_2 = vol
		if not (_condition_2 ~= 0 and (_condition_2 == _condition_2 and _condition_2)) then
			_condition_2 = self._default_vol
		end
		local player = PlayerGlicko.new(_condition, _condition_1, _condition_2, self._tau, self._default_rating, self._volatility_algorithm, id)
		self.players[id + 1] = player
		return player
	end
	function Glicko2:addResult(player1, player2, outcome)
		player1:addResult(player2, outcome)
		player2:addResult(player1, 1 - outcome)
	end
	function Glicko2:updateRatings(matches)
		if matches ~= nil then
			self:cleanPreviousMatch()
			do
				local i = 0
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i += 1
					else
						_shouldIncrement = true
					end
					if not (i < #matches) then
						break
					end
					local match = matches[i + 1]
					self:addResult(match[1], match[2], match[3])
				end
			end
		end
		self:calculatePlayersRatings()
	end
	function Glicko2:predict(player1, player2)
		return player1:predict(player2)
	end
end
return {
	PlayerGlicko = PlayerGlicko,
	Glicko2 = Glicko2,
}
