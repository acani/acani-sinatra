Feature: person goes on acani

  As a user
  I want to connect to acani
  So that I can connect & play with others nearby with similar interests

  Scenario: create account
    Given I am not yet connected to acani
    When I go on acani
    Then I should see a JSON array of users
