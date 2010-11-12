Feature: user goes on acani

  As a user
  I want to connect to acani
  So that I can meet people nearby with similar interests

  Scenario: create account
    Given I am not yet signed up for acani
    When I start acani
    Then, I should see
    Then I should see a JSON array of users
