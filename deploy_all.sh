#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo " AWS Intra-Region VPC Peering: Deploy All 7 Workspaces"
echo "=========================================================="

WORKSPACES=(
  "fe-network-ws"
  "be-network-ws"
  "peering-ws"
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
echo " 🎉 All 7 Workspaces Successfully Deployed!"
echo "=========================================================="

echo ""
echo "--- VPC Peering Outputs ---"
cd "$SCRIPT_DIR/peering-ws" && terraform output

echo ""
echo "--- Frontend Compute Outputs ---"
cd "$SCRIPT_DIR/fe-compute-ws" && terraform output

echo ""
echo "--- Backend Compute Outputs ---"
cd "$SCRIPT_DIR/be-compute-ws" && terraform output
