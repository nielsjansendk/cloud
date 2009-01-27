require File.dirname(__FILE__) + '/../test/gettysburg.rb'
require File.dirname(__FILE__) + '/../lib/cloud/cloud.rb'
require File.dirname(__FILE__) + '/../lib/cloud/wordbox.rb'

desc 'Generate a word cloud of the Gettysburg address'
task :gettysburg do
  temp = PaperSizes.new
  @paper_sizes = temp.paper_sizes
  @ordered_sizes = temp.ordered_sizes
  @cloud = WordCloud.new(GETTYSBURG,12,"Times-Roman","winter")
  @cloud.place_boxes("horizontal")
  @cloud.put_placed_boxes_in_pdf
  @cloud.dump_pdf
end