import { Repository } from "typeorm";
import { Notification } from "../../entities/notification.entity";
import { CreateNotificationDto, ListNotificationsDto } from "./dto";
export declare class NotificationsService {
    private readonly repo;
    constructor(repo: Repository<Notification>);
    paginate(q: ListNotificationsDto): Promise<{
        items: Notification[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    create(dto: CreateNotificationDto): Promise<Notification>;
    get(id: number): Promise<Notification>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
