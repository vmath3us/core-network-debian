FROM debian:11
### uuidgen | sha256sum
ENV PASS='ca5a5abb98e83a627fa39aa910925af6bbfdf54ecec0691ec751e12b3e43693f'

SHELL [ "/bin/bash", "-c" ]

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh
echo 'export LANG=en_US.UTF-8' >> /etc/profile.d/locale.sh
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
apt-get update
apt-get install -y locales tzdata
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure -fnoninteractive tzdata
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
EOF

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'

RUN <<EOF
cd /opt
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
            autoconf \
            automake \
            autotools-dev \
            bridge-utils \
            build-essential \
            ebtables \
            git \
            htop \
            iproute2 \
            libev-dev \
            libevdev-dev \
            libtool \
            pkg-config \
            python-dev-is-python2 \
            tcl \
            tk \
            libtk-img 
git clone https://github.com/eribertomota/core-network-debian 
cd ./core-network-debian
./bootstrap.sh
./configure
make
make install
EOF

#### xpra -- start
RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
            dbus-x11 \
            uuid-runtime \
            wget \
            gnupg \
            sudo \
            vim \
            nano \
            xvfb \
            x11-xserver-utils \
            python3-pip \
            python3-uinput \
            terminator \
            tmux \
            curl \
            gzip \
            git \
            bash-completion \
            fonts-noto-color-emoji \
            bzip2

pip3 install pyinotify
EOF

RUN <<EOF
wget -q -O- https://xpra.org/gpg.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/xpra.gpg

echo 'deb [signed-by=/etc/apt/trusted.gpg.d/xpra.gpg arch=amd64] https://xpra.org bullseye main' > /etc/apt/sources.list.d/xpra.list

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y xpra
EOF
#### xpra -- end

RUN <<EOF
cd /opt
curl -L 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=pt-BR' -o firefox-latest.tar.bz2
tar -xf ./firefox-latest.tar.bz2
rm ./firefox-latest.tar.bz2
ln -s /opt/firefox/firefox /usr/local/bin/firefox
EOF

RUN <<EOF

useradd -mG sudo -s /bin/bash --uid 1000 debian
printf "$PASS\n$PASS" | passwd debian

EOF

USER debian

RUN <<EOF

cd /home/debian
mkdir -pv ./.local/bin
mkdir -pv ./.local/share/fonts
mkdir -pv ./.config/tmux
mkdir -pv ./.config/terminator


curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o /home/debian/.local/share/fonts/meslo_nerd_bold.ttf
fc-cache -vf

cat > ./.config/tmux/tmux.conf <<-IS_TMUX_CONF
unbind C-b
set -g prefix C-s
default_color=colour202

set-window-option -g mode-keys vi
set-window-option -g xterm-keys on
set -s escape-time 0

set-option -g history-limit 3000

set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

setw -g pane-base-index 1
set -g base-index 1
set -g pane-border-status top
set -g status-left-length 50
set -g status-justify absolute-centre

set -g status-style "fg=black,bg=\${default_color}"
set -g window-status-format "#[fg=black] #I:#W "
set -g window-status-current-format "#[bg=black,fg=\${default_color}] #I:#W "
set -g pane-border-status top
set -g pane-border-style "bg=black fg=\${default_color}"
set -g pane-active-border-style "bg=\${default_color} fg=black"
set -g status-left "#[bg=black,fg=\${default_color}] #{session_name} "
set -g status-right "#[bg=black,fg=\${default_color}] %Y/%m/%d %H:%M:%S "

bind = split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
bind s choose-buffer
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind u resize-pane -L 3
bind i resize-pane -D 3
bind o resize-pane -U 3
bind p resize-pane -R 3
IS_TMUX_CONF

cat > ./.config/terminator/config <<-IS_TERMINATOR_CONF
[global_config]
[keybindings]
  full_screen = ""
[profiles]
  [[default]]
    font = MesloLGS NF Bold 16
    use_custom_command = True
    custom_command = tmux -2 -u new-session -A -s default
    use_system_font = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
IS_TERMINATOR_CONF
EOF

USER root
RUN <<EOF
cat > /usr/local/bin/xpra-entrypoint.sh <<-IS_A_ENTRYPOINT
#!/bin/bash
export PASS="\${PASS}"
printf "\$PASS\n\$PASS" | passwd debian
printf "\n\nsenha: \$PASS\n\n"
rm -rvf /tmp/.X* || true
mkdir -pv -m 0700 /run/user/1000
mkdir -pv -m 0700 /run/xpra/1000
mkdir -pv -m 0700 /run/xpra/debian
chown -Rv debian:debian /run/user/1000
chown -Rv debian:debian /run/xpra/debian
chown -Rv debian:debian /run/xpra/1000

dbus-send --system /org/freedesktop/DBus org.freedesktop.DBus 2>/dev/null|| dbus-daemon --system --fork 2>/dev/null
core-daemon -d
su -c "
    XDG_RUNTIME_DIR='/run/user/1000' \\
    DBUS_SYSTEM_BUS_ADDRESS='/run/dbus/system_bus_socket' \\
    DISPLAY=':80' \\
    XCURSOR_SIZE='50' \\
    LANG='en_US.UTF-8' \\
    LANGUAGE='en_US:en' \\
    LC_ALL='en_US.UTF-8' \\
        xpra start \\
        ':80' \\
        '-d auth' \\
        '--bind-tcp=0.0.0.0:15000,auth=password,value=\$PASS' \\
        '--mdns=no' \\
        '--webcam=no' \\
        '--no-daemon' \\
        '--notifications=no' \\
        '--no-audio' \\
        '--start-on-connect=/usr/bin/terminator' \\
        '--start=xhost +'
" debian

sleep infinity
IS_A_ENTRYPOINT

chmod +x /usr/local/bin/xpra-entrypoint.sh
EOF

EXPOSE 15000

VOLUME /home/debian

ENTRYPOINT [ "/usr/local/bin/xpra-entrypoint.sh" ]
