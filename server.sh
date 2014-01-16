#!/bin/sh

APPNAME=sandBox_server
JAVAMAIN=SandBoxServer
JDK=java
XMS=-Xms3m 
XMX=-Xmx192m

case $0 in
    /*)
 SCRIPT="$0"
 ;;
    *)
        PWD=$(pwd)
 SCRIPT="$PWD/$0"
esac
REALPATH=$(dirname $SCRIPT)

cd $REALPATH

CLASSPATH=./:./TcpSandBox-0.0.1-SNAPSHOT.jar

export LANG=zh_CN.gbk
PIDFILE=${REALPATH}/${APPNAME}.pid
LOGFILE=${REALPATH}/${APPNAME}.log

getpid() {
    if [ -f $PIDFILE ]
    then
        if [ -r $PIDFILE ]
        then
            pid=`cat $PIDFILE`
            if [ "X$pid" != "X" ]
            then
                # Verify that a process with this pid is still running.
                pid=`ps -p $pid | grep $pid | grep -v grep | awk '{print $1}' | tail -1`
                if [ "X$pid" = "X" ]
                then
                    # This is a stale pid file.
                    rm -f $PIDFILE
                    echo "Removed stale pid file: $PIDFILE"
                fi
            fi
 else
            echo "Cannot read $PIDFILE."
            exit 1
        fi
    fi
}

testpid() {
    pid=`ps -p $pid | grep $pid | grep -v grep | awk '{print $1}' | tail -1`
    if [ "X$pid" = "X" ]
    then
        # Process is gone so remove the pid file.
        rm -f $PIDFILE
    fi
}
start_server(){
    echo "Starting $APPNAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
   nohup ${JDK} -server $XMS $XMX -Dfile.encoding=UTF-8 -Djava.library.path=../lib -classpath $CLASSPATH ${JAVAMAIN} >${LOGFILE} 2>&1 &
   echo $! > ${PIDFILE}
   echo "$APPNAME Start finished" 
   else
        echo "$APPNAME is already running."
        exit 1
   fi
}

stop_server(){
    echo "Stopping $APPNAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        echo "$APPNAME was not running."
    else
        # Running so try to stop it.
        kill $pid
        if [ $? -ne 0 ]
           then
               echo "Unable to stop $APPNAME."
               exit 1
        fi

        #  Loop until it does.
        savepid=$pid
        CNT=0
        TOTCNT=0
        while [ "X$pid" != "X" ]
        do
            # Loop for up to 5 minutes
            if [ "$TOTCNT" -lt "30" ]
            then
                if [ "$CNT" -lt "5" ]
                then
                    CNT=`expr $CNT + 1`
                else
                    echo "Waiting for $APPNAME. to exit..."
                    CNT=0
                fi
                TOTCNT=`expr $TOTCNT + 1`

                sleep 1

                testpid
            else
                pid=
            fi
        done

        pid=$savepid
        testpid
        if [ "X$pid" != "X" ]
        then
            echo "Timed out waiting for $APPNAME to exit."
            echo "  Attempting a forced exit..."
            kill -9 $pid
        fi

        pid=$savepid
        testpid
        if [ "X$pid" != "X" ]
        then
            echo "Failed to stop $APPNAME."
            exit 1
        else
            echo "Stopped $APPNAME."
        fi
    fi
}

status_server(){
  getpid
  if [ "X$pid" = "X" ]
  then
      echo "the server is not running."
      exit 1
  else
      echo "the server is running ($pid)."
      exit 0
  fi
}

case "$1" in
  'stop')
    stop_server $1
    ;;
  'start')
    start_server $1
    ;;
  'restart')
    stop_server $1
    start_server $1
    ;;
  'status')
    status_server $1
    ;;
  *)
    printf "action : start | stop | restart | status \n"
    exit 1
    ;;
esac

