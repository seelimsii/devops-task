# Write-up: CI/CD Pipeline Project

### Tools & Services Used

* **Version Control**: GitHub (with a `main`/`dev` branching strategy).
* **CI/CD**: Jenkins for pipeline orchestration.
* **Containerization**: Docker & Dockerfile for creating a portable application image.
* **Cloud Provider**: Amazon Web Services (AWS).
* **Infrastructure as Code**: Terraform to provision and manage AWS resources (VPC, EKS, ECR).
* **Container Registry**: AWS Elastic Container Registry (ECR).
* **Deployment Target**: AWS Elastic Kubernetes Service (EKS).
* **Monitoring**: AWS CloudWatch for basic infrastructure and control plane logging.

### Challenges Faced & Solutions

1.  **EKS Cluster Setup**: Setting up an EKS cluster manually is complex, involving VPCs, subnets, IAM roles, and node groups.
    * **Solution**: I used Terraform with community-vetted modules (`terraform-aws-modules/eks/aws`). This abstracted away the complexity, reduced errors, and made the entire infrastructure reproducible and version-controlled.

2.  **Jenkins-EKS Authentication**: Allowing Jenkins to securely communicate with the EKS cluster can be tricky.
    * **Solution**: The `Jenkinsfile` uses the `withAWS` wrapper to handle temporary AWS credentials. The `aws eks update-kubeconfig` command dynamically generates the `kubeconfig` file on the Jenkins agent for `kubectl` to use, ensuring secure and seamless authentication for each deployment.

3.  **Dynamic Image Tagging**: I needed a way to ensure Kubernetes always pulled the latest built image, not a static one.
    * **Solution**: In the `Jenkinsfile`, I tagged the Docker image with the unique `${env.BUILD_NUMBER}`. Then, before deploying, I used a `sed` command to replace a placeholder `__IMAGE_URL__` in my `deployment.yaml` with the full ECR path and the new tag. This ensures the deployment always references the correct image version.

### Possible Improvements

* **Advanced Branching Strategy**: Implement a full GitFlow model with `feature`, `release`, and `hotfix` branches, with different pipeline behaviors for each (e.g., deploying feature branches to a staging environment).
* **Secrets Management**: Store sensitive information like database passwords or API keys in a secure vault like HashiCorp Vault or AWS Secrets Manager instead of plain text.
* **Testing**: Add more comprehensive testing stages, including integration tests, end-to-end tests, and static code analysis (e.g., SonarQube).
* **Cost Optimization**: Configure Horizontal Pod Autoscaling (HPA) in Kubernetes to automatically scale the number of pods based on CPU or memory usage, optimizing resource utilization.