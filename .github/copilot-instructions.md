# Repository instructions for GH-200

Concise, non-obvious rules for working in this repository. Keep additions here short and
behavioral — this is not a place for narrative history.

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
  this private repo replaces required reviewers with explicit `workflow_dispatch` confirmations
  (`05`: `confirm=deploy` plus a full `build_sha`; `06`: `confirm_production=deploy`) and owns the
  persistent live self-hosted runner; the public class repo uses the real production reviewer gate
  and keeps workflow `08` inert.

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
.\mvnw.cmd -B "-Dtest=InfoServiceTest#exposesTheBuildMetadataInjectedByCi" test

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
  workflow migration fixes all references; do not move the Java project back to root as
  a workaround. Because workflows `01`-`03` also have root-relative `push.paths` filters, commit
  their path migration in the same change as the Java move or the move commit will automatically
  trigger failing builds.
- If a committed checkout does not yet contain `DEMO/JAVA` but still contains the root Maven
  project, it predates the in-progress Java move described here; do not fabricate the target
  directory or treat the old root layout as the desired end state.
- If `DEMO/README.md` or trainer docs still describe root-level `pom.xml`, `src/`, Maven Wrapper,
  or `target/simpleweb.jar`, treat those references as pending the same path migration rather than
  moving the Java project back to match them.
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
  `.github/instructions/terraform.instructions.md` establishes the provider floor and apply ban,
  but the stricter apply/destroy single source of truth below overrides it.
  `.github/instructions/commit.instructions.md` remains authoritative for commit messages.
- `.mcp.json` already configures Playwright, Context7, Chrome DevTools, and Microsoft Learn.
  npm-based MCP servers use the local proxy registry, and Context7 requires the configured
  `CONTEXT7_API_KEY` input; do not add duplicate server entries.

## Course identity

- This repo is the reference/prep repo for **GH-200T00-A — "Automate your workflow with GitHub
  Actions"**: a **1-day** ESI/MCT instructor-led course, Intermediate level.
- The course is **7 modules across two Microsoft Learn learning paths** — do not treat it as one
  path:
  - Part 1 (`training/paths/github-actions/`): **M01** Automate development tasks · **M02** CI
    workflows · **M03** Build and deploy to Azure · **M04** GitHub Script
  - Part 2 (`training/paths/github-actions-2/`): **M05** Publish to GitHub Packages ·
    **M06** Create and publish custom actions · **M07** Manage GitHub Actions in the enterprise
- The related **GH-200: GitHub Actions** certification exam was **significantly rewritten in
  January 2026**. Course content and links must reflect the current objectives (service
  containers, YAML anchors/aliases, matrix strategies, job summaries, OIDC federation, immutable
  actions, artifact attestations, script-injection mitigation, starter vs reusable vs composite).
  Do not reuse pre-2026 material without re-checking it against the study guide.
- The course grants only an **Achievement Code** — there is **no Applied Skills credential**. Never
  add an `## Applied Skills` section to `README.md`.

## 2026-09-03 customer delivery

- This delivery uses the customer's certification-domain numbering rather than the official
  seven-module Learn sequence: **M1 Design and Manage Workflows**, **M2 Consume and Troubleshoot
  Workflows**, **M3 not taught**, **M4 Manage GitHub Actions in the Enterprise**, and **M5 Secure
  and Optimize Automation**. Keep the M3 numbering gap.
- **Do not add these removed topics back into the taught agenda:** Reusable Workflows, Matrix
  Strategy, or Author and Maintain Actions (the whole M3). Cache is concept-only. OIDC examples
  target Azure. Workflow Templates focus on Angular, React, Node.js, Python, Java, and C#.
