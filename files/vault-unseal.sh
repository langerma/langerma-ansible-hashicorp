#!/bin/bash

# Vault Auto-Unseal Script
# This script automatically unseals Vault using the stored unseal keys

VAULT_ADDR="http://localhost:8200"
VAULT_BINARY="/opt/bin/vault"
UNSEAL_KEYS_FILE="/etc/vault.d/unseal-keys"

# Check if Vault is running
if ! curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1; then
    echo "Vault is not responding at $VAULT_ADDR"
    exit 1
fi

# Check if already unsealed
SEALED_STATUS=$(curl -s "$VAULT_ADDR/v1/sys/seal-status" | grep -o '"sealed":[^,]*' | cut -d':' -f2)
if [ "$SEALED_STATUS" = "false" ]; then
    echo "Vault is already unsealed"
    exit 0
fi

# Check if unseal keys file exists
if [ ! -f "$UNSEAL_KEYS_FILE" ]; then
    echo "Unseal keys file not found at $UNSEAL_KEYS_FILE"
    exit 1
fi

echo "Vault is sealed. Starting unseal process..."

# Read the first 3 unseal keys and unseal
KEYS=($(head -3 "$UNSEAL_KEYS_FILE"))

for i in "${!KEYS[@]}"; do
    echo "Using unseal key $((i+1))/3..."
    VAULT_ADDR="$VAULT_ADDR" "$VAULT_BINARY" operator unseal "${KEYS[$i]}" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Unseal key $((i+1)) applied successfully"
    else
        echo "Failed to apply unseal key $((i+1))"
        exit 1
    fi
done

# Check final status
SEALED_STATUS=$(curl -s "$VAULT_ADDR/v1/sys/seal-status" | grep -o '"sealed":[^,]*' | cut -d':' -f2)
if [ "$SEALED_STATUS" = "false" ]; then
    echo "✅ Vault successfully unsealed!"
    exit 0
else
    echo "❌ Vault is still sealed after unseal attempts"
    exit 1
fi