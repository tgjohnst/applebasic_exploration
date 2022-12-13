
# Set constants


# Initialize the script
######

# Welcome the user
set dialogText to "This script will create a usable disk image containing your AppleSoft BASIC program(s). You will be guided through the process. Your BASIC program(s) need to be saved as text file(s) before you start. Press OK to continue."
display dialog dialogText buttons {"OK"} default button "OK"

# Check Java installation
on noJavaError()
    set errorText to "The script encountered a problem with your Java installation. Please ensure java is installed and available at the command line. You can install java from the java website, or by using homebrew ('brew install openjdk@11')"
    display dialog errorText buttons {"Exit"}
    quit
end noJavaError

try
    do shell script "java -h"
on error
    noJavaError()
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

set newTargetImage to createTargetImage(inputImagePath, outImageName, outFolder)

# Add each input BASIC file to the disk image
######

# Gets the path to the applecommander executable
on getACPath()
    set AC_RELPATH to "/applecommander/AppleCommander-ac-1.8.0.jar"
    set thisPath to POSIX path of (path to me)
    set workingPath to do shell script "dirname " & thisPath
    set workingPathAlias to POSIX FILE (workingPath & AC_RELPATH) as alias
    return workingPathAlias
end getACPath

# Makes the AppleCommander Command to run
on makeACCommand(basicFilePath, programName, targetImagePath)
    set acPath to getACPath()
    set theCommand to "cat " & (POSIX path of basicFilePath)
    set theCommand to theCommand & " | java -jar " & (POSIX path of acPath) 
    set theCommand to theCommand & " -bas " & (POSIX path of targetImagePath)
    set theCommand to theCommand & " " & programName
    log theCommand
    return theCommand
end makeACCommand

# Called if AppleCommander hits an error adding the basic file
on acJavaError(errMsg)
    set acMsg to "There was an error adding your basic file to the disk.\nHave you confirmed it's a valid integer basic file?\nDetails below:\n\n" & errMsg
    display dialog acMsg
    quit
end acJavaError

# Adds an applesoft BASIC file to a target image
on addFileToImage(basicFilePath, programName, targetImagePath)
    set acCommand to makeACCommand(basicFilePath, programName, targetImagePath)
    try
        do shell script acCommand
    on error errMsg
        acJavaError(errMsg)
    end try
end addFileToImage

# Gets a suggested name for a basic program. 
# e.g. by default, "myprog.bas" converts to MYPROG
on getSuggestedName(basicFilePath)
    set theCommand to "basename " & (POSIX path of basicFilePath)
    set theCommand to theCommand & " | sed 's/\\(.*\\)\\..*/\\1/'"
    set theCommand to theCommand & " | sed 's/[^[:alnum:]-]//g'"
    set theCommand to theCommand & " | tr [:lower:] [:upper:]"
    set parsedName to do shell script theCommand
    return parsedName
end getSuggestedName
    
# TODO ^add resource paths instead of using relative path here.

set addBasic to true

repeat while (addBasic = true)
    # Get program file
    set basicToAdd to choose file with prompt "Select your Apple basic program file (.txt / .bas)"
    set suggestedName to getSuggestedName(basicToAdd)
    # Get program name
    display dialog "Please enter a name for your program. This name cannot contain spaces or special characters" default answer suggestedName with icon note buttons {"Cancel", "Continue"} default button "Continue"
    set addAsName to text returned of the result
    # Add them to the image
    set cmdResult to addFileToImage(basicToAdd, addAsName, newTargetImage)
    # See if the user wants to add more files, if so repeat
    display dialog "Would you like to add any more BASIC files to your disk?" buttons {"Yes", "No"} default button "No"
    set doContinue to the button returned of the result
    if (doContinue = "No")
        set addBasic to False
    end if
end repeat

# Finally, open a finder window with the output file highlighted
display dialog "Complete - Your image is now ready to use!\n\nClick OK to open the file in Finder and exit" buttons {"OK"} default button "OK"
tell application "Finder"
    reveal newTargetImage
end tell