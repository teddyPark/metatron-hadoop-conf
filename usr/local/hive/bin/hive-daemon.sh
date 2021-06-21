#!/usr/bin/env bash

# Start, stop, status, clean or setup
HIVE_LAUNCH_COMMAND=$1
HIVE_LAUNCH_DAEMON=$2
source $HADOOP_CONF_DIR/hadoop-env.sh 

# Proccss id 
PID=0

# User Name for setup parameter
HIVE_USER=hive

#App name
APP_NAME=hive

#PID & LOG DIRs

[ -z $PID_DIR ] && PID_DIR="/var/run/$APP_NAME"
[ -z $LOG_DIR ] && LOG_DIR="/var/log/$APP_NAME"

#Name of PID file
PID_FILE="$PID_DIR/$HIVE_LAUNCH_DAEMON.pid"

#Name of LOG ERR file
ERR_FILE="$LOG_DIR/$HIVE_LAUNCH_DAEMON.err"

[ -z $MAX_WAIT_TIME ] && MAX_WAIT_TIME=120

function main {

   case "$1" in
      start)
         daemonStart $HIVE_LAUNCH_DAEMON
         ;;
      stop)
         daemonStop
         ;;
      status)
         daemonStatus
         ;;
      restart)
         daemonStop
         daemonStart $HIVE_LAUNCH_DAEMON
         ;;
      *)
         printf "Usage: $0 {start|stop|status|restart} {hiveserver2|metastore}\n"
         ;;
   esac
}

function daemonStart {

   getPID
   daemonIsRunning $PID
   if [ $? -eq 1 ]; then
     printf "$HIVE_LAUNCH_DAEMON is already running with PID=$PID.\n"
     exit 0
   fi
   printf "Starting $HIVE_LAUNCH_DAEMON "

   nohup $HIVE_HOME/bin/hive --service $1 >> /dev/null 2>>$ERR_FILE & echo $! > $PID_DIR/$HIVE_LAUNCH_DAEMON.pid &

   sleep 1

   getPID
   daemonIsRunning $PID
   if [ $? -ne 1 ]; then
      printf "failed.\n"
      exit 1
   fi

   printf "succeeded with PID=$PID.\n"
   return 0

}

function daemonStop {

   getPID 
   daemonIsRunning $PID
   if [ $? -eq 0 ]; then
     printf "$HIVE_LAUNCH_DAEMON is not running.\n"
     rm -f $PID_FILE
     return 0
   fi

   printf "Stopping $HIVE_LAUNCH_DAEMON [$PID] "
   daemonKill $PID >>/dev/null 2>>$ERR_FILE

   if [ $? -ne 0 ]; then
     printf "failed. \n"
     exit 1
   else
     rm -f $PID_FILE
     printf "succeeded.\n"
     return 0
   fi

}

function daemonKill {
   local localPID=$1
   printf $localPID
   kill $localPID || return 1
   for ((i=0; i<MAX_WAIT_TIME; i++)); do
      daemonIsRunning $localPID
      if [ $? -eq 0 ]; then return 0; fi
      sleep 1
   done

   kill -s KILL $localPID || return 1
   for ((i=0; i<MAX_WAIT_TIME; i++)); do
      daemonIsRunning $localPID
      if [ $? -eq 0 ]; then return 0; fi
      sleep 1
   done

   return 1
}

function daemonStatus {
   printf "$HIVE_LAUNCH_DAEMON "
   getPID
   if [ $? -eq 1 ]; then
     printf "is not running. No pid file found.\n"
     return 0
   fi

   daemonIsRunning $PID
   if [ $? -eq 1 ]; then
     printf "is running with PID=$PID.\n"
     exit 1
   else
     printf "is not running.\n"
     return 0
   fi
}

# Returns 0 if the Knox is running and sets the $PID variable.
function getPID () {
   if [ ! -d $PID_DIR ]; then
      printf "Can't find pid dir.\n"
      exit 1
   fi
   if [ ! -f "$PID_DIR/$HIVE_LAUNCH_DAEMON.pid" ]; then
     PID=0
     return 1
   fi

   PID="$(<$PID_FILE)"
   return 0
}

function daemonIsRunning {
   if [ $1 -eq 0 ]; then return 0; fi

   ps -p $1 > /dev/null

   if [ $? -eq 1 ]; then
     return 0
   else
     return 1
   fi
}

#Starting main
main $HIVE_LAUNCH_COMMAND
