#!/bin/bash
# detect-bad-commits.sh - Identify commits with poor messages
# Usage: ./detect-bad-commits.sh <scan_limit> <num_to_find>

SCAN_LIMIT=${1:-50}
NUM_TO_FIND=${2:-10}

BAD_COMMITS=""
FOUND_COUNT=0

for i in $(seq 0 $((SCAN_LIMIT - 1))); do
    commit="HEAD~$i"
    # Check if commit exists
    if ! git rev-parse "$commit" >/dev/null 2>&1; then
        break
    fi
    msg=$(git log -1 --pretty=%s "$commit" 2>/dev/null)
    hash=$(git rev-parse "$commit" 2>/dev/null)
    
    # Check if message is bad
    is_bad=false
    bad_reason=""
    
    # Too short (less than 10 chars)
    if [[ ${#msg} -lt 10 ]]; then
        is_bad=true
        bad_reason="too short"
    # Generic/meaningless messages (case insensitive)
    # Using tr for compatibility instead of bash 4+ ${var,,}
    elif echo "$msg" | tr '[:upper:]' '[:lower:]' | grep -qE '^(fix|fixes|fixed|fixing|update|updates|updated|updating|change|changes|changed|changing|stuff|asdf|wip|test|tests|tested|testing|\.+|improvements?|improved?|optimized?|better|misc|various|tweaks?|tweaked)$'; then
        is_bad=true
        bad_reason="generic/vague"
    # Messages that are variations of "making/doing X" without specifics
    elif echo "$msg" | tr '[:upper:]' '[:lower:]' | grep -qE '^(making|doing|adding|removing|deleting|creating) [a-z]+$'; then
        is_bad=true
        bad_reason="incomplete action"
    # Check for common typos
    elif echo "$msg" | grep -qE '(Importat|Optmized|Improvent|Refacor|Documention|Implemenation|Intergration|Confguration)'; then
        is_bad=true
        bad_reason="contains typo"
    # Single word messages that aren't conventional commits
    elif [[ "$msg" =~ ^[A-Za-z]+$ ]] && [[ ! "$msg" =~ ^(feat|fix|docs|refactor|test|chore|style|perf|build|revert|ci): ]]; then
        is_bad=true
        bad_reason="single word"
    # Already good conventional commits - skip
    elif [[ "$msg" =~ ^(feat|fix|docs|refactor|test|chore|style|perf|build|revert|ci): ]]; then
        is_bad=false
    fi
    
    if [[ "$is_bad" == "true" ]]; then
        echo "BAD:$hash:$msg:$bad_reason"
        FOUND_COUNT=$((FOUND_COUNT + 1))
        
        # Stop if we found enough bad commits
        [[ $FOUND_COUNT -ge $NUM_TO_FIND ]] && break
    fi
done

if [[ $FOUND_COUNT -eq 0 ]]; then
    echo "NONE:No bad commits found"
    exit 0
fi

echo "SUMMARY:Found $FOUND_COUNT bad commits"