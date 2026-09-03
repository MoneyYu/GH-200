# Repository instructions for GH-200

Concise, non-obvious rules for working in this repository. Keep additions here short and
behavioral — this is not a place for narrative history.

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
  credential and RBAC.
- The deployed Java target is `lab-linux-0903-ksh` in `GH200-0903`: test on port `8080`,
  production on `8081`. Production uses a GitHub Environment required-reviewer gate. The same
  Linux VM is also the SSH-only deployment target for `MoneyYu/GH-200`'s `demo-java-04`-`06` and
  hosts the same-VM self-hosted runner demo (`08`), as a classroom simplification.
- The shared Azure subscription enforces policy after deployment: Public IP resources receive a
  `FirstPartyUsage` tag, Windows OS disks use `Standard_LRS`, Web App basic publishing auth stays
  disabled, and persistent Internet-sourced SSH rules are removed. Terraform deliberately
  matches/ignores those policy-owned values so post-deploy `terraform plan` is clean. The active
  Java deployment path (`04`-`06`) is SSH-only to the Linux VM and relies on the
  Terraform-managed `AllowSshFromAzureCloud` rule (source `AzureCloud`, not `Internet`) staying in
  place; if the shared subscription's policy scan removes it, the trainer/user restores the same
  `AllowSshFromAzureCloud` rule manually — never broaden it to `Internet` and never add a
  temporary Internet-facing SSH rule.

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
- The user explicitly authorized one reviewed, one-off apply of `GH200-0903` for this delivery.
  It completed with 18 added / 0 changed / 0 destroyed. **Do not run apply again and do not run
  destroy before the class.**
- The user separately authorized **one reviewed Terraform apply for the SSH-only refactor**
  (Windows VM/Web App removal, Linux Web App conversion, `linux_ssh_public_key` variable,
  `AllowSshFromAzureCloud` NSG rule, runner-preinstall extension) after reviewing its plan. Only
  `plan` has been run for that refactor so far — **do not claim it has been applied, and do not
  run that apply, any further apply, or any destroy without a new explicit user instruction.**
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
