# Copilot Instructions Enhancement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance `.github/copilot-instructions.md` with verified repository commands, architecture,
and cross-file conventions while preserving its existing course and infrastructure safeguards.

**Architecture:** Add one compact operational section immediately after the file introduction, then
leave the existing detailed course, delivery, README, link-check, and Terraform rules intact. The
new section treats `DEMO/JAVA` as the intended Java location and uses a condition-based warning for
workflows that have not yet migrated their root-relative paths.

**Tech Stack:** Markdown, Java 21, Spring Boot 4.1.1, Maven Wrapper, GitHub Actions, Terraform
`azurerm ~> 4.0`, PowerShell.

## Global Constraints

- Modify only `.github/copilot-instructions.md`; do not edit workflows, Java sources, Terraform, or
  the user's in-progress Java move.
- Preserve every existing course identity, shared-target sequencing, self-hosted runner, credential,
  and Terraform apply/destroy rule.
- Treat `DEMO/JAVA` as the intended Java project location.
- Do not run or recommend `terraform apply`.
- Do not dispatch any `demo-java-*` workflow while its Java paths are incompatible with
  `DEMO/JAVA`.
- Keep the added instructions concise, behavioral, and repository-specific.

---

### Task 1: Add the operational repository guide

**Files:**
- Modify: `.github/copilot-instructions.md:4`

**Interfaces:**
- Consumes: `DEMO/JAVA/pom.xml`, `.github/workflows/demo-java-*.yml`,
  `TERRAFORM/README.md`, `.mcp.json`, `.github/instructions/*.md`, and `.github/skills/*/SKILL.md`.
- Produces: A repository-level instruction section used by future Copilot sessions.

- [ ] **Step 1: Capture the pre-edit safeguards**

Run:

```powershell
git --no-pager diff -- .github/copilot-instructions.md
Select-String -Path .github\copilot-instructions.md `
  -Pattern "^## ","terraform apply","Never dispatch","VM 部署排序","Self-hosted runner safety"
```

Expected: no pre-existing working-tree diff for `.github/copilot-instructions.md`; the existing
headings and safety rules are visible. If the file already has unrelated user edits, preserve them
and apply the new section around them.

- [ ] **Step 2: Insert the operational section after the introduction**

Insert the following text after the introductory paragraph and before `## Course identity`:

````markdown
## Working map

- `README.md` is attendee-facing HackMD content; trainer-only environment details and teaching
  notes belong in `docs/`.
- `DEMO/JAVA/` is the Java 21 / Spring Boot 4.1.1 demo. It uses the Maven Wrapper and produces
  `DEMO/JAVA/target/simpleweb.jar`.
- `.github/workflows/demo-java-01` through `09` are a progressive teaching sequence: `01`-`06`
  are the main build/test/package/SSH-deploy path; `07` is the Azure OIDC/App Service contrast;
  `08` is the private-repo same-VM self-hosted runner contrast; `09` is intentional
  troubleshooting material.
- `TERRAFORM/` is the trainer fallback stack for the shared Linux VM, Linux Web App, and runner
  preinstallation. It is not the primary classroom provisioning path.
- `MoneyYu/GH-200` and `MoneyDemo/20260903-GH200` share deployment targets but intentionally differ:
  this private repo uses `confirm_production=deploy` and owns the persistent live self-hosted
  runner; the public class repo uses the real production reviewer gate and keeps workflow `08`
  inert.

## Build, test, and static checks

Run Java commands from `DEMO\JAVA` with JDK 21:

```powershell
# Build/package without tests
.\mvnw.cmd -B -DskipTests package

# Full verification: unit tests, integration tests, and package
.\mvnw.cmd -B verify

# All unit tests
.\mvnw.cmd -B test

# One unit-test class or method
.\mvnw.cmd -B -Dtest=InfoServiceTest test
.\mvnw.cmd -B -Dtest=InfoServiceTest#exposesTheBuildMetadataInjectedByCi test

# One Failsafe integration-test class or method without running unit tests
.\mvnw.cmd -B verify "-Dtest=none" "-Dsurefire.failIfNoSpecifiedTests=false" "-Dit.test=SimpleWebApplicationIT"
.\mvnw.cmd -B verify "-Dtest=none" "-Dsurefire.failIfNoSpecifiedTests=false" "-Dit.test=SimpleWebApplicationIT#healthEndpointReportsUp"
```

Quote any Maven `-D` argument containing dots in its property name or value when running it in
PowerShell. This Maven project has no separately configured Java lint plugin; use compilation and
`verify` as its Java quality gates.

