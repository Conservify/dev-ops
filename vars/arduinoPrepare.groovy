#!/usr/bin/env groovy

def call(Map parameters = [:]) {
    stage ('prepare') {
        echo "Preparing Arduino Packages"

        dir ('..') {
            if (!fileExists('arduino-packages/.git/config')) {
                dir ('arduino-packages') {
                    git branch: 'linux', url: 'https://github.com/jlewallen/arduino-packages.git'
                }
            }

            dir ('arduino-ide') {
                sh """
if [ ! -d arduino-1.8.3 ]; then
  if [ ! -f arduino-1.8.3-linux64.tar.xz ]; then
    wget https://downloads.arduino.cc/arduino-1.8.3-linux64.tar.xz
  fi
  tar xf arduino-1.8.3-linux64.tar.xz
  (cd arduino-1.8.3 && ln -sf ../../arduino-packages/packages packages)
  (cd .. && ln -sf arduino-ide/arduino-1.8.3 arduino-1.8.3)
fi
"""
            }

            dir ("cmake") {
                if (!fileExists('.git/config')) {
                    git branch: 'main', url: 'https://github.com/Conservify/cmake.git'
                }
                else {
                    sh "git checkout main && git pull origin main"
                }
            }

            dir ("bin") {
                if (!fileExists('simple-deps')) {
                    copyArtifacts(projectName: 'simple-deps', flatten: true)
                }
                if (!fileExists('fktool')) {
                    copyArtifacts(projectName: 'fk/cloud', flatten: true)
                }
            }
        }
    }

    return
}
