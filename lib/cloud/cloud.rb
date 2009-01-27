class PaperSizes
  attr_accessor :paper_sizes, :ordered_sizes
  def initialize
    @paper_sizes = Hash.new
    @paper_sizes["A0"] = {:height => 1189, :width => 841}
    @paper_sizes["B0"] = {:height => 1414, :width => 1000}
    @paper_sizes["C0"] = {:height => 1297, :width => 917}

    (2..10).step(2) {|x|
      ["A","B","C"].each {|type|
        height =  @paper_sizes[type + (x-2).to_s][:height]/2
        width =  @paper_sizes[type + (x-2).to_s][:width]/2
        @paper_sizes[type + x.to_s] = {:height => height, :width => width}
      }
    }

    (1..9).step(2) {|x| 
      ["A","B","C"].each {|type|     
        height = @paper_sizes[type + (x-1).to_s][:width]
        width =  @paper_sizes[type + (x+1).to_s][:height]
        @paper_sizes[type + x.to_s] = {:height => height, :width => width}
      }
    }

    @paper_sizes.each{ |key, sizes|
      @paper_sizes[key] = {:width => sizes[:width], :height => sizes[:height], :area => sizes[:width]*sizes[:height]}
    }
    @ordered_sizes = @paper_sizes.sort {|a,b| a[1][:area]<=>b[1][:area]}
  end
end

class Palette
  attr_accessor :background_color, :font_colors
  @@palettes = {"wb" => ["#000000","#FFFFFF"],
    "bw" => ["#FFFFFF","#000000"],
    "blue-brown" => ["#FFFFFF", "#002231","#00597E","#504540","#CD8D56"],
    "clay" =>  ["#000000","#714C3F","#B1584F","#D4C0C4","#F8D6E5","#BC8588"],
    "winter" =>  ["#000000","#345379", "#4072B0", "#4586D2", "#9BBDF6", "#A0BDEB"],
    "heat" => ["#FFFFFF","#150000", "#770000", "#FF0000", "#CB0000", "#FF4200"],
    "ocean" => ["#FFFFFF","#00613C", "#005BC4", "#0091F5", "#FFFFFF", "#41A85D"],
    "blue-yellow" => ["#FFFFFF", "#224466", "#667788", "#ccaa66", "#8899aa","#ffeebb"]
  }
  def initialize(name)
    @background_color = @@palettes[name][0]
    size =  @@palettes[name].size
    @font_colors = @@palettes[name][1..size]
  end
end

