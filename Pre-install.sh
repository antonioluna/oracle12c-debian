#!/bin/bash

######################################################
#                                                    #
#    Author: Antonio Luna <equinoxe4@gmail.com>      #
#                                                    #
######################################################


### Dependencies:

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install sudo rlwrap original-awk binutils libpcap-dev gcc g++ libc6 libc6-dev ksh libaio1 libstdc++-4.8-dev libXi6 libXtst6 make sysstat build-essential gcc-multilib lib32z1 lib32ncurses5 libstdc++5 rpm xauth


### Create oinstall, oracle and dba group/user

sudo addgroup --system oinstall
sudo addgroup --system dba
sudo adduser --system --ingroup oinstall --shell /bin/bash oracle
sudo adduser oracle dba


### Symbolic links:

sudo mkdir -p /usr/lib64

sudo ln -s /etc /etc/rc.d
sudo ln -s /usr/bin/awk /bin/awk
sudo ln -s /usr/bin/basename /bin/basename
sudo ln -s /usr/bin/rpm /bin/rpm
sudo ln -s /lib/x86_64-linux-gnu/libgcc_s.so.1 /usr/lib64/
sudo ln -s /usr/lib/x86_64-linux-gnu/libc_nonshared.a /usr/lib64/
sudo ln -s /usr/lib/x86_64-linux-gnu/libpthread_nonshared.a /usr/lib64/
sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib64/


### Directory of installation:

directorys() {
  echo -e "\nPath of installation\nIf you will not use in a production server it is recommended directory: $1. Use it? y/n\n"
  read localconf
  
  case "${localconf,,}" in
      "y")
          localpath="$1"
          ;;
    
      "n")
          echo -e "\nWrite the path for Oracle Database installation:\n"
          read localpath
          ;;
    
      *)
          echo -e "\nWrite the path of installation:\n"
          read localpath
          ;;
  esac


### while bucle to confirm the path:

confirmation=" "
  while [[ "${confirmation,,}" != "y" ]]; do

      echo -e "\nPath: $localpath\n\n¿Sure? y/n:\n"
      read confirmation

    case "${confirmation,,}" in
        
        "y")
            functionpath="$localpath"
            ;;

        "n")
            echo -e "\nWrite the path\n"
            read localpath
            ;;
        *)
            continue 
    esac 

done
}


### Path directorys vars:

directorys "/opt/oracle-database"
oraclepath="$functionpath"

directorys "/opt/oraInventory"
orainventorypath="$functionpath"

directorys "/opt/oradata"
oradatapath="$functionpath"



### Path creation:

sudo mkdir -p "$oraclepath"
sudo mkdir -p "$orainventorypath"
sudo mkdir -p "$oradatapath"




### Permissions change:

sudo chown -R $USER:$USER $oraclepath
sudo chown -R $USER:$USER $orainventorypath
sudo chown -R $USER:$USER $oradatapath


### Oracle's propietary installer init:

echo -e "\nMake sure you enter your own database paths:\n\nBase: $oraclepath\n\nInventory: $orainventorypath\n\nOradata: $oradatapath\n\nin the Oracle's Database installer\n"

echo -e "Initializing Oracle Database 12c installer"
sleep 5

bash ./runInstaller -IgnoreSysPreReqs


### envs:

ORACLE_BASE="$oraclepath"
ORACLE_HOME="$oraclepath/product/12.1.0/dbhome_1"
ORACLE_OWNER="$USER"

echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64/bin" >> ~/.bashrc
echo "export ORACLE_BASE=$ORACLE_BASE" >> ~/.bashrc
echo "export ORACLE_HOME=$ORACLE_HOME" >> ~/.bashrc
echo "export ORACLE_OWNER=$ORACLE_OWNER" >> ~/.bashrc
echo "export ORACLE_SID=orcl" >> ~/.bashrc
echo "export ORACLE_HOME_LISTNER=$ORACLE_HOME/network/admin" >> ~/.bashrc
echo "export TNS_ADMIN=$ORACLE_HOME/network/admin" >> ~/.bashrc
echo "export LD_LIBRARY_PATH="$ORACLE_HOME/lib"" >> ~/.bashrc
echo "export NLS_LANG=SPANISH_SPAIN.AL32UTF8"
echo "alias sqlplus='rlwrap sqlplus'" >> ~/.bashrc

source ~/.bashrc

### Launcher

sudo ln -s $ORACLE_HOME/bin/sqlplus /usr/local/bin/ 2> /dev/null

echo -e "\nPre-installation complete!\nRemember to change the permissions of /usr/local/bin/sqlplus to 0700\n"

