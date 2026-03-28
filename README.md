# 🍎 Apple Storage Web Task

A highly scalable, containerized Node.js web application built for modern cloud environments. This project provisions a complete full-stack architecture utilizing Docker, MongoDB, Nginx Load Balancing, Terraform (IaC), and a robust GitHub Actions CI/CD pipeline.

---

## 🏗️ Architecture Design

The application is fully containerized and consists of the following isolated components communicating over a private Docker network:

1. **Frontend / Backend (`app`):** A lightweight Node.js server (Alpine based) operating concurrently in 2 replicas to handle API requests and serve static HTML.
2. **Database (`db`):** A MongoDB instance equipped with a persistent volume to prevent data loss, automatically seeded with initial fruit data on first startup.
3. **Load Balancer (`nginx`):** An Nginx reverse proxy exposed on port 80. It directs incoming internet traffic strictly to the Node replicas using a Round Robin strategy, ensuring High Availability.
4. **Infrastructure:** Promoted via Terraform onto an AWS EC2 instance (Ubuntu 24.04). The server automatically installs all Docker dependencies during initialization (`user_data`), completely abstracting manual server setup.

---

## 🚀 Quick Start: Local Development
If you wish to test the application locally on your machine without deploying to the cloud, use the provided orchestration script.

```bash
# 1. Provide executable permissions to the orchestrator
chmod +x setup.sh

# 2. Run the automated configuration script
./setup.sh
```
*The script automatically verifies Docker is installed, builds the images, spins up the docker-compose stack, and waits for the database seed to formulate. Visit `localhost:80` when complete!*

---

## ☁️ Production Deployment (AWS + GitOps)

To deploy the production-ready infrastructure to AWS, follow these 3 steps:

### Step 1: Provision Infrastructure (Terraform)
Navigate to the `terraform/` directory and authenticate with your AWS CLI.
```bash
terraform init
terraform plan
terraform apply -auto-approve
```
*Note: This automatically generates an RSA SSH Key pair and saves it securely as `apple_web_key.pem` on your local machine. It also outputs the static Elastic IP (`web_eip`) of your new server.*

### Step 2: Inject GitHub Secrets
Before pushing code, configure your GitHub Repository Secrets to authenticate the pipelines:
*   `EC2_HOST`: The Elastic IP outputted by Terraform.
*   `EC2_SSH_KEY`: The raw text contents of the generated `apple_web_key.pem` file.
*   `DOCKER_USERNAME`: Your Docker Hub username.
*   `DOCKERHUB_TOKEN`: A secure access token generated from Docker Hub.

### Step 3: Trigger the CI/CD Pipeline
Deployments are entirely automated. Simply commit your code and push to the `main` branch. 

---

## ⚙️ CI/CD Pipeline Workflow

The project utilizes two separate, strictly scoped GitHub Actions files for maximum security and efficiency:

1. **Continuous Integration (`ci.yml`):**
   * Triggers on Pull Requests.
   * Acts as a "Shift-Left" testing environment by building the Docker image to verify the `Dockerfile` syntax.
   * Executes Jest unit/routing tests securely *inside* the mock Alpine container to ensure production-parity.
   * If code is pushed directly to `main`, it logs into Docker Hub and pushes an immutable, numbered image tag (e.g., `v42`).

2. **Continuous Deployment (`cd.yml`):**
   * Triggers strictly on merges to `main`.
   * SSHs securely into the EC2 instance using the injected Github Secrets.
   * Pulls the newest repository changes.
   * Executes `docker-compose pull` forcing the server to download the exact image tagged by the CI step.
   * Peforms a Zero-Downtime rolling update via `docker-compose up -d --remove-orphans`.
