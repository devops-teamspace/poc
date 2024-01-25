#! /usr/bin/env bash
#
# This script is used to remove the sensitive log from the log file.
# It should be executed when release the product.

REPO_ROOT=$($(which git) rev-parse --show-toplevel)

function remove_sentry_sensitive() {
    UNITY_PROJ_SETTINGS="$REPO_ROOT/one-unity/unity-project/development/complete-unity/ProjectSettings/ProjectSettings.asset"

    case $(uname) in
        Darwin)
            sed -i '' 's/;TPFIVE_SENTRY_DEBUG//g' "$UNITY_PROJ_SETTINGS"
            ;;
        *)
            sed -i 's/;TPFIVE_SENTRY_DEBUG//g' "$UNITY_PROJ_SETTINGS"
            ;;
    esac
}

function main() {
    remove_sentry_sensitive
}

main
