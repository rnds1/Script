#!/bin/bash

# Detectar o gerenciador de pacotes
detect_package_manager() {
    if command -v apt &> /dev/null; then
        PACKAGE_MANAGER="apt"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
    elif command -v zypper &> /dev/null; then
        PACKAGE_MANAGER="zypper"
    else
        echo "Gerenciador de pacotes não encontrado. Instale um gerenciador de pacotes suportado."
        exit 1
    fi
}

# Função para detectar monitores e GPUs
detect_hardware() {
    echo "Detectando monitores e GPUs..."

    # Detectar GPUs (usando lspci para encontrar todas as GPUs)
    NVIDIA_GPU=$(lspci | grep -i nvidia)
    AMD_GPU=$(lspci | grep -i amd)

    # Detectar monitores conectados
    MONITORS=$(swaymsg -t get_outputs | jq -r '.[].name')

    # Exibir as GPUs encontradas
    if [ -n "$NVIDIA_GPU" ]; then
        echo "GPU NVIDIA detectada: $NVIDIA_GPU"
        GPU_TYPE="NVIDIA"
    elif [ -n "$AMD_GPU" ]; then
        echo "GPU AMD detectada: $AMD_GPU"
        GPU_TYPE="AMD"
    else
        echo "Nenhuma GPU NVIDIA ou AMD detectada."
        GPU_TYPE="Integrated"
    fi

    # Exibir os monitores encontrados
    if [ -z "$MONITORS" ]; then
        echo "Nenhum monitor detectado!"
        exit 1
    else
        echo "Monitores detectados: $MONITORS"
    fi
}

# Função para gerar a configuração do Hyperland
generate_configuration() {
    echo "Gerando configuração do Hyperland..."

    # Criar diretório de configuração se não existir
    mkdir -p ~/.config/sway

    # Cabeçalho de configuração
    echo "set $bg-color #2E3440
set $fg-color #D8DEE9

# Configuração de GPU: $GPU_TYPE
" > ~/.config/sway/config

    # Loop para configurar os monitores automaticamente
    for MONITOR in $MONITORS; do
        # Obter resolução e posição de cada monitor
        RESOLUTION=$(swaymsg -t get_outputs | jq -r ".[] | select(.name == \"$MONITOR\") | .current_mode")
        POSITION=$(echo $MONITOR | grep -q 'eDP' && echo "0,0" || echo "1920,0")  # Posição simples, ajustada para monitores secundários

        echo "output $MONITOR resolution $RESOLUTION position $POSITION scale 1" >> ~/.config/sway/config
    done

    # Configuração da barra de status (waybar)
    echo "
# Configuração básica do waybar
modules-left = [ 'sway/workspaces', 'sway/mode', 'sway/window' ]
modules-center = [ 'clock' ]
modules-right = [ 'network' ]

# Tema do waybar
style = 'flat'
" > ~/.config/waybar/config

    # Configuração do background
    echo "
# Background
exec --no-startup-id swaybg -i /usr/share/backgrounds/gnome/adwaita-day.jpg
" >> ~/.config/sway/config

    # Configuração de bloqueio de tela
    echo "
# Bloqueio de tela
bindsym $mod+Shift+L exec swaylock -f -c 000000
" >> ~/.config/sway/config

    # Criação da entrada para sessão do Hyperland
    echo "[Desktop Entry]
Name=Hyperland
Comment=Start Hyperland
Exec=hyperland
Type=Application
" | sudo tee /usr/share/xsessions/hyperland.desktop > /dev/null

    echo "Configuração gerada com sucesso!"
}

# Função principal
main() {
    detect_package_manager
    detect_hardware
    generate_configuration

    echo "Configuração do Hyperland concluída. Agora, você pode reiniciar o sistema ou usar a sessão Hyperland."
}

# Executar a função principal
main
