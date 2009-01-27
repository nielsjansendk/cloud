module WordBox
  class Point
    attr_accessor :x, :y
    def initialize(x,y)
      @x = x
      @y = y
    end
  end
  class Canvas
    attr_accessor :max, :center
    def initialize(x,y)
      @max = Point.new(x,y)
      @center = Point.new(x/2.0,y/2.0)
    end
  end

  class Point    
    def distance_to_center(canvas)
      Math.sqrt((self.x - canvas.center.x)**2 + (self.y - canvas.center.y)**2)
    end
    
    def ==(point)
      self.x == point.x && self.y == point.y
    end
    
    def distance_to_point(point)
      Math.sqrt((self.x - point.x)**2 + (self.y - point.y)**2)
    end
  end

  class Placement
    attr_accessor :point, :distance, :position, :opposite, :distance_to_last
    @@opposite_positions = {"ll" => ["ur","lr","ul","cr"],
                            "ul" => ["lr","ur","ll","cr"],
                            "lr" => ["ul","ll","ur","cl"],
                            "ur" => ["ll","ul","lr","cl"],
                            "cb" => ["ct","ul","ur"],
                            "ct" => ["cb","ll","lr"],
                            "cl" => ["cr","lr","ur"],
                            "cr" => ["cl","ll","ul"]}
    def initialize(point, canvas, position, last = nil)
      @point = point
      @distance = point.distance_to_center(canvas)
      @position = position
      @opposite = @@opposite_positions[position]
      if last
        @distance_to_last = point.distance_to_point(last)
      else
        @distance_to_last = 0.0
      end
    end

    def place_box_at_placement(box,canvas)
      if box.send("place_" + self.position + "_at_point", self.point, canvas)
        return true
      else
        return false
      end
    end
  end
  
  class LineSegment
    attr_accessor :start_point, :end_point
   
    def initialize(point1,point2)
      @start_point = point1
      @end_point = point2
    end
    
    inline do |builder|
      builder.include "<math.h>"
      builder.c "    
      int lineSegmentIntersection(double Ax, double Ay,double Bx, double By,double Cx, double Cy, double Dx, double Dy) {
       double  distAB, theCos, theSin, newX, ABpos ;

       //  Fail if either line segment is zero-length.
       if (Ax==Bx && Ay==By || Cx==Dx && Cy==Dy) return 0;

       //  Fail if the segments share an end-point. 
       if (Ax==Cx && Ay==Cy || Bx==Cx && By==Cy || Ax==Dx && Ay==Dy || Bx==Dx && By==Dy) {
          return 0; 
       }    

        //  (1) Translate the system so that point A is on the origin.
        Bx-=Ax; By-=Ay;
        Cx-=Ax; Cy-=Ay;
        Dx-=Ax; Dy-=Ay;

        //  Discover the length of segment A-B.
        distAB=sqrt(Bx*Bx+By*By);

        //  (2) Rotate the system so that point B is on the positive X axis.
        theCos=Bx/distAB;
        theSin=By/distAB;
        newX=Cx*theCos+Cy*theSin;
        Cy  =Cy*theCos-Cx*theSin; Cx=newX;
        newX=Dx*theCos+Dy*theSin;
        Dy  =Dy*theCos-Dx*theSin; Dx=newX;
        

        //  Fail if segment C-D doesn't cross line A-B.
        if (Cy<=0. && Dy<=0. || Cy >= 0. && Dy >= 0.) return 0;

        //  (3) Discover the position of the intersection point along line A-B.
        ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);

        //  Fail if segment C-D crosses line A-B outside of segment A-B.
        if (ABpos<=0. || ABpos>=distAB) return 0;

        //  Success.
        return 1;
      }
      "
    end
    
    def intersect?(segment)  
      self.lineSegmentIntersection(self.start_point.x,self.start_point.y,
                                                          self.end_point.x,self.end_point.y,segment.start_point.x,segment.start_point.y,
                                                          segment.end_point.x,segment.end_point.y) == 1
    end
  end
  

  class Box
    attr_accessor :ul, :ur, :ll, :lr, :center, :cb, :ct, :cl, :cr, :segments, :width, :height, :diagonal, :orientation
    @@positions = ["ll","ul","lr","ur","center","cb","ct","cl","cr"]
    @@edge_positions = ["ll","ul","lr","ur","cb","ct","cl","cr"]
    @@place_regex = /place_(.*?)_at_point/

    def initialize
      @ul = Point.new(0,0)
      @ur = Point.new(0,0)
      @ll = Point.new(0,0)
      @lr = Point.new(0,0)
      @center = Point.new(0,0)
      @cb = Point.new(0,0)
      @ct = Point.new(0,0)
      @cl = Point.new(0,0)
      @cr = Point.new(0,0)
      @width = 0.0
      @height = 0.0
      @diagonal = 0.0
      @orientation = "horizontal"
      @segments = [LineSegment.new(@ll,@ul),LineSegment.new(@ul,@ur),LineSegment.new(@ur,@lr),LineSegment.new(@ll,@lr)]
    end
    
    def ==(box)
      self.ll == box.ll && self.ul == box.ul && self.ur == box.ur && self.lr == box.lr
    end
    
    def set_from_width_and_height(width, height)
      self.width = width
      self.height = height
      self.ul = Point.new(0,height.to_f)
      self.lr = Point.new(width.to_f, 0.0)
      self.ur = Point.new(width, height)
      self.center = Point.new(width/2.0, height/2.0)
      self.cb = Point.new((self.lr.x - self.ll.x)/2.0,0)
      self.ct = Point.new((self.ur.x - self.ul.x)/2.0, height.to_f)
      self.cl = Point.new(0, (self.ul.y - self.ll.y)/2.0)
      self.cr = Point.new(width.to_f, (self.ur.y - self.lr.y)/2.0)
      self.diagonal = self.ll.distance_to_point(self.ur)
      self.segments = [LineSegment.new(self.ll,self.ul),LineSegment.new(self.ul,self.ur),LineSegment.new(self.ur,self.lr),LineSegment.new(self.ll,self.lr)]
      self
    end
    
    def rotate(canvas)
      #rotates box 90 degrees counterclockwise
      ll = self.ll
      p ll
      self.set_from_width_and_height(self.height,self.width)
      self.place_ll_at_point(ll,canvas)
      self.orientation = "vertical"
      self
    end

    def area
      x = self.lr.x - self.ll.x
      y = self.ul.y - self.ll.y
      x*y
    end
    
    inline do |builder|
      builder.c "      
      int c_point_in_box(double llx, double lly, double ulx, double uly, double urx, double ury, double lrx, double lry, double pointx, double pointy) {
        double v[8] = {llx,lly,ulx,uly,urx,ury,lrx,lry};
        double p[2] = {pointx,pointy};
        int i, count, e_count;
        int n = 4;
        int value;
        double x1;
        double x2;
        double y1;
        double y2;
        double rhs;
        double lhs;
        double v1x,v1y,v2x,v2y;
        int edge;
    
        value = 0;
        edge = 0;
        
        v1x = lrx;
        v1y = lry;
    
        for ( i = 0; i < n; i++ ) {
          v2x = v[0+i*2];
          v2y = v[1+i*2];
    
          if (v2x > v1x) {
            x1 = v1x;
            y1 = v1y;
            x2 = v2x;
            y2 = v2y;
          } else {
            x1 = v2x;
            y1 = v2y;
            x2 = v1x;
            y2 = v1y;
          }  
            
          if ((pointx == x1) || (y2 == y1)) {
            rhs = 0.0;
          } else {
            rhs = (y2-y1)*(pointx-x1);
          }
          
          if ((pointy == y1) || (x2 == x1)){
            lhs = 0.0;
          } else {
            lhs = (pointy-y1)*(x2-x1);
          }
          
          if (lhs == rhs) {
            e_count++;
            edge = 1;
          }              
              
          if ((x2 < pointx) == (pointx <= x1)) { 
            if (lhs < rhs) {
              count++;
              value = !value;
            }
          }
          v1x = v2x;
          v1y = v2y;
        }  
        return value && !edge;
      }
      "
    end
    
    def point_in_box?(point)
      self.c_point_in_box(self.ll.x, self.ll.y, self.ul.x, self.ul.y,  self.ur.x,  self.ur.y,  self.lr.x,  self.lr.y, point.x, point.y) == 1    
    end
    
    def total_diagonal(box)
      #finds the largest diagonal of that smallest box that encompases both boxes
      diag1 = self.ll.distance_to_point(box.ur)
      diag2 = self.ul.distance_to_point(box.lr)
      diag1 > diag2 ? diag1 : diag2
    end
    
    def min_total_diagonal(box)
      Math.sqrt((self.width + box.width)**2 + (self.height + box.height)**2)
    end
    
    def close?(box)
      self.min_total_diagonal(box) >= self.total_diagonal(box)
    end

    def overlap?(box, check = false)
      if self == box
        return true
      end
      
      if check
        if !self.close?(box)
          return false
        end
      end
      
      overlap = false
      self.segments.each {|segment|
        intersection = false
        box.segments.each {|segment2|
          if segment.intersect?(segment2)
            intersection = true
            break
          end
        }
        if intersection
          overlap = true
          break
        end
      }
      if !overlap
        ["center","cl","cr","cb","ct"].each {|c|
          if self.point_in_box?(box.method(c).call) || box.point_in_box?(self.method(c).call) 
            overlap = true
            break
          end
        }
      end
      return overlap
    end

    def enter_points_in_placements(placements, canvas, exception = nil)
      positions = @@edge_positions.dup
      last = nil
      if exception
        if exception.class == String && @@edge_positions.include?(exception)
          positions.delete(exception)
          last = self.method(exception).call
        end
      end
      positions.each {|position|
        placement = Placement.new(self.method(position).call,canvas,position,last)
        placements << placement
      }
      
      placements.sort {|x,y| x.distance <=> y.distance }
    end    

    def respond_to?(method)
      return true if method =~ @@place_regex 
      super
    end


    def method_missing(meth,*args)
      if meth.to_s =~  @@place_regex 
        if args[0].class == WordBox::Point
          if args[1].class == WordBox::Canvas
            if !@@positions.include?($1)
              super
            else
              point = args[0]
              canvas = args[1]
              origin = instance_variable_get("@#{$1}")
              diff_x = point.x - origin.x
              diff_y = point.y - origin.y
              ok = true
              @@positions.each{|c| 
                iv = instance_variable_get("@#{c}")
                new_x = iv.x + diff_x
                new_y = iv.y + diff_y
                if new_x < 0 || new_x > canvas.max.x || new_y < 0 || new_y > canvas.max.y
                  ok = false
                end
              }
              if ok
                @@positions.each{|c| 
                  iv = instance_variable_get("@#{c}")
                  instance_variable_set("@#{c}", Point.new(iv.x + diff_x, iv.y + diff_y))
                }
                @segments = [LineSegment.new(@ll,@ul),LineSegment.new(@ul,@ur),LineSegment.new(@ur,@lr),LineSegment.new(@ll,@lr)]
                return true
              else
                return false
              end
            end
          else
            raise ArgumentError, "invalid argument, second argument should have class WordBox::Canvas"
          end
        else
          raise ArgumentError, "invalid argument, first argument should have class WordBox::Point"
        end
      else
        super
      end
    end
  end
end