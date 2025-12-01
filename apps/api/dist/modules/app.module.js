"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
// apps/api/src/app.module.ts
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const path_1 = require("path");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: [
                    (0, path_1.join)(process.cwd(), ".env"), // apps/api/.env
                    (0, path_1.join)(process.cwd(), "../../.env"), // nếu để ở root
                ],
            }),
            typeorm_1.TypeOrmModule.forRootAsync({
                inject: [config_1.ConfigService],
                useFactory: (cfg) => {
                    const url = String(cfg.get("DATABASE_URL") ?? "");
                    console.log("DB_URL?", url.replace(/:\/\/.*@/, "://***@")); // log ẩn pass
                    if (!url)
                        throw new Error("Missing DATABASE_URL");
                    return {
                        type: "postgres",
                        url, // chỉ dùng url, không set host/user/password riêng
                        autoLoadEntities: true,
                        synchronize: false,
                        logging: cfg.get("TYPEORM_LOGGING") === "true"
                            ? ["error", "query"]
                            : ["error"],
                        ssl: false,
                    };
                },
            }),
        ],
    })
], AppModule);
