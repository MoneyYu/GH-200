# GH-200 Demo Environment

> 📖 **Related** — [Teaching guide](teaching-guide.md)

> **講師專用。** 本文描述 2026-09-03 客製場的 demo 環境與信任邊界；學員面向資料是 `README.md`，不要在學員可見處貼上 secret、private key、registration token、`.tfvars` 或 Azure 識別碼。

## Scope and purpose

本場主線是 class repo <https://github.com/MoneyDemo/20260903-GH200> 的 Java Spring Boot 4.1.1 / Java 21 / Maven 應用程式。它使用 Maven Wrapper，產出 `target/simpleweb.jar`，所以學生不必安裝 Maven。`/`、`/api/info`、`/actuator/health` 是驗證端點；首頁顯示 environment、build SHA、hostname，供講師辨識實際部署版本。

本場的 customer module map 是 M1、M2、**M3（本次不授課）**、M4、M5。這不等同官方 7 個 Learn 模組，且不教 Reusable Workflows、Matrix Strategy 或 custom action authoring。

## Linux VM deployment target

| 項目 | 場次設定／用途 |
|---|---|
| OS | Azure Ubuntu 24.04 Linux VM，模擬 on-prem application server |
| 測試服務 | systemd `simpleweb-test`，port `8080` |
| 正式服務 | systemd `simpleweb-prod`，port `8081` |
| GitHub Environments | `test` 與 `production` |
| Production 保護 | `production` 有 required-reviewer approval gate；這是預期等待狀態，不是 workflow failure。 |
| 主要部署方式（04-06） | SSH：Build → Test → Package → SCP → SSH → `systemctl` → 語意化 `/api/info` SHA smoke test；需要開放 inbound TCP/22 並在 GitHub 保存長期 private key，主機指紋釘選在 `VM_SSH_HOST_KEY`。 |
| 對照方式（07） | Linux App Service + Azure OIDC：短期 token、無需開放連接埠或保存長期 Azure 密碼，是 PaaS/OIDC 對照，不是 VM 部署路徑。 |
| M4 對照（08） | self-hosted runner 與 SSH 部署目標同一台 VM，屬課堂簡化；這條路徑本身不需要 inbound SSH，只在受信任 workflow 執行，且不可讓不信任 fork PR 使用。 |

Progressive workflow 是 `01.build` → `02.build-test` → `03.package-artifact` →
`04.deploy-test` → `05.deploy-prod` → `06.full-pipeline`。`07.deploy-webapp`、
`08.selfhosted-runner`、`09.troubleshooting` 是對照／診斷材料，而不是主線的替代方案：
`07` 是 Azure OIDC/PaaS 對照，`08` 是同一台 VM 上的 self-hosted runner 對照。

### 2026-09-03 班級 repo 已部署環境（pre-refactor 歷史紀錄）

> **這是 pre-refactor 歷史證據，不是目前的教學路徑。** 下表的 run 都在 class repo
> SSH-only 對齊（見下方「MoneyYu/GH-200 self-contained workflows」與
> `07.deploy-webapp`／`08.selfhosted-runner` 現行編號）**之前**完成，當時 class repo 自己的
> `04` 走 Azure OIDC + `az vm run-command`、`07` 才是 SSH 對照。這些 run 只證明「該次交付
> 曾經成功 apply／執行過」，**不能**當作目前 SSH-only `04`-`06`、`07.deploy-webapp`（App
> Service/OIDC 對照）或 `08.selfhosted-runner`（same-VM 對照）已經 live 驗證成功；也不要
> 誤讀成當時的 run 使用 SSH——它們用的是 Run Command／digest transport。

| 項目 | 實際值／驗證（pre-refactor） |
|---|---|
| Resource group | `GH200-0903` |
| Linux VM | `lab-linux-0903-ksh`（OpenJDK `21.0.12`） |
| Test | <http://20.210.89.243:8080> |
| Production | <http://20.210.89.243:8081> |
| OIDC test deployment | [Run 33673846495](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33673846495) — immutable per-SHA asset、Run Command sentinel、digest、build SHA 全部驗證 |
| Production approval | [Run 33673569379](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33673569379) 曾進入 `waiting`，核准後只 promote 指定 SHA |
| Full pipeline | [Run 33673131527](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33673131527) — Build / Test / Package / digest / test / approval / production 全部成功 |
| SSH deployment | [Run 33659763233](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33659763233) — class repo 當時獨立的 `07` SSH 風險對照，非現行 `04`-`06` SSH-only 主線 |
| Ephemeral self-hosted runner | [Run 33660507745](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33660507745)；完成後 runner 自動解除 |
| Troubleshooting failure | [Run 33660678534](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33660678534) — 故意失敗的教材 |

