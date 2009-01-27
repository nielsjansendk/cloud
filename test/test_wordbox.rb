class WordBoxTest < Test::Unit::TestCase
  include WordBox
  def setup
    @box = WordBox::Box.new
    @canvas = WordBox::Canvas.new(10,10)
  end

  def test_point
    point1 = Point.new(1.0,1.0)
    point2 = Point.new(1.0,1.0)
    assert_equal(point1 == point2, true)
    point3 = Point.new(1.0,2.0)
    assert_equal(point1 == point3, false)

    assert_equal(point1.distance_to_point(point2), 0.0)
    assert_equal(point1.distance_to_point(point3), 1.0)
    assert_equal(point3.distance_to_point(point1), 1.0)

    point4 = Point.new(0.0,0.0)
    assert_equal(point4.distance_to_point(point1), Math.sqrt(2))
  end

  def test_box_init
    ["ll","ul","lr","ur","center","cb","ct","cl","cr"].each {|methodname|
      assert_equal(@box.method(methodname.intern).call.x,0)
      assert_equal(@box.method(methodname.intern).call.y,0)
    }
  end

  def test_canvas_init
    assert_equal(@canvas.max.x,10)
    assert_equal(@canvas.max.y,10)
    assert_equal(@canvas.center.x,5)
    assert_equal(@canvas.center.y,5)
  end

  def test_set_from_width_and_height
    @box.set_from_width_and_height(1,1)
    ["ll","lr","cb"].each {|methodname|
      assert_equal(@box.method(methodname.intern).call.y,0)
    }
    ["ul","ur","ct"].each {|methodname|
      assert_equal(@box.method(methodname.intern).call.y,1)
    }
    ["ll","ul","cl"].each {|methodname|
      assert_equal(@box.method(methodname.intern).call.x,0)
    }
    ["lr","ur","cr"].each {|methodname|
      assert_equal(@box.method(methodname.intern).call.x,1)
    }
    ["center","cb","ct"].each {|methodname|
      assert_equal(@box.method(methodname.intern).call.x,0.5)
    }
    ["center","cr","cl"].each {|methodname|
      assert_equal(@box.method(methodname.intern).call.y,0.5)
    }
    assert_equal(@box.width,1.0)
    assert_equal(@box.height,1.0)
    assert_equal(@box.diagonal,Math.sqrt(2))
    @box.set_from_width_and_height(2,1)
    assert_equal(@box.diagonal,Math.sqrt(5))
  end

  def test_box_equality
    @box.set_from_width_and_height(1,1)
    box2 = WordBox::Box.new
    box2.set_from_width_and_height(1,1)
    assert_equal(box2 == @box, true)
    @box.place_ul_at_point(Point.new(5,5),@canvas)
    assert_equal(box2 == @box, false)
  end

  def test_total_diagonal
    @box.set_from_width_and_height(1,1)
    box2 =  WordBox::Box.new
    box2.set_from_width_and_height(1,1)
    box2.place_ll_at_point(Point.new(1,1),@canvas)
    assert_equal(@box.total_diagonal(box2), 2.0*Math.sqrt(2))

    box3 =  WordBox::Box.new
    box3.set_from_width_and_height(2,1)
    box3.place_ll_at_point(Point.new(1,1),@canvas)
    assert_equal(@box.total_diagonal(box3), Math.sqrt(9 + 4))
    assert_equal(@box.min_total_diagonal(box3), Math.sqrt(9 + 4))
    assert_equal(@box.close?(box3), true)

    box4 =  WordBox::Box.new
    box4.set_from_width_and_height(2,1)
    box4.place_ll_at_point(Point.new(2,2),@canvas)
    assert_equal(@box.min_total_diagonal(box4), Math.sqrt(9 + 4))
    assert_equal(@box.total_diagonal(box4),5)
    assert_equal(@box.close?(box4), false)

    box5 =  WordBox::Box.new
    box5.set_from_width_and_height(1,1)
    box5.place_cl_at_point(Point.new(1,0.5),@canvas)
    assert_equal(@box.total_diagonal(box5),Math.sqrt(5))
    assert_equal(@box.min_total_diagonal(box5),2*Math.sqrt(2))
    assert_equal(@box.close?(box5), true)
  end

  def test_place_ul_at_point
    @box.set_from_width_and_height(1,1)
    area_before = @box.area  
    assert_equal(@box.place_ul_at_point(Point.new(5,5),@canvas),true)
    assert_equal(@box.ul.x,5)
    assert_equal(@box.ul.y,5)
    assert_equal(@box.area,area_before)
    assert_equal(@box.place_ul_at_point(Point.new(10,5),@canvas),false)
  end

  def test_place_center_at_point
    @box.set_from_width_and_height(1,1)
    area_before = @box.area  
    assert_equal(@box.place_center_at_point(Point.new(5,5),@canvas),true)
    assert_equal(@box.center.x,5)
    assert_equal(@box.center.y,5)
    assert_equal(@box.area,area_before)
    assert_equal(@box.place_center_at_point(Point.new(10,5),@canvas),false)
  end

  def test_point_in_box
    @box.set_from_width_and_height(1,1)
    assert_equal(@box.point_in_box?(Point.new(1,1)), false)
    assert_equal(@box.point_in_box?(Point.new(1,0.5)), false)
    assert_equal(@box.point_in_box?(Point.new(0,0.5)), false)
    assert_equal(@box.point_in_box?(Point.new(0.5,1)), false)
    assert_equal(@box.point_in_box?(Point.new(0.5,1)), false)
    assert_equal(@box.point_in_box?(Point.new(0.5,0.5)), true)
    @box.set_from_width_and_height(2,2)
    @box.place_ll_at_point(Point.new(2.0,2.0),@canvas)
    assert_equal(@box.point_in_box?(Point.new(2.0,2.0)), false)
    @box.set_from_width_and_height(2,2)
    box2 = WordBox::Box.new
    box2.set_from_width_and_height(1,1)
    box2.place_ll_at_point(Point.new(2.0,2.0),@canvas)
    ["center","cl","cr","ct","cb"].each {|c|
      assert_equal(@box.point_in_box?(box2.method(c).call), false)
      assert_equal(box2.point_in_box?(@box.method(c).call), false)
    }

  end

  def test_overlap
    @box.set_from_width_and_height(2,2)
    box2 = WordBox::Box.new
    box2.set_from_width_and_height(1,1)
    #assert_equal(@box.overlap?(box2),true)
    box2.place_ll_at_point(Point.new(2.0,2.0),@canvas)
    assert_equal(@box.overlap?(box2),false)

    box2.place_ll_at_point(Point.new(0.0,2.0),@canvas)
    assert_equal(@box.overlap?(box2),false)    

    box2.place_ll_at_point(Point.new(0,1.9),@canvas)
    assert_equal(@box.overlap?(box2),true)

    box3 = WordBox::Box.new
    box3.set_from_width_and_height(2,2)
    assert_equal(@box.overlap?(box3),true)
  end

  def test_distance_to_center
    @box.set_from_width_and_height(1,1)
    assert_equal(@box.ll.distance_to_center(@canvas), Math.sqrt(25*2))
  end

  def test_enter_points_in_placements
    @box.set_from_width_and_height(1,1)
    placements = @box.enter_points_in_placements(Array.new, @canvas)
    assert_equal(placements[-1].distance, Math.sqrt(25*2))
    assert_equal(placements[0].distance, Math.sqrt(16*2))
    ["ll","ul","lr","ur","cb","ct","cl","cr"].each {|position|
      assert_not_nil(placements.find {|placement| placement.position == position})
    }
    placements = @box.enter_points_in_placements(Array.new, @canvas, "ul")
    assert_nil(placements.find {|placement| placement.position == "ul"})
    ["ll","lr","ur","cb","ct","cl","cr"].each {|position|
      assert_not_nil(placements.find {|placement| placement.position == position})
    }
    placements = @box.enter_points_in_placements(Array.new, @canvas, "ll")
    assert_equal(placements.find {|placement| placement.position == "ur"}.distance_to_last,Math.sqrt(2))  
    assert_equal(placements.find {|placement| placement.position == "ul"}.distance_to_last,1) 
    assert_equal(placements.find {|placement| placement.position == "cb"}.distance_to_last,0.5)
  end

  def test_place_box_at_placement
    box = WordBox::Box.new.set_from_width_and_height(1,1)
    placements = box.enter_points_in_placements(Array.new, @canvas)
    box2 = WordBox::Box.new.set_from_width_and_height(1,1)
    ["ul","ll","lr","cb","cl"].each {|position|
      placement = placements.find {|placement| placement.position == position}  
      assert_equal(placement.place_box_at_placement(box2,@canvas),true)
    }
    ["ct","ur","cr"].each {|position|
      placement = placements.find {|placement| placement.position == position}
      assert_equal(placement.place_box_at_placement(box2,@canvas),true)
    }
  end

  def test_linesegment
    point1 = WordBox::Point.new(0,0)
    point2 = WordBox::Point.new(1,0)
    point3 = WordBox::Point.new(1,1)
    point4 = WordBox::Point.new(0,1)
    point5 =  WordBox::Point.new(2,2)

    segment1 = WordBox::LineSegment.new(point1,point2)
    assert_equal(segment1.start_point.x,0)
    assert_equal(segment1.start_point.y,0)
    assert_equal(segment1.end_point.x,1)
    assert_equal(segment1.end_point.y,0)

    segment2 = WordBox::LineSegment.new(point1,point3)
    segment3 = WordBox::LineSegment.new(point2,point4)

    assert_equal(segment2.intersect?(segment3),true)
    assert_equal(segment1.intersect?(segment3),false)
    assert_equal(segment2.intersect?(segment1),false)

    segment4 = WordBox::LineSegment.new(point1,point5)
    assert_equal(segment1.intersect?(segment4),false)
    segment5 = WordBox::LineSegment.new(point3,point5)

    assert_equal(segment4.intersect?(segment5),false)     
  end 

  def test_overlapping_linesegment
    point1 = WordBox::Point.new(0,0)
    point2 = WordBox::Point.new(2,0)
    point3 = WordBox::Point.new(1,0)
    point4 = WordBox::Point.new(1,1)

    segment1 = WordBox::LineSegment.new(point1,point2)
    segment2 = WordBox::LineSegment.new(point3,point4)

    assert_equal(segment1.intersect?(segment2),false)  

    point1 = WordBox::Point.new(0,0)
    point2 = WordBox::Point.new(0,2)
    point3 = WordBox::Point.new(0,1)
    point4 = WordBox::Point.new(1,1)

    segment1 = WordBox::LineSegment.new(point1,point2)
    segment2 = WordBox::LineSegment.new(point3,point4)

    assert_equal(segment1.intersect?(segment2),false)

  end  

  def test_rotate
    @box.set_from_width_and_height(2,1)
    @box.rotate(@canvas)
    assert_equal(@box.width,1)
    assert_equal(@box.height,2)
    assert_equal(@box.center,Point.new(0.5,1))
  end
end