# dt-starter-kit-creation-script
This Perl script assists in the set-up of the Digital Twin Starter Kit.  It will attempt to create instances of Predix services (such as predix-uaa, postgres, timeseries, analytics-catalog, and rabbit-mq) and will wire them together.  It will create clients, groups, and users in the UAA service.  It will also add the appropriate scopes to the authorities of the clients.  Note: this script will not add the "redirect_url" to the tutorial-user UAA client since that would create a dependency on having pushed the vis app; after the vis app gets pushed, the user may use the UAAC command-line client to update the client via this command:
```
uaac client update tutorial-user --redirect_uri "<redirect_url_1>","<redirect_url_2>"
```

## Software Prerequisites
- Perl - See http://strawberryperl.com/
- Cloud Foundry command-line client - See https://docs.cloudfoundry.org/cf-cli/install-go-cli.html
- UAAC - UAA Command-line client - See https://github.com/cloudfoundry/cf-uaac

## Use the CloudFoundry client to:
- Set your target via "cf target <api-endpoint>"
- Login and set your org and space via "cf login"
- Make sure you have an application in CloudFoundry to bind your services to.  If you don't, then you can create a dummy application by entering an empty directory and pushing a named application from that empty directory like this: ```cf push myapp```

## Edit create-dt-starter-kit.pl
- On the first line, modify the path to Perl as appropriate for your environment
- At the top of the "dt_starter_kit_create" subroutine, modify the local variables as appropriate

## Run it!
From a Windows command prompt (same instance as above will suffice), make sure your proxy is set appropriately and then run the "create-dt-starter-kit.pl" script by typing its name on the command line.

```
D:\Projects2016\dt-starter-kit-creation-script>create-dt-starter-kit.pl
create_uaa_instance
        executing: cf create-service predix-uaa Tiered scripted-predix-uaa -c "{\"adminClientSecret\":\"********\"}"
        output: Creating service instance scripted-predix-uaa in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

bind_service_instance_to_application
        executing: cf bind-service myapp scripted-predix-uaa
        output: Binding service scripted-predix-uaa to app myapp in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK
TIP: Use 'cf restage myapp' to ensure your env variable changes take effect

get_environment_variables
        executing: cf env myapp
        retrieved environment variables
get_service_instance_env_vars
        looking for 'scripted-predix-uaa' in 'predix-uaa'
        number of instances: 4
                inspecting digitaltwin-predix-uaa
                inspecting digitaltwin-predix-uaa-test
                inspecting dt-predix-uaa
                inspecting scripted-predix-uaa
                        Found instance of scripted-predix-uaa
create_service_instance
        executing: cf create-service predix-timeseries Tiered scripted-timeseries -c "{\"trustedIssuerIds\":[\"https://some-guid.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token\"]}"
        output: Creating service instance scripted-timeseries in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

bind_service_instance_to_application
        executing: cf bind-service myapp scripted-timeseries
        output: Binding service scripted-timeseries to app myapp in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK
TIP: Use 'cf restage myapp' to ensure your env variable changes take effect

create_service_instance
        executing: cf create-service predix-analytics-catalog Bronze scripted-analytics-catalog -c "{\"trustedIssuerIds\":[\"https://some-guid.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token\"]}"
        output: Creating service instance scripted-analytics-catalog in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

bind_service_instance_to_application
        executing: cf bind-service myapp scripted-analytics-catalog
        output: Binding service scripted-analytics-catalog to app myapp in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK
TIP: Use 'cf restage myapp' to ensure your env variable changes take effect

get_environment_variables
        executing: cf env myapp
        retrieved environment variables
get_service_instance_env_vars
        looking for 'scripted-timeseries' in 'predix-timeseries'
        number of instances: 3
                inspecting rdt-turbine-data
                inspecting rdt-ts
                inspecting scripted-timeseries
                        Found instance of scripted-timeseries
get_service_instance_env_vars
        looking for 'scripted-analytics-catalog' in 'predix-analytics-catalog'
        number of instances: 4
                inspecting digitaltwin-analytics-catalog
                inspecting rdt-analytics-catalog
                inspecting hc-dt-analytic-catalog
                inspecting scripted-analytics-catalog
                        Found instance of scripted-analytics-catalog
create_service_instance
        executing: cf create-service postgres shared-nr scripted-postgres
        output: Creating service instance scripted-postgres in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

bind_service_instance_to_application
        executing: cf bind-service myapp scripted-postgres
        output: Binding service scripted-postgres to app myapp in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK
TIP: Use 'cf restage myapp' to ensure your env variable changes take effect

create_service_instance
        executing: cf create-service rabbitmq-36 standard scripted-rabbitmq-36
        output: Creating service instance scripted-rabbitmq-36 in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

bind_service_instance_to_application
        executing: cf bind-service myapp scripted-rabbitmq-36
        output: Binding service scripted-rabbitmq-36 to app myapp in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK
TIP: Use 'cf restage myapp' to ensure your env variable changes take effect

uaac_target
        executing: uaac target https://some-guid.predix-uaa.run.aws-usw02-pr.ice.predix.io --skip-ssl-validation
        output:
Target: https://some-guid.predix-uaa.run.aws-usw02-pr.ice.predix.io


uaac_token_client_get_admin
        executing: uaac token client get admin -s ********
        output:
Successfully fetched token via client credentials grant.
Target: https://some-guid.predix-uaa.run.aws-usw02-pr.ice.predix.io
Context: admin, from client admin


uaac_client_add
        authorities: "timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.user","timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.ingest","timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.user","timeseries.zones.3be68f29-0a33-49
23-934c-7e0d59d43cde.query","analytics.zones.ab59ed64-6854-4b80-a3f0-53336e2bbcf9.user"
        grant types: "client_credentials"
        executing: uaac client add tutorial-svcs --secret tutorial-svcs-password --authorized_grant_types "client_credentials" --authorities "timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.user","timeseries.zones.3be68f29-0a33-4923-9
34c-7e0d59d43cde.ingest","timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.user","timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.query","analytics.zones.ab59ed64-6854-4b80-a3f0-53336e2bbcf9.user"
        output:   scope: uaa.none
  client_id: tutorial-svcs
  resource_ids: none
  authorized_grant_types: client_credentials
  autoapprove:
  action: none
  authorities: timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.query timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d43cde.user analytics.zones.ab59ed64-6854-4b80-a3f0-53336e2bbcf9.user timeseries.zones.3be68f29-0a33-4923-934c-7e0d59d
43cde.ingest
  name: tutorial-svcs
  lastmodified: 1470070287306
  id: tutorial-svcs

uaac_client_add
        authorities: "uaa.resource"
        grant types: "refresh_token","password","authorization_code"
        executing: uaac client add tutorial-user --secret tutorial-user-password --authorized_grant_types "refresh_token","password","authorization_code" --authorities "uaa.resource"
        output:   scope: uaa.none
  client_id: tutorial-user
  resource_ids: none
  authorized_grant_types: refresh_token password authorization_code
  autoapprove:
  action: none
  authorities: uaa.resource
  name: tutorial-user
  lastmodified: 1470070290506
  id: tutorial-user

uaac_user_add
        executing: uaac user add tutorialuser --password tutorialuser-password --emails "tutorialuser@nowhere.com"
        output: user account successfully added

uaac_user_add
        executing: uaac user add tutorialadmin --password tutorialadmin-password --emails "tutorialadmin@nowhere.com"
        output: user account successfully added

uaac_group_add
        executing: uaac group add tutorial.user
        output:   meta
    version: 0
    created: 2016-08-01T16:51:40.088Z
    lastmodified: 2016-08-01T16:51:40.088Z
  schemas: urn:scim:schemas:core:1.0
  id: 74a7961e-272f-4096-b97a-29dbed42a81e
  displayname: tutorial.user
  zoneid: some-guid

uaac_group_add
        executing: uaac group add tutorial.admin
        output:   meta
    version: 0
    created: 2016-08-01T16:51:43.331Z
    lastmodified: 2016-08-01T16:51:43.331Z
  schemas: urn:scim:schemas:core:1.0
  id: 4f346f87-4fca-431d-86f6-b9c8411ae00e
  displayname: tutorial.admin
  zoneid: some-guid

uaac_member_add
        executing: uaac member add tutorial.user tutorialuser
        output: success

uaac_member_add
        executing: uaac member add tutorial.admin tutorialadmin
        output: success

uaac_member_add
        executing: uaac member add tutorial.user tutorialadmin
        output: success
```

