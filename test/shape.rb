# Here we assume the correctness of some Shape classes (Triangle etc.) and
# see if we can rotate them (etc.) correctly.
#
# shape.rotate _always_ returns a copy.
#
#   triangle(:ABC, :equilateral).rotate(30.d)
#     # Points ABC are unaffected by the rotation; the rotated triangle is
#     # anonymous and not even drawn.
#
#   _triangle(:equilateral).rotate(30.d).register
#     # The rotated triangle is anonymous, but is registered (will be drawn).
#     # The original equilateral triangle will be garbage collected.
#
#   _triangle(:equilateral).rotate(30.d).name(:ABC)
#     # Points ABC are set to the rotated triangle, which is _not_ registered.
#     # At least the points are set, so can be used to define other shapes.
#
#   _triangle(:equilateral).rotate(30.d).register(:ABC)
#     # Equivalent to (and short for)
#     #   _triangle(:equilateral).rotate(30.d).name(:ABC).register
#
# Finally, the following code will name and register the original triangle, then
# name and register the rotated one.  Note that we rotate about A, which means A
# is also a point in the rotated one, and we're allowed to use the point A in
# the label.
#
#   triangle(:ABC, :equilateral).rotate(30.d, :A).register(:AXY)
#
# Here are two approaches to creating a fully sick triangle spiral.
#
#   t = triangle(:A__, :equilateral)
#   (1..35).each do |i|
#     angle = 10*i
#     t.rotate(angle, :A).register
#   end
#
#   t = triangle(:A__, :equilateral)
#   Shape.generate(35, t) do |_t|
#     _t.rotate(10.d, :A).register
#   end

D "Shape methods" do
  D "rotate" do
    D "triangle about the origin (1)" do
      t1 = triangle(:ABC, :equilateral, :side => 3)
      T :vertices, t1, %{ _ 0 0   _ 3 0   _ 1.5 2.59808 }   # Just making sure...
      t2 = t1.rotate(30.d)
      Ko t2, Triangle
      T :vertices, t2, %{ _ 0 0   _ 2.59808 1.5   _ 0 3 }
    end
    D "triangle about the origin (2)" do
      points :D => p(2,1), :E => p(5,-1), :F => p(7,2)
      t1 = triangle(:DEF)
      T :vertices, t1, %{ D 2 1   E 5 -1   F 7 2 }   # Just making sure...
      t2 = t1.rotate(-71.d)
      T :vertices, t2, %{ _ -4.47980 -0.08535   _ -5.39413 -3.57204   _ -1.90644 -4.48637 }
    end
    D "triangle about an arbitrary point" do
      points :D => p(2,1), :E => p(5,-1), :F => p(7,2), :X => p(10,-1)
      t = _triangle(:DEF).rotate(-71.d, :X)
      Ko t, Triangle
      T :vertices, t2, %{ _ 9.28649 7.21528   _ 8.37216 3.72759   _ 11.85985 2.81326 }
    end
  end
end
