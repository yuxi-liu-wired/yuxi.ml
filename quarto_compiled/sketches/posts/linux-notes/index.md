---
title: "Notes on Using Linux"
author: "Yuxi Liu"
date: "2022-12-10"
date-modified: "2023-12-11"
categories: [programming]

format:
  html:
    toc: true
description: "My quick reference for using Linux for doing things."
# image: "figure/banner_1.png"

status: "wip"
confidence: "log"
importance: 2
---

This is my quick reference for using Linux for doing things. I claim no originality. Mostly they are copy pasted from the internet and tested by me. An increasing proportion of those are produced by AI.

## Linux koans {#sec-koans}

Everything is ~~a file~~ ~~a file or a directory~~ an inode. An inode (index node) is a representation of a sequence of data that the system can access. A file is just a list of inodes, and a directory is just a list of files.

Every command is an executable.

Every machine is a server. Some merely serve extremely slow machines (humans, aka "users").

The `\usr` is not the user. It is the **U**NIX **S**ystem **R**esources.

The `\usr` was the user, until Unix became so large that `\bin` overflowed and had to put the rest of them in `\usr\bin`. This was embarrassing for all involved, so they moved user files to `\home`, and pretend that `\usr` stands for UNIX System Resources. ([here](http://lists.busybox.net/pipermail/busybox/2010-December/074114.html)). A mistake that only took 40 years to fix.

In the beginning was the command line. The command line is just a face of the shell. What was the original face of the command line before the shell was born?

The shell reads in a stream of letters, because the user is just another file (a streaming file, named `stdin`). Like all streaming files, the user is eternal and inexhaustible. The shell stands, rapt in attention, afore the user file. 

So when does the user ever leave? The user never leaves. The shell simply kills itself when the user types `exit`. The shell would rather die than to face the prospect of reading the last word from the user.

So when does the shell ever break out of its rapt attention? Whenever it sees `\n`, it is shaken out of its trance and interprets what the user has just said, in the interval bracketed between two `\n`s.

The shell has one ear and two mouths. The ear is `stdin`, and the mouths are `stdout` and `stderr`. The shell has a tiny brain which is only capable of interpreting [the few syntactic elements of bash scripts](https://learnxinyminutes.com/docs/bash/). Everything else it wants to do, it dutifully sends a binary message into the oracular altar of the Linux kernel, from which an oceanic voice replies the answer of the kernel.

## How to `PATH` {#sec-path}

The `PATH` environment variable is a list of directories that the shell searches for commands. It is a colon-separated list of directories. For example, just about every Linux installation has a `PATH` variable that looks like:

```bash
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

To add things to `PATH`, use the `export` command, like `export PATH="$HOME/bin:$PATH"`.

```bash
env # same as printenv
export VAR_NAME="value"
unset VAR_NAME

export PATH=newpath:$PATH # There is no simple way to undo this one.
# but you can try export OLD_PATH=$PATH; ...; export PATH=$OLD_PATH
```

For Windows, use `Get-ChildItem Env:`.

## How to directories

Based on <https://askubuntu.com/a/135679>, <https://serverfault.com/a/24525>, `man hier`, [Filesystem Hierarchy Standard - Wikipedia](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard).

### Where to install read-only things

* `/bin` and `/sbin`: binaries and superuser-binaries.

* `/usr`: System-wide, read-only files installed by the OS. This directory can be remotely mounted to multiple hosts safely.
* `/usr/local`: System-wide, read-only files installed by `root`. _And that's why most directory names from `/usr` are duplicated here_.
* `/opt` - System-wide, read-only _and bundled-up_ software. That is, software that does not split their files over `bin`, `lib`, `share`, `include` like well-behaved software should.
* `/usr/bin` and `usr/sbin`: They no longer exist. Just use `/bin` and `/sbin`.

* `~/.local`: the per-user counterpart of `/usr/local`, that is: software installed by (and for) each user. Like `/usr`, it has its own `~/.local/share`, `~/.local/bin`, `~/.local/lib`.
* `~/.local/opt`: The per-user counterpart of `/opt`

Requiem for `/usr/bin` and `/usr/sbin`: Originally, `/bin` and `/lib` are only for binaries and libraries _required for booting_, while `/usr/bin` and `/usr/lib` are for all the other executables and libraries. This is no longer true, as some binaries required for booting has over the years leaked into those two folders (if there is a way to make a mess, people will make it), so since Ubuntu 20.04, they no longer exist, to remove this mess.

How to install for local user only:

```bash
./configure --prefix=$HOME/.local
make
make install
```

How to install for everyone: `sudo ./configure && make && make install`

### Where to install read-write things

Read-write things are typically configuration files, since they are read and written by both the user and binary executables.

* `/etc`: System-wide configuration. Typically used by the OS to decide what to do when starting up, shutting down, etc.
* `~/.config`: Per-user configuration files. Although because of legacy, you keep seeing nonsense like `.bashrc` in your home directory instead of `~/.config/.bashrc`. Here `rc` means "run configuration".

### Where to do read-write things

* `/home/username`, or just `~`: Each user typically is only able to modify their own folder here, like `~/myfile.txt`.
* `/tmp`: If you need to create something just for the moment, then make it here. It will be deleted when the system restarts.

### Other things (you should not modify them)

* `/run:` **run**time temporary data, representing the system's state since the last boot. It's used for storing process IDs, lock files, and other files that are would normally be stored in `/tmp`. It is basically `/tmp` for the machine.
* `/var`: Variable data. It is somewhat like `/run` in that both are meant to be read-written by programs, but unlike `/run`, data here persists over reboots. This is often used for logging information. For example, try `vim /var/log/user.log`

::: callout-warning
Modifying anything below this line may brick the system. Reading is fine though.
:::

* `/lib`: **lib**raries. You should not handle it directly. Some libraries are added at OS installation, and others at program installation. If you have a broken installation, you might be asked to manually copy some files looking like `libxxx.so` here. (`so` stands for "shared object".)
* `/boot`: Files required for **booting**. For example, the bootloader, the kernel, the initramfs (initial RAM file system).
* `/dev`: **Device** files. It typically looks like `/dev/sda1`, `/dev/sda2`, etc. Other than things like `sda1` (for harddrive) you might notice `tty1` and `pty1`' which stand for "teletype" and "pseudo teletype", respectively, but they are actually used as files to read whatever the user is typing from (the user is a file, see @sec-koans). There are some odd ones like:
  *  `/dev/null`, which is a "file" that you write to when you just want to throw something away (everything is a file, even a black hole...). 
  *  `/dev/urandom`, which is a random number generator. It is preferred over `/dev/random`. See [here](https://www.2uo.de/myths-about-urandom/#orthodoxy).
  *  `/dev/zero`, which is a file that you can't write to, but you can read, but it's filled with zeros.
* `/media`: Mount removable **medias**, like USB drives and SD cards. For example, you can mount a USB at `/media/usb1` and another one at `/media/usb2`. Mounting is typically done automatically by the system when you plug it in.
* `/mnt`: **Mounts** that are not so easily removable, like a hard drive, or a network drive. And unlike `/media`, mounting and unmounting is not automatic. On WSL, this typically has just one important thing: `/mnt/c`.
* `/srv`: Static files that are **served** out. `/srv/http` would be for static websites, `/srv/ftp` for an FTP server. It is usually used only on webservers, not an end-user machine like your laptop.

## Environment variables

### How to control them

Use `echo $X` to see what the current value of `X` is.

For current session, use `export` like `export EDITOR=nano`.

For all sessions, add to your `.bashrc` or `.profile`. If you just want to add it to the end (not recommended, as you can end up with an archeological [tell](https://en.wikipedia.org/wiki/Tell_(archaeology))), you can do one-liner like `echo "export EDITOR=nano" >> ~/.bashrc`.

### Common ones

* `PATH`: path to binaries. See @sec-path.
* `EDITOR`: default editor.
* `SHELL`: default shell.
* `HOME`: home directory.
* `USER`: current user.
* `PS1`: current prompt (just try `echo $PS1` if it doesn't make sense).

You can change prompts in a rather arcane language. For example, try this one:

```bash
export PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\\$ "
```

## Cron jobs

Cron jobs are scheduled tasks that run periodically. For scheduling one-off tasks, use the `at` command. The name came from "Cronos", the name of the Greek god of time. A good reference is [Newbie: Intro to cron](http://www.unixgeeks.org/security/newbie/unix/cron-1.html).

### Quick reference

The cron job syntax is as follows (See [Crontab.guru - The cron schedule expression editor](https://web.archive.org/web/20231205205101/https://crontab.guru/)):

```txt
# ┌───────────── minute (0–59)
# │ ┌───────────── hour (0–23)
# │ │ ┌───────────── day of the month (1–31)
# │ │ │ ┌───────────── month (1–12)
# │ │ │ │ ┌───────────── day of the week (0–6) (Sunday to Saturday)
# │ │ │ │ │                                   
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <command to execute>

* * * * * <once a minute>
0 * * * * <once an hour at 0-th minute>
0 0 * * * <once a day at midnight>
0 0 1 * * <once a month at the midnight of the 1-th day>
0 0 1 1 * <once a year at the midnight of January 1>
* * * * 0 <once a minute every Sunday>
```

Check that `cron` service is running by ` systemctl list-unit-files --type=service | grep "cron"`

List cron jobs by `crontab -l`.

### Creating a Cron Job

For this example, we create a job that runs every 20 seconds.

1. **Open Crontab**: 
   Open your crontab file by typing `crontab -e` in your terminal. This command opens the crontab file for the current user in the default text editor.

2. **Write Cron Job**: 
   Standard cron jobs can't run in a smaller granularity than a minute. For a once-per-20-seconds job, you'll need to use a workaround.

   Add the following lines to your crontab:

  ```bash
   * * * * * /path/to/script.sh
   * * * * * sleep 20; ~/cronjobs/script.sh
   * * * * * sleep 40; ~/cronjobs/script.sh
  ```

3. **Script Content**: 
   Create `script.sh`, have the following content:

  ```bash
  #!/bin/bash
  CRON_MESSAGE="Some message"
  echo "The cron message is: $CRON_MESSAGE"
  ```

  Then save and close the file, and `chmod +x ~/cronjobs/script.sh` to make it executable.

### Best Practices

- **Location**: Store scripts in a dedicated directory, such as `~/cronjobs`, for better organization.
- **Script Naming**: Use meaningful names for your scripts for easier identification.
- **Logging**: Implement logging within your scripts to capture output and errors for later review. It's good practice to use `/var/log/cron` for logging.

### Cron environment variables

Cron jobs run in a minimal environment, so any environment variable, like `CRON_MESSAGE`, is not accessible by the cron script. Instead, you have a few choices:

1. Put it directly in the crontab file:

```bash
CRON_MESSAGE="Some message"
* * * * * /path/to/script.sh
```

2. Put it directly in the script:

```bash
#!/bin/bash
export CRON_MESSAGE="Some message"
# rest of the script follows
```

3. If the variable is defined in an external file (like ~/.bashrc, ~/.profile, or a custom configuration file), you can source that file at the beginning of your script:

```bash
#!/bin/bash
source /path/to/environment_variables_file
# rest of the script follows
```

### Troubleshooting

- **Check Permissions**: Ensure your script is executable and the cron daemon has the necessary permissions to run it.
- **Logs**: Check `/var/log/cron` or relevant logs for errors.

If you're using WSL, ensure that the cron service is running since it doesn't start by default. Use `sudo service cron start`. You can configure `~/.bashrc` by adding the following line: `sudo service cron start`, but it would make you enter the password at every login.

Alternatively, enable `systemd` as described at @sec-init-vs-systemd.

## How to WSL

### `init` vs `systemd` {#sec-init-vs-systemd}

Every Linux starts its first process with some root process. The `init` is the traditional and simpler one, and `systemd` is more modern and advanced one.

WSL by default starts with `init` instead of `systemd`, perhaps to save time and compute. This makes things annoying for some users. You can check by `ps -p 1 -o comm` and see what it returns.

To enable `systemd`, enter in your `/etc/wsl.conf` with:

```conf
[boot]
systemd=true
```

or just use `cat "[boot]\nsystemd=true" >> /etc/wsl.conf`.


