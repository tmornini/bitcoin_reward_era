#!/usr/bin/env ruby

$LOAD_PATH.unshift 'lib'

require 'rubygems'
require 'bundler/setup'

# require 'awesome_print'

require 'reward_era'

puts RewardEra.report_string
