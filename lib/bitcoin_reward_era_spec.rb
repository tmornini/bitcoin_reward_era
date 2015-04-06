# -*- encoding : utf-8 -*-

require 'spec_helper'

require 'digest'

require 'bitcoin_reward_era'

Module BitcoinRewardEra do
  RespondsTo :report do
    ByReturning 'a report string' do
      subject.report.must_be_instance_of String

      Digest::SHA256.hexdigest(subject.report)
        .must_equal '6b54d5484000f0cbed42dd70b4c857f' \
                    '18528543b64cb07fc8a7e285ce74d9ba4'
    end
  end
end
