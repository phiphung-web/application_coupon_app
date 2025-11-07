import { Column, Entity, Index, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export type SourceType = 'ECOM' | 'APP' | 'GAME' | 'SERVICE' | 'OTHER';

@Entity('sources')
export class Source {
  @PrimaryColumn({ length: 50 })
  id!: string; // 'shopee', 'lazada', 'genshin',...

  @Index()
  @Column({ length: 120 })
  name!: string;

  @Column({ type: 'varchar', length: 10, default: 'ECOM' })
  type!: SourceType;

  @Column({ nullable: true }) logoUrl?: string;
  @Column({ nullable: true }) domain?: string;
  @Column({ nullable: true }) packageId?: string; // app android
  @Column({ nullable: true }) bundleId?: string;  // app ios
  @Column({ nullable: true }) publisher?: string; // game/service

  @Column('int', { default: 0 })
  priority: number = 0;

  @Column({ default: true })
  isActive: boolean = true;

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
}
