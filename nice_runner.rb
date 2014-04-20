require 'open3'

class NiceRunner
  def self.run(options = {}, &prc)
    runner = RunRunner.new
    prc.call(runner)
    runner.result(options)
  end
end

class RunRunner
  attr_accessor :args, :file_number, :output_files

  def initialize
    @args = []
    @file_number = 0
    @output_files = []
  end

  def command(string)
    self.args << string
  end

  def input_file(string)
    File.open("/tmp/#{self.file_number}", "wb") { |f| f.write(string) }
    self.args << "/tmp/#{self.file_number}"
    self.file_number += 1
  end

  def input_files(args)
    args.each { |a| self.input_file(a) }
  end

  def output_file(symbol)
    system("touch /tmp/#{self.file_number}")
    @output_files << ["/tmp/#{self.file_number}", symbol]
    self.args << "/tmp/#{self.file_number}"
    self.file_number += 1
  end

  def stdin(string)
    raise "currently not implemented"
    raise "called stdin twice" if @stdin

    @stdin = string
  end

  def result(options)
    {}.tap do |out|
      command = self.args.join(" ")

      puts "running command: #{command}" if options[:verbose]

      stdout_str, stderr_str, status = Open3.capture3(command)

      self.output_files.each do |file_name, out_name|
        out[out_name] = File.read(file_name)
      end

      (0...self.file_number).each { |n| system("rm /tmp/#{n}") }

      out[:stderr] = stderr_str
      out[:stdout] = stdout_str
    end
  end
end