class WordCloud
  attr_accessor :text, :word_freq, :min_text_size, :font, :pdf, :boxes, :canvas, :ordered_boxes, :placed_boxes, :placements, :palette, :common
  def initialize(text, min_text_size, font, palette = "bw", lang = "EN")
    @text = text
    @font = font
    if lang = "EN"
      @common = COMMON_EN
    else
      @common = COMMON_EN
    end
    @palette = Palette.new(palette) 
    @min_text_size = min_text_size
    @pdf = PDF::Writer.new 
    @pdf.select_font font
    @word_freq = self.compute_frequencies
    @boxes = self.init_boxes
    @ordered_boxes = @boxes.sort {|a,b| @word_freq[b[0]] <=> @word_freq[a[0]]}
    @placed_boxes = Hash.new
    @placements = Array.new
  end

  def compute_frequencies
    words = @text.split($/).join(" ").squeeze(" ").split(" ")

    freq = Hash.new(0)
    count = 0

    words.each{|word|
      if word =~ /(\W)$/
        word = word.delete $1
      end
      word = word.downcase
      if !self.common.include? word
        freq[word] = freq[word] +1
        count = count + 1
      end
    }
    freq
  end
  def init_boxes
    sizes = Hash.new
    @word_freq.each {|word, count|
      width =  self.pdf.text_width(" " + word + " ",self.min_text_size*count)
      height = self.pdf.font_height(self.min_text_size*count)
      if word !~ /g|j|p|q|y/
        height =  height + self.pdf.font_descender(count*self.min_text_size)
      end
      #area in mm^2 to compare to paper sizes
      area = width*0.3528*height*0.3528
      sizes[word] = {:width => width , :height => height, :area => area}
    }

    total_area = 0
    sizes.each_value {|value|
      total_area = total_area +  value[:area]
    } 

    ordered_sizes = PaperSizes.new.ordered_sizes
    paper = ""
    canvas_width = 0
    canvas_height = 0

    ordered_sizes.each{|key, value|
      if value[:area] > 2*total_area
        paper = key
        canvas_width = PDF::Writer.mm2pts(value[:width])
        canvas_height = PDF::Writer.mm2pts(value[:height])
        break
      end
    }
    #orientation is landscape by default, so we need to switch width and height
    self.canvas = WordBox::Canvas.new(canvas_height, canvas_width)

    self.pdf = PDF::Writer.new :paper => paper, :orientation => :landscape
    self.pdf.select_font self.font

    if self.palette.background_color != "#FFFFFF"
      pdf.fill_color Color::RGB.from_html(self.palette.background_color)
      pdf.rectangle(0, 0, pdf.page_width, pdf.page_height).fill
    end

    boxes = Hash.new
    sizes.each {|word, value|
      box = WordBox::Box.new
      box.set_from_width_and_height(value[:width],value[:height])
      boxes[word] = box
    }
    boxes
  end

  def write_word_in_box(word,freq,box,include_box = false, color_index = 0)
    pdf.fill_color    Color::RGB::from_html(self.palette.font_colors[color_index])
    pdf.stroke_color  Color::RGB::from_html(self.palette.font_colors[color_index])

    descender = - 1.5*self.pdf.font_descender(freq*self.min_text_size)
    if word !~ /g|j|p|q|y/
      descender = - 0.75 * self.pdf.font_descender(freq*self.min_text_size)
    end

    if include_box
      self.pdf.rectangle(box.ll.x, box.ll.y, box.lr.x - box.ll.x, box.ul.y - box.ll.y).stroke
    end
    if box.orientation == "vertical"
      self.pdf.add_text(box.lr.x - descender, box.lr.y, " " + word + " ", freq*self.min_text_size, angle = 90)
    else
      self.pdf.add_text(box.ll.x, box.ll.y + descender, " " + word + " ", freq*self.min_text_size, angle = 0)
    end

  end

  def output_box(box)
    self.pdf.rectangle(box.ll.x, box.ll.y, box.lr.x - box.ll.x, box.ul.y - box.ll.y).stroke
  end

  def dump_pdf
    self.pdf.save_as "cloud.pdf"
    #File.open("cloud.pdf", "wb") { |f| f.write self.pdf.render }
  end

  def place_first_box(rotation_type)
    first_box = self.ordered_boxes.first[1]
    if rotation_type == "all_vertical"
      first_box.rotate(self.canvas)
    end
    first_box.place_center_at_point(self.canvas.center,self.canvas)
    self.placed_boxes[self.ordered_boxes.first[0]] = first_box
    self.placements = first_box.enter_points_in_placements(self.placements, self.canvas)
    self.placements = self.placements.sort {|a,b| a.distance<=>b.distance}
  end

  def clean_placements(diagonal = nil)
    unit_box = WordBox::Box.new
    width =  self.pdf.text_width("   ",self.min_text_size)
    height = self.pdf.font_height(self.min_text_size)
    unit_box.set_from_width_and_height(width,height)
    self.placements.each_with_index {|placement,index| 
      if diagonal && placement.distance_to_last >= diagonal
        next
      else
        placed = false
        placement.opposite.each {|opposite|
          p = WordBox::Placement.new(placement.point,self.canvas,opposite)
          position = opposite
          p.place_box_at_placement(unit_box,self.canvas)
          ok = true
          self.placed_boxes.each {|key,box2|
            if box2.overlap?(unit_box, false)
              ok = false
              break
            end
          }
          if ok
            placed = true
            break
          end
        }
        if !placed
          self.placements.delete_at(index)
        end
      end
    }
  end      

  def place_boxes(rotation_type)
    self.place_first_box(rotation_type)
    i = 0
    unit_box = WordBox::Box.new
    width =  self.pdf.text_width("   ",self.min_text_size)
    height = self.pdf.font_height(self.min_text_size)

    self.ordered_boxes.each {|word,box|
      if word == self.ordered_boxes.first[0]
        next
      end

      if rotation_type == "half_and_half"
        if (i % 2 == 1)
          box.rotate(self.canvas)
        end
      elsif rotation_type == "all_vertical"
        box.rotate(self.canvas)
      elsif rotation_type == "mostly_horizontal"
        if (i % 10 == 1)
          box.rotate(self.canvas)
        end
      elsif rotation_type == "mostly_vertical"
        if (i % 10 != 1)
          box.rotate(self.canvas)
        end
      end

      #try placements until a fit is found
      final_placement = nil
      position = ""
      j = 0
      self.placements.each_with_index {|placement,index| 
        j = j+1
        p "trying placement #{j} #{placement.position}"
        placed = false
        final_placement = index
        placement.opposite.each {|opposite|
          ok = true
          p = WordBox::Placement.new(placement.point,self.canvas,opposite)
          position = opposite
          if !p.place_box_at_placement(box,self.canvas)
            ok = false
          end

          self.placed_boxes.each {|key,box2|
            if box2.overlap?(box,true)
              ok = false
              break
            end
          }
          if ok
            placed = true
            break  
          end
        }
        if placed
          break
        end
      }

      self.placed_boxes[word] = box
      self.placements.delete_at(final_placement)

      self.placements = box.enter_points_in_placements(self.placements, self.canvas, position)

      self.clean_placements(box.diagonal)

      self.placements = self.placements.sort {|a,b| a.distance<=>b.distance}

      i = i + 1
      if i > 100   
        break
      end
    }
  end

  def put_placed_boxes_in_pdf
    color_index = 0
    self.placed_boxes.each {|word, box|
      self.write_word_in_box(word,self.word_freq[word],box,false,color_index)
      color_index = color_index + 1
      if color_index > self.palette.font_colors.size - 1
        color_index = 0
      end
    }
  end
end

COMMON_EN = %w(
a about after again against all an another any and are as at
be being been before but by
can could
did do don't down
each 
few from for
get got great
had has have he her here his him himself hers how
i if i'm in into is it it's
just
like
made me more most my
no not
of off on once one only or other our out over own
said she should so some such 
than that the their them then there these they this those through to too
under until up 
very
was wasn't we were we're what when where which while who why will with would wouldn't
you your)