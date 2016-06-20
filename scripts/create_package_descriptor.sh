#!/bin/bash

. ${SOURCEDIR}/scripts/lib/pkg_environment.sh

ruby ${SOURCEDIR}/scripts/lib/write_package_descriptor.rb > ${SOURCEDIR}/.cmkpackage.json
