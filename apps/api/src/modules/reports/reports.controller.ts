import { Body, Controller, Post } from '@nestjs/common';

@Controller()
export class ReportsController {
  @Post('clicks') clicks(@Body() body: any) { return { ok: true }; }
  @Post('reports') reports(@Body() body: any) { return { ok: true }; }
}
