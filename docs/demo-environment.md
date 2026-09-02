# GH-200 Demo Environment

> 📖 **Related** — [Teaching guide](teaching-guide.md)

> **講師專用。** 本文不是學員面向的 `README.md`。學員作業在 Microsoft Learn 模組內、使用自己的 GitHub 帳戶完成；講師 demo 才使用 `MoneyDemo` organization 與（必要時）Azure 備援環境。

## Scope and purpose

**GH-200T00-A — Automate your workflow with GitHub Actions** 是一天、Intermediate、共 7 個模組的 instructor-led course。本課**沒有** MicrosoftLearning lab repository；練習題在 Learn 模組內。M03 另外需要 Azure subscription。本課**不使用** Azure AI / Foundry models；course-prep Phase 4 的 model retirement 對本環境不適用。

課堂原則是 **live-first**：

- 優先在 GitHub UI 與學員／講師自己的 repository 現場建立 workflow、secret、environment 與 package。
- Azure 資源（M03 的 Web App、M07 的 self-hosted runner 主機）也優先現場建立。
- [`../TERRAFORM/`](../TERRAFORM/README.md) 是 **fallback / backup stack**：現場建立失敗、或開課前需要可重現的 Azure 目標時，由**講師本人**套用。它只佈建 Azure infrastructure，**不會**安裝或註冊 GitHub Actions runner，也**不會**種入 demo repository、workflow 或 package。

學員與講師邊界：

