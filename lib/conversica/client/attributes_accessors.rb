# frozen_string_literal: true

module Conversica
  module Client
    # This module is used to create functionality for attribute accessors for an attributes hash
    module AttributesAccessors
      def define_attr_accessors_for_attributes
        self::PERMITTED_COLUMNS.each do |c|
          define_method c do
            self.attributes[c]
          end

          define_method "#{c}=" do |v|
            self.attributes[c] = v
          end
        end
      end
    end
  end
end
