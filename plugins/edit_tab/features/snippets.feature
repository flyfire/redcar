Feature: Snippets
  As a user
  I want to speed myself up with snippets

  Background:
    Given there is an EditTab open with syntax "Ruby"

  Scenario: Inserts snippet contents
    When I type "def"
    And I press "Tab"
    Then I should see "def <s>method_name<c>\n\t\nend" in the EditTab

  Scenario: Presents options when multiple
    When I type "cla"
    And I press "Tab"
    Then I should see a menu with "class .. end"