import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
} from "@nestjs/common";
import { SourcesService } from "./sources.service";
import { CreateSourceDto, SourceHighlightQueryDto, UpdateSourceDto } from "./dto";

@Controller("sources")
export class SourcesController {
  constructor(private readonly svc: SourcesService) {}

  @Get()
  list() {
    return this.svc.list();
  }

  @Get("highlights")
  highlights(@Query() q: SourceHighlightQueryDto) {
    return this.svc.highlights(q);
  }

  @Get(":id")
  get(@Param("id", ParseIntPipe) id: number) {
    return this.svc.get(id);
  }

  @Post()
  create(@Body() dto: CreateSourceDto) {
    return this.svc.create(dto);
  }

  @Patch(":id")
  update(@Param("id", ParseIntPipe) id: number, @Body() dto: UpdateSourceDto) {
    return this.svc.update(id, dto);
  }

  @Delete(":id")
  remove(@Param("id", ParseIntPipe) id: number) {
    return this.svc.remove(id);
  }
}