## Cleaning up...
There's a clean-up utility that can be invoked by command-line option, "-clean", that will unbind and delete the created services.  It's handy for script development/maintenance.

```
D:\Projects2016\dt-starter-kit-creation-script>create-dt-starter-kit.pl -clean
unbind_and_delete_service
        executing: cf unbind-service myapp scripted-predix-uaa
        output: Unbinding app myapp from service scripted-predix-uaa in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

        executing: cf delete-service -f scripted-predix-uaa
        output: Deleting service scripted-predix-uaa in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

unbind_and_delete_service
        executing: cf unbind-service myapp scripted-postgres
        output: Unbinding app myapp from service scripted-postgres in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

        executing: cf delete-service -f scripted-postgres
        output: Deleting service scripted-postgres in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

unbind_and_delete_service
        executing: cf unbind-service myapp scripted-timeseries
        output: Unbinding app myapp from service scripted-timeseries in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

        executing: cf delete-service -f scripted-timeseries
        output: Deleting service scripted-timeseries in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

unbind_and_delete_service
        executing: cf unbind-service myapp scripted-rabbitmq-36
        output: Unbinding app myapp from service scripted-rabbitmq-36 in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

        executing: cf delete-service -f scripted-rabbitmq-36
        output: Deleting service scripted-rabbitmq-36 in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

unbind_and_delete_service
        executing: cf unbind-service myapp scripted-analytics-catalog
        output: Unbinding app myapp from service scripted-analytics-catalog in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK

        executing: cf delete-service -f scripted-analytics-catalog
        output: Deleting service scripted-analytics-catalog in org DigitalTwin / space dev as address@mail.ad.ge.com...
OK
```
