# vim: set ft=ruby:

require 'rb-fsevent'

# Create a reload function that reloads all files in lib
def reload!
  Object.send(:remove_const, :Kitchenw)
  path = File.expand_path("../", __FILE__)
  Dir.glob("#{path}/**/*.rb") { |f| load f }
end

# Watch for changes and fire off the reload function
def watcher
  fsevent = FSEvent.new
  fsevent.watch Dir.pwd do |directories|
    reload!
  end
  fsevent.run
end

# Load the current directory into the Ruby lib search path,
# then pull in our module
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
#require("kitchenw.rb")

# Kick off the monitoring thread
Thread.start { watcher }
