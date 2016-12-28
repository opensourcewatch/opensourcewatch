HttpLog.options[:logger]        = Logger.new('log/requests_benchmarks.log')
HttpLog.options[:color]         = {color: :black, background: :light_red}  
HttpLog.options[:compact_log]   = true