#!/bin/bash
# Script para restaurar reglas de firewall
# Usar: sudo ./restore-iptables.sh

echo "Restaurando reglas de firewall..."
sudo iptables-restore < iptables-current.rules && echo "✓ IPv4 restauradas"
sudo ip6tables-restore < ip6tables-current.rules && echo "✓ IPv6 restauradas"
echo "✓ Firewall restaurado a estado actual"
