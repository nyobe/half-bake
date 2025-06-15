#!/usr/bin/env bash
set -euo pipefail

# Content-addressed cache for Make targets
# Usage: cached-run.sh <hash_file> <target> <command>

HASH_FILE="$1"
TARGET="$2"
COMMAND="$3"

# Configuration
CACHE_DIR="${BUILD_CACHE_DIR:-.cache}"
VERBOSE="${VERBOSE:-1}"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Read the hash of dependencies
if [[ ! -f "$HASH_FILE" ]]; then
    echo "Hash file $HASH_FILE not found - cannot use cache" >&2
    eval "$COMMAND"
    exit $?
fi

# Create cache key from dependency hashes
CACHE_KEY=$(cat "$HASH_FILE" | sha1sum | cut -d' ' -f1)
CACHED_TARGET="$CACHE_DIR/by-deps/$CACHE_KEY"
mkdir -p "$(dirname "$CACHED_TARGET")"

# Check if we have a cached result
if [[ -f "$CACHED_TARGET" ]]; then
    if [[ "$VERBOSE" == "1" ]]; then
        echo "Cache hit for $TARGET (key: $CACHE_KEY)" >&2
    fi

    # Copy from cache
    cp "$CACHED_TARGET" "$TARGET"

    # Update timestamp to reflect cache hit
    touch "$TARGET"

    exit 0
fi

# Cache miss - run the command
if [[ "$VERBOSE" == "1" ]]; then
    echo "Cache miss for $TARGET (key: $CACHE_KEY)" >&2
fi

eval "$COMMAND"
EXIT_CODE=$?

# If command succeeded, store result in cache
if [[ $EXIT_CODE -eq 0 && -f "$TARGET" ]]; then
    # Store by content hash for deduplication
    CONTENT_HASH=$(sha1sum "$TARGET" | cut -d' ' -f1)
    CONTENT_CACHED="$CACHE_DIR/by-content/$CONTENT_HASH"
    if [[ ! -f "$CONTENT_CACHED" ]]; then
        mkdir -p "$(dirname "$CONTENT_CACHED")"
        cp "$TARGET" "$CONTENT_CACHED"
    fi
    # Link input-addressed entry to content-addressed for deduplication
    ln "$CONTENT_CACHED" "$CACHED_TARGET"

    if [[ "$VERBOSE" == "1" ]]; then
        echo "Stored $TARGET in cache (key: $CACHE_KEY)" >&2
    fi
fi

exit $EXIT_CODE