以上 run 都來自 public class repo `MoneyDemo/20260903-GH200`，記錄該次交付當時已完成的
pre-refactor 歷史 run；它與下方 `MoneyYu/GH-200` self-contained workflows 目前採用的
SSH-only 機制是兩套獨立設定，不代表 `MoneyYu/GH-200` 現在也使用 Run Command 或 digest
transport。class repo 自身的 `04`-`06`／`07`／`08` 編號已在後續對齊工作中改為與
`MoneyYu/GH-200` 相同的 SSH-only／OIDC-webapp／same-VM-runner 主線設計（見下一節），但
**尚未有該次對齊後的 live workflow run**——目前只完成程式碼與 Terraform 的靜態驗證。

### MoneyYu/GH-200 self-contained workflows

GH-200 自己是 private repo，因此 `demo-java-04`/`05`/`06` 不使用匿名 GitHub Release，
也**不再**使用 Azure Run Command、Blob artifact transport 或 VM managed-identity/IMDS
下載。目前作法改為 **SSH-only**：

1. GitHub-hosted runner 建置、測試並打包 jar 為 `actions/upload-artifact` workflow
   artifact（不上傳到 Azure）。
2. `demo-java-04-deploy-test` 用 repository secret `VM_SSH_PRIVATE_KEY` 建立僅本次 run
   使用的 SSH 身分，並以 repository variable `VM_SSH_HOST_KEY`（完整 OpenSSH
   `known_hosts` 格式，不是 `SHA256:` 指紋）做 `StrictHostKeyChecking=yes` 的主機指紋
   釘選；**不使用** `ssh-keyscan` 或任何 per-run TOFU（trust-on-first-use）。
3. `scp` 把 jar 複製到 VM，再用 SSH 執行 `sudo install` 與
   `systemctl restart simpleweb-test`／`simpleweb-prod`，最後對 `/api/info` 做語意化
   smoke test，比對 build SHA 而不是只看 HTTP 200。
4. `demo-java-05-deploy-prod` 不重新 build，而是下載 `04` 針對同一 commit SHA 成功的
   artifact，經 `confirm=deploy` 與完整 40 字元 SHA 的人工輸入確認後 promote 到
   production；`demo-java-06-full-pipeline` 則是 build once、把同一份 artifact 串接部署
   到 test 與 production 的完整流程 demo。

目前已配置的 GitHub 設定：

| 項目 | 值／用途 |
|---|---|
| Repository secret | `VM_SSH_PRIVATE_KEY`（deploy 用 SSH private key；`04`/`05`/`06` 都會用到，因此設在
  repository 層級，或需要在 `test` 與 `production` 兩個 Environment 各設一份） |
| Repository variable | `VM_PUBLIC_IP` |
| Repository variable | `VM_SSH_USER=azureuser` |
| Repository variable | `VM_SSH_HOST_KEY`（完整 OpenSSH `known_hosts` 行；於受信任網路下設定/擷取，VM host key
  輪替後須手動更新，不可用 `SHA256:` 指紋代替） |

這個作法的代價是需要對 VM 開放 inbound TCP/22，並在 GitHub 保存一把長期存在的 private
key；`demo-java-07-deploy-webapp` 走 Azure OIDC 部署到 Linux App Service，不需要開放
連接埠或保存長期 Azure 密碼，可用來對照兩種部署方式的風險與維運差異，但它是 PaaS/OIDC
對照，不是取代 VM 的部署路徑。

Storage account `gh200state0903ksh` 之前的 `deployments` container（Blob artifact
transport 遺留資源）目前**不受 Terraform 管理，也未刪除**；本文與 Terraform 都不指示
清除它，如需處理由講師/使用者另行決定。

