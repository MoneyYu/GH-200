# GH-200 備課指南

> 📖 **Related** — [Demo environment](demo-environment.md)

> **講師專用。** 本文是 2026-09-03 客戶場的教學與控場指南；學員面向連結頁是 [`../README.md`](../README.md)，不要投影本文的環境、權限或風險內容。

---

## 課程定位與基本資料

本場以客戶的認證技能領域架構重組 **GH-200T00-A — Automate your workflow with GitHub Actions**。學員多數第一次接觸 GitHub Actions；結訓目標是能自己寫 YAML，完成 **Build → Test → Package → Deploy** 至測試／正式環境，並能讀 workflow log 處理錯誤。

| 項目 | 內容 |
|---|---|
| 課程頁面 | <https://learn.microsoft.com/en-us/training/courses/gh-200t00> |
| 時數 | 1 天 |
| 客製模組 | M1、M2、**M3（本次不授課）**、M4、M5 |
| 講師 demo org | <https://github.com/MoneyDemo> |
| Class demo repo | <https://github.com/MoneyDemo/20260903-GH200> |
| Course metadata | Date: `20260903`；Course ID: `109066`；Skillable Training key: `53F35FFC16441C69` |

先備知識是 Git 基本操作與 YAML 縮排。沒有 Azure 經驗不阻礙學員理解流程，但 Azure VM 的 live deploy 是講師 demo，不承諾每位學員各自部署。

### 本次交付的客製調整

| 類型 | 調整 |
|---|---|
| 移除 | **Reusable Workflows**、**Matrix Strategy**、整個 **Module 3 — Author and Maintain Actions** |
| 縮限 | Cache **只講加速相依性的概念**，不做設定或深入除錯 |
| 聚焦 | OIDC 的 Connect 對象以 **Azure** 為主 |
| 聚焦 | Workflow Templates 只以 **Frontend：Angular、React；Backend：node、python、java、c#** 為例 |

**講師不得漂回被移除主題。** 客戶以此架構安排學習時間與後續討論；把 Reusable Workflows、Matrix Strategy 或 custom action authoring 當作正課，會擠壓 YAML、部署與 log troubleshooting 的實作時間，也會讓客戶文件的 M3/M4/M5 編號失去對照。學員提問時可明確標為「本場未授課的延伸閱讀」，不可示範或指定為 lab。

### 學分／認證的正確說法

| 項目 | 說法 |
|---|---|
| Achievement Code | 完成本 instructor-led course 的出席／完課憑證，依交付流程提供。 |
| GitHub Actions certification | 需另行報名與通過考試；以 [Study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-200) 的當天內容為準。 |
| Applied Skills | 本課沒有對應的 Applied Skills credential；不要暗示存在。 |

## 客製課程地圖與官方對照表

官方 Learn 仍採 7 個模組；下表是講師回答「這在官方教材的哪裡」的唯一對照，不代表本場授課順序或範圍。