- The class repo is `MoneyDemo/20260903-GH200`. It contains a Java 21 / Spring Boot 4.1.1 demo,
  progressive workflows `01`–`09`, and fill-in-the-blank student labs. CI labs run in student
  forks; CD labs are trainer-run by default because each fork needs its own exact OIDC federated
  credential and RBAC. **Both repos' active workflows use the same SSH-only VM deployment
  design**: `04`-`06` SSH-only to the Linux VM, `07` (`07.deploy-webapp` /
  `demo-java-07-deploy-webapp`) the Azure OIDC/PaaS contrast to the Linux Web App, `08` the
  same-VM self-hosted runner contrast. The class repo's earlier runs that used Azure OIDC +
  `az vm run-command` for its own `04` (with a separate `07.deploy-ssh` as the SSH contrast) are
  **pre-refactor historical evidence only** — do not treat them as the current class-repo design,
  and do not claim those historical runs used SSH. Nothing in either repo's active workflows uses
  Azure Run Command or Azure Arc; do not reintroduce that as an active path.
- The deployed Java target is `lab-linux-0903-ksh` in `GH200-0903`: test on port `8080`,
  production on `8081`. The class repo `MoneyDemo/20260903-GH200`'s `production` uses a GitHub
  Environment required-reviewer approval gate; `MoneyYu/GH-200` has no required reviewers and
  instead gates production with explicit `workflow_dispatch` confirmations (`05`:
  `confirm=deploy` plus a full `build_sha`; `06`: `confirm_production=deploy`) — keep the two
  distinct and never describe `MoneyYu/GH-200` as having a required-reviewer gate. The same
  Linux VM is also the SSH-only deployment target for `MoneyYu/GH-200`'s `demo-java-04`-`06` and
  hosts the same-VM self-hosted runner demo (`08`), as a classroom simplification.
- **Self-hosted runner safety (persistent private runner; zero public runner; inert class 08).**
  The `MoneyYu/GH-200` self-hosted runner is 常駐課程基礎設施 (persistent course infrastructure)
  that stays registered/online for `demo-java-08`; it is **not** ephemeral and is not deregistered
  after the demo — it is the **only** live same-VM runner demo. The public class repo
  `MoneyDemo/20260903-GH200` intentionally has zero registered self-hosted runners, and its
  `08.selfhosted-runner` is an **inert reference artifact**: its job is hard-skipped with the
  literal `if: ${{ false }}`, so it never runs on the public upstream **or on any learner fork or
  private copy** (there is no learner-side runner path in the course). Do not write instructions
  that register a runner to the public class upstream or to any learner fork/copy, that point a
  learner runner at the shared course VM, that say the private runner should be removed after the
  demo, or that claim the runner count returns to zero after a run. The class Lab 07 is an
  observation/design exercise; any optional hands-on runner belongs on a separate,
  instructor-approved isolated machine and a separate private repository, never course resources.
