#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo " AWS Intra-Region VPC Peering: Deploy All 6 Workspaces"
echo "=========================================================="

WORKSPACES=(
  "fe-network-ws"
  "be-network-ws"
  "fe-security-ws"
  "be-security-ws"
  "fe-compute-ws"
  "be-compute-ws"
)

TOTAL=${#WORKSPACES[@]}
STEP=1

for ws in "${WORKSPACES[@]}"; do
  echo ""
  echo "----------------------------------------------------------"
  echo " [Step $STEP/$TOTAL] Deploying Workspace: $ws"
  echo "----------------------------------------------------------"
  
  cd "$SCRIPT_DIR/$ws"
  
  echo "[+] Initializing Terraform..."
  terraform init
  
  echo "[+] Applying Terraform..."
  terraform apply -auto-approve
  
  echo "[✓] Successfully deployed $ws"
  STEP=$((STEP + 1))
done

echo ""
echo "=========================================================="
echo " 🎉 All 6 Workspaces Successfully Deployed!"
echo "=========================================================="

echo ""
echo "--- Frontend Compute Outputs ---"
cd "$SCRIPT_DIR/fe-compute-ws" && terraform output

echo ""
echo "--- Backend Compute Outputs ---"
cd "$SCRIPT_DIR/be-compute-ws" && terraform output
