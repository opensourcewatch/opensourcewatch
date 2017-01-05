class RequestsLogReport 
  def self.present
    File.open("log/requests_benchmarks.log", 'r') do |f|
      # TODO: SHOULD READ BASED ON DELIMITERS
      requests = IO.readlines(f)[0..-6]
      meta = IO.readlines(f)[-5..-1]

      puts meta
      puts "Processed #{requests.length} requests"
    end
  end
end