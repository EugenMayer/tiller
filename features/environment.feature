Feature: Configure tiller with environment variables

  Scenario: Set tiller_lib
    Given I set the environment variables exactly to:
      | variable          | value       |
      | tiller_lib        | /tmp        |
    When I run `tiller -d -h`
    Then the output should match:
      """
      :tiller_lib=>"/tmp"|tiller_lib: "/tmp"
      """

  Scenario: Set environment
    Given I set the environment variables exactly to:
      | variable          | value       |
      | environment       | test        |
    When I run `tiller -d -h`
    Then the output should match:
      """
      :environment=>"test"|environment: "test"
      """

