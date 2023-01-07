/* eslint-disable @typescript-eslint/no-explicit-any */
type Tipe_Volatility = "oldprocedure" | "newprocedure" | "newprocedure_mod" | "oldprocedure_simple"

type TipeSettings = {
    tau?: number,
    rating?: number,
    rd?: number,
    vol?: number,
    volatility_algorithm?: Tipe_Volatility
}

const scallingFactor = 173.7178;

export class PlayerGlicko {
    private _tau = 0.5;
    public defaultRating = 1500;
    private _volatility_algorithm: Tipe_Volatility = "newprocedure";
    public id = 0;

    public adv_ranks: number[] = [];
    public adv_rds: number[] = [];
    public outcomes: number[] = [];

    public __rating = 1500;
    public __rd = 350;
    public __vol = 0.06;

    private volatility_algorithms = {
        oldprocedure: (v: number, delta: number) => {
            const sigma = this.__vol;
            const phi = this.__rd;
            const tau = this._tau;

            let x1, x2, x3, y1, y2, y3;
            let result;

            const upper = find_upper_falsep(phi, v, delta, tau);

            const a = math.log(math.pow(sigma, 2));
            y1 = equation(phi, v, 0, a, tau, delta);
            if (y1 > 0 ){
                result = upper;
            } else {
                x1 = 0;
                x2 = x1;
                y2 = y1;
                x1 = x1 - 1;
                y1 = equation(phi, v, x1, a, tau, delta);
                while (y1 < 0){
                    x2 = x1;
                    y2 = y1;
                    x1 = x1 - 1;
                    y1 = equation(phi, v, x1, a, tau, delta);
                }
                for (let i = 0; i<21; i++){
                    x3 = y1 * (x1 - x2) / (y2 - y1) + x1;
                    y3 = equation(phi, v, x3, a, tau, delta);
                    if (y3 > 0 ){
                        x1 = x3;
                        y1 = y3;
                    } else {
                        x2 = x3;
                        y2 = y3;
                    }
                }
                if (math.exp((y1 * (x1 - x2) / (y2 - y1) + x1) / 2) > upper ){
                    result = upper;
                } else {
                    result = math.exp((y1 * (x1 - x2) / (y2 - y1) + x1) / 2);
                }
            }
            return result;

            //
            function new_sigma(sigma: number , phi: number , v: number , delta: number , tau: number ) {
                const a = math.log(math.pow(sigma, 2));
                let x = a;
                let old_x = 0;
                while (x !== old_x){
                    old_x = x;
                    const d = math.pow(phi, 2) + v + math.exp(old_x);
                    const h1 = -(old_x - a) / math.pow(tau, 2) - 0.5 * math.exp(old_x) / d + 0.5 * math.exp(old_x) * math.pow((delta / d), 2);
                    const h2 = -1 / math.pow(tau, 2) - 0.5 * math.exp(old_x) * (math.pow(phi, 2) + v) / math.pow(d, 2) + 0.5 * math.pow(delta, 2) * math.exp(old_x) * (math.pow(phi, 2) + v - math.exp(old_x)) / math.pow(d, 3);
                    x = old_x - h1 / h2;
                }
                return  math.exp(x / 2);
            }

            function equation(phi: number , v: number , x: number , a: number , tau: number , delta: number) {
                const d = math.pow(phi, 2) + v + math.exp(x);
                return -(x - a) / math.pow(tau, 2) - 0.5 * math.exp(x) / d + 0.5 * math.exp(x) * math.pow((delta / d), 2);
            }

            function new_sigma_bisection(sigma: number , phi: any , v: any , delta: any , tau: any ) {
                let x1, x2, x3;
                const a = math.log(math.pow(sigma, 2));
                if (equation(phi, v, 0, a, tau, delta) < 0 ){
                    x1 = -1;
                    while (equation(phi, v, x1, a, tau, delta) < 0){
                        x1 = x1 - 1;
                    }
                    x2 = x1 + 1;
                } else {
                    x2 = 1;
                    while (equation(phi, v, x2, a, tau, delta) > 0){
                        x2 = x2 + 1;
                    }
                    x1 = x2 - 1;
                }

                for (let i = 0; i < 27; i++) {
                    x3 = (x1 + x2) / 2;
                    if (equation(phi, v, x3, a, tau, delta) > 0 ){
                        x1 = x3;
                    } else {
                        x2 = x3;
                    }
                }
                return  math.exp((x1 + x2)/ 4);
            }

            function Dequation(phi: number , v: number , x: number , tau: number , delta: number) {
                const d = math.pow(phi, 2) + v + math.exp(x);
                return -1 / math.pow(tau, 2) - 0.5 * math.exp(x) / d + 0.5 * math.exp(x) * (math.exp(x) + math.pow(delta, 2)) / math.pow(d, 2) - math.pow(math.exp(x), 2) * math.pow(delta, 2) / math.pow(d, 3);
            }

            function find_upper_falsep(phi: number , v: any , delta: any , tau: number) {
                let x1, x2, x3, y1, y2, y3;
                y1 = Dequation(phi, v, 0, tau, delta);
                if (y1 < 0 ){
                    return 1;
                } else {
                    x1 = 0;
                    x2 = x1;
                    y2 = y1;
                    x1 = x1 - 1;
                    y1 = Dequation(phi, v, x1, tau, delta);
                    while (y1 > 0){
                        x2 = x1;
                        y2 = y1;
                        x1 = x1 - 1;
                        y1 = Dequation(phi, v, x1, tau, delta);
                    }
                    for (let i = 0; i < 21 ; i++){
                        x3 = y1 * (x1 - x2) / (y2 - y1) + x1;
                        y3 = Dequation(phi, v, x3, tau, delta);
                        if (y3 > 0 ){
                            x1 = x3;
                            y1 = y3;
                        } else {
                            x2 = x3;
                            y2 = y3;
                        }
                    }
                    return math.exp((y1 * (x1 - x2) / (y2 - y1) + x1) / 2);
                }
            }
        },
        newprocedure: (v: number, delta: number) => {
            //Step 5.1
            let A = math.log(math.pow(this.__vol, 2));
            const f = this._makef(delta, v, A);
            const epsilon = 0.0000001;

            //Step 5.2
            let B, k;
            if (math.pow(delta, 2) >  math.pow(this.__rd, 2) + v){
                B = math.log(math.pow(delta, 2) -  math.pow(this.__rd, 2) - v);
            } else {
                k = 1;
                while (f(A - k * this._tau) < 0){
                    k = k + 1;
                }
                B = A - k * this._tau;
            }

            //Step 5.3
            let fA = f(A);
            let fB = f(B);

            //Step 5.4
            let C, fC;
            while (math.abs(B - A) > epsilon){
                C = A + (A - B) * fA /(fB - fA );
                fC = f(C);
                if (fC * fB <= 0){ // March 22, 2022 algorithm update : `<` replaced by `<=`
                    A = B;
                    fA = fB;
                } else {
                    fA = fA / 2;
                }
                B = C;
                fB = fC;
            }
            //Step 5.5
            return math.exp(A/2);
        },
        newprocedure_mod: (v: number, delta: number) => {
            //Step 5.1
            let A = math.log(math.pow(this.__vol, 2));
            const f = this._makef(delta, v, A);
            const epsilon = 0.0000001;

            //Step 5.2
            let B, k;
            //XXX mod
            if (delta >  math.pow(this.__rd, 2) + v){
                //XXX mod
                B = math.log(delta -  math.pow(this.__rd, 2) - v);
            } else {
                k = 1;
                while (f(A - k * this._tau) < 0){
                    k = k + 1;
                }
                B = A - k * this._tau;
            }

            //Step 5.3
            let fA = f(A);
            let fB = f(B);

            //Step 5.4
            let C, fC;
            while (math.abs(B - A) > epsilon){
                C = A + (A - B) * fA /(fB - fA );
                fC = f(C);
                if (fC * fB < 0){
                    A = B;
                    fA = fB;
                } else {
                    fA = fA / 2;
                }
                B = C;
                fB = fC;
            }
            //Step 5.5
            return math.exp(A/2);
        },
        oldprocedure_simple: (v: number, delta: number) => {
            const i = 0;
            const a = math.log(math.pow(this.__vol, 2));
            const tau = this._tau;
            let x0 = a;
            let x1 = 0;
            let d,h1,h2;

            while (math.abs(x0 - x1) > 0.00000001){
                // New iteration, so x(i) becomes x(i-1)
                x0 = x1;
                d = math.pow(this.__rating, 2) + v + math.exp(x0);
                h1 = -(x0 - a) / math.pow(tau, 2) - 0.5 * math.exp(x0) / d + 0.5 * math.exp(x0) * math.pow(delta / d, 2);
                h2 = -1 / math.pow(tau, 2) - 0.5 * math.exp(x0) * (math.pow(this.__rating, 2) + v) / math.pow(d, 2) + 0.5 * math.pow(delta, 2) * math.exp(x0) * (math.pow(this.__rating, 2) + v - math.exp(x0)) / math.pow(d, 3);
                x1 = x0 - (h1 / h2);
            }

            return math.exp(x1 / 2);
        }
    }

