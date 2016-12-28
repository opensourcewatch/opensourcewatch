class RequestsLogReport 
  def self.present
    File.open("log/requests_benchmarks.log", 'r') do |f|
      requests = IO.readlines(f)[0..-5]
      meta = IO.readlines(f)[-4..-1]

      puts meta
      puts "Processed #{requests.length} requests"
    end
  end
end