desc 'Generate a word cloud from a users del.ici.ous tags. Pdf with the cloud will be located in the pdf directory.'
task :delicious do
  temp = PaperSizes.new
  @paper_sizes = temp.paper_sizes
  @ordered_sizes = temp.ordered_sizes
  options = {:delicious => 'ninajansen',
             :min_font_size => 12,
             :max_words => 200,
             :font => "Times-Roman",
             :palette => "clay",
             :lang => "DA",
             :short_name => "delicious_200_Times-Roman_mostly_horizontal"
    }
  
  t = time { 
    @cloud = WordCloud.new(options)
    @cloud.place_boxes("mostly_horizontal")
    @cloud.put_placed_boxes_in_pdf
    @cloud.dump_pdf
  }
  puts "execution took #{t} seconds"
end