    constructor(rating: number, rd: number, vol: number, tau: number, default_rating: number, volatility_algorithm: Tipe_Volatility, id: number) {
        this._tau = tau;
        this.defaultRating = default_rating;
        this._volatility_algorithm = volatility_algorithm;

        this.setRating(rating);
        this.setRd(rd);
        this.setVol(vol);

        this.id = id;
        this.adv_ranks = [];
        this.adv_rds = [];
        this.outcomes = []
    }

    getRating() {
        return this.__rating * scallingFactor + this.defaultRating;
    }

    setRating(rating: number) {
        this.__rating = (rating - this.defaultRating) / scallingFactor;
    }

    getRd() {
        return this.__rd * scallingFactor;
    }

    setRd(rd: number) {
        this.__rd = rd / scallingFactor;
    }

    getVol() {
        return this.__vol
    }

    setVol(vol: number) {
        this.__vol = vol;
    }

    addResult(opponent: PlayerGlicko, outcome: number) {
        this.adv_ranks.push(opponent.__rating);
        this.adv_rds.push(opponent.__rd);
        this.outcomes.push(outcome);
    }

    update_rank() {
        if(!this.hasPlayed()) {
            this._preRatingRD();
            return; 
        }

        const v = this._variance();

        const delta = this._delta(v);

        this.__vol = this.volatility_algorithms[this._volatility_algorithm](v, delta);

        this._preRatingRD();

        this.__rd = 1 / math.sqrt((1 / math.pow(this.__rd, 2)) + (1 / v));

        let tempSum = 0;
        for (let i=0,len = this.adv_ranks.size(); i< len;i++){
            tempSum += this._g(this.adv_rds[i]) * (this.outcomes[i] - this._E(this.adv_ranks[i], this.adv_rds[i]));
        }
        this.__rating += math.pow(this.__rd, 2) * tempSum;
    }

