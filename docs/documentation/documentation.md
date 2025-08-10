# Irion OS Documentation
Welcome to Irion OS Documentation! Here you will learn what Irion OS is and how to use it. Enjoy reading

## The documentation uses
- Irion OS v1.0.0
- IC32 v0.0.1
- x86 PC and QEMU

<br>

# 1. Install OS
At the moment there are 2 options how to download and run Irion OS. We will solve each

## Via terminal (Medium)
To install Irion OS via terminal you need to execute the following commands
```
# Clone the repository
git clone https://github.com/filcherock/irion.git
cd irion

# Install the necessary packages
sudo apt install nasm
```

## Via GitHub (Easy)
Later :)

# 2. Launch OS
To run Irion OS, you need to open a command prompt, go to the directory with the disk image and enter the following command
```
qemu-system-i386 -hda img/irion.img
```
But if you have made any changes to the OS source code and now want to build a new OS image, then you need to run the command line, go to the root directory and run the following command there
```
sh build.sh
```