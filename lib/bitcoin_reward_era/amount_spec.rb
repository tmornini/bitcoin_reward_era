# -*- encoding : utf-8 -*-

require 'spec_helper'

require 'bitcoin_reward_era/amount'

module BitcoinRewardEra
  Class Amount do
    let(:amount) { '0.000001' }

    RespondsTo :new do
      ByReturning 'an instance' do
        subject.new(amount).class.must_equal Amount
      end

      Instance do
        subject { Amount.new amount }

        RespondsTo :to_s do
          ByReturning 'a nicely formatted string' do
            subject.to_s.must_equal amount
          end
        end
      end
    end
  end
end
