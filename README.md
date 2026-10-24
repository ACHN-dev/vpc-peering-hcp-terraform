# AWS Intra-Region VPC Peering Architecture (Assignment-02)

This repository contains the Terraform infrastructure code for the **Intra-Region VPC Peering Assignment** deployed on **AWS (Singapore `ap-southeast-1`)** using **HCP Terraform (Terraform Cloud)** micro-workspaces.

---

## 1. Architecture Overview

![AWS Intra-Region VPC Peering Architecture](./vpc-peering-architecture.png)

---

## 2. HCP Terraform Micro-Workspaces Architecture

The codebase is modularized into **7 decoupled workspaces** in HCP Terraform (Terraform Cloud) to enable isolation of network, peering, security, and compute layers:

```text
vpc-peering-assignment/
├── common/
│   └── providers.tf         # Shared AWS Provider config (symlinked into all workspaces)
├── fe-network-ws/           # 1. Frontend VPC, Subnets, IGW, NAT GW & Route Tables
├── be-network-ws/           # 2. Backend VPC, Subnets, IGW, NAT GW & Route Tables
├── peering-ws/              # 3. Cross-VPC Peering Connection & Cross-VPC Routes
├── fe-security-ws/          # 4. Frontend Security Groups & Internal Rules
├── be-security-ws/          # 5. Backend Security Groups & Cross-Peering Security Rules
├── fe-compute-ws/           # 6. Frontend Bastion + Private Instances + Key Pair
├── be-compute-ws/           # 7. Backend Bastion + Private Instances + Key Pair
├── deploy_all.sh            # One-click deployment script (Order: 1 -> 7)
├── destroy_all.sh           # One-click teardown script (Order: 7 -> 1)
├── fe-key.pem               # SSH Private Key for Frontend Instances
└── be-key.pem               # SSH Private Key for Backend Instances
```

### Remote State Dependency Graph

```mermaid
flowchart TD
    fe_net["fe-network-ws"] --> peering["peering-ws"]
    be_net["be-network-ws"] --> peering
    fe_net --> fe_sec["fe-security-ws"]
    be_net --> be_sec["be-security-ws"]
    fe_sec --> be_sec
    fe_net --> fe_comp["fe-compute-ws"]
    fe_sec --> fe_comp
    be_net --> be_comp["be-compute-ws"]
    be_sec --> be_comp
```

---

## 3. Security Groups & Traffic Rules Matrix

All security rules are implemented using modern standalone resources (`aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`) with Security Group referencing (`referenced_security_group_id`):

| Security Group       | Inbound Rules                                                                                                    | Outbound Rules                                                            |
| :------------------- | :--------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------ |
| **`fe: pub-sgp-01`** | • Allow Your IP to Ping (ICMP Type 8 Code 0)<br>• Allow Your IP to SSH (TCP 22)                                  | • Allow ALL Types of traffic to `0.0.0.0/0`                               |
| **`fe: pri-sgp-01`** | • Allow Only `pub-sgp-01` to Ping<br>• Allow Only `pub-sgp-01` to SSH                                            | • Allow ALL Types of traffic to `0.0.0.0/0`                               |
| **`fe: pri-sgp-02`** | • Allow Only FROM `fe: pri-sgp-01` to Ping & SSH<br>• Allow Only FROM `be: pri-sgp-02` (Cross-VPC) to Ping & SSH | • Allow to Ping TO `be: pri-sgp-02`<br>• Allow to SSH TO `be: pri-sgp-02` |
| **`fe: pri-sgp-03`** | • Allow Only FROM `fe: pri-sgp-01` to Ping & SSH<br>• Allow Only FROM `be: pri-sgp-03` (Cross-VPC) to Ping & SSH | • Allow to Ping TO `be: pri-sgp-03`<br>• Allow to SSH TO `be: pri-sgp-03` |
| **`be: pub-sgp-01`** | • Allow Your IP to Ping (ICMP Type 8 Code 0)<br>• Allow Your IP to SSH (TCP 22)                                  | • Allow ALL Types of traffic to `0.0.0.0/0`                               |
| **`be: pri-sgp-01`** | • Allow Only `pub-sgp-01` to Ping<br>• Allow Only `pub-sgp-01` to SSH                                            | • Allow ALL Types of traffic to `0.0.0.0/0`                               |
| **`be: pri-sgp-02`** | • Allow Only FROM `be: pri-sgp-01` to Ping & SSH<br>• Allow Only FROM `fe: pri-sgp-02` (Cross-VPC) to Ping & SSH | • Allow to Ping TO `fe: pri-sgp-02`<br>• Allow to SSH TO `fe: pri-sgp-02` |
| **`be: pri-sgp-03`** | • Allow Only FROM `be: pri-sgp-01` to Ping & SSH<br>• Allow Only FROM `fe: pri-sgp-03` (Cross-VPC) to Ping & SSH | • Allow to Ping TO `fe: pri-sgp-03`<br>• Allow to SSH TO `fe: pri-sgp-03` |

