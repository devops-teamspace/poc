#! /usr/bin/env bash
#
# Change the Unity bundle identifier.
set -e

REPO_ROOT=$($(which git) rev-parse --show-toplevel)
PUBSPECT="${REPO_ROOT}/one-mobile/flutter_project/pubspec.yaml"

VERSION=$(grep 'version: ' "$PUBSPECT" | cut -d ' ' -f 2)
BUILD_VERSION=$(echo "$VERSION" | cut -d '+' -f 1)
BUILD_NUMBER=$(echo "$VERSION" | cut -d '+' -f 2)

function main() {
    PROJ_SETTINGS="${REPO_ROOT}/one-unity/unity-project/development/complete-unity/ProjectSettings/ProjectSettings.asset"
    SENTRY_OIPTIONS="${REPO_ROOT}/one-unity/unity-project/development/complete-unity/Assets/Resources/Sentry/SentryOptions.asset"

    case $(uname) in
        Darwin)
            sed -i '' "s/bundleVersion: .*/bundleVersion: ${BUILD_VERSION}/g" "${PROJ_SETTINGS}"
            sed -i '' "s/iPhone: 0/iPhone: ${BUILD_NUMBER}/g" "${PROJ_SETTINGS}"
            sed -i '' "s/AndroidBundleVersionCode: 1/AndroidBundleVersionCode: ${BUILD_NUMBER}/g" "${PROJ_SETTINGS}"
            sed -i '' "s/<ReleaseOverride>k__BackingField:/<ReleaseOverride>k__BackingField: ${VERSION}/g" "${SENTRY_OIPTIONS}"
            ;;
        *)
            sed -i "s/bundleVersion: .*/bundleVersion: ${BUILD_VERSION}/g" "${PROJ_SETTINGS}"
            sed -i "s/iPhone: 0/iPhone: ${BUILD_NUMBER}/g" "${PROJ_SETTINGS}"
            sed -i "s/AndroidBundleVersionCode: 1/AndroidBundleVersionCode: ${BUILD_NUMBER}/g" "${PROJ_SETTINGS}"
            sed -i "s/<ReleaseOverride>k__BackingField:/<ReleaseOverride>k__BackingField: ${VERSION}/g" "${SENTRY_OIPTIONS}"
            ;;
    esac

    echo "$VERSION" >"$REPO_ROOT/one-unity/unity-project/development/complete-unity/.version"
    echo "$VERSION" >"$REPO_ROOT/one-mobile/flutter_project/.version"
    echo "$VERSION"
}

main "${1:-$VERSION}"
