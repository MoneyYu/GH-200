# GH-200 Terraform 備援環境

此目錄提供 GH-200T00-A **Automate your workflow with GitHub Actions** 課程的 trainer
backup/fallback stack。課堂中應由 trainer 現場建立 Azure resources；若現場建立失敗，
可使用此 Terraform configuration 快速建立替代環境。

## 用途與課程對應

此 stack 建立：

- 一部 Windows Server 2022 VM，包含 Microsoft Entra ID login extension 與 IIS。
  預定用於 **M07 — Manage GitHub Actions in the enterprise** 的 self-hosted runner demo，
  也可用來展示 runner infrastructure。
- 一個 Windows App Service plan 與 Windows Web App。
  預定用於 **M03 — Build and deploy applications to Azure by using GitHub Actions**，
  作為 `azure/webapps-deploy` action 的 deployment target。

## Prerequisites

- Terraform `>= 1.0`
- Azure CLI，並已執行 `az login`
- 可建立 resources 的 Azure subscription
- 在 `japaneast` region 具備所需 quota
- 由環境提供 Azure subscription，例如設定 `ARM_SUBSCRIPTION_ID`

## Variables

| Name | Type | Default | Required? | Description |
|---|---|---:|:---:|---|
| `group_postfix` | `string` | 無 | 是 | Resource group suffix；只接受 1–10 個小寫英文字母或數字，符合 `^[a-z0-9]{1,10}$`。 |
| `user_name` | `string` | `demouser` | 否 | Windows VM 的 local administrator username。 |
| `user_password` | `string` | 無 | 是 | Windows VM 的 local administrator password；為 sensitive variable，必須在執行時提供。 |

建議透過 `TF_VAR_user_password` 提供密碼，避免把密碼寫入 `.tf` 或命令歷程：

```powershell
$securePassword = Read-Host "Enter the VM administrator password" -AsSecureString
$env:TF_VAR_user_password = [System.Net.NetworkCredential]::new("", $securePassword).Password
```

也可使用 `-var "user_password=<password>"`，但密碼可能留在 shell history，因此不建議。

## Usage

```powershell
cd TERRAFORM
terraform init
terraform plan -var "group_postfix=0903"
```

> [!WARNING]
> 本 repo 明確禁止 AI agent 執行 `terraform apply`。Trainer 檢查 plan 後，必須自行手動執行：
>
> ```powershell
> terraform apply -var "group_postfix=0903"
> ```

課程結束後，由 trainer 手動清除本 stack：

```powershell
terraform destroy -var "group_postfix=0903"
Remove-Item Env:\TF_VAR_user_password
```

## Naming

`group_postfix` 決定 resource group 名稱，例如 `group_postfix=0903` 會建立
`GH200-0903`。其他 resource names 使用
`local.resource_suffix = "<group_postfix>-<random_str>"`；固定的
`local.random_str = "ksh"` 讓同一場次重跑時名稱維持穩定：

- VM：`lab-vm-0903-ksh`
- Public IP：`lab-pip-0903-ksh`
- Virtual network：`lab-vnet-0903-ksh`
- Network interface：`lab-nic-0903-ksh`
- App Service plan：`lab-app-plan-0903-ksh`
- Windows Web App：`gh200-web-0903-ksh`

## Notes and known limitations

- 此 stack 只建立 Azure infrastructure，沒有 application/data-plane automation。
- VM 的 Standard public IP 已連接至 network interface，但此 stack 未建立 Network Security
  Group 或 inbound rules；如需 RDP 或瀏覽 IIS，trainer 必須另外建立限制來源 IP 的 rule。
- VM 建立完成後，仍須手動將 self-hosted runner 註冊至 GitHub repository、
  organization 或 enterprise。請參考
  [Adding self-hosted runners](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)。
- `user_password` 標示為 sensitive 可避免一般 CLI output 顯示，但 Terraform state
  仍會保存 VM administrator password；請使用安全的 remote backend 與適當 access control。
- Windows Web App 使用 .NET 8。部署前應確認課程 sample application 的 target framework
  與 Azure App Service runtime support。
