require 'test_helper'

class ImageMailerTest < ActionMailer::TestCase
  test "send_image" do
    mail = ImageMailer.send_image
    assert_equal "Send image", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "send_error" do
    mail = ImageMailer.send_error
    assert_equal "Send error", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
