---
image: https://learn.microsoft.com/en-us/media/learn/certification/badges/github-actions.svg
tags: GH-200, Reference
GA: G-DXYJBX6BH8
---

# GH-200 Reference

Build, test, package, deploy, troubleshoot, secure, and govern software-development automation with GitHub Actions.

## Course
:::success
Date: 20260903
Course ID: 109066
:::

:::info
Post Course Survey: [https://aka.ms/gh200survey](https://aka.ms/gh200survey)
:::

## Course Materials
[Course GH-200 English version](https://learn.microsoft.com/en-us/training/courses/gh-200t00)
[Course GH-200 简体中文版本](https://learn.microsoft.com/zh-cn/training/courses/gh-200t00)
[Course GH-200 正體中文版本](https://learn.microsoft.com/zh-tw/training/courses/gh-200t00)

## Class Demo Repository

[MoneyDemo/20260903-GH200](https://github.com/MoneyDemo/20260903-GH200) is the class repository for the progressive Java workflow demos and student labs.

The same Java 21 / Spring Boot 4.1.1 demo source is also included directly in this repository
(`pom.xml`, `src/`, Maven Wrapper, and `Dockerfile`). GH-200's active
`demo-java-*` workflows let future deliveries build, test, package, and deploy the demo without
recreating the class repository.

`MoneyYu/GH-200` does not currently have a GitHub plan that supports required reviewers on
Environments. Its full deployment workflow is therefore manual and requires the
`confirm_production=deploy` input. Use the class repository above when demonstrating the real
required-reviewer approval gate.

## Infos
[Learner Experience Portal](https://esi.microsoft.com/)
[ESI Support](https://aka.ms/esisupport)

## Lab
### Skillable lab system
[ESI Labs](https://aka.ms/esilab)
:::success
Training key: 53F35FFC16441C69
:::

### Class repository labs

Start from [MoneyDemo/20260903-GH200](https://github.com/MoneyDemo/20260903-GH200).
Open the [student lab index](https://github.com/MoneyDemo/20260903-GH200/blob/main/labs/README.md)
and complete `lab01-first-workflow.md` through `lab06-troubleshooting.md`;
`lab07-selfhosted-runner.md` is optional.

Follow the progressive workflows in `.github/workflows`: `01.build` → `02.build-test` → `03.package-artifact` → `04.deploy-test` → `05.deploy-prod` → `06.full-pipeline`. Use `07.deploy-ssh`, `08.selfhosted-runner`, and `09.troubleshooting` as instructor-led contrasts and troubleshooting material.

## Course Info
![Course overview](https://mdcontent.yu.money/contents/f008fce23003844339a3ac100.zh-TW.png)

## Links

### Foundations
[Understanding GitHub Actions and its components](https://docs.github.com/en/actions/get-started/understand-github-actions)
[Workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
[Expressions](https://docs.github.com/en/actions/reference/workflows-and-actions/expressions)
[Contexts](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts)
[GitHub-hosted runners](https://docs.github.com/en/actions/concepts/runners/github-hosted-runners)
[GitHub Marketplace Actions](https://github.com/marketplace?type=actions)
[GitHub Actions billing and usage](https://docs.github.com/en/actions/concepts/billing-and-usage)

### M1 — Design and Manage Workflows
[Microsoft Learn: Automate development tasks](https://learn.microsoft.com/en-us/training/modules/github-actions-automate-tasks/)
[Events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)
[Manual workflow_dispatch events](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_dispatch)
[Scheduled workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
[Variables and default environment variables](https://docs.github.com/en/actions/reference/workflows-and-actions/variables)
[Using secrets in GitHub Actions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
[Workflow artifacts](https://docs.github.com/en/actions/concepts/workflows-and-actions/workflow-artifacts)
[Dependency caching](https://docs.github.com/en/actions/concepts/workflows-and-actions/dependency-caching) — concept only in this delivery

### M2 — Consume and Troubleshoot Workflows
[Microsoft Learn: Build continuous integration workflows](https://learn.microsoft.com/en-us/training/modules/github-actions-ci/)
[Continuous integration](https://docs.github.com/en/actions/get-started/continuous-integration)
[Workflow templates](https://docs.github.com/en/actions/how-tos/write-workflows/use-workflow-templates)
[Debug logging](https://docs.github.com/en/actions/how-tos/monitor-workflows/enable-debug-logging)
[Workflow commands, GITHUB_ENV, and GITHUB_OUTPUT](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands)
[Workflow concurrency](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency)

Workflow-template examples in this delivery focus on Angular and React frontends, plus node, python, java, and c# backends.

### M4 — Manage GitHub Actions in the Enterprise
[Microsoft Learn: Manage GitHub Actions in the enterprise](https://learn.microsoft.com/en-us/training/modules/manage-github-actions-enterprise/)
[Organization Actions policies and allow-lists](https://docs.github.com/en/organizations/managing-organization-settings/disabling-or-limiting-github-actions-for-your-organization)
[Enterprise Actions policies](https://docs.github.com/en/enterprise-cloud@latest/admin/enforcing-policies/enforcing-policies-for-your-enterprise/enforcing-policies-for-github-actions-in-your-enterprise)
[Organization workflow templates](https://docs.github.com/en/actions/how-tos/reuse-automations/create-workflow-templates)
[Self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)
[Add self-hosted runners](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)
[Runner groups](https://docs.github.com/en/actions/concepts/runners/runner-groups)
[Runner groups and access management](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/manage-access)

### M5 — Secure and Optimize Automation
[Microsoft Learn: Build and deploy applications to Azure](https://learn.microsoft.com/en-us/training/modules/github-actions-cd/)
[Deployment environments](https://docs.github.com/en/actions/concepts/workflows-and-actions/deployment-environments)
[Manage environments and protection rules](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
[GitHub Actions OIDC for Azure](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
[Authenticate to Azure from GitHub Actions with OIDC](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
[GITHUB_TOKEN permissions and security](https://docs.github.com/en/actions/concepts/security/github_token)
[Secure Actions use and full-SHA pinning](https://docs.github.com/en/actions/reference/security/secure-use#using-third-party-actions)
[Script injection security](https://docs.github.com/en/actions/concepts/security/script-injections)
[Artifact and log retention policy](https://docs.github.com/en/organizations/managing-organization-settings/configuring-the-retention-period-for-github-actions-artifacts-and-logs-in-your-organization)

## Demo GitHub
[GitHub: MoneyDemo](https://github.com/MoneyDemo)
[Class demo repository](https://github.com/MoneyDemo/20260903-GH200)

## Exam
[GH-200 Exam Page](https://learn.microsoft.com/en-us/credentials/certifications/github-actions/)
[Practice Assessment](https://learn.microsoft.com/en-us/credentials/certifications/github-actions/practice/assessment?assessment-type=practice&assessmentId=1001&practice-assessment-type=certification)
[Study Guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-200)
[Exam duration and exam experience](https://learn.microsoft.com/en-us/credentials/support/exam-duration-exam-experience)
[GitHub certification sandbox](https://ghcertdemo.starttest.com/)
[Microsoft certification exam sandbox](https://mscertdemo.starttest.com/)
[Microsoft Exam FAQ](https://learn.microsoft.com/en-us/credentials/certifications/online-exams)
[Renew your Microsoft Certifications for free](https://youtu.be/X7ydip-GWVw)

![Exam information](https://mdcontent.yu.money/contents/31b5b0d6ee886b9be732c5f03.png)

SVG: [exam.svg](https://mttcontent.yu.money/common/exam.svg)

## Videos
| No. | Name | Module | Link |
| --- | --- | --- | --- |
| 1 | Course Preview — GH-200 — Automate your workflow with GitHub Actions | Foundations | [youtu.be/wuHiemCckNo](https://youtu.be/wuHiemCckNo) |
| 2 | How to use GitHub Actions — GitHub for Beginners | M1 | [youtu.be/BQrohJ3PT7I](https://youtu.be/BQrohJ3PT7I) |
| 3 | 5 ways to automate everyday workflows with GitHub Actions | M2 | [youtu.be/2p1D29zJdBI](https://youtu.be/2p1D29zJdBI) |
| 4 | Securely building GitHub on GitHub | M5 | [youtu.be/eig5tJUl688](https://youtu.be/eig5tJUl688) |

## Mind Map
```markmap
# GH-200 · Customer delivery

## Foundations
- Workflow, event, job, step, action, runner
- YAML structure, expressions, contexts, and GitHub-hosted runners
- Class demo: Java Spring Boot 4.1.1 / Java 21 / Maven with Maven Wrapper
- App endpoints: `/`, `/api/info`, `/actuator/health`

## M1 — Design and Manage Workflows
- Events and triggers; `workflow_dispatch`
- Jobs, steps, dependencies, variables, and secrets
- Artifact management; cache is a performance concept only
- **Build spine**: `01.build` → `02.build-test` → `03.package-artifact`

## M2 — Consume and Troubleshoot Workflows
- Inspect workflow execution, logs, and debug output
- Failure troubleshooting
- Workflow templates for Angular / React and node / python / java / c#
- **Lab**: use the progressive workflow logs and `09.troubleshooting`

## M4 — Manage GitHub Actions in the Enterprise
- Enterprise governance and organization policies
- Self-hosted runner management and runner groups
- Secrets and variables governance; enterprise templates
- Contrast: `08.selfhosted-runner` runs on the Azure Ubuntu VM

## M5 — Secure and Optimize Automation
- Least-privilege permissions and secure action use
- OIDC to Azure; environment protection and approval gates
- Test (`8080`) and production (`8081`) systemd services on the Azure Ubuntu 24.04 VM
- **Deploy spine**: `04.deploy-test` → `05.deploy-prod` → `06.full-pipeline`
- Contrast: `az vm run-command` + OIDC (primary) vs `07.deploy-ssh`
- Workflow performance and cost optimization
```

## Contact
- Money Yu
- Mail: [Money.Yu@microsoft.com](mailto:Money.Yu@microsoft.com)
- LinkedIn: `@abc12207`
