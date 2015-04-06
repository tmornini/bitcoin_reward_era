# -*- encoding : utf-8 -*-

require 'bitcoin_reward_era/calculator'

module BitcoinRewardEra
  class Representation
    def initialize config
      @calculator =
        Calculator.new reward_era_number: config[:reward_era_number].to_i
    end

    def to_representation
      {
        first_block:              @calculator.first_block,
        reward_era_number:        @calculator.reward_era_number,
        btc_per_block:            @calculator.btc_per_block,
        year:                     @calculator.year,
        start_btc:                @calculator.start_btc,
        btc_added:                @calculator.btc_added,
        end_btc:                  @calculator.end_btc,
        btc_increase_percentage:  @calculator.btc_increase_percentage,
        end_btc_percent_of_limit: @calculator.end_btc_percent_of_limit,
        supply_inflation_rate:    @calculator.supply_inflation_rate
      }
    end

    def to_s
      [
        format('%7d', @calculator.first_block),
        format('%10d', @calculator.reward_era_number),
        align(@calculator.btc_per_block, 2),
        align(@calculator.year, 4, 3),
        align(@calculator.start_btc),
        align(@calculator.btc_added),
        align(@calculator.end_btc),
        percentage(@calculator.btc_increase_percentage, 4, 8),
        percentage(@calculator.end_btc_percent_of_limit, 8, 8),
        percentage(@calculator.supply_inflation_rate, 11, 8)
      ].join ' : '
    end

    private

    def align amount, unit_width = 8, decimal_width = 8
      total_length = unit_width + 1 + decimal_width

      pattern = "%#{total_length}.#{decimal_width}f"

      format pattern, amount
    end

    def percentage amount, unit_width = 3, decimal_width = 8
      total_length = unit_width + 1 + decimal_width

      return format("%#{total_length + 1}s", amount) if amount.is_a? String

      pattern = "%#{total_length}.#{decimal_width}f%"

      format pattern, amount * 100
    end
  end
end
