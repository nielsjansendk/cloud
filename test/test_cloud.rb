class CloudTest < Test::Unit::TestCase
  def setup
    temp = PaperSizes.new
    @paper_sizes = temp.paper_sizes
    @ordered_sizes = temp.ordered_sizes
    @cloud = WordCloud.new({:text => GETTYSBURG})
  end

  def test_paper_sizes
    assert_equal(@paper_sizes["A4"][:width],210)
    assert_equal(@paper_sizes["A4"][:height],297)
    assert_equal(@ordered_sizes[0][0],"A10")
    assert_equal(@ordered_sizes[-1][0],"B0")
  end
  
  def test_pallette
    assert_equal(@cloud.palette.background_color, "#FFFFFF")
    assert_equal(@cloud.palette.font_colors, ["#000000"])
    @cloud = WordCloud.new({:text => GETTYSBURG, :palette => "wb"})
    assert_equal(@cloud.palette.background_color, "#000000")
    assert_equal(@cloud.palette.font_colors, ["#FFFFFF"])
  end

  def test_text
    assert_equal(@cloud.font,"Times-Roman")
    assert_equal(@cloud.min_text_size, 12)
    assert_equal(@cloud.text, GETTYSBURG)
    assert_equal(@cloud.word_freq["nation"],5)
    assert_equal(@cloud.word_freq["dead"],3)
  end

  def test_boxes
    @cloud = WordCloud.new({:text => GETTYSBURG, :palette => "wb"})
    box = @cloud.boxes["nation"]
    assert_equal(box.ll.x,0)
    assert_equal(box.ll.y,0)
    assert_equal(box.ur.x,@cloud.pdf.text_width(" nation ", 12*5))
    assert_equal(box.ur.y,@cloud.pdf.font_height(12*5) + @cloud.pdf.font_descender(12*5))
    assert_equal(box.orientation,"horizontal")
    box.rotate(@cloud.canvas)
    assert_equal(box.orientation,"vertical")    
  end
end