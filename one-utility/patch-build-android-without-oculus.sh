#! /usr/bin/env bash
#
# This is the workaround script to remove Oculus from the Android build in AndroidManifest.xml

REPO_ROOT=$($(which git) rev-parse --show-toplevel)

function removeOculusUsesFeature() {
    find -L "$1" -name AndroidManifest.xml | while read -r line; do
        case $(uname) in
            Darwin)
                sed -i '' '/uses-feature.*android:name="oculus.*/g' "$line"
                ;;
            Linux)
                sed -i '/uses-feature.*android:name="oculus.*/g' "$line"
                ;;
            *)
                echo "Unsupported platform: $(uname)"
                exit 1
                ;;
        esac
    done
}

function main() {
    removeOculusUsesFeature "$REPO_ROOT/one-mobile/flutter_project/android"
    removeOculusUsesFeature "$REPO_ROOT/one-unity/unity-project/development/"
}

main