    hasPlayed() {
        return this.outcomes.size() > 0;
    }

    private _preRatingRD() {
        this.__rd = math.sqrt(math.pow(this.__rd, 2) + math.pow(this.__vol, 2));
    }

    private _variance() {
        let tempSum = 0;
        for(let i = 0; i < this.adv_ranks.size(); i++) {
            const tempE = this._E(this.adv_ranks[i], this.adv_rds[i]);
            tempSum += math.pow(this._g(this.adv_rds[i]), 2) * tempE * (1 - tempE);
        }

        return 1 / tempSum;
    }

    private _E(p2rating: number, p2RD: number) {
        return 1 / (1 + math.exp(-1 * this._g(p2RD) *  (this.__rating - p2rating)));
    }

    predict(p2: PlayerGlicko) {
        const diffRD = math.sqrt(math.pow(this.__rd, 2) + math.pow(p2.__rd, 2));
        return 1 / (1 + math.exp(-1 * this._g(diffRD) *  (this.__rating - p2.__rating)));
    }

    private _g(RD: number) {
        return 1 / math.sqrt(1 + 3 * math.pow(RD, 2) / math.pow(math.pi, 2));
    }

    private _delta(v: number) {
        let tempSum = 0;
        for (let i = 0, len = this.adv_ranks.size(); i<len;i++){
            tempSum += this._g(this.adv_rds[i]) * (this.outcomes[i] - this._E(this.adv_ranks[i], this.adv_rds[i]));
        }
        return v * tempSum;
    }

