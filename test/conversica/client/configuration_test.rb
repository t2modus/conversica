# frozen_string_literal: true

require 'test_helper'

class Conversica::Client::ConfigurationTest < Minitest::Test
  ENV['CONVERSICA_OUTGOING_USERNAME'] = 'user'
  ENV['CONVERSICA_OUTGOING_PASSWORD'] = 'password'

  def test_username_and_password_are_correctly_set_from_an_environment_variable
    assert_equal 'user', Conversica::Client::Configuration.instance.instance_variable_get('@username')
    assert_equal 'password', Conversica::Client::Configuration.instance.instance_variable_get('@password')
  end

  def test_can_get_a_faraday_instance_with_basic_auth_applied
    obj = Object.new
    Faraday.expects(:new).once.returns(obj)
    obj.expects(:basic_auth).once.with('user', 'password')
    Conversica::Client::Configuration.instance.connection
  end

  def test_can_post_to_conversica_with_json_payload
    payload = {
      test: 'payload',
      these: 'keys',
      are: 'fun'
    }
    req = Object.new
    Faraday::Connection.any_instance.stubs(:basic_auth)
    Faraday::Connection.any_instance.expects(:post).once.yields(req)
    req.expects(:body=).once.with(MultiJson.dump payload)
    Conversica::Client::Configuration.post(payload)
  end
end