---

## 4. Deployment Instructions

### Method A: Automated Script

```bash
# 1. Deploy all workspaces in sequence (1 -> 7)
./deploy_all.sh

# 2. Destroy all workspaces when done (7 -> 1)
./destroy_all.sh
```

### Method B: Manual Step-by-Step Deployment

```bash
# Step 1: Frontend Network
cd fe-network-ws && terraform init && terraform apply -auto-approve && cd ..

# Step 2: Backend Network
cd be-network-ws && terraform init && terraform apply -auto-approve && cd ..

# Step 3: VPC Peering (Connections & Cross-VPC Routes)
cd peering-ws && terraform init && terraform apply -auto-approve && cd ..

# Step 4: Frontend Security Groups
cd fe-security-ws && terraform init && terraform apply -auto-approve && cd ..

# Step 5: Backend Security Groups (includes Cross-peering rules)
cd be-security-ws && terraform init && terraform apply -auto-approve && cd ..

# Step 6: Frontend Compute (Bastion + Private Instances)
cd fe-compute-ws && terraform init && terraform apply -auto-approve && cd ..

# Step 7: Backend Compute (Bastion + Private Instances)
cd be-compute-ws && terraform init && terraform apply -auto-approve && cd ..
```

---

## 5. VCS-Driven Workflow Deployment

This repository supports full **VCS-Driven (Version Control System driven)** automated deployments via **HCP Terraform (Terraform Cloud)** and **GitHub Actions**.

### Option A: Micro-Workspaces VCS with HCP Terraform Run Triggers (7 Workspaces)
To connect all 7 micro-workspaces to this Git repo:
1. In HCP Terraform (`achn-testing`), create 7 VCS workspaces pointing to `ACHN-dev/vpc-peering-hcp-terraform.git`:
   * `fe-network-ws` (Working Dir: `fe-network-ws`)
   * `be-network-ws` (Working Dir: `be-network-ws`)
   * `peering-ws` (Working Dir: `peering-ws`)
   * `fe-security-ws` (Working Dir: `fe-security-ws`)
   * `be-security-ws` (Working Dir: `be-security-ws`)
   * `fe-compute-ws` (Working Dir: `fe-compute-ws`)
   * `be-compute-ws` (Working Dir: `be-compute-ws`)
2. Set **Run Triggers** in HCP Terraform:
   * `peering-ws` listens to `fe-network-ws` & `be-network-ws`
   * `fe-security-ws` listens to `fe-network-ws`
   * `be-security-ws` listens to `be-network-ws` & `fe-security-ws`
   * `fe-compute-ws` listens to `fe-security-ws`
   * `be-compute-ws` listens to `be-security-ws`

### Option B: GitHub Actions Automated CI/CD Pipeline
The workflow in `.github/workflows/vcs-peering-pipeline.yml` automatically orchestrates all 7 workspaces sequentially:
* **Pull Request**: Runs `terraform validate` and `terraform plan` on all 7 workspaces in dependency order.
* **Merge to Main**: Runs `terraform apply` across all 7 workspaces in sequence (1 -> 7).

### SSH Private Key Retrieval from AWS SSM
Because VCS runners are ephemeral, the SSH private keys are automatically stored in **AWS Systems Manager (SSM) Parameter Store**:
```bash
# Fetch Frontend Key
aws ssm get-parameter --name "/vpc-peering/fe/private_key_pem" --with-decryption --query "Parameter.Value" --output text > fe-key.pem && chmod 400 fe-key.pem

# Fetch Backend Key
aws ssm get-parameter --name "/vpc-peering/be/private_key_pem" --with-decryption --query "Parameter.Value" --output text > be-key.pem && chmod 400 be-key.pem
```
