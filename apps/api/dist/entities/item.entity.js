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
exports.Item = exports.ItemType = void 0;
const typeorm_1 = require("typeorm");
const source_entity_1 = require("./source.entity");
const item_category_entity_1 = require("./item_category.entity");
const badge_entity_1 = require("./badge.entity");
const item_coupon_link_entity_1 = require("./item_coupon_link.entity");
const storage_util_1 = require("../common/utils/storage.util");
var ItemType;
(function (ItemType) {
    ItemType["PRODUCT"] = "PRODUCT";
    ItemType["APP"] = "APP";
    ItemType["GAME"] = "GAME";
    ItemType["SERVICE"] = "SERVICE";
})(ItemType || (exports.ItemType = ItemType = {}));
let Item = class Item extends typeorm_1.BaseEntity {
    hydrateUrls() {
        if (this.imageUrl) {
            this.imageUrl = (0, storage_util_1.toPublicUrl)(this.imageUrl);
        }
    }
};
exports.Item = Item;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Item.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 255 }),
    __metadata("design:type", String)
], Item.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)("text", { nullable: true }),
    __metadata("design:type", String)
], Item.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "image_url", length: 255, nullable: true }),
    __metadata("design:type", String)
], Item.prototype, "imageUrl", void 0);
__decorate([
    (0, typeorm_1.Column)({
        name: "item_type",
        type: "enum",
        enum: ItemType,
        default: ItemType.PRODUCT,
    }),
    __metadata("design:type", String)
], Item.prototype, "itemType", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "item_url", length: 255, nullable: true }),
    __metadata("design:type", String)
], Item.prototype, "itemUrl", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: "decimal",
        precision: 12,
        scale: 2,
        nullable: true,
    }),
    __metadata("design:type", String)
], Item.prototype, "price", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "source_id", nullable: true }),
    __metadata("design:type", Number)
], Item.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => source_entity_1.Source, (source) => source.items, {
        onDelete: "SET NULL",
    }),
    (0, typeorm_1.JoinColumn)({ name: "source_id" }),
    __metadata("design:type", source_entity_1.Source)
], Item.prototype, "source", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "category_id", nullable: true }),
    __metadata("design:type", Number)
], Item.prototype, "categoryId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => item_category_entity_1.ItemCategory, (category) => category.items, {
        onDelete: "SET NULL",
    }),
    (0, typeorm_1.JoinColumn)({ name: "category_id" }),
    __metadata("design:type", item_category_entity_1.ItemCategory)
], Item.prototype, "category", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "badge_id", nullable: true }),
    __metadata("design:type", Number)
], Item.prototype, "badgeId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => badge_entity_1.Badge, (badge) => badge.items, { onDelete: "SET NULL" }),
    (0, typeorm_1.JoinColumn)({ name: "badge_id" }),
    __metadata("design:type", badge_entity_1.Badge)
], Item.prototype, "badge", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => item_coupon_link_entity_1.ItemCouponLink, (link) => link.item),
    __metadata("design:type", Array)
], Item.prototype, "couponLinks", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "view_count", type: "int", default: 0 }),
    __metadata("design:type", Number)
], Item.prototype, "viewCount", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: "created_at" }),
    __metadata("design:type", Date)
], Item.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)({ name: "updated_at" }),
    __metadata("design:type", Date)
], Item.prototype, "updatedAt", void 0);
__decorate([
    (0, typeorm_1.AfterLoad)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], Item.prototype, "hydrateUrls", null);
exports.Item = Item = __decorate([
    (0, typeorm_1.Entity)("items")
], Item);
