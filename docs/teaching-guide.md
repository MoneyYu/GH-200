# GH-200 備課指南

> 📖 **Related** — [Demo environment](demo-environment.md)

> **講師專用。** 本文不是學員面向的 [`../README.md`](../README.md)。README 是給學員的參考連結頁；本文是備課、控場與風險提示，**不要**投影本文內容給學員看。

---

## 課程定位與基本資料

**GH-200T00-A — Automate your workflow with GitHub Actions** 是 Microsoft instructor-led course，內容涵蓋從單一 workflow、CI/CD、GitHub Script 自動化，到 packages、custom actions，以及 enterprise 層級的 Actions 治理。

| 項目 | 內容 |
|---|---|
| 課程頁面 | <https://learn.microsoft.com/en-us/training/courses/gh-200t00> |
| 時數 | 1 天 |
| 難度 | Intermediate |
| 模組數 | 7（跨 2 條 learning path） |
| 對象 | 想用 GitHub Actions 自動化 SDLC 的 developers、DevOps engineers、以及需要治理 Actions 的 GitHub administrators |
| 相關認證 | GitHub Actions certification — <https://learn.microsoft.com/en-us/credentials/certifications/github-actions/> |
| Study guide | <https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-200> |
| 實作環境 | 學員自己的 GitHub 帳戶；M03 另需 Azure subscription |
| 講師 demo org | <https://github.com/MoneyDemo> |

**先備知識（開場先對齊，避免中段崩盤）：**

- Git 基本操作：clone、branch、commit、push、pull request。**這是硬需求**，不會 Git 的學員在 M02 之後會全程跟不上。
- 讀得懂 YAML（縮排、list、mapping、字串引號）。YAML 縮排錯誤是本課最常見的 lab 卡點。
- 對 CI/CD 概念有基本認識（build、test、artifact、deploy 的區別）。
- M03 需要對 Azure 資源與訂用帳戶有基本概念；沒有 Azure 經驗的學員要提前告知節奏會比較快。
- M04 會出現 JavaScript / Octokit 語法；不需要會寫 JS，但要能讀。

### ⚠️ 2026 年 1 月 exam objectives 大改版警告

**GitHub Actions certification 的 exam objectives 在 2026 年 1 月經過大幅改寫。**

- **不要**直接沿用 2026 年以前的備課筆記、投影片補充、模擬題或「考試重點整理」。舊版的 domain 切分與權重已經不同，照舊講會誤導學員的備考方向。
- 開課前**務必**親自打開 study guide（<https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-200>），看該頁面的 **change log / 更新日期**與目前的 skills measured 清單，以**當天實際頁面內容**為準來調整強調比重。
- 學員問「考試會考什麼」時，一律導向 study guide 與 certification 頁面，**不要**憑印象講題型、題數、及格分數或計分方式——這些本文一律不提供，因為無法驗證。
- 本備課指南的模組內容依照**目前的 Learn 模組單元**撰寫；遇到 study guide 與模組內容側重不同時，課堂教學以模組為準，備考建議以 study guide 為準，並向學員說明兩者的角色差異。

### 學分／認證的正確說法

課程與認證是**兩件不同的事**，開場就要講清楚，否則課後 Q&A 會反覆被問：

| 項目 | 是什麼 | 怎麼取得 |
|---|---|---|
| **Achievement Code** | 完成本 instructor-led course 的出席／完課憑證 | 由講師／交付單位在課程流程中提供給學員 |
| **Certification（GitHub Actions certification）** | 正式認證，需另外報名並通過考試 | 依 certification 頁面的報名流程 |
| **Applied Skills** | **本課程沒有對應的 Applied Skills credential** | N/A — 不要暗示存在 |

---

## 課程地圖：7 個模組

課程內容分屬兩條 learning path：

- **Part 1**：<https://learn.microsoft.com/en-us/training/paths/github-actions/>（M01–M04）
- **Part 2**：<https://learn.microsoft.com/en-us/training/paths/github-actions-2/>（M05–M07）

