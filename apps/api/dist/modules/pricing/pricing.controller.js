"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PricingController = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const product_entity_1 = require("../../entities/product.entity");
const product_coupon_entity_1 = require("../../entities/product_coupon.entity");
const coupon_entity_1 = require("../../entities/coupon.entity");
const pricing_service_1 = require("./pricing.service");
let PricingController = class PricingController {
    constructor(prodRepo, pcRepo, couponRepo, pricing) {
        this.prodRepo = prodRepo;
        this.pcRepo = pcRepo;
        this.couponRepo = couponRepo;
        this.pricing = pricing;
    }
    async bestDeal(productId) {
        const p = await this.prodRepo.findOne({ where: { id: productId } });
        if (!p)
            return { bestDeal: null };
        const pcs = await this.pcRepo.find({ where: { productId } });
        const ids = pcs.map((x) => x.couponId);
        if (!ids.length)
            return { bestDeal: null };
        const coupons = await this.couponRepo.findByIds(ids);
        const deal = this.pricing.bestDealForProduct(p, coupons);
        return { bestDeal: deal };
    }
};
exports.PricingController = PricingController;
__decorate([
    (0, common_1.Get)("best-deal/:productId"),
    __param(0, (0, common_1.Param)("productId", common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], PricingController.prototype, "bestDeal", null);
exports.PricingController = PricingController = __decorate([
    (0, common_1.Controller)("pricing"),
    __param(0, (0, typeorm_1.InjectRepository)(product_entity_1.Product)),
    __param(1, (0, typeorm_1.InjectRepository)(product_coupon_entity_1.ProductCoupon)),
    __param(2, (0, typeorm_1.InjectRepository)(coupon_entity_1.Coupon)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        pricing_service_1.PricingService])
], PricingController);