Run Terraform static checks from `TERRAFORM\`:

```powershell
terraform fmt -check
terraform init -backend=false
terraform validate
```

A real `terraform plan -var "group_postfix=0903"` requires the documented AAD backend
initialization, `az login`, `ARM_SUBSCRIPTION_ID`, and `TF_VAR_linux_ssh_public_key`. Never run
`terraform apply`; the detailed authorization rules below remain authoritative.

For delivery link validation, follow the authoritative `Link and video verification` section
below; it defines the ledger format, environment setup, and exact checker command.

## Cross-file conventions

- When the Java project path changes, update workflow path filters, `working-directory` or command
  paths, Maven Wrapper invocations, and artifact upload/deploy paths together. If any
  `demo-java-*` workflow still uses root-relative `src/**`, `./mvnw`, or
  `target/simpleweb.jar` while the project lives in `DEMO/JAVA`, do not dispatch it until a
  separate workflow migration fixes all references; do not move the Java project back to root as
  a workaround.
- Maven resource filtering bakes the full commit SHA and UTC build time into the JAR. Deployment
  verification must read `/api/info` and compare the full `buildSha`; HTTP 200 alone is
  insufficient.
- Workflows `04`-`06` deploy the GitHub Actions artifact to the VM over SSH; `07` deploys the same
  app to App Service through Azure OIDC. Do not reintroduce Azure Run Command, Blob artifact
  transport, or VM managed-identity download into the active path.
- Shared VM and Web App workflows must follow the manual cross-repository sequencing rules below;
  a repository-local `concurrency:` group cannot serialize both repositories.
- `.github/skills/` contains the repository-specific course preparation, commit, and GitHub issue
  workflows; use the matching skill when applicable. The inherited TypeScript/Vue/Hono guidance
  and TypeScript test guidance in `.github/instructions/code-review.instructions.md` and
  `.github/instructions/testing.instructions.md` is not an architecture description for this
  Java/Terraform repo and must not be copied into this file.
  `.github/instructions/terraform.instructions.md` and
  `.github/instructions/commit.instructions.md` remain authoritative for their respective scopes.
- `.mcp.json` already configures Playwright, Context7, Chrome DevTools, and Microsoft Learn.
  npm-based MCP servers use the local proxy registry, and Context7 requires the configured
  `CONTEXT7_API_KEY` input; do not add duplicate server entries.
````

- [ ] **Step 3: Check the documentation diff**

Run:

```powershell
git --no-pager diff --check -- .github/copilot-instructions.md
git --no-pager diff -- .github/copilot-instructions.md
```

Expected: no whitespace errors; only the new operational section appears, and all pre-existing
safety sections remain unchanged.

- [ ] **Step 4: Verify the documented Maven commands**

Run from `DEMO\JAVA`:

```powershell
.\mvnw.cmd -B clean -DskipTests package
.\mvnw.cmd -B verify
.\mvnw.cmd -B test
.\mvnw.cmd -B -Dtest=InfoServiceTest test
.\mvnw.cmd -B -Dtest=InfoServiceTest#exposesTheBuildMetadataInjectedByCi test
.\mvnw.cmd -B verify "-Dtest=none" "-Dsurefire.failIfNoSpecifiedTests=false" "-Dit.test=SimpleWebApplicationIT"
.\mvnw.cmd -B verify "-Dtest=none" "-Dsurefire.failIfNoSpecifiedTests=false" "-Dit.test=SimpleWebApplicationIT#healthEndpointReportsUp"
```

Expected:

- each command exits `0`;
- the package exists at `DEMO\JAVA\target\simpleweb.jar`;
- the single unit-test output contains `Running money.gh200.simpleweb.service.InfoServiceTest`;
- the single unit-test-method output reports `Tests run: 1`;
- the selected integration-test output contains
  `Running money.gh200.simpleweb.SimpleWebApplicationIT` and `Tests run: 3`;
- the selected integration-test-method output reports `Tests run: 1`;
- do not accept stale reports or `BUILD SUCCESS` alone as proof that a selected test ran.

- [ ] **Step 5: Verify Terraform static commands**

Run from `TERRAFORM`:

```powershell
terraform fmt -check
terraform init -backend=false
terraform validate
```

Expected: all commands exit `0`; no backend state is read or modified; `terraform apply` is not
run.

- [ ] **Step 6: Confirm acceptance and preserved safeguards**

Run:

```powershell
Select-String -Path .github\copilot-instructions.md `
  -Pattern "DEMO/JAVA","InfoServiceTest","SimpleWebApplicationIT","terraform init -backend=false","Cross-file conventions","CONTEXT7_API_KEY"
Select-String -Path .github\copilot-instructions.md `
  -Pattern "terraform apply","Never dispatch both repos","VM 部署排序規則","Self-hosted runner safety","Achievement Code"
$linkCheckHits = @(Select-String -Path .github\copilot-instructions.md -Pattern 'link_check\.py')
if ($linkCheckHits.Count -ne 1) {
  throw "link_check.py must appear exactly once; found $($linkCheckHits.Count)"
}
```

Expected: every new acceptance topic appears, and the existing safety constraints still appear.
Also confirm the existing `Link and video verification` section still contains the exact
`link_check.py <ledger>` command, and compare the documented `terraform plan` prerequisites
against `TERRAFORM\README.md` and `TERRAFORM\MAIN.tf`; the documentation task does not execute a
credentialed remote-state plan.

- [ ] **Step 7: Run the Implementation Gate review**

Treat this repository-wide agent instruction change as high risk because future agents execute its
behavioral guidance. Run three council reviewers (including correctness and safety) plus one
independent Rubber Duck, then apply only findings that meet the repository harm threshold. After
fixes, perform diff-scoped re-review by the finding authors and the independent Rubber Duck; stop
after at most five gate rounds and freeze the file once Clean.

- [ ] **Step 8: Commit only the instruction change**

```powershell
git add -- .github/copilot-instructions.md
git --no-pager diff --cached --name-only
git commit --only -m "docs(config): document GH-200 Copilot workflows" `
  -m "Add verified commands, architecture, and cross-file conventions for future Copilot sessions while preserving the existing course and infrastructure safeguards." `
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" `
  -m "Copilot-Session: 28ca97f7-90db-48e5-a571-a056b86a4723" `
  -- .github/copilot-instructions.md
git --no-pager show --stat --oneline HEAD
$committed = @(git show --name-only --format= HEAD | Where-Object { $_ })
if ($committed.Count -ne 1 -or $committed[0] -ne '.github/copilot-instructions.md') {
  throw "Commit contains unexpected paths: $($committed -join ', ')"
}
```

Expected: the staged-name check may list unrelated user-staged files; do not unstage or modify
them. The post-commit assertion proves this commit contains only `.github/copilot-instructions.md`;
the user's Java move and README edits remain uncommitted and untouched.
