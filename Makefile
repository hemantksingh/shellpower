.PHONY: build package

APPLICATION?=iisconfig
BUILD_NUMBER?=0
APP_VERSION?=1.0.$(BUILD_NUMBER)-alpha
PUBLISH_DIR=${CURDIR}/out/$(APPLICATION)
NUGET_SOURCE=https://api.nuget.org/v3/index.json

define create-dir
	@powershell.exe "If(!(test-path $(1))) {\
		echo Creating dir $(1)\
		New-Item -ItemType Directory -Force -Path $(1)}"
endef

build:
	powershell "If(!(test-path $(PUBLISH_DIR))) { New-Item -ItemType Directory -Force -Path $(PUBLISH_DIR)}"
	cp $(APPLICATION)/src/* $(PUBLISH_DIR)
	
package: build
	powershell ./$(APPLICATION)/nuget/nugetpack.ps1 \
	-application $(APPLICATION) \
	-version $(APP_VERSION) \
	-publishDir $(PUBLISH_DIR)

push: 
	nuget push ${CURDIR}/shellpower.$(APPLICATION).$(APP_VERSION).nupkg \
	-Source $(NUGET_SOURCE) \
	-ApiKey $(NUGET_KEY)