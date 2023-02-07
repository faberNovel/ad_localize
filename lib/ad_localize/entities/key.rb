# frozen_string_literal: true
module AdLocalize
  module Entities
    Key = Struct.new(:id, :label, :variant_name, :type, keyword_init: true)
  end
end
