# KickThemOut

> [KickThemOut](https://nikolaskama.me/kickthemoutproject) - **Kick Devices Off Your Network**

A tool to kick devices out of your network and enjoy all the bandwidth for yourself.
It allows you to select specific or all devices and ARP spoofs them off your local area network.

- Compatible with Python **3+** 🎉.

- *Not* compatible with Windows.

Authors: [Nikolaos Kamarinakis](mailto:nikolaskam@gmail.com) & [David Schütz](mailto:xdavid@protonmail.com).

[![License Badge](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/k4m4/kickthemout/blob/master/LICENSE)
[![Compatibility](https://img.shields.io/badge/python-3-brightgreen.svg)](https://github.com/k4m4/kickthemout)
[![GitHub Stars](https://img.shields.io/github/stars/k4m4/kickthemout.svg)](https://github.com/k4m4/kickthemout/stargazers)

---

    
-------------

# Installation

## Debian Installation

**NOTE**
After most linux distros/Mac implemented PEP 668, you can no longer use **pip** to install system-wide python dependencies without a virtual environment. For most distros you will need to install the dependencies through your package manager using a command like this: ``` sudo apt install python3-packagename ``` 

You can download kickthemout by using the setup.sh, or cloning the repo:

**IF USING THE SETEUP.SH (Debian Systems ONLY) Follow the instructions below:**
```
1. create the setup.sh shell script by copying its contents from this repo.
2. ❯❯❯ chmod +x setup.sh
3. ❯❯❯ ./setup.sh
```
4. The script will clone the repo, install needed dependencies, and run kickthemout for the first time!


**DEBIAN MANUAL INSTALL INSTRUCTIONS BELOW:**


```
~ ❯❯❯ sudo apt-get update && sudo apt-get install nmap

~ ❯❯❯ sudo apt install python3-nmap && sudo apt install python3-scapy && sudo apt install python3-netifaces

~ ❯❯❯ git clone https://github.com/k4m4/kickthemout.git

~ ❯❯❯ cd kickthemout/

~/kickthemout ❯❯❯ sudo python3 kickthemout.py
```


## MacOS Installation

If you would like to install KickThemOut on a Mac, please run the following: **NOTE: You will need a virtual environment on mac**

```
~ ❯❯❯ brew install libdnet nmap

~ ❯❯❯ git clone https://github.com/k4m4/kickthemout.git

~ ❯❯❯ cd kickthemout/

~/kickthemout ❯❯❯ sudo -H pip3 install -r requirements.txt 

~/kickthemout ❯❯❯ sudo python3 kickthemout.py

```

**NOTE**: You need to have [Homebrew](http://brew.sh/) installed before running the Mac OS installation. 

Also, **keep in mind** that you might be asked to run some extra commands after executing the pip requirement installation.


## ArchLinux Installation

You can download KickThemOut on an Arch based system by executing the following: 

**NOTE: You will need a virtual environment to use pip, unless you install the python dependencies through the AUR as PACMAN does not currently have the needed dependencies**

```
~ ❯❯❯ git clone https://github.com/k4m4/kickthemout.git

~ ❯❯❯ cd kickthemout/

~/kickthemout ❯❯❯ sudo -H pip3 install -r requirements.txt **NOTE: You will need a virtual environment to use pip**

~/kickthemout ❯❯❯ sudo python kickthemout.py
```

<br/>

# Usage

```
Usage: sudo python3 kickthemout.py [options]

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -p PACKETS, --packets=PACKETS
                        number of packets broadcasted per minute (default: 6)
  -s, --scan            perform a quick network scan and exit
  -t TARGETS, --target=TARGETS
                        specify target IP address(es) and perform attack

Examples:
  sudo python3 kickthemout.py --target 192.168.1.10 
  sudo python3 kickthemout.py -t 192.168.1.5,192.168.1.10 -p 30
  sudo python3 kickthemout.py (interactive mode)
```

To view all available options run:

```
~/kickthemout ❯❯❯ sudo python3 kickthemout.py -h
```


<br/>


<br/>

# Developers

* Nikolaos Kamarinakis - [@nikolaskama](https://twitter.com/nikolaskama)
* David Schütz - [@xdavidhu](https://twitter.com/xdavidhu)


<br/>

# Disclaimer

KickThemOut is provided as is under the MIT Licence (as stated below). 
It is built for educational purposes *only*. If you choose to use it otherwise, the developers will not be held responsible. Please, do not use it with evil intent.


<br/>

# License

Copyright (c) 2017-18 by [Nikolaos Kamarinakis](mailto:nikolaskam@gmail.com) & [David Schütz](mailto:xdavid@protonmail.com). Some rights reserved.

KickThemOut is under the terms of the [MIT License](https://www.tldrlegal.com/l/mit), following all clarifications stated in the [license file](https://raw.githubusercontent.com/k4m4/kickthemout/master/LICENSE).


For more information head over to the [official project page](https://nikolaskama.me/kickthemoutproject).
You can also go ahead and email me anytime at **nikolaskam{at}gmail{dot}com** or David at **xdavid{at}protonmail{dot}com**.
