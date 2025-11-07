// apps/api/src/app.module.ts
import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { join } from "path";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [
        join(process.cwd(), ".env"), // apps/api/.env
        join(process.cwd(), "../../.env"), // nếu để ở root
      ],
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => {
        const url = String(cfg.get("DATABASE_URL") ?? "");
        console.log("DB_URL?", url.replace(/:\/\/.*@/, "://***@")); // log ẩn pass
        if (!url) throw new Error("Missing DATABASE_URL");
        return {
          type: "postgres",
          url, // chỉ dùng url, không set host/user/password riêng
          autoLoadEntities: true,
          synchronize: false,
          logging:
            cfg.get("TYPEORM_LOGGING") === "true"
              ? ["error", "query"]
              : ["error"],
          ssl: false,
        };
      },
    }),
  ],
})
export class AppModule {}
