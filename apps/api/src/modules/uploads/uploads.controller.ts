import {
  BadRequestException,
  Controller,
  Post,
  Query,
  UploadedFile,
  UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { diskStorage } from "multer";
import { join } from "path";
import { existsSync, mkdirSync } from "fs";
import { Express } from "express";

const UPLOAD_ROOT = join(process.cwd(), "apps", "api", "uploads");

function ensureDir(path: string) {
  if (!existsSync(path)) {
    mkdirSync(path, { recursive: true });
  }
}

function sanitizeFolder(input?: string) {
  if (!input) return "general";
  return input.replace(/[^a-zA-Z0-9/_-]/g, "").replace(/^\/*/, "");
}

@Controller("uploads")
export class UploadsController {
  @Post()
  @UseInterceptors(
    FileInterceptor("file", {
      storage: diskStorage({
        destination: (req, file, cb) => {
          const folder = sanitizeFolder((req.query.folder as string) ?? "general");
          const dest = join(UPLOAD_ROOT, folder);
          ensureDir(dest);
          cb(null, dest);
        },
        filename: (_req, file, cb) => {
          const normalized = file.originalname.replace(/\s+/g, "-");
          cb(null, `${Date.now()}-${normalized}`);
        },
      }),
    })
  )
  uploadFile(
    @UploadedFile() file: Express.Multer.File,
    @Query("folder") folder?: string
  ) {
    if (!file) {
      throw new BadRequestException("File is required");
    }
    const safeFolder = sanitizeFolder(folder);
    const relativePath = `${safeFolder}/${file.filename}`.replace(/^\/*/, "");
    const appUrl =
      process.env.APP_URL?.replace(/\/$/, "") ||
      `http://localhost:${process.env.PORT || 3000}`;
    const url = `${appUrl}/uploads/${relativePath}`;

    return {
      url,
      path: relativePath,
      size: file.size,
      mimeType: file.mimetype,
    };
  }
}
