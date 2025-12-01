import { NotificationsService } from "./notifications.service";
import { CreateNotificationDto, ListNotificationsDto } from "./dto";
export declare class NotificationsController {
    private readonly svc;
    constructor(svc: NotificationsService);
    list(q: ListNotificationsDto): Promise<{
        items: import("../../entities/notification.entity").Notification[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    create(dto: CreateNotificationDto): Promise<import("../../entities/notification.entity").Notification>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
