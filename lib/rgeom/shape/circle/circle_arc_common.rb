module RGeom

  # An arc is part of a circle, but Arc does not extend Circle.  This module
  # holds methods common to both.  @centre and @radius are required.
  module CircleArcCommon

      # Returns the point on the circle at the given angle, where 0 degrees is
      # East, as usual.
    def point(angle)
      angle = angle.in_radians
      x = @centre.x + @radius * Math.cos(angle)
      y = @centre.y + @radius * Math.sin(angle)
      Point[x,y]
    end

    def interpolate(k)
      a, b = @angles || [0,360]
      angle = a + k*(b-a)
      point(angle)
    end

      # A circle or arc doesn't have vertices, but it does have a defining
      # point, and a Shape object must give a good answer when asked what its
      # vertices are.
    def vertices
      VertexList.new(1, nil, [@centre])
    end

  end  # module CircleArcCommon
 
end  # module RGeom
