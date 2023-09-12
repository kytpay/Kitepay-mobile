"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TipLink = void 0;
const web3_js_1 = require("@solana/web3.js");
const libsodium_wrappers_sumo_1 = __importDefault(require("libsodium-wrappers-sumo"));
const bs58_1 = require("bs58");
const DEFAULT_TIPLINK_KEYLENGTH = 12;
const TIPLINK_ORIGIN = "https://tiplink.io";
const TIPLINK_PATH = "/i";
const getSodium = () => __awaiter(void 0, void 0, void 0, function* () {
    yield libsodium_wrappers_sumo_1.default.ready;
    return libsodium_wrappers_sumo_1.default;
});
const kdf = (fullLength, pwShort, salt) => __awaiter(void 0, void 0, void 0, function* () {
    const sodium = yield getSodium();
    return sodium.crypto_pwhash(fullLength, pwShort, salt, sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE, sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE, sodium.crypto_pwhash_ALG_DEFAULT);
});
const randBuf = (l) => __awaiter(void 0, void 0, void 0, function* () {
    const sodium = yield getSodium();
    return sodium.randombytes_buf(l);
});
const kdfz = (fullLength, pwShort) => __awaiter(void 0, void 0, void 0, function* () {
    const sodium = yield getSodium();
    const salt = new Uint8Array(sodium.crypto_pwhash_SALTBYTES);
    return yield kdf(fullLength, pwShort, salt);
});
const pwToKeypair = (pw) => __awaiter(void 0, void 0, void 0, function* () {
    const sodium = yield getSodium();
    const seed = yield kdfz(sodium.crypto_sign_SEEDBYTES, pw);
    return (web3_js_1.Keypair.fromSeed(seed));
});
class TipLink {
    constructor(url, keypair) {
        this.url = url;
        this.keypair = keypair;
    }
    static create() {
        return __awaiter(this, void 0, void 0, function* () {
            yield getSodium();
            const b = yield randBuf(DEFAULT_TIPLINK_KEYLENGTH);
            const keypair = yield pwToKeypair(b);
            const link = new URL(TIPLINK_PATH, TIPLINK_ORIGIN);
            link.hash = (0, bs58_1.encode)(b);
            const tiplink = new TipLink(link, keypair);
            return tiplink;
        });
    }
    static fromUrl(url) {
        return __awaiter(this, void 0, void 0, function* () {
            const slug = url.hash.slice(1);
            const pw = Uint8Array.from((0, bs58_1.decode)(slug));
            const keypair = yield pwToKeypair(pw);
            const tiplink = new TipLink(url, keypair);
            return tiplink;
        });
    }
    static fromLink(link) {
        return __awaiter(this, void 0, void 0, function* () {
            const url = new URL(link);
            return this.fromUrl(url);
        });
    }
}
exports.TipLink = TipLink;