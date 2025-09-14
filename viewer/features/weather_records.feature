Feature: Weather records browsing
  In order to view weather history
  As a user
  I want to filter weather records by city

  Background:
    Given the following cities exist:
      | name             |
      | Moscow           |
      | Saint Petersburg |

    And the following weather records exist:
      | city             | temp_c | fetched_at   |
      | Moscow           | 15     | 2025-09-14 09:00:00  |
      | Moscow           | 16     | 2025-09-14 12:00:00 |
      | Saint Petersburg | 18     | 2025-09-14 10:00:00 |

  Scenario: View all weather records
    When I go to the weather records page
    Then I should see "Moscow" in table
    And I should see "Saint Petersburg" in table

  Scenario: Filter by Moscow
    When I go to the weather records page
    And I select "Moscow" from "Город"
    And I press "Фильтровать"
    Then I should see "Moscow" in table
    And I should not see "Saint Petersburg" in table

  Scenario: Filter by Saint Petersburg
    When I go to the weather records page
    And I select "Saint Petersburg" from "Город"
    And I press "Фильтровать"
    Then I should see "Saint Petersburg" in table
    And I should not see "Moscow" in table
    