# Exit immediately if a command exits with a non-zero status
set -e

PATH_TO_CONSTANTS_FILE="deploy/fb_dev_constants.json";

cp $PATH_TO_CONSTANTS_FILE web/assets/firebase_constants.json

# Dev command
webdev serve --auto=refresh
