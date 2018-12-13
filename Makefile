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

push: package
	nuget push ${CURDIR}/$(PACKAGE).nupkg \
	-Source $(NUGET_SOURCE) \
	-ApiKey $(NUGET_KEY)

install:
	nuget install shellpower.$(APPLICATION) \
	-version $(APP_VERSION) \
	-outputdirectory $(PACKAGES_DIR) \
	-source $(NUGET_SOURCE)

test:
	powershell $(APPLICATION)/tests/iisconfigtest.ps1 -source $(APPLICATION)/src

DBSERVER?=localhost
test-sqlserver:
	powershell "$(APPLICATION)/tests/sqlservertest.ps1 -dbServer \"$(DBSERVER)\""
	powershell "$(APPLICATION)/tests/sqlcmdtest.ps1 -dbServer \"$(DBSERVER)\""

test-package:install
	powershell $(APPLICATION)/tests/iisconfigtest.ps1 -source $(PACKAGES_DIR)/$(PACKAGE)/bin

