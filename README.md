# applebasic_exploration

Figuring out how to run apple BASIC programs, written on a modern mac, on an apple II.

One suggested potential solution is to build a remote keyboard emulator. However, this would require a significant amount of hardware expertise, components that may no longer exist, and a string of conversions of input format. We may be better off emulating a disk drive and packaging up programs as disk images.

# Writing disk images

AppleCommander appears to be the standard for composing disk images. Although our program will be written in AppleSoft BASIC, it needs to be properly tokenized to be read by the Apple IIc. Thankfully, AppleCommander has a utility for loading plaintext BASIC into disk images: https://applecommander.github.io/ac/#put-standard-input-basic-source-code-onto-disk-image-as-a-basic-file.

## Setup AppleCommander on a mac
My mac is running OSX ventura on Apple silicon (M1). Theoretically, the `ac` (commandline) version of applecommander is agnostic to OS, so this shouldn't matter; the included jar file should work on all systems.

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


# Testing disk images
You can use these emulators to test disk images by using the process above if you don't own actual apple II hardware:
- https://www.scullinsteel.com/apple2/ is an online apple ii emulator
- [microm8](https://paleotronic.com/software/microm8/) is an Apple II emulator for Windows

# Running your programs from a disk image

## If we are using a modified DOS master disk (option 1)
1. Insert our modified disk (image) in drive 1 (bootable). 
    - Allow to boot into DOS (you should see "DOS VERSION 3.3 .... (LOADING INTEGER INTO LANGUAGE CARD)")
2. Run the program, using the program name you chose, via `RUN MYPROGRAM`
    - You do not need to specify disk, since by default it will look on the booted disk (D1)
3. If you need to exit (let's say you want to try multiple programs), hit RESET on the keyboard and `RUN MYOTHERPROGRAM` to run any other program on the disk

## If we are using 1 disk drive with a DOS master disk + a custom disk (option 2a)
1. Insert DOS 3.3 master disk in drive 1 (bootable). Allow to boot
2. Insert custom disk (image) in drive 1. 
3. At the DOS command prompt, enter `RUN MYPROGRAM` and hit enter, using your program name instead of "MYPROGRAM".
4. If you need to exit, hit RESET on the keyboard, you'll still be in DOS

## If we are using 2 disk drives with a DOS master disk + a custom disk (option 2b)
1. Insert DOS 3.3 master disk in drive 1 (bootable). Allow to boot
2. Insert custom disk (image) in drive 2. 
3. At the DOS command prompt, enter `RUN MYPROGRAM,D2` and hit enter, using your program name instead of "MYPROGRAM". D2 specifies to look on the second disk.
4. If you need to exit, hit RESET on the keyboard, you'll still be in DOS


# Random notes

```
For the system Java wrappers to find this JDK, symlink it with
  sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

openjdk@11 is keg-only, which means it was not symlinked into /opt/homebrew,
because this is an alternate version of another formula.

If you need to have openjdk@11 first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> /Users/timothyjohnstone/.bash_profile

For compilers to find openjdk@11 you may need to set:
  export CPPFLAGS="-I/opt/homebrew/opt/openjdk@11/include"
  ```