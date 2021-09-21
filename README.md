# SchildiChat Web/Desktop

SchildiChat Web/Desktop is a fork of Element [Web](https://github.com/vector-im/element-web)/[Desktop](https://github.com/vector-im/element-desktop).

The most important changes of SchildiChat Web/Desktop compared to Element Web/Desktop are:
- A unified chat list for both direct and group chats
- Message bubbles
- Bigger items in the room list
- &hellip; and more!

Desktop downloads with installation instructions are listed on our website: [https://schildi.chat/desktop](https://schildi.chat/desktop)  
Hosted web variant: [https://app.schildi.chat/](https://app.schildi.chat/)

Feel free to [join the discussion on matrix](https://matrix.to/#/#schildichat-web:matrix.org).

<img src="https://raw.githubusercontent.com/SchildiChat/schildichat-desktop/sc/screenshots/1.png"/>


## Building SchildiChat Web/Desktop

This particular repo is a wrapper project for element-desktop, element-web, matrix-react-sdk and matrix-js-sdk. It's the recommended starting point to build SchildiChat for Web **and** Desktop.

<pre><code><b>schildichat-desktop</b> <i>&lt;-- this repo</i> (recommended starting point to build SchildiChat for Web <b>and</b> Desktop)
|-- <a href="https://github.com/SchildiChat/element-desktop">element-desktop</a> (electron wrapper)
|-- <a href="https://github.com/SchildiChat/element-web">element-web</a> ("skin" for matrix-react-sdk)
|-- <a href="https://github.com/SchildiChat/matrix-react-sdk">matrix-react-sdk</a> (most of the development happens here)
`-- <a href="https://github.com/SchildiChat/matrix-js-sdk">matrix-js-sdk</a> (Matrix client js sdk)
</code></pre>

### Install dependencies

#### Debian build dependencies

Since Debian is usually slow to update packages on its stable releases,
some dependencies might not be recent enough to build SchildiChat.  
The following are the dependencies required to build SchildiChat Web/Desktop on Debian 10:

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

#### macOS build dependencies

##### Install brew package manager
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

##### Install packages

```
brew install tcl rust node gpg vim curl git yarn git make gcc
```

#### Signed macOS builds

To sign a macOS build set the environment or make variable `CSC_IDENTITY_AUTO_DISCOVERY` to true
or set `CSC_NAME` to your certificate name or id.

To notarize a build with Apple set `NOTARIZE_APPLE_ID` to your AppleID and set the keychain item
`NOTARIZE_CREDS` to an App specific AppleID password.  


### Initial setup

The `master` branch does contain the latest release.
The development happens in the `sc` branch, which might be broken any time!

```
git clone -b master --recurse-submodules https://github.com/SchildiChat/schildichat-desktop.git
cd schildichat-desktop
make setup # optional step if using the other make targets
```

### Create release builds

Those are the builds distributed via GitHub releases.

```
# The single make targets are explained below
make [{web|debian|windows-setup|windows-portable|macos}-release]
```

After that these packages which belong to to their respective make target should appear in release/\<version\>/:
- `web`: _schildichat-web-\<version\>.tar.gz_: archive that can be unpacked and served by a **web** server (copy `config.sample.json` to `config.json` and adjust the [configuration](https://github.com/SchildiChat/element-web/blob/sc/docs/config.md) to your likings)
- `debian`: file ready for installation on a **Debian Linux** (based) system via `dpkg -i schildichat-desktop_<version>_amd64.deb`
- `windows-setup`: _SchildiChat_Setup_v\<version\>.exe_: file ready for **installation** on a **Windows** system
- `windows-portable`: _SchildiChat_win-portable_v\<version\>.zip_: **portable** version for a **Windows** system – take SchildiChat together with your login data around with you (the archive contains a readme with **instructions** and **notes**)
- `macos`: Build a *.dmg for macOS
- `macos-mas`: Build a *.pkg for release in the Mac App Store

#### Additional make targets not used for GitHub releases
- `pacman`: file ready for installation on an **Arch Linux** (based) system via `pacman -U schildichat-desktop-<version>.pacman`
- `windows-unpacked`: _SchildiChat_win-unpacked_v\<version\>.zip_: **unpacked** archive for a **Windows** system

### Build SchildiChat Web and deploy it directly to your web server

Put the `config.json` with the [configuration](https://github.com/SchildiChat/element-web/blob/sc/docs/config.md) you want for your hosted instance in a subfolder of the `configs` folder.  
Then create a file named `release.mk` and fill it similar to that:
```
.PHONY: your-deploy-web

YOUR_CFGDIR := configs/your_subfolder
your-deploy-%: CFGDIR := $(YOUR_CFGDIR)

your-deploy-web: web
	rsync --info=progress2 -rup --del element-web/webapp/ you@yourwebserver:/the/folder/served/for/schildi/
```
