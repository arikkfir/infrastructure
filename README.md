# infrastructure
Infrastructure-as-Code for the KFIRS umbrella.

## FAQ

#### Why store the service account key externally
 
Deployer service account key is stored externally since changing it does not require a re-deployment of the infrastructure. If we change it, we usually wouldn't want to trigger a re-deployment.

#### Why store the Terraform secrets in the repository

Contrary to the service account key, changing the secrets **does** affect the deployment, its artifacts and outcomes, therefor it makes sense to make sure that changing it triggers deployments.

## ROADMAP

- [ ] Evaluate [kiali](https://www.kiali.io)
- [ ] Consider applying affinity to core components
- [ ] Consider applying priority to core components
- [ ] Use Cloud Build to apply Terraform infrastructure
- [ ] Terraform should also set up Kubernetes clusters (`dev`, `qa`, `prod`)
- [ ] Production cluster `prod` should also run Spinnaker
- [ ] Spinnaker should be connected to Cloud Build
- [ ] Projects are built by Cloud Build, which publishes artifacts (e.g. `gcr`)
- [ ] Artifacts detected by Spinnaker, which deploys/delivers them to relevant environments
- [ ] Custom GitHub bot that detects commands in PRs and triggers Spinnaker pipelines (deployment)
- [ ] Evaluate Tekton
