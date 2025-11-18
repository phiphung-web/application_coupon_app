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
exports.ItemCategory = void 0;
const typeorm_1 = require("typeorm");
const item_entity_1 = require("./item.entity");
let ItemCategory = class ItemCategory extends typeorm_1.BaseEntity {
};
exports.ItemCategory = ItemCategory;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], ItemCategory.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 100 }),
    __metadata("design:type", String)
], ItemCategory.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "parent_id", nullable: true }),
    __metadata("design:type", Number)
], ItemCategory.prototype, "parentId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => ItemCategory, (cat) => cat.children, { onDelete: "SET NULL" }),
    (0, typeorm_1.JoinColumn)({ name: "parent_id" }),
    __metadata("design:type", ItemCategory)
], ItemCategory.prototype, "parent", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => ItemCategory, (cat) => cat.parent),
    __metadata("design:type", Array)
], ItemCategory.prototype, "children", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "image_url", length: 255, nullable: true }),
    __metadata("design:type", String)
], ItemCategory.prototype, "imageUrl", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => item_entity_1.Item, (item) => item.category),
    __metadata("design:type", Array)
], ItemCategory.prototype, "items", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: "created_at" }),
    __metadata("design:type", Date)
], ItemCategory.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)({ name: "updated_at" }),
    __metadata("design:type", Date)
], ItemCategory.prototype, "updatedAt", void 0);
exports.ItemCategory = ItemCategory = __decorate([
    (0, typeorm_1.Entity)("item_categories")
], ItemCategory);
