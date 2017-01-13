require 'fileutils'

# Fix exceptions for 404 and 500

# Won't work as it's the user of the RUNNING machine:
# user = ENV['USER']

# Will have to ssh this
user = `echo $USER`.chomp

working_directory = "/home/#{user}/workspace/capstone"

pidfile_dir = FileUtils.mkpath("#{working_directory}/.daemon_tasks/tmp").first
execution_dir = FileUtils.mkpath("#{working_directory}/.daemon_tasks/tasks").first

command = ARGV[0]
commands = ['start', 'stop', 'status']
raise ArgumentError.new("Command must include #{commands}") unless commands.include?(command)

process = ARGV[1]
processes = ['commits', 'issues', 'metadata']
raise ArgumentError.new("Command must include #{processes}") unless processes.include?(process)
execution_file = "#{process}_scraper"
pid_file = "#{execution_file}.pid"

pidfile_path = "#{pidfile_dir}/#{pid_file}"
execution_path = "#{execution_dir}/#{execution_file}"

# Create pid file
File.new("#{pidfile_path}", 'w+').close

# Set rake task execution file
task = case ARGV[1]
       when 'commits'
         'rake dispatch:repo_commits'
       when 'issues'
         'rake dispatch:repo_issues'
       when 'metadata'
         'rake dispatch:repo_metadata'
       end

File.open(execution_path, 'w+') do |f|
  bash_path = `which bash`
  f.puts "#!#{bash_path}"
  f.puts task
end
FileUtils.chmod "u=wrx", execution_path

execution = "start-stop-daemon -v --#{command}"
execution += " -m --pidfile #{pidfile_path}"
execution += " -u #{user} -d #{working_directory}"
execution += " -b --exec #{execution_path}"

`#{execution}`





# `start-stop-daemon --start -m --pidfile /home/durendal/workspace/capstone/tmp/commits_scraper.pid -u durendal -d /home/durendal/workspace/capstone -b --startas /home/durendal/workspace/capstone/daemon_rake`
