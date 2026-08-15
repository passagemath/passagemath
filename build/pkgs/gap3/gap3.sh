#!/usr/bin/env bash

SAGE_LOCAL="$(cd "$(dirname "$0")" && cd .. && pwd -P)"

#############################################################################
##
##  gap.sh                      GAP                          Martin Schoenert
##
##  This is a shell script for UNIX-like  operating systems that starts  GAP.
##  This is the place where to make your customizations.
##  Copy/rename this file to a directory in your search path like '~/bin/gap'.
##  If you move the GAP distribution you need only change this file.
##

#############################################################################
##
##  GAP_DIR . . . . . . . . . . . . . . . . . . . . directory where GAP lives
##
##  Set 'GAP_DIR' to the name of the directory where you have installed  GAP,
##  i.e., the directory with the subdirectories  'lib',  'grp',  'doc',  etc.
##  The default is '/usr/local/lib/gap3-jm'.
##  You have to change this unless you have installed  GAP in this  location.
##
GAP_DIR="$SAGE_LOCAL/gap3/latest/gap3"

#############################################################################
##
##  GAP_MEM . . . . . . . . . . . . . . . . . . . amount of initial workspace
##
##  Set 'GAP_MEM' to the amount of memory GAP shall use as initial workspace.
##  The default is 512MBytes.
##  If you are not going to run  GAP  in parallel with other programs you may
##  want to set this value close to the  amount of memory your  computer has.
##

ARCH=`getconf LONG_BIT`
if [[ "$ARCH" == '32' ]]; then
   GAP_MEM=512m
elif [[ "$ARCH" == '64' ]]; then
   GAP_MEM=1024m
fi

#############################################################################
##
##  GAP_PRG . . . . . . . . . . . . . . . . .  name of the executable program
##
##  Set 'GAP_PRG' to the name of the executable  program of the  GAP  kernel.
##  It should be one of
##     gap.linux for linux 64 bit
##     gap.linux32 for linux 32 bit
##     gap.powerpcmac for Mac OSX on powerPC
##     gap.mac for Mac OSX on X86 32 bit
##     gap.mac64 for Mac OSX on X86 64 bit
##  Thanks to Andrew Mathas and Dima Pasechnik for gap.powerpcmac and gap.mac
##
GAP_PRG=gap3

#############################################################################
##
##  GAP . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . run GAP
##
##  You  probably should  not change  this line,  which  finally starts  GAP.
##
exec $GAP_DIR/bin/$GAP_PRG -m $GAP_MEM -l $GAP_DIR/lib/ -h $GAP_DIR/doc/ $*
