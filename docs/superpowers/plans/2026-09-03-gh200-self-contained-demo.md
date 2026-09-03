# GH-200 Self-Contained Java Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Put the verified Java demo application and active CI/CD workflows directly in MoneyYu/GH-200 beside its Terraform environment.

**Architecture:** The Java Maven project lives at repository root so GitHub workflows execute without cross-repository checkout. Workflow filenames are prefixed `demo-java-` and use the verified class implementation, adapted from branch `main` to GH-200's `master`; deployment remains per-SHA, digest-verified, OIDC-authenticated and approval-gated.

**Tech Stack:** Java 21, Spring Boot 4.1.1, Maven Wrapper, GitHub Actions, Azure OIDC, Azure VM Run Command, Terraform AzureRM 4.x.

## Global Constraints
- Keep the existing attendee `README.md`, `TERRAFORM/`, and trainer docs.
- Never commit secrets, Terraform state, SSH keys, or Azure identifiers.
- Production deployment remains protected by the `production` GitHub Environment.
- Use `master` as the GH-200 default branch.
- `terraform apply` is not run again; deployed infrastructure must remain no-change.

---

### Task 1: Add Java Demo Source

**Files:**
- Create: `pom.xml`, `mvnw`, `mvnw.cmd`, `.mvn/wrapper/maven-wrapper.properties`, `Dockerfile`, `src/**`
- Modify: `.gitignore`, `.gitattributes`, `README.md`

**Interfaces:**
- Produces: `target/simpleweb.jar`; endpoints `/`, `/api/info`, `/actuator/health`.

- [ ] Copy source from `C:\Source\Repos\20260903-GH200`, excluding `.git`, `.github`, `labs`, `README.md`, and `target`.
- [ ] Set `mvnw` Git mode to `100755` and enforce LF.
- [ ] Run `.\mvnw.cmd -B clean verify`.
- [ ] Expected: 14 Surefire + 3 Failsafe tests, `BUILD SUCCESS`, `target/simpleweb.jar`.
- [ ] Remove `target/` and commit.

### Task 2: Add Active Demo Workflows

**Files:**
- Create: `.github/workflows/demo-java-01-build.yml` through `demo-java-09-troubleshooting.yml`

**Interfaces:**
- Consumes: root Maven project and existing GitHub variables/secrets.
- Produces: CI artifacts and deployments to `simpleweb-test`/`simpleweb-prod`.

- [ ] Copy the nine verified workflows from `C:\Source\Repos\20260903-GH200\.github\workflows`.
- [ ] Prefix filenames and workflow names with `demo-java-`; change push/PR branches from `main` to `master`.
- [ ] Keep per-SHA releases, SHA-256 checks, shared concurrency, OIDC and approval gates unchanged.
- [ ] Parse all YAML with PyYAML.
- [ ] Commit and push.
- [ ] Verify demo CI build/test/package runs succeed in MoneyYu/GH-200.

### Task 3: Configure GH-200 Deployment Identity

**Files:**
- No credential files.

**Interfaces:**
- Produces GitHub Environments `test`/`production`, repo variables and encrypted secrets; Entra federated credentials for GH-200.

- [ ] Add exact stable-ID `environment:test` and `environment:production` federated credentials to the existing deployment app.
- [ ] Set `AZURE_RESOURCE_GROUP`, `AZURE_VM_NAME`, `VM_PUBLIC_IP`; set three Azure ID secrets.
- [ ] Keep production required reviewer.
- [ ] Trigger the full pipeline, approve production, and verify both URLs report the new GH-200 commit SHA.
- [ ] Confirm Terraform remote plan is `No changes` and push final docs.
