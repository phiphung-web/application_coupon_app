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
const coupon_entity_1 = require("../../entities/coupon.entity");
let PricingService = class PricingService {
    bestDealForProduct(item, coupons) {
        const base = item.price ? Number(item.price) : 0;
        if (!base)
            return null;
        const now = new Date();
        let bestAfter = base;
        let picked = null;
        for (const coupon of coupons) {
            if (coupon.startDate && coupon.startDate > now)
                continue;
            if (coupon.endDate && coupon.endDate < now)
                continue;
            const value = coupon.discountValue
                ? Number(coupon.discountValue)
                : undefined;
            let cut = 0;
            if (coupon.discountType === coupon_entity_1.DiscountType.FIXED_AMOUNT &&
                value != null) {
                cut = Math.min(value, base);
            }
            else if (coupon.discountType === coupon_entity_1.DiscountType.PERCENT &&
                value != null) {
                cut = Math.min((base * value) / 100, base);
            }
            else {
                cut = value ?? 0;
            }
            const after = Math.max(base - cut, 0);
            if (after < bestAfter) {
                bestAfter = after;
                picked = coupon;
            }
        }
        if (!picked)
            return null;
        return { after: bestAfter, saved: base - bestAfter, coupon: picked };
    }
};
exports.PricingService = PricingService;
exports.PricingService = PricingService = __decorate([
    (0, common_1.Injectable)()
], PricingService);
