# -*- encoding : utf-8 -*-

$LOAD_PATH.unshift 'lib'

require 'rake/testtask'

task default: 'spec:unit'

namespace :spec do
  Rake::TestTask.new :unit do |task|
    task.test_files = FileList['lib/**/*_spec.rb']
  end
end
