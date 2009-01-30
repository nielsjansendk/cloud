desc 'Generate a word cloud of a blog rss feed. Pdf with the cloud will be located in the pdf directory.'
task :blog do
  temp = PaperSizes.new
  @paper_sizes = temp.paper_sizes
  @ordered_sizes = temp.ordered_sizes
  options = {:rss => 'http://codegirl.dk/?feed=rss2',
             :min_font_size => 12,
             :max_words => 100,
             :font => "Times-Roman",
             :palette => "heat",
             :lang => "DA",
             :distance_type => "ellipse",
             :short_name => "codegirl_100_Times-Roman_horizontal_ellipse",
    }
  
  t = time { 
    @cloud = WordCloud.new(options)
    @cloud.place_boxes("horizontal")
    @cloud.put_placed_boxes_in_pdf
    @cloud.dump_pdf
  }
  puts "execution took #{t} seconds"
end