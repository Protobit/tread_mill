require 'test_helper'

class QueueListenerTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Class, TreadMill::QueueListener
  end
end