| # | 模組 | 這個模組要讓學員帶走什麼 | 練習數 |
|---|---|---|---|
| **M01** | [Automate development tasks by using GitHub Actions](https://learn.microsoft.com/en-us/training/modules/github-actions-automate-tasks/) | Actions 的組成（workflow / job / step / action）、事件觸發、第一個能跑起來的 workflow | 1 |
| **M02** | [Build continuous integration workflows by using GitHub Actions](https://learn.microsoft.com/en-us/training/modules/github-actions-ci/) | 用 workflow 做 CI：build、test、matrix、artifact、status check、與 PR 流程整合 | 1 |
| **M03** | [Build and deploy applications to Azure by using GitHub Actions](https://learn.microsoft.com/en-us/training/modules/github-actions-cd/) | CD 到 Azure：environments、deployment 認證（OIDC / secret）、artifact 交接、容器化部署 | 3 |
| **M04** | [Automate GitHub by using GitHub Script](https://learn.microsoft.com/en-us/training/modules/automate-github-using-github-script/) | 用 `actions/github-script` 在 workflow 內直接呼叫 GitHub API 做流程自動化 | 1 |
| **M05** | [Leverage GitHub Actions to publish to GitHub Packages](https://learn.microsoft.com/en-us/training/modules/github-actions-packages/) | 發佈 package／container image 到 GitHub Packages / GHCR，權限與 visibility | 1 |
| **M06** | [Create and publish custom GitHub actions](https://learn.microsoft.com/en-us/training/modules/create-custom-github-actions/) | 自製 action（JavaScript / Docker / composite）、metadata、版本與發佈策略 | 1 |
| **M07** | [Manage GitHub Actions in the enterprise](https://learn.microsoft.com/en-us/training/modules/manage-github-actions-enterprise/) | 組織／企業層級治理：政策、runner groups、self-hosted runners、reusable workflow 與 template 的散佈 | **0** |

**M07 沒有動手練習，這是課程設計，不是遺漏。** 不要臨時發明一個 M07 lab 塞進去；要補足手感就用 demo（見 M07 段落）。

**練習形式：** 本課**沒有** MicrosoftLearning GH-200 lab repository，也沒有 `aka.ms/gh200labs` 這類短網址（未註冊，不要在投影片或口頭提及）。所有練習都是 **Learn 模組內的 exercise unit**，學員在**自己的 GitHub 帳戶**完成；M03 另需自己的 Azure subscription。

---

## 建議議程與時間分配

以 6.5 小時實際授課時間規劃（不含午休與休息）。時間為**課堂議程**建議，非實作工時估算。

| 時段 | 內容 | 分鐘 |
|---|---|---|
| 09:00–09:15 | 開場：自我介紹、課程範圍、認證 vs Achievement Code、環境確認（GitHub 帳戶、Azure 訂用帳戶） | 15 |
| 09:15–10:15 | **M01** 概念 + demo + 練習 | 60 |
| 10:15–10:30 | ☕ 休息 | 15 |
| 10:30–11:40 | **M02** CI：matrix、artifact、status check + 練習 | 70 |
| 11:40–12:40 | 🍱 午餐 | 60 |
| 12:40–14:10 | **M03** CD to Azure（本課最重的模組，3 個練習，取捨見下） | 90 |
| 14:10–14:25 | ☕ 休息 | 15 |
| 14:25–15:00 | **M04** GitHub Script | 35 |
| 15:00–15:40 | **M05** GitHub Packages | 40 |
| 15:40–15:50 | ☕ 休息 | 10 |
| 15:50–16:40 | **M06** Custom actions | 50 |
| 16:40–17:10 | **M07** Enterprise 治理（demo-only）+ 認證指引 + Q&A + survey | 30 |

實際授課時間合計 **390 分鐘（6 小時 30 分）**，加上休息與午餐後於 17:10 結束。

**取捨規則（時間一定會不夠，先想好要砍哪裡）：**

- **M03 是最容易超時的模組**（3 個練習）。若進度落後，優先讓學員完成「deploy web app to Azure」該題，artifact 與 container 兩題改為講師 demo + 課後自行練習。
- 沒有 Azure subscription 的學員在 M03 只能觀摩：提前在早上就確認人數，若超過半數沒有訂用帳戶，直接把 M03 改成全 demo，把省下的時間補到 M02 與 M06。
- **M07 不要花時間在 UI 逐頁點擊**。企業設定畫面依 plan 與角色差異很大，講不完又容易講錯，重點放在「哪些控制點存在、為什麼要有」。
- 若嚴重落後，M04 可壓縮到 25 分鐘（概念 + 一段 script 講解），因為它的觀念相對獨立。

---

## 貫穿全課的核心觀念

這一節的內容在 M01 就要建立，之後每個模組回頭引用。學員在這幾個概念上混淆，會一路錯到 M07。

### Workflow / Action / Job / Step 的層級

| 概念 | 是什麼 | 存在哪裡 | 關鍵特性 |
|---|---|---|---|
| **Workflow** | 由事件觸發的自動化流程 | `.github/workflows/*.yml`（存在 repository 內） | 一個 repo 可有多個 workflow；由 `on:` 定義觸發條件 |
| **Job** | Workflow 內的一組 step，跑在**一台 runner** 上 | workflow 檔的 `jobs:` | 預設**平行**執行；用 `needs:` 建立相依；**不同 job 不共用檔案系統**，要傳檔案得靠 artifact |
| **Step** | Job 內的單一動作 | job 的 `steps:` | 依序執行；同一 job 的 step **共用同一個 workspace 與檔案系統** |
| **Action** | 可重用的封裝單元，被 step 以 `uses:` 呼叫 | 自己的 repository（或 Marketplace） | 是**被呼叫的元件**，不是流程本身 |

**最常見的誤解：** 學員把 workflow 講成 action。務必用一句話定錨——**「Workflow 是流程，action 是流程裡被 `uses:` 叫用的零件」**。

Step 只有兩種形式：`run:`（執行 shell 指令）或 `uses:`（呼叫 action）。**一個 step 不能同時有 `run:` 與 `uses:`** — 這是 knowledge check 常見陷阱。

- 概念：<https://docs.github.com/en/actions/get-started/understand-github-actions>
- Workflow syntax：<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax>

### Runner 類型比較

| 類型 | 由誰維護／代管 | 典型用途 | 要注意什麼 |
|---|---|---|---|
| **GitHub-hosted runner** | GitHub 代管，每次 job 使用乾淨的 VM | 絕大多數 CI/CD | 映像檔內容與預裝軟體**會隨時間變動**；不要假設某個工具版本永遠存在，需要固定版本就用 `actions/setup-*` 明確指定 |
| **Larger runner** | GitHub 代管，但可選更多 vCPU／記憶體／指定作業系統設定 | 需要更高規格或特定網路設定的工作 | 需要對應的 plan／組織設定；由 runner group 控管誰能用 |
| **Self-hosted runner** | **你自己**的機器（實體、VM、容器） | 需要存取內網、特殊硬體、或既有授權軟體 | 環境**不是每次重置**，會有殘留狀態；維護、修補、安全性都歸你；**絕對不要**掛在接受不信任 fork PR 的 public repository 上 |

- <https://docs.github.com/en/actions/concepts/runners/github-hosted-runners>
- <https://docs.github.com/en/actions/concepts/runners/larger-runners>
- <https://docs.github.com/en/actions/concepts/runners/self-hosted-runners>

### 重用機制：starter workflow / reusable workflow / composite action

三者非常容易混淆，M02、M06、M07 都會碰到，建議在 M01 先給這張表：

| 機制 | 重用的是什麼 | 怎麼使用 | 更新來源後既有使用端會怎樣 |
|---|---|---|---|
| **Starter workflow（workflow template）** | 一份**範本檔** | 在 repo 建立新 workflow 時從範本**複製**出來 | **不會**跟著變 — 已經是複製出去的獨立檔案 |
| **Reusable workflow** | **整個 workflow（含多個 job）** | 呼叫端用 `jobs.<id>.uses: owner/repo/.github/workflows/x.yml@ref` | 會（取決於引用的 `@ref`）；呼叫端傳 `with:` / `secrets:` |
| **Composite action** | **一組 step** | 在 job 的 step 用 `uses:` 呼叫 | 會（取決於引用的 ref／SHA） |

判斷口訣：**要重用「一串 step」→ composite action；要重用「整個工作流程／多個 job」→ reusable workflow；只是要給團隊一個起手式 → starter workflow。**

- Reusable workflows：<https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows>
- Workflow templates：<https://docs.github.com/en/actions/how-tos/reuse-automations/create-workflow-templates>
- Custom action 類型：<https://docs.github.com/en/actions/concepts/workflows-and-actions/custom-actions>

### 身分與認證：`GITHUB_TOKEN` vs PAT vs OIDC

**這是全課最關鍵、也最常被答錯的觀念。**

| 機制 | 用來對誰認證 | 生命週期 | 適用情境 |
|---|---|---|---|
| **`GITHUB_TOKEN`** | **GitHub API／該 repository** | 每次 workflow run 自動產生，run 結束即失效 | 大多數對「自己這個 repo」的操作：留言、加 label、發布 package、建立 release |
| **PAT（personal access token）** | **GitHub API**（跨 repo／跨 org 時） | 由人建立，需自行輪替與保管 | `GITHUB_TOKEN` 權限範圍**不足**時（例如要操作另一個 repository）。存成 secret，**永遠不要寫進 YAML** |
| **OIDC（OpenID Connect）** | **雲端供應商**（如 Azure、AWS） | workflow run 期間換發的短期 token | **取代長期雲端憑證**（例如把 Azure service principal 密碼存成 secret） |

**必須澄清的重點：OIDC 是「與雲端供應商建立信任的身分聯邦」，不是用來取代 `GITHUB_TOKEN` 去呼叫 GitHub API 的。** 學員很常以為「有了 OIDC 就不用 `GITHUB_TOKEN`」——這是錯的，兩者解決不同問題。

`GITHUB_TOKEN` 的權限要用 `permissions:` 明確收斂（least privilege）。在 workflow 或 job 層級寫出需要的 scope，比整份開 `write-all` 安全得多。

- `GITHUB_TOKEN`：<https://docs.github.com/en/actions/concepts/security/github_token>
- OIDC in Azure：<https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure>
- Azure 端設定：<https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect>

### Secrets vs configuration variables，以及 context 的求值時機

| | Secrets | Configuration variables |
|---|---|---|
| 用途 | 敏感值（token、密碼、連線字串） | 非敏感設定（環境名稱、region、build flag） |
| 存取方式 | `${{ secrets.NAME }}` | `${{ vars.NAME }}` |
| Log 中的顯示 | 會被遮蔽（masked） | **明文顯示** |
| 建立後可否讀回原值 | **不行**，只能覆寫 | 可以檢視 |
| 作用範圍 | repository / environment / organization | repository / environment / organization |

**遮蔽不等於安全。** 提醒學員：secret 若被 base64、拆字串或反轉後印出，遮蔽機制可能失效；secret **不會**傳給來自 fork 的 pull request workflow（這是刻意的安全設計，也是學員 lab 「為什麼我的 secret 是空的」的常見原因）。

**Context 與不受信任資料（script injection）——這是安全題常考點：**

`${{ ... }}` 是在**指令實際執行之前**由 Actions 做字串代換的。若把使用者可控的內容（如 `github.event.issue.title`、`github.event.pull_request.body`）直接插進 `run:`，攻擊者可在標題裡塞入 shell 語法而在 runner 上執行任意指令。

正確做法：**把不受信任的值先放進環境變數，再在 script 內引用**：

```yaml
- name: Safe
  env:
    TITLE: ${{ github.event.issue.title }}
  run: echo "$TITLE"
```

- Contexts：<https://docs.github.com/en/actions/reference/workflows-and-actions/contexts>
- Expressions：<https://docs.github.com/en/actions/reference/workflows-and-actions/expressions>
- Variables：<https://docs.github.com/en/actions/reference/workflows-and-actions/variables>
- Secrets：<https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets>
- Script injection：<https://docs.github.com/en/actions/concepts/security/script-injections>

### 供應鏈安全：pinning、immutable releases、artifact attestations

| 主題 | 重點 | 對學員的一句話 |
|---|---|---|
| **Pinning third-party actions** | 引用第三方 action 時，用**完整 commit SHA**（而非可移動的 tag），避免上游把 tag 指向新的 commit | 「tag 會動，SHA 不會」 |
| **Immutable releases / tags** | 讓 action 的 release 與 tag 不可被覆寫，降低「同一個版本內容被抽換」的風險 | 發佈自己的 action 時要開啟 |
| **Artifact attestations** | 為 build 產出物產生可驗證的來源證明（provenance） | 「證明這個 artifact 真的是這條 workflow 建出來的」 |

- Secure use（含第三方 action）：<https://docs.github.com/en/actions/reference/security/secure-use#using-third-party-actions>
- Immutable releases：<https://docs.github.com/en/actions/how-tos/create-and-publish-actions/using-immutable-releases-and-tags-to-manage-your-actions-releases>
- Artifact attestations：<https://docs.github.com/en/actions/concepts/security/artifact-attestations>

---

## 逐模組備課指南

### M01 - Automate development tasks by using GitHub Actions

#### 學習目標

- 說明 GitHub Actions 的組成元件與彼此關係（workflow、event、job、step、action、runner）。
- 說明哪些事件可以觸發 workflow，以及 workflow 檔要放在哪裡。
- 建立並執行第一個可運作的 workflow，並在 Actions tab 讀懂執行結果。

#### 講解重點

- **檔案位置是硬規定**：workflow 必須在 `.github/workflows/`，副檔名 `.yml` 或 `.yaml`。放錯地方不會有錯誤訊息，只是**完全不會執行**——這是學員第一個卡點。
- `on:` 的三大類觸發：repository 事件（`push`、`pull_request`、`issues`…）、排程（`schedule` + cron）、手動／外部（`workflow_dispatch`、`repository_dispatch`）。
- **`workflow_dispatch` 值得多花兩分鐘**：它讓學員能手動重跑，整天的 demo 都靠它，而且它是「不用一直亂 push commit」的救命稻草。
- Job 預設**平行**；`needs:` 才有順序。用一張圖說明「同 job 的 step 共用檔案系統，跨 job 不共用」。
- `uses:` 的引用語法：`owner/repo@ref`。順便帶出「`@v4` 是 tag、可以被移動；`@<full-SHA>` 才固定」。
- Workflow commands：用 `$GITHUB_OUTPUT`、`$GITHUB_ENV`、`::notice`／`::error` 在 step 之間傳值與標註結果。

#### Demo / Lab

- **Lab（1 題）**：Learn 模組內的 exercise unit，學員在自己的 repository 完成。
- **建議 demo 順序（live-first）**：
  1. 在 `MoneyDemo` 或講師自己的 repo，用 GitHub UI 的 Actions tab 直接新增一個 workflow 檔（示範它其實只是一個 commit）。
  2. 故意留一個縮排錯誤，讓學員看 GitHub 的 YAML 驗證訊息，再修正——**這比「一次寫對」教學效果好很多**。
  3. 加上 `workflow_dispatch`，手動觸發一次。
  4. 打開 run 的 log，逐段展開：set up job → 每個 step → complete job。**教會學員看 log**，是本課投報率最高的十分鐘。

#### 常見問題 / 坑

- **Workflow 不執行**：檔案不在 `.github/workflows/`、分支不對（`on: push` 只監看指定分支）、或 repository／org 層級停用了 Actions。
- **YAML 縮排**：`steps:` 底下每一項要有 `- `；`with:` 是 `uses:` 的參數，不是 step 的同層屬性。
- **Knowledge check 陷阱**：
  - 「workflow 檔可以放哪裡？」→ 只有 `.github/workflows/`，**不含子目錄**。
  - 「一個 step 能不能同時 `uses:` 和 `run:`？」→ **不行**。
  - 「job 預設是循序還是平行？」→ **平行**，除非 `needs:`。
- 學員的新 repo 若是空的，某些 `on: push` 觸發要先有 commit 才看得到效果。

#### 重要連結

- 模組：<https://learn.microsoft.com/en-us/training/modules/github-actions-automate-tasks/>
- Exercise：<https://learn.microsoft.com/en-us/training/modules/github-actions-automate-tasks/3-exercise-create-container-action>
- 概念：<https://docs.github.com/en/actions/get-started/understand-github-actions>
- Events：<https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows>
- Workflow commands：<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands>

---

### M02 - Build continuous integration workflows by using GitHub Actions

#### 學習目標

- 用 GitHub Actions 建立 CI workflow：安裝相依、build、跑測試。
- 使用 matrix strategy 在多個版本／作業系統上平行驗證。
- 產生並取用 workflow artifact；把 CI 結果接到 pull request 的 status check。

#### 講解重點

- **CI 的價值主張先講**：在 merge 之前自動驗證，讓 `pull_request` 觸發的 workflow 成為 branch protection 的守門員。
- `actions/checkout` 幾乎是所有 CI 的第一個 step——**沒有它，runner 上沒有你的原始碼**。學員常忘記，然後困惑「檔案不存在」。
- **Matrix**：用 `strategy.matrix` 展開多組組合，一個定義產生多個 job。順帶說明 `fail-fast`（預設會在其中一組失敗時取消其他組）與 `include` / `exclude` 的用途。
- **Artifact 是跨 job 傳遞檔案的正規手段**：`upload-artifact` / `download-artifact`。強調 artifact 有保留期限，而且**不是**部署機制。
- **Caching vs artifact 的區別**（高頻混淆點）：
  - **Cache** 是為了**加速**（例如相依套件），內容遺失只是變慢，不影響正確性。
  - **Artifact** 是為了**保存與交付產出物**，供下載或後續 job 使用。
- **Service containers**：需要資料庫等相依服務的整合測試，用 `services:` 在 job 內起容器。
- **Concurrency**：同一個 PR 連續 push 時取消前一次的 run，省時間也省用量。
- 選講：**YAML anchors** 可減少重複，但可讀性有代價，團隊要有共識。

#### Demo / Lab

- **Lab（1 題）**：在 GitHub 上建立 CI workflow。
- **Demo 建議**：現場開一個 PR，讓學員看到 check 從黃色 → 綠色／紅色的變化，再點進失敗的 job 讀 log。**故意讓測試失敗一次**，示範怎麼從 log 定位問題，再修好重跑。
- 若時間允許，加一個兩維 matrix（例如兩個 runtime 版本 × 兩個 OS），讓學員直觀感受「一段設定變出四個 job」。

#### 常見問題 / 坑

- 忘了 `actions/checkout`。
- Matrix 變數要用 `${{ matrix.<key> }}` 引用，寫成 `${{ matrix }}` 無效。
- 以為 artifact 會自動在 job 之間流動——**不會**，必須明確 upload 再 download。
- 以為 cache 命中就代表相依版本一定正確：cache key 設計不良會拿到過期內容。
- **Knowledge check 陷阱**：「要在 job 之間共享 build 產出物用什麼？」→ **artifact**，不是 cache。
- 在 fork 的 PR 上，`GITHUB_TOKEN` 權限受限且 secret 不可用，CI 若依賴 secret 會失敗。

#### 重要連結

- 模組：<https://learn.microsoft.com/en-us/training/modules/github-actions-ci/>
- Exercise：<https://learn.microsoft.com/en-us/training/modules/github-actions-ci/3-exercise-ci-workflow-github>
- Matrix：<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idstrategy>
- Artifacts：<https://docs.github.com/en/actions/concepts/workflows-and-actions/workflow-artifacts>
- Caching：<https://docs.github.com/en/actions/concepts/workflows-and-actions/dependency-caching>
- Service containers：<https://docs.github.com/en/actions/tutorials/use-containerized-services/use-docker-service-containers>
- Concurrency：<https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency>
- YAML anchors：<https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations#yaml-anchors-and-aliases>

---

### M03 - Build and deploy applications to Azure by using GitHub Actions

#### 學習目標

- 建立把應用程式部署到 Azure 的 workflow。
- 使用 environment 做部署目標的區隔、保護規則與環境層級 secret／variable。
- 在部署流程中正確處理 artifact，並示範容器化應用程式的部署路徑。

#### 講解重點

- **這是全課最重、最容易超時的模組（3 個練習）**。開場先講清楚今天要完成哪一題、哪些改為 demo。
- **認證方式是本模組的核心教學價值**，不是 YAML 語法：
  - 傳統做法：把 Azure service principal 憑證存成 secret（長期憑證，需輪替）。
  - 建議做法：**OIDC federated credential**，workflow 換發短期 token，**不需要在 GitHub 存長期雲端密碼**。使用 OIDC 時，job 需要 `permissions: id-token: write`（少了它會出現 token 取得失敗，這是最常見的錯誤）。
- **Environments**：不只是名字，還帶來 required reviewers、wait timer、branch 限制，以及環境層級的 secret／variable。這是「CD 治理」的落點。
- **Build 一次、部署多次**：build job 產出 artifact，deploy job 下載同一份 artifact 部署，避免每個環境各自 build 出不同結果。這個模式要講出來，它是實務上的正解。
- 容器路徑：build image → push 到 registry（GHCR 或 Azure Container Registry）→ Web App 拉取。這裡與 M05 的 packages 內容自然銜接，可以先埋伏筆。
- **⚠️ 租戶／訂用帳戶政策相依**：能否建立 service principal、federated credential、App Service，完全取決於學員／講師的 Azure 訂用帳戶權限與租戶政策。**不要保證學員一定做得到**，事前確認。

#### Demo / Lab

- **Lab（3 題）**：deploy web app to Azure、work with workflow artifacts、deploy containerized app。
- **時間不足時的優先序**：第 1 題學員自己做 → 第 2 題快速帶過（多數觀念 M02 已建立）→ 第 3 題講師 demo。
- **講師 demo 環境**：可使用 [`../TERRAFORM/`](../TERRAFORM/) 備援 stack 產出的 Windows Web App 作為部署目標。**AI agent 一律不得執行 `terraform apply`；由講師本人手動套用**。詳見 [demo-environment.md](demo-environment.md)。
- 部署前確認 sample 的 target framework 與 App Service runtime 相容，否則會在部署後才在瀏覽器看到錯誤，很難在課堂上除錯。

#### 常見問題 / 坑

- **沒有 Azure subscription 的學員**：課前就要盤點，不要等到中午才發現。
- OIDC 少了 `id-token: write` → 取得 token 失敗。
- Federated credential 的 subject（repo／branch／environment）與實際觸發條件不符 → 認證被拒。**subject 必須精準對應**。
- 用了 environment 但設了 required reviewer，部署卡在等待核准，學員以為壞掉了。
- Web App 名稱全域唯一，學員撞名。
- 部署成功但網站 500：多半是 runtime 版本或發佈內容結構不符，不是 workflow 的問題——示範怎麼分辨「workflow 失敗」與「應用程式失敗」。
- **Knowledge check 陷阱**：「用 OIDC 部署到 Azure 時，還需要在 GitHub 存 client secret 嗎？」→ **不需要**，這正是 OIDC 的重點。

#### 重要連結

- 模組：<https://learn.microsoft.com/en-us/training/modules/github-actions-cd/>
- Exercise 1：<https://learn.microsoft.com/en-us/training/modules/github-actions-cd/3-create-workflow-deploy-azure>
- Exercise 2：<https://learn.microsoft.com/en-us/training/modules/github-actions-cd/exercise-2>
- Exercise 3：<https://learn.microsoft.com/en-us/training/modules/github-actions-cd/exercise>
- Environments：<https://docs.github.com/en/actions/concepts/workflows-and-actions/deployment-environments>
- OIDC in Azure：<https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure>
- Azure 端 OIDC 設定：<https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect>
- Secrets：<https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets>

---

### M04 - Automate GitHub by using GitHub Script

#### 學習目標

- 說明 `actions/github-script` 的用途：在 workflow 內以 JavaScript 直接呼叫 GitHub API。
- 使用預先驗證好的 `github`（Octokit）與 `context` 物件操作 issue、PR、comment 等資源。
- 判斷什麼時候該用 GitHub Script，什麼時候該寫成獨立的 custom action。

#### 講解重點

- **定位**：GitHub Script 的價值是「**省掉認證與 SDK 安裝的樣板**」。它已經幫你注入了一個用 `GITHUB_TOKEN` 驗證好的 Octokit 實例。
- 可直接使用的物件：`github`（Octokit REST client）、`context`（事件與 repo 資訊）、`core`（輸出與 log）。
- **權限就是 `GITHUB_TOKEN` 的權限**：要留言就要 `issues: write`，要改 PR 就要 `pull-requests: write`。403 錯誤十之八九是 `permissions:` 沒開。
- 跨 repository 操作時 `GITHUB_TOKEN` 不夠，需要 PAT（或 GitHub App token）存成 secret。
- **安全提醒（延續核心觀念）**：不要把 `context.payload.issue.title` 這類使用者可控內容拼進 shell 或當程式碼求值。
- **何時不該用 GitHub Script**：邏輯超過數十行、需要單元測試、要跨多個 repo 重用時 → 改寫成 custom action（銜接 M06）。

#### Demo / Lab

- **Lab（1 題）**：在 workflow 中使用 GitHub Script。
- **Demo 建議**：做一個「新 issue 自動回覆歡迎留言並貼上 label」的 workflow，現場開一個 issue 觸發。效果直觀，學員接受度最高。
- 可以順手示範 `core.setOutput()` 把結果傳給後續 step，串回 M01 的 workflow commands。

#### 常見問題 / 坑

- YAML 的 `script:` 區塊要用 block scalar（`|`），且內部 JavaScript 縮排要一致。
- 在 script 內誤用 `${{ }}` 插入不受信任的值 → injection 風險（**這是安全題常考點**）。正確做法是透過 `env:` 傳入，再用 `process.env` 讀取。
- Octokit 的方法命名與 REST 端點對應關係（例如 `github.rest.issues.createComment`）——建議現場打開 Octokit 文件查一次，示範「怎麼查」比背 API 有用。
- 403 / Resource not accessible by integration → 缺 `permissions:`。
- **Knowledge check 陷阱**：「GitHub Script 預設用哪個 token？」→ **`GITHUB_TOKEN`**（不是 PAT）。

#### 重要連結

- 模組：<https://learn.microsoft.com/en-us/training/modules/automate-github-using-github-script/>
- Exercise：<https://learn.microsoft.com/en-us/training/modules/automate-github-using-github-script/3-use-github-script>
- `actions/github-script`：<https://github.com/actions/github-script>
- Octokit REST：<https://octokit.github.io/rest.js/v22/>
- `GITHUB_TOKEN`：<https://docs.github.com/en/actions/concepts/security/github_token>
- Script injection：<https://docs.github.com/en/actions/concepts/security/script-injections>

---

### M05 - Leverage GitHub Actions to publish to GitHub Packages

#### 學習目標

- 說明 GitHub Packages 的角色，以及與 GitHub Container Registry（GHCR）的關係。
- 用 workflow 自動建置並發佈 package／container image。
- 管理 package 的 visibility、權限與版本。

#### 講解重點

- **Packages 就是與 repository 同源的 registry**：認證、權限、稽核都跟 GitHub 帳號體系整合，這是它相對外部 registry 的主要賣點。
- 支援多種 registry 類型（npm、NuGet、Maven、RubyGems、container 等）；本課 demo 通常走 **container registry（`ghcr.io`）**。
- **權限**：workflow 要推 package，需要 `permissions: packages: write`（讀取則是 `packages: read`）。這是最常見的失敗原因。
- 登入 GHCR 用 `docker/login-action`，帳號用 `${{ github.actor }}`、密碼用 `${{ secrets.GITHUB_TOKEN }}`——**再次強調不需要另外的 PAT**（除非跨 org）。
- **Image 名稱要全小寫**：`ghcr.io/<owner>/<name>`，owner 或 repo 名稱含大寫時推送會失敗。這個坑非常常見，`MoneyDemo` 這種名稱正好是活教材。
- **Visibility**：package 的 visibility 與 repository 的 visibility 是**分開**的設定，容易誤以為連動。
- 可延伸提到 **artifact attestations**：為發佈的 image 產生來源證明（銜接供應鏈安全主題）。

#### Demo / Lab

- **Lab（1 題）**：發佈到 GitHub Packages registry。
- **Demo 建議**：build 一個極簡 Dockerfile 的 image，push 到 GHCR，然後到 repository 的 Packages 區塊看到它出現，再展示 pull 指令。
- **⚠️ 組織政策相依**：`MoneyDemo` 或學員所屬 org 可能限制 package 的建立、visibility 變更或刪除權限。課前要實測一次（見課前清單）。

#### 常見問題 / 坑

- 忘了 `packages: write` → `denied` / `unauthorized`。
- Image 名稱有大寫 → push 失敗。
- 推上去了卻在 UI 找不到：package 預設 visibility 為 private，且要在正確的 owner 範圍下找。
- 刪除 package 需要額外權限，課後清理要事先確認自己有沒有權限。
- **Knowledge check 陷阱**：「發佈 package 需要 PAT 嗎？」→ 同一 repo／org 情境下通常只要 `GITHUB_TOKEN` 加上正確的 `permissions:`。

#### 重要連結

- 模組：<https://learn.microsoft.com/en-us/training/modules/github-actions-packages/>
- Exercise：<https://learn.microsoft.com/en-us/training/modules/github-actions-packages/3-exercise-github-packages-docker-registry>
- Packages：<https://docs.github.com/en/packages>
- Container registry：<https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry>
- Artifact attestations：<https://docs.github.com/en/actions/concepts/security/artifact-attestations>

---

### M06 - Create and publish custom GitHub actions

#### 學習目標

- 比較 JavaScript、Docker container、composite 三種 custom action 的差異與適用情境。
- 撰寫 `action.yml` metadata：`inputs`、`outputs`、`runs`、`branding`。
- 為 action 設計版本策略，並了解發佈到 GitHub Marketplace 的前提。

#### 講解重點

- **三種 action 類型比較**（一定要給表）：

  | 類型 | 執行方式 | 可跑在哪種 runner | 適合什麼 |
  |---|---|---|---|
  | **JavaScript** | 直接在 runner 上執行 Node | Linux / Windows / macOS | 啟動快、跨平台、要呼叫 GitHub API |
  | **Docker container** | 在容器內執行 | **僅 Linux** | 需要特定作業系統相依或非 JS 的工具鏈 |
  | **Composite** | 把多個既有 step 包成一個 | 依內含 step 而定 | 純粹重用一串 step，不需要寫程式 |

- `action.yml`（或 `action.yaml`）必須放在被 `uses:` 指向的 **action 目錄根層**；
  action 可以位於 repository 子目錄。若要發佈到 GitHub Marketplace，metadata file
  才必須位於 repository 根目錄。
- Metadata 重點欄位：`inputs`（含 `required`、`default`）、`outputs`、`runs.using`、`runs.main` / `runs.steps`。
- **JavaScript action 的相依問題**：runner **不會**幫你跑 `npm install`。要嘛把 `node_modules` 一起 commit，要嘛用打包工具（如 `@vercel/ncc`）產出單一檔案再 commit。這是學員自製 action 第一次失敗的頭號原因。
- **版本策略**：用 tag／release 發版；使用者端則建議 pin 到完整 SHA。搭配 **immutable releases** 讓已發佈版本不可被抽換。
- **Marketplace 發佈**：需要 public repository、根目錄的 `action.yml`、以及符合 Marketplace 的規範與帳戶政策。**多數課堂不需要真的發佈**——在第二個 workflow 用 `uses:` 引用自己的 action 就足以說明重用機制。

#### Demo / Lab

- **Lab（1 題）**：建立 custom JavaScript GitHub action。
- **Demo 建議**：
  1. 先做 **composite action**（最快，5 分鐘就能看到成果，不用寫 JS）。
  2. 再做 JavaScript action，重點放在 `action.yml` 與 inputs/outputs 的對應。
  3. 從另一個 repo 的 workflow `uses:` 它，示範跨 repo 重用與版本 ref 的效果。
- 這裡是回頭複習「composite action vs reusable workflow」的最佳時機。

#### 常見問題 / 坑

- `action.yml` 不在 `uses:` 指向的 action 目錄根層 → 引用時報找不到 action；
  位於 repository 子目錄本身沒有問題。
- 忘記打包／commit 相依 → `Cannot find module`。
- Docker action 想跑在 Windows runner 上 → **不支援**，只能 Linux。這是 knowledge check 常見題。
- Composite action 內部想直接用 `secrets` context → 不行，要透過 `inputs` 傳入。
- Action 的 `outputs` 沒有正確設定，導致呼叫端拿到空值。
- 在同一個 repo 內用相對路徑 `uses: ./path` 引用時，**必須先 `actions/checkout`**。

#### 重要連結

- 模組：<https://learn.microsoft.com/en-us/training/modules/create-custom-github-actions/>
- Exercise：<https://learn.microsoft.com/en-us/training/modules/create-custom-github-actions/exercise-create-custom-action>
- Action 類型：<https://docs.github.com/en/actions/concepts/workflows-and-actions/custom-actions>
- Metadata syntax：<https://docs.github.com/en/actions/reference/workflows-and-actions/metadata-syntax>
- JavaScript action：<https://docs.github.com/en/actions/tutorials/create-actions/create-a-javascript-action>
- Docker action：<https://docs.github.com/en/actions/tutorials/use-containerized-services/create-a-docker-container-action>
- Composite action：<https://docs.github.com/en/actions/tutorials/create-actions/create-a-composite-action>
- Marketplace：<https://docs.github.com/en/actions/how-tos/create-and-publish-actions/publish-in-github-marketplace>
- Immutable releases：<https://docs.github.com/en/actions/how-tos/create-and-publish-actions/using-immutable-releases-and-tags-to-manage-your-actions-releases>

---

### M07 - Manage GitHub Actions in the enterprise

#### 學習目標

- 說明組織／企業層級可用的 Actions 治理控制點（允許哪些 action、權限預設值、fork PR 行為）。
- 說明 self-hosted runner 與 runner group 的用途、安全考量與管理方式。
- 用 reusable workflow 與 workflow template 在組織內散佈標準做法。

#### 講解重點

- **本模組沒有 lab，內容偏治理與決策**。用「情境題」帶會比逐條唸設定有效：「你是一家有 200 個 repo 的公司的平台團隊，怎麼確保大家不亂用第三方 action？」
- **政策控制點**（以概念講解，**不要**逐頁點 UI，畫面因 plan 與角色而異）：
  - 是否啟用 Actions、允許哪些 action（全部／僅 GitHub 建立／允許清單）。
  - `GITHUB_TOKEN` 的預設權限（建議 read-only 起手）。
  - Fork PR 的 workflow 是否需要核准。
- **Self-hosted runner 的安全紅線**：**絕對不要**把 self-hosted runner 掛在接受不信任 fork PR 的 public repository 上——外部 PR 可在你的機器上執行任意程式碼。這句話務必講出來。
- **Runner groups** 用來限制「哪些 repository／組織可以用哪些 runner」，是企業情境的關鍵控制點。
- **Registration token 是短效的**：現場註冊 runner 時，token 取得後要儘快使用，過期就要重新產生（demo 前才取，不要提早截圖到投影片裡）。
- **Reusable workflow + required workflow 的治理價值**：中央維護一份 CI 標準，各 repo 引用，改一次全面生效——對照 starter workflow 的「複製後不同步」。
- **成本與用量觀念**：GitHub-hosted runner 依 plan 有一定額度，超出後依用量計費；self-hosted runner 不計 Actions 分鐘數，但**機器、維運與安全成本轉嫁給你**。**不要在課堂上報具體價格或免費額度數字**——請學員以官方 billing 頁面為準。

#### Demo / Lab

- **本模組沒有練習（0 題）。這是課程設計，不要自行發明一個 lab。**
- **建議 demo（依講師實際權限調整）**：
  1. 展示 organization 的 Actions 設定頁（allowed actions、預設 token 權限）——**前提是講師在該 org 有足夠角色，課前先確認**。
  2. 展示 runner group 的概念（若無權限，改用架構圖說明）。
  3. **Self-hosted runner demo（可選）**：[`../TERRAFORM/`](../TERRAFORM/) 備援 stack 會建立 Windows VM + IIS 作為 runner 主機。**Stack 不會安裝或註冊 runner**，註冊由講師手動完成；**AI agent 不得執行 `terraform apply`**。細節見 [demo-environment.md](demo-environment.md)。
  4. 展示一個 reusable workflow 被另一個 repo 呼叫。
- **控場提醒**：這是全天最後一個模組，學員已經累了。用 15–20 分鐘講治理觀念，剩下時間給認證指引與 Q&A，比硬撐 40 分鐘 UI 導覽好。

#### 常見問題 / 坑

- **⚠️ 權限相依**：許多 enterprise 設定需要 org owner 或 enterprise admin。講師若沒有該角色，畫面會不同或不可見——**課前務必實測一次**，不要在課堂上才發現點不進去。
- 學員以為 self-hosted runner「比較便宜」——要平衡說明維運與安全成本。
- 以為 self-hosted runner 每次都是乾淨環境——**不是**，狀態會殘留，需要自行清理。
- 混淆 starter workflow 與 reusable workflow（回頭引用核心觀念的表格）。
- 以為停用 org 的 Actions 會刪掉既有 workflow 檔——不會，只是不再執行。

#### 重要連結

- 模組：<https://learn.microsoft.com/en-us/training/modules/manage-github-actions-enterprise/>
- Org 政策：<https://docs.github.com/en/organizations/managing-organization-settings/disabling-or-limiting-github-actions-for-your-organization>
- Self-hosted runners：<https://docs.github.com/en/actions/concepts/runners/self-hosted-runners>
- 新增 runner：<https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners>
- Runner groups：<https://docs.github.com/en/actions/concepts/runners/runner-groups>
- Larger runners：<https://docs.github.com/en/actions/concepts/runners/larger-runners>
- Reusable workflows：<https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows>
- Workflow templates：<https://docs.github.com/en/actions/how-tos/reuse-automations/create-workflow-templates>
- Secure use：<https://docs.github.com/en/actions/reference/security/secure-use#using-third-party-actions>

---

## 預期學員問題 Q&A

**Q：這門課上完就能考過認證嗎？課程範圍等於考試範圍嗎？**
A：不等於。課程是 7 個模組的一天課程，認證考試有自己的 skills measured 清單。課程涵蓋核心主題，但考試可能包含課程未深入的細節。請以 study guide 為準備考依據：<https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-200>。**另外提醒：exam objectives 在 2026 年 1 月大幅改寫，網路上舊的備考整理不要照用。**

**Q：Achievement Code、certification、Applied Skills 有什麼差別？**
A：**Achievement Code** 是完成這門 instructor-led course 的完課憑證，由課程流程提供。**Certification** 是需要另外報名、通過考試才取得的正式認證。**本課程沒有對應的 Applied Skills credential**。

**Q：Actions 是免費的嗎？分鐘數怎麼算？**
A：GitHub-hosted runner 依帳戶 plan 有內含額度，超出後依用量計費，且不同作業系統的分鐘數換算倍率不同。**課堂上不提供具體數字**，請以官方 billing 文件與你自己帳戶的 billing 頁面為準（數字會變動，講錯會誤導預算決策）。Public repository 與 self-hosted runner 的計費方式與 private repository 不同。

**Q：secret 存進去之後，別人（或我自己）看得到嗎？**
A：建立後**無法讀回原值**，只能覆寫或刪除。Log 中會被遮蔽，但**遮蔽不等於安全**——若在 script 中對 secret 做編碼、拆解再輸出，可能繞過遮蔽。另外，來自 fork 的 pull request workflow **拿不到** secret，這是刻意的安全設計。

**Q：用 self-hosted runner 可以省錢嗎？**
A：可以省 Actions 分鐘數的費用，但你要自己負擔機器成本、作業系統與工具維護、修補與安全隔離。**安全風險是最大的隱藏成本**：self-hosted runner 絕不能用在會執行不信任 fork PR 的 public repository。實務上多數團隊採用 self-hosted 是為了**存取內網或特殊硬體**，不是單純為了省錢。

**Q：什麼時候用 reusable workflow、什麼時候用 composite action？**
A：要重用「一串 step」（可以塞進任何 job 裡）→ **composite action**。要重用「整個流程／多個 job」，含 job 之間的相依與環境設定 → **reusable workflow**。只是想給團隊一個可複製的起手式範本 → **starter workflow**（複製之後就與來源脫鉤）。

**Q：為什麼要用 OIDC？我用 secret 存憑證不是也能部署？**
A：可以，但那是**長期憑證**：需要輪替、可能外洩、洩漏後有效期長。OIDC 讓 workflow 在執行時向雲端供應商換發**短期 token**，GitHub 端不需要保存任何雲端密碼。再次澄清：**OIDC 是對雲端供應商的身分聯邦，不是用來取代 `GITHUB_TOKEN` 呼叫 GitHub API 的機制**。

**Q：GitHub-hosted runner 上預裝的工具版本會變嗎？**
A：**會。** Runner 映像檔會定期更新，預裝軟體版本會變動。因此不要依賴「映像檔剛好有某個版本」，需要固定版本就用 `actions/setup-node`、`actions/setup-dotnet` 這類 action 明確指定，並把版本寫進 workflow。這也是「昨天還能跑、今天壞了」的常見原因。

**Q：什麼是 immutable action release？為什麼要 pin 到 SHA？**
A：`@v4` 這種 tag 是**可以被移動的**——上游把 tag 指到新的 commit，你的 workflow 下一次執行拿到的就是不同的程式碼。Pin 到**完整 commit SHA** 可以固定實際內容。Immutable releases 則是在**發佈端**保證某個版本一旦發出就不能被覆寫。兩者搭配才是完整的供應鏈防護。

**Q：M07 為什麼沒有練習？是不是漏掉了？**
A：**不是漏掉，這個模組本來就沒有動手練習。** 它的內容是組織／企業層級的治理與決策，需要 org 或 enterprise 管理權限才能操作，不適合在學員的個人帳戶做。課堂上以講師 demo 與情境討論取代。

**Q：練習要在哪裡做？有沒有實驗室環境或 lab repository？**
A：**沒有**專屬的 lab 環境或 GH-200 lab repository。所有練習都是 Learn 模組內的 exercise unit，在**你自己的 GitHub 帳戶**完成；M03 額外需要你自己的 Azure subscription。課後這些 repo 都還在你自己帳戶下，可以繼續練習。

---

## 課前準備清單（開課前 1–2 天）

以下**全部是待執行的檢查項目**，不是已完成的紀錄。逐項實際操作，不要用「應該沒問題」帶過。

### GitHub 帳戶與權限

- [ ] 講師自己的 GitHub 帳戶可正常登入，且已設定好 2FA／備援方式（開課當天卡在登入是最糟的開場）。
- [ ] 能開啟並操作 demo organization：<https://github.com/MoneyDemo>。確認**目前實際的角色與權限**，不要假設。
- [ ] 已選定或建立本次要用的 demo repository（M01/M02 各一個可丟棄的 repo，M04 一個能開 issue 的 repo，M06 一個放 custom action 的 repo）。
- [ ] 目標 repository **與 organization 層級**都已啟用 GitHub Actions，且 allowed actions 政策不會擋掉課堂要用的 action。
- [ ] 確認 `GITHUB_TOKEN` 的預設權限設定；若組織設為 read-only，demo 的 workflow 要明確宣告 `permissions:`。
- [ ] M07：確認講師在該 org／enterprise 是否看得到 Actions 政策頁與 runner groups。**看不到就改用架構圖，不要臨場硬點。**

### Azure（M03）

- [ ] Azure subscription 可用，且講師有權限建立 App Service 與（若走 OIDC）app registration / federated credential。
- [ ] **確認學員端的 Azure 訂用帳戶狀況**（有幾位有、幾位沒有），決定 M03 是全班實作還是講師 demo。
- [ ] 已決定 demo 走 **OIDC** 還是 **service principal secret**，並把該路徑實際跑通一次。OIDC 記得 job 要有 `permissions: id-token: write`，federated credential 的 subject 要對應實際的 repo／branch／environment。
- [ ] **備援**：若現場建立失敗，[`../TERRAFORM/`](../TERRAFORM/) stack 可產出 Windows Web App（M03 部署目標）與 Windows VM + IIS（M07 self-hosted runner 主機）。**由講師本人手動執行 `terraform apply`；AI agent 一律不得執行。** 若決定使用，**要在開課前套用完成並驗證**，不要指望課堂上現套。
- [ ] 確認 sample 應用程式的 target framework 與 Web App runtime 相容。

### Secrets、variables 與身分

- [ ] Demo 用的 secrets／configuration variables 已先建立好（名稱與 demo 腳本一致），避免在課堂上邊講邊打錯字。
- [ ] 檢查投影片、瀏覽器分頁、終端機歷史紀錄中**沒有**殘留 token、密碼或 `.tfvars` 內容。
- [ ] 若要示範 PAT，準備一個**最小權限、短效期**的專用 token，課後立即撤銷。

### Packages、Marketplace、runner

- [ ] **M05**：實際 push 一次 package／image 到目標 registry，確認權限（`packages: write`）與 visibility 設定可行，並確認自己**有刪除權限**以便課後清理。
- [ ] **M06**：確認帳戶／org 的 GitHub Marketplace 發佈政策。若政策不允許，demo 只做「另一個 workflow `uses:` 自己的 action」，不做實際發佈。
- [ ] **M07（若要現場註冊 self-hosted runner）**：**registration token 是短效的，請在 demo 前才取得**，不要提早產生或截圖進投影片。同時準備好 fallback（改播事先錄好的畫面或截圖）。
- [ ] 確認 runner 主機可對外連線並能完成註冊；若需通過公司網路限制，事先測試。

### 連結、教材與行政

- [ ] **⛔ 阻斷性項目 — 課後問卷 URL**：`https://aka.ms/gh200survey` 目前會導向 Metrics That Matter 的錯誤頁面。**必須在開課前向交付單位取得／確認本場次專屬的 survey URL 並實際點開驗證。** 在確認到可用連結之前，不要在課堂上唸出或投影這個網址。README 依使用者要求保留該連結，但**課堂上要用驗證過的網址**。
- [ ] **重新驗證所有連結**：README 與本文的 Learn 模組、exercise、docs.github.com 連結**每次開課前都要重跑一次驗證**。上一場能開不代表這場能開——Microsoft Learn 與 GitHub Docs 的 URL 會改版重導。
- [ ] 逐一點開 7 個模組與各 exercise unit 連結，確認頁面存在且內容與本備課指南一致（若模組單元被改版，以模組現況為準並回頭更新本文）。
- [ ] 打開 certification 頁面與 study guide，確認 skills measured 的**最新更新日期**與內容（2026-01 改版後可能再度微調）。
- [ ] 準備 **backup 素材**：主要 demo 的成功截圖、關鍵 workflow YAML 片段（純文字，可直接貼給學員）、以及 M03／M05／M07 三個最容易失敗的 demo 的錄影或截圖流程。網路或雲端出問題時，這是唯一的救命工具。
- [ ] 確認教室網路能連 GitHub、Azure Portal 與 Microsoft Learn（部分企業網路會擋 `ghcr.io` 或 Actions 的 webhook 回呼）。
- [ ] Achievement Code 的發放流程與時間點已確認。

> **來源說明／限制：** 本備課指南依據 Microsoft Learn 的課程與模組頁面、GitHub Docs 官方文件，以及本 repo 既有的 `README.md` 與 `docs/demo-environment.md` 撰寫。`PPT/GH-200-All.pptx` 為 IRM 加密檔案（OLE 容器，`D0 CF 11 E0` 檔頭），**無法擷取投影片備忘稿**，因此本文的模組重點來自 Learn 模組單元結構而非官方 speaker notes；若官方 deck 內有額外的講解順序建議，請以 deck 為準。

---

## 講師小技巧

**時間救援**

- 進度落後時，第一個砍的是 **M03 的第 2、3 題**（改為 demo），第二個砍的是 **M07 的 UI 導覽**。**不要**砍 M01 的基礎概念——那會讓後面全部崩掉。
- 每個模組結束前留 2 分鐘做「一句話總結」，比拖到最後統一複習有效，也讓落後的學員有喘息點。
- 學員實作時間務必給**明確的截止時間**（「我們 11:30 回來」），並在剩 5 分鐘時提醒。否則永遠有人還在裝環境。

**Live demo vs 事先做好**

- **建立 workflow、觸發、看 log** → 一定要 live，這是本課的核心體驗。
- **需要等待的部分**（Azure 資源佈建、image build、runner 註冊）→ 事先準備好一份「已完成」的版本，一邊等一邊切過去講解，不要讓全班盯著進度條。
- 準備兩個瀏覽器分頁：一個是「正在做的」，一個是「已經做好的成功結果」。這個習慣能救掉大部分 demo 失敗。

**從失敗中教學**

- **故意讓一個 workflow 失敗**（YAML 縮排錯、缺 `permissions:`、忘記 `checkout`），然後從 log 一步步定位。學員課後真正會遇到的就是這些，這比看成功案例學得多。
- 教學員讀 log 的順序：先看**哪個 job**紅了 → 展開**哪個 step** → 看**錯誤訊息最上面那幾行**（不是最下面）。
- 真的 demo 掛掉時，**當成教材而不是意外**：「我們現在來看看這是什麼問題」——如果 3 分鐘內找不到原因，切到備援畫面繼續，課後再追。

**其他**

- 開場先問「誰有 Azure subscription？誰用過 GitHub Actions？」，用舉手結果決定 M03 與 M01 的節奏。
- 企業設定畫面（M07）依 plan 與角色差異大，**寧可講概念與決策原則，也不要逐頁點**。點不出來很尷尬，而且容易講出不存在的 UI 路徑。
- 遇到不確定的問題（計費數字、考試題型、某功能是否在某 plan 可用）→ **當場說「我查一下／請以官方頁面為準」**，不要臨場推測。本課的學員大多會回去照做，講錯的成本很高。

---

## 參考

| 資源 | 連結 |
|---|---|
| 課程頁面 GH-200T00-A | <https://learn.microsoft.com/en-us/training/courses/gh-200t00> |
| Learning path Part 1（M01–M04） | <https://learn.microsoft.com/en-us/training/paths/github-actions/> |
| Learning path Part 2（M05–M07） | <https://learn.microsoft.com/en-us/training/paths/github-actions-2/> |
| Study guide（**2026-01 改版**） | <https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-200> |
| GitHub Actions certification | <https://learn.microsoft.com/en-us/credentials/certifications/github-actions/> |
| 學員面向參考頁（本 repo） | [`../README.md`](../README.md) |
| Demo 環境與 Terraform 備援 | [`demo-environment.md`](demo-environment.md) |
| Demo organization | <https://github.com/MoneyDemo> |
