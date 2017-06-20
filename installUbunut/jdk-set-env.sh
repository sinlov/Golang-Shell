#!/bin/bash

set_path_file="$HOME/.bash_profile"

echo -e "input your jdk install path:"
read jdkInstallPath
if [ -n "${jdkInstallPath}" ]; then
  echo -e "you set install jdk path is ${jdkInstallPath}"
else
  echo -e "you are not set jdk install path, exit"
  exit 1
fi

# check jdk install path
if [ ! -d "${jdkInstallPath}" ]; then
  echo -e "you jdk install path is empty, exit"
  exit 1
fi

echo -e "This script set event of java!
Env set file path: ${set_path_file}
JAVA_HOME -> ${jdkInstallPath}
\n"

if [ -f "${set_path_file}" ]; then
  cat > "${set_path_file}" << EOF
# environment set by https://github.com/sinlov

EOF
fi

cat >> "${set_path_file}" << EOF
# set java environment
export JAVA_HOME=${jdkInstallPath}
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
EOF
echo -e "jdk evn set at ${set_path_file}
You can change by your self or load path by
source ${set_path_file}"
