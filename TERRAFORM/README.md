# GH-200 Terraform 備援環境

此目錄提供 GH-200T00-A **Automate your workflow with GitHub Actions** 課程的 trainer
backup/fallback stack。課堂中應由 trainer 現場建立 Azure resources；若現場建立失敗，
可使用此 Terraform configuration 快速建立替代環境。

## 用途與課程對應

此 stack 建立：

- 一部具 system-assigned managed identity 的 Ubuntu 24.04 LTS VM，預先安裝 OpenJDK 21，
  作為 **Java** demo 的 deployment target，用於呈現
  **Build → Test → Package → Deploy** story。
- 一個 Linux App Service plan 與 Java SE 21 Web App，作為 `azure/webapps-deploy`
  fallback target。
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

### Private deployment artifact container

因 `MoneyYu/GH-200` 是 private repo，Java CD workflows 使用同一個 AAD-only storage
account 的獨立 `deployments` container，不使用匿名 GitHub Release URL。Backend
`tfstate` container 與 application artifact container 的 RBAC scope 完全分開。

一次性 bootstrap（目前環境已完成）：

```powershell
$storageAccount = "gh200state0903ksh"
$resourceGroup = "GH200-0903"
$container = "deployments"
$accountId = az storage account show `
  --resource-group $resourceGroup `
  --name $storageAccount `
  --query id --output tsv
$containerScope = "$accountId/blobServices/default/containers/$container"

az storage container create `
  --account-name $storageAccount `
  --name $container `
  --auth-mode login

# GitHub OIDC service principal 的 object ID（不是 client/application ID）
$deploymentPrincipalId = "<OIDC_SERVICE_PRINCIPAL_OBJECT_ID>"
az role assignment create `
  --assignee-object-id $deploymentPrincipalId `
  --assignee-principal-type ServicePrincipal `
  --role "Storage Blob Data Contributor" `
  --scope $containerScope

$vmPrincipalId = az vm show `
  --resource-group $resourceGroup `
  --name "lab-linux-0903-ksh" `
  --query identity.principalId --output tsv
az role assignment create `
  --assignee-object-id $vmPrincipalId `
  --assignee-principal-type ServicePrincipal `
  --role "Storage Blob Data Reader" `
  --scope $containerScope

gh variable set AZURE_STORAGE_ACCOUNT `
  --repo MoneyYu/GH-200 `
  --body $storageAccount
