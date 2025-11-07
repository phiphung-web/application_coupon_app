import 'reflect-metadata';
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./modules/app.module";
import { AppValidationPipe } from "./common/pipes/validation.pipe";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(AppValidationPipe);
  app.enableCors();
  await app.listen(process.env.PORT || 3000);
}
bootstrap();
