require 'rubygems'
require 'bundler'
require 'rake'

$LOAD_PATH << File.expand_path('./lib', File.dirname(__FILE__))

task :export_env_vars do
  require 'dotenv'
  Dotenv.load
end


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec
Rake::Task["export_env_vars"].invoke
require 'tasks/files_task'
Athena::Tasks::FilesTask.new.install_tasks
require 'pandora/tasks/db_task'
Pandora::Tasks::DBTask.new.install_tasks
