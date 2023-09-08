# docker-replibyte-arm64

Running Qovery Replibyte from arm64 nodes :)

## Quickstart

```bash
docker run --privileged --rm tonistiigi/binfmt --install all

ll /proc/sys/fs/binfmt_misc/qemu*
-rw-r--r-- 1 root root 0 sept.  8 18:25 /proc/sys/fs/binfmt_misc/qemu-aarch64
-rw-r--r-- 1 root root 0 sept.  8 18:25 /proc/sys/fs/binfmt_misc/qemu-arm
-rw-r--r-- 1 root root 0 sept.  8 18:25 /proc/sys/fs/binfmt_misc/qemu-mips64
-rw-r--r-- 1 root root 0 sept.  8 18:25 /proc/sys/fs/binfmt_misc/qemu-mips64el
-rw-r--r-- 1 root root 0 sept.  8 18:25 /proc/sys/fs/binfmt_misc/qemu-ppc64le
-rw-r--r-- 1 root root 0 sept.  8 18:25 /proc/sys/fs/binfmt_misc/qemu-riscv64
-rw-r--r-- 1 root root 0 sept.  8 18:25 /proc/sys/fs/binfmt_misc/qemu-s390x

docker buildx ls
NAME/NODE DRIVER/ENDPOINT STATUS  BUILDKIT             PLATFORMS
default * docker
  default default         running v0.11.6+616c3f613b54 linux/amd64, linux/amd64/v2, linux/amd64/v3, linux/386, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/mips64le, linux/mips64, linux/arm/v7, linux/arm/v6
```

```bash
docker buildx build --file Dockerfile --platform linux/arm64 --pull --push --tag ghcr.io/eagleusb/docker-replibyte-arm64:latest .
```
