# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Hive and Hadoop environment variables here. These variables can be used
# to control the execution of Hive. It should be used by admins to configure
# the Hive installation (so that users do not have to set environment variables
# or set command line parameters to get correct behavior).
#
# The hive service being invoked (CLI etc.) is available via the environment
# variable SERVICE


# Hive Client memory usage can be an issue if a large number of clients
# are running at the same time. The flags below have been useful in 
# reducing memory usage:
#
# if [ "$SERVICE" = "cli" ]; then
#   if [ -z "$DEBUG" ]; then
#     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:+UseParNewGC -XX:-UseGCOverheadLimit"
#   else
#     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:-UseGCOverheadLimit"
#   fi
# fi

# The heap size of the jvm stared by hive shell script can be controlled via:
#
# export HADOOP_HEAPSIZE=1024
#
# Larger heap size may be required when running queries over large number of files or partitions. 
# By default hive shell scripts use a heap size of 256 (MB).  Larger heap size would also be 
# appropriate for hive server.


# Set HADOOP_HOME to point to a specific hadoop install directory

export HADOOP_HOME=/usr/local/hadoop
export HIVE_HOME=/usr/local/hive
export HIVE_CONF_DIR=/usr/local/hive/conf

# Folder containing extra libraries required for hive compilation/execution can be controlled by:
# export HIVE_AUX_JARS_PATH=

# The heap size of the jvm, and jvm args stared by hive shell script can be controlled via:

if [ "$SERVICE" = "metastore" ]; then

  export HADOOP_HEAPSIZE=3901 # Setting for HiveMetastore
  export HADOOP_OPTS="$HADOOP_OPTS -Xloggc:/var/log/hive/hivemetastore-gc-%t.log -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCCause -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/hive/hms_heapdump.hprof -Dhive.log.dir=/var/log/hive -Dhive.log.file=hivemetastore.log"

fi

if [ "$SERVICE" = "hiveserver2" ]; then

  export HADOOP_HEAPSIZE=11704 # Setting for HiveServer2 and Client
  export HADOOP_OPTS="$HADOOP_OPTS -Xloggc:/var/log/hive/hiveserver2-gc-%t.log -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCCause -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/hive/hs2_heapdump.hprof -Dhive.log.dir=/var/log/hive -Dhive.log.file=hiveserver2.log"

fi



export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS  -Xmx${HADOOP_HEAPSIZE}m"
export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS"

# Larger heap size may be required when running queries over large number of files or partitions.
# By default hive shell scripts use a heap size of 256 (MB).  Larger heap size would also be
# appropriate for hive server (hwi etc).

# Folder containing extra libraries required for hive compilation/execution can be controlled by:
if [ "${HIVE_AUX_JARS_PATH}" != "" ]; then
  if [ -f "${HIVE_AUX_JARS_PATH}" ]; then
    export HIVE_AUX_JARS_PATH=${HIVE_AUX_JARS_PATH}
  elif [ -d "/usr/local/hive/hcatalog/share/hcatalog" ]; then
    export HIVE_AUX_JARS_PATH=/usr/local/hive/hcatalog/share/hcatalog/hive-hcatalog-core-3.1.2.jar
  fi
elif [ -d "/usr/local/hive/hcatalog/share/hcatalog" ]; then
  export HIVE_AUX_JARS_PATH=/usr/local/hive/hcatalog/share/hcatalog/hive-hcatalog-core-3.1.2.jar
fi


export METASTORE_PORT=9083

