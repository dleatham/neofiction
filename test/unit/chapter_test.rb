require 'test_helper'

class ChapterTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Chapter.new.valid?
  end
end
