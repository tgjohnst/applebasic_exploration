# applebasic_exploration

Figuring out how to run AppleSoft BASIC programs, written on a modern mac, on an original apple IIc.

One suggested potential solution is to build a remote keyboard emulator. However, this would require a significant amount of hardware expertise, components that may no longer exist, and a string of conversions of input format. We are be better off emulating a disk drive (or even writing our own floppies) and packaging up programs as disk images.

# AppleSoft BASIC

[Applesoft (integer) BASIC](https://en.wikipedia.org/wiki/Applesoft_BASIC) is a form of Microsoft BASIC written for the Apple I and II.

Example Hello World program:
```
10 PRINT "HELLO WORLD"
```

More example programs, including those used below can be found in this repo in the [applesoft_basic_programs](applesoft_basic_programs/) folder

# Writing disk images containing our program

AppleCommander appears to be the standard for composing disk images. Although our program will be written in AppleSoft BASIC, it needs to be properly tokenized to be read by the Apple IIc. Thankfully, AppleCommander has a utility for loading plaintext BASIC into disk images: https://applecommander.github.io/ac/#put-standard-input-basic-source-code-onto-disk-image-as-a-basic-file.

## Setup AppleCommander on a mac
My mac is running OSX ventura on Apple silicon (M1). Theoretically, the `ac` (commandline) version of applecommander is agnostic to OS, so this shouldn't matter; the included jar file should work on all systems.

Unless I write some kind of web server for this, we are going to do this using the command line (terminal) on our mac

Install java openjdk and test if the distributed jar is working (note we use the `ac` jar for command line version of applecommander)

```
brew install openjdk@11
# in this repository
java -jar applecommander/AppleCommander-ac-1.8.0.jar
```

## Converting a BASIC file to a disk image
We can add BASIC to be loaded 2 ways, either on a disk with DOS 3.3 Master preloaded, or on an empty DOS compatible disk. Generally, if we only have one disk drive (or disk drive emulator), we will want to go with option (1) since we will need the BASIC interpreter that comes with DOS

### Adding images on top of DOS w/ Integer BASIC
```
# from the root of this repo
cp disk_images/dos_3_3_master.dsk disk_images/helloworld_dos.dsk
cat applesoft_basic_programs/helloworld.bas | java -jar applecommander/AppleCommander-ac-1.8.0.jar -bas disk_images/helloworld_dos.dsk helloworld

# we can add multiple BASIC programs to one disk image
cp disk_images/dos_3_3_master.dsk disk_images/myprograms_dos.dsk
cat applesoft_basic_programs/helloworld.bas | java -jar applecommander/AppleCommander-ac-1.8.0.jar -bas disk_images/myprograms_dos.dsk helloworld
cat applesoft_basic_programs/sample.bas | java -jar applecommander/AppleCommander-ac-1.8.0.jar -bas disk_images/myprograms_dos.dsk sample
```

### Adding images to an empty DOS disk image

```
# from the root of this repo
java -jar applecommander/AppleCommander-ac-1.8.0.jar -dos140 disk_images/helloworld.dsk
cat applesoft_basic_programs/helloworld.bas | java -jar applecommander/AppleCommander-ac-1.8.0.jar -bas disk_images/helloworld.dsk helloworld

java -jar applecommander/AppleCommander-ac-1.8.0.jar -dos140 disk_images/sample.dsk
cat applesoft_basic_programs/sample.bas | java -jar applecommander/AppleCommander-ac-1.8.0.jar -bas disk_images/sample.dsk sample
```

# Where to run your disk image

## Using an actual Apple II + a disk drive emulator
Unless you have the (rare) hardware to write 5.25" floppy disks, you will need a hardware device to pretend to be a disk drive. The images (.dsk files) you created above are loaded via SD card onto this disk drive emulator device, which is connected to the Apple II. Such emulators tend to cost around $100

Suitable devices include:
- [FloppyEmu](https://www.bigmessowires.com/floppy-emu/)
- [wDrive](https://ct6502.org/product/wdrive/)

### *Using a disk emulator but don't want to move an SD card back and forth?*
Using a Wifi SD card such as eye-fi, toshiba flashAir, etc, you could enable wifi transfer of disk images to one of the above hardware disk emulators so that you wouldn't even have to worry about SD cards, just connect to the wifi sd network from your mac and drop the disk image files on there.

## Using an actual Apple II + ADTPro
ADTPro is a program that, when running on both an apple II and a modern PC connected by some manner, allows transfer of disk images between the two. 

The suggested setup for a modern PC to an Apple IIc involves a null modem to RS232 cable and a USB to rs232 cable. These cables can be purchased [here](https://retrofloppy.com/products/#USB)

Since we only need to run applesoft BASIC programs, and our IIc may not have enough memory to run ProDOS, we just want the DOS 3.3 version of ADT if we can manage to get it working
- [ADT (DOS 3.3)](https://github.com/david-schmidt/adt)
- [ADTPro](https://adtpro.com/index.html)

TODO: I will finish this section later.

## Using a software-emulated Apple II
Don't have an actual Apple II? You can use these emulators to test disk images by using the process above if you don't own actual apple II hardware:
- https://www.scullinsteel.com/apple2/ is an online apple ii emulator
- [microm8](https://paleotronic.com/software/microm8/) is an Apple II emulator for Windows

# Loading your program from disk

## If we are using a modified DOS master disk in single disk mode (option 1)
1. Insert our modified disk (image) in drive 1 (bootable). 
    - Allow to boot into DOS (you should see "DOS VERSION 3.3 .... (LOADING INTEGER INTO LANGUAGE CARD)")
2. Run the program, using the program name you chose, via `RUN MYPROGRAM`
    - You do not need to specify disk, since by default it will look on the booted disk (D1)
3. If you need to exit (let's say you want to try multiple programs), hit RESET on the keyboard and `RUN MYOTHERPROGRAM` to run any other program on the disk

## If we are using a DOS master disk + a custom disk via a single drive (option 2a)
1. Insert DOS 3.3 master disk in drive 1 (bootable). Allow to boot
2. Insert custom disk (image) in drive 1. 
3. At the DOS command prompt, enter `RUN MYPROGRAM` and hit enter, using your program name instead of "MYPROGRAM".
4. If you need to exit, hit RESET on the keyboard, you'll still be in DOS

## If we are using a DOS master disk + a custom disk via 2 drives (option 2b)
1. Insert DOS 3.3 master disk in drive 1 (bootable). Allow to boot
2. Insert custom disk (image) in drive 2. 
3. At the DOS command prompt, enter `RUN MYPROGRAM,D2` and hit enter, using your program name instead of "MYPROGRAM". D2 specifies to look on the second disk.
4. If you need to exit, hit RESET on the keyboard, you'll still be in DOS

