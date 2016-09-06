# Unicorn configuration
require 'fileutils'

APP_ROOT = File.expand_path '../', File.dirname(__FILE__)

worker_processes 3
working_directory APP_ROOT

timeout 30
FileUtils.mkdir_p "#{APP_ROOT}/tmp/sockets" unless Dir.exists? "#{APP_ROOT}/tmp/sockets"
FileUtils.mkdir_p "#{APP_ROOT}/tmp/pids/" unless Dir.exists? "#{APP_ROOT}/tmp/pids/"
FileUtils.mkdir_p "#{APP_ROOT}/logs/" unless Dir.exists? "#{APP_ROOT}/logs/"
# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
listen "#{APP_ROOT}/tmp/sockets/unicorn.sock", :backlog => 64

# Set process id path
pid "#{APP_ROOT}/tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{APP_ROOT}/logs/unicorn.stderr.log"
stdout_path "#{APP_ROOT}/logs/unicorn.stdout.log"