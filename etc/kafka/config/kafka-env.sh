#!/bin/bash

# Set KAFKA specific environment variables here.

# The java implementation to use.
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export PATH=$PATH:$JAVA_HOME/bin
export PID_DIR=/var/run/kafka
export LOG_DIR=/var/log/kafka

export KAFKA_KERBEROS_PARAMS=

