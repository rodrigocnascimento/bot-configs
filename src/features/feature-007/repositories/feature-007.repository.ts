import { Feature007DTO } from '../dtos/feature-007.dto';
import { Feature007Entity } from '../entities/feature-007.entity';

export interface Feature007Repository {
  create(dto: Feature007DTO): Promise<Feature007Entity>;
  findById(id: string): Promise<Feature007Entity | null>;
  findAll(): Promise<Feature007Entity[]>;
  update(id: string, dto: Feature007DTO): Promise<Feature007Entity>;
  delete(id: string): Promise<void>;
}