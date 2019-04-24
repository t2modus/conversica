# frozen_string_literal: true

require 'test_helper'

class FakeClass1
  extend Conversica::Client::AttributesAccessors
  PERMITTED_COLUMNS = %w[test1 test2 test3].freeze
  attr_accessor :attributes
end

class Conversica::Client::AttributesAccessorsTest < Minitest::Test
  def test_should_define_getters_and_setters_for_all_permitted_columns
    FakeClass1::PERMITTED_COLUMNS.each do |col|
      assert_raises NoMethodError do
        FakeClass1.new.send(col)
      end
      assert_raises NoMethodError do
        FakeClass1.new.send("#{col}=", 1)
      end
    end

    FakeClass1.define_attr_accessors_for_attributes
    instance = FakeClass1.new
    instance.attributes = {}
    FakeClass1::PERMITTED_COLUMNS.each do |col|
      instance.send("#{col}=", col)
      assert_equal col, instance.send(col)
    end
    assert_equal({ 'test1' => 'test1', 'test2' => 'test2', 'test3' => 'test3' }, instance.attributes)
  end
end
