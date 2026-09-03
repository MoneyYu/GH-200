# GH-200 Terraform 備援環境

此目錄提供 GH-200T00-A **Automate your workflow with GitHub Actions** 課程的 trainer
backup/fallback stack。課堂中應由 trainer 現場建立 Azure resources；若現場建立失敗，
可使用此 Terraform configuration 快速建立替代環境。

## 用途與課程對應

此 stack 建立：

- 一部 Ubuntu 24.04 LTS VM，預先安裝 OpenJDK 21，模擬 **on-prem application server**，
  作為 **04-06 SSH-only** Java deployment demo 的主要 target，呈現
  **Build → Test → Package → SCP → SSH → `systemctl` → 語意化 `/api/info` smoke test**
  story。同一台 VM 也可作為 **08** 的 self-hosted runner 課堂簡化示範主機。
- 一個 Linux App Service plan 與 Java SE 21 Web App，作為 **07** 的 Azure OIDC／PaaS
  對照 target（`azure/webapps-deploy`），與 SSH VM 路徑並非互相替代。
- 一個 Linux Custom Script VM extension，預先下載並解壓縮 GitHub Actions self-hosted
  runner `v2.337.0` 到 `/opt/actions-runner`。它不會註冊 runner，也不包含 registration
  token。

## Prerequisites

- Terraform `>= 1.0`
- Azure CLI，並已執行 `az login`
- 可建立 resources 的 Azure subscription
- 在 `japaneast` region 具備所需 quota
- 由環境提供 Azure subscription，例如設定 `ARM_SUBSCRIPTION_ID`
- Linux VM 使用 SSH key authentication。Terraform 只需要 public key；請勿將 private
  key 放入 Terraform state、`.tfvars` 或 repo。

## Variables

| Name | Type | Default | Required? | Description |
|---|---|---:|:---:|---|
| `group_postfix` | `string` | 無 | 是 | Resource group suffix；只接受 1–10 個小寫英文字母或數字，符合 `^[a-z0-9]{1,10}$`。 |
| `linux_ssh_public_key` | `string` | 無 | 是 | Linux VM admin user (`azureuser`) 的 SSH public key。請從本機 `.pub` 檔案讀入。 |

建議透過 `TF_VAR_linux_ssh_public_key` 提供 public key，避免將任何 SSH private key material
寫入 `.tf`、`.tfvars` 或命令歷程：

```powershell
$pubKeyPath = Join-Path $HOME ".ssh\gh200-linux.pub"
$env:TF_VAR_linux_ssh_public_key = (Get-Content -Raw $pubKeyPath).Trim()
```

保留 private key 於使用者自己的 `.ssh` 目錄，並依 SSH key 一般安全做法限制檔案權限。

## Remote state backend

本場已將 state 遷移到 Azure Storage，避免 Terraform state 留在多人可讀的本機
`terraform.tfstate`：

| 項目 | 值 |
|---|---|
| Resource group | `GH200-0903` |
| Storage account | `gh200state0903ksh` |
| Container | `tfstate` |
| Blob key | `gh200-0903.tfstate` |
| Authentication | Microsoft Entra ID (`use_azuread_auth=true`)，shared key 已停用 |

目前講師帳號在 storage account scope 具 `Storage Blob Data Contributor`。Fresh clone
第一次初始化時使用：

```powershell
$subscriptionId = az account show --query id --output tsv

terraform init `
  -backend-config="resource_group_name=GH200-0903" `
  -backend-config="storage_account_name=gh200state0903ksh" `
  -backend-config="container_name=tfstate" `
  -backend-config="key=gh200-0903.tfstate" `
  -backend-config="use_azuread_auth=true" `
  -backend-config="subscription_id=$subscriptionId"
```

不要刪除 storage account/container，也不要把 state 下載後 commit。若要交接講師，請在
storage account scope 指派最小必要的 data-plane role；不要啟用 shared key。

### Deprecated Blob artifact container (unmanaged, do not delete)

`MoneyYu/GH-200` 的 Java CD workflows（`04`/`05`/`06`）先前曾用同一個 AAD-only storage
account 的 `deployments` container 搬運 build artifact（OIDC 上傳、VM managed-identity
下載）。**這個 deploy 機制已被 SSH-only 取代**：現行 workflows 改用
`actions/upload-artifact`／`actions/download-artifact` 保存 jar，並以 GitHub secret
`VM_SSH_PRIVATE_KEY` 透過 SCP/SSH 直接部署到 VM，不再讀寫 `deployments` container。

