import {
  Body,
  Controller,
  DefaultValuePipe,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
} from "@nestjs/common";
import { CouponCategoriesService } from "./coupon-categories.service";

@Controller("coupon-categories")
export class CouponCategoriesController {
  constructor(private readonly svc: CouponCategoriesService) {}
  @Get()
  list() {
    return this.svc.list();
  }

  @Get("highlights")
  highlights(@Query("limit", new DefaultValuePipe(6), ParseIntPipe) limit: number) {
    return this.svc.highlights(limit);
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
