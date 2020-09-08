# SchildiChat-Desktop

Wrapper project for element-desktop, element-web, matrix-react-sdk and matrix-js-sdk, in order to build SchildiChat-Desktop.


# Debian compilation dependencies

```
# apt install vim curl git make gcc g++ libsqlcipher-dev pkg-config libsecret-1-dev bsdtar
# curl -sL https://deb.nodesource.com/setup_14.x | bash -
# apt update
# apt install nodejs

# curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
# echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# apt update
# apt install yarn

$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
$ echo 'export PATH="$PATH:$HOME/.cargo/bin"' >> .bashrc
$ source .bashrc
```

# Initial setup

```
git clone --recurse-submodules https://github.com/SpiritCroc/schildichat-desktop.git
cd schildichat-desktop
./setup.sh
```

# Build

`make`

# Install

Installable packages should appear in element-desktop/dist/.
