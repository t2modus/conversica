# frozen_string_literal: true

require 'test_helper'

class Conversica::Client::LeadUpdateTest < Minitest::Test
  def test_keys_of_params_hash_are_underscored
    assert_equal(
      Conversica::Client::LeadUpdate::PERMITTED_COLUMNS,
      Conversica::Client::LeadUpdate.new(example_hash).attributes.keys.sort
    )
  end

  def test_unpermitted_params_keys_are_filtered
    assert_equal(
      Conversica::Client::LeadUpdate::PERMITTED_COLUMNS,
      Conversica::Client::LeadUpdate.new(
        example_hash.merge(unknownKey: 'unknownValue')
      ).attributes.keys.sort
    )
  end

  def test_date_and_time_columns_are_parsed_into_time_objects
    lead_update = Conversica::Client::LeadUpdate.new(example_hash)
    Conversica::Client::LeadUpdate::DATE_COLUMNS.each do |c|
      assert lead_update.send(c).is_a?(Time)
      assert_equal(
        example_hash[c.camelize(:lower)],
        lead_update.send(c).to_datetime.rfc3339
      )
    end
  end

  def example_hash
    MultiJson.load <<~JSON
      {
        "apiVersion": "7.1",
        "clientId": 67890,
        "id": 12345,
        "dateAdded": "2017-01-10T15:19:21+00:00", "firstMessageDate": "2017-01-10T15:23:25+00:00", "lastMessageDate": "2017-01-11T12:49:33+00:00", "lastResponseDate": "2017-01-11T14:48:23+00:00", "hotLead": true,
        "hotLeadDate": "2017-01-11T15:00:00+00:00", "discoveredPhone1": "1234567899",
        "doNotEmail": false
      }
    JSON
  end
end
