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
exports.CouponCategory = void 0;
const typeorm_1 = require("typeorm");
let CouponCategory = class CouponCategory extends typeorm_1.BaseEntity {
};
exports.CouponCategory = CouponCategory;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], CouponCategory.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Index)(),
    (0, typeorm_1.Column)({ length: 120 }),
    __metadata("design:type", String)
], CouponCategory.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], CouponCategory.prototype, "imageUrl", void 0);
__decorate([
    (0, typeorm_1.Column)("int", { nullable: true }),
    __metadata("design:type", Number)
], CouponCategory.prototype, "parentId", void 0);
__decorate([
    (0, typeorm_1.Column)("int", { default: 0 }),
    __metadata("design:type", Number)
], CouponCategory.prototype, "priority", void 0);
__decorate([
    (0, typeorm_1.Index)(),
    (0, typeorm_1.Column)({ default: true }),
    __metadata("design:type", Boolean)
], CouponCategory.prototype, "isActive", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], CouponCategory.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], CouponCategory.prototype, "updatedAt", void 0);
__decorate([
    (0, typeorm_1.DeleteDateColumn)(),
    __metadata("design:type", Date)
], CouponCategory.prototype, "deletedAt", void 0);
exports.CouponCategory = CouponCategory = __decorate([
    (0, typeorm_1.Entity)("coupon_categories")
], CouponCategory);
