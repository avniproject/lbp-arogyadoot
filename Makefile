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
server_url:=$(server):$(port)
su:=$(shell id -un)
org_name=Lokbiradari Prakalp
org_admin_name=lbp-admin

poolId:=
clientId:=
username:=lbp-admin
password:=

auth:
	$(if $(poolId),$(eval token:=$(shell node scripts/token.js $(poolId) $(clientId) $(username) $(password))))
	echo $(token)

auth_live:
	make auth poolId=$(OPENCHS_PROD_USER_POOL_ID) clientId=$(OPENCHS_PROD_APP_CLIENT_ID) username=lbp-admin password=$(OPENCHS_PROD_ADMIN_USER_PASSWORD)

define _curl
	curl -X $(1) $(server_url)/$(2) -d $(3)  \
		-H "Content-Type: application/json"  \
		-H "USER-NAME: $(org_admin_name)"  \
		$(if $(token),-H "AUTH-TOKEN: $(token)",)
	@echo
	@echo
endef

define _curl_as_openchs
	curl -X $(1) $(server_url)/$(2) -d $(3)  \
		-H "Content-Type: application/json"  \
		-H "USER-NAME: admin"  \
		$(if $(token),-H "AUTH-TOKEN: $(token)",)
	@echo
	@echo
endef

# <create_org>
create_org: ## Create Lokbiradari Prakalp org and user+privileges
	psql -U$(su) openchs < create_organisation.sql
# </create_org>


deploy_checklists:
	$(call _curl,POST,forms,@child/checklistForm.json)
	$(call _curl,POST,checklistDetail,@child/checklist.json)



# <deploy>
deploy_org_data:
	$(call _curl,POST,locations,@locations.json)
	$(call _curl,POST,catchments,@catchments.json)

create_admin_user:
	$(call _curl_as_openchs,POST,users,@admin-user.json)

create_admin_user_dev:
	$(call _curl_as_openchs,POST,users,@users/dev-admin-user.json)

create_users_dev:
	$(call _curl,POST,users,@users/dev-users.json)

create_users:
	$(call _curl,POST,users,@users/users.json)

deploy_org_data_live:
	make auth deploy_org_data poolId=$(STAGING_USER_POOL_ID) clientId=$(STAGING_APP_CLIENT_ID) username=lbp-admin password=$(STAGING_ADMIN_USER_PASSWORD)

_deploy_refdata:
	$(call _curl,POST,concepts,@concepts.json)
	$(call _curl,POST,forms,@registrationForm.json)
	$(call _curl,POST,operationalEncounterTypes,@operationalModules/operationalEncounterTypes.json)
	$(call _curl,POST,operationalPrograms,@operationalModules/operationalPrograms.json)
	$(call _curl,DELETE,forms,@mother/enrolmentDeletions.json)
	$(call _curl,PATCH,forms,@mother/deliveryAdditions.json)
	$(call _curl,DELETE,forms,@child/exitDeletions.json)
	$(call _curl,PATCH,forms,@mother/enrolmentAdditions.json)
	$(call _curl,PATCH,forms,@mother/pncAdditions.json)
	$(call _curl,DELETE,forms,@mother/ancDeletions.json)
	$(call _curl,PATCH,forms,@mother/ancAdditions.json)

deploy_rules:
	node index.js "$(server_url)" "$(token)" "$(username)"

deploy_rules_live:
	make auth deploy_rules poolId=$(OPENCHS_PROD_USER_POOL_ID) clientId=$(OPENCHS_PROD_APP_CLIENT_ID) username=lbp-admin password=$(password) server=https://server.openchs.org port=443

deploy_refdata: deploy_org_data _deploy_refdata

deploy: create_admin_user_dev deploy_refdata deploy_checklists deploy_rules create_users_dev##

_deploy_prod: deploy_refdata deploy_checklists deploy_rules

deploy_prod:
#	there is a bug in server side. which sets both isAdmin, isOrgAdmin to be false. it should be done. also metadata upload should not rely on isAdmin role.
#	need to be fixed. then uncomment the following line.
#	make auth deploy_admin_user poolId=ap-south-1_DU27AHJvZ clientId=1d6rgvitjsfoonlkbm07uivgmg server=https://server.openchs.org port=443 username=admin password=
	make auth _deploy_prod poolId=$(OPENCHS_PROD_USER_POOL_ID) clientId=$(OPENCHS_PROD_APP_CLIENT_ID) server=https://server.openchs.org port=443 username=lbp-admin password=$(password)


create_deploy: create_org deploy ##

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

set_lbp_prod_auth:
	$(eval poolId:=$(OPENCHS_LBP_PROD_USER_POOL_ID))
	$(eval clientId:=$(OPENCHS_LBP_PROD_APP_CLIENT_ID))

as_admin:
	$(eval username:=admin)

as_org_admin:
	$(eval username:=$(org_admin_name))

#18021 is port forwared TO in-premise machine
#start tunneling before running any of the following commands
inpremise_create_admin_with_prod_auth:
	make set_lbp_prod_auth as_admin auth create_admin_user password=$(password) server=http://localhost port=18021

inpremise_deploy_with_prod_auth:
	make set_lbp_prod_auth as_org_admin auth _deploy_prod password=$(password) server=http://localhost port=18021

inpremise_deploy_refdata_with_prod_auth:
	make set_lbp_prod_auth as_org_admin auth deploy_refdata password=$(password) server=http://localhost port=18021

inpremise_deploy_checklists_with_prod_auth:
	make set_lbp_prod_auth as_org_admin auth deploy_checklists password=$(password) server=http://localhost port=18021

inpremise_deploy_rules_with_prod_auth:
	make set_lbp_prod_auth as_org_admin auth deploy_rules password=$(password) server=http://localhost port=18021

inpremise_create_users_with_prod_auth:
	make set_lbp_prod_auth as_org_admin auth create_users password=$(password) server=http://localhost port=18021
