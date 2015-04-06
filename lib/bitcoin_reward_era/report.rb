# -*- encoding : utf-8 -*-

require 'bitcoin_reward_era/model'

module BitcoinRewardEra
  module Report
    def self.to_s
      report_string = header + "\n"

      1.upto(34) do |reward_era_number|
        report_string += new(reward_era_number: reward_era_number).to_s
        report_string += "\n"
      end

      report_string
    end
  end
end
