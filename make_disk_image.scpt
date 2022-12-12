# Welcome the user
set dialogText to "This script will create a usable disk image containing your AppleSoft BASIC program(s). You will be guided through the process. Your BASIC programs need to be saved as a text file. Press OK to continue."
display dialog dialogText buttons {"OK"}

# Check Java installation
to javaError()
    set errorText to "The script encountered a problem with your Java installation. Please ensure java is installed and available at the command line. You can install java from the java website, or by using homebrew ('brew install openjdk@11')"
    display dialog errorText buttons {"Exit"}
    quit
end javaError

try
    do shell script "java -h"
on error
    javaError()
end try


# Prompt the user for  the base image
set dialogText to "Select your base disk image. Empty images do not contain DOS 3.3 so DOS must be loaded from another disk prior to running programs contained on the result."
display dialog dialogText buttons {"Empty Image", "DOS 3.3 Image"} default button "Empty Image" cancel button "DOS 3.3 Image"

# Prompt the user for output folder
#TODO

# Prompt the user for output file name
#TODO

# Set addBasic to true. While addbasic: 
  # Prompt the user for basic file (or txt)
  # Ask user for program name
  # Do the actual conversion and addition
  # Ask the user if they would like to add more and set addbasic accordingly

# Display to the user the output filename
# Open a finder window in the output location
# Exit
