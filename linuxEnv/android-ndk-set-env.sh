#!/bin/bash

set_path_file="$HOME/.bash_profile"

echo -e "input your androidNDK install path:"
read androidNDKInstallPath
if [ -n "${androidNDKInstallPath}" ]; then
  echo -e "you set install androidNDK path is ${androidNDKInstallPath}"
else
  echo -e "you are not set androidNDK install path, exit"
  exit 1
fi

# check androidNDK install path
if [ ! -d "${androidNDKInstallPath}" ]; then
  echo -e "you androidNDK install path is empty, exit"
  exit 1
fi

echo -e "This script set event of java!
Env set file path: ${set_path_file}
JAVA_HOME -> ${androidNDKInstallPath}
\n"

if [ ! -f "${set_path_file}" ]; then
  cat > "${set_path_file}" << EOF
# environment set by https://github.com/sinlov/Golang-Shell

EOF
fi

cat >> "${set_path_file}" << EOF

# set androidNDK environment
ANDROID_NDK_HOME=${androidNDKInstallPath}
export ANDROID_NDK_HOME
export PATH=\${ANDROID_NDK_HOME}:\$PATH
EOF
echo -e "androidNDK evn set at ${set_path_file}
You can change by your self or load path by
source ${set_path_file}"
