"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildAdminOptions = buildAdminOptions;
const upload_1 = __importDefault(require("@adminjs/upload"));
const path_1 = require("path");
const fs_1 = require("fs");
const item_entity_1 = require("../entities/item.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const category_entity_1 = require("../entities/category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const badge_entity_1 = require("../entities/badge.entity");
const source_entity_1 = require("../entities/source.entity");
const item_coupon_link_entity_1 = require("../entities/item_coupon_link.entity");
const user_entity_1 = require("../entities/user.entity");
const UPLOADS_ROOT = (0, path_1.join)(process.cwd(), "apps", "api", "uploads");
function ensureDir(path) {
    if (!(0, fs_1.existsSync)(path)) {
        (0, fs_1.mkdirSync)(path, { recursive: true });
    }
}
function imageUploadFeature(folder, property = "imageUrl") {
    const bucket = (0, path_1.join)(UPLOADS_ROOT, folder);
    ensureDir(bucket);
    return (0, upload_1.default)({
        provider: {
            local: {
                bucket,
            },
        },
        properties: {
            key: property,
            file: `${property}File`,
        },
        publicPath: "/uploads",
        uploadPath: (_record, filename) => `${folder}/${Date.now()}-${filename.replace(/\s+/g, "-")}`,
    });
}
function buildAdminOptions(ds) {
    const resources = [
        {
            resource: item_entity_1.Item,
            options: {
                navigation: { name: "Catalog", icon: "Box" },
                properties: {
                    imageUrl: {
                        isVisible: { list: true, show: true, edit: false },
                    },
                    price: { type: "number" },
                    itemType: {
                        availableValues: [
                            { value: "PRODUCT", label: "Product" },
                            { value: "APP", label: "App" },
                            { value: "GAME", label: "Game" },
                            { value: "SERVICE", label: "Service" },
                        ],
                    },
                    createdAt: {
                        isVisible: { list: true, filter: true, show: true, edit: false },
                    },
                    updatedAt: {
                        isVisible: { list: true, filter: true, show: true, edit: false },
                    },
                },
                listProperties: [
                    "id",
                    "name",
                    "itemType",
                    "price",
                    "sourceId",
                    "categoryId",
                ],
            },
            features: [imageUploadFeature("items")],
        },
        {
            resource: coupon_entity_1.Coupon,
            options: {
                navigation: { name: "Deals", icon: "Badge" },
                properties: {
                    imageUrl: {
                        isVisible: { list: true, show: true, edit: false },
                    },
                    discountType: {
                        availableValues: [
                            { value: "PERCENT", label: "Percent" },
                            { value: "FIXED_AMOUNT", label: "Fixed amount" },
                            { value: "FREESHIP", label: "Freeship" },
                            { value: "GIFT", label: "Gift" },
                        ],
                    },
                    discountValue: { type: "number" },
                    startDate: { type: "datetime" },
                    endDate: { type: "datetime" },
                },
                listProperties: [
                    "id",
                    "code",
                    "discountType",
                    "discountValue",
                    "startDate",
                    "endDate",
                ],
            },
            features: [imageUploadFeature("coupons")],
        },
        {
            resource: source_entity_1.Source,
            options: {
                navigation: { name: "Settings", icon: "Cloud" },
                properties: {
                    imageUrl: {
                        isVisible: { list: true, show: true, edit: false },
                    },
                },
            },
            features: [imageUploadFeature("sources")],
        },
        {
            resource: badge_entity_1.Badge,
            options: {
                navigation: { name: "Settings", icon: "Award" },
                properties: {
                    iconUrl: {
                        isVisible: { list: true, show: true, edit: false },
                    },
                },
            },
            features: [imageUploadFeature("badges", "iconUrl")],
        },
        {
            resource: item_coupon_link_entity_1.ItemCouponLink,
            options: {
                navigation: { name: "Relations", icon: "Shuffle" },
                listProperties: ["itemId", "couponId", "isPrimaryDisplay", "linkedAt"],
            },
        },
        {
            resource: category_entity_1.Category,
            options: { navigation: { name: "Catalog", icon: "Tag" } },
        },
        {
            resource: coupon_category_entity_1.CouponCategory,
            options: { navigation: { name: "Deals", icon: "Tag" } },
        },
        {
            resource: user_entity_1.User,
            options: { navigation: { name: "Settings", icon: "User" } },
        },
    ];
    return {
        rootPath: "/admin",
        databases: [ds],
        resources,
        branding: {
            companyName: "Coupon App Admin",
            softwareBrothers: false,
        },
        locale: { language: "vi" },
    };
}
