# frozen_string_literal: true
module AdLocalize
  module Entities
    SimpleWording = Struct.new(:key, :value, :comment, keyword_init: true)
  end
end
