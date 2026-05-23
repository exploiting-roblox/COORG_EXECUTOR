#!/bin/bash
echo "Escaneando red 192.168.1.0/24..."

for i in {1..254}; do
    ping -c 1 192.168.1.$i > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "192.168.1.$i está activo"
    fi
done

echo "Escaneo completado"
