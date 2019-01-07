#!/usr/bin/env bash
# Ubuntu installer script for Lutris (https://lutris.net/).


error_msg() {
  echo -e "\e[31mERROR\e[0m: $1"
}

info_msg() {
  echo -e "\e[36mINFO\e[0m: $1"
}

add_key() {
  wget --no-clobber --output-document="$HOME/$1.key" "$2" && \
  chown $SUDO_USER:$SUDO_USER "$HOME/$1.key" && \
  apt-key add "$HOME/$1.key"
}

# Validate script is being run as root.
if [[ $EUID -ne 0 ]]; then
  error_msg "this script must be run as root"
  exit 1
fi

# Validate Ubuntu version.
readonly ver="$(lsb_release -sr)"
readonly codename="$(lsb_release -sc)"
if [[ "$ver" != "18.10" && \
      "$ver" != "18.04" && \
      "$ver" != "16.04" ]]
then
  error_msg "unsupported version: '$ver'"
  exit 1
fi

# Install wine-staging repository.
apt-cache show wine-staging &> /dev/null
if [[ ! "!?" ]]; then
  info_msg "adding repository for wine-staging"
  dpkg --add-architecture i386 && \
  add_key "winehq" "https://dl.winehq.org/wine-builds/winehq.key" && \
  apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $codename main" && \
  apt-get update && \
  info_msg "success!"
fi

# Install wine-staging package.
if ! dpkg-query -l wine-staging | grep -q -e "^ii"; then
  info_msg "installing missing dependency: 'wine-staging'"
  apt-get install --install-recommends winehq-staging && \
  info_msg "success!"
fi

# Install lutris repository.
apt-cache show lutris &> /dev/null
if [[ ! "!?" ]]; then
  info_msg "adding repository for lutris"
  add_key "lutris" "https://download.opensuse.org/repositories/home:/strycore/xUbuntu_$ver/Release.key" && \
  echo "deb http://download.opensuse.org/repositories/home:/strycore/xUbuntu_$ver/ ./" | \
  tee /etc/apt/sources.list.d/lutris.list && \
  apt-get update && \
  info_msg "success!"
fi

# Install lutris package.
if ! dpkg-query -l lutris | grep -q -e "^ii"; then
  info_msg "installing lutris..."
  apt-get install --install-recommends lutris && \
  info_msg "success!"
else
  info_msg "lutris is already installed"
fi
