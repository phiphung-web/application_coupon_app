import { Controller, Get, Query, Param, Post, Body, Patch, Delete } from '@nestjs/common';
import { SourcesService } from './sources.service';
import { CreateSourceDto, ListSourceDto, UpdateSourceDto } from './dto';

@Controller('sources')
export class SourcesController {
  constructor(private readonly svc: SourcesService) {}

  @Get() list(@Query() q: ListSourceDto) { return this.svc.list(q); }
  @Get(':id') get(@Param('id') id: string) { return this.svc.get(id); }
  @Post() create(@Body() dto: CreateSourceDto) { return this.svc.create(dto); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateSourceDto) { return this.svc.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.svc.remove(id); }
}
