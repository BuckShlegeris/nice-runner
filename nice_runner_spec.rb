require "./nice_runner.rb"

describe "runner" do
  # I run all the tests twice to check for them screwing each other up.
  2.times do |round|
    describe "round #{round}" do
      describe "testing with cat" do
        it "works with output files" do
          expect(Dir.entries("/tmp") & ["0", "1", "2"]).to eq([])

          r = NiceRunner.run do |r|
            r.command 'cat'
            r.input_file "hello "
            r.input_file "world"
            r.command " > "
            r.output_file :out
          end

          expect(r).to eq({:out=>"hello world", :stderr=>"", :stdout=>""})
        end

        it "works with stdout" do
          expect(Dir.entries("/tmp") & ["0", "1", "2"]).to eq([])

          r = NiceRunner.run do |r|
            r.command 'cat'
            r.input_file "hello "
            r.input_file "world"
          end

          expect(Dir.entries("/tmp") & ["0", "1", "2"]).to eq([])

          expect(r).to eq({:stderr=>"", :stdout => "hello world"})
        end
      end

      describe "testing with echo" do
        it "works with stdout" do
          r = NiceRunner.run { |r| r.command "echo 'whatever'" }
          expect(r).to eq({:stderr=>"", :stdout => "whatever\n"})
        end

        it "works with output files" do
          r = NiceRunner.run { |r| r.command "echo 'whatever' > "; r.output_file :out }
          expect(r).to eq({:out=>"whatever\n", :stderr=>"", :stdout=>""})
        end
      end

      describe "testing python" do
        it "works with stdout" do
          r = NiceRunner.run { |r| r.command "python"; r.input_file "print 'hey'"}
          expect(r).to eq({:stderr=>"", :stdout=>"hey\n"})
        end

        it "works with stderr" do
          r = NiceRunner.run { |r| r.command "python"; r.input_file "print lol"}
          expect(r).to eq({:stderr=>"Traceback (most recent call last):\n  File \"/tmp/0\", line 1, in <module>\n    print lol\nNameError: name 'lol' is not defined\n", :stdout=>""})
        end
      end
    end
  end
end