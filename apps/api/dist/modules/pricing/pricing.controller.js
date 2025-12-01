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
const item_entity_1 = require("../../entities/item.entity");
const item_coupon_link_entity_1 = require("../../entities/item_coupon_link.entity");
const coupon_entity_1 = require("../../entities/coupon.entity");
const pricing_service_1 = require("./pricing.service");
let PricingController = class PricingController {
    constructor(itemRepo, linkRepo, couponRepo, pricing) {
        this.itemRepo = itemRepo;
        this.linkRepo = linkRepo;
        this.couponRepo = couponRepo;
        this.pricing = pricing;
    }
    async bestDeal(itemId) {
        const item = await this.itemRepo.findOne({ where: { id: itemId } });
        if (!item)
            return { bestDeal: null };
        const links = await this.linkRepo.find({ where: { itemId } });
        if (!links.length)
            return { bestDeal: null };
        const ids = links.map((link) => link.couponId);
        const coupons = ids.length
            ? await this.couponRepo.findBy({ id: (0, typeorm_2.In)(ids) })
            : [];
        const deal = this.pricing.bestDealForProduct(item, coupons);
        return { bestDeal: deal };
    }
};
exports.PricingController = PricingController;
__decorate([
    (0, common_1.Get)("best-deal/:itemId"),
    __param(0, (0, common_1.Param)("itemId", common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], PricingController.prototype, "bestDeal", null);
exports.PricingController = PricingController = __decorate([
    (0, common_1.Controller)("pricing"),
    __param(0, (0, typeorm_1.InjectRepository)(item_entity_1.Item)),
    __param(1, (0, typeorm_1.InjectRepository)(item_coupon_link_entity_1.ItemCouponLink)),
    __param(2, (0, typeorm_1.InjectRepository)(coupon_entity_1.Coupon)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        pricing_service_1.PricingService])
], PricingController);
