#!/bin/bash

set_path_file="$HOME/.bash_profile"

echo -e "input your android install path:"
read androidInstallPath
if [ -n "${androidInstallPath}" ]; then
  echo -e "you set install android path is ${androidInstallPath}"
else
  echo -e "you are not set android install path, exit"
  exit 1
fi

# check android install path
if [ ! -d "${androidInstallPath}" ]; then
  echo -e "you android install path is empty, exit"
  exit 1
fi

echo -e "This script set event of java!
Env set file path: ${set_path_file}
JAVA_HOME -> ${androidInstallPath}
\n"

if [ -f "${set_path_file}" ]; then
  cat > "${set_path_file}" << EOF
# environment set by https://github.com/sinlov

EOF
fi

cat >> "${set_path_file}" << EOF
# set android environment
ANDROID_HOME=${androidInstallPath}
export ANDROID_HOME
export PATH=\${ANDROID_HOME}/tools:\${ANDROID_HOME}/platform-tools:\${ANDROID_HOME}/build-tools/24.0.0:\$PATH
EOF
echo -e "android evn set at ${set_path_file}
You can change by your self or load path by
source ${set_path_file}"
