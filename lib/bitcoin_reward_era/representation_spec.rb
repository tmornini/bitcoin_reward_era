# -*- encoding : utf-8 -*-

require 'spec_helper'

require 'bitcoin_reward_era/representation'

module BitcoinRewardEra
  Class Representation do
    RespondsTo :new do
      ByReturning 'and instance' do
        subject.new(reward_era_number: 1).must_be_instance_of Representation
      end
    end
  end
end
