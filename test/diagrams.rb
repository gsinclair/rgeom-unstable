include Math
require 'fileutils'

D "Diagrams" do

  D.<< do
    Dir['out/*.png'].each do |p|
      FileUtils.rm_f(p)
    end
  end

  D.< do
    RGeom::Register.instance.clear!
  end

  def wrap_test(name)
    filename = "out/#{name}.png"
    F { File.exist? filename }
    yield
    render filename
    T { File.exist? filename }
  end

  D "circles" do
    wrap_test "circles" do
      (0..30).each do |d|
        centre = Point[sqrt(d), sqrt(d)]
        radius = sqrt(2.2*d)
        circle(:centre => centre, :radius => radius)
      end
    end
  end

  NTRIANGLES = 10

  D "triangle spiral (#{NTRIANGLES})" do
    wrap_test "spiral-#{NTRIANGLES}" do
      # construction code taken from test/construct/spiral.rb
      first = triangle(:right_angle => :first, :base => 3, :height => 1)
      Shape.generate(NTRIANGLES, first) do |tn|
        triangle(:base => tn.hypotenuse.reverse, :right_angle => :first, :height => 1)
      end
    end
  end

  D "variety" do
    TESTS = []
    TESTS << { :desc => "Triangle",   :code => "triangle" }
    TESTS << { :desc => "Circle",     :code => "circle" }
    TESTS << { :desc => "Arc",        :code => "arc(:angles => [3.d,189.d])" }
    TESTS << { :desc => "Semicircle", :code => "semicircle" }

    TESTS.each do |test|
      description = test[:desc].downcase
      D "#{description}" do
        wrap_test "variety-#{description}" do
          RGeom::Register.instance.clear!
          eval test[:code]
        end
      end
    end
  end  # variety

  D "polygons 1" do
    # A bunch of polygons on the same base (0-1)
    wrap_test "polygons-1" do
      b = seg(p(0,0), p(1,0))
      (3..17).each do |n|
        polygon(n: n, base: b)
      end
    end
  end

  D "polygons 2" do
    # A bunch of circles containing polygons of increasing sidality
    wrap_test "polygons-2" do
      15.times do |i|
        x = 3*(i%5)
        y = 3*(i/5)
        c = pt(x,y)
        n = i+3          # triangle, square, pentagon, ...
        circle(centre: c, radius: 1)
        polygon(n: n, centre: c, radius: 1)
      end
    end
  end

  D "polygons 3" do
    # A miscellaneous triangle with a different polygon on each side
    wrap_test "polygons-3" do
      points A: p(5.7,1.9), B: p(-4.5,-4.189)
      triangle(:ABC, :equilateral)
      polygon n: 7, base: :BA
      polygon n: 5, base: :CB
      polygon n:10, base: :AC
    end
  end

end if defined? Cairo

