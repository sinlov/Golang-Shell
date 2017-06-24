#!/bin/bash

# this scirpt need set ANDROID_HOME
(while :; do echo 'y'; sleep 3; done) | android update sdk --no-ui --all --filter "$(cat ${ANDROID_HOME}/android_sdk_components.env)"
