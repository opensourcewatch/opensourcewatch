require 'fileutils'

# Fix exceptions for 404 and 500

# Won't work as it's the user of the RUNNING machine:
# user = ENV['USER']

# Steps:
# 1. Identify the task that needs to be run
# 2. If a node is required thne make sure there is a values for nodes
# 3. Send that method to be executed
# 4. If the command is start make sure that a valid process is being used

class DaemonTasks
  NODES = [
    'durendal@138.197.20.199',
    'gungnir@45.55.222.220',
    'migl@104.236.81.65'
  ]

  def initialize(nodes = nil)
    @working_directory = "/home/#{user}/workspace/capstone"
    # mkdir dir --parents
    @pidfile_dir = "#{working_directory}/.daemon_tasks/tmp"
    @execution_dir = "#{working_directory}/.daemon_tasks/tasks"

    @pidfile_dir = FileUtils.mkpath("#{working_directory}/.daemon_tasks/tmp").first
    @execution_dir = FileUtils.mkpath("#{working_directory}/.daemon_tasks/tasks").first
  end

  # COMMANDS:
  # start: -s, --start
  # stop: -k, --kill
  # status: -t, --status
  # restart: -r, --restart
  # list_nodes: -l, --listnodes
  # help: --h, --help
  #
  # PROCESSES:
  # scrape commits: -c, --commits
  # scrape metadata: -m, --metadata
  # scrape issues: -i, --issues
  #
  # MATCHING OPTIONS:
  # -n, --node NODENUMBER
  #
  # GENERIC OPTIONS:
  # -a, --all
  def list_nodes
    NODES.each_with_index do |el, i|
      puts "#{i}:"
      name, ip = el.split('@')
      puts "\tNAME: #{name}"
      puts "\tIP: #{ip}"
      puts
    end
  end

  # OPTIONS:
  # -a;--all, -n;--node
  # Needs to check if currently running
  def start(process)
    execution = "start-stop-daemon -v --start"
    execution += " -m --pidfile #{pidfile_path}"
    execution += " -u #{user} -d #{working_directory}"
    execution += " -b --exec #{execution_path}"
  end

  def kill
    @execution_file = "#{process}_scraper"
  end

  def restart
    stop('all')
    start('all')
  end

  def status

  end

  private

  def user
    `echo $USER`.chomp
  end

  def pid_file
    "#{execution_file}.pid"
  end
end

# Will have to ssh this
user = `echo $USER`.chomp

working_directory = "/home/#{user}/workspace/capstone"

pidfile_dir = FileUtils.mkpath("#{working_directory}/.daemon_tasks/tmp").first
execution_dir = FileUtils.mkpath("#{working_directory}/.daemon_tasks/tasks").first

#### TO HERE DONE

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
