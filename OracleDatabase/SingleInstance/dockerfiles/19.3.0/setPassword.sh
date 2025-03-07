#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2022 Oracle and/or its affiliates. All rights reserved.
# 
# Since: November, 2016
# Author: gerald.venzl@oracle.com
# Description: Sets the password for sys, system and pdb_admin
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

if [ -e "${ORACLE_BASE}/oradata/${ORACLE_SID}/.prebuiltdb" ] && [ -n "${ORACLE_PWD}" ] && [ "${ORACLE_PWD}" != "$1" ]; then
      echo "WARNING: The database password can not be changed for this container having a prebuilt database. The original password exists in the container environment. Your new password has been ignored!"
      exit 1
fi

ORACLE_PWD=$1
ORACLE_SID="$(grep "$ORACLE_HOME" /etc/oratab | cut -d: -f1)"
ORACLE_PDB="$(ls -dl "$ORACLE_BASE"/oradata/"$ORACLE_SID"/*/ | grep -v -e pdbseed -e "$ARCHIVELOG_DIR_NAME" | awk '{print $9}' | cut -d/ -f6)"
ORAENV_ASK=NO

ORACLE_USER_NAME=$2
ORACLE_USER_PWD=$3
source oraenv

sqlplus / as sysdba << EOF
      alter profile default limit password_life_time unlimited; 
      alter system set processes=10000 scope=spfile;
      ALTER USER SYS IDENTIFIED BY "$ORACLE_PWD";
      ALTER USER SYSTEM IDENTIFIED BY "$ORACLE_PWD";
      ALTER SESSION SET CONTAINER=$ORACLE_PDB;
      ALTER USER PDBADMIN IDENTIFIED BY "$ORACLE_PWD";
      create USER  $ORACLE_USER_NAME IDENTIFIED by "$ORACLE_USER_PWD";
      grant connect, resource to $ORACLE_USER_NAME; 
      exit;
EOF


# sqlplus / as sysdba << EOF
#       alter profile default limit password_life_time unlimited; 
#       alter system set processes=10000 scope=spfile;
#       create USER  $ORACLE_USER_NAME IDENTIFIED by "$ORACLE_USER_PWD";
#       grant connect, resource to $ORACLE_USER_NAME; 
#       exit;
# EOF


# sqlplus / as sysdba << EOF
#       alter profile default limit password_life_time unlimited; 
#       alter system set processes=10000 scope=spfile;
#       ALTER USER SYS IDENTIFIED BY "$ORACLE_PWD";
#       ALTER USER SYSTEM IDENTIFIED BY "$ORACLE_PWD";
#       ALTER SESSION SET CONTAINER=$ORACLE_PDB;
#       ALTER USER PDBADMIN IDENTIFIED BY "$ORACLE_PWD";
#       create USER  c##$ORACLE_USER_NAME IDENTIFIED by "$ORACLE_USER_PWD";
#       grant connect, resource to c##$ORACLE_USER_NAME; 
#       exit;
# EOF
