## Class Demo Repository

[MoneyDemo/20260903-GH200](https://github.com/MoneyDemo/20260903-GH200) is the class repository for the progressive Java workflow demos and student labs.

The same Java 21 / Spring Boot 4.1.1 demo source is also included directly in this repository
under `JAVA/` (`pom.xml`, `src/`, Maven Wrapper, and `Dockerfile`). GH-200's active
`demo-java-*` workflows let future deliveries build, test, package, and deploy the demo without
recreating the class repository.

`MoneyYu/GH-200` does not currently have a GitHub plan that supports required reviewers on
Environments. Production deployments therefore use explicit `workflow_dispatch` confirmations:
`demo-java-05` requires `confirm=deploy` plus a full `build_sha`, while `demo-java-06` requires
`confirm_production=deploy`. Use the class repository above when demonstrating the real
required-reviewer approval gate.

Because GH-200 is private, its deployment workflows do not expose GitHub release assets.
`demo-java-04` through `06` build once and deploy the same Actions artifact over SSH to an
on-premises-style Ubuntu VM simulation — build, test, package, copy, connect, restart the service,
then verify the deployed commit SHA — and promote a verified test build to production by SHA.

### Reusable Demo Environment

- [Terraform deployment and operations guide](../TERRAFORM/README.md)
- [Java CI/CD workflows](../.github/workflows/)
- [Trainer demo environment guide](../docs/demo-environment.md)

`demo-java-01` through `06` are the main Build → Test → Package → Deploy path to the
on-premises VM simulation, over SSH. `demo-java-07` is a contrast that deploys the same Java app
to a Linux App Service through Azure OIDC — a PaaS/OIDC comparison, not a VM deployment path.
`demo-java-08` runs on the same VM as the SSH deploy target, as a classroom simplification; this
path itself needs no inbound SSH access. It runs on the persistent `gh200`-labelled self-hosted
runner registered to this private repo (persistent course infrastructure, not removed after the
demo); it otherwise stays queued by design. The `confirm_production=deploy` input
prevents accidental deployment but does
**not** provide separation of duties; use the MoneyDemo class repo for the real reviewer gate.