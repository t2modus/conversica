# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'date'
require 'conversica/client/attributes_accessors'
require 'conversica/client/configuration'
require 'conversica/client/lead_update'
require 'conversica/client/lead'
require 'conversica/client/message'

module Conversica
  # This module serves as a namespace for all API communication with conversica's servers, whether it be initiated by
  # them or by us
  module Client; end
end
