WD := $(shell pwd)
PROJECT_DIR := $(WD)/notification_demo
PYTHON_FOR_ANDROID := $(WD)/python-for-android
PYTHON_FOR_ANDROID_PACKAGE := $(PYTHON_FOR_ANDROID)/dist/default
VENV := $(WD)/venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

# Android settings
APK_PACKAGE := net.clusterbleep.notificationdemo
APP_NAME := "Kivy Notification Demo"
APK_NAME := KivyNotificationDemo
APK_VERSION := 0.1
APK_ORIENTATION := portrait
APK_ICON := $(PROJECT_DIR)/resources/icon.png
APK_PRESPLASH := $(PROJECT_DIR)/resources/presplash.jpg
APK_DEBUG := $(PYTHON_FOR_ANDROID_PACKAGE)/bin/$(APK_NAME)-$(APK_VERSION)-debug.apk
APK_RELEASE := $(PYTHON_FOR_ANDROID_PACKAGE)/bin/$(APK_NAME)-$(APK_VERSION)-release-unsigned.apk
APK_FINAL := $(PYTHON_FOR_ANDROID_PACKAGE)/bin/$(APK_NAME).apk
APK_KEYSTORE := ~/Dropbox/Secure/net-clusterbleep-saythis-release.keystore
APK_ALIAS := cb-play

# Dropbox
DROPBOX := /home/brousch/Dropbox/Files/APKs/

.PHONY: run
run:
	cd $(PROJECT_DIR); \
	$(PY) main.py

.PHONY: inspect
inspect:
	cd $(PROJECT_DIR); \
	python main.py -m inspect

# Setup
.PHONY: install_system_packages
install_system_packages:
	sudo apt-get update
	cat system-packages-kivy.txt | xargs sudo apt-get -y install

.PHONY: create_virtualenv
create_virtualenv:
	virtualenv -p python2.7 --system-site-packages $(VENV)

.PHONY: initialize_virtualenv
initialize_virtualenv: install_cython install_kivy_dev

.PHONY: install_cython
install_cython:
	$(PIP) install -U -r requirements-cython.txt

.PHONY: install_kivy_dev
install_kivy_dev:
	$(PIP) install -U -r requirements-kivy-dev.txt

.PHONY: refresh_python_for_android
refresh_python_for_android: clone_py4a create_py4a_distribution

.PHONY: clone_py4a
clone_py4a:
	rm -rf $(PYTHON_FOR_ANDROID)
	git clone https://github.com/kivy/python-for-android.git

.PHONY: create_py4a_distribution
create_py4a_distribution:
	rm -rf $(PYTHON_FOR_ANDROID)/dist
	source $(VENV)/bin/activate; \
	cd $(PYTHON_FOR_ANDROID); \
	./distribute.sh -m "kivy"
	
# Android commands
.PHONY: package_android
package_android:
	cd $(PYTHON_FOR_ANDROID_PACKAGE); \
	$(PY) ./build.py --package $(APK_PACKAGE) --name $(APP_NAME) --version $(APK_VERSION) --orientation $(APK_ORIENTATION) --icon $(APK_ICON) --presplash $(APK_PRESPLASH) --dir $(PROJECT_DIR) debug

.PHONY: package_android_release
package_android_release:
	cd $(PYTHON_FOR_ANDROID_PACKAGE); \
	$(PY) ./build.py --package $(APK_PACKAGE) --name $(APP_NAME) --version $(APK_VERSION) --orientation $(APK_ORIENTATION) --icon $(APK_ICON) --presplash $(APK_PRESPLASH) --dir $(PROJECT_DIR) release
	make sign_android

.PHONY: install_android
install_android:
	adb install -r $(APK_DEBUG)

.PHONY: sign_android
sign_android:
	rm -f $(APK_FINAL)
	jarsigner -verbose -sigalg MD5withRSA -digestalg SHA1 -keystore $(APK_KEYSTORE) $(APK_RELEASE) $(APK_ALIAS)
	zipalign -v 4 $(APK_RELEASE) $(APK_FINAL)

.PHONY: dropbox
dropbox:
	cp $(APK_DEBUG) $(DROPBOX)
