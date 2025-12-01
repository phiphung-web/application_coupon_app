import { PaginationDto } from "../../common/dtos/pagination.dto";
import { NotificationCategory } from "../../entities/notification.entity";
export declare class ListNotificationsDto extends PaginationDto {
    category?: NotificationCategory;
    from?: string;
    to?: string;
    sourceId?: number;
    itemId?: number;
    couponId?: number;
}
export declare class CreateNotificationDto {
    category: NotificationCategory;
    title: string;
    message: string;
    payload?: Record<string, any>;
    sourceId?: number;
    itemId?: number;
    couponId?: number;
    expiresAt?: string;
    tags?: string[];
    importance?: number;
}