```

Workflows 04/06 以 `az storage blob upload --auth-mode login` 寫入
`deployments/builds/<commit-sha>/`；VM 透過 IMDS managed-identity token 讀取。不要把
GitHub token、Storage key 或 SAS token 傳入 Run Command。

## Usage

```powershell
cd TERRAFORM
# 先依上節初始化 remote backend
$env:TF_VAR_linux_ssh_public_key = (Get-Content -Raw "$HOME\.ssh\gh200-linux.pub").Trim()
terraform plan -var "group_postfix=0903"
```

> [!WARNING]
> 本 repo 明確禁止 AI agent 執行 `terraform apply`。Trainer 檢查 plan 後，必須自行手動執行：
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

課程結束後，由 trainer 手動清除本 stack：

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
- Linux Java Web App：`gh200-web-0903-ksh`

## Java VM deployment layout

Cloud-init 會安裝 OpenJDK 21、建立不可登入的 `simpleweb` system user，並準備兩個
deployment directories 與 systemd services：

| Environment | Jar path | Environment file | Service | Port |
|---|---|---|---|---:|
| Test | `/opt/simpleweb/test/simpleweb.jar` | `/opt/simpleweb/test/app.env` | `simpleweb-test.service` | `8080` |
| Production | `/opt/simpleweb/prod/simpleweb.jar` | `/opt/simpleweb/prod/app.env` | `simpleweb-prod.service` | `8081` |

`app.env` 是 optional，可由 deployment workflow 寫入 `APP_BUILD_SHA` 與
`APP_BUILD_TIME`。Cloud-init 只執行 `systemctl enable`，不會在 jar 尚未部署時啟動
services；workflow 應在放置 jar 與 environment file 後執行
`sudo systemctl restart simpleweb-test.service` 或
`sudo systemctl restart simpleweb-prod.service`。

Azure Ubuntu image 預設授予 admin user `azureuser` passwordless sudo，因此 SSH
deployment 可用 `sudo install` / `sudo mv` 將檔案放入 `/opt/simpleweb`，並 restart
service。`az vm run-command invoke` 以 `root` 執行，可直接寫入相同路徑及操作 systemd。
兩種路徑最後都應將 jar 與 `app.env` ownership 設為 `simpleweb:simpleweb`。

### Post-apply verification

`terraform apply` 完成只代表 Azure VM control plane provisioning 已完成；第一次開機的
cloud-init（包含 OpenJDK 21 安裝與 systemd units 建立）可能仍在背景執行。**先等待
cloud-init 完成，再檢查 Java 與 services**，避免把正常的初始收斂誤判為部署失敗：

```powershell
$resourceGroup = terraform output -raw resource_group_name
$linuxVm = terraform output -raw linux_vm_name
$verifyScript = (@'
set -e
cloud-init status --wait --long || true
java -version
id simpleweb
ls -ld /opt/simpleweb/test /opt/simpleweb/prod
systemctl is-enabled simpleweb-test.service simpleweb-prod.service
systemctl is-active simpleweb-test.service simpleweb-prod.service || true
'@ -replace "`r", "")

az vm show `
  --resource-group $resourceGroup `
  --name $linuxVm `
  --query provisioningState `
  --output tsv

az vm run-command invoke `
  --resource-group $resourceGroup `
  --name $linuxVm `
  --command-id RunShellScript `
  --scripts $verifyScript `
  --query "value[0].message" `
  --output tsv
```

預期：cloud-init 為 `done`、Java 為 OpenJDK 21、兩個目錄由 `simpleweb` 擁有、兩個
services 為 `enabled`。在第一個 jar 部署前，services 顯示 `inactive` 是正常狀態。

## Notes and known limitations

- 此 stack 只建立 Azure infrastructure 與 runner binary preinstall，沒有 application
  artifact deployment automation。
- Linux VM 建立完成後，仍須手動將 self-hosted runner 註冊至 GitHub repository、
  organization 或 enterprise；Terraform 不保存 registration token。請參考
  [Adding self-hosted runners](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)。
- Terraform 會忽略既有 Linux VM 的 `custom_data`，因此後續 cloud-init 變更不會自動套用；若要更新，請透過 SSH/手動方式調整，或刻意重建 VM 讓新設定生效。
- Linux Web App 使用 Java SE 21。部署前應確認課程 sample application 與 Azure App
  Service Java runtime support。
- Linux subnet 的 Network Security Group 只持續允許 `8080` 與 `8081`，讓兩個 app
  environments 可公開測試，並允許 `AzureCloud` 來源的 TCP/22 供 Azure/GitHub-hosted
  automation 比較 demo 使用。共享 subscription 的 policy 會移除持續開放的 Internet
  SSH rule；若需要從任意 Internet 來源示範 `07.deploy-ssh`，由講師在 demo 前建立
  **精確命名、短生命週期**的 rule，完成後立即移除：

  ```powershell
  az network nsg rule create `
    --resource-group GH200-0903 `
    --nsg-name lab-linux-nsg-0903-ksh `
    --name AllowSshForDemo `
    --priority 100 `
    --access Allow --direction Inbound --protocol Tcp `
    --source-address-prefixes Internet `
    --destination-port-ranges 22

  # SSH demo 完成後
  az network nsg rule delete `
    --resource-group GH200-0903 `
    --nsg-name lab-linux-nsg-0903-ksh `
    --name AllowSshForDemo
  ```

  SSH 僅允許 key authentication，但開放期間 VM 仍暴露於 Internet；正式環境應改用
  self-hosted runner、固定 egress、Azure Bastion、private networking 或 allowlist。
