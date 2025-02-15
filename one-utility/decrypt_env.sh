#!/bin/bash
# Usage example:
# $ decrypt_env.sh local # to decrypt local env files
# $ decrypt_env.sh dev # to decrypt dev env files

REPO_ROOT=$($(which git) rev-parse --show-toplevel)

validate_env() {
    envs=(local dev qa prod)
    if [[ ! "${envs[*]}" =~ ${1} ]]; then
        echo "local"
        exit 0
    fi
    echo "${1}"
}

env=$(validate_env "${1}")
echo "env=${env}"

function decrypt_env_file() {
    SOURCE_ENCRYPTED_FILE="${1}/.${env}.env"
    TARGET_ENCRYPTED_FILE="${2}/.env"

    echo The encryped file:
    echo "${SOURCE_ENCRYPTED_FILE}"
    echo The decrypted file:
    echo "${TARGET_ENCRYPTED_FILE}"

    git checkout "${SOURCE_ENCRYPTED_FILE}"
    if ! sops -d "${SOURCE_ENCRYPTED_FILE}" >"${TARGET_ENCRYPTED_FILE}"; then
        echo "Can not decrypt env file"
        exit 1
    fi
}

function decrypt_env_files() {
    # decrypt auth env file to unity project
    AUTH_ENV_SOURCE_FOLDER=$REPO_ROOT/one-native
    AUTH_ENV_UNITY_TARGET_FOLDER=$REPO_ROOT/one-unity/unity-project/development/complete-unity
    decrypt_env_file "${AUTH_ENV_SOURCE_FOLDER}" "${AUTH_ENV_UNITY_TARGET_FOLDER}"

    # decrypt auth env file for flutter project
    AUTH_ENV_FLUTTER_TARGET_FOLDER=$REPO_ROOT/one-mobile/flutter_project
    decrypt_env_file "${AUTH_ENV_SOURCE_FOLDER}" "${AUTH_ENV_FLUTTER_TARGET_FOLDER}"

    # decrypt cms env file
    CMS_FOLDER=$REPO_ROOT/one-cms
    decrypt_env_file "${CMS_FOLDER}" "${CMS_FOLDER}"

    # decrypt backend env file
    BACKEND_FOLDER=$REPO_ROOT/one-backend
    if ! decrypt_env_file "${BACKEND_FOLDER}" "${BACKEND_FOLDER}"; then
        echo "Can not decrypt env files correctly, please refer to:"
        echo "https://xrspace.atlassian.net/wiki/spaces/TF/pages/2254897163/Confidential+Data+Management"

        return
    fi

    if [ "$env" == "prod" ]; then
        echo "Skip decrypting one-data for prod env"
        return
    fi
    DATA_FOLDER=$REPO_ROOT/one-data
    decrypt_env_file "${DATA_FOLDER}" "${DATA_FOLDER}"
}

function decrypt_google_api_key() {
    if [ "$env" == "qa" ]; then
        echo "Skip decrypting one-data for qa env"
        return
    fi

    DECRYPT_ENV="$env"
    if [ "$env" == "local" ]; then
        echo "decrypt google api key for local env"
        DECRYPT_ENV="dev"
    fi

    GOOGLE_API_KEY_FILES="${REPO_ROOT}/one-mobile/flutter_project/android/app/src/${DECRYPT_ENV}/google-services.${DECRYPT_ENV}.json"

    FOLDER_OF_FILE=$(dirname "$GOOGLE_API_KEY_FILES")
    if ! sops -d "$GOOGLE_API_KEY_FILES" >"${FOLDER_OF_FILE}/google-services.json"; then
        echo "Can not decrypt google api key"
        exit 1
    fi
}

function decrypt_firebase_credentials() {
    DECRYPT_ENV="$env"
    if [ "$env" == "qa" ]; then
        echo "decrypt firebase credentials qa env"
        DECRYPT_ENV="prod"
    fi

    FIREBASE_CREDENTIALS_FILE="${REPO_ROOT}/one-backend/firebase-credentials.${DECRYPT_ENV}.json"

    FOLDER_OF_FILE=$(dirname "$FIREBASE_CREDENTIALS_FILE")
    if ! sops -d "$FIREBASE_CREDENTIALS_FILE" >"${FOLDER_OF_FILE}/server/firebase-credentials.json"; then
        echo "Can not decrypt firebase credentials"
        exit 1
    fi
}

function remove_sensitive() {
    if [ "$env" == "local" ] || [ "$env" == "dev" ]; then
        return
    fi

    "$REPO_ROOT/one-utility/remove_sensitive_log.sh"
}

decrypt_env_files
decrypt_google_api_key
decrypt_firebase_credentials
remove_sensitive
echo "Decrypt correctly"
