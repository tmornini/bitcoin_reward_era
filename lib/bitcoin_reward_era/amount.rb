# -*- encoding : utf-8 -*-

require 'delegate'
require 'bigdecimal'

module BitcoinRewardEra
  class Amount < SimpleDelegator
    def initialize amount
      super(BigDecimal amount)
    end

    def inspect
      to_s
    end

    def to_json _state_ = nil
      %("#{self}")
    end

    def to_s pattern = 'F'
      __getobj__.to_s pattern
    end

    def to_str
      to_s
    end
  end
end
