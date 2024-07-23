#!/bin/bash

CONFIG_FILE="/etc/zabbix/zabbix_agent2.conf"
if [ ! -f ${CONFIG_FILE} ]; then
    echo "Error: archivo ${CONFIG_FILE} no encontrado" && exit 1
fi

if [ -f /etc/zabbix/encrypted.key ]; then
    echo "Warning: archivo encrypted.key encontrado, se reemplazara por el input del usuario"
    echo "======================"
fi

if [ -f ${CONFIG_FILE}.bkp ]; then
    echo "Error: El script parece ya haber corrido. Restaurar backup y volver a intentar" && exit 1
    echo "======================"
fi

cp ${CONFIG_FILE} ${CONFIG_FILE}.bkp
if [ -f ${CONFIG_FILE}.bkp ]; then
    echo "original file backuped OK"
    echo "======================"
fi
echo "ingresar URL de zabbix agents"
read URL_AGENTE
echo "ingresar nombre de host"
read HOST_AGENTE
echo "ingresar contenido de encrypted.key"
read KEY_CONTENT

sed -i "s|Server=127.0.0.1|Server=${URL_AGENTE}|g" ${CONFIG_FILE}
sed -i "s|ServerActive=127.0.0.1|ServerActive=${URL_AGENTE}|g" ${CONFIG_FILE}
sed -i "s|Hostname=Zabbix server|Hostname=${HOST_AGENTE}|g" ${CONFIG_FILE}
sed -i "s|# TLSConnect=unencrypted|TLSConnect=psk|g" ${CONFIG_FILE}
sed -i "s|# TLSAccept=unencrypted|TLSAccept=psk|g" ${CONFIG_FILE}
sed -i "s|# TLSPSKIdentity=|TLSPSKIdentity=${HOST_AGENTE}|g" ${CONFIG_FILE}
sed -i "s|# TLSPSKFile=|TLSPSKFile=/etc/zabbix/encrypted.key|g" ${CONFIG_FILE}

echo ${KEY_CONTENT} > /etc/zabbix/encrypted.key

systemctl restart zabbix-agent2 || echo "falla en el comando systemctl restart zabbix-agent2. Verificar instalacion de agente"

echo "Ah, recuerda, el nombre del host en zabbix debe ser" 
echo "${HOST_AGENTE}"
echo "saludos"
