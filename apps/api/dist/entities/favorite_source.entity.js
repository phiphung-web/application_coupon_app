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
exports.FavoriteSource = void 0;
const typeorm_1 = require("typeorm");
const user_entity_1 = require("./user.entity");
const source_entity_1 = require("./source.entity");
let FavoriteSource = class FavoriteSource extends typeorm_1.BaseEntity {
};
exports.FavoriteSource = FavoriteSource;
__decorate([
    (0, typeorm_1.PrimaryColumn)({ name: "user_id" }),
    __metadata("design:type", Number)
], FavoriteSource.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.PrimaryColumn)({ name: "source_id" }),
    __metadata("design:type", Number)
], FavoriteSource.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, (user) => user.favoriteSources, {
        onDelete: "CASCADE",
    }),
    (0, typeorm_1.JoinColumn)({ name: "user_id" }),
    __metadata("design:type", user_entity_1.User)
], FavoriteSource.prototype, "user", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => source_entity_1.Source, { onDelete: "CASCADE" }),
    (0, typeorm_1.JoinColumn)({ name: "source_id" }),
    __metadata("design:type", source_entity_1.Source)
], FavoriteSource.prototype, "source", void 0);
exports.FavoriteSource = FavoriteSource = __decorate([
    (0, typeorm_1.Entity)("favorite_sources")
], FavoriteSource);
