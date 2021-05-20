#!/usr/bin/env bash

APP_CENTER_CURRENT_PLATFORM="android"

if [ -z "$APP_CENTER_CURRENT_PLATFORM" ]
then
    echo "You need define the APP_CENTER_CURRENT_PLATFORM variable in App Center with values android or ios"
    exit
fi

if [ "$APP_CENTER_CURRENT_PLATFORM" == "android" ]
then
    echo "lsb_release -a"
    lsb_release -a
    echo "react-native info ---"
    react-native info
    echo "Setup Android simulator"
    SIMULATOR_IMAGE="system-images;android-28;google_apis;x86"
    # SIMULATOR_NAME="Pixel_XL_API_28"

    ANDROID_HOME=~/Library/Android/sdk
    # ANDROID_SDK_ROOT=~/Library/Android/sdk
    # ANDROID_HOME=~/Android/sdk
    # ANDROID_SDK_ROOT=~/Android/sdk
    # ANDROID_AVD_HOME=~/.android/avd
    # PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"


    export PATH=$PATH:$ANDROID_HOME/emulator
    export ANDROID_HOME=~/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/platform-tools/
    export PATH=$PATH:$ANDROID_HOME/tools/bin/
    export PATH=$PATH:$ANDROID_HOME/tools/
    PATH=$ANDROID_HOME/emulator:$PATH

    echo "PATH ---'$PATH'"

    # Install AVD files
    echo "Install AVD files---"
    $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-29;default;x86'
    yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

    # Create emulator
    echo "Create emulator---"
    echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n Pixel_API_29_AOSP -d pixel --package 'system-images;android-29;default;x86' --force
    echo "Finish creating emulator---"

    $ANDROID_HOME/emulator/emulator -list-avds

    # Set screen dimensions
    echo "Set screen dimensions---"
    echo "hw.lcd.density=420" >> ~/.android/avd/Pixel_API_29_AOSP.avd/config.ini
    echo "hw.lcd.height=1920" >> ~/.android/avd/Pixel_API_29_AOSP.avd/config.ini
    echo "hw.lcd.width=1080" >> ~/.android/avd/Pixel_API_29_AOSP.avd/config.ini

    echo "Starting emulator and waiting for boot to complete..."
    nohup $ANDROID_HOME/emulator/emulator -avd Pixel_API_29_AOSP -no-snapshot -no-window -no-audio -no-boot-anim -camera-back none -camera-front none -qemu -m 2048 > /dev/null 2>&1 &
    $ANDROID_HOME/platform-tools/adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed | tr -d '\r') ]]; do sleep 1; done; input keyevent 82'

    echo "Emulator has finished booting"
    $ANDROID_HOME/platform-tools/adb devices

    # echo "Accepts all sdk licences"
    # yes | sdkmanager --licenses

    # echo "Download Simulator Image"
    # sdkmanager --install "$SIMULATOR_IMAGE"

    # echo "Create Simulator '$SIMULATOR_NAME' with image '$SIMULATOR_IMAGE'"
    # echo "no" | avdmanager --verbose create avd --force --name "$SIMULATOR_NAME" --device "pixel" --package "$SIMULATOR_IMAGE" --tag "google_apis" --abi "x86"

    echo "Emulator list---"
    # emulator @"$SIMULATOR_NAME"
    emulator -list-avds

    DETOX_CONFIG=android.emu.release
else
    echo "Install AppleSimUtils"

    brew tap wix/brew
    brew update
    brew install applesimutils

    echo "Install pods "
    cd ios; pod install; cd ..

    DETOX_CONFIG=ios.sim.release
fi

echo "adb devices -----"
adb devices -l

echo "Building the project for Detox tests..."
npx detox build --configuration "$DETOX_CONFIG"

echo "Executing Detox tests..."
npx detox test --configuration "$DETOX_CONFIG" -l trace --record-logs all --cleanup