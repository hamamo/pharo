#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# The first parameter is the architecture
# The second parameter is the stage name

CACHE="${BOOTSTRAP_CACHE:-bootstrap-cache}"

find ${CACHE}

# I will use the name of the image to determine the vm version (because file name is in the format Pharo7.0.0-rc1)
IMAGE_ARCHIVE=$(find ${CACHE} -name Pharo*-${1}bit-*.zip)
# take VM version
PHARO_VM_VERSION=$(echo "${IMAGE_ARCHIVE}" | cut -d'-' -f 1 | cut - c 6- | cut -d'.' -f 1-2 | sed 's/\.//')
# now download vm
${BOOTSTRAP_REPOSITORY:-.}/bootstrap/scripts/getPharoVM.sh ${PHARO_VM_VERSION} vm ${1}
# ...and continue with the processing
unzip $IMAGE_ARCHIVE
IMAGE_FILE=$(find . -name Pharo*-${1}bit-*.image)
CHANGES_FILE=$(find . -name Pharo*-${1}bit-*.changes)
				
cp ${CACHE}/*.sources .
mv $IMAGE_FILE Pharo.image
mv $CHANGES_FILE Pharo.changes

export PHARO_CI_TESTING_ENVIRONMENT=1

./pharo Pharo.image test --junit-xml-output --stage-name=${2} '.*'
