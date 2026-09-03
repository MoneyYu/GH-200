# GH-200 Demo Environment

> 📖 **Related** — [Teaching guide](teaching-guide.md)

> **講師專用。** 本文描述 2026-09-03 客製場的 demo 環境與信任邊界；學員面向資料是 `README.md`，不要在學員可見處貼上 secret、private key、registration token、`.tfvars` 或 Azure 識別碼。

## Scope and purpose

本場主線是 class repo <https://github.com/MoneyDemo/20260903-GH200> 的 Java Spring Boot 4.1.1 / Java 21 / Maven 應用程式。它使用 Maven Wrapper，產出 `target/simpleweb.jar`，所以學生不必安裝 Maven。`/`、`/api/info`、`/actuator/health` 是驗證端點；首頁顯示 environment、build SHA、hostname，供講師辨識實際部署版本。

本場的 customer module map 是 M1、M2、**M3（本次不授課）**、M4、M5。這不等同官方 7 個 Learn 模組，且不教 Reusable Workflows、Matrix Strategy 或 custom action authoring。

## Linux VM deployment target

| 項目 | 場次設定／用途 |
|---|---|
| OS | Azure Ubuntu 24.04 Linux VM |
| 測試服務 | systemd `simpleweb-test`，port `8080` |
| 正式服務 | systemd `simpleweb-prod`，port `8081` |
| GitHub Environments | `test` 與 `production` |
| Production 保護 | `production` 有 required-reviewer approval gate；這是預期等待狀態，不是 workflow failure。 |
| 主要部署方式 | `az vm run-command` + Azure OIDC |
| 對照方式 | SSH：需要開放連接埠與儲存 private key；只作安全代價比較。 |
| M4 對照 | self-hosted runner 安裝於該 VM；只在受信任 workflow 執行。 |

Progressive workflow 是 `01.build` → `02.build-test` → `03.package-artifact` → `04.deploy-test` → `05.deploy-prod` → `06.full-pipeline`。`07.deploy-ssh`、`08.selfhosted-runner`、`09.troubleshooting` 是對照／診斷材料，而不是主線的替代方案。

### 2026-09-03 班級 repo 已部署環境

