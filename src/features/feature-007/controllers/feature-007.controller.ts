import { Feature007DTO } from '../dtos/feature-007.dto';
import { Feature007UseCase } from '../usecases/feature-007.usecase';

export class Feature007Controller {
  constructor(private useCase: Feature007UseCase) {}

  async create(dto: Feature007DTO): Promise<any> {
    try {
      const result = await this.useCase.create(dto);
      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async findById(id: string): Promise<any> {
    try {
      const result = await this.useCase.findById(id);
      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async findAll(): Promise<any> {
    try {
      const result = await this.useCase.findAll();
      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async update(id: string, dto: Feature007DTO): Promise<any> {
    try {
      const result = await this.useCase.update(id, dto);
      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async delete(id: string): Promise<any> {
    try {
      await this.useCase.delete(id);
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}