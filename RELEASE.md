# Releasing SchildiChat deskop

## Build Linux releases

On a Linux machine with podman:

```
make container-release-linux
```

## Build Windows releases

On a Windows machine in git bash (**not** WSL), run:

```
make windows-setup-release
```

## Upload the release

Copy the Windows-generated `.exe` from the `release` directory into the release directory on your Linux machine.  
Then (after ensuring you have a GitHub API token setup for the script to pick up):

```
./deploy/create-github-release.sh
```
