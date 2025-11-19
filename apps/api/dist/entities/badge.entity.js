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
exports.Badge = void 0;
const typeorm_1 = require("typeorm");
const item_entity_1 = require("./item.entity");
const coupon_entity_1 = require("./coupon.entity");
const storage_util_1 = require("../common/utils/storage.util");
let Badge = class Badge extends typeorm_1.BaseEntity {
    hydrateUrls() {
        if (this.iconUrl) {
            this.iconUrl = (0, storage_util_1.toPublicUrl)(this.iconUrl);
        }
    }
};
exports.Badge = Badge;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Badge.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50 }),
    __metadata("design:type", String)
], Badge.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, unique: true, nullable: true }),
    __metadata("design:type", String)
], Badge.prototype, "slug", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "icon_url", length: 255, nullable: true }),
    __metadata("design:type", String)
], Badge.prototype, "iconUrl", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "color_code", length: 7, nullable: true }),
    __metadata("design:type", String)
], Badge.prototype, "colorCode", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => item_entity_1.Item, (item) => item.badge),
    __metadata("design:type", Array)
], Badge.prototype, "items", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => coupon_entity_1.Coupon, (coupon) => coupon.badge),
    __metadata("design:type", Array)
], Badge.prototype, "coupons", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: "created_at" }),
    __metadata("design:type", Date)
], Badge.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)({ name: "updated_at" }),
    __metadata("design:type", Date)
], Badge.prototype, "updatedAt", void 0);
__decorate([
    (0, typeorm_1.AfterLoad)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], Badge.prototype, "hydrateUrls", null);
exports.Badge = Badge = __decorate([
    (0, typeorm_1.Entity)("badges")
], Badge);
