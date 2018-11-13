#!/bin/sh

#
# NOTE: If your check script needs additional or specific packages, you can
#       list them under extra_package build argument. They will be installed
#       during the build of the image.
#

# random int between 0 and 1
healty=$(shuf -i 0-1 -n 1)

#
# NOTE: You have to echo 1 to say "the system is up"
#       or echo 0 to say "the system is down". How
#       to obtain 1 or 0 is a your own job.
#
echo ${healty}
