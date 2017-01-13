require 'fileutils'

class LogManager
  attr_accessor :current_activity, :last_activity_log

  USER_CANCEL = ''
  PROCESS_KILLED = 'SIGTERM'

  def initialize(current_activity)
    init_log_dir
    @current_activity = current_activity
    @log_file = File.new("#{Rails.root}/log/#{@current_activity}.log", 'a+')
  end

  def log_scraping
    begin_log "Beginning to scrape #{@current_activity} at #{start_time}\n"

    yield if block_given?

  rescue Exception => e
    if e.message == USER_CANCEL
      @last_activity_log = "USER CANCEL\n" + @last_activity_log
    elsif e.message.chomp == PROCESS_KILLED
      @last_activity_log = "PROCESS KILLED\n" + @last_activity_log
    elsif
      @last_activity_log = e.backtrace.unshift(@last_activity_log, e.message)
    end
  ensure
    log_to_file @last_activity_log
    end_log "Ending scraping of #{@current_activity} at #{end_time}\n\n"
    @log_file.close
  end

  private

  def init_log_dir
    FileUtils.mkpath "#{Rails.root}/log"
  end

  def start_time
    Time.now
  end
  alias_method :end_time, :start_time


  def log_to_file(str)
    @log_file.puts str
    @log_file.flush
  end
  alias_method :begin_log, :log_to_file
  alias_method :end_log, :log_to_file
end
