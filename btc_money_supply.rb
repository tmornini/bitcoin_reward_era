#!/usr/bin/env ruby

require 'bigdecimal'
require 'time'

require 'rubygems'

require 'bundler/setup'

class RewardEra
  def self.header
    '  Block   Reward Era     BTC/block       Year           Start BTC' \
    '           BTC Added             End BTC   BTC % Increase'\
    '   End BTC % of Limit'
  end

  def initialize reward_era
    @reward_era = reward_era
  end

  def first_block_in_era
    (@reward_era - 1) * BLOCKS_PER_REWARD_ERA
  end

  def btc_per_block
    reward = BigDecimal 50

    1.upto last_reward_era_number do
      reward /= 2
    end

    truncate_at_satoshis reward
  end

  def year
    year = reward_era_time.year

    format '%8.3f', year + portion_of_year
  end

  def start_btc
    btc_in_circulation = 0

    1.upto last_reward_era_number do |reward_era_number|
      a_reward_era = self.class.new reward_era_number

      btc_in_circulation +=
        a_reward_era.btc_per_block * BLOCKS_PER_REWARD_ERA
    end

    btc_in_circulation
  end

  def btc_added
    end_btc - start_btc
  end

  def end_btc
    next_reward_era.start_btc
  end

  def btc_increase
    if @reward_era == 1
      'infinite'
    else
      btc_added / last_reward_era.end_btc
    end
  end

  def end_btc_percent_of_limit
    end_btc / final_reward_era.end_btc
  end


  def to_representation
    {
      block:                    block,
      reward_era:               reward_era,
      btc_per_block:            btc_per_block,
      year:                     year,
      start_btc:                start_btc,
      btc_added:                btc_added,
      end_btc:                  end_btc,
      btc_increase:             btc_increase,
      end_btc_percent_of_limit: end_btc_percent_of_limit
    }
  end

  def to_s
    format('%7d', first_block_in_era) +
    ' : '                             +
    format('%10d', reward_era)        +
    ' : '                             +
    align(btc_per_block, 2)           +
    ' : '                             +
    year                              +
    ' : '                             +
    align(start_btc)                  +
    ' : '                             +
    align(btc_added)                  +
    ' : '                             +
    align(end_btc)                    +
    ' : '                             +
    percentage(btc_increase, 4, 8)    +
    ' : '                             +
    percentage(end_btc_percent_of_limit, 8 ,8)
  end

  private

  BLOCKS_PER_REWARD_ERA = 210_000

  attr_reader :reward_era

  def last_reward_era_number
    @reward_era - 1
  end

  def next_reward_era_number
    @reward_era + 1
  end

  def last_reward_era
    self.class.new last_reward_era_number
  end

  def next_reward_era
    self.class.new next_reward_era_number
  end

  def final_reward_era_number
    34
  end

  def final_reward_era
    self.class.new final_reward_era_number
  end

  def truncate_at_satoshis btc
    string = btc.to_s '8F'

    truncation_match = string.match /^\d+[.]\d+/

    BigDecimal truncation_match[0]
  end

  def block_zero_time
    Time.parse '2009-01-03 18:15:05 GMT'
  end

  def seconds_since_block_zero
    first_block_in_era * 60 * 10
  end

  def reward_era_time
    block_zero_time + seconds_since_block_zero
  end

  def reward_era_year
    reward_era_time.year
  end

  def portion_of_year
    this_year = reward_era_year
    next_year = this_year + 1

    beginning_of_this_year = Time.new this_year, 1, 1
    beginning_of_next_year = Time.new next_year, 1, 1

    seconds_in_year = beginning_of_next_year - beginning_of_this_year

    seconds_in_year_until_block = reward_era_time - beginning_of_this_year

    seconds_in_year_until_block / seconds_in_year
  end

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

puts RewardEra.header

1.upto(34) do |reward_era_number|
  puts RewardEra.new(reward_era_number).to_s
end
