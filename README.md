# 🏗️ Infrastructure as Code (IaC)

This repository manages the cloud infrastructure for our application using **Terraform**. We deploy resources to **Google Cloud Platform (GCP)** and **Firebase** using a modular, Trunk-Based CI/CD pipeline via GitHub Actions.

## 📂 Project Structure

We follow the "Build Once, Deploy Anywhere" philosophy. Our environments are physically isolated by directories, but they all share the same underlying module (blueprint).

- `/modules/app` - The core blueprint. Defines Cloud Run services, Firebase Hosting sites, IAM permissions, and Database integrations.
- `/shared` - Global resources that are environment-agnostic (e.g., the shared Artifact Registry for Docker images).
- `/staging` - The staging environment. Automatically deployed when `main` is updated.
- `/prod` - The production environment. Requires a manual approval in GitHub Actions to deploy.

## 🚀 CI/CD Workflows

All infrastructure deployments are fully automated. **Never run `terraform apply` locally.**

1.  **Pull Requests (`terraform plan`):** Opening a PR to `main` triggers a plan for both Staging and Prod. This allows reviewers to see exactly what will be created, modified, or destroyed before merging.
2.  **Merge to `main` (`terraform apply`):** Automatically applies the changes to the Staging and Production environments.
3.  **Shared Infrastructure:** Changes made specifically to the `/shared` folder trigger a separate workflow to update global resources.

## 🔒 Security & Environments

- **Authentication:** GitHub Actions authenticates with GCP using a Service Account Key stored securely in GitHub Secrets (`GCP_SA_KEY`).
- **GitHub Environments:** We utilize GitHub Environments (`staging` and `production`). The `production` environment is configured with strict _Required Reviewers_ to prevent accidental deployments.

## 🛠️ Adding New Resources

1. Add the new resource to the blueprint in `/modules/app/main.tf`.
2. Expose any necessary variables in `/modules/app/variables.tf`.
3. Pass the specific values for the new variables in `/staging/main.tf` and `/prod/main.tf`.
4. Create a Pull Request to review the Terraform Plan.
