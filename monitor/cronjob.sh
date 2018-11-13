#!/bin/bash

# Copyright 2018 Paolo Smiraglia <paolo.smiraglia@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

_CHANNEL=${CHANNEL:-""}
_WEBHOOK=${WEBHOOK:-""}

if [ "X${_CHANNEL}" == "X" ]; then
  (>&2 echo "The Slack channel must be set! (use CHANNEL envvar)")
  exit 1
fi

if [ "X${_WEBHOOK}" == "X" ]; then
  (>&2 echo "The webhook URL must be set! (use WEBHOOK envvar)")
  exit 1
fi

_EMOJI=${EMOJI:-":moyai:"}
_SERVICE=${SERVICE:-"NyService"}
_USERNAME=${USERNAME:-"MyBot"}

#
# helpers
#

HEALTY=1
WASUP=".wasup"
WASDOWN=".wasdown"

function _notify() {
  payload=$(mktemp)
  cat > ${payload} <<EOF
{
  "channel": "${_CHANNEL}",
  "icon_emoji": "${_EMOJI}",
  "text": "${_SERVICE} is ${1}! ${2}",
  "username": "${_USERNAME}"
}
EOF
  curl \
    --silent \
    -XPOST \
    -d @${payload} \
    -H 'Content-Type: application/json' \
    ${_WEBHOOK} > /dev/null
  rm -f ${payload}
}

function _notify_u() {
  _notify "up" "${1}"
}

function _notify_d() {
  _notify "down" "${1}"
}

#
# worker
#

(>&2 echo -n "$(date) - Checking ${_SERVICE}...")
check=$(/opt/monitor/check.sh)
(>&2 echo " (${check})")

if [ ${check} -eq ${HEALTY} ]; then
  if [ -f ${WASDOWN} ]; then

    # reset counters
    date +%s > ${WASUP}

    # calculate downtime
    _up=$(cat ${WASUP})
    _down=$(cat ${WASDOWN})
    _downtime=$((${_up} - ${_down}))

    
    ((h=${_downtime}/3600))
    ((m=(${_downtime}%3600)/60))
    ((s=${_downtime}%60))

    # notify
    msg="It was DOWN for $(printf '%02d hours, %02d minutes and %02d seconds' $h $m $s)"
    _notify_u "${msg}"

    # reset DOWN counter
    rm -f ${WASDOWN}
  fi
  if [ ! -f ${WASUP} ]; then
    # set UP counter
    date +%s > ${WASUP}
  fi
else
  if [ -f ${WASUP} ]; then
    # notify
    msg=""
    _notify_d "${msg}"
    
    # reset counters
    date +%s > ${WASDOWN}
    rm -f ${WASUP}
  fi
  if [ ! -f ${WASDOWN} ]; then
    # notify
    msg=""
    _notify_d "${msg}"
    
    # set DOWN counter
    date +%s > ${WASDOWN}
  fi
fi

# vim: tabstop=2 shiftwidth=2 softtabstop=2
