# -*- encoding : utf-8 -*-

require 'bigdecimal'
require 'time'

class RewardEra
  def self.report_string
    report_string = header + "\n"

    1.upto(34) do |reward_era_number|
      report_string += new(reward_era_number: reward_era_number).to_s
      report_string += "\n"
    end

    report_string
  end

  def initialize config
    @bigdecimal_klass  = config[:bigdecimal_klass] || BigDecimal
    @time_klass        = config[:time_klass]       || Time

    @reward_era_number = config[:reward_era_number].to_i

    # fail ':reward_era_number must be positive' if @reward_era_number < 1
  end

  def first_block_in_era
    last_reward_era_number * BLOCKS_PER_REWARD_ERA
  end

  def btc_per_block
    reward = BigDecimal 50

    truncate_at_satoshis reward / (2 ** last_reward_era_number)
  end

  def year
    year = beginning_of_reward_era.year

    format '%8.3f', year + portion_of_year
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
    next_reward_era.start_btc
  end

  def btc_increase_percentage
    btc_added / last_reward_era.end_btc
  end

  def end_btc_percent_of_limit
    end_btc / final_reward_era.end_btc
  end

  def supply_inflation_rate
    ((1 + btc_increase_percentage) ** 0.25) - 1
  end

  def to_representation
    {
      block:                    block,
      reward_era_number:        reward_era_number,
      btc_per_block:            btc_per_block,
      year:                     year,
      start_btc:                start_btc,
      btc_added:                btc_added,
      end_btc:                  end_btc,
      btc_increase_percentage:  btc_increase_percentage,
      end_btc_percent_of_limit: end_btc_percent_of_limit,
      supply_inflation_rate:    supply_inflation_rate
    }
  end

  def to_s
    format('%7d', first_block_in_era)          +
    ' : '                                      +
    format('%10d', reward_era_number)          +
    ' : '                                      +
    align(btc_per_block, 2)                    +
    ' : '                                      +
    year                                       +
    ' : '                                      +
    align(start_btc)                           +
    ' : '                                      +
    align(btc_added)                           +
    ' : '                                      +
    align(end_btc)                             +
    ' : '                                      +
    percentage(btc_increase_percentage, 4, 8)  +
    ' : '                                      +
    percentage(end_btc_percent_of_limit, 8 ,8) +
    ' : '                                      +
    percentage(supply_inflation_rate, 11 ,8)
  end

  private

  BLOCKS_PER_REWARD_ERA  = 210_000
  SECONDS_PER_REWARD_ERA = BLOCKS_PER_REWARD_ERA * 10 * 60
  GENESIS_BLOCK_TIME     = Time.at(1231006505).utc

  def self.header
    '  Block   Reward Era     BTC/block       Year           Start BTC' \
    '           BTC Added             End BTC   BTC % Increase'\
    '   End BTC % of Limit   Supply Inflation Rate'
  end

  attr_reader :reward_era_number

  def last_reward_era_number
    reward_era_number - 1
  end

  def next_reward_era_number
    reward_era_number + 1
  end

  def last_reward_era
    self.class.new reward_era_number: last_reward_era_number
  end

  def next_reward_era
    self.class.new reward_era_number: next_reward_era_number
  end

  def final_reward_era_number
    34
  end

  def final_reward_era
    self.class.new reward_era_number: final_reward_era_number
  end

  def truncate_at_satoshis btc
    string = btc.to_s '8F'

    truncation_match = string.match /^\d+[.]\d+/

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

    portion_of_this_year = (beginning_of_reward_era - beginning_of_this_year) /
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
