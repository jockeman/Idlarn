require_relative '../test_helper'

class MessageTest < Minitest::Test
  def raw(payload, channel: "dv")
    build_raw_message(payload: payload, channel: channel)
  end

  def test_dot_command_sets_action_and_message
    user = FakeUser.new("alice")
    msg = Message.new(user, raw(".echo hello"))
    assert_equal "echo", msg.action
    assert_equal "hello", msg.message
  end

  def test_dot_command_with_no_args_has_empty_message
    user = FakeUser.new("alice")
    msg = Message.new(user, raw(".echo"))
    assert_equal "echo", msg.action
    assert_equal "", msg.message
  end

  def test_dot_command_with_multi_word_args
    user = FakeUser.new("alice")
    msg = Message.new(user, raw(".karma some user"))
    assert_equal "karma", msg.action
    assert_equal "some user", msg.message
  end

  def test_plain_text_has_no_action
    user = FakeUser.new("alice")
    msg = Message.new(user, raw("hello world"))
    assert_nil msg.action
    assert_equal "hello world", msg.message
  end

  def test_channel_is_set_from_raw_message
    user = FakeUser.new("alice")
    msg = Message.new(user, raw(".echo hi", channel: "mychan"))
    assert_equal "mychan", msg.channel
  end

  def test_user_is_set
    user = FakeUser.new("bob")
    msg = Message.new(user, raw(".echo hi"))
    assert_equal user, msg.user
  end
end
