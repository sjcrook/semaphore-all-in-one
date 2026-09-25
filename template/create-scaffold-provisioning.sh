#!/bin/bash
# Scaffolds a semaphore-provisioning/ directory (real license/certs/RPMs/
# credentials, fed into the Docker build via additional_contexts).
# Usage: vendor/semaphore-all-in-one/template/create-scaffold-provisioning.sh [target] [--force]
# Run from the consuming project's repo root; target defaults to ./semaphore-provisioning.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/provisioning"

TARGET="semaphore-provisioning"
FORCE=0
for arg in "$@"; do
    if [ "$arg" = "--force" ]; then
        FORCE=1
    else
        TARGET="$arg"
    fi
done

if [ -e "$TARGET" ] && [ "$FORCE" -ne 1 ]; then
    echo "Refusing to overwrite existing '$TARGET' (pass --force to proceed)." >&2
    exit 1
fi

mkdir -p "$TARGET"
cp -R "$TEMPLATE_DIR/." "$TARGET/"

echo "Scaffolded a Semaphore provisioning directory at '$TARGET'."
echo "Next steps:"
echo "  1. Read $TARGET/README.md for the exact layout required."
echo "  2. Place your real license, certs, RPMs, and studio-authentication.properties there."
echo "  3. Confirm docker-compose.yml's semaphore.build.additional_contexts points at '$TARGET'."
