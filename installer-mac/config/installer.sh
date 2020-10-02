#!/usr/bin/env bash
sudo rm -rf /Library/CoreMediaIO/Plug-Ins/DAL/obs-mac-virtualcam.plugin && sudo cp -r obs-mac-virtualcam.plugin /Library/CoreMediaIO/Plug-Ins/DAL
mkdir /Library/Audio/Plug-Ins/HAL
sudo rm -rf /Library/Audio/Plug-Ins/HAL/BlackHole.driver && sudo cp -r BlackHole.driver /Library/Audio/Plug-Ins/HAL/BlackHole.driver
sudo launchctl kickstart -kp system/com.apple.audio.coreaudiod
sudo rm -rf ~/Library/Application\ Support/obs-studio && sudo cp -r obs-studio ~/Library/Application\ Support/
sudo rm -rf /Library/Application\ Support/obs-studio && sudo mkdir /Library/Application\ Support/obs-studio
sudo cp -r plugins /Library/Application\ Support/obs-studio
