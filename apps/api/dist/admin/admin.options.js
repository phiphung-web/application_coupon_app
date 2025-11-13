"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildAdminOptions = buildAdminOptions;
const product_entity_1 = require("../entities/product.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const category_entity_1 = require("../entities/category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const badge_entity_1 = require("../entities/badge.entity");
const source_entity_1 = require("../entities/source.entity");
const product_coupon_entity_1 = require("../entities/product_coupon.entity");
function buildAdminOptions(ds) {
    const resources = [
        {
            resource: product_entity_1.Product,
            options: {
                navigation: { name: "Catalog", icon: "Box" },
                properties: {
                    priceOriginal: { type: "number" },
                    priceCurrent: { type: "number" },
                    currency: { availableValues: [{ value: "USD", label: "USD" }] },
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
                    "priceCurrent",
                    "priceOriginal",
                    "sourceId",
                ],
                filterProperties: ["name", "sourceId", "categories", "badges"],
            },
        },
        {
            resource: coupon_entity_1.Coupon,
            options: {
                navigation: { name: "Deals", icon: "Badge" },
                properties: {
                    discountType: {
                        availableValues: [
                            { value: "PERCENT", label: "PERCENT" },
                            { value: "FIXED", label: "FIXED" },
                        ],
                    },
                    discountValue: { type: "number" },
                    minSpend: { type: "number" },
                    maxDiscount: { type: "number" },
                    endAt: { type: "datetime" },
                    imageUrl: { type: "string" },
                    isActive: { type: "boolean" },
                    createdAt: {
                        isVisible: { list: true, filter: true, show: true, edit: false },
                    },
                    updatedAt: {
                        isVisible: { list: true, filter: true, show: true, edit: false },
                    },
                },
                listProperties: [
                    "id",
                    "title",
                    "code",
                    "discountType",
                    "discountValue",
                    "endAt",
                    "isActive",
                ],
                filterProperties: [
                    "title",
                    "code",
                    "sourceId",
                    "categories",
                    "badges",
                    "isActive",
                ],
            },
        },
        {
            resource: product_coupon_entity_1.ProductCoupon,
            options: {
                navigation: { name: "Relations", icon: "Shuffle" },
                properties: {
                    productId: { type: "number" },
                    couponId: { type: "string" },
                    isPrimary: { type: "boolean" },
                    createdAt: {
                        isVisible: { list: true, filter: true, show: true, edit: false },
                    },
                },
                listProperties: ["productId", "couponId", "isPrimary", "createdAt"],
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
            resource: badge_entity_1.Badge,
            options: { navigation: { name: "Settings", icon: "Award" } },
        },
        {
            resource: source_entity_1.Source,
            options: { navigation: { name: "Settings", icon: "Cloud" } },
        },
    ];
    return {
        rootPath: "/admin",
        resources,
        databases: [ds],
        branding: {
            companyName: "Coupon App Admin",
            softwareBrothers: false,
        },
        locale: {
            language: "vi",
        },
    };
}
