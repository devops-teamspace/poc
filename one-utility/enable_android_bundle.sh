#! /usr/bin/env bash
#
# The utility script to enable Android bundle for Flutter project.

REPO_ROOT=$($(which git) rev-parse --show-toplevel)

MOBILE_ANDROID_PATH="$REPO_ROOT/one-mobile/flutter_project/android"
UNITY_PROJECT_PATH="$REPO_ROOT/one-unity/unity-project/development/complete-unity/ProjectSettings"

function sed_patch() {
    PATTERN="$1"
    FILE="$2"

    case "$(uname)" in
        Darwin)
            sed -i '' "$PATTERN" "$FILE"
            ;;
        Linux)
            sed -i "$PATTERN" "$FILE"
            ;;
        *)
            echo "Unsupported OS: $(uname)"
            exit 1
            ;;
    esac
}

function main() {
    sed_patch 's#// \(.*UnityDataAssetPack\)#\1#g' "$MOBILE_ANDROID_PATH/app/build.gradle"
    sed_patch 's#// \(.*UnityDataAssetPack\)#\1#g' "$MOBILE_ANDROID_PATH/settings.gradle"

    sed_patch 's#APKExpansionFiles: 0#APKExpansionFiles: 1#g' "$UNITY_PROJECT_PATH/ProjectSettings.asset"
    sed_patch 's#projectExportEnabled" value="False#projectExportEnabled" value="True#g' "$UNITY_PROJECT_PATH/AndroidResolverDependencies.xml"
}

main
