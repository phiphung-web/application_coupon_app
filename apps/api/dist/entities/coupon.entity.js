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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Coupon = exports.DiscountType = void 0;
const typeorm_1 = require("typeorm");
const source_entity_1 = require("./source.entity");
const coupon_category_entity_1 = require("./coupon_category.entity");
const badge_entity_1 = require("./badge.entity");
const item_coupon_link_entity_1 = require("./item_coupon_link.entity");
const storage_util_1 = require("../common/utils/storage.util");
var DiscountType;
(function (DiscountType) {
    DiscountType["PERCENT"] = "PERCENT";
    DiscountType["FIXED_AMOUNT"] = "FIXED_AMOUNT";
    DiscountType["FREESHIP"] = "FREESHIP";
    DiscountType["GIFT"] = "GIFT";
})(DiscountType || (exports.DiscountType = DiscountType = {}));
let Coupon = class Coupon extends typeorm_1.BaseEntity {
    hydrateUrls() {
        if (this.imageUrl) {
            this.imageUrl = (0, storage_util_1.toPublicUrl)(this.imageUrl);
        }
    }
};
exports.Coupon = Coupon;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Coupon.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 100 }),
    __metadata("design:type", String)
], Coupon.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)("text", { nullable: true }),
    __metadata("design:type", String)
], Coupon.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "image_url", length: 255, nullable: true }),
    __metadata("design:type", String)
], Coupon.prototype, "imageUrl", void 0);
__decorate([
    (0, typeorm_1.Column)({
        name: "discount_type",
        type: "enum",
        enum: DiscountType,
        default: DiscountType.FIXED_AMOUNT,
    }),
    __metadata("design:type", String)
], Coupon.prototype, "discountType", void 0);
__decorate([
    (0, typeorm_1.Column)({
        name: "discount_value",
        type: "decimal",
        precision: 12,
        scale: 2,
        nullable: true,
    }),
    __metadata("design:type", String)
], Coupon.prototype, "discountValue", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "deal_url", length: 255, nullable: true }),
    __metadata("design:type", String)
], Coupon.prototype, "dealUrl", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "source_id", nullable: true }),
    __metadata("design:type", Number)
], Coupon.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => source_entity_1.Source, (source) => source.coupons, {
        onDelete: "SET NULL",
    }),
    (0, typeorm_1.JoinColumn)({ name: "source_id" }),
    __metadata("design:type", source_entity_1.Source)
], Coupon.prototype, "source", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "category_id", nullable: true }),
    __metadata("design:type", Number)
], Coupon.prototype, "categoryId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => coupon_category_entity_1.CouponCategory, (category) => category.coupons, {
        onDelete: "SET NULL",
    }),
    (0, typeorm_1.JoinColumn)({ name: "category_id" }),
    __metadata("design:type", coupon_category_entity_1.CouponCategory)
], Coupon.prototype, "category", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "badge_id", nullable: true }),
    __metadata("design:type", Number)
], Coupon.prototype, "badgeId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => badge_entity_1.Badge, (badge) => badge.coupons, { onDelete: "SET NULL" }),
    (0, typeorm_1.JoinColumn)({ name: "badge_id" }),
    __metadata("design:type", badge_entity_1.Badge)
], Coupon.prototype, "badge", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "start_date", type: "timestamptz", nullable: true }),
    __metadata("design:type", Date)
], Coupon.prototype, "startDate", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "end_date", type: "timestamptz", nullable: true }),
    __metadata("design:type", Date)
], Coupon.prototype, "endDate", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => item_coupon_link_entity_1.ItemCouponLink, (link) => link.coupon),
    __metadata("design:type", Array)
], Coupon.prototype, "itemLinks", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: "created_at" }),
    __metadata("design:type", Date)
], Coupon.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)({ name: "updated_at" }),
    __metadata("design:type", Date)
], Coupon.prototype, "updatedAt", void 0);
__decorate([
    (0, typeorm_1.AfterLoad)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], Coupon.prototype, "hydrateUrls", null);
exports.Coupon = Coupon = __decorate([
    (0, typeorm_1.Entity)("coupons")
], Coupon);
