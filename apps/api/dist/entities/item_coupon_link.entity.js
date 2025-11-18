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
exports.ItemCouponLink = void 0;
const typeorm_1 = require("typeorm");
const item_entity_1 = require("./item.entity");
const coupon_entity_1 = require("./coupon.entity");
let ItemCouponLink = class ItemCouponLink extends typeorm_1.BaseEntity {
};
exports.ItemCouponLink = ItemCouponLink;
__decorate([
    (0, typeorm_1.PrimaryColumn)({ name: "item_id" }),
    __metadata("design:type", Number)
], ItemCouponLink.prototype, "itemId", void 0);
__decorate([
    (0, typeorm_1.PrimaryColumn)({ name: "coupon_id" }),
    __metadata("design:type", Number)
], ItemCouponLink.prototype, "couponId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => item_entity_1.Item, (item) => item.couponLinks, {
        onDelete: "CASCADE",
    }),
    (0, typeorm_1.JoinColumn)({ name: "item_id" }),
    __metadata("design:type", item_entity_1.Item)
], ItemCouponLink.prototype, "item", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => coupon_entity_1.Coupon, (coupon) => coupon.itemLinks, {
        onDelete: "CASCADE",
    }),
    (0, typeorm_1.JoinColumn)({ name: "coupon_id" }),
    __metadata("design:type", coupon_entity_1.Coupon)
], ItemCouponLink.prototype, "coupon", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "is_primary_display", default: false }),
    __metadata("design:type", Boolean)
], ItemCouponLink.prototype, "isPrimaryDisplay", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: "linked_at" }),
    __metadata("design:type", Date)
], ItemCouponLink.prototype, "linkedAt", void 0);
exports.ItemCouponLink = ItemCouponLink = __decorate([
    (0, typeorm_1.Entity)("item_coupon_links")
], ItemCouponLink);
