# 開發流程協議

開始任何功能前先執行以下四個階段：

## 1. Research（研究）

- 讀取相關規則檔（見 `.prompts/README.md` 場景對照表）
- 確認是否有現成套件/共用型別可用
- 找出對應的 Controller / Service / API Module

## 2. Design（設計）

產出 YAML 格式實作清單，**必須獲得使用者核准後**才進入實作：

```yaml
# 範例（.NET）
files:
  - Domain/Entities/MyEntity.cs
  - Models/DTOs/MyEntity/InCreateMyEntityDto.cs
  - Models/DTOs/MyEntity/OutMyEntityDto.cs
  - Interfaces/IMyEntityService.cs
  - Services/MyEntityService.cs
  - Services/MyEntityService.Logging.cs
  - Infrastructure/Factories/MyEntityFactory.cs
  - Controllers/MyEntityController.cs
```

```yaml
# 範例（TypeScript）
files:
  - composables/api/modules/MyEntity.ts
  - views/Domain/MyEntity.vue
  - router/index.ts  # 新增路由
env_vars: []
```

## 3. Implement（實作）

依清單順序產出，.NET 順序：

`Entity → DTO → Interface → Factory → Service → Service.Logging → Controller`

TypeScript 順序：

`types（interface）→ api module → store（若需要）→ view → router`

## 4. Verify（驗證）

執行對應的自審清單：

- .NET：讀取 `.prompts/commands/audit-dotnet.md`
- TypeScript：讀取 `.prompts/commands/audit-typescript.md`
