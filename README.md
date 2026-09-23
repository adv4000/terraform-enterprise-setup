## ☁️ Terraform Enterprise Setup for AWS

### 📋 Overview

This repository manages AWS infrastructure across multiple accounts and regions using Pure Terraform.
Each service stack (for example, `s3`, `vpc`, `iam`, `route53`) is deployed per account and region. All Terraform state is stored in a single S3 bucket in the ROOT/Management account.

- Remote state backend bucket: `astahov-root-terraform-remote-state` (us-west-2)
- State locking uses S3 native lock files (`use_lockfile = true`)
- State keys follow this pattern: `org/accounts/<account>/regions/<region>/<service>/the.tfstate`
- The backend stack that creates the state bucket lives in `backend/` with key `backend/the.tfstate`
- Infrastructure variables on three levels:
  - Global variables in `org/var_global.yml`
  - Account variables in `org/accounts/<account>/var_account.yml`
  - Region variables in `org/accounts/<account>/regions/<region>/var_region.yml`

### ⚠️ Critical Requirement

**You must run Terraform with ROOT/Management account credentials for all deployments.**

- For non-ROOT accounts, Terraform assumes the cross-account role defined in `var_account.yml`.
Usually:
  - `AWSControlTowerExecution` if the account was created by AWS Control Tower
  - `OrganizationAccountAccessRole` if the account was created from AWS Organizations
- The AWS provider in each stack assumes that role in the target account. Base credentials must be for the ROOT account with permission to assume those roles.
- The ROOT account stack has no `assume_role` block; it deploys into the management account directly.

### 📁 Skeleton Folder Hierarchy

```
├── backend
└── org
    ├── var_global.yml
    └── accounts
        ├── astahov-dev
        │   ├── var_account.yml
        │   └── regions
        │       ├── us-east-1
        │       │   ├── cloudfront
        │       │   ├── iam
        │       │   └── route53
        │       └── us-west-2
        │           ├── databases
        │           │   ├── dynamodb
        │           │   └── rds
        │           │       ├── mysql
        │           │       └── oracle
        │           ├── ec2-web
        │           ├── eks
        │           │   ├── cluster
        │           │   └── nodes
        │           ├── s3
        │           └── vpc
        ├── astahov-prod
        │   ├── var_account.yml
        │   └── regions
        │       ├── us-east-1
        │       │   ├── iam
        │       │   └── route53
        │       └── us-west-2
        │           ├── ec2-web
        │           └── vpc
        ├── astahov-shared
        │   ├── var_account.yml
        │   └── regions
        │       ├── us-east-1
        │       │   └── iam
        │       └── us-west-2
        │           ├── network
        │           │   ├── transitgateway
        │           │   └── vpc
        │           └── s3
        └── root
            ├── var_account.yml
            └── regions
                ├── us-east-1
                │   ├── billing
                │   ├── iam
                │   └── organization
                │       ├── policies
                │       │   ├── backup
                │       │   ├── scp
                │       │   └── tag
                │       └── settings
                └── us-west-2
```

### ⚙️ Configuration Model

- `org/var_global.yml` — global-level variables applied everywhere
- `org/accounts/<account>/var_account.yml` — account-level variables
- `org/accounts/<account>/regions/<region>/var_region.yml` — region-level variables

All the Magic happening in `config.tf` in each terraform stack, it find and reads these variables files, dynamically configure region, provider and default tags. Make sure you have this file in each terraform folder!  

✅ Prerequisites

- Terraform CLI installed (1.10+ recommended for S3 native state locking).
- AWS credentials for the ROOT/Management account available via environment variables or profile.

#### 🪟 Set AWS Credentials in Windows PowerShell

```
$env:AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxxx"
$env:AWS_SECRET_ACCESS_KEY="yyyyyyyyyyyyyyyyyyyyyyyyyyyy"
$env:AWS_DEFAULT_REGION="zzzzzzzzz"
```

#### 🐧 Set AWS Credentials in Linux Shell

```
export AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="yyyyyyyyyyyyyyyyyyyyyyyyyyyy"
export AWS_DEFAULT_REGION="zzzzzzzzz"
```

### 🚀 Deploying a Service Stack

Always deploy from the Management account context; the provider will assume the cross-account role for non-ROOT accounts.

Example (deploy `s3` for `astahov-dev` in `us-west-2`):

```bash
cd org/accounts/astahov-dev/regions/us-west-2/s3

terraform init
terraform plan
terraform apply
```

The state for this stack will be stored at:
`org/accounts/astahov-dev/regions/us-west-2/s3/the.tfstate` in the `astahov-root-terraform-remote-state` bucket.

The backend `key` in `config.tf` should match the git path of the stack (`git rev-parse --show-prefix`).

### ➕ Adding a New Account or Region

1. Duplicate an existing account folder under `org/accounts/` and adjust `var_account.yml` (`account_id`, `assume_role`, tags, domains).
2. Add desired regions under `regions/`, create or update `var_region.yml`.
3. Create service subfolders (`<service>/config.tf`, `main.tf`) or copy from an existing service and modify resources as needed.
4. Set the S3 backend `key` to the stack path ending in `the.tfstate`.
5. Deploy using the steps above.

Or  Ask AI to do it for you 🧠🤖

### 💥 Destroying a Stack

From the stack directory:

```bash
terraform destroy
```

### 🔄 CI/CD Setup

You can generate Backend Key automatically and not hardcode it in `config.tf`:

```bash
terraform init -backend-config="key=$(git rev-parse --show-prefix)the.tfstate"
terraform plan
terraform apply -auto-approve
```

### 📄 License

Copyright (c) Denis Astahov ADV-IT.

You may use, copy, modify, merge, publish, distribute, sublicense, sell, and relicense this software under any other license, for any purpose, without restriction.

The only condition is that the original developer, **Denis Astahov ADV-IT**, must remain credited in `README.md` of every copy and derivative work.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.