Feature: person goes on acani

  As a person
  I want to go on acani
  So that I can connect and play with others nearby with similar interests

  Scenario: create account
    Given I am not yet on acani
    When I go on acani
    Then I should see a JSON array of users
