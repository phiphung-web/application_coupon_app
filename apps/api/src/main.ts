// src/main.ts
import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import { existsSync, mkdirSync } from "fs";
import { join } from "path";
import { NestExpressApplication } from "@nestjs/platform-express";
async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.enableCors();
  const uploadsDir = join(__dirname, "..", "uploads");
  if (!existsSync(uploadsDir)) {
    mkdirSync(uploadsDir, { recursive: true });
  }
  app.useStaticAssets(uploadsDir, {
    prefix: "/uploads",
  });
  await app.listen(process.env.PORT || 3000);
}
bootstrap();
