#! /usr/bin/env bash
#
# Change the Unity bundle identifier.
set -e

REPO_ROOT=$($(which git) rev-parse --show-toplevel)

# https://stackoverflow.com/a/2264537/1151939
function TitleCase() {
    set "${*,,}"
    echo "${*^}"
}

function main() {
    ENV_NAME=$(TitleCase "$1")
    SENTRY_OIPTIONS="${REPO_ROOT}/one-unity/unity-project/development/complete-unity/Assets/Resources/Sentry/SentryOptions.asset"

    case $(uname) in
        Darwin)
            sed -i '' "s/<EnvironmentOverride>k__BackingField:.*/<EnvironmentOverride>k__BackingField: ${ENV_NAME}/g" "${SENTRY_OIPTIONS}"
            ;;
        *)
            sed -i "s/<EnvironmentOverride>k__BackingField:.*/<EnvironmentOverride>k__BackingField: ${ENV_NAME}/g" "${SENTRY_OIPTIONS}"
            ;;
    esac
}

main "${1:-Dev}"
