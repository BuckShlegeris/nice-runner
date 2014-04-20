require "./nice_runner.rb"

r = NiceRunner.run do |r|
  r.command 'cat'
  r.input_file "hello "
  r.input_file "world"
  r.command " > "
  r.output_file :out
end
