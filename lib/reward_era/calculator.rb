# -*- encoding : utf-8 -*-

require 'bigdecimal'
require 'time'

module RewardEra
  class Calculator
    BLOCKS_PER_REWARD_ERA  = 210_000
    SECONDS_PER_REWARD_ERA = BLOCKS_PER_REWARD_ERA * 10 * 60
    GENESIS_BLOCK_TIME     = Time.at(1_231_006_505).utc

    attr_reader :reward_era_number

    def initialize config
      @representation_klass = config[:representation_klass] || Representation
      @bigdecimal_klass     = config[:bigdecimal_klass]     || BigDecimal
      @time_klass           = config[:time_klass]           || Time

      @reward_era_number = config[:reward_era_number].to_i
    end

    def first_block_in_era
      last_reward_era_number * BLOCKS_PER_REWARD_ERA
    end

    def btc_per_block
      reward = BigDecimal 50

      truncate_at_satoshis reward / (2**last_reward_era_number)
    end

    def year
      beginning_of_reward_era.year + portion_of_year
    end

    def start_btc
      btc_in_circulation = 0

      1.upto last_reward_era_number do |ren|
        btc_in_circulation +=
          self.class.new(reward_era_number: ren)
          .btc_per_block * BLOCKS_PER_REWARD_ERA
      end

      btc_in_circulation
    end

    def btc_added
      end_btc - start_btc
    end

    def end_btc
      next_calculator.start_btc
    end

    def btc_increase_percentage
      btc_added / last_calculator.end_btc
    end

    def end_btc_percent_of_limit
      end_btc / final_calculator.end_btc
    end

    def supply_inflation_rate
      ((1 + btc_increase_percentage)**0.25) - 1
    end

    private

    def last_reward_era_number
      @reward_era_number - 1
    end

    def next_reward_era_number
      @reward_era_number + 1
    end

    def final_reward_era_number
      34
    end

    def truncate_at_satoshis btc
      string = btc.to_s '8F'

      truncation_match = string.match(/^\d+[.]\d+/)

      BigDecimal truncation_match[0]
    end

    def seconds_since_block_zero
      first_block_in_era * 60 * 10
    end

    def beginning_of_reward_era
      GENESIS_BLOCK_TIME + seconds_since_block_zero
    end

    def this_year
      beginning_of_reward_era.year
    end

    def portion_of_year
      next_year = this_year + 1

      beginning_of_this_year = Time.new(this_year, 1, 1, 0, 0, 0, '+00:00').utc
      beginning_of_next_year = Time.new(next_year, 1, 1, 0, 0, 0, '+00:00').utc

      portion_of_this_year =
        (beginning_of_reward_era - beginning_of_this_year) /
        (beginning_of_next_year - beginning_of_this_year)

      # ap beginning_of_this_year:    beginning_of_this_year,
      #    beginning_of_this_year_i:  beginning_of_this_year.to_i,
      #    beginning_of_reward_era:   beginning_of_reward_era,
      #    beginning_of_reward_era_i: beginning_of_reward_era.to_i,
      #    beginning_of_next_year:    beginning_of_next_year,
      #    beginning_of_next_year_i:  beginning_of_next_year.to_i,
      #    portion_of_this_year:      portion_of_this_year

      portion_of_this_year
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