| 角色 | 使用什麼 | 不要做什麼 |
|---|---|---|
| 學員 | 自己的 GitHub 帳戶；M03 用自己的 Azure subscription（若課堂有提供） | 不要把講師的 PAT、OIDC app、VM 密碼、`MoneyDemo` 的 privileged 設定當成作業答案 |
| 講師 | 自己的 GitHub 帳戶、[`MoneyDemo`](https://github.com/MoneyDemo) organization、必要時 Azure 備援 stack | 不要在學員可見的 chat／投影片貼上 secret、registration token 或 `.tfvars` |

本文描述「開課前應該準備什麼」與「目前 repo 裡已核對的 Terraform 意圖」。**未勾選的核取方塊都是講師必須實際執行的項目**，不是已經跑過的測試紀錄。

## Module-to-environment map

| 模組 | 平台／資源 | 需要的存取 | Terraform 是否有幫助 |
|---|---|---|---|
| **M01** Automate development tasks by using GitHub Actions | 個人或 organization 的 GitHub repository；GitHub Actions | 能建立 workflow 檔（`.github/workflows/`）並看到 workflow run | **否。** 只需 GitHub。 |
| **M02** Build continuous integration workflows by using GitHub Actions | 同上；CI workflow、status check、artifact | 能推送、能看 Actions tab、能下載 artifact | **否。** |
| **M03** Build and deploy applications to Azure by using GitHub Actions | GitHub repository **加上** Azure subscription 與 Windows Web App；`azure/login` + `azure/webapps-deploy` | Azure 能建立／部署 Web App；GitHub 能設 OIDC federated credential 或（僅在必要時）deployment secret | **是（備援）。** Stack 會建立 Windows App Service plan + Windows Web App，作為 deploy target。OIDC／secret 仍須講師手動設定。 |
| **M04** Automate GitHub by using GitHub Script | 可丟棄的 GitHub repository（issue／comment 即可） | `GITHUB_TOKEN` 對該 repo 有足夠的 issues／contents 權限 | **否。** |
| **M05** Leverage GitHub Actions to publish to GitHub Packages | GitHub Packages 與／或 GHCR | 該 repo／org 允許寫入 package；workflow 的 `GITHUB_TOKEN` 或專用 identity 具 `packages` 相關權限 | **否。** Terraform 不種 package。 |
| **M06** Create and publish custom GitHub actions | 用來放 custom action 的 repository；若要公開則還有 Marketplace 政策 | 能建立 action metadata／程式碼，並從另一個 workflow `uses:` 它 | **否。** |
| **M07** Manage GitHub Actions in the enterprise | GitHub organization 或 enterprise 的政策、runner groups；可選 self-hosted runner 主機 | **可能需要** org／enterprise admin。Self-hosted runner 還需要能在目標機器上完成註冊 | **部分。** Stack 只提供 Windows Server VM + public IP + Entra ID login + IIS。**不會**安裝或註冊 runner。 |

多數模組只要一個個人 GitHub repository 就能 demo。不要假設學員能看到 `MoneyDemo` 的內部設定。

## GitHub prerequisites

開課前由講師確認（下列皆為檢查項目，**不是**已驗證的 org 現況）：

- [ ] 講師與學員都有可用的 GitHub 帳戶。
- [ ] 講師能開啟 [MoneyDemo](https://github.com/MoneyDemo)。實際角色／team 權限以 org 設定為準，本文不臆測。
- [ ] **Demo repository 策略：** 在 `MoneyDemo` 或講師帳戶**選用或準備一個合適的 repository**。本環境文件**不指定**尚未核對過的 repo 名稱；不要為了備課去猜 `MoneyDemo` 裡現成的 repo。
- [ ] 該 repository（以及如需 org 層級政策）已啟用 GitHub Actions。
- [ ] Workflow 需要的 permissions 足夠：預設 `GITHUB_TOKEN`、必要時的 environment、branch protection。採 least privilege，不要為了省事開 `write-all`。
- [ ] 若要示範 reusable workflow 或 workflow templates：確認所選 repository／org **允許** `uses: <owner>/<repo>/.github/workflows/...` 的來源，且呼叫端有讀取權。未核對前不要宣稱 org 已有現成 template。
- [ ] M05：確認 GitHub Packages 與 GHCR 對該 identity 可推送；注意 package visibility（internal／private／public）與刪除權限。
- [ ] M06：若示範發布到 GitHub Marketplace，先讀該帳戶／org 的 Marketplace 政策；多數課堂只需在第二個 workflow 引用尚未公開的 custom action。

Actions 必須在目標 repo 可用。Fork 來的 public repository 若接受不信任的 pull request，**不要**把 self-hosted runner 掛上去（見 M07）。

## Azure prerequisites for M03

M03 的現場目標是「GitHub Actions 把應用程式部署到 Azure Web App」。需要：

- [ ] 有效的 Azure subscription，講師能建立 App Service（或使用下方 Terraform 備援產出的 Web App）。
- [ ] 一個 Windows Web App 作為 `azure/webapps-deploy` 的 target。備援 stack 的 Web App 使用 .NET 8；部署前確認課程 sample 的 target framework 與 App Service runtime 相容。
- [ ] **優先使用 OIDC**（workload identity federation），讓 workflow 不必長期存放 Azure client secret。
- [ ] 僅在 OIDC 無法及時完成時，才退回 `azure/login` 的 secret-based 登入。Secret 放在 GitHub Actions secrets 或 environment secrets，**不要**寫進 workflow YAML，也不要出現在投影片。

官方入口：

- [`Azure/login`](https://github.com/Azure/login)
- [`Azure/webapps-deploy`](https://github.com/Azure/webapps-deploy)
- [Use OpenID Connect (OIDC) in Azure](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
- [Connect GitHub Actions to Azure with OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)

本文不記載 subscription ID、tenant ID、App registration ID 或 federated credential subject。那些值只存在講師自己的 Azure／GitHub 設定中。

## Terraform fallback environment

操作細節以 [`../TERRAFORM/README.md`](../TERRAFORM/README.md) 為準。以下是講師備課需要的摘要，對應目前 repo 裡的 `TERRAFORM/MAIN.tf`、`MOD.tf`、`OUTPUT.tf`。

### 資源

| Azure 資源 | 名稱模式（`local.resource_suffix` = `<group_postfix>-ksh`） | 課程用途 |
|---|---|---|
| Resource group | `GH200-<group_postfix>` | 整個 backup stack 的容器 |
| Virtual network / subnet | `lab-vnet-<group_postfix>-ksh` / `default` | VM 網路 |
| Public IP（Standard、Static） | `lab-pip-<group_postfix>-ksh` | VM 的 public IP |
| Network interface | `lab-nic-<group_postfix>-ksh` | 接到 VM |
| Windows Server 2022 VM（`Standard_B4ms`） | `lab-vm-<group_postfix>-ksh` | **M07** self-hosted runner **主機**（尚未安裝 runner） |
| `AADLoginForWindows` extension | `lab-aad-<group_postfix>-ksh` | Microsoft Entra ID 登入 VM |
| Custom Script extension（安裝 IIS） | `lab-script-<group_postfix>-ksh` | 在 VM 上放一個簡單的 IIS 頁面 |
| Windows App Service plan（`S1`） | `lab-app-plan-<group_postfix>-ksh` | **M03** Web App 的 plan |
| Windows Web App（.NET 8） | `gh200-web-<group_postfix>-ksh` | **M03** `azure/webapps-deploy` target |

Region 固定為 `japaneast`（`local.location`，不是變數）。

### 變數與命名

| 變數 | 必填 | 預設 | 說明 |
|---|:---:|---|---|
| `group_postfix` | 是 | 無 | 1–10 個小寫英數字；resource group 為 `GH200-<group_postfix>` |
| `user_name` | 否 | `demouser` | VM local administrator |
| `user_password` | 是 | **無** | Sensitive；必須在執行時提供 |

**不要**把密碼寫進 `.tf`、commit、chat 或本文。建議：

```powershell
$securePassword = Read-Host "Enter the VM administrator password" -AsSecureString
$env:TF_VAR_user_password = [System.Net.NetworkCredential]::new("", $securePassword).Password
```

或使用本機 `.tfvars`（此 repo 的 `.gitignore` 已忽略 `*.tfvars`／`*.tfvars.json`，不要 commit）。不要在命令列用 `-var "user_password=..."`，以免進入 shell history。

### 講師手動操作

在 `TERRAFORM/`：

```powershell
cd TERRAFORM
terraform init
terraform plan -var "group_postfix=<your-postfix>"
```

檢查 plan 之後，**只有講師**可以套用：

```powershell
terraform apply -var "group_postfix=<your-postfix>"
terraform output
```

課後：

```powershell
terraform destroy -var "group_postfix=<your-postfix>"
Remove-Item Env:\TF_VAR_user_password
```

> [!CAUTION]
> **AI agent 禁止執行 `terraform apply`。** Agent 可協助閱讀 configuration、
> `fmt`／`init`／`validate`／`plan`。`terraform destroy` 雖未被基礎規範禁止，但屬破壞性操作，
> 必須由使用者明確要求並再次確認；本課程的正常流程由講師本人執行 apply／destroy。

### 此 stack 做不到的事

- **不會**在 VM 上安裝 GitHub Actions runner，也**不會**向 GitHub 註冊 runner。
- **不會**建立 demo GitHub repository、workflow、secret、package 或 custom action。
- **沒有** application data plane；Web App 在首次部署前是空的 runtime。
- **沒有** Network Security Group 或 inbound rule。Public IP 已掛在 NIC 上，但 RDP／IIS 連線需要講師另外用限制來源 IP 的規則（若課堂需要連進去）。
- **沒有**自動清理；課後只能講師對**這個** stack 做 `terraform destroy`，或刪除 `terraform output` 指出的那個 resource group。禁止用顯示名稱或萬用字元掃整個 subscription。

## Self-hosted runner demo (M07)

Terraform 只給你一台 Windows VM。Runner 註冊永遠是課堂上的手動、短生命週期程序。

建議流程（每一步都由講師執行，且不要把 token 貼進聊天或 repo）：

1. 確認 VM 已存在且你能登入（Entra ID login 或 local admin）。本文不記載連線指令的成功紀錄。
2. 在 GitHub 的 repository 或 organization runner 頁面，**即將 demo 前**才建立 registration token。Token 是短效的；過期就重開，不要預先產好放著。
3. 在 VM 上依官方文件下載並設定 runner，註冊到 **repository 或 organization**（課堂範圍用哪個層級，選最小足夠的那個）。
4. 加上可辨識的 label（例如只給這堂課用的 label），workflow 用 `runs-on:` 對準該 label，避免誤用到別的 runner。
5. 跑一個**最小** workflow（例如 `echo` 或 `hostname`）證明 runner 有接 job。
6. **下課後立刻移除 runner 註冊**，並在 GitHub UI 確認狀態為 offline／removed。不要把長駐、已登入的 runner 留在共用 tenant。

安全（必須遵守）：

- **不要**讓 self-hosted runner 處理不信任的 fork pull request。Runner 程序在你的機器上跑，惡意 workflow 等於在該 VM 執行程式。
- 保持機器乾淨／可重建：demo 結束就移除 runner；下一堂課重新註冊。不要在這台機器上存 PAT、課程以外的密鑰或學員作業。
- Least privilege：註冊在 repo 層級優於 org，org 優於 enterprise（除非你真的在教 enterprise runner group）。
- 官方文件：
  - [Adding self-hosted runners](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)
  - [Self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)
  - [Runner groups](https://docs.github.com/en/actions/concepts/runners/runner-groups)

## Demo identity, secrets, and trust boundaries

課堂上會同時出現三種身份，不要混用：

| 身份 | 適用 | 不要用來 |
|---|---|---|
| `GITHUB_TOKEN` | 同一個 repository 的 workflow（checkout、issue comment、推 package 到同 repo 等） | 跨 repo、跨 Azure、或任何需要你個人帳號的操作 |
| Fine-grained 或 classic PAT | 極少數 `GITHUB_TOKEN` 不夠的講師操作 | 寫進 YAML、commit、或給 self-hosted runner 當長期登入 |
| Azure OIDC（建議） | M03 部署 | 與 GitHub secret 混成兩套都長期有效的後門 |

原則：

- Least privilege：workflow `permissions:` 只開用到的 scope；Azure 端 federated credential 限制到特定 repo／environment。
- 把 Azure 與 production-like 部署放到 GitHub **environment**，加上 protection rules（必要的 reviewer、限制分支）。課堂 demo 也走同一條路，避免「只在 repo secret 放萬能金鑰」。
- **永遠不要** `echo` secret、把 secret 寫進 artifact、或在 `run:` 裡把 secret 拼進可被 log 的命令。
- **不要**把不信任的 PR title、issue body、branch 名稱直接插進 `run:` script（expression injection）。用 env 傳遞並加引號，或避免在 shell 展開。
- 官方文件：
  - [`GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)
  - [Using secrets in GitHub Actions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
  - [Script injection](https://docs.github.com/en/actions/concepts/security/script-injections)

講師的 VM 密碼、Azure 登入與 GitHub PAT 都在講師信任邊界內。學員練習必須使用學員自己的身份。

## Pre-class smoke test

以下是**開課前講師檢查清單**。方塊未勾選代表「你必須去做」；本文**不宣稱**這些項目已經執行或通過。

GitHub：

- [ ] `gh auth status`（或瀏覽器登入）顯示講師身份可用，且能開啟 [MoneyDemo](https://github.com/MoneyDemo)。
- [ ] 選用的 demo repository 已啟用 Actions；沒有 org policy 把 workflow 全部擋住。
- [ ] 在**可丟棄**的 repo 跑一個最小 workflow（`workflow_dispatch` 或 push），run 為 success。
- [ ] 同一個（或另一個可丟棄）workflow 上傳 artifact，並能從 UI 下載。
- [ ] 需要教 cache 時，確認 `actions/cache`（或等價）有寫入／命中；沒教就跳過。
- [ ] M04：在可丟棄 repo 用 GitHub Script 留一則 issue comment，再刪掉該 issue 或整個 repo。
- [ ] M05：能把一個測試 image／package 推到 GHCR 或 GitHub Packages（名稱自訂，課後刪除）。不要推到共用的 production package。
- [ ] M06：custom action 能被另一個 workflow `uses:`（local path 或同一 org 的 repo）。不必實際上架 Marketplace。

Azure／M03：

- [ ] OIDC：`azure/login` 在目標 repo 成功（優先）。若尚未設好 federation，才用 secret-based login 作為暫時退路。
- [ ] `azure/webapps-deploy` 能部署到預定的 Web App；瀏覽 `terraform output web_app_url`（或現場建立的 hostname）看得到你部署的內容，而不是預設空頁就算「有資源」。

M07 runner：

- [ ] 若本堂要 demo self-hosted runner：機器在線、runner 在 GitHub UI 顯示 Idle／Online，最小 workflow 有被該 runner 接走。
- [ ] 已想好下課後如何把 runner 從 GitHub 移除，以及 VM 要 destroy 還是關機。

Terraform（本機、非 apply）：

- [ ] `terraform fmt -check`、`terraform init`、`terraform validate` 在 `TERRAFORM/` 成功。
- [ ] `terraform plan -var "group_postfix=<your-postfix>"` 在已 `az login` 的前提下可產生 plan。**到此為止。**
- [ ] 若講師決定使用備援環境，由講師本人 `terraform apply`，再用 `terraform output` 核對 resource group、VM public IP、Web App URL。

清理計畫：

- [ ] 已決定哪些 GitHub repo／package／runner 是一次性的、哪些 `MoneyDemo` 資產要保留。
- [ ] 已決定 Azure 是 `terraform destroy` 還是只刪 `terraform output` 列出的那一個 resource group。

## Cleanup

只刪**已確認身份**的資源。禁止用顯示名稱、前綴或萬用字元對共用 subscription／org 做破壞性清理。

Terraform stack 若曾 apply，預期會有（名稱隨 `group_postfix` 與固定 `ksh` 後綴）：

- Resource group `GH200-<group_postfix>` 及其內的 VNet、subnet、public IP、NIC、Windows VM、兩個 VM extension、App Service plan、Windows Web App。

講師應用 `terraform destroy -var "group_postfix=<同一組 postfix>"` 拆除**這個** stack。若 destroy 失敗，再以 `terraform output resource_group_name` 的**精確名稱**在 Azure Portal／CLI 刪除該 resource group——不是搜尋所有叫 `GH200-*` 的群組。

GitHub 側（僅限本堂建立、且不屬於共用教材的物件）：

- [ ] 從 repository 或 organization 移除本堂註冊的 self-hosted runner（用 runner 的 id／名稱在 UI 或 API 對準，不要 `Remove-Item` 式的名稱猜測）。
- [ ] 刪除本堂推送的測試 package／GHCR tag（對準 package 名稱，不要清整個 org 的 Packages）。
- [ ] 刪除可丟棄 demo repo、測試 issue、一次性 environment secret。
- [ ] **保留**共用的 `MoneyDemo` organization、以及其他課程仍在用的 repository 與政策。

VM 本機若曾放下 runner 資料夾或 PAT，登出前一併刪除；不要把 token 留在磁碟。

## Known limitations

- **AI 沒有、也不得做 live `terraform apply` 驗證。** 本文對 Azure 資源的描述來自目前工作樹中的 Terraform 與 `TERRAFORM/README.md`，不是一次成功套用後的現場輸出。
- 課程 PPT 若存在，屬 IRM 保護教材，與本 demo 環境無關；不要把投影片裡的截圖當成可登入的端點。
- 本課沒有 Azure AI／Foundry model lifecycle 要維護。
- 本 repo **不種入** GitHub repository、workflow、secret、package 或 runner。GitHub 側一切都是講師即時準備。
- Terraform **不**註冊 GitHub runner，也沒有 NSG。連進 VM 或給 runner 出站／入站，都是講師額外的責任。
- GH-200 **沒有** MicrosoftLearning lab repository 可 fork；學員練習以 Learn 模組為準。
- `MoneyDemo` 內現成 repo 清單未經本文件核對，故不列出名稱。

## References

- 課程頁：[GH-200T00](https://learn.microsoft.com/en-us/training/courses/gh-200t00)
- Path 1（M01–M04）：[Automate your workflow with GitHub Actions](https://learn.microsoft.com/en-us/training/paths/github-actions/)
- Path 2（M05–M07）：[Automate your workflow with GitHub Actions — part 2](https://learn.microsoft.com/en-us/training/paths/github-actions-2/)
- 講師教學：[Teaching guide](teaching-guide.md)
- Terraform 備援：[TERRAFORM/README.md](../TERRAFORM/README.md)
- Demo organization：[MoneyDemo](https://github.com/MoneyDemo)
- [`Azure/login`](https://github.com/Azure/login)
- [`Azure/webapps-deploy`](https://github.com/Azure/webapps-deploy)
- [OIDC in Azure (GitHub Docs)](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
- [Connect from Azure with OpenID Connect (Microsoft Learn)](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [Adding self-hosted runners](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)
- [Self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)
- [Runner groups](https://docs.github.com/en/actions/concepts/runners/runner-groups)
- [`GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)
- [Using secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
- [Script injection](https://docs.github.com/en/actions/concepts/security/script-injections)
