import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Query } from "@nestjs/common";
import { NotificationsService } from "./notifications.service";
import { CreateNotificationDto, ListNotificationsDto } from "./dto";

@Controller("notifications")
export class NotificationsController {
  constructor(private readonly svc: NotificationsService) {}

  @Get()
  list(@Query() q: ListNotificationsDto) {
    return this.svc.paginate(q);
  }

  @Post()
  create(@Body() dto: CreateNotificationDto) {
    return this.svc.create(dto);
  }

  @Delete(":id")
  remove(@Param("id", ParseIntPipe) id: number) {
    return this.svc.remove(id);
  }
}

