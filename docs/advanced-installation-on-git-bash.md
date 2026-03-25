#### Install *client* prerequisites on [Git for Windows](https://gitforwindows.org/) (Git-Bash/MinGW/MSYS2)

Unfortunately `Git-Bash` doesn't have a default package manager, this chapter describes the manual installation for the dependencies.

`Git-Bash` leverages MSYS2 and ships with a subset of its files. To go deeper on MSYS2 architecture see [Environment](https://www.msys2.org/docs/environments/)

Good news is that there are pre-compiled packages available, you just have download, extract the archives and add them to your existing `Git-Bash` installation.

:warning: The next steps are platform specific. I assume you are on Windows x86_64 and installed [Git for Windows](https://gitforwindows.org/) 64 bit version

Tested with [Git for Windows](https://gitforwindows.org/) versions:
- 2.43.0
- 2.41.0

To extract the archives you need the `zstd` tool, this needs to be installed first.

Make sure your `Git-Bash` installation directory is correct.

```bash
mkdir tmp
cd tmp
curl -L https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win64.zip -o zstd-v1.5.5-win64.zip
unzip zstd-v1.5.5-win64.zip
gsudo cp zstd-v1.5.5-win64/zstd.exe 'C:\Program Files\Git\usr\bin'
```

The last `cp` command requires elevation. If don't have [gsudo](https://github.com/gerardog/gsudo) installed,
than copy `zstd-v1.5.5-win64/zstd.exe` to `C:\Program Files\Git\usr\bin` directory manually.


Once the `zstd` is working, download the following packages:

- [libxxhash-0.8.1-1-x86_64.pkg.tar.zst](http://repo.msys2.org/msys/x86_64/libxxhash-0.8.1-1-x86_64.pkg.tar.zst)
- [xxhash-0.8.1-1-x86_64.pkg.tar.zst](http://repo.msys2.org/msys/x86_64/xxhash-0.8.1-1-x86_64.pkg.tar.zst)
- [libzstd-1.5.5-1-x86_64.pkg.tar.zst](http://repo.msys2.org/msys/x86_64/libzstd-1.5.5-1-x86_64.pkg.tar.zst)
- [liblz4-1.9.4-1-x86_64.pkg.tar.zst ](https://mirror.msys2.org/msys/x86_64/liblz4-1.9.4-1-x86_64.pkg.tar.zst)
- [libopenssl-3.2.0-1-x86_64.pkg.tar.zst](https://mirror.msys2.org/msys/x86_64/libopenssl-3.2.0-1-x86_64.pkg.tar.zst)
- [rsync-3.2.7-2-x86_64.pkg.tar.zst](http://repo.msys2.org/msys/x86_64/rsync-3.2.7-2-x86_64.pkg.tar.zst)
- [util-linux-2.35.2-1-x86_64.pkg.tar.zst](http://repo.msys2.org/msys/x86_64/util-linux-2.35.2-1-x86_64.pkg.tar.zst)

You can use `get-git-bash-packages.sh` script to automate this step. Run it from the `tmp` directory.
```bash
cd tmp
. get-git-bash-packages.sh
gsudo cp -r usr/ 'C:\Program Files\Git'
```

The last `cp` command requires elevation. If don't have [gsudo](https://github.com/gerardog/gsudo) installed,
than copy `usr/` to `C:\Program Files\Git` directory manually.

:bulb: If don't want to pollute your vanilla `Git-Bash` installation, move these packages to any directory and add it to the `PATH` variable.
