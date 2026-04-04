export class Feature007Entity {
  constructor(
    public id: string,
    public name: string,
    public description: string,
    public createdAt: Date = new Date(),
    public updatedAt: Date = new Date()
  ) {}
}