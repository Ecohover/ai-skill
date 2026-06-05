# .NET Backend — 測試規範

## 測試策略

| 約束 | 說明 |
|------|------|
| MUST | 依 `core/agent-mandates.md` 採用風險導向 TDD，不要求所有變更都先測試 |
| MUST | Bug fix 先新增或確認失敗測試，再修正，再確認測試通過 |
| MUST | 核心商業邏輯、API contract、DTO / Entity / Factory mapping、權限、同步、排程、環境設定優先補測試 |
| MUST | 測試案例使用 Arrange / Act / Assert 三段式，段落之間以空白行分隔 |
| MUST | 測試名稱描述行為與預期結果，不只描述方法名稱 |
| PREFER | 測試 method identifier 使用英文 ASCII，並用中文 `DisplayName` / attribute / 註解補充人類可讀情境 |
| MUST NOT | 測試只驗證 private implementation detail；應驗證外部可觀察行為 |

## 命名建議

若測試框架支援顯示名稱，優先用中文描述業務情境：

```csharp
[Fact(DisplayName = "庫存不足時應拋出庫存不足錯誤")]
public async Task UpdateAsync_WhenInventoryIsInsufficient_ShouldThrowInventoryError()
{
    // Arrange
    var service = CreateServiceWithInventory(available: 1);

    // Act
    var act = () => service.UpdateAsync(CreateRequest(required: 2));

    // Assert
    await act.Should().ThrowAsync<InvalidOperationException>();
}
```

若框架不支援顯示名稱，可在測試 method 上方用繁體中文註解補充情境。
