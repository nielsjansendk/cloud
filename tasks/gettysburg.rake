require File.dirname(__FILE__) + '/../test/gettysburg.rb'
require File.dirname(__FILE__) + '/../lib/cloud/cloud.rb'
require File.dirname(__FILE__) + '/../lib/cloud/wordbox.rb'

desc 'Generate a word cloud of the Gettysburg address. Pdf with the cloud will be located in the pdf directory.'
task :gettysburg do
  temp = PaperSizes.new
  @paper_sizes = temp.paper_sizes
  @ordered_sizes = temp.ordered_sizes
  options = {:text => GETTYSBURGH, 
             :min_font_size => 12,
             :max_words => 100,
             :font => "Times-Roman",
             :palette => "winter",
             :lang => "EN",
             :output_file =>  File.dirname(__FILE__) + '/../pdf/gettysburg.pdf'
    }
  @cloud = WordCloud.new(options)
  @cloud.place_boxes("horizontal")
  @cloud.put_placed_boxes_in_pdf
  @cloud.dump_pdf
end