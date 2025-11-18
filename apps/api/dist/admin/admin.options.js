"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildAdminOptions = buildAdminOptions;
const item_entity_1 = require("../entities/item.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const category_entity_1 = require("../entities/category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const badge_entity_1 = require("../entities/badge.entity");
const source_entity_1 = require("../entities/source.entity");
const item_coupon_link_entity_1 = require("../entities/item_coupon_link.entity");
const user_entity_1 = require("../entities/user.entity");
function buildAdminOptions(ds) {
    const resources = [
        {
            resource: item_entity_1.Item,
            options: {
                navigation: { name: "Catalog", icon: "Box" },
                properties: {
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
        },
        {
            resource: coupon_entity_1.Coupon,
            options: {
                navigation: { name: "Deals", icon: "Badge" },
                properties: {
                    discountType: {
                        availableValues: [
                            { value: "PERCENT", label: "Percent" },
                            { value: "FIXED_AMOUNT", label: "Fixed amount" },
                            { value: "FREESHIP", label: "Freeshop" },
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
            resource: badge_entity_1.Badge,
            options: { navigation: { name: "Settings", icon: "Award" } },
        },
        {
            resource: source_entity_1.Source,
            options: { navigation: { name: "Settings", icon: "Cloud" } },
        },
        {
            resource: user_entity_1.User,
            options: { navigation: { name: "Settings", icon: "User" } },
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
        locale: { language: "vi" },
    };
}
