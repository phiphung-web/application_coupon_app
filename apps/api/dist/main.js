"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// src/main.ts
require("reflect-metadata");
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const fs_1 = require("fs");
const path_1 = require("path");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.enableCors();
    const uploadsDir = (0, path_1.join)(__dirname, "..", "uploads");
    if (!(0, fs_1.existsSync)(uploadsDir)) {
        (0, fs_1.mkdirSync)(uploadsDir, { recursive: true });
    }
    app.useStaticAssets(uploadsDir, {
        prefix: "/uploads",
    });
    await app.listen(process.env.PORT || 3000);
}
bootstrap();