MoneyYu organization 的方案不支援 Environment required reviewers（API 回傳 HTTP 422）。
因此 GH-200 的 `demo-java-06-full-pipeline` 只允許手動觸發，且要求
`confirm_production=deploy`；這是避免誤觸的確認，不是 separation of duties。要展示
真正的 reviewer gate，使用上表的 MoneyDemo class repo。

### Azure OIDC federated credential

OIDC 建立 GitHub Actions 與 **Azure** 的 workload identity federation；它不取代用於 GitHub API 的 `GITHUB_TOKEN`。講師在 Azure 端為 class repo 的實際觸發條件建立 federated credential，subject 必須精準限制於使用的 repository、branch 或 GitHub Environment；workflow job 必須宣告最小必要的 `permissions:`，包括 `id-token: write`。

- 設定順序：先準備具有最小 Azure RBAC 的 Azure workload identity，再建立 GitHub OIDC federated credential，接著在對應 GitHub Environment 設定 workflow 所需的非敏感識別值／secret，最後以實際 workflow 觸發條件測試 `azure/login` 與其後的 Azure 動作。**現行對齊後**，`MoneyYu/GH-200` 與 `MoneyDemo/20260903-GH200` 的 `07.deploy-webapp`／`demo-java-07-deploy-webapp` 都部署到 Azure Linux App Service，兩者都不涉及 `az vm run-command`；`az vm run-command` 只出現在 class repo **pre-refactor**（重構前）的歷史 run（見上方「2026-09-03 班級 repo 已部署環境」表），不是目前的 `07`。兩個 repo 的 `04`-`06` 都完全不使用 OIDC，改用 SSH。
- 建立 credential 時，以「該 repo」和 `test`／`production` 的實際部署條件為準；`MoneyYu/GH-200` 與 `MoneyDemo/20260903-GH200` 是兩個獨立 repo，**各自需要專屬的 federated credential**，不要複製另一個 repo、branch 或 environment 的 subject（詳見下方「Azure RBAC for the 07 OIDC identity」）。
- 不把 Azure client secret 寫入 workflow 或交給學員。
- Azure RBAC 只授與部署所需的最小權限。
- 所需的 subscription ID、tenant ID、client ID、federated credential subject 和 Environment secrets/variables 只存在講師已核對的設定，本文不記載其值。
- OIDC login 失敗時，先檢查 `id-token: write`、subject、audience 與 Azure RBAC；不得為了示範而繞過 environment gate 或印出 credential。
- 本場 GitHub OIDC assertion 使用含 organization/repository **stable ID** 的 subject
  格式。若出現 `AADSTS700213`，以 workflow log 顯示的 presented assertion subject
  為準更新 federated credential，不要假設傳統的純 `owner/repo` 格式。
- 共享 subscription 可能由外部排程 deallocate VM。使用 Run Command 的 class repo
  **pre-refactor** workflows（重構前的歷史版本）已在 Run Command 前執行 `az vm start`；
  現行對齊後的兩個 repo 都不再有任何 Run Command workflow。`MoneyYu/GH-200` 的 SSH-only
  `04`/`05`/`06` **沒有** Azure CLI 登入步驟，也不會自動啟動 VM——VM 電源狀態或
  TCP/22 未就緒時，SSH 連線步驟會快速失敗並提示「請確認 VM 已啟動」。**必須由講師
  在課前用 Azure CLI 啟動該 VM**，workflow 本身不會、也不應該負責開機。若看到
  `OperationNotAllowed` 要先查 power state，不要重跑 Terraform。

### Azure RBAC for the `07` OIDC identity（每個 repo 各自一組，不共用）

`07.deploy-webapp`／`demo-java-07-deploy-webapp` 只部署到 Linux App Service，不觸碰 VM
或 Blob，因此只需要 Azure 內建角色 **Website Contributor**，且範圍應精準指定到那個
Linux Web App 資源本身（例如 `gh200-java-web-0903-ksh`），不是整個 resource group，也
不是 subscription；`Website Contributor` 本來就能在資源層級指派，不需要更寬的範圍。

`MoneyYu/GH-200` 與 `MoneyDemo/20260903-GH200` 是兩個獨立 repo，**各自需要一組專屬的
federated credential／Azure identity**：

