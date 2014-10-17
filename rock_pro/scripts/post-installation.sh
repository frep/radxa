#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)
filedir=${basedir}/files


##########################################################################################################
# functions
##########################################################################################################

function assertLaunchStartxScriptExists {
  if [ ! -f /root/launchAtStartx.sh ]; then
    # script does not exist yet. Create it!
    cp ${filedir}/launchAtStartx.sh /root/
  fi
  if [ ! -f /root/.config/autostart/launchAtStartx.desktop ]; then
    # launchAtStartx.desktop does not exist yet. Create it!
    cp ${filedir}/launchAtStartx.desktop /root/.config/autostart/
  fi
}

function setKeyboardlayout {
  dpkg-reconfigure keyboard-configuration
}

function setTimezone {
  dpkg-reconfigure tzdata
}

function resizeRootfs {
  resize2fs /dev/block/mtd/by-name/linuxroot
}

function updateAndUpgrade {
  apt-get clean && apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
}

function installConky {
  apt-get install conky -y
  cp ${filedir}/.conkyrc /root/
}

function activateAliasCommands {
  cp -f ${filedir}/.bashrc /root/
}

function changeXtermColors {
  cp ${filedir}/.Xdefaults /root/
}

function startConkyAtStartx {
  assertLaunchStartxScriptExists
}

function installChromium {
  cp -f ${filedir}/sources.list /etc/apt/sources.list
  cp ${filedir}/main.pref /etc/apt/preferences.d/
  apt-get update
  apt-get install libc6  -t testing -y
  apt-get install libnspr4 libnss3 libxss1 -y
  dpkg -i ${filedir}/chromium/chromium-browser_37.0.2062.120-0ubuntu0.12.04.1~pkg917_armhf.deb ${filedir}/chromium/chromium-codecs-ffmpeg-extra_37.0.2062.120-0ubuntu0.12.04.1~pkg917_armhf.deb
  tar xvfz ${filedir}/chromium/PepperFlash-12.0.0.77-armv7h.tar.gz -C /usr/lib
  cp -f ${filedir}/chromium/default /etc/chromium-browser/default
}

function installJava {
  mkdir -p -v /opt/java
  tar xvzf ${filedir}/jdk-8u6-linux-arm-vfp-hflt.tar.gz -C /opt/java
  update-alternatives --install "/usr/bin/java" "java" "/opt/java/jdk1.8.0_06/bin/java" 1
  update-alternatives --set java /opt/java/jdk1.8.0_06/bin/java
  echo "JAVA_HOME=\"/opt/java/jdk1.8.0_06\"" >> /etc/enviroment
  echo "" >> /root/.bashrc
  echo "export JAVA_HOME=\"/opt/java/jdk1.8.0_06\"" >> /root/.bashrc
  echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /root/.bashrc
}

function installMaven {
  mkdir -p -v /opt/maven
  tar xvzf ${filedir}/apache-maven-3.2.3-bin.tar.gz -C /opt/maven
  echo "" >> /root/.bashrc
  echo "export M2_HOME=\"/opt/maven/apache-maven-3.2.3\"" >> /root/.bashrc
  echo "export M2=\$M2_HOME/bin" >> /root/.bashrc
  echo "export PATH=\$PATH:\$M2" >> /root/.bashrc

}

function installRuby {
  apt-get install curl -y
  curl -L https://get.rvm.io | bash -s stable
  source /usr/local/rvm/bin/rvm
  apt-get install libc6-dev -t testing -y
  rvm requirements
  rvm install ruby
  echo "check ruby installation with rvm list"
  echo "if installed ruby is not set, open a new terminal and type:"
  echo "rvm use ruby-2.1.3 --default"
  mkdir /root/Documents/ruby
  cp ${filedir}/helloWorld.rb /root/Documents/ruby/
}

function installArduino {
  apt-get install arduino -y
  mkdir -p /lib/modules/3.0.36+/kernel/drivers/usb/class
  cp ${filedir}/cdc-acm.ko /lib/modules/3.0.36+/kernel/drivers/usb/class/
  depmod -a
  echo "cdc-acm" >> /etc/modules
}

function fixWiresharkRootProblem {
  cat /usr/share/wireshark/init.lua | sed 's@disable_lua = false@disable_lua = true@' > tmpFile
  mv tmpFile /usr/share/wireshark/init.lua
}

function fixSshService {
  cat /etc/init.d/ssh | sed 's@^.*# Default-Stop:.*$@# Default-Stop:         0 1 6@' > tmpFile
  mv tmpFile /etc/init.d/ssh
  chmod +x /etc/init.d/ssh
  update-rc.d -f ssh remove
  update-rc.d ssh defaults
}

function replaceNetworkManagerWithWicd {
  apt-get remove network-manager -y
  apt-get install wicd -y
}

##########################################################################################################
# program
##########################################################################################################

#setKeyboardlayout

#setTimezone

#resizeRootfs

#updateAndUpgrade

#installConky

#activateAliasCommands

#changeXtermColors

#startConkyAtStartx

#installChromium

#installJava

#installMaven

#installRuby

#fixWiresharkRootProblem

#fixSshService

#replaceNetworkManagerWithWicd

#installArduino
