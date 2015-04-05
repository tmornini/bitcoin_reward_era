# -*- encoding : utf-8 -*-

require 'rake/testtask'

task :default do
  task('spec:unit').invoke
  sh 'rubocop --fail-fast --display-cop-name'
end

namespace :spec do
  Rake::TestTask.new :unit do |task|
    task.test_files = FileList['lib/**/*_spec.rb']
  end
end
