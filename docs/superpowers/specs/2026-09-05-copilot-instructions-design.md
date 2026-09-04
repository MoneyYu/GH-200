# Copilot Instructions Enhancement Design

## Goal

Improve `.github/copilot-instructions.md` so future Copilot sessions can quickly operate this
repository without removing its existing course, deployment, security, and Terraform safeguards.
The instructions will describe the intended post-reorganization layout where the Java demo lives
under `DEMO/JAVA`.

## Acceptance Checklist

### Before implementation

- [x] Preserve the existing `.github/copilot-instructions.md` and enhance it rather than replacing
  it wholesale.
- [x] Treat `DEMO/JAVA` as the Java demo's intended location.
- [x] Limit the implementation change to `.github/copilot-instructions.md`.
- [x] Preserve existing course identity, shared-environment sequencing, self-hosted runner,
  credential, and Terraform apply/destroy constraints.

### After implementation

- [ ] Document the supported Java build, full test, unit-test, integration-test, and single-test
  commands from `DEMO/JAVA`.
- [ ] Document Terraform formatting, initialization, validation, and plan commands without
  authorizing or running `terraform apply`.
- [ ] State clearly when no separate Java lint command exists rather than inventing one.
- [ ] Treat the Markdown link checker and `terraform fmt -check` as the repository's available
  static checks, while distinguishing them from a Java linter.
- [ ] Explain the high-level relationship among the attendee README, trainer documentation, Java
  demo, progressive workflows, Terraform fallback stack, and shared deployment targets.
- [ ] Capture cross-file conventions that require repository-wide context, including artifact
  provenance, environment differences between the two repositories, shared-target serialization,
  and path-sensitive workflow maintenance after the `DEMO/JAVA` move.
- [ ] State conditionally that workflows must not be dispatched if they still use root-relative
  Java paths after the project lives in `DEMO/JAVA`; a separate migration must update path filters,
  working directories, Maven commands, and artifact paths together.
- [ ] Incorporate relevant existing instruction files, repository skills, and `.mcp.json` without
  copying unrelated TypeScript, Vue, Hono, or Vitest guidance into the repository-level
  instructions.
- [ ] Keep the new material concise, behavioral, and free of generic development advice.
- [ ] Verify every documented local command against the repository's actual Maven and Terraform
  configuration or existing workflow usage.

## Chosen Approach

Use a surgical enhancement:

1. Add a compact operational section near the top of `.github/copilot-instructions.md`.
2. Describe the intended `DEMO/JAVA` workspace and the commands that future sessions should run
   from it.
3. Add a high-level architecture and cross-file conventions section that links the existing
   detailed safety rules into a usable mental model.
4. Leave the existing detailed domain rules in place, changing only statements that conflict with
   the intended `DEMO/JAVA` layout.

This approach minimizes the risk of dropping safeguards that were accumulated from verified live
course operations. A concise rewrite was rejected because it could erase operational constraints;
splitting the instructions into more path-specific files was rejected because it would expand the
scope and require separately cleaning unrelated inherited instruction files.

## Command Model

Java commands run from `DEMO/JAVA` on Windows:

- Build/package without tests: `.\mvnw.cmd -B -DskipTests package`
- Full verification, including unit and integration tests: `.\mvnw.cmd -B verify`
- All unit tests: `.\mvnw.cmd -B test`
- One unit-test class: `.\mvnw.cmd -B -Dtest=InfoServiceTest test`
- One unit-test method: `.\mvnw.cmd -B -Dtest=InfoServiceTest#methodName test`
- One integration-test class:
  `.\mvnw.cmd -B verify "-Dtest=none" "-Dsurefire.failIfNoSpecifiedTests=false" "-Dit.test=SimpleWebApplicationIT"`
- One integration-test method:
  `.\mvnw.cmd -B verify "-Dtest=none" "-Dsurefire.failIfNoSpecifiedTests=false" "-Dit.test=SimpleWebApplicationIT#methodName"`

The Maven build produces `DEMO/JAVA/target/simpleweb.jar`. There is no separately configured Java
lint plugin; compilation and test verification are the available Java quality gates. JDK 21 is
required. Quote any Maven `-D` argument containing dots in its property name or value when running
it in PowerShell.

Terraform commands run from `TERRAFORM`:

- `terraform fmt -check`
- offline syntax-validation initialization: `terraform init -backend=false`
- backend-aware `terraform init` using the documented Azure Storage settings when a real plan is
  required and the operator has completed `az login` with the required data-plane access
- `terraform validate`
- `terraform plan -var "group_postfix=0903"` with the SSH public key supplied through
  `TF_VAR_linux_ssh_public_key` and the Azure subscription supplied through
  `ARM_SUBSCRIPTION_ID`

The instructions must retain the prohibition on agent-run `terraform apply`.

Repository-level static checks also include the standard-library link checker documented in the
existing instructions:
`.venv\Scripts\python.exe .github\skills\course-prep\scripts\link_check.py <ledger>`.

## Architecture to Document

- `README.md` is attendee-facing HackMD content and must not absorb trainer-private details.
- `docs/` contains trainer guidance, live-environment evidence, and operational boundaries.
- `DEMO/JAVA` is the Java 21 / Spring Boot 4.1.1 application used by the demos.
- `.github/workflows/demo-java-01` through `09` form a progressive teaching sequence, with `01` to
  `06` as the main build-to-deploy path and `07` to `09` as contrasts or troubleshooting material.
- `TERRAFORM/` is a trainer fallback stack for the shared Linux VM, Linux Web App, and runner
  preinstallation; it is not the primary classroom provisioning path.
- `MoneyYu/GH-200` and `MoneyDemo/20260903-GH200` share deployment targets but intentionally differ
  in production gating and self-hosted runner availability.

## Cross-File Conventions to Document

- Workflow path filters, Maven invocations, and artifact paths must move together when the Java
  project path changes.
- If `demo-java-*` workflows still use root-relative path filters, `./mvnw`, or
  `target/simpleweb.jar` after the Java project lives in `DEMO/JAVA`, future sessions must not
  dispatch them until a separate workflow migration updates those references together. Do not
  move the Java project back to the repository root as a workaround.
- Build SHA and UTC build time are Maven-filtered into the JAR; deployment verification reads
  `/api/info` and compares the full SHA.
- Workflows `04` to `06` deploy the GitHub Actions artifact to the VM over SSH; `07` is the Azure
  OIDC/App Service contrast; `08` is the private-repository same-VM runner contrast.
- Shared VM and Web App deployments must be serialized manually across both repositories and
  semantically verified before another shared-target run starts.
- The existing `.mcp.json` already configures Playwright, Context7, Chrome DevTools, and Microsoft
  Learn MCP servers. The npm-based servers use the local proxy registry, and Context7 requires the
  configured `CONTEXT7_API_KEY` input. The final handoff should mention the existing configuration
  rather than proposing duplicate setup.
- `.github/skills/` contains repository-specific course preparation, commit, and GitHub issue
  workflows. Future sessions should use them when their task matches. The broad inherited
  TypeScript/Vue/Hono guidance in `.github/instructions/` does not describe this Java/Terraform
  repository and must not be copied into the repository-level architecture or command sections.

## Validation

Read back the changed instruction file, confirm the acceptance checklist line by line, and run the
documented non-destructive commands that are practical in the current workspace. Maven test
validation must use `clean` or inspect the current command output for the intended
`Running <fully-qualified-class>` and `Tests run:` lines; stale report files and `BUILD SUCCESS`
alone are not sufficient. Do not run deployment workflows or Terraform apply as part of this
documentation-only change.
