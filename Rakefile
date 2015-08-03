require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

task default: :ci
task ci: [:test, :rubocop]
