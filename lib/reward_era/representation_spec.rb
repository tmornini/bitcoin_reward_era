# -*- encoding : utf-8 -*-

require 'digest'

require 'spec_helper'

require 'reward_era/representation'

module RewardEra
  Class Representation do
    RespondsTo :new do
      ByReturning 'and instance' do
        subject.new(reward_era_number: 1).must_be_instance_of Representation
      end
    end
  end
end
