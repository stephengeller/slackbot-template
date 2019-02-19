#!/usr/bin/env bash

PACKAGE_DIR=package # Directory to bundle everything up
FUNCTION_NAME=SOME_LAMBDA_FUNCTION_NAME # Change this
ZIPPED_PACKAGE=${FUNCTION_NAME}.zip # So that we can use it later
REGION=SOME_REGION # Your chosen AWS region, eg eu-west-1
PROFILE=SOME_PROFILE # Write "default" if you don't have more fancy configuration


# Install dependencies from requirements.txt
function install_dependencies() {
    mkdir ${PACKAGE_DIR}
    pip install -r requirements.txt --target ${PACKAGE_DIR}/
}

# Copy source files into directory, and zip it up
function zip_files() {
    cp src/* ${PACKAGE_DIR}/
    cd ${PACKAGE_DIR}
    echo "Zipping up..."
    zip -r ../${ZIPPED_PACKAGE} *
    cd - &>/dev/null
}

# Upload the zipped directory straight to the AWS Lambda,
function upload_to_aws() {
    echo "Uploading to AWS Lambda..."
    aws lambda update-function-code --profile ${PROFILE} --publish --region ${REGION} --function-name ${FUNCTION_NAME} --zip-file fileb://${ZIPPED_PACKAGE}
    cleanup
    echo "Done."
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