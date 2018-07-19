# <makefile>
# Objects: refdata, package
# Actions: clean, build, deploy
help:
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
	    IFS=$$'#' ; \
	    help_split=($$help_line) ; \
	    help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    printf "%-30s %s\n" $$help_command $$help_info ; \
	done
# </makefile>

port:= $(if $(port),$(port),8021)
server:= $(if $(server),$(server),http://localhost)

su:=$(shel`l id -un)
org_name=Lokbiradari Prakalp

token:=
poolId:=
clientId:=
username:=
password:=

auth:
	$(if $(poolId),$(eval token:=$(shell node scripts/token.js $(poolId) $(clientId) $(username) $(password))))

define _curl
	curl -X $(1) $(server):$(port)/$(2) -d $(3)  \
		-H "Content-Type: application/json"  \
		-H "ORGANISATION-NAME: $(org_name)"  \
		-H "AUTH-TOKEN: $(token)"
	@echo
	@echo
endef

# <create_org>
create_org: ## Create Lokbiradari Prakalp org and user+privileges
	psql -U$(su) openchs < create_organisation.sql
# </create_org>

# <deploy>
deploy_org_data:
	$(call _curl,POST,catchments,@catchments.json)

deploy_org_data_live:
	make auth deploy_org_data poolId=$(STAGING_USER_POOL_ID) clientId=$(STAGING_APP_CLIENT_ID) username=admin password=$(STAGING_ADMIN_USER_PASSWORD)

_deploy_refdata:
	$(call _curl,POST,concepts,@concepts.json)
	$(call _curl,POST,forms,@registrationForm.json)
	$(call _curl,POST,operationalEncounterTypes,@operationalModules/operationalEncounterTypes.json)
	$(call _curl,POST,operationalPrograms,@operationalModules/operationalPrograms.json)
	$(call _curl,DELETE,forms,@mother/enrolmentDeletions.json)
	$(call _curl,DELETE,forms,@child/exitDeletions.json)
	$(call _curl,PATCH,forms,@mother/enrolmentAdditions.json)
	$(call _curl,PATCH,forms,@mother/pncAdditions.json)
	node index.js

deploy_refdata: deploy_org_data _deploy_refdata

deploy: create_org deploy_refdata

create_deploy: create_org deploy_refdata ##

deploy_refdata_live:
	make auth _deploy_refdata poolId=$(STAGING_USER_POOL_ID) clientId=$(STAGING_APP_CLIENT_ID) username=lbp-admin password=$(STAGING_LBP_ADMIN_USER_PASSWORD)
# </deploy>

# <package>
build_package: ## Builds a deployable package
	rm -rf output/impl
	mkdir -p output/impl
	cp registrationForm.json catchments.json deploy.sh output/impl
	cd output/impl && tar zcvf ../openchs_impl.tar.gz *.*
# </package>

deps:
	npm i