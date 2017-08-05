# As cli_daemon.rb does not rely on the rails env it's necessary to parse
# the application.yaml file to read in nodes and store them as environment
# variables on your local machine.

# TODO: right now just appends to bashrc without checking if nodes already exist
# this needs to be smarter! Should check if nodes exists, or perhaps write to 
# a separate file and simply store a link in the bashrc to that file
require 'yaml'

lines = File.readlines('./config/application.yml')
lines.each do |l|
  next if l.chomp == "" || l[0] == '#'
  yaml_hash = YAML.load(l)
  key = yaml_hash.keys[0]
  value = yaml_hash[key]
  if key.end_with? '_NODE'
    `echo "export #{key}=#{value}" >> ~/.bashrc`
  end
end
`source ~/.bashrc`