`deployments` container 本身**維持既有、不受 Terraform 管理**的狀態：不要刪除它，也不要
把它當孤兒資源清理；它與 backend 使用的 `tfstate` container 的 RBAC scope 仍然分開。若未來
確認不再需要，交由講師/使用者另行決定是否移除，本文不在此指示刪除。

## Usage

```powershell
cd TERRAFORM
# 先依上節初始化 remote backend
$env:TF_VAR_linux_ssh_public_key = (Get-Content -Raw "$HOME\.ssh\gh200-linux.pub").Trim()
terraform plan -var "group_postfix=0903"
```

> [!WARNING]
> 本 repo 明確禁止 AI agent 執行 `terraform apply`。此 stack 在 SSH-only 重構之前，`GH200-0903`
> 已有一次不同、已完成的歷史 apply（`18 added, 0 changed, 0 destroyed`，建立含 Windows VM/Web
> App 的舊有 topology）。**針對 SSH-only 重構本身**（移除 Windows VM/Web App、改用
> `linux_ssh_public_key`、加入 `AllowSshFromAzureCloud`、runner 預先安裝 extension），使用者僅
> 授權 trainer 在檢閱過 plan 且通過 implementation gate 後手動執行**一次** reviewed apply；
> 截至目前只跑過 `plan`，尚未實際 apply，**不得宣稱已套用到 Azure**。**未經使用者新的明確
> 授權，不得再次執行 apply**：
>
> ```powershell
> $env:TF_VAR_linux_ssh_public_key = (Get-Content -Raw "$HOME\.ssh\gh200-linux.pub").Trim()
> terraform apply -var "group_postfix=0903"
> ```

## Outputs

| Name | Description |
|---|---|
| `resource_group_name` | Backup environment 所在的 resource group。 |
| `web_app_name` | Java deployment demo 使用的 Linux Web App 名稱。 |
| `web_app_url` | Linux Java Web App HTTPS URL。 |
| `app_service_plan_name` | Linux Java Web App 所在的 App Service plan。 |
| `linux_vm_name` | Java deployment demo 使用的 Ubuntu VM 名稱。 |
| `linux_vm_public_ip` | Ubuntu VM public IP。 |
| `linux_ssh_command` | 可直接貼上的 `ssh -i <key-path> azureuser@<ip>` 指令（使用預設 key path）。 |
| `app_test_url` | Test environment URL（port `8080`）。 |
| `app_prod_url` | Production environment URL（port `8081`）。 |

SSH private key 不由 Terraform 產生，也不會寫入 Terraform state。需要 SSH 時，請使用
本機 private key 搭配 Terraform output 的 public IP：

```powershell
$keyPath = Join-Path $HOME ".ssh\gh200-linux"
ssh -i $keyPath azureuser@$(terraform output -raw linux_vm_public_ip)
```

請像保護其他 private key 一樣限制該檔案的存取權。

`terraform destroy` **只能在使用者提出新的明確要求並確認後**，才由 trainer 手動執行；課程
開始前絕對不得執行，也不得因為例行清理、policy 掃描或維運方便而自行觸發：

```powershell
$env:TF_VAR_linux_ssh_public_key = (Get-Content -Raw "$HOME\.ssh\gh200-linux.pub").Trim()
terraform destroy -var "group_postfix=0903"
Remove-Item Env:\TF_VAR_linux_ssh_public_key
```

## Naming

`group_postfix` 決定 resource group 名稱，例如 `group_postfix=0903` 會建立
`GH200-0903`。其他 resource names 使用
`local.resource_suffix = "<group_postfix>-<random_str>"`；固定的
`local.random_str = "ksh"` 讓同一場次重跑時名稱維持穩定：

- Virtual network：`lab-vnet-0903-ksh`
- Linux VM：`lab-linux-0903-ksh`
- Linux subnet：`lab-linux-subnet-0903-ksh`
- Linux public IP：`lab-linux-pip-0903-ksh`
- Linux network interface：`lab-linux-nic-0903-ksh`
- Linux Network Security Group：`lab-linux-nsg-0903-ksh`
- App Service plan：`lab-app-plan-0903-ksh`
- Linux Java Web App：`gh200-java-web-0903-ksh`

## Java VM deployment layout

Cloud-init 會安裝 OpenJDK 21、建立不可登入的 `simpleweb` system user，並準備兩個
deployment directories 與 systemd services：

