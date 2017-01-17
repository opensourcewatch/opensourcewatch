require 'nokogiri'
require 'open-uri'
require 'httplog'
# Github_Doc is a class that manages the state of
# a Nokogiri html document to be parsed. It also takes care
# of the error handling with connections started by Nokogiri
class NokoDoc
  def self.new_temp_doc(url)
    check_timeout { Nokogiri::HTML(open(url, @HEADERS_HASH)) }
  end

  def self.check_timeout
    tries ||= 3
    yield
  rescue Timeout::Error => e
    tries -= 1
    if tries > 0
      retry
    else
      puts e.message
    end
  end

  def initialize(agent = "Ruby")
    @HEADERS_HASH = {"User-Agent" => agent}
  end

  def new_doc(url)
    check_timeout { @doc = Nokogiri::HTML(open(url, @HEADERS_HASH)) }
  end

  def doc
    @doc
  end

  private

  def check_timeout
    tries ||= 3
    yield
  rescue Timeout::Error => e
    tries -= 1
    if tries > 0
      retry
    else
      puts e.message
    end
  end
end
