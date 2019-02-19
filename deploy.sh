#!/usr/bin/env bash

RED="\033[31m"
GREEN="\033[32m"
BOLD="\033[1m"
NC="\033[0m"

PACKAGE_DIR=package # Directory to bundle everything up
FUNCTION_NAME=$1 # Change this
ZIPPED_PACKAGE=${FUNCTION_NAME}.zip # So that we can use it later
REGION=$2 # Your chosen AWS region, eg eu-west-1
PROFILE="${3:-default}" # Use "default" if you don't have fancy configuration in your ~/.aws/credentials

if [[ -z ${FUNCTION_NAME} ||  -z ${REGION} ||  -z ${PROFILE} ]]; then
    echo -e "${RED}Error! Missing config in deploy.sh"
    echo -e "Make sure you pass FUNCTION_NAME, REGION and PROFILE variables."
    echo -e "${BOLD}e.g. ${0} some_function eu-west-1 some_user1${NC}"
    exit 1
fi


# Install dependencies from requirements.txt
function install_dependencies() {
    mkdir ${PACKAGE_DIR}
    pip install -r requirements.txt --target ${PACKAGE_DIR}/
}

# Copy source files into directory, and zip it up
function zip_files() {
    cp src/* ${PACKAGE_DIR}/
    cd ${PACKAGE_DIR}
    echo -e "\n${BOLD}Zipping up...${NC}"
    zip -r ../${ZIPPED_PACKAGE} *
    cd - &>/dev/null
}

# Upload the zipped directory straight to the AWS Lambda,
function upload_to_aws() {
    echo -e "\n${BOLD}Uploading to AWS Lambda...${NC}"
    aws lambda update-function-code --profile ${PROFILE} --publish --region ${REGION} --function-name ${FUNCTION_NAME} --zip-file fileb://${ZIPPED_PACKAGE}
    EXIT_CODE=$?
    if [[ ${EXIT_CODE} -ne 0 ]]; then
        echo -e "\n***${RED} Failed to upload to AWS Lambda ${NC}***"
    fi

    cleanup
    echo -e "${GREEN}Done. ${NC}"
}

# Remove generated directory and zipped package
function cleanup() {
    rm -rf ${ZIPPED_PACKAGE}
    rm -rf ${PACKAGE_DIR}
}

cleanup
install_dependencies
zip_files
upload_to_aws