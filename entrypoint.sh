#!/bin/bash
set -e

USE_FTP=
FTP_USR=anonymous
FTP_PWD=
FTP_HOST=127.0.0.1
FTP_PORT=21
FTP_PATH=

if [ "$RUN_MODE" = "WORKER" ]
then
    echo "Will START AS SERVER MODE!!!"
    DISKOVER_CMD='python diskover_worker_bot.py'    
else if [ "$RUN_MODE" = "TCP_SERVER" ]
    echo "Will START AS WORKER MODE !!!"
    DISKOVER_CMD="python diskover.py --listen --debug"
else     
fi


echo "Evaluated DISKOVER_CMD=$DISKOVER_CMD"

while [ "$1" != "" ]; do
        case $1 in
                --ftp-host )            FTP_HOST=$2; shift 2;;
                --ftp-port )            FTP_PORT=$2; shift 2;;
                --ftp-path )            FTP_PATH=$2; shift 2;;
                --ftp-username )        FTP_USR=$2; shift 2;;
                --ftp-password )        FTP_PWD=$2; shift 2;;
                --ftp )                 USE_FTP=1; shift;;
                --)                     shift; break;;
                * )                     DISKOVER_CMD="$DISKOVER_CMD $1"; shift;;
# =======
#                 --ftp-host )                    FTP_HOST=$2; shift 2;;
#                 --ftp-port )                    FTP_PORT=$2; shift 2;;
#                 --ftp-path )                    FTP_PATH=$2; shift 2;;
#                 --ftp-username )                FTP_USR=$2; shift 2;;
#                 --ftp-password )                FTP_PWD=$2; shift 2;;
#                 --diskover-server )             DISKOVER_CMD="python diskover.py"; shift;;
#                 --diskover-socket-server )      DISKOVER_CMD="python diskover.py --listen --debug"; shift;;
#                 --diskover-worker )             DISKOVER_CMD="python diskover_worker_bot.py"; shift;;
#                 --ftp )                         USE_FTP=1; shift;;
#                 --)                             shift; break;;
#                 * )                             DISKOVER_CMD="$DISKOVER_CMD $1"; shift;;
# >>>>>>> CPDBDS-184
        esac 
done

if ! [ -z "$USE_FTP" ]; then
    echo "Will mount ftp://$FTP_HOST:$FTP_PORT/$FTP_PATH on $DISKOVER_ROOTDIR"
    curlftpfs -r -o custom_list="LIST",ftp_port=- "ftp://$FTP_USR:$FTP_PWD@$FTP_HOST:$FTP_PORT/$FTP_PATH" "$DISKOVER_ROOTDIR"
    echo "Will execute: $DISKOVER_CMD"
    eval '$DISKOVER_CMD'
    fusermount -u "$DISKOVER_ROOTDIR"
else
    echo "Will execute: $DISKOVER_CMD"
    eval '$DISKOVER_CMD'
fi
