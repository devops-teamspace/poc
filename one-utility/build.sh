#! /usr/bin/env bash
#
# The All-in-one build script for build the TP-Five project.
set -e -o pipefail

REPO_ROOT=$($(which git) rev-parse --show-toplevel)

UNITY_VER="${UNITY_VER:-2022.3.10f1}"
UNITY="/Applications/Unity/Hub/Editor/$UNITY_VER/Unity.app/Contents/MacOS/Unity"
BUILD_ENV="dev"
BUNDLE_ID="com.xrspace.tpfive.dev"
FLUTTER_BUILD_ARGS="--debug --flavor dev --target lib/main_dev.dart"

function main() {
    parse_args "$@"
    build_and_install
}

function welcome() {
    echo "Usage: build.sh [options] [platform]"
    echo "Build the TP-Five project."
    echo ""
    echo "Options:"
    echo "  -c: Clean the build environment."
    echo "  -h: Show this help message."
    echo "  -i: Install the artifact into local device."
    echo "  -m: Mock build the unity project."
    echo "  -r: Build the release artifact."
    echo ""
    echo "Platforms:"
    echo "  android            Build the Android artifact."
    echo "  bundle             Build the Android AAB bundle."
    echo "  vr                 Build the Oculus Quest artifact."
}

function parse_args() {
    while getopts "chimr" opt; do
        case $opt in
            c)
                echo "Clean the build environment..."

                git checkout .
                git clean -ffd one-unity one-mobile

                pushd one-mobile/flutter_project >/dev/null || exit 1
                flutter clean
                popd >/dev/null || exit 1
                ;;
            h)
                :
                welcome
                exit 0
                ;;
            i)
                INSTALL_INTO_DEVICE=1
                ;;
            m)
                MOCK_BUILD=1
                ;;
            r)
                BUILD_ENV="prod"
                BUNDLE_ID="com.xrspace.tpfive"
                FLUTTER_BUILD_ARGS="--release --flavor prod --target lib/main_prod.dart"
                ;;
            *)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    shift $((OPTIND - 1))
    PLATFORM="${1:-ios}"
}

function check_or_install() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Installing $1..."
        brew install "$1"
    fi
}

function build_and_install() {
    "$REPO_ROOT/one-utility/decrypt_env.sh" "$BUILD_ENV"
    "$REPO_ROOT/one-utility/change_unity_bundle_ver.sh"

    build_unity
    build_artifact
    install_artifact
}

function build_unity() {
    echo -e "\x1b[1;33minfo\x1b[m Build and export unity project ..."

    case "$MOCK_BUILD" in
        1)
            "$REPO_ROOT/one-utility/mock_unity.sh"
            ;;
        *)
            case "$PLATFORM" in
                ios)

                    "$REPO_ROOT/one-utility/patch-build-ios-app.sh"
                    "$REPO_ROOT/one-utility/enable_unity_sentry.sh"
                    "$REPO_ROOT/one-utility/patch-build-mobile-app.sh"
                    BUILD_METHOD="FlutterUnityIntegration.Editor.Build.DoBuildIOSRelease"
                    ;;
                android | bundle)
                    "$REPO_ROOT/one-utility/publish_auth_aar.sh"
                    "$REPO_ROOT/one-utility/change_unity_bundle_id.sh" "$BUNDLE_ID"

                    BUILD_METHOD="FlutterUnityIntegration.Editor.Build.DoBuildAndroidLibraryRelease"
                    ;;
                vr)
                    "$REPO_ROOT/one-utility/publish_auth_aar.sh"
                    "$REPO_ROOT/one-utility/change_unity_bundle_id.sh" "$BUNDLE_ID"

                    BUILD_METHOD="TPFive.Build.Editor.Builder.BuildOculus"
                    ;;
                *)
                    echo "Invalid platform: $PLATFORM" >&2
                    exit 1
                    ;;
            esac

            echo -e "\x1b[1;33minfo\x1b[m Start export unity and it may \x1b[1;31;3mtake a while\x1b[m..."
            "$UNITY" \
                -batchmode \
                -quit \
                -logfile build.log \
                -projectPath "$REPO_ROOT/one-unity/unity-project/development/complete-unity" \
                -executeMethod "$BUILD_METHOD"
            ;;
    esac
}

function build_artifact() {
    echo -e "\x1b[1;33minfo\x1b[m Build the final artifact ..."
    pushd "$REPO_ROOT/one-mobile/flutter_project/" >/dev/null || exit 1

    flutter clean
    flutter pub get
    case "$PLATFORM" in
        ios)
            echo "Building iOS artifact..."

            pushd "$REPO_ROOT/one-mobile/flutter_project/ios" >/dev/null || exit 1
            pod install
            popd >/dev/null || exit 1

            "$REPO_ROOT/one-utility/link-unity-frameworks.sh"
            flutter build ios --no-codesign --no-tree-shake-icons
            ;;
        android)
            echo "Building Android artifact..."

            "$REPO_ROOT/one-utility/patch-build-android-without-oculus.sh"
            pushd "$REPO_ROOT/one-mobile/flutter_project/android" >/dev/null || exit 1

            "$REPO_ROOT/one-utility/patch-build-android-without-oculus.sh"
            # shellcheck disable=SC2086
            flutter build apk $FLUTTER_BUILD_ARGS --target-platform android-arm64
            popd >/dev/null || exit 1
            ;;
        bundle)
            echo "Building Android AAB bundle..."

            "$REPO_ROOT/one-utility/patch-build-android-without-oculus.sh"
            pushd "$REPO_ROOT/one-mobile/flutter_project/android" >/dev/null || exit 1

            "$REPO_ROOT/one-utility/patch-build-android-without-oculus.sh"
            # shellcheck disable=SC2086
            flutter build appbundle $FLUTTER_BUILD_ARGS --target-platform android-arm,android-arm64
            popd >/dev/null || exit 1
            ;;
    esac

    popd >/dev/null || exit 1
}

function install_artifact() {
    if [[ -z "$INSTALL_INTO_DEVICE" ]]; then
        return
    fi

    echo -e "\x1b[1;33minfo\x1b[mInstalling artifact..."
    case "$PLATFORM" in
        ios)
            echo "Installing iOS artifact..."

            pushd "$REPO_ROOT/one-mobile/flutter_project/ios" >/dev/null || exit 1

            if [ -z "$DEVICE_ID" ]; then
                read -rp "Please Enter your device ID or phone name: " DEVICE_NAME
                DEVICE_ID="$(xcrun xctrace list devices | grep -E "$DEVICE_NAME" | grep -oE '([0-9A-F]{8}-[0-9A-F]{16})')"

                if [ -z "$DEVICE_ID" ]; then
                    echo "No device found with name: $DEVICE_NAME" >&2
                    exit 1
                fi
            fi

            "$REPO_ROOT/one-utility/link-unity-frameworks.sh"
            fastlane match development --readonly
            env DEVICE_ID="$DEVICE_ID" fastlane install

            popd >/dev/null || exit 1
            ;;
        android)
            adb shell pm list packages | grep com\.xrspace\. | cut -d ":" -f 2 | xargs -n 1 adb uninstall
            find "$REPO_ROOT/one-mobile/flutter_project/build/app/outputs/flutter-apk/" -name "*.apk" -exec adb install {} \;
            ;;
    esac
}

main "$@"
