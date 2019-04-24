# frozen_string_literal: true

require 'test_helper'

class Conversica::Client::LeadTest < Minitest::Test
  def test_unpermitted_params_keys_are_filtered
    ENV['CONVERSICA_API_VERSION'] = 'yay'
    assert_equal(
      { 'api_version' => 'yay' },
      Conversica::Client::Lead.new(unpermitted_key: 'some_value').attributes
    )
  end

  def test_validations_require_correct_types_for_all_columns
    Conversica::Client::Lead::DATE_COLUMNS.each do |c|
      instance = Conversica::Client::Lead.new(c => DateTime.now)
      instance.validate_type
      assert_equal [], instance.errors
      instance.send("#{c}=", DateTime.now.rfc3339)
      instance.validate_type
      assert_equal 1, instance.errors.count
      assert instance.errors.first.match(/valid date/)
    end

    Conversica::Client::Lead::BOOLEAN_COLUMNS.each do |c|
      instance = Conversica::Client::Lead.new(c => true)
      instance.validate_type
      assert_equal [], instance.errors
      instance.send("#{c}=", 'true')
      instance.validate_type
      assert_equal 1, instance.errors.count
      assert instance.errors.first.match(/must be a boolean/)
    end

    (
      Conversica::Client::Lead::PERMITTED_COLUMNS -
      Conversica::Client::Lead::DATE_COLUMNS.to_a -
      Conversica::Client::Lead::BOOLEAN_COLUMNS.to_a
    ).each do |c|
      instance = Conversica::Client::Lead.new(c => 'String')
      instance.validate_type
      assert_equal [], instance.errors
      instance.send("#{c}=", 5)
      instance.validate_type
      assert_equal 1, instance.errors.count
      assert instance.errors.first.match(/must be null or a string/)
    end
  end

  def test_api_version_is_set_based_on_env_variable
    ENV['CONVERSICA_API_VERSION'] = 'thisisfake'
    assert_equal 'thisisfake', Conversica::Client::Lead.new({}).api_version
  end

  def test_validations_enforce_required_columns
    # This test also checks that non-required columns are not enforced, since everything except required attributes are null
    ENV['CONVERSICA_API_VERSION'] = 'fakeversion'
    hash = Conversica::Client::Lead::REQUIRED_ATTRIBUTES.map { |k| [k, k] }.to_h
    instance = Conversica::Client::Lead.new(hash)
    instance.validate_required
    assert_equal [], instance.errors
    hash.each do |k, v|
      instance.send("#{k}=", nil)
      instance.validate_required
      assert_equal 1, instance.errors.count
      assert instance.errors.first.match(/#{k} is required/)
      instance.errors = []
      instance.send("#{k}=", '')
      instance.validate_required
      assert_equal 1, instance.errors.count
      assert instance.errors.first.match(/#{k} is required/)
      instance.errors = []
      instance.send("#{k}=", k)
    end
  end

  def test_conversicate_converts_date_fields_to_rfc3339_format
    lead = Conversica::Client::Lead.new(Conversica::Client::Lead::PERMITTED_COLUMNS.map { |k| [k, DateTime.now] }.to_h)
    hash = lead.conversicate
    Conversica::Client::Lead::DATE_COLUMNS.each do |c|
      assert_equal hash[c.camelize(:lower)], lead.send(c).rfc3339
    end
  end

  def test_conversicate_correctly_transforms_keys_to_lower_camel_case
    lead = Conversica::Client::Lead.new(Conversica::Client::Lead::PERMITTED_COLUMNS.map { |k| [k, DateTime.now] }.to_h)
    expected = %w[address altEmail apiVersion appointmentDate appointmentStatus bdcRepId bdcRepEmail bdcRepName
      cellPhone city clientId conversationId date email firstName homeEmail homePhone id lastName leadSource leadStatus
      leadType make model optOut repId repEmail repName serviceRepId serviceRepEmail serviceRepName smsOptOut state
      skipToFollowup stopMessaging vin workEmail workPhone year zip]
    assert_equal expected, lead.conversicate.keys
  end

  def test_create_does_not_post_to_conversica_if_lead_is_invalid
    Conversica::Client::Lead.any_instance.stubs(:valid?).returns(false)
    Conversica::Client::Configuration.expects(:post).never
    Conversica::Client::Lead.create({test: 'test'})
  end

  def test_create_does_post_to_conversica_if_lead_is_valid
    Conversica::Client::Lead.any_instance.stubs(:valid?).returns(true)
    Conversica::Client::Configuration.expects(:post).once
    Conversica::Client::Lead.create(test: 'test')
  end

  def test_valid_returns_true_if_no_errors_are_present
    instance = Conversica::Client::Lead.new({})
    instance.expects(:validate_type).once
    instance.expects(:validate_required).once
    assert instance.valid?
  end

  def test_valid_returns_false_if_errors_are_present
    instance = Conversica::Client::Lead.new({})
    instance.expects(:validate_type).once
    instance.expects(:validate_required).once
    instance.errors = ['this is an error']
    refute instance.valid?
  end
end
