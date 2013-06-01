require 'test_helper'

class SpimeTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  test "spime attributes must not be empty" do
    spime = Spime.new
    assert spime.invalid?
    assert spime.errors[:name].any?
    assert spime.errors[:description].any?
    assert spime.errors[:image].any?
    assert spime.errors[:materials].any?
    assert spime.errors[:date_manufactured].any?
  end

  test "image url validity" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg
              http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }
    
    ok.each do |image|
      assert new_spime(image).valid?, "#{image} shouldn't be invalid"
    end
    
    bad.each do |image|
      assert new_spime(image).invalid?, "#{image} shouldn't be valid"
    end
  end

  def new_spime(image_url)
    Spime.new(:name         => "Spime Name",
              :description  => "yyy",
              :image        => image_url,
              :materials    => "xxx",
              :date_manufactured => "2013-05-03")
    end

end
