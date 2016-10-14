#!/bin/sh

#
# Display the small window that receives the input to connect to other
# remote machines.  Set up the user configuration if it doesn't already
# exist.
#

CONFIG_FILE=$HOME/.whererc.$LOGNAME

RLOGIN_TITLE="Where..."
RLOGIN_FG=red
RLOGIN_BG=ivory

if [ -f $HOME/.whererc ]
then
  mv $HOME/.whererc $CONFIG_FILE
  . $CONFIG_FILE
elif [ -f $CONFIG_FILE ]
then
  . $CONFIG_FILE
else
  cat > $CONFIG_FILE <<EOF
# These are the environment settings for the where.. window
#
# These are the foreground and background color settings for
# systems on production subnets
FONT=fixed
PROD_FG=yellow3
PROD_BG=black
# systems on production subnets
NON_PROD_FG=lightblue
NON_PROD_BG=black
# These are the foreground and background color settings for
# systems on all other subnets
OTHER_FG=DarkSeaGreen2
OTHER_BG=black
#
# This is the default connection type to use.  Options are rlogin, telnet,
# ssh and any.  Any will try ssh first, then rlogin, then telnet as a last
# resort.
CONNECTION_TYPE=any
# These are the foreground, background and other settings for
# the where window itself
RLOGIN_TITLE="Where..."
RLOGIN_FG=red
RLOGIN_BG=white
WHERE_WIN_GEOM="20x1+1200+0"
XTERM=`which xterm`
EOF

  . $CONFIG_FILE
  
  # This may fail if you don't have xmessage on your system.  Not too
  # big a deal.
  xmessage -fn 12x24 "Note:  If you don't like the colors of the windows,
 modify this file: $CONFIG_FILE." &
fi

changes=0
for conf_val in NON_PROD_FG.lightblue NON_PROD_BG.black CONNECTION_TYPE.any WHERE_WIN_GEOM."20x1+1200+0" XTERM.`which xterm`
do
  var=`echo $conf_val | awk -F. '{print $1}'`
  val=`echo $conf_val | awk -F. '{print $2}'`
  is_there=`grep $var $CONFIG_FILE | grep -v "^#"`
  if [ "$is_there" = "" ]
  then
    echo "${var}=${val}" >> $CONFIG_FILE
    changes=1
  fi
done

if [ -f $CONFIG_FILE -a $changes -eq 1 ]
then
  . $CONFIG_FILE
fi

nohup $XTERM -cr $RLOGIN_FG -fg $RLOGIN_FG -bg $RLOGIN_BG -fn 12x24 -rw -geom $WHERE_WIN_GEOM -T "$RLOGIN_TITLE" -ls -e ~/scripts/where.sh >/dev/null &
