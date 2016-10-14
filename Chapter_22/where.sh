#!/bin/sh

#
# Read the input of the user for the system they want to attach to and
# start an x client that contains the connection to that machine as well
# as using the type specified.
#

CONFIG_FILE=$HOME/.whererc.$LOGNAME
LOG_FILE=$HOME/.whererc.${LOGNAME}.log

stty intr '' kill ''
stty erase ''

while true
do
  if [ -f /usr/ucb/echo ]
  then
    /usr/ucb/echo -n "Node: "
  elif [ -f /bin/echo ]
  then
    /bin/echo -n "Node: "
  else
    /usr/bin/echo "Node: "
  fi
   
  read nodename conn
  if [ "$nodename" = "" ]
  then
    continue
  fi

  nodename=`echo $nodename | tr "[A-Z]" "[a-z]"`
  if [ -f $CONFIG_FILE ]
  then
    . $CONFIG_FILE
  fi

  if [ "$CONNECTION_TYPE" = "any" ]
  then
    # These commands timeout in about 2 seconds each..
    S=`nmap -p 22 --max_rtt_timeout 500 $nodename | grep open`
    R=`nmap -p 513 --max_rtt_timeout 500 $nodename | grep open`
    if [ "$S" != "" ]
    then
      CONNECTION_TYPE=ssh
    elif [ "$R" != "" ]
    then
      CONNECTION_TYPE=rlogin
    else
      CONNECTION_TYPE=telnet
    fi
  fi

  if [ "$conn" != "" ]
  then
    case $conn in
      r) # Use rlogin
         CONNECTION_TYPE=rlogin
         ;;
      s) # Use ssh
         CONNECTION_TYPE=ssh
         ;;
      t) # Use telnet
         CONNECTION_TYPE=telnet
         ;;
      *) # Do nothing
         echo
         ;;
    esac
  fi

  echo `date` $nodename $CONNECTION_TYPE $conn >> $LOG_FILE
  third_ip=`grep -w $nodename /etc/hosts | grep -v '^#' | tail -n 1 | awk '{print $1}' | cut -d\. -f3`
  if [ "$third_ip" = "" ]
  then
    third_ip=`echo $nodename | awk -F. '{print $3}'`
    if [ "$third_ip" = "" ]
    then
      nohup $XTERM -fn $FONT -bg $OTHER_BG -fg $OTHER_FG -sb -sl 500 -T "$nodename" -e "$CONNECTION_TYPE" -l $USER $nodename >/dev/null &
      continue
    fi
  fi
  if [ $third_ip -ge 1 -a $third_ip -le 10 ]
  then
    nohup $XTERM -fn $FONT -bg $PROD_BG -fg $PROD_FG -sb -sl 500 -T "$nodename" -e "$CONNECTION_TYPE" -l $USER $nodename >/dev/null &
  elif [ $third_ip -ge 11 -a $third_ip -le 20 ]
  then
    nohup $XTERM -fn $FONT -bg $NON_PROD_BG -fg $NON_PROD_FG -sb -sl 500 -T "$nodename" -e "$CONNECTION_TYPE" -l $USER $nodename >/dev/null &
  else
    nohup $XTERM -fn $FONT -bg $OTHER_BG -fg $OTHER_FG -sb -sl 500 -T "$nodename" -e "$CONNECTION_TYPE" -l $USER $nodename >/dev/null &
  fi
done
