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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UploadsController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const multer_1 = require("multer");
const path_1 = require("path");
const fs_1 = require("fs");
const UPLOAD_ROOT = (0, path_1.join)(process.cwd(), "apps", "api", "uploads");
function ensureDir(path) {
    if (!(0, fs_1.existsSync)(path)) {
        (0, fs_1.mkdirSync)(path, { recursive: true });
    }
}
function sanitizeFolder(input) {
    if (!input)
        return "general";
    return input.replace(/[^a-zA-Z0-9/_-]/g, "").replace(/^\/*/, "");
}
let UploadsController = class UploadsController {
    uploadFile(file, folder) {
        if (!file) {
            throw new common_1.BadRequestException("File is required");
        }
        const safeFolder = sanitizeFolder(folder);
        const relativePath = `${safeFolder}/${file.filename}`.replace(/^\/*/, "");
        const appUrl = process.env.APP_URL?.replace(/\/$/, "") ||
            `http://localhost:${process.env.PORT || 3000}`;
        const url = `${appUrl}/uploads/${relativePath}`;
        return {
            url,
            path: relativePath,
            size: file.size,
            mimeType: file.mimetype,
        };
    }
};
exports.UploadsController = UploadsController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)("file", {
        storage: (0, multer_1.diskStorage)({
            destination: (req, file, cb) => {
                const folder = sanitizeFolder((req.query?.folder ?? req.query?.["folder"]) ?? "general");
                const dest = (0, path_1.join)(UPLOAD_ROOT, folder);
                ensureDir(dest);
                cb(null, dest);
            },
            filename: (_req, file, cb) => {
                const normalized = file.originalname.replace(/\s+/g, "-");
                cb(null, `${Date.now()}-${normalized}`);
            },
        }),
    })),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Query)("folder")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], UploadsController.prototype, "uploadFile", null);
exports.UploadsController = UploadsController = __decorate([
    (0, common_1.Controller)("uploads")
], UploadsController);
