"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminCmsModule = void 0;
// src/admin/admin.module.ts
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const nestjs_1 = require("@adminjs/nestjs");
const typeorm_2 = require("@adminjs/typeorm");
const typeorm_3 = require("typeorm");
const adminjs_1 = __importDefault(require("adminjs"));
const item_entity_1 = require("../entities/item.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const category_entity_1 = require("../entities/category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const badge_entity_1 = require("../entities/badge.entity");
const source_entity_1 = require("../entities/source.entity");
const item_coupon_link_entity_1 = require("../entities/item_coupon_link.entity");
const user_entity_1 = require("../entities/user.entity");
const admin_options_1 = require("./admin.options");
adminjs_1.default.registerAdapter({ Database: typeorm_2.Database, Resource: typeorm_2.Resource });
let AdminCmsModule = class AdminCmsModule {
};
exports.AdminCmsModule = AdminCmsModule;
exports.AdminCmsModule = AdminCmsModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forFeature([
                item_entity_1.Item,
                coupon_entity_1.Coupon,
                category_entity_1.Category,
                coupon_category_entity_1.CouponCategory,
                badge_entity_1.Badge,
                source_entity_1.Source,
                item_coupon_link_entity_1.ItemCouponLink,
                user_entity_1.User,
            ]),
            nestjs_1.AdminModule.createAdminAsync({
                inject: [typeorm_3.DataSource],
                useFactory: async (ds) => {
                    const adminJsOptions = (0, admin_options_1.buildAdminOptions)(ds);
                    return {
                        adminJsOptions,
                        auth: {
                            authenticate: async (email, password) => email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD
                                ? { email }
                                : null,
                            cookieName: "adminjs",
                            cookiePassword: process.env.ADMIN_COOKIE_SECRET || "secret-password",
                        },
                        sessionOptions: {
                            resave: false,
                            saveUninitialized: true,
                            secret: process.env.ADMIN_COOKIE_SECRET || "secret-password",
                        },
                    };
                },
            }),
        ],
    })
], AdminCmsModule);