- **Live-run evidence and access retirement are both complete** — do not re-describe either as
  "pending validation" anywhere in this repo. Both repos have live `workflow_dispatch` success
  evidence for `04`-`06` (SSH-only), `07`/`demo-java-07-deploy-webapp` (OIDC + Azure CLI JAR
  deploy, including a run in each repo dispatched *after* the retirement below), and `08`; `09`
  has its expected-failure evidence. See `docs/demo-environment.md` for the run links — do not
  duplicate raw run IDs here. The old shared Azure identity used for VM/Blob access before the
  SSH-only refactor (its four federated identity credentials, `Virtual Machine Contributor`,
  `Storage Blob Data Contributor`, and the Linux VM's `Storage Blob Data Reader`) has been
  removed. The class repo's Lab 06 broken-3/fixed-3 M2 OIDC troubleshooting exercise **no longer
  references `AZURE_WEBAPP_CLIENT_ID` or any `secrets.*`**: it uses all-zero placeholder UUIDs
  (`00000000-0000-0000-0000-000000000000`) for client/tenant/subscription. `AZURE_WEBAPP_CLIENT_ID`
  is used only by `07`. Student forks receive no Azure identity; the broken case fails before Azure
  login on the missing `id-token: write`, and the fixed case (`contents: read` + `id-token: write`)
  obtains the OIDC token and then fails at Azure auth on the placeholder identity — both are the
  expected two-stage outcomes. Never reuse the retired shared identity for a deployment, and never
  describe it as a valid live identity. Both repos'
  repository-level
  `VM_SSH_PRIVATE_KEY` copies have been deleted; the secret now exists only as `test`/`production`
  Environment secrets. Both repos also now restrict `test`/`production` Environment deployments
  to their default branch; MoneyDemo's `production` still keeps its required-reviewer gate on
  top of that.
- **Never dispatch both repos' `07` workflows at the same time.** They share one Linux Web App,
  and concurrent OneDeploy requests have been observed to fail the App Service startup timeout.
  **Rule:** do not start the other repo's `07` until the first repo's `07` run has completed
  successfully *and* the Web App's `/api/info` response has been confirmed to show that run's
  expected commit SHA. Whichever repo's `07` deploys successfully last silently overwrites the
  live app version (last successful deployment wins) — there is no versioned rollback. On a
  collision or a timeout failure, wait for **both** runs to finish, then re-dispatch only the
  repo you actually want live and re-verify its SHA via `/api/info` before treating it as done.
  This is an operational sequencing rule for trainers/agents, not a GitHub cross-repo concurrency
  lock, so do not implement a `concurrency:` group spanning both repos to fake one.
- **VM 部署排序規則（04/05/06/08）.** Both repos' `04`/`05`/`06` (SSH deploy) and `08` (same-VM
  self-hosted runner) write the *same* shared Linux VM `simpleweb-test` (`8080`) and
  `simpleweb-prod` (`8081`) systemd services. Serialize them across the two repos exactly like the
  `07` rule: do not start one repo's VM-deploy workflow (`04`/`05`/`06`/`08`) until the other
  repo's prior run has completed successfully **and** the relevant `8080` or `8081` `/api/info`
  endpoint has been confirmed to show that run's expected commit SHA. This too is a manual
  operator sequencing rule, not a GitHub cross-repo concurrency lock — do not add a fake
  `concurrency:` group spanning both repos.
- The shared Azure subscription enforces policy after deployment: Public IP resources receive a
  `FirstPartyUsage` tag, Windows OS disks use `Standard_LRS`, Web App basic publishing auth stays
  disabled, and persistent Internet-sourced SSH rules are removed. **The Linux VM's OS disk also
  uses `Standard_LRS`** — that is what the live disk (`lab-linux-osdisk-0903-ksh`) actually is, so
  `os_disk.storage_account_type` in `MOD.tf` must stay `Standard_LRS`; setting it to `Premium_LRS`
  makes Terraform force-replace `azurerm_linux_virtual_machine.lab` (destroy and recreate the
  existing VM), which both violates "preserve the existing Linux VM" and bypasses the
  `admin_ssh_key`/`custom_data` `lifecycle.ignore_changes` (those only apply to in-place updates,
  not to a full replace). Terraform deliberately
  matches/ignores those policy-owned values so post-deploy `terraform plan` is clean. The active
  Java deployment path (`04`-`06`) is SSH-only to the Linux VM and relies on the
  Terraform-managed `AllowSshFromAzureCloud` rule (source `AzureCloud`, not `Internet`) staying in
  place; if the shared subscription's policy scan removes it, the trainer/user restores the same
  `AllowSshFromAzureCloud` rule manually — never broaden it to `Internet` and never add a
  temporary Internet-facing SSH rule. Because the NSG only allows source `AzureCloud`, any
  trainer-run SSH or runner-registration command against this VM must come from Azure Cloud Shell
  or another network the NSG explicitly allows — a normal trainer laptop is not covered by that
  rule.

## Labs: there is no lab repo

- GH-200 has **no** `MicrosoftLearning/*` lab repo and **no** `aka.ms/gh200labs`-style shortlink
  (both verified empty/unregistered). The "labs" are the **exercise units inside the Learn
  modules**, done in the attendee's own GitHub account; M03 additionally needs an Azure
  subscription.
