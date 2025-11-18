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
exports.FavoriteCoupon = void 0;
const typeorm_1 = require("typeorm");
const user_entity_1 = require("./user.entity");
const coupon_entity_1 = require("./coupon.entity");
let FavoriteCoupon = class FavoriteCoupon extends typeorm_1.BaseEntity {
};
exports.FavoriteCoupon = FavoriteCoupon;
__decorate([
    (0, typeorm_1.PrimaryColumn)({ name: "user_id" }),
    __metadata("design:type", Number)
], FavoriteCoupon.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.PrimaryColumn)({ name: "coupon_id" }),
    __metadata("design:type", Number)
], FavoriteCoupon.prototype, "couponId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, (user) => user.favoriteCoupons, {
        onDelete: "CASCADE",
    }),
    (0, typeorm_1.JoinColumn)({ name: "user_id" }),
    __metadata("design:type", user_entity_1.User)
], FavoriteCoupon.prototype, "user", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => coupon_entity_1.Coupon, { onDelete: "CASCADE" }),
    (0, typeorm_1.JoinColumn)({ name: "coupon_id" }),
    __metadata("design:type", coupon_entity_1.Coupon)
], FavoriteCoupon.prototype, "coupon", void 0);
exports.FavoriteCoupon = FavoriteCoupon = __decorate([
    (0, typeorm_1.Entity)("favorite_coupons")
], FavoriteCoupon);