| 客戶模組／技能領域 | 本場內容 | 官方 Microsoft Learn 模組 | 說明 |
|---|---|---|---|
| **M1 — Design and Manage Workflows** | YAML、events、jobs、steps、dependencies、variables、secrets、artifact、cache 概念 | [Automate development tasks](https://learn.microsoft.com/en-us/training/modules/github-actions-automate-tasks/)、[Build continuous integration workflows](https://learn.microsoft.com/en-us/training/modules/github-actions-ci/) | 不教 Matrix Strategy 或 Reusable Workflows。 |
| **M2 — Consume and Troubleshoot Workflows** | execution、log、debug、failure、templates | [Build continuous integration workflows](https://learn.microsoft.com/en-us/training/modules/github-actions-ci/) | Templates 依本場指定技術堆疊選例。 |
| **M3 — Author and Maintain Actions（本次不授課）** | 無 | [Create and publish custom GitHub actions](https://learn.microsoft.com/en-us/training/modules/create-custom-github-actions/) | 不排 demo、lab 或補課。 |
| **M4 — Manage GitHub Actions in the Enterprise** | governance、policies、self-hosted runners、runner groups、secrets/variables governance、enterprise templates | [Manage GitHub Actions in the enterprise](https://learn.microsoft.com/en-us/training/modules/manage-github-actions-enterprise/) | 以控制點與 VM runner 對照為主。 |
| **M5 — Secure and Optimize Automation** | security、least privilege、Azure OIDC、environment gates、效能與成本 | [Build and deploy applications to Azure](https://learn.microsoft.com/en-us/training/modules/github-actions-cd/)、[Manage GitHub Actions in the enterprise](https://learn.microsoft.com/en-us/training/modules/manage-github-actions-enterprise/) | 把官方 CD/security/enterprise 的相關單元併入本場 M5。 |

## 建議議程與時間分配

以下是 6 小時 30 分的實際授課時間，不含午餐與休息。Lab 均使用 class repo 的 fill-in-the-blank `labs/lab01` 至 `labs/lab06`；`lab07` 為可選。

| 時段 | 內容 | 分鐘 |
|---|---|---:|
| 09:00–09:20 | 開場、成果目標、Git/YAML 快速對齊、class repo 導覽 | 20 |
| 09:20–10:40 | **M1**：YAML 設計、Build/Test/Artifact + `lab01`/`lab02`/`lab03` | 80 |
| 10:40–10:55 | 休息 | 15 |
| 10:55–12:10 | **M2**：logs、debug、failure troubleshooting + `lab06` | 75 |
| 12:10–13:10 | 午餐 | 60 |
| 13:10–14:10 | **M4**：governance、runner groups、ephemeral self-hosted runner + `lab07`（選修） | 60 |
| 14:10–14:25 | 休息 | 15 |
| 14:25–16:00 | **M5**：Azure OIDC、test → production、approval gate + `lab04`/`lab05` | 95 |
| 16:00–16:15 | 休息 | 15 |
| 16:15–17:00 | `06.full-pipeline` 全流程回顧、Q&A、Achievement Code 與 survey 提醒 | 45 |

**取捨規則：**

1. M1 的 jobs/steps/`needs`、M2 的 log 判讀、M5 的 Build→Test→Package→Deploy spine 不得刪除。
2. 時間不足時，cache 只用一句話重申「miss 只會變慢」；M4 不逐頁瀏覽 enterprise UI；SSH 與 self-hosted runner 僅做已準備好的 contrast。
3. production approval 等待時，改講 OIDC trust、environment protection 或切換到成功 run；不得為了趕時間繞過 approval gate。
4. **M3 不補課。** 未授課的 Matrix Strategy、Reusable Workflows、custom actions 都只可指向延伸閱讀，不進入 hands-on。

## Java + VM demo

class repo 是 <https://github.com/MoneyDemo/20260903-GH200>。依客戶提供的場次設計，它包含 Java Spring Boot 4.1.1、Java 21、Maven 應用程式與 Maven Wrapper，產出 `target/simpleweb.jar`；學員無須安裝 Maven。用 `/`、`/api/info`、`/actuator/health` 檢查服務，其中首頁的 environment、build SHA 與 hostname 可視覺驗證部署目標。

| 項目 | 課堂呈現 |
|---|---|
| Azure Ubuntu 24.04 Linux VM | 同一台 VM 承載兩個 systemd services：`simpleweb-test` 在 `8080`，`simpleweb-prod` 在 `8081`。 |
| GitHub Environments | `test` 與 `production`；`production` 有 required-reviewer approval gate。 |
| 主線部署 | `az vm run-command` + Azure OIDC（M5）。強調短期 token、`permissions: id-token: write` 與精準 federated credential。 |
| SSH 對照 | `07.deploy-ssh`：說明需要開放連接埠與儲存 private key，因此不是主線。 |
| Self-hosted runner 對照 | `08.selfhosted-runner`（M4）：runner 在 VM 上，適合說明網路可達性、runner group、殘留狀態與不信任 PR 的風險。 |
| 漸進 workflow | `01.build` → `02.build-test` → `03.package-artifact` → `04.deploy-test` → `05.deploy-prod` → `06.full-pipeline`；`09.troubleshooting` 用於讀 log。 |

**live deploy 中途失敗：** 先判斷是 YAML/workflow、OIDC、VM command、systemd service 或應用程式 health 的哪一層；用失敗 run 的 job/step/log 示範診斷。三分鐘內未能定位時，切至已完成 run 與兩個健康端點的備援畫面，保留錯誤 run 作為 M2 討論素材。不要改用 SSH、關閉 production gate、印出 secret 或在課堂上修 Terraform。

## 逐模組備課指南

### M1 — Design and Manage Workflows

#### 學習目標

- 能寫出 events、jobs、steps、`needs` 與 `workflow_dispatch` 的 YAML。
- 能分辨 variables、secrets、artifact 與 cache 的用途。

#### 講解重點

- Workflow 在 `.github/workflows/`；workflow 是流程，action 是由 `uses:` 呼叫的元件。
- Job 預設平行；`needs:` 建立依賴。同一 job 的 step 共用 workspace，跨 job 的產出物用 artifact。
- events、manual dispatch、environment variables、secrets；secrets 不可回讀，不能寫進 YAML。
- Cache 只作「加速相依性」概念比較，**不講 Matrix Strategy、也不配置 cache**。

#### Demo・Lab

- 開啟 `01.build`、`02.build-test`、`03.package-artifact`，讓學員由 `lab01`/`lab02` 自己補 YAML。
- 使用 Maven Wrapper build Java app，展示 `target/simpleweb.jar` 被 upload 成 artifact。

#### 常見問題・坑

- workflow 放錯目錄或 YAML 縮排錯誤會導致不執行／解析失敗。
- 忘記 `actions/checkout` 會沒有 source；把 cache 誤當 artifact 會造成跨 job 找不到 jar。

#### 重要連結

- <https://learn.microsoft.com/en-us/training/modules/github-actions-automate-tasks/>
- <https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax>
- <https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows>
- <https://docs.github.com/en/actions/concepts/workflows-and-actions/workflow-artifacts>

### M2 — Consume and Troubleshoot Workflows

#### 學習目標

- 能由 Actions tab 找到失敗 job、step 與有意義的 log 訊息。
- 能用 debug logging 與 workflow templates 開始建立適合的 CI workflow。

#### 講解重點

- 診斷順序：紅色 job → 失敗 step → 錯誤第一段 → YAML、相依、權限或應用程式問題。
- `GITHUB_ENV`、`GITHUB_OUTPUT`、debug logging 與 rerun 的適用時機。
- Templates 聚焦 Angular/React frontend 與 node/python/java/c# backend；模板是起點，仍要依 repo 調整。

#### Demo・Lab

- 用 `09.troubleshooting` 製造或開啟既有失敗案例，讓學員完成 `lab06` 並說出 root cause。
- 對照 Java workflow 和指定技術堆疊的 template，避免把 template 視為通用的完成品。

#### 常見問題・坑

- 不要只看 log 最後一行；先辨識哪個 step 失敗。
- environment approval pending 不是 failure；應回到 M5 說明。

#### 重要連結

- <https://learn.microsoft.com/en-us/training/modules/github-actions-ci/>
- <https://docs.github.com/en/actions/how-tos/monitor-workflows/enable-debug-logging>
- <https://docs.github.com/en/actions/how-tos/write-workflows/use-workflow-templates>
- <https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands>

### M3 — Author and Maintain Actions（本次不授課）

#### 學習目標

- 無；本模組是客戶明確排除的範圍。

#### 講解重點

- 不講 custom action authoring、composite action、Marketplace 或 action release。

#### Demo・Lab

- 無；不可臨時加 lab。

#### 常見問題・坑

- 學員問到時，說明這是官方 [Create and publish custom GitHub actions](https://learn.microsoft.com/en-us/training/modules/create-custom-github-actions/) 的延伸範圍，不占用本場授課時間。

#### 重要連結

- <https://learn.microsoft.com/en-us/training/modules/create-custom-github-actions/>

### M4 — Manage GitHub Actions in the Enterprise

#### 學習目標

- 能說明 enterprise governance、organization policies、runner groups 與 secrets/variables governance 的控制目的。
- 能比較 GitHub-hosted 與 self-hosted runner 的責任邊界。

#### 講解重點

- Actions allow-list、預設 `GITHUB_TOKEN` 權限、fork PR approval 與 enterprise templates。
- self-hosted runner 是自管機器，不是乾淨環境；不得讓它執行不信任 fork PR。
- runner groups 限制誰能使用 runner；先看權限與隔離，再討論成本。

#### Demo・Lab

- 用 `08.selfhosted-runner` 與選修 `lab07` 對照 VM runner；若無 org admin 權限，改用流程圖與已備妥畫面。

#### 常見問題・坑

- 註冊 token 短效，不可貼進投影片或 chat。
- 不因自管 runner 不計 Actions minutes 就忽略 VM、修補與安全成本。

#### 重要連結

- <https://learn.microsoft.com/en-us/training/modules/manage-github-actions-enterprise/>
- <https://docs.github.com/en/organizations/managing-organization-settings/disabling-or-limiting-github-actions-for-your-organization>
- <https://docs.github.com/en/actions/concepts/runners/runner-groups>
- <https://docs.github.com/en/actions/concepts/runners/self-hosted-runners>

### M5 — Secure and Optimize Automation

#### 學習目標

- 能用 least-privilege `permissions:`、Azure OIDC 與 GitHub Environments 設計安全部署。
- 能完成 test/prod 的 artifact deploy，並辨識 workflow 效能與成本的基本取捨。

#### 講解重點

- `GITHUB_TOKEN` 不等於 Azure identity；OIDC 以 Azure 為 Connect 對象，job 需 `id-token: write`。
- federated credential subject 必須精準對應 repo、branch 或 environment；production 用 required reviewer，不繞過 gate。
- 建置一次、以同一 artifact 部署 test/prod；控制 concurrency、避免不必要 runner 分鐘與重複 build。
- 對第三方 action 用完整 SHA，防止 script injection；secrets 不可 echo 或放 artifact。

#### Demo・Lab

- `04.deploy-test` 部署 `simpleweb-test:8080`；`05.deploy-prod` 等待 production approval 後部署 `simpleweb-prod:8081`；`06.full-pipeline` 串起流程。
- `lab04`/`lab05` 寫 YAML；`07.deploy-ssh` 只作 SSH 安全代價的對照。

#### 常見問題・坑

- OIDC 失敗先檢查 `id-token: write` 與 federated credential subject；不要把 client secret 作為第一反應。
- 本場第一次登入曾出現 `AADSTS700213`：GitHub token 的 subject 使用含
  organization/repository stable ID 的格式，而非只含名稱的舊格式。**直接從 workflow
  error 讀取 presented assertion subject，再讓 Azure federated credential 精確匹配**；
  不要從記憶猜 subject。
- 共享課程 subscription 可能由外部排程 deallocate VM。每個 Run Command deployment
  在 `azure/login` 後先執行 `az vm start`，再 invoke；看到
  `OperationNotAllowed: The operation requires the VM to be running` 時不要重建資源。
- run 成功但 health endpoint 失敗時，分開檢查 systemd service、port 與 app health。

#### 重要連結

- <https://learn.microsoft.com/en-us/training/modules/github-actions-cd/>
- <https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure>
- <https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect>
- <https://docs.github.com/en/actions/concepts/workflows-and-actions/deployment-environments>
- <https://docs.github.com/en/actions/reference/security/secure-use#using-third-party-actions>

## 課前準備清單（開課前 1–2 天）

以下全為待講師執行的檢查，本文不宣稱已完成。

### Class repo 與 GitHub

- [ ] 講師 GitHub 帳戶可登入，且已設定 2FA 與備援方式；不可假設 classroom browser 仍有登入狀態。
- [ ] 可開啟 <https://github.com/MoneyDemo/20260903-GH200>，並確認 `labs/lab01`…`labs/lab06`、可選 `lab07` 與 workflows 可讀取。
- [ ] 在可丟棄分支／repo 實跑一個 `workflow_dispatch`，確認 Build、Test、Package、Artifact 與 log 可展示。
- [ ] organization 與 target repository 的 Actions 均啟用，allowed-actions policy 不會擋住課堂使用的 action；確認預設 `GITHUB_TOKEN` 權限，workflow 仍採 least privilege。
- [ ] `test`、`production` GitHub Environments 存在；production 的 required-reviewer approval gate 由正確人員可核准。
- [ ] OIDC 所需 GitHub Environment secrets/variables 已存在，但不在投影片、chat、terminal history 或 YAML 明文出現。
- [ ] M4 若需 UI demo，確認講師可見 organization policies / runner groups；否則備妥架構圖或成功截圖。
- [ ] runner registration token 僅於課堂前註冊時取得；若需要 self-hosted runner，確認主機出站連線與最小 trusted workflow。

### Java + Azure VM

- [x] Azure Ubuntu 24.04 VM 可由 Azure Run Command 管理。SSH 對照已驗證，但共享
  policy 會移除 port 22；若現場要重跑 `07.deploy-ssh`，依 `TERRAFORM/README.md`
  使用精確命名的暫時 rule，demo 後立即刪除。
- [ ] `simpleweb-test`（`8080`）與 `simpleweb-prod`（`8081`）systemd services 均 healthy；`/`、`/api/info`、`/actuator/health` 可回應。
- [ ] Azure OIDC federated credential、最小 Azure RBAC 與 workflow `permissions: id-token: write` 的組合已實跑；確認 subject 對應 class repo 與 Environment。
- [ ] `az vm run-command` 主線、SSH 對照、self-hosted runner 對照各有可展示的成功結果與 fallback 截圖。
- [ ] 若有 C# demo，另確認 Windows Web App 的 target framework 與 runtime 相容；不要把 Java jar 部署到該目標。

### 行政、連結與備援

- [ ] **⛔ 阻斷性項目 — survey URL：** `https://aka.ms/gh200survey` 已知會導向 Metrics That Matter 錯誤頁。README 必須保留此連結，但開課前必須向交付單位取得並點開驗證本場可用網址；在那之前不要投影或朗讀該網址。
- [ ] 開課前重新驗證 README 與本文所有 Learn、GitHub Docs 與影片連結；前一場存活不代表本場仍可用。
- [ ] 準備 workflow 成功與失敗 log、VM health、production approval pending/approved 的備援截圖。
- [ ] 確認教室網路可連 GitHub、Azure Portal、Microsoft Learn 與需要的 GitHub Actions service。
- [ ] Achievement Code 發放流程已確認。

## 講師小技巧

- 全日反覆使用同一條 Build → Test → Package → Deploy 故事線；每一段都回到 YAML 和 log。
- live demo 必做的是寫 YAML、觸發 run、讀 log；需等待的 approval 或部署則用第二個已完成分頁維持節奏。
- 遇到不確定的計費、plan 或考試問題，當場查官方文件或明確說明未驗證；不要推測。

## 參考

| 資源 | 連結 |
|---|---|
| Course | <https://learn.microsoft.com/en-us/training/courses/gh-200t00> |
| Study guide | <https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-200> |
| Class demo repo | <https://github.com/MoneyDemo/20260903-GH200> |
| Demo environment | [demo-environment.md](demo-environment.md) |
| Attendee reference | [../README.md](../README.md) |
