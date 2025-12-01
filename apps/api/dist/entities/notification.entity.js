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
exports.Notification = exports.NotificationCategory = void 0;
const typeorm_1 = require("typeorm");
const source_entity_1 = require("./source.entity");
const item_entity_1 = require("./item.entity");
const coupon_entity_1 = require("./coupon.entity");
var NotificationCategory;
(function (NotificationCategory) {
    NotificationCategory["SYSTEM"] = "SYSTEM";
    NotificationCategory["EVENT"] = "EVENT";
    NotificationCategory["PERSONAL"] = "PERSONAL";
})(NotificationCategory || (exports.NotificationCategory = NotificationCategory = {}));
let Notification = class Notification extends typeorm_1.BaseEntity {
};
exports.Notification = Notification;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Notification.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: "enum",
        enum: NotificationCategory,
        default: NotificationCategory.SYSTEM,
    }),
    __metadata("design:type", String)
], Notification.prototype, "category", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 255 }),
    __metadata("design:type", String)
], Notification.prototype, "title", void 0);
__decorate([
    (0, typeorm_1.Column)("text"),
    __metadata("design:type", String)
], Notification.prototype, "message", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: "jsonb", nullable: true }),
    __metadata("design:type", Object)
], Notification.prototype, "payload", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "source_id", nullable: true }),
    __metadata("design:type", Number)
], Notification.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => source_entity_1.Source, { onDelete: "SET NULL" }),
    (0, typeorm_1.JoinColumn)({ name: "source_id" }),
    __metadata("design:type", source_entity_1.Source)
], Notification.prototype, "source", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "item_id", nullable: true }),
    __metadata("design:type", Number)
], Notification.prototype, "itemId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => item_entity_1.Item, { onDelete: "SET NULL" }),
    (0, typeorm_1.JoinColumn)({ name: "item_id" }),
    __metadata("design:type", item_entity_1.Item)
], Notification.prototype, "item", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "coupon_id", nullable: true }),
    __metadata("design:type", Number)
], Notification.prototype, "couponId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => coupon_entity_1.Coupon, { onDelete: "SET NULL" }),
    (0, typeorm_1.JoinColumn)({ name: "coupon_id" }),
    __metadata("design:type", coupon_entity_1.Coupon)
], Notification.prototype, "coupon", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "tags", type: "text", array: true, nullable: true }),
    __metadata("design:type", Array)
], Notification.prototype, "tags", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "importance", type: "smallint", default: 0 }),
    __metadata("design:type", Number)
], Notification.prototype, "importance", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: "created_at" }),
    __metadata("design:type", Date)
], Notification.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: "expires_at", type: "timestamptz", nullable: true }),
    __metadata("design:type", Date)
], Notification.prototype, "expiresAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)({ name: "updated_at" }),
    __metadata("design:type", Date)
], Notification.prototype, "updatedAt", void 0);
exports.Notification = Notification = __decorate([
    (0, typeorm_1.Entity)("notifications")
], Notification);
