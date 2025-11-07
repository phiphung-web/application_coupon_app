"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PricingService = void 0;
const common_1 = require("@nestjs/common");
let PricingService = class PricingService {
    bestDealForProduct(p, coupons) {
        var _a, _b;
        const base = (_a = p.priceCurrent) !== null && _a !== void 0 ? _a : p.priceOriginal;
        let pick = null;
        let bestAfter = base;
        const now = new Date();
        for (const c of coupons) {
            if (!c.isActive)
                continue;
            if (c.endAt && c.endAt < now)
                continue;
            if (c.minSpend && base < c.minSpend)
                continue;
            let cut = 0;
            if (c.discountType === "FIXED") {
                cut = Math.min(c.discountValue, base);
            }
            else {
                const raw = Math.floor((base * c.discountValue) / 100);
                cut = Math.min(raw, (_b = c.maxDiscount) !== null && _b !== void 0 ? _b : raw);
            }
            const after = Math.max(base - cut, 0);
            if (after < bestAfter) {
                bestAfter = after;
                pick = c;
            }
        }
        if (!pick)
            return null;
        return { after: bestAfter, saved: base - bestAfter, coupon: pick };
    }
};
exports.PricingService = PricingService;
exports.PricingService = PricingService = __decorate([
    (0, common_1.Injectable)()
], PricingService);
