# -*- encoding : utf-8 -*-

require 'time'

require 'bitcoin_reward_era/amount'

module BitcoinRewardEra
  class Calculator
    BLOCKS_PER_REWARD_ERA  = Amount.new(210_000)
    SECONDS_PER_REWARD_ERA = Amount.new(BLOCKS_PER_REWARD_ERA * 10 * 60)
    GENESIS_BLOCK_TIME     = Time.at(1_231_006_505).utc

    attr_reader :reward_era_number

    def initialize config
      @time_klass           = config[:time_klass]           || Time
      @amount_klass         = config[:amount_klass]         || Amount

      @reward_era_number = @amount_klass.new config[:reward_era_number]
    end

    def first_block
      Amount.new last_reward_era_number * BLOCKS_PER_REWARD_ERA
    end

    def btc_per_block
      initial_reward = @amount_klass.new 50

      truncate_at_satoshis initial_reward / (2**last_reward_era_number)
    end

    def year
      Amount.new this_year + portion_of_year
    end

    def start_btc
      btc_in_circulation = BigDecimal 0

      1.upto last_reward_era_number do |ren|
        btc_in_circulation +=
          self.class.new(reward_era_number: ren)
          .btc_per_block * BLOCKS_PER_REWARD_ERA
      end

      Amount.new btc_in_circulation
    end

    def btc_added
      Amount.new end_btc - start_btc
    end

    def end_btc
      next_calculator.start_btc
    end

    def btc_increase_percentage
      Amount.new btc_added / last_calculator.end_btc
    end

    def end_btc_percent_of_limit
      Amount.new end_btc / final_calculator.end_btc
    end

    def supply_inflation_rate
      Amount.new(((1 + btc_increase_percentage)**0.25) - 1)
    end

    private

    def truncate_at_satoshis amount
      string = amount.to_s '8F'

      truncation_match = string.match(/^\d+[.]\d+/)

      @amount_klass.new truncation_match[0]
    end

    def last_reward_era_number
      Amount.new @reward_era_number - 1
    end

    def next_reward_era_number
      Amount.new @reward_era_number + 1
    end

    def final_reward_era_number
      Amount.new 34
    end

    def seconds_since_block_zero
      Amount.new first_block * 60 * 10
    end

    def beginning_of_reward_era
      GENESIS_BLOCK_TIME + seconds_since_block_zero
    end

    def this_year
      Amount.new beginning_of_reward_era.year
    end

    def portion_of_year
      next_year = this_year + 1

      beginning_of_this_year =
        Time.new(this_year, 1, 1, 0, 0, 0, '+00:00').utc.to_i

      beginning_of_next_year =
        Time.new(next_year, 1, 1, 0, 0, 0, '+00:00').utc.to_i

      bd_beginning_of_reward_era = BigDecimal beginning_of_reward_era.to_i

      bd_portion_of_year =
        BigDecimal(bd_beginning_of_reward_era - beginning_of_this_year) /
        BigDecimal(beginning_of_next_year - beginning_of_this_year)

      Amount.new bd_portion_of_year
    end

    def last_calculator
      self.class.new reward_era_number: last_reward_era_number
    end

    def next_calculator
      self.class.new reward_era_number: next_reward_era_number
    end

    def final_calculator
      self.class.new reward_era_number: final_reward_era_number
    end
  end
end
