# COMMANDS:
# start: -s, --start=COMMAND
# stop: -k, --kill
# status: -t, --status
# restart: -r, --restart
# list_nodes: -l, --listnodes
# help: --h, --help
#
# MATCHING OPTIONS:
# -n, --node NODENUMBER
#
# GENERIC OPTIONS:
# -a, --all

require 'optparse'
require 'pry'
require_relative './daemon_tasks'

class DaemonInterface
  class ScriptOptions
    attr_accessor :options

    def initialize
      @options = {}
    end

    def define_options(parser)
      start_executing_command_option(parser)
      kill_running_process_option(parser)
      status_of_processes_option(parser)
      restart_current_running_processes_option(parser)
      list_all_node_connections_option(parser)
      nodes_to_execute_on_option(parser)
    end

    private

    def start_executing_command_option(parser)
      parser.on('-s', '--start=PROCESS',
                'Attempts to start executing the process on specified nodes. Options: commits, issues, metadata.'
               ) do |s|
        self.options[:start] = s
      end
    end

    def kill_running_process_option(parser)
      parser.on('-k', '--kill',
                'Kill the currently running process(es) on specified node(s).'
               ) do
        self.options[:kill] = :kill
      end
    end

    def status_of_processes_option(parser)
      parser.on('-t', '--status',
                'Check the status of the specified node(s). DEFAULTS to all.'
                ) do
        self.options[:status] = :status
      end
    end

    def restart_current_running_processes_option(parser)
      parser.on('-r', '--restart',
                'Restart the currently running process(es) on the specified node(s).'
                ) do
        self.options[:restart] = :restart
      end
    end

    def list_all_node_connections_option(parser)
      parser.on('-l', '--listnodes', 'List all nodes you have a connection to.') do
        self.options[:list_nodes] = :list_nodes
      end
    end

    def nodes_to_execute_on_option(parser)
      parser.on('-n', '--nodes=NODE(S)', Array,
                'Specify the node(s), by ID, you wish to act on. Ex: -n 1,3,4'
                ) do |n|
        self.options[:nodes] = n
      end
    end
  end

  def initialize
    @parser = nil
    @options = nil
    @valid_commands = [:start, :kill, :status, :restart, :list_nodes]
  end

  def parse(args)
    @options = ScriptOptions.new
    OptionParser.new do |parser|
      @options.define_options(parser)
      begin
        parser.parse!(args)
      rescue OptionParser::InvalidOption
        raise ArgumentError.new("Invalid option. Please see:\n" + opts.to_s)
      end
    end
    check_input
    @tasks = DaemonTasks.new(opts[:nodes])
    send_command
  end

  attr_reader :parser, :options

  private

  def send_command
    if command == @options.options[:start]
      @tasks.send(:start, command)
    else
      @tasks.send(command)
    end
  end

  def command
    opts = @options.options
    opts[:start] || opts[:kill] || opts[:status] || opts[:restart] || opts[:list_nodes]
  end

  def check_input
    only_one_command?
    valid_process?
    has_nodes_if_command?
    valid_nodes?
    @options
  end

  def valid_process?
    process_opts = ['commits', 'issues', 'metadata']
    start_option = @options.options[:start]
    if start_option && !process_opts.include?(start_option)
      raise ArgumentError.new("PROCESS option must be one of the following: " + process_opts.to_s)
    end
  end

  def only_one_command?
    if !((@valid_commands - @options.options.keys).count == (@valid_commands.count - 1))
      raise ArgumentError.new("Only one command allowed at a time.")
    end
  end

  def valid_nodes?
    nodes = @options.options[:nodes]
    allowed_nodes = DaemonTasks::NODES + ['all']
    nodes.each do |arg_node|
      if !allowed_nodes.include?(arg_node)
        # change this to InvalidNodeError
        raise ArgumentError.new('Invalid node. Must be one of ' + allowed_nodes.to_s)
      end
    end
  end

  def has_nodes_if_executing_command?
    nodes = @options.options[:nodes]
    if nodes.nil? && executing_command?
      # make EmptyNodeError
      raise ArgumentError.new('You need a valid node to execute this command. Otherwise use "all" to specify all nodes.')
    end
  end

  def executing_command?
    @options.option.each do |opt|
      return true if executing_commands.include? opt
    end
    false
  end

  def executing_commands
    [:start, :stop, :restart]
  end

  def non_executing_command?
    @options.options[:status].nil? && @options.options[:list_nodes].nil?
  end
end

DaemonInterface.new.parse(ARGV)
