# GH-200 Self-Contained Java Demo Design

## Goal
Make MoneyYu/GH-200 self-contained for future deliveries: Terraform, Java demo source, and directly executable GitHub Actions CI/CD must live in the same repository.

## Architecture
- Keep the course HackMD `README.md`, `TERRAFORM/`, and trainer docs unchanged in purpose.
- Add the Java 21 / Spring Boot 4.1.1 application at repository root (`pom.xml`, `mvnw`, `src/`, `Dockerfile`) so workflows need no cross-repository checkout.
- Add active `.github/workflows/demo-java-01-*.yml` through `demo-java-09-*.yml`, adapted from the verified class repository. Push triggers use `master`; deployment workflows retain per-SHA releases, digest checks, OIDC, approval gates, Run Command sentinel, and build-SHA smoke tests.
- Configure GH-200 `test` and `production` Environments, stable-ID OIDC federated credentials, Azure secrets, VM variables, and production required reviewer.
- Link source/workflows from the course README.

## Safety
- No credential values enter git.
- Deployment principal remains resource-group-scoped Virtual Machine Contributor.
- Production remains approval-gated.
- Terraform state remains AAD-only remote state.
- SSH and self-hosted workflows remain manual advanced examples.

## Verification
- Maven Wrapper `clean verify` passes (17 tests).
- All workflow YAML parses.
- GitHub-hosted CI 01–03 passes in GH-200.
- Full pipeline deploys test and production through GH-200 OIDC and verifies the exact build SHA.
- Terraform remote plan remains no-change.
