require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Load database tasks (db:create, db:migrate, db:setup, db:reset, db:drop).
Dir.glob(File.expand_path('tasks/*.rake', __dir__)).sort.each { |task_file| load task_file }

desc 'Run specs'
RSpec::Core::RakeTask.new

task :default => :spec
