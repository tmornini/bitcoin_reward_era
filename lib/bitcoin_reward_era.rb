# -*- encoding : utf-8 -*-

require 'bitcoin_reward_era/representation'

module BitcoinRewardEra
  def self.report
    report_string = "#{HEADER}\n"

    1.upto(34) do |reward_era_number|
      report_string +=
        "#{Representation.new reward_era_number: reward_era_number}\n"
    end

    report_string
  end

  private

  HEADER = '  Block   Reward Era     BTC/block       Year' \
           '           Start BTC           BTC Added'      \
           '             End BTC   BTC % Increase'         \
           '   End BTC % of Limit   Supply Inflation Rate'
end
