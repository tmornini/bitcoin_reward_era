# -*- encoding : utf-8 -*-

require 'spec_helper'

require 'bitcoin_reward_era/representation'

module BitcoinRewardEra
  Class Representation do
    let(:config) { { reward_era_number: 1 } }

    RespondsTo :new do
      ByReturning 'an instance' do
        subject.new(config).must_be_instance_of Representation
      end
    end

    Instance do
      subject { Representation.new config }

      RespondsTo :to_representation do
        ByReturning 'a hash' do
          subject.to_representation.must_be_instance_of Hash
        end
      end
    end
  end
end
