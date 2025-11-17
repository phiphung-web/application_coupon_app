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
import { CategoriesService } from "./categories.service";
import { CategoryQueryDto, CreateCategoryDto, UpdateCategoryDto } from "./dto";

@Controller("categories")
export class CategoriesController {
  constructor(private readonly svc: CategoriesService) {}

  @Get()
  list(@Query() q: CategoryQueryDto) {
    return this.svc.paginate(q);
  }

  @Get("all")
  listAll() {
    return this.svc.listAll();
  }

  @Get("tree")
  tree() {
    return this.svc.tree();
  }

  @Get(":id")
  get(@Param("id", ParseIntPipe) id: number) {
    return this.svc.get(id);
  }

  @Get(":id/breadcrumbs")
  breadcrumbs(@Param("id", ParseIntPipe) id: number) {
    return this.svc.breadcrumbs(id);
  }

  @Post()
  create(@Body() dto: CreateCategoryDto) {
    return this.svc.create(dto);
  }

  @Patch(":id")
  update(
    @Param("id", ParseIntPipe) id: number,
    @Body() dto: UpdateCategoryDto
  ) {
    return this.svc.update(id, dto);
  }

  @Delete(":id")
  remove(@Param("id", ParseIntPipe) id: number) {
    return this.svc.remove(id);
  }
}
