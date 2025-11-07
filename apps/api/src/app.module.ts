import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => {
        const url = cfg.get<string>("DATABASE_URL");
        if (!url) throw new Error("Missing DATABASE_URL");
        return {
          type: "postgres",
          url, // <-- chỉ dùng url
          autoLoadEntities: true, // nếu bạn đang dùng decorators entity
          synchronize: false,
          logging:
            cfg.get("TYPEORM_LOGGING") === "true"
              ? ["error", "query"]
              : ["error"],
          ssl: false,
        } as any;
      },
    }),
    // ... các module còn lại
  ],
})
export class AppModule {}
