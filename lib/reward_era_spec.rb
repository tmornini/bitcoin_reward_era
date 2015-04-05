# -*- encoding : utf-8 -*-

require 'digest'

require 'spec_helper'

require 'reward_era'

Class RewardEra do
  RespondsTo :report_string do
    ByReturning 'a report string' do
      subject.report_string.must_be_instance_of String
      subject.report_string.length.must_equal 5880

      Digest::SHA256.hexdigest(subject.report_string)
      .must_equal '6b54d5484000f0cbed42dd70b4c857f' \
                  '18528543b64cb07fc8a7e285ce74d9ba4'
    end
  end

  RespondsTo :new do
    ByReturning 'and instance' do
      subject.new(reward_era_number: 1).must_be_instance_of RewardEra
    end
  end
end
