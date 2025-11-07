"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CouponCategoriesModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const coupon_category_entity_1 = require("../../entities/coupon_category.entity");
const coupon_categories_controller_1 = require("./coupon-categories.controller");
const coupon_categories_service_1 = require("./coupon-categories.service");
let CouponCategoriesModule = class CouponCategoriesModule {
};
exports.CouponCategoriesModule = CouponCategoriesModule;
exports.CouponCategoriesModule = CouponCategoriesModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([coupon_category_entity_1.CouponCategory])],
        controllers: [coupon_categories_controller_1.CouponCategoriesController],
        providers: [coupon_categories_service_1.CouponCategoriesService],
        exports: [coupon_categories_service_1.CouponCategoriesService],
    })
], CouponCategoriesModule);