| 項目 | 實際值／驗證 |
|---|---|
| Resource group | `GH200-0903` |
| Linux VM | `lab-linux-0903-ksh`（OpenJDK `21.0.12`） |
| Test | <http://20.210.89.243:8080> |
| Production | <http://20.210.89.243:8081> |
| OIDC test deployment | [Run 33673846495](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33673846495) — immutable per-SHA asset、Run Command sentinel、digest、build SHA 全部驗證 |
| Production approval | [Run 33673569379](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33673569379) 曾進入 `waiting`，核准後只 promote 指定 SHA |
| Full pipeline | [Run 33673131527](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33673131527) — Build / Test / Package / digest / test / approval / production 全部成功 |
| SSH deployment | [Run 33659763233](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33659763233) |
| Ephemeral self-hosted runner | [Run 33660507745](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33660507745)；完成後 runner 自動解除 |
| Troubleshooting failure | [Run 33660678534](https://github.com/MoneyDemo/20260903-GH200/actions/runs/33660678534) — 故意失敗的教材 |

以上 run 都來自 public class repo `MoneyDemo/20260903-GH200`，用來示範真正的
required-reviewer approval gate。

### MoneyYu/GH-200 self-contained workflows

GH-200 自己是 private repo，因此 `demo-java-04/05/06` 不使用匿名 GitHub Release。
流程改為：

1. Workflow 以 Azure OIDC 登入。
2. 將每個 commit 的 jar、`build-sha.txt`、SHA-256 digest 上傳到 private Blob path
   `deployments/builds/<commit-sha>/`。
3. Linux VM 以 system-assigned managed identity 取得 Storage token、下載並驗證 digest。
4. Run Command 回傳 `DEPLOY_OK`，外部 smoke test 再比對 `/api/info` build SHA。

目前已配置：

| 項目 | 值／權限 |
|---|---|
| Storage account | `gh200state0903ksh`（shared key disabled） |
| Container | `deployments` |
| GitHub variable | `AZURE_STORAGE_ACCOUNT=gh200state0903ksh` |
| OIDC service principal | Container scope `Storage Blob Data Contributor` |
| Linux VM managed identity | Container scope `Storage Blob Data Reader` |

MoneyYu organization 的方案不支援 Environment required reviewers（API 回傳 HTTP 422）。
因此 GH-200 的 `demo-java-06-full-pipeline` 只允許手動觸發，且要求
`confirm_production=deploy`；這是避免誤觸的確認，不是 separation of duties。要展示
真正的 reviewer gate，使用上表的 MoneyDemo class repo。

### Azure OIDC federated credential

OIDC 建立 GitHub Actions 與 **Azure** 的 workload identity federation；它不取代用於 GitHub API 的 `GITHUB_TOKEN`。講師在 Azure 端為 class repo 的實際觸發條件建立 federated credential，subject 必須精準限制於使用的 repository、branch 或 GitHub Environment；workflow job 必須宣告最小必要的 `permissions:`，包括 `id-token: write`。

- 設定順序：先準備具有最小 Azure RBAC 的 Azure workload identity，再建立 GitHub OIDC federated credential，接著在對應 GitHub Environment 設定 workflow 所需的非敏感識別值／secret，最後以實際 workflow 觸發條件測試 `azure/login` 與 `az vm run-command`。
- 建立 credential 時，以 class repo 和 `test`／`production` 的實際部署條件為準；不要複製另一個 repo、branch 或 environment 的 subject。
- 不把 Azure client secret 寫入 workflow 或交給學員。
- Azure RBAC 只授與部署所需的最小權限。
- 所需的 subscription ID、tenant ID、client ID、federated credential subject 和 Environment secrets/variables 只存在講師已核對的設定，本文不記載其值。
- OIDC login 失敗時，先檢查 `id-token: write`、subject、audience 與 Azure RBAC；不得為了示範而繞過 environment gate 或印出 credential。
- 本場 GitHub OIDC assertion 使用含 organization/repository **stable ID** 的 subject
  格式。若出現 `AADSTS700213`，以 workflow log 顯示的 presented assertion subject
  為準更新 federated credential，不要假設傳統的純 `owner/repo` 格式。
- 共享 subscription 可能由外部排程 deallocate VM；deployment workflows 已在
  Run Command 前執行 `az vm start`。若看到 `OperationNotAllowed` 要先查 power state，
  不要重跑 Terraform。

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
| **M5 — Secure and Optimize Automation** | Azure OIDC、`test`/`production` Environments、Ubuntu VM services、`az vm run-command` | `04.deploy-test`、`05.deploy-prod`、`06.full-pipeline`；production 必經 approval。 |

## GitHub prerequisites

以下均為講師課前待檢查事項，非已驗證紀錄：

- [ ] 可開啟 [MoneyDemo](https://github.com/MoneyDemo) 與 class repo <https://github.com/MoneyDemo/20260903-GH200>。
- [ ] class repo Actions 已啟用，且 organization policy 未阻擋課堂必要 actions。
- [ ] `test` / `production` Environments 存在；production required reviewer 可由正確人員核准。
- [ ] Environment secrets 和 variables 已依 workflow 名稱建立，且未出現在 YAML、log、投影片或 shell history。
- [ ] `01.build`…`06.full-pipeline` 至少有一組可展示的 run；`09.troubleshooting` 有可讀的失敗案例。
- [ ] 若示範 VM self-hosted runner，runner 已在 GitHub UI 顯示可用，registration token 僅在註冊當下取得。

Self-hosted runner 不得接收不信任 fork pull request。它保留機器狀態，維護、修補、清理與安全隔離均由講師／管理者負責；runner group 應限縮可使用的 repository。

## Windows VM and Windows Web App (C# demos)

`TERRAFORM/` 的既有 Windows VM 和 Windows Web App 仍保留給 **C# demos**。它們不是本場 Java 主線的部署目標，也不取代 Ubuntu VM 上的 `simpleweb-test` / `simpleweb-prod`。

既有 stack 的角色：

| 資源 | 用途 |
|---|---|
| Windows Server VM + IIS | C# demo 或 Windows self-hosted runner 對照主機。 |
| Windows Web App（.NET 8） | C# `azure/webapps-deploy` demo target。 |
| Ubuntu 24.04 VM | 本場 Java app 的 test/prod systemd services 與 Linux runner 對照。 |

### Existing Terraform fallback inventory

下列是既有 `TERRAFORM/` 的 Windows/C# fallback 意圖，保留供講師辨識資源；詳細操作以 [`../TERRAFORM/README.md`](../TERRAFORM/README.md) 為準。

| Azure 資源 | 名稱模式（`local.resource_suffix` = `<group_postfix>-ksh`） | C# demo 用途 |
|---|---|---|
| Resource group | `GH200-<group_postfix>` | Windows/C# fallback stack 容器。 |
| Virtual network / subnet | `lab-vnet-<group_postfix>-ksh` / `default` | Windows VM 網路。 |
| Public IP、NIC | `lab-pip-<group_postfix>-ksh`、`lab-nic-<group_postfix>-ksh` | VM 的既有網路元件。 |
| Windows Server 2022 VM | `lab-vm-<group_postfix>-ksh` | C# demo 或 Windows runner 對照主機；runner 不由 Terraform 安裝或註冊。 |
| `AADLoginForWindows` / IIS script extension | `lab-aad-<group_postfix>-ksh`、`lab-script-<group_postfix>-ksh` | Microsoft Entra ID 登入與 IIS baseline。 |
| Windows App Service plan（`S1`） | `lab-app-plan-<group_postfix>-ksh` | Windows Web App plan。 |
| Windows Web App（.NET 8） | `gh200-web-<group_postfix>-ksh` | C# `azure/webapps-deploy` target。 |

既有 stack 的 region 為 `japaneast`。`group_postfix` 為 1–10 個小寫英數字；`user_name` 預設為 `demouser`，`user_password` 是 sensitive 且僅能在講師安全輸入時提供。不得將 password 寫入 `.tf`、`.tfvars`、chat、投影片或命令列 history。

> [!CAUTION]
> Repo 的一般規則禁止 agent 執行 `terraform apply`；本次使用者在核准客製化計畫時，
> **明確授權 agent 只對 `GH200-0903` 執行一次 reviewed plan**。該 apply 已完成：
> `18 added, 0 changed, 0 destroyed`。授權不包含再次 apply，也不包含 destroy。
> `terraform destroy` 在課程開始前**絕對不得執行**，也不得以 display name、prefix
> 或 wildcard 對共享 subscription 清理。

Terraform 的閱讀、`fmt`、`init`、`validate`、`plan` 仍應依 [`../TERRAFORM/README.md`](../TERRAFORM/README.md) 與既有 repo 規則由適當人員處理。本文不修改或重新定義 Terraform 設定。

Terraform 不會建立 GitHub repository、workflow、Environment、secret、package 或 runner；它也不會替講師建立 Microsoft Entra ID VM login role assignment。若使用 Windows VM，講師仍須依實際需要安排 `Virtual Machine Administrator Login` 或 `Virtual Machine User Login`，並以精確識別的資源處理任何課後清理。

## Pre-class smoke test

以下為講師待執行檢查；未勾選即未驗證。

### Java pipeline

- [x] `01.build` 使用 Maven Wrapper 成功。
- [x] `02.build-test` 的 tests 成功，另有 `09.troubleshooting` 的可讀失敗 log。
- [x] `03.package-artifact` 可 upload/download 同一份 jar。
- [x] `04.deploy-test` 後 `simpleweb-test` 在 `8080` 健康，三個端點可回應。
- [x] `05.deploy-prod` 曾停在 production approval，核准後 `simpleweb-prod` 在 `8081` 健康。
- [x] `06.full-pipeline` 已完成成功 end-to-end run。

### Identity and VM

- [x] Azure OIDC federated credential、`Virtual Machine Contributor` RBAC、
  `permissions: id-token: write` 與 `az vm run-command` 已用 class repo 實際測通。
- [x] Ubuntu VM 可用 Azure Run Command 管理；SSH 對照曾實測成功。共享 policy
  會移除 persistent port 22 rule，現場 SSH demo 前須依 `TERRAFORM/README.md` 建立
  `AllowSshForDemo`，完成後立即刪除。
- [x] `systemctl` 顯示 `simpleweb-test` 和 `simpleweb-prod` 運作，兩個 health endpoint 為 `UP`。
- [x] Ephemeral self-hosted runner 已接走一個 trusted workflow，job 完成後 runner count 回到 `0`。

### C# fallback and lifecycle

- [ ] Windows VM / Windows Web App 僅於 C# demo 使用，與 Java VM ports 分開說明。
- [ ] `GH200-0903` stack 已由 trainer/author 的 one-off apply 準備好；**課前不執行 destroy**。
- [ ] 清理只針對人員確認的精確 resource ID／名稱與本次 runner/package；不做自動或萬用字元清理。

## Trust boundaries and live-failure handling

| 身分 | 用途 | 禁止事項 |
|---|---|---|
| `GITHUB_TOKEN` | repository 內 GitHub API 操作 | 不作 Azure 登入。 |
| Azure OIDC | Azure deploy 的短期 token | 不用來取代 `GITHUB_TOKEN`。 |
| SSH private key | 只作 `07.deploy-ssh` 對照 | 不貼入 repo、log 或投影片。 |
| self-hosted runner token | 一次性的 runner 註冊 | 不保存或重用。 |

若 live deploy 失敗，先保留 run，按 workflow → OIDC → run-command → systemd → health endpoint 的順序定位。三分鐘後切至成功 run／health screenshot；不臨時改 Terraform、不開放額外網路連接埠、不關掉 approval gate，也不將 secret 當作除錯輸出。

## References

- [Class demo repo](https://github.com/MoneyDemo/20260903-GH200)
- [Teaching guide](teaching-guide.md)
- [Attendee README](../README.md)
- [Terraform fallback](../TERRAFORM/README.md)
- [Self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)
- [Runner groups](https://docs.github.com/en/actions/concepts/runners/runner-groups)
