#!/usr/bin/env bash
#  ┳┓┏┓┏┓┏┓┳┓┳┓
#  ┣┫┣ ┃ ┃┃┣┫┃┃
#  ┛┗┗┛┗┛┗┛┛┗┻┛
#

getdate() {
  date '+%Y-%m-%d_%H%M%S'
}
getactivemonitor() {
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

xdgvideo="$(xdg-user-dir VIDEOS)"
if [[ $xdgvideo = "$HOME" ]]; then
  unset xdgvideo
fi
mkdir -p "${xdgvideo:-$HOME/Videos}"
cd "${xdgvideo:-$HOME/Videos}" || exit

if pgrep wf-recorder >/dev/null; then
  notify-send "Recording Stopped" "Stopped" -a 'Recorder' &
  pkill wf-recorder &
else
  if [[ "$1" == "--fullscreen-sound" ]]; then
    notify-send "Starting recording" 'recording_'"$(getdate)"'.mp4' -a 'Recorder'
    wf-recorder -o $(getactivemonitor) -f './recording_'"$(getdate)"'.mp4' -t -a &
    disown
  elif [[ "$1" == "--fullscreen" ]]; then
    notify-send "Starting recording" 'recording_'"$(getdate)"'.mp4' -a 'Recorder'
    wf-recorder -o $(getactivemonitor) -f './recording_'"$(getdate)"'.mp4' -t &
    disown
  else
    if ! region="$(slurp 2>&1)"; then
      notify-send "Recording cancelled" "Selection was cancelled" -a 'Recorder'
      exit 1
    fi
    notify-send "Starting recording" 'recording_'"$(getdate)"'.mp4' -a 'Recorder'
    if [[ "$1" == "--sound" ]]; then
      wf-recorder -f './recording_'"$(getdate)"'.mp4' -t --geometry "$region" -a &
      disown
    else
      wf-recorder -f './recording_'"$(getdate)"'.mp4' -t --geometry "$region" &
      disown
    fi
  fi
fi
