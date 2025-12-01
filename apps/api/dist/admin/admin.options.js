"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildAdminOptions = buildAdminOptions;
const adminjs_1 = require("adminjs");
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
const notification_entity_1 = require("../entities/notification.entity");
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
                opts: {},
            },
        },
        properties: {
            key: property,
            file: `${property}File`,
        },
        uploadPath: (_record, filename) => `${folder}/${Date.now()}-${filename.replace(/\s+/g, "-")}`,
    });
}
function buildAdminOptions(ds) {
    const couponRepo = ds.getRepository(coupon_entity_1.Coupon);
    const linkRepo = ds.getRepository(item_coupon_link_entity_1.ItemCouponLink);
    const componentLoader = new adminjs_1.ComponentLoader();
    const Components = {
        CouponLinkPreview: componentLoader.add("CouponLinkPreview", "./components/coupon-link-preview"),
        ItemLinkPreview: componentLoader.add("ItemLinkPreview", "./components/item-link-preview"),
    };
    const handleItemExtras = (actionName) => ({
        before: async (request, context) => {
            if (request.payload) {
                const extras = {
                    linkCouponId: request.payload.linkCouponId,
                    newCouponCode: request.payload.newCouponCode,
                    newCouponDescription: request.payload.newCouponDescription,
                    newCouponDiscountType: request.payload.newCouponDiscountType,
                    newCouponDiscountValue: request.payload.newCouponDiscountValue,
                };
                context.itemActionExtras = extras;
                Object.keys(extras).forEach((key) => {
                    if (request.payload && key in request.payload) {
                        delete request.payload[key];
                    }
                });
            }
            return request;
        },
        after: async (response, request, context) => {
            const extras = context.itemActionExtras || {};
            const recordId = context.record?.params?.id || response.record?.id || response.record?.params?.id;
            if (!recordId)
                return response;
            const itemId = Number(recordId);
            if (extras.linkCouponId) {
                const couponId = Number(extras.linkCouponId);
                if (!Number.isNaN(couponId)) {
                    await linkRepo.delete({ itemId });
                    await linkRepo.save(linkRepo.create({
                        itemId,
                        couponId,
                        isPrimaryDisplay: true,
                    }));
                }
            }
            if (extras.newCouponCode) {
                const discountValue = Number(extras.newCouponDiscountValue);
                const coupon = couponRepo.create({
                    code: extras.newCouponCode,
                    description: extras.newCouponDescription,
                    discountType: extras.newCouponDiscountType || undefined,
                    discountValue: Number.isNaN(discountValue)
                        ? undefined
                        : String(discountValue),
                });
                const saved = await couponRepo.save(coupon);
                await linkRepo.save(linkRepo.create({
                    itemId,
                    couponId: saved.id,
                    isPrimaryDisplay: true,
                }));
            }
            return response;
        },
    });
    const handleCouponExtras = () => ({
        before: async (request, context) => {
            if (request.payload) {
                const extras = {
                    linkItemId: request.payload.linkItemId,
                };
                context.couponActionExtras = extras;
                if (request.payload) {
                    delete request.payload.linkItemId;
                }
            }
            return request;
        },
        after: async (response, request, context) => {
            const extras = context.couponActionExtras || {};
            const recordId = context.record?.params?.id || response.record?.id || response.record?.params?.id;
            if (!recordId)
                return response;
            const couponId = Number(recordId);
            if (extras.linkItemId) {
                const itemId = Number(extras.linkItemId);
                if (!Number.isNaN(itemId)) {
                    await linkRepo.delete({ itemId });
                    await linkRepo.save(linkRepo.create({
                        itemId,
                        couponId,
                        isPrimaryDisplay: true,
                    }));
                }
            }
            return response;
        },
    });
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
                    linkCouponId: {
                        type: "reference",
                        reference: "Coupon",
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        position: 120,
                    },
                    linkCouponPreview: {
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        components: {
                            edit: Components.CouponLinkPreview,
                        },
                        isDisabled: true,
                        position: 121,
                    },
                    newCouponCode: {
                        type: "string",
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        position: 130,
                    },
                    newCouponDescription: {
                        type: "textarea",
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        position: 131,
                    },
                    newCouponDiscountType: {
                        type: "string",
                        availableValues: [
                            { value: "PERCENT", label: "Percent" },
                            { value: "FIXED_AMOUNT", label: "Fixed amount" },
                            { value: "FREESHIP", label: "Freeship" },
                            { value: "GIFT", label: "Gift" },
                        ],
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        position: 132,
                    },
                    newCouponDiscountValue: {
                        type: "number",
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        position: 133,
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
                actions: {
                    new: handleItemExtras("new"),
                    edit: handleItemExtras("edit"),
                },
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
                    linkItemId: {
                        type: "reference",
                        reference: "Item",
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        position: 110,
                    },
                    linkItemPreview: {
                        isVisible: { list: false, filter: false, show: false, edit: true },
                        components: {
                            edit: Components.ItemLinkPreview,
                        },
                        isDisabled: true,
                        position: 111,
                    },
                },
                listProperties: [
                    "id",
                    "code",
                    "discountType",
                    "discountValue",
                    "startDate",
                    "endDate",
                ],
                actions: {
                    new: handleCouponExtras(),
                    edit: handleCouponExtras(),
                },
            },
            features: [imageUploadFeature("coupons")],
        },
        {
            resource: notification_entity_1.Notification,
            options: {
                navigation: { name: "Engagement", icon: "Notification" },
                listProperties: ["id", "title", "category", "importance", "createdAt"],
                properties: {
                    message: { type: "textarea" },
                    payload: { type: "mixed" },
                    tags: { type: "mixed" },
                },
            },
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
        componentLoader,
        branding: {
            companyName: "Coupon App Admin",
            softwareBrothers: false,
        },
        locale: {
            language: "vi",
            translations: {},
        },
    };
}
