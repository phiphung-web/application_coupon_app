import { Controller, Get } from '@nestjs/common';
import { ShopsService } from './shops.service';

@Controller('shops')
export class ShopsController {
  constructor(private readonly service: ShopsService) {}
  @Get() list() { return this.service.list(); }
}
