#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
#
# check-deps.sh — verifies that the workspace dependency graph matches
# the frozen graph (docs/ARCHITECTURE.md, ADR-009) EXACTLY.
#
# Exit codes: 0 OK, 1 violation, 2 environment error.

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

command -v jq    >/dev/null 2>&1 || { echo "[check-deps] jq required"    >&2; exit 2; }
command -v cargo >/dev/null 2>&1 || { echo "[check-deps] cargo required" >&2; exit 2; }

declare -rA ALLOWED_EDGES=(
    ["myapp-canonical"]=""
    ["myapp-protocol"]=""
    ["myapp-core"]="myapp-protocol myapp-canonical"
    ["myapp-crypto"]="myapp-core myapp-canonical"
    ["myapp-storage"]="myapp-core"
    ["myapp-transport"]="myapp-core myapp-protocol"
    ["myapp-discovery"]="myapp-core myapp-protocol"
    ["myapp-media"]="myapp-core myapp-protocol"
    ["myapp-client"]="myapp-core myapp-crypto myapp-storage myapp-transport myapp-discovery myapp-media myapp-protocol myapp-canonical"
    ["myapp-relay"]="myapp-canonical myapp-protocol myapp-transport myapp-storage"
    ["myapp-cli"]="myapp-client"
    ["myapp-desktop"]="myapp-client"
    ["myapp-tools"]="myapp-canonical myapp-protocol"
)

metadata="$(cargo metadata --format-version=1 --no-deps)" \
    || { echo "[check-deps] cargo metadata failed" >&2; exit 2; }

violations=0

mapfile -t members < <(printf '%s' "${metadata}" \
    | jq -r '.packages[].name | select(startswith("myapp-"))' \
    | sort)

mapfile -t members_unique < <(printf '%s\n' "${members[@]}" | sort -u)
if (( ${#members[@]} != ${#members_unique[@]} )); then
    echo "[check-deps] duplicate workspace member names detected" >&2
    printf '%s\n' "${members[@]}" | sort | uniq -d | sed 's/^/  /' >&2
    violations=$((violations + 1))
fi

for m in "${members[@]}"; do
    if [[ ! -v "ALLOWED_EDGES[${m}]" ]]; then
        echo "[check-deps] workspace member missing from table: ${m}" >&2
        violations=$((violations + 1))
    fi
done

for k in "${!ALLOWED_EDGES[@]}"; do
    found=0
    for m in "${members[@]}"; do
        [[ "${m}" == "${k}" ]] && { found=1; break; }
    done
    if (( found == 0 )); then
        echo "[check-deps] table entry has no workspace member: ${k}" >&2
        violations=$((violations + 1))
    fi
done

actual_edges="$(printf '%s' "${metadata}" | jq -r '
    .packages[]
    | select(.name | startswith("myapp-"))
    | .name as $from
    | .dependencies[]
    | select(.name | startswith("myapp-"))
    | select(.kind == null)
    | "\($from)\t\(.name)"
' | sort -u)"

for from in "${!ALLOWED_EDGES[@]}"; do
    in_ws=0
    for m in "${members[@]}"; do [[ "${m}" == "${from}" ]] && { in_ws=1; break; }; done
    (( in_ws == 1 )) || continue

    mapfile -t actual < <(printf '%s\n' "${actual_edges}" \
        | awk -F'\t' -v f="${from}" '$1==f {print $2}' | sort)

    read -r -a allowed <<< "${ALLOWED_EDGES[${from}]}"
    if (( ${#allowed[@]} > 0 )); then
        mapfile -t allowed < <(printf '%s\n' "${allowed[@]}" | sort)
    else
        allowed=()
    fi

    for a in "${allowed[@]:-}"; do
        [[ -z "${a}" ]] && continue
        hit=0
        for b in "${actual[@]:-}"; do [[ "${b}" == "${a}" ]] && { hit=1; break; }; done
        if (( hit == 0 )); then
            echo "[check-deps] MISSING edge: ${from} → ${a}" >&2
            violations=$((violations + 1))
        fi
    done

    for b in "${actual[@]:-}"; do
        [[ -z "${b}" ]] && continue
        hit=0
        for a in "${allowed[@]:-}"; do [[ "${a}" == "${b}" ]] && { hit=1; break; }; done
        if (( hit == 0 )); then
            echo "[check-deps] FORBIDDEN edge: ${from} → ${b}" >&2
            violations=$((violations + 1))
        fi
    done
done

if (( violations > 0 )); then
    echo "[check-deps] FAILED: ${violations} violation(s)." >&2
    exit 1
fi

echo "[check-deps] OK: frozen dependency graph respected (exact match)."
