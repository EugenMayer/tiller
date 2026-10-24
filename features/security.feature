Feature: Security hardening

  Scenario: ERb syntax in an environment variable is not evaluated with dynamic_values
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "file" , "environment" ]
    template_sources: [ "file" ]
    dynamic_values: true

    environments:
      development:
        test.erb:
          target: test.txt
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    value: <%= env_evil %>
    """
    And I set the environment variables exactly to:
      | variable | value         |
      | evil     | <%= 6 * 7 %>  |
    When I successfully run `tiller -b . -n`
    Then the file "test.txt" should contain "value: <%= 6 * 7 %>"
    And the file "test.txt" should not contain "42"

  Scenario: The result of evaluating ERb is not evaluated again
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "environment" , "file" , "defaults" ]
    template_sources: [ "file" ]
    dynamic_values: true

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            from_file: <%= env_evil %>
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    value: <%= from_file %>
    """
    And I set the environment variables exactly to:
      | variable | value         |
      | evil     | <%= 6 * 7 %>  |
    When I successfully run `tiller -b . -n`
    Then the file "test.txt" should contain "value: <%= 6 * 7 %>"
    And the file "test.txt" should not contain "42"

  Scenario: A target starting with a pipe character does not run a command
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]

    environments:
      development:
        test.erb:
          target: "|touch pwned"
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test
    """
    When I successfully run `tiller -b . -n`
    Then a file named "pwned" should not exist
    And a file named "|touch pwned" should exist

  Scenario: Arguments of an exec array are not interpreted by a shell
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "echo" , "a b; touch pwned" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]

    environments:
      development:
        test.erb:
          target: test.txt
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test
    """
    When I successfully run `tiller -b .`
    Then the output should contain "a b; touch pwned"
    And a file named "pwned" should not exist

  Scenario: YAML configuration cannot instantiate Ruby objects
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: !ruby/object:OpenStruct {}
    """
    When I run `tiller -b .`
    Then the exit status should not be 0
    And the output should contain "Could not open common configuration files"

  Scenario: Values of keys that look like secrets are not logged
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "defaults" , "file" ]
    template_sources: [ "file" ]

    defaults:
      test.erb:
        db_password: from defaults
        db_host: host from defaults

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            db_password: from file
            db_host: host from file
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    <%= db_password %> <%= db_host %>
    """
    When I successfully run `tiller -b . --verbose -n`
    Then the file "test.txt" should contain "from file host from file"
    And the output should contain "db_password => '[REDACTED]' being replaced by : '[REDACTED]'"
    And the output should contain "db_host => 'host from defaults' being replaced by : 'host from file'"
    And the output should not contain "'from defaults'"
    And the output should not contain "'from file'"

  Scenario: Files in the plugin directory do not replace the libraries Tiller uses
    Given a directory named "lib"
    And a file named "lib/diplomat.rb" with:
    """
    puts "HIJACKED"
    """
    And a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "file" , "consul" ]
    template_sources: [ "file" ]

    environments:
      development:
        test.erb:
          target: test.txt
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test
    """
    When I successfully run `tiller -b . -l ./lib -n`
    Then the output should not contain "HIJACKED"

  Scenario: Plugin names can only be plain names
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "../../../tmp/evil" ]
    template_sources: [ "file" ]
    """
    When I run `tiller -b .`
    Then the exit status should not be 0
    And the output should contain "Invalid plugin name '../../../tmp/evil'"

  Scenario: Helper names can only be plain names
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    helpers: [ "../evil" ]

    environments:
      development:
        test.erb:
          target: test.txt
    """
    When I run `tiller -b .`
    Then the exit status should not be 0
    And the output should contain "Invalid plugin name '../evil'"

  Scenario: The environment name can only be a plain name
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    """
    When I run `tiller -b . -e ../../etc/passwd`
    Then the exit status should not be 0
    And the output should contain "Invalid environment name '../../etc/passwd'"

  @root
  Scenario: Permissions of a new file are set when running as root
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]

    environments:
      development:
        secret.erb:
          target: secret.txt
          perms: 0600
        public.erb:
          target: public.txt
    """
    And a directory named "templates"
    And a file named "templates/secret.erb" with:
    """
    secret
    """
    And a file named "templates/public.erb" with:
    """
    public
    """
    When I successfully run `tiller -b . -n`
    Then the file "secret.txt" should have permissions "0600"
    And the file "public.txt" should have permissions "0644"

  @root
  Scenario: Permissions of an existing file are set when running as root
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "true" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]

    environments:
      development:
        secret.erb:
          target: secret.txt
          perms: 0600
    """
    And a directory named "templates"
    And a file named "templates/secret.erb" with:
    """
    secret
    """
    And an empty file named "secret.txt" with mode "0644"
    When I successfully run `tiller -b . -n`
    Then the file "secret.txt" should have permissions "0600"
    And the file "secret.txt" should contain "secret"

