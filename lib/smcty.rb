require 'smcty/console'

class Smcty
  def self.start(path)
    puts "Starting Simcity Production Assistent"
    puts "> load configuration from #{path}"

    console = Console.new($stdin, path)
    console.prompt!
  end
end