| Environment | Jar path | Environment file | Service | Port |
|---|---|---|---|---:|
| Test | `/opt/simpleweb/test/simpleweb.jar` | `/opt/simpleweb/test/app.env` | `simpleweb-test.service` | `8080` |
| Production | `/opt/simpleweb/prod/simpleweb.jar` | `/opt/simpleweb/prod/app.env` | `simpleweb-prod.service` | `8081` |

`app.env` 是 optional 的 `EnvironmentFile=-`（缺檔也能啟動）。build provenance（完整
commit SHA 與 UTC build 時間）現在於 build 階段由 Maven resource filtering 烤進 jar，
deployment workflow **不再**寫入 `APP_BUILD_SHA`／`APP_BUILD_TIME`；版本佐證一律來自
`/api/info`（artifact 本身），不靠外部設定。`APP_ENVIRONMENT` 仍由 systemd unit 的
`Environment=` 指令提供。Cloud-init 只執行 `systemctl enable`，不會在 jar 尚未部署時啟動
services；workflow 應在放置 jar 後執行
`sudo systemctl restart simpleweb-test.service` 或
`sudo systemctl restart simpleweb-prod.service`。

Azure Ubuntu image 預設授予 admin user `azureuser` passwordless sudo，因此 SSH
deployment 可用 `sudo install` / `sudo mv` 將檔案放入 `/opt/simpleweb`，並 restart
service。這是 `04`/`05`/`06` 目前實際採用的路徑；jar 與 `app.env` 最後都應將
ownership 設為 `simpleweb:simpleweb`。

### OS disk storage type

既有 Linux VM 的 OS disk（`lab-linux-osdisk-0903-ksh`）在 Azure 上實際是 `Standard_LRS`。
`os_disk.storage_account_type` 因此維持 `Standard_LRS`，而不是改成 `Premium_LRS`：兩者不
一致會讓 `storage_account_type` 觸發 `forces replacement`，導致下一次 `plan`／`apply` 把
既有 `azurerm_linux_virtual_machine.lab` 整台重建——不只違反「保留既有 Linux VM」的需求，
重建還會繞過 `admin_ssh_key`／`custom_data` 的 `lifecycle.ignore_changes`（那只在原地更新時
生效，資源被整個換掉時不適用），等於用一次意外的 replace 蓋掉課前已完成的 out-of-band SSH
金鑰輪替。維持 `Standard_LRS` 才能讓 `terraform plan` 對這台既有 VM 保持 clean（no changes/
no replacement），也符合共享 subscription policy 對既有 disk 的實際狀態。這裡刻意只改這一
個欄位，不對 `os_disk` 加上整體的 `ignore_changes`——後者會連未來刻意的欄位變更都靜默吃掉，
掩蓋而非解決這個落差。

### Post-apply verification

`terraform apply` 完成只代表 Azure VM control plane provisioning 已完成；第一次開機的
cloud-init（包含 OpenJDK 21 安裝與 systemd units 建立）可能仍在背景執行。**先等待
cloud-init 完成，再檢查 Java 與 services**，避免把正常的初始收斂誤判為部署失敗。驗證改用
trainer 自己的 SSH private key 連線，**不要**印出 private key 內容或把它寫進任何 log。

> [!IMPORTANT]
> `lab-linux-nsg-0903-ksh` 只允許來源 `AzureCloud` 連入 TCP/22（`AllowSshFromAzureCloud`）；
> 一般講師筆電所在的網路**不在** `AzureCloud` 這個 service tag 內，直接從筆電 SSH 會被
> NSG 擋下。下列 post-apply 驗證、以及「Notes and known limitations」的 runner registration
> 手動連線，都必須從 **Azure Cloud Shell** 或其他已被 NSG 明確允許的受信任網路執行，而不是
> 一般筆電。**不要**為了讓筆電能連而放寬 NSG（開放 `Internet` 來源或新增臨時規則）；也不要
> 走 Azure Run Command 或 Arc 之類的替代連線路徑——本 stack 刻意不採用那些機制。

主機指紋**不使用** `StrictHostKeyChecking=accept-new`，也不使用 `ssh-keyscan` 或任何
per-run TOFU（trust-on-first-use）；一律使用已釘選在 repository variable
`VM_SSH_HOST_KEY` 的完整 OpenSSH `known_hosts` 行，搭配 `StrictHostKeyChecking=yes`、明確
`UserKnownHostsFile` 與 `GlobalKnownHostsFile=/dev/null`。`VM_SSH_HOST_KEY` 必須先在受信任
管道（例如 Azure serial console，或已用其他方式確認身分的初次連線）擷取並人工核對後才寫入
該 repository variable；這裡只讀出已核對過的值，不重新掃描：

