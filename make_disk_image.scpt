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
