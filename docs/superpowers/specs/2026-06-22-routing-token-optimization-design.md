# 設計：路由層 Token 優化（薄派工表 + 細節下放）

| 欄位 | 內容 |
|------|------|
| 日期 | 2026-06-22 |
| 範圍 | `AI Engineering Rule Pack`（本規則庫 repo） |
| 方案 | A（薄派工表 + 細節下放，tool-agnostic） |
| 關聯 | 與 `2026-06-22-harness-engineering-loop-design.md` 互補，實作時一起做 |

## 1. 背景與動機

規則庫已採按需載入，但**路由層本身**仍有可省空間：

- `SKILL.md` 為全庫最大單一檔（約 5,412 字元 / 82 行），每 session 必讀。
- 其中「XX 任務必讀」的長段警語（enum metadata 反射、audit-log SKIPPED、服務間 API key / response、單元測試邊界）**重複了它所指向的目標檔**。例如 enum 警語與 `language/dotnet/custom/enum.md`（約 5,060 字元）內容重疊。
- 結果：每 session 先讀一次 SKILL 內的警語，涉及該主題時再讀目標檔一次——同一份規則讀兩遍。

真正的浪費是**路由層的重複與散文**，不是按需載入本身。

## 2. 目標與非目標

**目標**
- 把 `SKILL.md` 從散文式「必讀」重構為**緊湊派工表**（任務訊號 → 必載檔案），約 20–30 行。
- 消除路由層與目標檔的重複，讓目標檔成為單一真理來源。
- AI 開場只讀派工表分類任務、命中對應檔，不再讀表外散文。

**非目標**
- 不改動規則層各檔的實質規範內容（只搬移位置、去重）。
- 不引入 hook / 腳本預過濾（方案 C，依賴 harness 支援，違反 tool-agnostic）。
- 不取代 `AGENT.md` 的角色路由；SKILL 派工表與 AGENT 角色流程分工：AGENT 管「角色 + 各角色 baseline」，SKILL 管「任務訊號 → 額外加載檔」。

## 3. 設計

### 3.1 SKILL.md 新結構（約 20–30 行）

```
# AI 工程協作 Skill（派工入口）

讀本表判斷任務訊號 → 只載對應檔 → 不讀表外散文。角色流程見 AGENT.md。

## 每個任務必載 baseline
角色檔（依 AGENT.md）+ core/agent-mandates.md + core/principles.md
+ core/verification.md + core/escalation.md

## 任務訊號 → 加載檔案
| 命中關鍵字 | 額外必載 |
| .NET 測試（新增/改/修復 test） | language/dotnet/custom/testing.md |
| 排程同步 / ERP / 主檔同步 / audit log | package/common-utils/audit-log.md |
| 服務間 API key / shared secret / DachanApiResponse / response envelope | package/common-utils/api-key.md + api-response.md + core/api-contract.md（外部再加 external-contract.md） |
| Enum option / I18nKeyEnum / enum metadata | language/dotnet/custom/enum.md + core/api-contract.md |
| 判斷不出來 | 只載角色 baseline，從 AGENT.md custom 清單挑或詢問 |

## 失敗回饋
漏載 / 反覆失敗 → doc/lessons/；晉升見 command/promote-lesson.md
```

### 3.2 細節下放原則

實作時逐一處理 SKILL 現有的每段「必讀」警語：

1. 核對該警語是否已存在於目標檔。
2. **已存在** → 直接從 SKILL 刪除（純去重）。
3. **不存在** → 先下放到目標檔，再從 SKILL 刪除。
4. 目標檔為單一真理來源；AI 涉及該主題時本來就會載入該檔。

涉及的目標檔對照：

| SKILL 現有警語 | 目標檔 |
|----------------|--------|
| 單元測試依賴邊界 | `language/dotnet/custom/testing.md` |
| audit-log SKIPPED / 無業務變更不寫 audit | `package/common-utils/audit-log.md` |
| 服務名稱不在 CommonUtils 定義、ItemCode/ProductNo 不擅自改名 | `package/common-utils/api-key.md` / `api-response.md`、`core/api-contract.md`、`core/external-contract.md` |
| enum metadata 反射機制（I18nKeyEnum、EnumMetadataField、named argument…） | `language/dotnet/custom/enum.md` |

> 下放後若目標檔超過 100 行的建議上限，依 README 維護者準則評估是否再拆子規則，但本次以「去重不擴張」為原則，不主動拆檔。

### 3.3 高 recall 防漏

- 每個現有「必讀」主題在派工表都保留一列，不減覆蓋。
- 新增「判斷不出來」fallback 列：只載角色 baseline，從 `AGENT.md` custom 清單挑或詢問，不靜默略過。
- 派工表寧可多列一份（高 recall），避免重演「該載沒載」。

### 3.4 與 harness engineering loop 的閉環

- `core/verification.md`、`core/escalation.md` 列入 baseline。
- 「漏載」即一筆失敗訊號 → 寫 `doc/lessons/` → 經 `command/promote-lesson.md` 晉升時，落點具體為**派工表新增一列**。
- 主動防漏（派工表）＋ 被動補漏（lessons loop）兩端閉環。

## 4. 逐檔變更

- `SKILL.md`：重構為派工表（3.1），刪除散文式「必讀」段落。
- `language/dotnet/custom/testing.md` / `package/common-utils/audit-log.md` / `package/common-utils/api-key.md` / `api-response.md` / `language/dotnet/custom/enum.md`：依 3.2 核對，缺漏的警語才下放補入。
- `AGENT.md`：確認各角色 baseline 與 SKILL 派工表不重複定義；必要時加一句指向 SKILL 派工表。
- `README.md`：維護者準則補一句「新增任務型規則時，於 SKILL 派工表加一列，警語寫在目標檔」。

## 5. 相容性與風險

- 純路由重構，不改規則實質，向後相容。
- 主要風險為「派工表覆蓋不足導致漏載」，以 3.3 高 recall + fallback + lessons 回饋緩解。
- 預期省下路由層重複與散文約 3–4k 字元／session；規則層本體仍按需載入，不在本次節省範圍（屬另一條「custom 模組精簡」議題）。
