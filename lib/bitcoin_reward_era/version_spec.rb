# -*- encoding : utf-8 -*-

require 'spec_helper'

require 'bitcoin_reward_era/version'

Module BitcoinRewardEra do
  it 'has a constant VERSION' do
    BitcoinRewardEra::VERSION.must_equal '0.0.2'
  end
end
