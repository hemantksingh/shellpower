.PHONY: build package push test

APPLICATION?=iisconfig
BUILD_NUMBER?=0
APP_VERSION?=1.0.$(BUILD_NUMBER)-alpha
PUBLISH_DIR=${CURDIR}/$(APPLICATION)/out
PACKAGES_DIR=${CURDIR}/$(APPLICATION)/packages
PACKAGE=shellpower.$(APPLICATION).$(APP_VERSION)
NUGET_SOURCE=https://api.nuget.org/v3/index.json

build:
	powershell "If(!(test-path $(PUBLISH_DIR))) { New-Item -ItemType Directory -Force -Path $(PUBLISH_DIR)}"
	cp $(APPLICATION)/src/* $(PUBLISH_DIR)
	
package: build
	powershell ./$(APPLICATION)/nuget/nugetpack.ps1 \
	-application $(APPLICATION) \
	-version $(APP_VERSION) \
	-publishDir $(PUBLISH_DIR)

push: 
	nuget push ${CURDIR}/$(PACKAGE).nupkg \
	-Source $(NUGET_SOURCE) \
	-ApiKey $(NUGET_KEY)

test:
	nuget install shellpower.$(APPLICATION) \
	-version $(APP_VERSION) \
	-OutputDirectory $(PACKAGES_DIR) \
	-source $(NUGET_SOURCE)
	powershell $(APPLICATION)/tests/testwebapp.ps1 -packages $(PACKAGES_DIR)/$(PACKAGE)
	