#!/usr/bin/env bash
#
# This is start script for spring boot application.
#
#

### Envionment Variables

BIN="`dirname "$0"`"
HOME="`cd "$BIN";cd ..; pwd`"
echo $HOME

export PROJECT_HOME=$HOME
export DATA_HOME=$HOME"/data"
export RUNNING_HOME=$PROJECT_HOME/running
export LOG_HOME=$PROJECT_HOME/log

### JVM
JVM_MEMORY="-Xmx4g -Xms4g -Xss1m -XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=512m"
JVM_GC="-XX:+UseG1GC -XX:MaxGCPauseMillis=200"
JVM_GC_LOG="-Xlog:gc*,gc+heap=debug:$LOG_HOME/gc-heap.log:time,uptime,level,tags:filecount=10,filesize=20971520 -Xlog:gc*,gc+heap=debug,safepoint:$LOG_HOME/gc-heap-safepoint.log:time,uptime,level,tags:filecount=10,filesize=20971520"
JVM_PROPERTIES="-Dfile.encoding=UTF-8"
JVM_ARGS=$JVM_MEMORY" "$JVM_GC" "$JVM_GC_LOG" -XX:+HeapDumpOnOutOfMemoryError"
JVM_DEBUG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:34520"

### Functions
function usage(){
cat << EOF
Usage:
    service.sh <command> [service.jar] [-D key=value] [-JAVA_HOME <java_home>] [-Debug <debug_args>] [-JVM_ARGS <"jvm_args">] [--no-daemon] [args...]
The commands are:
    start   start service
    debug   debug service
    stop    stop service
The arguments are:
    --no-daemon     Optional. The service will run on the foreground.
Examples
    service.sh start <service.jar> [-D key=value] [args...]
    service.sh stop
EOF
}

function check_process_is_running(){
    if [ -f $RUNNING_HOME/service.pid ]; then
        pid=`cat $RUNNING_HOME/service.pid`
        ps $pid > /dev/null 2>&1
        return $?
    fi
    return 1
}

function init(){
    if [ ! -d $LOG_HOME ];then
        mkdir $LOG_HOME
    fi
    if [ ! -d $RUNNING_HOME ]; then
        mkdir $RUNNING_HOME
    fi
}

### start script

command=$1
case $command in
    start|debug)
        if [ $# -lt 2 ]; then
            usage
            exit 1
        fi
        init
        check_process_is_running
        if [ $? -eq 0 ]; then
            echo "Service[pid="`cat $RUNNING_HOME/pid`"] Already Started, Stop It First"
            exit 11
        fi
        EXEC_JAR=$2

        shift 2
        while [[ $# > 0 ]]
            do
                case $1 in
                    --no-daemon)
                        no_daemon="yes"
                        shift
                        ;;
                    -D)
                        JVM_PROPERTIES="-D$2 $JVM_PROPERTIES"
                        shift 2
                        ;;
                    -JAVA_HOME)
                        export JAVA_HOME=$2
                        shift 2
                        ;;
                    -JVM_ARGS)
                        JVM_ARGS="$JVM_ARGS $2"
                        shift 2
                        ;;
                    -Debug)
                        JVM_DEBUG=$2
                        shift 2
                        ;;
                    *)
                        break
                        ;;
                esac
            done

        if [ -z "$JAVA_HOME" ]; then
            echo "Error: JAVA_HOME is not set."
            exit 111
        fi
        JAVA="$JAVA_HOME/bin/java -server"
        if [ $command == "debug" ]; then
            JVM_ARGS="$JVM_ARGS $JVM_DEBUG"
        fi

        RUN_COMMAND="$JAVA $JVM_ARGS $JVM_PROPERTIES -jar $EXEC_JAR $@"
        echo "Service is now starting..."
        echo "[Command]" $RUN_COMMAND

        if [ -z "$no_daemon" ]; then
            nohup $RUN_COMMAND > $LOG_HOME/stdout.log 2>$LOG_HOME/stderr.log &
            echo $! > $RUNNING_HOME/service.pid
        else
            $RUN_COMMAND
        fi


     ;;
    stop)
        check_process_is_running
        if [ $? -eq 0 ]; then
            kill $pid
            echo "Stop Service[pid=$pid]..."
            sleep 3
        else
            echo "No Service Is Running"
        fi
     ;;
    *)
        echo Unsupported operation: $command
        usage
     exit 9
   ;;
esac
