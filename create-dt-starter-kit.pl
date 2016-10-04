#!/bin/perl

use JSON qw(decode_json);


#####################################################################################
############################### Start of MAIN  ######################################
#####################################################################################
dt_starter_kit_create($ARGV[0]);
#####################################################################################
################################ End of MAIN  #######################################
#####################################################################################



############################### DT_STARTER_KIT #######################################

# Creates service instances and binds them to an application.
# Creates clients, users, and groups.
# Adds zones to the approiriate client authorities
sub dt_starter_kit_create() {
  my($my_application_name) = "myapp";

  my($uaa_instance_name) = "scripted-predix-uaa";
  my($uaa_admin_secret) = "pa55w0rd";
  my($uaa_plan) = "Tiered";

  my($postgres_instance_name) = "scripted-postgres";
  my($postgres_plan) = "shared-nr";

  my($timeseries_instance_name) = "scripted-timeseries";
  my($timeseries_plan) = "Tiered";

  my($analytics_catalog_instance_name) = "scripted-analytics-catalog";
  my($analytics_catalog_plan) = "Bronze";

  my($rabbitmq_36_instance_name) = "scripted-rabbitmq-36";
  my($rabbitmq_36_plan) = "standard";

  my($redis_instance_name) = "scripted-redis";
  my($redis_plan) = "shared-vm";

  my($client_name_tutorial_svcs) = "tutorial-svcs";
  my($client_secret_tutorial_svcs) = "tutorial-svcs-password";
  my($client_grant_types_tutorial_svcs) = "\"client_credentials\"";

  my($client_name_tutorial_user) = "tutorial-user";
  my($client_secret_tutorial_user) = "tutorial-user-password";
  my($client_grant_types_tutorial_user) = "\"refresh_token\",\"password\",\"authorization_code\"";

  my($user_name_tutorialuser) = "tutorial-user";
  my($user_secret_tutorialuser) = "tutorialuser-password";
  my($user_emails_tutorialuser) = "\"tutorialuser\@ge.com\"";

  my($user_name_tutorialadmin) = "tutorial-admin";
  my($user_secret_tutorialadmin) = "tutorialadmin-password";
  my($user_emails_tutorialadmin) = "\"tutorialadmin\@ge.com\"";

  my($group_name_tutorialuser) = "tutorial.user";
  my($group_name_tutorialadmin) = "tutorial.admin";

  my($clean) = shift();
  if ($clean eq "-clean") {
    dt_starter_kit_clean_up($my_application_name, $uaa_instance_name, $postgres_instance_name, $timeseries_instance_name, $rabbitmq_36_instance_name, $analytics_catalog_instance_name, $redis_instance_name);
    exit(0);
  }

  # create uaa instance and bind to app
  create_uaa_instance($uaa_plan, $uaa_instance_name, $uaa_admin_secret);
  bind_service_instance_to_application($uaa_instance_name, $my_application_name);

  # get uaa instance variables from the environment
  # $vcap_services_json, $vcap_application_json = get_environment_variables($my_application_name);
  $vcap_services_json = get_environment_variables($my_application_name);
  $uaa_instance_vars = get_service_instance_env_vars("predix-uaa", $uaa_instance_name, $vcap_services_json->{'VCAP_SERVICES'}{'predix-uaa'}, $vcap_services_json);

  # create timeseries instance and bind
  create_service_instance("predix-timeseries", $timeseries_plan, $timeseries_instance_name, "{\\\"trustedIssuerIds\\\":[\\\"" . $uaa_instance_vars->{'credentials'}{'uri'} . "/oauth/token\\\"]}");
  bind_service_instance_to_application($timeseries_instance_name, $my_application_name);

  # create analytics catalog and bind
  create_service_instance("predix-analytics-catalog", $analytics_catalog_plan, $analytics_catalog_instance_name, "{\\\"trustedIssuerIds\\\":[\\\"" . $uaa_instance_vars->{'credentials'}{'uri'} . "/oauth/token\\\"]}");
  bind_service_instance_to_application($analytics_catalog_instance_name, $my_application_name);

  # get timeseries and analytics catalog instance variables from the environment
  # $vcap_services_json, $vcap_application_json = get_environment_variables($my_application_name);
  $vcap_services_json = get_environment_variables($my_application_name);
  $timeseries_instance_vars = get_service_instance_env_vars("predix-timeseries", $timeseries_instance_name, $vcap_services_json->{'VCAP_SERVICES'}{'predix-timeseries'}, $vcap_services_json);
  $analytics_catalog_instance_vars = get_service_instance_env_vars("predix-analytics-catalog", $analytics_catalog_instance_name, $vcap_services_json->{'VCAP_SERVICES'}{'predix-analytics-catalog'}, $vcap_services_json);

  # create postgres instance and bind
  create_service_instance("postgres", $postgres_plan, $postgres_instance_name);
  bind_service_instance_to_application($postgres_instance_name, $my_application_name);

  # create rabbitMQ and bind
  create_service_instance("rabbitmq-36", $rabbitmq_36_plan, $rabbitmq_36_instance_name);
  bind_service_instance_to_application($rabbitmq_36_instance_name, $my_application_name);

  # create redis and bind
  create_redis_and_bind($redis_instance_name, $redis_plan, $my_application_name);

  # set the target uaa instance
  uaac_target($uaa_instance_vars->{'credentials'}{'uri'});

  # authenticate as the admin client
  uaac_token_client_get_admin($uaa_admin_secret);

  # add two groups
  uaac_group_add($group_name_tutorialuser);
  uaac_group_add($group_name_tutorialadmin);

  # add two clients
  uaac_client_add($client_name_tutorial_svcs, $client_secret_tutorial_svcs, "", $client_grant_types_tutorial_svcs, "\"uaa.resource\",\"" . $group_name_tutorialuser . "\",\"" . $group_name_tutorialadmin . "\",\"" . $timeseries_instance_vars->{'credentials'}{'ingest'}{'zone-token-scopes'}[0] . "\",\"" . $timeseries_instance_vars->{'credentials'}{'ingest'}{'zone-token-scopes'}[1] . "\",\"" . $timeseries_instance_vars->{'credentials'}{'query'}{'zone-token-scopes'}[0] . "\",\"" . $timeseries_instance_vars->{'credentials'}{'query'}{'zone-token-scopes'}[1] . "\",\"" . $analytics_catalog_instance_vars->{'credentials'}{'zone-oauth-scope'} . "\"", "");
  uaac_client_add($client_name_tutorial_user, $client_secret_tutorial_user, "\"" . $group_name_tutorialadmin . "\",\"" . $group_name_tutorialuser . "\"", $client_grant_types_tutorial_user, "\"uaa.resource\"", "\"" . $group_name_tutorialadmin . "\",\"" . $group_name_tutorialuser . "\"" );

  # add two users
  uaac_user_add($user_name_tutorialuser, $user_secret_tutorialuser, $user_emails_tutorialuser);
  uaac_user_add($user_name_tutorialadmin, $user_secret_tutorialadmin, $user_emails_tutorialadmin);

  # add members (users) to groups
  uaac_member_add($group_name_tutorialuser, $user_name_tutorialuser);
  uaac_member_add($group_name_tutorialadmin, $user_name_tutorialadmin);
  uaac_member_add($group_name_tutorialuser, $user_name_tutorialadmin);
}

