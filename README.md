# SchildiChat-Desktop

SchildiChat-Desktop is a fork of [Element-Web](https://github.com/vector-im/element-web)/[-Desktop](https://github.com/vector-im/element-desktop).

The most important changes of SchildiChat-Desktop compared to Element are:

- A unifed chat list for both direct and group chats
- Message bubbles
- Bigger items in the room list

While SchildiChat-Desktop should be already usable as is, it's still better seen as a
proof-of-concept rather than a finished product, as there are still a few UX bugs
remaining, and no ways to configure Schildi's features.
Furthermore, I don't know how much more work I'm going to put into this, but
if anybody wants to help improving it, contributions are welcome!

Downloads for Desktop: https://github.com/SchildiChat/schildichat-desktop/releases <br/>
Hosted web variant: https://schildiweb.spiritcroc.de/

Feel free to [join the discussion on matrix](https://matrix.to/#/#schildichat-web:matrix.org).

<img src="https://raw.githubusercontent.com/SchildiChat/schildichat-desktop/sc/screenshots/1.png"/>


# Building SchildiChat-Desktop

This particular repo is a wrapper project for element-desktop, element-web, matrix-react-sdk and matrix-js-sdk, in order to build SchildiChat-Desktop.


## Debian compilation dependencies

Since Debian is usually slow to update packages on its stable releases, some dependencies
might not be recent enough to building Schildi.
Here are the dependencies which I had to install for compilation on Debian 10:

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

## Initial setup

```
git clone --recurse-submodules https://github.com/SchildiChat/schildichat-desktop.git
cd schildichat-desktop
./setup.sh
```

## Build

`make [{web|debian|pacman|windows}-release]`

## Install

Installable packages should appear in release/.
