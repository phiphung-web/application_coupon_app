import { MigrationInterface, QueryRunner } from "typeorm";
export declare class CoreRefactor1720867200000 implements MigrationInterface {
    name: string;
    up(queryRunner: QueryRunner): Promise<void>;
    down(queryRunner: QueryRunner): Promise<void>;
}