# utility method to unbind and delete services
sub dt_starter_kit_clean_up() {
  my($app) = shift();
  my($uaa_service_instance) = shift();
  my($postgres_service_instance) = shift();
  my($timeseries_service_instance) = shift();
  my($rabbitmq_36_service_instance) = shift();
  my($analytics_catalog_service_instance) = shift();
  my($redis_service_instance) = shift();

  unbind_and_delete_service($app, $uaa_service_instance);
  unbind_and_delete_service($app, $postgres_service_instance);
  unbind_and_delete_service($app, $timeseries_service_instance);
  unbind_and_delete_service($app, $rabbitmq_36_service_instance);
  unbind_and_delete_service($app, $analytics_catalog_service_instance);
  unbind_and_delete_service($app, $redis_service_instance);
}
############################# DT_STARTER_KIT ######################################



sub unbind_and_delete_service() {
  print "unbind_and_delete_service\n";

  my($app) = shift();
  my($service) = shift();

  $command = 'cf unbind-service ' . $app . " " . $service;
  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";

  $command = 'cf delete-service -f ' . $service;
  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub create_uaa_instance() {
  print "create_uaa_instance\n";

  my($plan) = shift();
  my($instance_name) = shift();
  my($admin_secret) = shift();

  $command = 'cf create-service predix-uaa ' . $plan . " " . $instance_name . ' -c "{\"adminClientSecret\":\"' . $admin_secret . '\"}"';
  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub create_service_instance() {
  print "create_service_instance\n";

  my($service_type) = shift();
  my($plan) = shift();
  my($instance_name) = shift();
  my($config) = shift();

  $command = 'cf create-service ' . $service_type . " " . $plan . " " . $instance_name;
  if ($config ne "") {
    $command .= ' -c "' . $config . '"';
  }
  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub bind_service_instance_to_application() {
  print "bind_service_instance_to_application\n";

  my($service_instance) = shift();
  my($app) = shift();

  $command = 'cf bind-service ' . $app . " " . $service_instance;
  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub create_redis_and_bind() {
  print "create_redis_and_bind\n";

  my($redis_instance_name) = shift();
  my($redis_plan) = shift();
  my($app_name) = shift();
  my($command) = 'cf marketplace';
  my($output);
  my($i);
  my(@redis_types);
  my($retval);
  my($type);

  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  my(@data) = split("\n", $output);
  for ($i = 0 ; $i < @data ; $i++) {
    if ($data[$i] =~ /^(redis-\d+)\s+/) {
      $type = $1;
      push(@redis_types, $type);
      print "\tTrying to create instance of $1\n";
      $command = "cf create-service $type $redis_plan $redis_instance_name";
      $output = `$command`;

      if ($output =~ /OK$/) { # if it ends with "OK" then it was successful
	print "\tSuccessfully created instance of $type\n";
	$command = "cf bind-service $app_name $redis_instance_name";
	$output = `$command`;
	print "\toutput: $output\n";
	break;
      } else {
	print "\tCreation of instance type $type failed.  Looking for an available service type...\n";
      }
    }
  }
}

sub get_environment_variables() {
  print "get_environment_variables\n";

  my($appname) = shift();
  my($services_json);
  my($command) = 'cf env ' . $appname;

  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  $output =~ m/(?s)(\{.*\})\s*(\{.*\})/m;
  $services_json = decode_json($1);
  # $vcap_application_json = decode_json($2);
  print "\tretrieved environment variables\n";
  return $services_json;
}

sub get_service_instance_env_vars() {
  print "get_service_instance_env_vars\n";

  my($service_type) = shift();
  my($instance_name) = shift();
  my($array) = shift();
  my($services_json) = shift();
  my($service_instance_vars);
  my($size);

  $size = @$array;
  print "\tlooking for '" . $instance_name . "' in '" . $service_type . "'\n";
  print "\tnumber of instances: " . $size . "\n";
  for (my($i)=0 ; $i < $size ; $i++) {
    print "\t\tinspecting ". $services_json->{'VCAP_SERVICES'}{$service_type}[$i]{'name'} . "\n";
    if ($services_json->{'VCAP_SERVICES'}{$service_type}[$i]{'name'} eq $instance_name) {
      $service_instance_vars = $services_json->{'VCAP_SERVICES'}{$service_type}[$i];
      print "\t\t\tFound instance of $instance_name\n";
    }
  }
  return $service_instance_vars;
}

sub uaac_target() {
  print "uaac_target" . "\n";

  my($uri) = shift();
  my($command) = 'uaac target ' . $uri . ' --skip-ssl-validation';

  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub uaac_token_client_get_admin() {
  print "uaac_token_client_get_admin\n";

  my($secret) = shift();
  my($command) = 'uaac token client get admin -s ' . $secret;

  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub uaac_client_add() {
  print "uaac_client_add\n";

  my($client_id) = shift();
  my($client_secret) = shift();
  my($scope) = shift();
  my($grant_types) = shift();
  my($authorities) = shift();
  my($auto_approve) = shift();

  print "\tauthorities: " . $authorities . "\n";
  print "\tgrant types: " . $grant_types . "\n";
  my($command) = 'uaac client add ' . $client_id . ' --secret ' . $client_secret . ' --authorized_grant_types ' . $grant_types;
  if ($scope ne "") {
    $command .= ' --scope ' . $scope;
  }
  if ($authorities ne "") {
    $command .= ' --authorities ' . $authorities;
  }
  if ($auto_approve ne "") {
    $command .= ' --autoapprove ' . $auto_approve;
  }
  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub uaac_user_add() {
  print "uaac_user_add\n";

  my($user_id) = shift();
  my($user_secret) = shift();
  my($emails) = shift();
  my($command) = 'uaac user add ' . $user_id . ' --password ' . $user_secret . ' --emails ' . $emails;

  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub uaac_group_add() {
  print "uaac_group_add\n";

  my($group_name) = shift();
  my($command) = 'uaac group add ' . $group_name;

  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}

sub uaac_member_add() {
  print "uaac_member_add\n";

  my($group_name) = shift();
  my($user_id) = shift();
  my($command) = 'uaac member add ' . $group_name . ' ' . $user_id;

  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  print "\toutput: $output\n";
}


################################## experiments ######################################
sub get_app_guid() {
  print "get_app_guid\n";
  # $command = 'cf curl /v2/apps | jq -r ".resources[] | {name: .entity.name, guid: .metadata.guid} | select(.name | contains(\"myapp\")) | .guid"';
  $command = 'cf curl /v2/apps | jq -r ".resources[] | select(.entity.name | contains(\"' . $my_application_name . '\")) | .metadata.guid"';
  print "\texecuting: " . $command . "\n";
  $output = `$command`;
  chomp($output);
  print "\toutput: $output\n";
  return $output;
}

sub list_uaa_instances() {
  print "list_uaa_instances\n";
  $array = shift();
  $size = @$array;
  print "\tinstances: " . $size . "\n";
  for ($i=0 ; $i < $size ; $i++) {
    print "\t\t" . $vcap_services_json->{'VCAP_SERVICES'}{'predix-uaa'}[$i]{'name'} . "\n";
  }
}

sub test() {
  my($json) = decode_json('{"a":1, "b":2}');
  print "json: " . $json->{'a'} . "\n";
}

