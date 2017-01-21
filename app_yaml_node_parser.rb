# As cli_daemon.rb does not rely on the rails env it's necessary to parse
# the application.yaml file to read in nodes and store them as environment
# variables on your local machine.

require 'yaml'

lines = File.readlines('./config/application.yml')
lines.each do |l|
  yaml_hash = YAML.load(l)
  key = yaml_hash.keys[0]
  value = yaml_hash[key]
  if key.end_with? '_NODE'
    `echo "export #{key}=#{value}" >> ~/.bashrc`
  end
end
`source ~/.bashrc`