- 每個 repo 的 federated credential subject 都必須對應「那個 repo 自己」實際觸發 `07`
  的條件（通常是該 repo 的 `test` Environment）；上方已說明本場採 organization/repository
  **stable ID** 格式，實際 subject 一律以該 repo 的 workflow log 顯示的 presented
  assertion subject 為準，不要假設傳統 `owner/repo` 格式，也不要把一個 repo 核對過的
  subject 原樣套用到另一個 repo。
- **不要沿用 SSH-only 重構之前那組給 VM／Blob 存取用的共用 identity 或其角色指派。**
  那組身分是為了 Run Command（VM 存取）與 Blob artifact transport（Blob 存取）設計的，
  範圍與資料類型都與現在 `07` 需要的「只管理一個 Web App」不同；繼續共用等於讓兩個
  repo 的部署身分持有超出實際需要的 VM／Blob 權限，違反最小權限，也讓兩個 repo 的
  Azure 存取邊界糾纏在一起。
- 兩個 repo 的 `07`／`demo-java-07-deploy-webapp` 現在改用專屬的 GitHub secret
  `AZURE_WEBAPP_CLIENT_ID` 提供 client ID 給 `azure/login`，代表**這個 Web App 專用**的
  federated identity，不再沿用舊有的 `AZURE_CLIENT_ID`。舊的 `AZURE_CLIENT_ID` 目前
  **維持不動**，因為還有其他 VM／Blob 相關的既有使用者依賴它；等那些舊使用者全部
  除役後才會處理 `AZURE_CLIENT_ID` 本身，本次變更範圍不含這件事。tenant ID／
  subscription ID 仍沿用既有的 Environment secret 名稱，不受影響。

### Terraform outputs → GitHub variables（兩個 repo 都要各設一次）

`terraform apply` 完成後，用 Terraform **非機密** outputs（不含任何私鑰或 host key）
分別設定 `MoneyYu/GH-200` 與 `MoneyDemo/20260903-GH200` 兩個 repo 各自的 repository
variable；兩個 repo 各有自己的 Environments 與部署身分，因此要各設一次，不是共用一份：

```powershell
cd TERRAFORM
$vmIp       = terraform output -raw linux_vm_public_ip
$webAppName = terraform output -raw web_app_name
$webAppUrl  = terraform output -raw web_app_url
$webAppHost = $webAppUrl -replace '^https://', ''

foreach ($repo in @('MoneyYu/GH-200', 'MoneyDemo/20260903-GH200')) {
  gh variable set VM_PUBLIC_IP --body $vmIp --repo $repo
  gh variable set VM_SSH_USER --body azureuser --repo $repo
  gh variable set AZURE_WEB_APP_NAME --body $webAppName --repo $repo
  gh variable set AZURE_WEB_APP_HOSTNAME --body $webAppHost --repo $repo
}
```

`VM_SSH_HOST_KEY` **不**適合用上面這種批次迴圈：它必須先在受信任管道（例如 Azure
serial console，或已用其他方式確認身分的初次連線）擷取完整 OpenSSH `known_hosts` 行並
人工核對，才逐一設到兩個 repo；下列指令只示範「怎麼設」，`$knownHostsPath` 內容本身
不在本文出現，也不要把它印到終端機或 log：

```powershell
Get-Content -Raw -LiteralPath $knownHostsPath |
  gh variable set VM_SSH_HOST_KEY --repo MoneyYu/GH-200
Get-Content -Raw -LiteralPath $knownHostsPath |
  gh variable set VM_SSH_HOST_KEY --repo MoneyDemo/20260903-GH200
```

官方參考：

