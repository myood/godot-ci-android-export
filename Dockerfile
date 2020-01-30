FROM ubuntu:cosmic
LABEL author="artur@barichello.me,myoodster@gmail.com"

# Install development and other tools
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

# Use Godot 3.1.2
ENV GODOT_VERSION "3.1.2"

# Download and install Godot Engine (headless) and export templates
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir -v ~/.cache \
    && mkdir -p -v ~/.config/godot \
    && mkdir -p -v ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip
    
# Download and install Android SDK
RUN mkdir -p -v ~/android \
    && cd ~/android \
    && curl -fsSLO "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    && unzip -q sdk-tools-linux-*.zip \
    && rm sdk-tools-linux-*.zip \
    && export ANDROID_HOME=~/android
    
# Download and install SDK tools, accept licences, and create debug.keystore
RUN mkdir -p -v ~/.android
RUN echo "count=0" > ~/.android/repositories.cfg
RUN { yes | "$ANDROID_HOME/tools/bin/sdkmanager" --licenses || true } > /dev/null 
RUN { yes | "$ANDROID_HOME/tools/bin/sdkmanager" "tools" "platform-tools" "build-tools;28.0.3" || true } > /dev/null
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
    && mv debug.keystore $ANDROID_HOME/debug.keystore
   
# Initialize Godot so it creates editor_settings-3.tres file, then update android export section
RUN godot -e -q
RUN sed -i 's/export\/android\/adb = .*/export\/android\/adb = "~\/android\/platform-tools\/adb"/g' ~/.config/godot/editor_settings-3.tres
RUN sed -i 's/export\/android\/debug_keystore = .*/export\/android\/debug_keystore = "~\/android\/debug.keystore"/g' ~/.config/godot/editor_settings-3.tres
RUN sed -i 's/export\/android\/jarsigner =.*/export\/android\/jarsigner = "\/usr\/lib\/jvm\/java-8-openjdk-amd64\/bin\/jarsigner"/g' ~/.config/godot/editor_settings-3.tres

# Leftover from original image, I guess this is for itch.io deplotyment - missing here
# TODO: remove
ADD getbutler.sh /opt/butler/getbutler.sh
RUN bash /opt/butler/getbutler.sh
RUN /opt/butler/bin/butler -V
ENV PATH="/opt/butler/bin:${PATH}"
