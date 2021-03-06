# Polygon use cases outlined in the test code:
#

module RGeom::Shapes
  
  # *------------------* General polygon code *------------------* 

  class Polygon < RGeom::Shape

    def self.construct(spec)
      Constructor.construct(spec)
    end

    def initialize(n, circle, sidelength, vertices)
      super(vertices)
      @n = n
      @centre, @radius = circle.centre, circle.radius
      @sidelength = sidelength
      @points = vertices.points
    end

    attr_reader :n, :sidelenth, :centre, :radius, :points

    def inspect; to_s(:short); end

    def to_s(opt)
      points_str = points.map { |p| p.to_s(3) }.join(' ')
      "Polygon #{label} n:#{n} centre:#{centre} radius:#{radius}\n" \
      "  #{points_str}"
    end

  end  # class Polygon

  # *------------------* Polygon construction code *------------------* 

  class Polygon
    class Constructor
      DEFAULT_SIDE = 1   # todo: revisit

        # Cases:
        #   polygon :ABXYZ                  (A defined or defaults to origin)
        #   polygon :n => 6, :base => 2.5   (label permitted)
        #   polygon :n => 3, :base => :AX 
        #   polygon :n => 4, :centre => :A, :radius => 2 
        #   polygon :n => 4, :radius => :AX 
        #   polygon :n => 3, :diameter => :AC 
        #   polygon :MNP, :n => 3, :diameter => :AC 
        #   polygon :CWXYZ, :side => 10               (C defined)
        #   polygon :CBHI                             (C and B defined)
      def Constructor.construct(spec)
        # -
        # n: number, side: length
        # n: number, base: segment
        # n: number, radius: segment
        # n: number, diameter: segment
        # n: number, centre: point=origin, radius: length
        # n: number, centre: point=origin, diameter: length
        # side: length
        label = spec.label
        n, centre, radius, sidelength, points = nil

        ##
        ## If any of :centre, :radius, :diameter are given, we construct the
        ## polygon based on a circle.
        ##
        circle_params = spec.extract_parameters(:centre, :radius, :diameter)
                              # todo: ^^^ implement
        unless circle_params.empty?
          circle = _circle(circle_params)
          n = spec.n || raise("...")
          points = determine_points_from_circle(circle, n)
        else

        ##
        ## Otherwise, we determine the first and second point, and the number
        ## of sides, and go from there.
        ##

          a, b = nil   # a and b are the first two points of the polygon
          case spec.parameters
          when []
            # It all depends on the label.
            n, a, b = determine_first_two_points(spec, label)
          when [:n, :side]
            n = spec.n
            a, b = two_points(side: spec.side)
          when [:n, :base]
            n = spec.n
            a, b = two_points(base: spec.base)
          when [:side]
            n, a, b = determine_first_two_points(spec, label, spec.side)
          end
          circle = construct_circle(a, b, n)
          points = determine_points_from_circle(circle, n, start_at: a)
        end

        sidelength = Point.distance( points[0], points[1] )
        vertices = VertexList.new(n, label, points).register
        Polygon.new(n, circle, sidelength, vertices)
      end  # def Constructor.construct

      # Given a circle and the number of sides, return the points that define
      # the polygon.  If 'start_at' parameter given, start at that point and
      # work anticlockwise.  Otherwise, ensure bottom base is flat.
      def self.determine_points_from_circle(circle, n, args={})
        first_point = args[:start_at]
        theta = 360.0/n
        first_angle =
          if first_point.nil?
            (270 - theta/2).d    # This ensures bottom side is horizontal.
          else
            circle.angle_at(first_point)
          end
        angles = (0...n).map { |i| first_angle + (i*theta).d }
        points = angles.map { |x| circle.point(x) }
      end

      # Given the first two points of the polygon, construct the circle in which
      # the polygon will be inscribed.
      def self.construct_circle(a, b, n)
        # Form an isosceles triangle based on (ab) with the angle determined by
        # the number of sides in the polygon.  The apex of this triangle is the
        # centre of the circle/polygon.
        base_angle = (90.0 * (n-2) / n).d
        t = _triangle(:isosceles, base: seg(a,b), angle: base_angle)
        centre = t.apex
        radius = Point.distance(a, centre)
        _circle(centre: centre, radius: radius)
      end

      # Returns two points given a length (in which case it starts at the origin)
      # or a segment (in which case it's easy).
      # Legitimate arguments: start AND (side OR base)
      def self.two_points(args={})
        start = args[:start] || p(0,0)
        if (side = args[:side])
          [ start, start + p(side,0) ]
        elsif args[:base]
          args[:base].points
        else
          raise "..."
        end
      end

      # Returns _n_ and the first two points, based on the label and base vales.
      # It's complicated to determine what info has been provided, because some
      # points may exist already.
      def self.determine_first_two_points(spec, label, side=nil)
        # First determine how many sides we have.
        n = if label.nil?
              Err.label_required_for_polygon("...")
            elsif label.size <= 2
              Err.insufficient_label_for_polygon("...")
            else
              label.size rescue Err.label_required("...")
            end

        mask = label.mask
        if side.nil?
          # We either divine the side length from the label or use the default.
          a, b =
            case mask
            when /^F*$/     # no points defined
              two_points(side: DEFAULT_SIDE)
            when /^TF*$/    # only first point defined
              p1 = label.point(0)     # todo: implement this, or similar
              two_points(start: p1, side: DEFAULT_SIDE)
            when /^TTF*$/   # first two points defined
              [ label.point(0), label.point(1) ]
            else
              Err.invalid_spec(:polygon, spec, "mask == #{mask}")
            end
          return n, a, b
        end
        if side.not_nil?
          a, b =
            case mask
            when /^F*$/     # no points defined
              two_points(side)
            when /^TF*$/    # only first point defined
              _a = label.point(0)
              _b = _a + p(side, 0)
              [ _a, _b ]
            when /^TTF*/    # first two points defined
              warn "Ignoring spec: side=#{side} -- conflicts with label #{label}"
            else
              Err.invalid_spec(:polygon, spec,
                           "Too many points defined in #{label}: mask = #{mask}")
            end
          return n, a, b
        end
      end  # def determine_first_two_points

    end  # class Constructor
  end  # class Polygon
end  # module RGeom::Shapes
