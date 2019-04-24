# frozen_string_literal: true

require 'test_helper'

class Conversica::Client::MessageTest < Minitest::Test
  def test_keys_of_params_hash_are_underscored
    assert_equal(
      Conversica::Client::Message::PERMITTED_COLUMNS,
      Conversica::Client::Message.new(example_hash).attributes.keys.sort
    )
  end

  def test_unpermitted_params_keys_are_filtered
    assert_equal(
      Conversica::Client::Message::PERMITTED_COLUMNS,
      Conversica::Client::Message.new(
        example_hash.merge(unknownKey: 'unknownValue')
      ).attributes.keys.sort
    )
  end

  def test_date_and_time_columns_are_parsed_into_time_objects
    message = Conversica::Client::Message.new(example_hash)
    assert message.date.is_a?(Time)
    assert_equal(
      example_hash['date'],
      message.date.to_datetime.rfc3339
    )
  end

  def example_hash
    MultiJson.load <<~JSON
      {
        "apiVersion": "7.1",
        "clientId": "67890",
        "id": "12345",
        "action": "received",
        "date": "2017-01-10T18:20:25+00:00", "subject": "Your Request",
        "body": "Hello Rachel \\nI would like to schedule a call with you regarding setting up.\\nThank you \\nAnna Slazkiewicz"
      }
    JSON
  end
end
