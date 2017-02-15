FROM node:7.5

# Installs i386 architecture required for running 32 bit Android tools
RUN dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        libc6:i386 \
        libncurses5:i386 \
        libstdc++6:i386 \
        zlib1g:i386 \
        lib32gcc1 \
        lib32z1 \
        lib32stdc++6 \
        openjdk-8-jdk-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install android SDK, tools and platforms 
RUN cd /opt \
    && curl https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -o android-sdk.tgz \
    && tar xzf android-sdk.tgz \
    && rm android-sdk.tgz

ENV ANDROID_HOME /opt/android-sdk-linux
RUN echo 'y' | /opt/android-sdk-linux/tools/android update sdk -u -a -t platform-tools,build-tools-23.0.3,android-23

# Install npm packages
RUN npm i -g cordova ionic gulp bower grunt phonegap node-gyp && npm cache clean

# Create dummy app to build and preload gradle and maven dependencies
RUN cd / \
    && echo 'n' | ionic start app --v2 --ts \
    && cd /app \
    && ionic platform add android \
    && ionic build android \
    && rm -rf * .??* \
    && rm /root/.android/debug.keystore

WORKDIR /app