- Exercise counts per module are **not uniform**: M01 1 · M02 1 · **M03 3** · M04 1 · M05 1 ·
  M06 1 · **M07 0**. M07 genuinely has no exercise — a link to
  `manage-github-actions-enterprise/exercise/` silently redirects to the module assessment, so it
  must not be presented as an exercise.

## Attendee README vs trainer `docs/`

- `README.md` is the **attendee-facing** course reference, published on **HackMD**. It uses
  HackMD syntax that is *not* plain GitHub Markdown — preserve the YAML front-matter
  (`image`, `tags`, `GA`), the `:::success` / `:::info` admonition blocks, and the
  ` ```markmap ` fenced mind map.
- Keep trainer-private material **out** of `README.md`: demo-environment details, Terraform,
  teaching notes, and internal logistics live under `docs/`.
- README tail order is exactly **Videos → Mind Map → Contact** (no Applied Skills for this course).
- `## Links` is grouped **by module** (`## Foundations`, then `## M01 - …` … `## M07 - …`),
  mirroring the module list above — not by service or product.
- Per-instance metadata to refresh **every delivery**: `Date`, `Course ID`, and the post-course
  survey link.

## Link and video verification (required before every delivery)

- **A HTTP 200 is not enough.** Verify each URL semantically: final URL after redirects, page
  title, and locale. Drop any link that 200s but lands on a generic hub or a different page.
  Known trap in this repo's history: `…/manage-github-actions-enterprise/exercise/` 200s but
  redirects to `…/knowledge-check`.
- **`docs.github.com` restructures often.** Never write a `docs.github.com` URL from memory —
  a recent sweep found 7 of 24 plausible URLs returning 404. Discover the real path from a docs
  index, then verify it.
- Tooling: build a `label | url` ledger covering `README.md` plus `docs/*.md`, then run
  `.venv\Scripts\python.exe .github\skills\course-prep\scripts\link_check.py <ledger>`. The script
  needs only the Python standard library; create the environment once with `uv venv .venv`.
  Ledgers (`urls*.txt`) and `.venv/` are git-ignored — a fresh clone has neither.
- **Videos: first-party channels only.** Microsoft-owned channels *and* GitHub's own channel are
  acceptable (GitHub is Microsoft-owned and the GH-200 study guide itself links
  `youtube.com/github`). Confirm each is LIVE via YouTube oEmbed and record the real
  `author_name`. Reject third-party creators. A module with no qualifying video gets no row —
  never add an "no video found" placeholder.

## TERRAFORM/

- This stack is the trainer's **backup/fallback** only. In class the trainer builds resources
  live; this stands them up if that fails. There is **no Windows VM** in this stack. It maps to
  the course as: **Linux VM → M07 self-hosted runner demo** (same VM as the SSH deploy target,
  a classroom simplification) and **Linux Java Web App → M03 Azure OIDC/PaaS contrast** deploy
  target.
- For the 2026-09-03 customer delivery, the stack also contains an Ubuntu 24.04 VM for the Java
  Build → Test → Package → Deploy story. It runs `simpleweb-test` (8080) and `simpleweb-prod`
  (8081). `cloud-init-java.yaml` installs OpenJDK 21 and creates the systemd units. The active
  Java deployment path (`demo-java-04` through `06`) is **SSH-only** — build once, `scp` the jar,
  `ssh` to run `systemctl restart` — with the Linux VM simulating an on-prem server. It does
  **not** use Azure Run Command, Blob artifact transport, or VM IMDS/managed-identity download;
  `demo-java-07-deploy-webapp` is the Azure OIDC/PaaS contrast to the Linux Web App, not a VM
  deployment path.
- **`terraform apply` is forbidden for the AI agent** (`.github/instructions/terraform.instructions.md`).
  `fmt`, `init`, `validate`, and `plan` are allowed. `terraform destroy` is permitted by the base
  rule but is destructive, so run it only after an explicit user request and confirmation; course
  cleanup is normally trainer-run. Because `apply` is forbidden, never claim an end-to-end
  apply/destroy validation was performed.
