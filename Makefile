.PHONY: build package push test

APPLICATION?=iisconfig
BUILD_NUMBER?=10
APP_VERSION?=1.0.$(BUILD_NUMBER)
PUBLISH_DIR=${CURDIR}/$(APPLICATION)/out
PACKAGES_DIR=${CURDIR}/$(APPLICATION)/packages
PACKAGE=shellpower.$(APPLICATION).$(APP_VERSION)
NUGET_SOURCE=https://api.nuget.org/v3/index.json
GIT_COMMIT?=af39e9091be8c6beacd3d33b6afd4dd2e0133839

clean:
	git clean -xfd

build: clean
	powershell "If(!(test-path $(PUBLISH_DIR))) { New-Item -ItemType Directory -Force -Path $(PUBLISH_DIR)}"
	cp -r $(APPLICATION)/src/* $(PUBLISH_DIR)
	
package: build
	powershell ./$(APPLICATION)/nuget/nugetpack.ps1 \
	-application $(APPLICATION) \
	-version $(APP_VERSION) \
	-publishDir $(PUBLISH_DIR) \
	-gitCommit $(GIT_COMMIT)

push: package
	nuget push ${CURDIR}/$(PACKAGE).nupkg \
	-Source $(NUGET_SOURCE) \	
	-ApiKey $(NUGET_KEY)

install:
	nuget install shellpower.$(APPLICATION) \
	-version $(APP_VERSION) \
	-outputdirectory $(PACKAGES_DIR) \
	-source $(NUGET_SOURCE) \
	-nocache

#WIN_USER?=example\win-user
DBSERVER?=localhost
TRUSTED_CONNECTION?=true
SOURCE=$(PACKAGES_DIR)/$(PACKAGE)/bin
test:
ifeq ($(APPLICATION), iisconfig)
	powershell $(APPLICATION)/tests/runtests.ps1
else ifeq ($(APPLICATION), sqlserver)
	powershell "$(APPLICATION)/tests/sqlservertest.ps1 -dbServer \"$(DBSERVER)\" -winUser \"$(WIN_USER)\""
	powershell "$(APPLICATION)/tests/sqlcmdtest.ps1 -dbServer \"$(DBSERVER)\" -useTrustedConnection $(TRUSTED_CONNECTION)"
else
	@echo Unknown app $(APPLICATION)
endif

test-package:package install
ifeq ($(APPLICATION), iisconfig)
	powershell $(APPLICATION)/tests/runtests.ps1 -source $(SOURCE)
else ifeq ($(APPLICATION), sqlserver)
	powershell "$(APPLICATION)/tests/sqlservertest.ps1 -dbServer \"$(DBSERVER)\" -winUser \"$(WIN_USER)\" -source $(SOURCE)"
	powershell "$(APPLICATION)/tests/sqlcmdtest.ps1 -dbServer \"$(DBSERVER)\" -useTrustedConnection $(TRUSTED_CONNECTION) -source $(SOURCE)"
else
	@echo Unknown app $(APPLICATION)
endif