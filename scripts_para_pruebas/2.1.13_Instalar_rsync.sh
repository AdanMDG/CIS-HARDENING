#!/bin/bash
#CIS Hardening 
{
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' rsync | grep -q "not-installed"; then
    echo "- rsync no esta instalado. Se instalará para probar el hardening"
    apt install rsync -y
    echo -e "\n - 2.1.13 > \033[0;33m ** Se instalo rsync. ** \033[0m \n"
else
    echo "- rsync esta instalado. Es necesario hardenizar"
fi
}