Feature: Command line arguments

  @debug
  Scenario: Display executable path
    When I run `tiller -d`

  Scenario: Run tiller with no arguments
    When I run `tiller`
    Then the output should contain "Error: No configuration files present!"

  Scenario: Run tiller with -h
    When I successfully run `tiller -h`
    Then the output should contain "Usage: tiller"

  Scenario: Verbose mode
    When I successfully run `tiller -d -v -h`
    Then the output should match:
      """
      :verbose=>true|verbose: true
      """

  Scenario: Debug mode
    When I successfully run `tiller -d -h`
    Then the output should match:
      """
      :debug=>true|debug: true
      """

  Scenario:API enable
    When I successfully run `tiller -d -a -h`
    Then the output should match:
      """
      "api_enable"\s*=>\s*true
      """

  Scenario: Change API port
    When I successfully run `tiller -d -a -p 1234 -h`
    Then the output should match:
      """
      "api_port"\s*=>\s*"1234"
      """

  Scenario: Set environment
    When I run `tiller -d -e test -h`
    Then the output should match:
      """
      :environment=>"test"|environment: "test"
      """

  Scenario: Enable md5 checks
  When I run `tiller -d --md5sum -h`
  Then the output should match:
    """
    "md5sum"\s*=>\s*true
    """

  Scenario: Enable md5 noexec
    When I run `tiller -d --md5sum-noexec -h`
    Then the output should match:
      """
      "md5sum_noexec"\s*=>\s*true
      """