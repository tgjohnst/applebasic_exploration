
# Set constants


# Initialize the script
######

# Welcome the user
set dialogText to "This script will create a usable disk image containing your AppleSoft BASIC program(s). You will be guided through the process. Your BASIC program(s) need to be saved as text file(s) before you start. Press OK to continue."
display dialog dialogText buttons {"OK"} default button "OK"

# Check Java installation
on javaError()
    set errorText to "The script encountered a problem with your Java installation. Please ensure java is installed and available at the command line. You can install java from the java website, or by using homebrew ('brew install openjdk@11')"
    display dialog errorText buttons {"Exit"}
    quit
end javaError

try
    do shell script "java -h"
on error
    javaError()
end try

# Get info from the user about what they want to do and create base image
######

# Prompt the user for output folder
set outFolder to choose folder with prompt "Please select a destination folder for your disk image"

# Prompt the user for output file name
display dialog "Please enter a name for your disk image. This name cannot contain spaces or special characters" default answer "my_image" with icon note buttons {"Cancel", "Continue"} default button "Continue"
set outImageName to text returned of the result

# Prompt the user for  the base image
set dialogText to "Select your base disk image.\n\nEmpty images do not contain DOS 3.3 so DOS must be loaded from another disk prior to running programs contained on the result.\n\nBootable images contain DOS 3.3 and have less space for larger programs, but allow you to boot and run from a single disk."
set imageChoice to the button returned of (display dialog dialogText buttons {"Empty Image", "Bootable Image"} default button "Bootable Image")

# Get path to input reference file for use in the next step
#  this is a relative path to this applescript, since they should stay in the same folder
on getInputImagePath(imageChc)
    set DOS_MASTER_RELPATH to "/disk_images/reference/dos_3_3_master.dsk"
    set EMPTY_RELPATH to "/disk_images/reference/dos140_empty.dsk"
    set thisPath to POSIX path of (path to me)
    set workingPath to do shell script "dirname " & thisPath
    if (imageChc = "Empty Image") then
        set imagePath to workingPath & EMPTY_RELPATH
    else if (imageChc = "Bootable Image") then
        set imagePath to workingPath & DOS_MASTER_RELPATH
    end if
    return imagePath
end getInputImagePath

set inputImagePath to (POSIX file getInputImagePath(imageChoice) as alias)

# TODO ^ change these to Resources once packaged as app i.e.
# set resourceName to "blablabla.dsk"
# set filePathName to quoted form of POSIX path of (path to resource resourceName) as text

# checks if a file exists in a folder, if so adds a _1 (etc) so we dont hit rename collisions
on createNewFileName(fileLocation, fileName, fileExtension)
   set x to 1
   if fileExtension = null or fileExtension = "" then
       set fileExtension to ""
   else
       set fileExtension to "." & fileExtension
   end if
   set existingFiles to list folder fileLocation with invisibles
   set availableFileName to fileName & fileExtension
   repeat
       if availableFileName is in existingFiles then
           set availableFileName to fileName & "_" & x & fileExtension
           set x to x + 1
       else
           return availableFileName
       end if
   end repeat
end createNewFileName 


# Copy input image to destination for upcoming modification
on createTargetImage(baseImagePath, outFileName, outFolder)
    set outFileNameNR to createNewFileName(outFolder, outFileName, "dsk")
    tell application "Finder"
        set duplicatedFile to duplicate file baseImagePath to folder outFolder with replacing
        set name of duplicatedFile to outFileNameNR
    end tell
    return alias ((outFolder as text) & outFileNameNR)
end createTargetImage

display dialog (createTargetImage(inputImagePath, outImageName, outFolder) as text)

# Set addBasic to true. While addbasic: 
  # Prompt the user for basic file (or txt)
  # Ask user for program name
  # Do the actual conversion and addition
  # Ask the user if they would like to add more and set addbasic accordingly

# Display to the user the output filename
# Open a finder window in the output location
# Exit