```powershell
$linuxIp = terraform output -raw linux_vm_public_ip
$keyPath = Join-Path $HOME ".ssh\gh200-linux"
$knownHostsPath = Join-Path $HOME ".ssh\gh200-linux-known-hosts"
gh variable get VM_SSH_HOST_KEY --repo MoneyYu/GH-200 | Set-Content -NoNewline $knownHostsPath
$verifyScript = (@'
set -e
cloud-init status --wait --long || true
java -version
id simpleweb
ls -ld /opt/simpleweb/test /opt/simpleweb/prod
systemctl is-enabled simpleweb-test.service simpleweb-prod.service
systemctl is-active simpleweb-test.service simpleweb-prod.service || true
'@ -replace "`r", "")

ssh -i $keyPath `
  -o StrictHostKeyChecking=yes `
  -o "UserKnownHostsFile=$knownHostsPath" `
  -o GlobalKnownHostsFile=/dev/null `
  azureuser@$linuxIp "$verifyScript"
Remove-Item $knownHostsPath
```

預期：cloud-init 為 `done`、Java 為 OpenJDK 21、兩個目錄由 `simpleweb` 擁有、兩個
services 為 `enabled`。在第一個 jar 部署前，services 顯示 `inactive` 是正常狀態。此驗證
只使用本機已存在的 private key 檔案與已釘選的 host key，指令與輸出都不得包含金鑰內容。

## Notes and known limitations

- 此 stack 只建立 Azure infrastructure 與 runner binary preinstall，沒有 application
  artifact deployment automation。
- VM extension 只會把 runner binary 預先下載並解壓縮到 `/opt/actions-runner`；**註冊
  runner 仍需要一次短效 registration token，且必須由講師以受信任的手動連線／session**
  （例如 SSH 到該 VM）完成 `config.sh` 與啟動 runner service，Terraform 不會、也不能
  自動化這一步。這次 SSH 連線同樣只允許來源 `AzureCloud`，**必須從 Azure Cloud Shell 或
  其他已被 NSG 明確允許的受信任網路**執行，一般講師筆電無法直接連線；請參考
  [Adding self-hosted runners](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)。
- `linux_ssh_public_key` 只用於**建立新 VM**時設定 admin SSH public key；既有 VM 的
  `admin_ssh_key` 已被 `ignore_changes` 忽略，讓講師可在 Terraform 之外做受控的金鑰輪替，
  而不會被下一次 `plan`/`apply` 覆蓋或觸發重建。SSH private key 永遠不會回到 Terraform
  state。
  - **本次交付的金鑰輪替證據（trainer-only）**：既有 VM 的 SSH 金鑰已在 apply **之前**於
    Terraform 之外（out-of-band）完成輪替——直接在 VM 上以新的 public key 取代舊的
    `authorized_keys`、用替換後的金鑰實際連線測試通過、並撤銷（revoke）舊金鑰的存取。此
    輪替**不是**由 Terraform 執行；`linux_ssh_public_key` 僅在日後**建立新 VM**時作為 seed，
    不會回寫或輪替既有 VM 的金鑰。本文件不重新產生也不揭露任何金鑰內容。
- Terraform 會忽略既有 Linux VM 的 `custom_data`，因此後續 cloud-init 變更不會自動套用；若要更新，請透過 SSH/手動方式調整，或刻意重建 VM 讓新設定生效。
- Linux Web App 使用 Java SE 21。部署前應確認課程 sample application 與 Azure App
  Service Java runtime support。
- Linux subnet 的 Network Security Group 持續允許 `8080` 與 `8081`，讓兩個 app
  environments 可公開測試；SSH (`22`) 由 Terraform 管理的 `AllowSshFromAzureCloud`
  規則持續允許來源 `AzureCloud`，供 GitHub-hosted runner 執行 `04`/`05`/`06` 的 SSH
  部署使用，**必須實際從 GitHub-hosted runner 連線測試**，不能只看 `terraform plan`。
  若共享 subscription 的 policy 掃描移除了這條規則，由講師/使用者手動還原相同的
  `AllowSshFromAzureCloud` 設定；**不要**把它靜默放寬為允許 `Internet` 來源，也不要新增
  臨時的 Internet-facing SSH 規則。