    private _makef(delta: any, v: number, a: number) {
        const this__rd = this.__rd;
        const this__tau = this._tau;

        return function(x: number){
            return math.exp(x) * (math.pow(delta, 2) - math.pow(this__rd, 2) - v - math.exp(x)) / (2*math.pow(math.pow(this__rd, 2) + v + math.exp(x), 2)) - (x - a) / math.pow(this__tau, 2);
        };
    }
}

export class Glicko2 {
    private _tau = .5;
    private _default_rating = 1500;
    private _default_rd = 350;
    private _default_vol = 0.06;
    private _volatility_algorithm: Tipe_Volatility = "newprocedure"
    private players: PlayerGlicko[] = [];
    private players_index = 0;

    constructor(settings: TipeSettings) {
        this._tau = settings.tau || this._tau;
        this._default_rating = settings.rating || this._default_rating;
        this._default_rd = settings.rd || this._default_rd;
        this._default_vol = settings.vol || this._default_vol;

        this._volatility_algorithm = settings.volatility_algorithm || "newprocedure";
    }

    removePlayers() {
        this.players = [];
        this.players_index = 0;
    }

    getPlayers() {
        return this.players;
    }

    cleanPreviousMatch() {
        for (let i = 0, len = this.players.size();i < len;i++){
            this.players[i].adv_ranks = [];
            this.players[i].adv_rds = [];
            this.players[i].outcomes = [];
        }
    }

    calculatePlayersRatings() {
        for (let i=0, len = this.players.size(); i < len;i++){
            this.players[i].update_rank();
        }
    }

    // addMatch(player1: PlayerGlicko, player2: PlayerGlicko, outcome: number) {
    //     const pl1 = this._createInternalPlayer(player1.rating, player1.rd, player1.vol, player1.id);
    //     const pl2 = this._createInternalPlayer(player2.rating, player2.rd, player2.vol, player2.id);
    //     this.addResult(pl1, pl2, outcome);
    //     return {pl1:pl1, pl2:pl2};
    // }

    makePlayer(rating: number, rd: number, vol: number) {
        return this._createInternalPlayer(rating, rd, vol);
    }

    private _createInternalPlayer(rating: number, rd:number, vol: number, id?: number) {
        if(id === undefined) {
            id = this.players_index;
            this.players_index++;
        } else {
            const candidate = this.players[id];
            if(candidate !== undefined) return candidate;
        }

        const player = new PlayerGlicko(rating || this._default_rating, rd || this._default_rd, vol || this._default_vol, this._tau, this._default_rating, this._volatility_algorithm, id);
        this.players[id] = player;
        return player;
    }

    addResult(player1: PlayerGlicko, player2: PlayerGlicko, outcome: number) {
        player1.addResult(player2, outcome);
        player2.addResult(player1, 1 - outcome);
    }

    updateRatings(matches?: (number | PlayerGlicko)[][]) {
        if(matches !== undefined) {
            this.cleanPreviousMatch();
            for(let i = 0; i < matches.size(); i++) {
                const match = matches[i];
                this.addResult(match[0] as PlayerGlicko, match[1] as PlayerGlicko, match[2] as number);
            }
        }
        this.calculatePlayersRatings();
    }

    predict(player1: PlayerGlicko, player2: PlayerGlicko) {
        return player1.predict(player2);
    }
}