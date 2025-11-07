import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Delete,
} from "@nestjs/common";
import { BadgesService } from "./badges.service";

@Controller("badges")
export class BadgesController {
  constructor(private readonly svc: BadgesService) {}
  @Get() list() {
    return this.svc.list();
  }
  @Get(":id") get(@Param("id", ParseIntPipe) id: number) {
    return this.svc.get(id);
  }
  @Post() create(@Body() body: any) {
    return this.svc.create(body);
  }
  @Patch(":id") update(
    @Param("id", ParseIntPipe) id: number,
    @Body() body: any
  ) {
    return this.svc.update(id, body);
  }
  @Delete(":id") remove(@Param("id", ParseIntPipe) id: number) {
    return this.svc.remove(id);
  }
}
