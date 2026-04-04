import { Feature007UseCase } from '../../src/features/feature-007/usecases/feature-007.usecase';
import { Feature007Repository } from '../../src/features/feature-007/repositories/feature-007.repository';
import { Feature007DTO } from '../../src/features/feature-007/dtos/feature-007.dto';
import { Feature007Entity } from '../../src/features/feature-007/entities/feature-007.entity';

// Mock repository
const mockRepository = {
  create: jest.fn(),
  findById: jest.fn(),
  findAll: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
};

describe('Feature007UseCase', () => {
  let useCase: Feature007UseCase;

  beforeEach(() => {
    useCase = new Feature007UseCase(mockRepository as Feature007Repository);
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should create a feature', async () => {
      const dto: Feature007DTO = {
        name: 'Test Feature',
        description: 'Test Description',
      };

      const expectedEntity = new Feature007Entity('1', dto.name, dto.description);
      mockRepository.create.mockResolvedValue(expectedEntity);

      const result = await useCase.create(dto);

      expect(mockRepository.create).toHaveBeenCalledWith(dto);
      expect(result).toEqual(expectedEntity);
    });
  });

  describe('findById', () => {
    it('should find a feature by ID', async () => {
      const featureId = '1';
      const expectedEntity = new Feature007Entity(featureId, 'Test', 'Test');
      mockRepository.findById.mockResolvedValue(expectedEntity);

      const result = await useCase.findById(featureId);

      expect(mockRepository.findById).toHaveBeenCalledWith(featureId);
      expect(result).toEqual(expectedEntity);
    });

    it('should return null if feature not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      const result = await useCase.findById('nonexistent');

      expect(mockRepository.findById).toHaveBeenCalledWith('nonexistent');
      expect(result).toBeNull();
    });
  });

  describe('findAll', () => {
    it('should return all features', async () => {
      const expectedEntities = [
        new Feature007Entity('1', 'Feature 1', 'Desc 1'),
        new Feature007Entity('2', 'Feature 2', 'Desc 2'),
      ];
      mockRepository.findAll.mockResolvedValue(expectedEntities);

      const result = await useCase.findAll();

      expect(mockRepository.findAll).toHaveBeenCalled();
      expect(result).toEqual(expectedEntities);
    });
  });

  describe('update', () => {
    it('should update a feature', async () => {
      const featureId = '1';
      const dto: Feature007DTO = {
        name: 'Updated Feature',
        description: 'Updated Description',
      };

      const expectedEntity = new Feature007Entity(featureId, dto.name, dto.description);
      mockRepository.update.mockResolvedValue(expectedEntity);

      const result = await useCase.update(featureId, dto);

      expect(mockRepository.update).toHaveBeenCalledWith(featureId, dto);
      expect(result).toEqual(expectedEntity);
    });
  });

  describe('delete', () => {
    it('should delete a feature', async () => {
      const featureId = '1';
      mockRepository.delete.mockResolvedValue(undefined);

      await useCase.delete(featureId);

      expect(mockRepository.delete).toHaveBeenCalledWith(featureId);
    });
  });
});