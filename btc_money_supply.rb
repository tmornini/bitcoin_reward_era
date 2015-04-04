#!/usr/bin/env ruby

require 'bigdecimal'
require 'time'

require 'awesome_print'

BLOCKS_PER_REWARD_ERA = 210_000

def block reward_era
  (reward_era - 1) * BLOCKS_PER_REWARD_ERA
end

def align amount, unit_width = 8, decimal_width = 8
  total_length = unit_width + 1 + decimal_width

  return format("%#{total_length}s",amount) if amount.is_a? String

  pattern = "%#{total_length}.#{decimal_width}f"

  format pattern, amount
end

def round_to_satoshis btc
  BigDecimal(format '%17.8f', btc)
end

def truncate_at_satoshis btc
  string = btc.to_s '8F'

  truncation_match = string.match /^\d+[.]\d+/

  BigDecimal truncation_match[0]
end

def btc_per_block reward_era
  reward = BigDecimal 50

  1.upto reward_era - 1 do
    reward /= 2
  end

  reward_era == 34 ? BigDecimal(0) : reward
end

def year reward_era
  block_zero_time = Time.parse '2009-01-03 18:15:05 GMT'

  minutes_since_zero = block(reward_era) * 10 * 60

  reward_era_time = block_zero_time + minutes_since_zero

  year = reward_era_time.year

  portion_of_year = reward_era_time.yday / 365.25

  format '%8.3f', year + portion_of_year
end

def start_btc reward_era
  btc_in_circulation = 0

  1.upto reward_era - 1 do |reward_era|
    btc_in_circulation += btc_per_block(reward_era) * BLOCKS_PER_REWARD_ERA
  end

  btc_in_circulation
end

def btc_added reward_era
  end_btc(reward_era) - start_btc(reward_era)
end

def end_btc reward_era
  start_btc(reward_era + 1)
end

def btc_increase reward_era
  if reward_era == 1
    'infinite'
  else
    (btc_added(reward_era) / end_btc(reward_era - 1)) * 100
  end
end

def end_btc_percent_of_limit reward_era
  (end_btc(reward_era) / end_btc(34)) * 100
end

def output hash
  truncated = truncate_at_satoshis(hash[:btc_per_block])
  # rounded   = round_to_satoshis(hash[:btc_per_block])

  puts format('%7d', hash[:block])      +
       " : "                            +
       format('%10d', hash[:reward_era]) +
       " : "                            +
       align(truncated,2)               +
       " : "                            +
       hash[:year]                      +
       " : "                            +
       align(hash[:start_btc])          +
       " : "                            +
       align(hash[:btc_added])          +
       " : "                            +
       align(hash[:end_btc])            +
       " : "                            +
       align(hash[:btc_increase], 3, 8) +
       " : "                            +
       align(hash[:end_btc_percent_of_limit], 9 ,8)
  # ap hash
end

puts '  Block   Reward Era     BTC/block       Year           Start BTC' \
     '           BTC Added             End BTC   BTC Increase'\
     '   End BTC % of Limit'

1.upto(34) do |reward_era|
  reward_era = BigDecimal reward_era

  output block:                    block(reward_era),
         reward_era:               reward_era,
         btc_per_block:            btc_per_block(reward_era),
         year:                     year(reward_era),
         start_btc:                start_btc(reward_era),
         btc_added:                btc_added(reward_era),
         end_btc:                  end_btc(reward_era),
         btc_increase:             btc_increase(reward_era),
         end_btc_percent_of_limit: end_btc_percent_of_limit(reward_era)
end
