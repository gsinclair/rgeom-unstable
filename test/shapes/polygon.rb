require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

class TestPolygon < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    #debug $test_unit_current_test
  end

  def test_01_ABCDE
    polygon(:ABCDE).tap do |s|
      assert_vertices s, %w(A 0 0    B 1 0   C 1.30902  0.95106
                            D 0.5 1.53884    E -0.30902 0.95106)
      assert_point p(0.5,1.53884), s.pt(3)
      assert_point p(0.5,1.53884), @register[:D]
    end
  end

  def test_02_n_base
    polygon(:n => 6, :base => 2.5).tap do |s|
      assert_vertices s, %w(_ 0.0 0.0       _ 2.5 0.0       _  3.75 2.16505
                            _ 2.5 4.33013   _ 0.0 4.33013   _ -1.25 2.16506)
    end
  end

  def test_03_n_start_base_rotate
    point :X => p(5.977638455,0.6343919698)
    reference_triangle = _triangle(:equilateral, :base => :AX)
    polygon(:n => 3, :start => :A, :base => 3, :rotate => -7.d).tap do |s|
      # Our polygon should be equivalent to an equilateral triangle based on AX.
      t = reference_triangle
      assert_equal t.points, s.points
      assert_equal _segment(:AX), s.base
    end
  end

    # We generate the same shape as test_03, but use <tt>:base => :AX</tt>
    # instead of <tt>:start => :A, :base => 3, :angle => -7.d</tt>.
  def test_04_n_start_base
    point :X => p(5.977638455,0.6343919698)
    reference_triangle = _triangle(:equilateral, :base => :AX)
    polygon(:n => 3, :base => :AX).tap do |s|
      t = reference_triangle
      assert_equal t.points, s.points
      assert_equal _segment(:AX), s.base
    end
  end

  def test_05_centre_radius
    polygon(:n => 4, :centre => :A, :radius => 2).tap do |s|
      assert_vertices s, %(_ 1.58579 -0.41421   _ 4.41421 -0.41421
                           _ 4.41421  2.41421   _ 1.58579  2.41421)
    end
  end

    # Same polygon as test_05, but constructed differently.
  def test_06_radius
    point :X => p(5,1)
    polygon(:n => 4, :radius => :AX).tap do |s|
      assert_vertices s, %(_ 1.58579 -0.41421   _ 4.41421 -0.41421
                           _ 4.41421  2.41421   _ 1.58579  2.41421)
    end
  end

  def test_07_diameter_rotate_1
    polygon(:n => 3, :diameter => :AC, :rotate => 35.d).tap do |s|
      assert_vertices s, %w(_ 4.12875 -0.36840   _ 7.05371 1.67968   _ 3.81754 3.18873)
    end
  end

    # Same as test_07, but this time we want some points registered.
  def test_08_diameter_rotate_2
    polygon(:MNP, :n => 3, :diameter => :AC, :rotate => 35.d).tap do |s|
      assert_vertices s, %w(M 4.12875 -0.36840   N 7.05371 1.67968   P 3.81754 3.18873)
    end
  end

  def test_09_existing_point_C
    polygon(:CWXYZ, :base => 10).tap do |s|
      assert_vertices s,
        %w(C 7.0 2.0     W 17.0 2.0     X 20.09017 11.51057
                                        Y 12.0     17.38842     Z 3.90983 11.51057)
    end
  end

  def test_10_existing_points_CB
    polygon(:CBHI).tap do |s|
      assert_vertices s, %w(C 7 2   B 6 1   H 7 0   I 8 1)
    end
  end

end  # TestPolygon
