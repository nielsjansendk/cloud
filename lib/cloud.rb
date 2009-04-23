$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

  require File.dirname(__FILE__) + '/cloud/cloud.rb'
  require File.dirname(__FILE__) + '/cloud/wordbox.rb'
  require File.dirname(__FILE__) + '/cloud/object_stash.rb'
  require File.dirname(__FILE__) + '/cloud/rss.rb'
module Cloud
  VERSION = '0.0.7'
end