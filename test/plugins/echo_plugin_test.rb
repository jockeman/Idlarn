require_relative '../test_helper'
require 'plugins/echo_plugin'

class EchoPluginTest < Minitest::Test
  def setup
    @plugin = EchoPlugin.new
    @plugin.nick = "TestBot"
  end

  def make_msg(text, channel: "dv")
    user = FakeUser.new("alice")
    raw = build_raw_message(payload: ".echo #{text}", channel: channel)
    msg = Message.new(user, raw)
    msg
  end

  def test_echo_returns_the_message_text
    msg = make_msg("hello")
    assert_equal "hello", @plugin.echo(msg)
  end

  def test_echo_returns_multi_word_message
    msg = make_msg("hello world")
    assert_equal "hello world", @plugin.echo(msg)
  end

  def test_action_dispatch_returns_outgoing_objects
    # Note: EchoPlugin#initialize skips super, so @plugins is nil.
    # action() returns nil for the @plugins branch but falls through
    # to @actions branch correctly because @actions is set.
    msg = make_msg("hi")
    result = @plugin.action(msg)
    assert_instance_of Array, result
    assert_instance_of Outgoing, result.first
    assert_match "hi", result.first.to_s
  end

  def test_action_formats_response_as_privmsg
    msg = make_msg("test")
    result = @plugin.action(msg)
    assert_equal "PRIVMSG #dv :test", result.first.to_s
  end

  def test_registered_action_includes_echo
    assert_includes @plugin.actions, 'echo'
  end
end
