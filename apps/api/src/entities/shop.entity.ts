import { Column, Entity, Index, PrimaryColumn } from 'typeorm';

@Entity('shops')
export class Shop {
  // FE đang dùng id: string
  @PrimaryColumn({ length: 50 })
  id: string;

  @Index()
  @Column({ length: 120 })
  name: string;

  @Column({ nullable: true })
  logoUrl?: string;

  @Column({ nullable: true })
  domain?: string;

  @Column('int', { default: 0 })
  priority: number;

  @Column({ default: true })
  isActive: boolean;
}
