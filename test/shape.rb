# Here we assume the correctness of some Shape classes (Triangle etc.) and
# see if we can rotate them (etc.) correctly.
#
# shape.rotate alters the receiver; it does not produce a copy
#
#   t = triangle(:ABC, :equilateral)
#         # A, B, C are defined
#   t.rotate(30.d)
#         # A, B, C now have new values
#   render
#         # only one triangle is drawn
#
#   t = triangle(:ABC, :equilateral)
#   t.copy.rotate(180.d)
#         # Here we have two triangles.  The second one has anonymous vertices.
#   render
#         # Two triangles will be drawn; it will look like a star.
#
#   t = triangle(:ABC, :equilateral)
#   t.copy.rotate(180.d).register(:XYZ)
#   render
#         # Our six-pointed star again, with labels X, X, A, Z, B, Y going
#         # anti-clockwise from top.
#
#   t = triangle(:ABC, :equilateral)
#   t.copy.rotate(180.d).hide
#   render
#         # Two triangles created, but only the first one will be drawn.
#         # The points of the second one may be used in construction.
#         # Implementation: a shape will have a :visible flag, defaulting to
#         # true. The renderer can just ignore invisible shapes.  This may
#         # become the way that other shapes don't hit the register: instead of
#         # _circle(...), we could do circle(...).hide.
#
# Here's a way to create a nice triangle spiral (or complex star):
#
#   t = triangle(:equilateral)
#   Shape.generate(35, t) do |_t|
#     _t.copy.rotate(10.d)
#   end
#
# Rotating about one of the vertices would be pretty cool, too:
#
#   t = triangle(:ABC, :equilateral)
#   Shape.generate(35, t) do |_t|
#     _t.copy.rotate(10.d, :A)
#   end
#
# How to approach this...
#
# * write tests based on the above scenarios
# * flesh out #translate, #enlarge, #mirror as well
# * think about :visible flag in Shape, and test that too
# * also Shape#copy and Shape#register
# * document this stuff, not just in the code
#   - may have implications for _circle, etc.
#   - those methods could be done by method_missing; but keep a central
#     list of applicable methods
# * write code in Shape class (perhaps Transformations module?)

xD "Shape methods" do
  D "rotate" do
    D "triangle about the origin (1)" do
      t1 = triangle(:ABC, :equilateral, :side => 3)
      T :vertices, t1, %{ A 0 0   B 3 0   C 1.5 2.59808 }   # Just making sure...
      t1.rotate(30.d)
      T :vertices, t1, %{ A 0 0   B 2.59808 1.5   C 0 3 }
    end
    D "triangle about the origin (2)" do
      points :D => p(2,1), :E => p(5,-1), :F => p(7,2)
      t1 = triangle(:DEF)
      T :vertices, t1, %{ D 2 1   E 5 -1   F 7 2 }   # Just making sure...
      t2 = t1.copy.rotate(-71.d)
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
