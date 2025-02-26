#!/bin/bash

# Ref:
# https://docs.oracle.com/en/learn/oci-iam-config-initial-tenancy/
# https://community.oracle.com/customerconnect/discussion/648453/regaining-access-to-tenancy-lost-access-to-tenancy

#Update the below with details for the environment
tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaabowwb3qlgdwvmp6etejj5cr5cvio7fp54ohbjcaxzsnjtneimkha"

#Group names
tenancy_manager_group=TenancyManagers
pol_admin_group=PolicyAdmins
sec_admin_group=SecurityAdmin
sec_analyst_group=SecurityAnalysts

#All_Users_Policy
oci iam policy create -c $tenancy_ocid --name "All_Users_Policy" \
--description "General purpose permissions intended for all users of the tenancy." \
--statements "[\"allow any-user to inspect tag-defaults in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\", \
              \"allow any-user to inspect limits in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\", \
              \"allow any-user to inspect tenancies in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\", \
              \"allow any-user to inspect compartments in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\", \
              \"allow any-user to read policies in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\", \
              \"allow any-user to read objectstorage-namespaces in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\", \
              \"allow any-user to read announcements in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\", \
              \"allow any-user to use cloud-shell in tenancy where all{ request.domain.name = 'default', request.principal.type = 'user' }\"]"

#Tenancy Managers
oci iam group create --name $tenancy_manager_group \
--description "Group for Tenancy Managers for OCI, who can manage tenancy-level constructs, such as budgets and regions."

oci iam policy create -c $tenancy_ocid --name "Tenancy_Managers_Policy" \
  --description "Policy statements which define the 'Tenancy Manager' role, which allows for managing tenancy-level configuration and objects." \
  --statements "[\"define tenancy usage-report as ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq\", \
                \"allow group ${tenancy_manager_group} to read usage-report in tenancy\", \
                \"allow group ${tenancy_manager_group} to read resource-availability in tenancy\", \
                \"allow group ${tenancy_manager_group} to manage quotas in tenancy\", \
                \"allow group ${tenancy_manager_group} to manage tenancies in tenancy\", \
                \"allow group ${tenancy_manager_group} to manage objectstorage-namespaces in tenancy\", \
                \"allow group ${tenancy_manager_group} to manage buckets in tenancy where request.operation = 'UpdateNamespaceMetadata'\", \
                \"allow group ${tenancy_manager_group} to manage usage-budgets in tenancy\", \
                \"allow group ${tenancy_manager_group} to manage organizations-family in tenancy\", \
                \"allow group ${tenancy_manager_group} to {AUDIT_CONFIGURATION} in tenancy\", \
                \"endorse group ${tenancy_manager_group} to read objects in tenancy usage-report\"]"

#Policy Admins
oci iam group create --name $pol_admin_group \
--description "Group for Policy Administrators for OCI, who create and maintain IAM Policies and supporting resources."

oci iam policy create -c $tenancy_ocid --name "Policy_Admins_Policy" \
--description "Policy statements which define the 'Policy Admin' role, who create and maintain IAM Policies and supporting resources." \
--statements "[\"allow group ${pol_admin_group} to inspect groups in tenancy\", \
              \"allow group ${pol_admin_group} to read users in tenancy\", \
              \"allow group ${pol_admin_group} to manage groups in tenancy where target.group.name != 'Administrators'\", \
              \"allow group ${pol_admin_group} to manage compartments in tenancy\", \
              \"allow group ${pol_admin_group} to manage dynamic-groups in tenancy\", \
              \"allow group ${pol_admin_group} to manage domains in tenancy where request.permission != 'DOMAIN_RESOURCES_ADMINISTER'\", \
              \"allow group ${pol_admin_group} to manage network-sources in tenancy\", \
              \"allow group ${pol_admin_group} to manage policies in tenancy\", \
              \"allow group ${pol_admin_group} to manage tag-namespaces in tenancy\", \
              \"allow group ${pol_admin_group} to manage iamworkrequests in tenancy\"]"

#Security Admin
oci iam group create --name $sec_admin_group \
--description "Group for Security Admins for OCI, who can manage Cloud Guard and Data Safe"

oci iam policy create -c $tenancy_ocid --name "Security_Admins_Policy" \
  --description "Policy statements which define the 'Security Admin' role, which allows for managing Cloud Guard and Data Safe." \
  --statements "[\"allow group ${sec_admin_group} to inspect groups in tenancy\", \
                \"allow group ${sec_admin_group} to read repos in tenancy\", \
                \"allow group ${sec_admin_group} to manage cloud-guard-family in tenancy\", \
                \"allow group ${sec_admin_group} to manage data-safe in tenancy\"]"

#Security Analyst
oci iam group create --name $sec_analyst_group \
--description "Group for Security Analysts for OCI, which provides read access to resources in the tenancy, and the ability to use Cloud Guard"

oci iam policy create -c $tenancy_ocid --name "Security_Analysts_Policy" \
  --description "Policy statements which define the 'Security Analyst' role, which allows for read access to the tenancy, and the ability to work with Cloud Guard." \
  --statements "[\"allow group ${sec_analyst_group} to read all-resources in tenancy\", \
                \"allow group ${sec_analyst_group} to read audit-events in tenancy\", \
                \"allow group ${sec_analyst_group} to read cloud-guard-family in tenancy\", \
                \"allow group ${sec_analyst_group} to use cloud-guard-config in tenancy\", \
                \"allow group ${sec_analyst_group} to manage cloud-guard-detectors in tenancy\", \
                \"allow group ${sec_analyst_group} to manage cloud-guard-problems in tenancy\", \
                \"allow group ${sec_analyst_group} to manage cloud-guard-detector-recipes in tenancy\", \
                \"allow group ${sec_analyst_group} to manage cloud-guard-managed-lists in tenancy\", \
                \"allow group ${sec_analyst_group} to manage cloud-guard-user-preferences in tenancy\"]"