- [GitHub Actions OIDC for Azure](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
- [Authenticate to Azure from GitHub Actions with OIDC](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)

## Module-to-environment map

| 客戶模組 | 平台／資源 | 課堂操作 |
|---|---|---|
| **M1 — Design and Manage Workflows** | class repo、GitHub-hosted runner、Maven Wrapper、artifact | 寫 `01.build` 至 `03.package-artifact`；cache 只說明概念。 |
| **M2 — Consume and Troubleshoot Workflows** | Actions tab、workflow logs、`09.troubleshooting`、指定 workflow templates | 讀 execution / log / debug，完成 failure diagnosis。 |
| **M3 — Author and Maintain Actions（本次不授課）** | N/A | 不配置環境、不示範、不安排 lab。 |
| **M4 — Manage GitHub Actions in the Enterprise** | organization policies、runner groups、secrets/variables governance、Ubuntu VM self-hosted runner | 說明治理與 runner 信任邊界；可展示 `08.selfhosted-runner`。 |
| **M5 — Secure and Optimize Automation** | SSH-only VM 部署（`04`-`06`）＋ Azure OIDC 的 `07.deploy-webapp` 對照、`test`/`production` Environments、Ubuntu VM services | `04.deploy-test`、`05.deploy-prod`、`06.full-pipeline`；production 必經 approval。 |

## GitHub prerequisites

以下均為講師課前待檢查事項，非已驗證紀錄：

- [ ] 可開啟 [MoneyDemo](https://github.com/MoneyDemo) 與 class repo <https://github.com/MoneyDemo/20260903-GH200>。
- [ ] class repo Actions 已啟用，且 organization policy 未阻擋課堂必要 actions。
- [ ] `test` / `production` Environments 存在；production required reviewer 可由正確人員核准。
- [ ] Environment secrets 和 variables 已依 workflow 名稱建立，且未出現在 YAML、log、投影片或 shell history。
- [ ] `01.build`…`06.full-pipeline` 至少有一組可展示的 run；`09.troubleshooting` 有可讀的失敗案例。
- [ ] 若示範 VM self-hosted runner，runner 已在 GitHub UI 顯示可用，registration token 僅在註冊當下取得；registration 需要講師以受信任的手動連線／session 完成，且 runner 應用程式須每 30 天內更新一次，否則 GitHub 不會再派工作給它。
- [ ] 課前用 Azure CLI 確認並啟動（若已 deallocate）SSH 部署目標 VM；`04`/`05`/`06` 的 workflow 完全不含 Azure 登入，也不會自行啟動 VM，VM 未開機或 TCP/22 未開放時 SSH 連線步驟會快速失敗。
- [ ] `VM_SSH_PRIVATE_KEY`（secret）與 `VM_PUBLIC_IP`、`VM_SSH_USER=azureuser`、`VM_SSH_HOST_KEY`（variables）已在 **`MoneyYu/GH-200` 與 `MoneyDemo/20260903-GH200` 兩個 repo** 各自設定（見上方「Terraform outputs → GitHub variables」）；`VM_SSH_HOST_KEY` 是完整 OpenSSH `known_hosts` 行而非 `SHA256:` 指紋，且是在受信任網路下取得後手動貼入，VM host key 輪替後需手動更新。
- [ ] `AZURE_WEB_APP_NAME`、`AZURE_WEB_APP_HOSTNAME`（variables）已從 Terraform outputs（`web_app_name`、`web_app_url`）在**兩個 repo**各自設定；`07`／`demo-java-07-deploy-webapp` 專屬的 OIDC identity 已依上方「Azure RBAC for the 07 OIDC identity」在兩個 repo 各自建立，且範圍是精準的該 Linux Web App（`Website Contributor`），未沿用舊有的 VM／Blob 共用 identity。
- [ ] `AZURE_WEBAPP_CLIENT_ID`（secret）已在**兩個 repo**各自設定，提供上述專屬 Web App identity 的 client ID 給 `07`／`demo-java-07-deploy-webapp` 的 `azure/login`；舊的 `AZURE_CLIENT_ID` 目前維持不動，等其他 VM／Blob 相關使用者全部除役後才處理。

Self-hosted runner 不得接收不信任 fork pull request。它保留機器狀態，維護、修補、清理與安全隔離均由講師／管理者負責；runner group 應限縮可使用的 repository。

## Java Web App and Windows fallback

`TERRAFORM/` 現行設定**沒有 Windows VM 或 Windows Web App**；SSH-only 重構已把它們從
`MOD.tf` 移除。既有 stack 只剩兩個 Azure 部署 target：

| 資源 | 用途 |
|---|---|
| Ubuntu 24.04 VM | 本場 Java app 的 test/prod systemd services，也是 `04`-`06` 的 SSH 部署 target 與 `08` 的 same-VM self-hosted runner 對照主機。 |
| Linux App Service（Java SE 21 Web App） | `07.deploy-webapp` 的 Azure OIDC／PaaS 對照 target，與 SSH VM 路徑並非互相替代。 |

若未來需要獨立的 C# demo，須另行規劃基礎設施；目前 `TERRAFORM/` 不包含任何 C# 或
Windows 目標。

### Current Terraform inventory

下列對照現行 `TERRAFORM/MOD.tf` 的實際資源，詳細操作以
[`../TERRAFORM/README.md`](../TERRAFORM/README.md) 為準。

| Azure 資源 | 名稱模式（`local.resource_suffix` = `<group_postfix>-ksh`） | 用途 |
|---|---|---|
| Resource group | `GH200-<group_postfix>` | Stack 容器。 |
| Virtual network / subnet | `lab-vnet-<group_postfix>-ksh` / `lab-linux-subnet-<group_postfix>-ksh` | Linux VM 網路。 |
| Public IP、NIC | `lab-linux-pip-<group_postfix>-ksh`、`lab-linux-nic-<group_postfix>-ksh` | Linux VM 的網路元件。 |
| Network Security Group | `lab-linux-nsg-<group_postfix>-ksh` | `8080`/`8081` 對外開放；`22` 只允許來源 `AzureCloud`（`AllowSshFromAzureCloud`）。 |
| Ubuntu 24.04 VM | `lab-linux-<group_postfix>-ksh` | `04`-`06` SSH 部署 target；`08` self-hosted runner 對照主機。 |
| Linux Custom Script extension | `lab-linux-runner-<group_postfix>-ksh` | 預先下載/解壓縮 runner binary，不含 registration token。 |
| Linux App Service plan（`S1`） | `lab-app-plan-<group_postfix>-ksh` | Linux Java Web App plan。 |
| Linux Java Web App（Java SE 21） | `gh200-java-web-<group_postfix>-ksh` | `07.deploy-webapp` 的 Azure OIDC/PaaS 對照 target。 |

既有 stack 的 region 為 `japaneast`。`group_postfix` 為 1–10 個小寫英數字；Linux VM 的
admin user 為 `azureuser`，只用 SSH public key 認證（`linux_ssh_public_key` 變數），
沒有任何 password 變數。不得將 SSH private key 寫入 `.tf`、`.tfvars`、chat、投影片或
命令列 history。

> [!CAUTION]
> Repo 的一般規則禁止 agent 執行 `terraform apply`。`GH200-0903` 在 SSH-only 重構存在之前，
> 已有一次不同、**已完成**的歷史 apply：`18 added, 0 changed, 0 destroyed`，建立含 Windows
> VM/Web App 的舊有 stack；這是已發生的歷史事實，與下方針對 SSH-only 重構的授權是不同事件。
>
> **針對 SSH-only 重構本身**（移除 Windows VM/Web App、改用 `linux_ssh_public_key`、加入
> `AllowSshFromAzureCloud`、runner 預先安裝 extension），使用者授權對 `GH200-0903` 執行
> **恰好一次** reviewed apply，且僅限於已審閱的 plan 與 implementation gate 通過之後。
> 截至目前只跑過 `plan`，**尚未實際 apply，不得宣稱這次重構已經套用到 Azure**。**未經
> 使用者新的明確授權，不得再次執行 apply**。`terraform destroy` **必須有使用者新的明確
> 要求並經確認**才可執行；課程開始前絕對不得執行，也不得以 display name、prefix 或
> wildcard 對共享 subscription 清理。

Terraform 的閱讀、`fmt`、`init`、`validate`、`plan` 仍應依 [`../TERRAFORM/README.md`](../TERRAFORM/README.md) 與既有 repo 規則由適當人員處理。本文不修改或重新定義 Terraform 設定。

Terraform 不會建立 GitHub repository、workflow、Environment、secret、package 或 runner；它也不會替講師註冊 self-hosted runner 或處理 GitHub secrets/variables。

## Pre-class smoke test

以下為講師待執行檢查；未勾選即未驗證。

### Java pipeline（pre-refactor 歷史紀錄）

> 見上方「2026-09-03 班級 repo 已部署環境（pre-refactor 歷史紀錄）」表；下列勾選只證明
> 該次交付當時的舊拓樸曾經成功，**不是**目前 SSH-only 對齊版本的驗證。

- [x] `01.build` 使用 Maven Wrapper 成功。
- [x] `02.build-test` 的 tests 成功，另有 `09.troubleshooting` 的可讀失敗 log。
- [x] `03.package-artifact` 可 upload/download 同一份 jar。
- [x] `04.deploy-test` 後 `simpleweb-test` 在 `8080` 健康，三個端點可回應。
- [x] `05.deploy-prod` 曾停在 production approval，核准後 `simpleweb-prod` 在 `8081` 健康。
- [x] `06.full-pipeline` 已完成成功 end-to-end run。

### Identity and VM

- [x] **Pre-refactor 歷史紀錄**：Azure OIDC federated credential、least-privilege
  Azure RBAC、`permissions: id-token: write` 曾用 class repo **當時**的 `04`（走
  `az vm run-command`）實際測通。這只證明 OIDC 機制本身在該次交付曾經成功，**不是**
  對目前已對齊的 `07.deploy-webapp`（Linux App Service，`MoneyYu/GH-200` 與
  `MoneyDemo/20260903-GH200` 現行都是這個編號）的驗證。
- [ ] **尚待課前驗證**：兩個 repo 現行對齊版本的 `07.deploy-webapp`（Linux App
  Service／OIDC 對照）尚未有 live workflow dispatch 證據；目前只完成程式碼靜態驗證
  （YAML parse／`bash -n`）。課前須各自用該 repo 專屬的 OIDC identity（見下方 Azure
  RBAC 小節）實際 dispatch 一次，確認 `azure/login` 與 `azure/webapps-deploy` 成功，
  並用 `/api/info` 的 build SHA 做語意化 smoke test。
- [ ] **尚待課前驗證**：`MoneyYu/GH-200` 的 SSH-only `04`/`05`/`06`
  尚未有 live workflow dispatch 證據；目前只完成程式碼與 Terraform 的靜態驗證
  （lint／`bash -n`／`terraform validate`／`plan`），未實際觸發 workflow 或執行
  `terraform apply`。課前須實際 dispatch 一次，確認 `VM_SSH_PRIVATE_KEY` +
  `VM_SSH_HOST_KEY` 主機指紋釘選、SCP、`systemctl restart` 與 `/api/info` SHA smoke
  test 全部成功，且持久的 `AllowSshFromAzureCloud`（來源 `AzureCloud`，非
  `Internet`）規則確實可讓 GitHub-hosted runner 連線；不需要、也不應該建立任何
  臨時 `AllowSshForDemo` 規則。
- [x] `systemctl` 顯示 `simpleweb-test` 和 `simpleweb-prod` 運作，兩個 health endpoint 為 `UP`。
- [x] Ephemeral self-hosted runner 已接走一個 trusted workflow，job 完成後 runner count 回到 `0`。

### Lifecycle and cleanup

- [ ] `GH200-0903` stack 的原始 apply（`18 added, 0 changed, 0 destroyed`）已就緒；
  SSH-only 重構的 Terraform plan 已審閱但**尚未 apply**；**課前不執行 destroy**。
- [ ] 清理只針對人員確認的精確 resource ID／名稱與本次 runner/package；不做自動或萬用字元清理。

## Trust boundaries and live-failure handling

| 身分 | 用途 | 禁止事項 |
|---|---|---|
| `GITHUB_TOKEN` | repository 內 GitHub API 操作 | 不作 Azure 登入。 |
| Azure OIDC | Azure deploy 的短期 token（`07.deploy-webapp`） | 不用來取代 `GITHUB_TOKEN`；`04`-`06` 完全不使用它。 |
| `VM_SSH_PRIVATE_KEY` | `04`/`05`/`06` 主線 SSH 部署身分 | 不貼入 repo、log 或投影片；每個 job run 結束都清除暫存檔。 |
| self-hosted runner token | 一次性的 runner 註冊 | 不保存或重用。 |

若 live deploy 失敗，先保留 run，按 workflow → SSH 連線 → SCP → systemd → health endpoint 的順序定位（`07.deploy-webapp` 則是 workflow → OIDC → Web App deploy → health endpoint）。三分鐘後切至成功 run／health screenshot；不臨時改 Terraform、不開放額外網路連接埠、不關掉 approval gate，也不將 secret 當作除錯輸出。

## References

- [Class demo repo](https://github.com/MoneyDemo/20260903-GH200)
- [Teaching guide](teaching-guide.md)
- [Attendee README](../README.md)
- [Terraform fallback](../TERRAFORM/README.md)
- [Self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)
- [Runner groups](https://docs.github.com/en/actions/concepts/runners/runner-groups)
