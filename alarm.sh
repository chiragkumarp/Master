
# cat alarm_alarm.sh |more
#!/usr/bin/ksh

HOST=`hostname`
case $HOST in
    toiumpp1|to5iumc1) NODE=T
        ;;
    toiumpp2|ml2iumc1) NODE=M
        ;;
    va2iumc1) NODE=V
        ;;
    *) echo "cannot run on server $HOST"; exit 1
        ;;
esac

#### alarm collector need to monitor
ALARM_PROC=${NODE}_X_COM_CL_LOG_C

function directly_send_snmptrap
{

trapsend 172.25.0.92 public 6 1001 1.3.6.1.4.1.11.377 0 \
1.3.6.1.4.1.11.377.1.1 -i 3 \
1.3.6.1.4.1.11.377.1.2 -D $HOST \
1.3.6.1.4.1.11.377.1.3 -D "alarm_alarm" \
1.3.6.1.4.1.11.377.1.4 -D "70.001.03" \
1.3.6.1.4.1.11.377.1.5 -D "Alarm collector down" \
1.3.6.1.4.1.11.377.1.6 -D "Alarm collector down. Please try to start it as per r
un book."
}
function directly_send_snmptrap_up
{
trapsend 172.25.0.92 public 6 1001 1.3.6.1.4.1.11.377 0 \
1.3.6.1.4.1.11.377.1.1 -i 3 \
1.3.6.1.4.1.11.377.1.2 -D $HOST \
1.3.6.1.4.1.11.377.1.3 -D "alarm_alarm" \
1.3.6.1.4.1.11.377.1.4 -D "70.001.05" \
1.3.6.1.4.1.11.377.1.5 -D "Alarm collector has been started up" \
1.3.6.1.4.1.11.377.1.6 -D "Alarm collector has been started up."
}
function check_alarm
{
    FlagFile=/tmp/FlagFileForLogCollector
         ps -ef |grep JVMargs|grep -q  $ALARM_PROC
         if (( $? != 0 )); then
                #echo "send NetCool message."
                directly_send_snmptrap
                if [[ -a $FlagFile ]]
                then
                  #echo "delete FlagFile"
                  rm $FlagFile
           fi
      #echo "ended"
    else
                #echo log collector starts up
                if [[ -a $FlagFile ]]
                then
                  echo "process is running, and the flag file was created!"
      else
                  #echo "process is running with no flag file generated"
                  ps -ef | grep JVMargs|grep -q  $ALARM_PROiC > $FlagFile
                  #echo "send alarm to net cool process starts"
                  directly_send_snmptrap_up
      fi
    fi
}


################# main flow #############
#while true
#do
check_alarm
#sleep 600
#done
