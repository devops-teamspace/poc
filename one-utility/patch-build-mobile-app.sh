#! /usr/bin/env bash

REPO_ROOT=$($(which git) rev-parse --show-toplevel)
UNITY_PROJ="${REPO_ROOT}/one-unity/unity-project/development/complete-unity"
REMOVE_PKG=(
    # Firebase
    "com.google.firebase.app"
    "com.google.firebase.analytics"
    "io.xrspace.tpfive.extended.firebase-remoteconfig"
    "io.xrspace.tpfive.extended.google-analytics"
)

REMOVE_TGZ=(
    "Packages/GooglePackages/com.google.firebase.analytics-11.3.0.tgz"
    "Packages/GooglePackages/com.google.firebase.app-11.3.0.tgz"
)

main() {
    PACKAGE_LOCK="Packages/packages-lock.json"
    MANIFEST_JSON="Packages/manifest.json"

    pushd "$UNITY_PROJ" || exit 1

    # remove the package file
    for tgz in "${REMOVE_TGZ[@]}"; do
        rm -f "${tgz}" || true
    done

    for pkg in "${REMOVE_PKG[@]}"; do
        jq "del(.dependencies.\"$pkg\")" "${PACKAGE_LOCK}" >"${PACKAGE_LOCK}.tmp"
        mv "${PACKAGE_LOCK}.tmp" "${PACKAGE_LOCK}"

        jq "del(.dependencies.\"$pkg\")" "${MANIFEST_JSON}" >"${MANIFEST_JSON}.tmp"
        mv "${MANIFEST_JSON}.tmp" "${MANIFEST_JSON}"
    done
}

main
