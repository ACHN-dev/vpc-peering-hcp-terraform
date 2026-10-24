#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo " AWS Intra-Region VPC Peering: Destroy All 7 Workspaces"
echo " (Reverse Order: Compute -> Security -> Peering -> Network)"
echo "=========================================================="

WORKSPACES=(
  "be-compute-ws"
  "fe-compute-ws"
  "be-security-ws"
  "fe-security-ws"
  "peering-ws"
  "be-network-ws"
  "fe-network-ws"
)

TOTAL=${#WORKSPACES[@]}
STEP=1

for ws in "${WORKSPACES[@]}"; do
  echo ""
  echo "----------------------------------------------------------"
  echo " [Step $STEP/$TOTAL] Destroying Workspace: $ws"
  echo "----------------------------------------------------------"
  
  cd "$SCRIPT_DIR/$ws"
  
  echo "[+] Initializing Terraform..."
  terraform init
  
  echo "[+] Destroying Terraform resources..."
  terraform destroy -auto-approve
  
  echo "[✓] Successfully destroyed $ws"
  STEP=$((STEP + 1))
done

echo ""
echo "=========================================================="
echo " 🎉 All 7 Workspaces Successfully Destroyed!"
echo "=========================================================="
