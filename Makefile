.PHONY: build package push test

APPLICATION?=iisconfig
BUILD_NUMBER?=6
APP_VERSION?=1.0.$(BUILD_NUMBER)-rc1
PUBLISH_DIR=${CURDIR}/$(APPLICATION)/out
PACKAGES_DIR=${CURDIR}/$(APPLICATION)/packages
PACKAGE=shellpower.$(APPLICATION).$(APP_VERSION)
NUGET_SOURCE=https://api.nuget.org/v3/index.json
GIT_COMMIT?=cc7c38664503e7247f76f53ce9b8e427163a507f

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
	-source $(NUGET_SOURCE)

#WIN_USER?=example\win-user
DBSERVER?=localhost
TRUSTED_CONNECTION?=true

test:
ifeq ($(APPLICATION), iisconfig)
	powershell $(APPLICATION)/tests/iisconfigtest.ps1
else ifeq ($(APPLICATION), sqlserver)
	powershell "$(APPLICATION)/tests/sqlservertest.ps1 -dbServer \"$(DBSERVER)\" -winUser \"$(WIN_USER)\""
	powershell "$(APPLICATION)/tests/sqlcmdtest.ps1 -dbServer \"$(DBSERVER)\" -useTrustedConnection $(TRUSTED_CONNECTION)"
else
	@echo Unknown app $(APPLICATION)
endif

test-package:package install
ifeq ($(APPLICATION), iisconfig)
	powershell $(APPLICATION)/tests/iisconfigtest.ps1 -source $(PACKAGES_DIR)/$(PACKAGE)/bin
endif