# US Mobile Take Home assignment

The project is deployed for US Mobile interview using AWS, Terraform, Helm , ArgoCD and github action

---

## DESIGN

The project follows a GitOps workflow:

1.  **Infrastructure as Code (IaC):** [Terraform] is used to provision all the necessary AWS infrastructure, including the VPC, EKS Cluster, and ECR repository.
2.  **Git Repositories:** Two separate Git repositories are used to maintain a clean separation of concerns:
    *   `app-source-code`: 
3.  **Continuous Integration (CI):** 
    *   Builds a new Docker image.
    *   Pushes the image to Amazon ECR with a unique tag (the Git commit SHA).
4.  **Continuous Deployment (CD):** [ArgoCD] runs in the EKS cluster.
    *   When it detects a change (the new image tag), it automatically pulls the updated manifests.
    *   It applies the changes to the cluster, triggering a rolling update of the application.

---

### Steps 

1.  **Deploy the Infrastructure:**
    *   Download this repository and navigate to the `Terraform` directory.
    *   Initialize Terraform: `terraform init`
    *   Review the plan: `terraform plan`
    *   Apply the infrastructure: `terraform apply --auto-approve` (This will take ~30 minutes).
    *   Configure `kubectl` to connect to your new cluster:
        ```bash
        aws eks --region us-east-1 update-kubeconfig --name us-mobile-interview-cluster)
        ```

2.  **Install and Configure ArgoCD:**
    *   Install ArgoCD using the Helm chart
        ``` bash
            helm repo add argo-cd https://argoproj.github.io/argo-helm
            helm repo update
            kubectl create namespace argocd
            helm install argocd argo-cd/argo-cd -n argocd --create-namespace
        ```
    *   Port-forward to access the UI: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
    *   Log in to the UI at `https://localhost:8080` with the `admin` user and the auto-generated password.
         ``` bash
          kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 
          ```

3.  **Bootstrap the Application:**
    *   Apply the following command to start the gitops process. 
        ```bash
        kubectl apply -f gitops/argocd/argocd-app.yml 
        ```
    *   ArgoCD will now automatically detect and deploy the `hello-world-app` application in `hello-world` namespace
        (argocd-app.yml will call gitops/argocd/hello-world-app which contains hello-world.yaml )

4.  **Set up the CI Pipeline:**
    *   CI pipeline has been developed at .github/workflows/pipeline.yml and configure the following secrets in the github repo
        * ARGOCD_PASSWORD
        * ARGOCD_SERVER
        * ARGOCD_USERNAME
        * AWS_ACCESS_KEY_ID 
        * AWS_ACCOUNT_ID
        * AWS_SECRET_ACCESS_KEY
 
5.  **Observe and Verify:**
    *   Watch the GitHub Actions pipeline build the image and update the manifests repo.
    *   Watch in the ArgoCD UI as it detects the change and deploys the new version.
    *   Access the application via the Load Balancer URL provided by the service: `kubectl get svc -n hello-world`.

6. **Blue/Green Deployment with Argo Rollout:**
    * Deploy argocd rollout with helm using following command
    ``` bash
        helm repo add argo https://argoproj.github.io/argo-helm
        helm repo update
        helm install argocd argo/argo-cd \
        --namespace argocd \
        --create-namespace
    ```

    * Update Helm Chart (Code at : gitops/blue-green)
        Replace Deployment with Rollout resource.
        Define blueGreen strategy with preview and active services.
        Deploy New Version:
---

##  Results

Few Screnshots of the project are attached as pdf (results-screenshots.pdf) and github action logs as Continous-integration.pdf

---

##  Destroying the resources to avoid cose

To avoid ongoing AWS costs, destroy all the created infrastructure.

1.  Go to the `Terraform` directory and execute 'terraform destroy --auto-approve'

---



