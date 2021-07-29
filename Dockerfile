FROM ubuntu:20.04
LABEL author="myoodster@gmail.com"

# Install development and other tools
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    python \
    python-openssl \
    unzip \
    wget \
    zip \
    curl \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

# Use Godot 3.3-rc8
ENV GODOT_VERSION "3.3.2"
ENV GODOT_DL_SUBDIR "3.3.2"
ENV GODOT_RELEASE "stable"

# Download and install Godot Engine (headless) and export templates
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz \
    && mkdir -v ~/.cache \
    && mkdir -p -v ~/.config/godot \
    && mkdir -p -v ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE} \
    && unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE} \
    && rm -f Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip
    
# Download and install Android SDK
RUN mkdir -p -v /root/android-sdk-installer/cmdline-tools \
    && cd /root/android-sdk-installer/cmdline-tools \
    && curl -fsSLO "https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip" \
    && unzip -q commandlinetools-linux-*.zip \
    && rm commandlinetools-linux-*.zip \
    && mv cmdline-tools latest

ENV ANDROID_HOME /root/android-sdk

# Download and install SDK tools, accept licences, and create debug.keystore
RUN mkdir -p -v /root/.android
RUN echo "count=0" > /root/.android/repositories.cfg
RUN yes | /root/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --licenses
RUN yes | /root/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "build-tools;30.0.3" "platforms;android-29" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;21.4.7075529"
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
    && mv debug.keystore /root/android-sdk/debug.keystore
   
# Initialize Godot so it creates editor_settings-3.tres file, then add android export section, since it is missing at first
RUN godot -e -q
RUN echo 'export/android/debug_keystore = "/root/android-sdk/debug.keystore"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore_pass = "android"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/android_sdk_path = "/root/android-sdk"' >> ~/.config/godot/editor_settings-3.tres 