- **Terraform apply/destroy policy for `GH200-0903` (single source of truth — do not restate
  this differently in `docs/demo-environment.md` or `TERRAFORM/README.md`).** A historical apply
  ran *before* the SSH-only refactor existed and created the pre-refactor topology (Windows VM,
  Windows Web App, and the original Linux VM): 18 added / 0 changed / 0 destroyed. That is a
  separate, already-completed event, superseded by the SSH-only refactor.
  The **SSH-only refactor** apply (Windows VM/Web App removal, Linux Web App conversion,
  `linux_ssh_public_key` variable, `AllowSshFromAzureCloud` NSG rule, runner-preinstall
  extension) that the user authorized as **exactly one** reviewed apply **has now completed**: it
  removed the Windows stack, created the Linux Java Web App and the runner-preinstall extension,
  changed the NSG (source-restricted `AllowSshFromAzureCloud`), and the post-apply
  `terraform plan` is clean (no drift). That single authorization is now **spent** — **do not run
  or instruct any further `apply`**; every additional apply needs a new explicit user
  authorization. Any `terraform destroy` still needs a new explicit user request and confirmation
  before it may run (course cleanup is normally trainer-run and must not happen before class). Do
  not write generic "trainer may run apply/destroy whenever" instructions anywhere in this repo —
  every apply or destroy invitation must carry this authorization/confirmation gating.
- Preserve the existing unmanaged backend storage: never delete the `tfstate` container or the
  now-orphaned `deployments` Blob container (leftover from the pre-SSH artifact-transport design)
  without a new explicit user instruction; they are out of Terraform's management scope.
- If the shared subscription's policy scan removes the Terraform-managed `AllowSshFromAzureCloud`
  rule, the trainer/user restores it manually and has accepted that risk; the AI agent must not
  silently broaden it to `Internet` or add a substitute rule.
- `azurerm` must be **`~>4.0` or higher**. Write resources from the official provider docs; do not
  invent arguments. `terraform validate` passing is the proof.
- File split: `MAIN.tf` = terraform/provider blocks, variables, locals, resource group;
  `MOD.tf` = all resources; `OUTPUT.tf` = outputs (never secrets). Put new resources in `MOD.tf`.
- Names derive from a single `var.group_postfix` (validated `^[a-z0-9]{1,10}$`) via
  `local.group_name = "GH200-<postfix>"` and
  `local.resource_suffix = "<postfix>-<random_str>"`. Region is
  `local.location = "japaneast"`.
- Apply `tags = local.default_tags` to every taggable resource.
- **No credentials in source.** `var.linux_ssh_public_key` is the only VM identity input and takes
  only a public key; supply it via `TF_VAR_linux_ssh_public_key` or `-var`. SSH private keys are
  never passed to Terraform and never appear in `.tf`, `.tfvars`, or state. `*.tfvars` stays
  git-ignored regardless.
- Active state is stored in the AAD-only Azure backend
  `gh200state0903ksh/tfstate/gh200-0903.tfstate`; shared-key access is disabled. Fresh clones must
  use the backend configuration documented in `TERRAFORM/README.md`. Never download or commit
  state, and never re-enable shared-key authentication.

## What is not committed

- `PPT/` — IRM-protected courseware (the `.pptx` is an encrypted OLE compound file, so speaker
  notes **cannot** be extracted; do not plan work that depends on them).
- `.terraform/`, `*.tfstate*`, `.terraform.lock.hcl`, `*.tfvars`, `.venv/`, and link-check
  ledgers/output. Do not add exceptions for them.
- Binary types are marked `binary` in `.gitattributes` — the global `* text=auto` would otherwise
  corrupt `.pptx`/`.png`/`.pdf`. Add a marker before committing any new binary type.

## Not applicable to this course

- The `course-prep` skill's **Phase 4 (model selection / retirement schedule)** is **N/A** — GH-200
  deploys no Azure AI or Foundry models.
- The skill's Phase 5 real `apply` → `destroy` end-to-end test is **not performable** here because
  `apply` is forbidden; static validation is the accepted substitute.
