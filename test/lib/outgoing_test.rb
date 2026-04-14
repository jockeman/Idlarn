require_relative '../test_helper'

class OutgoingTest < Minitest::Test
  def test_to_s_formats_as_privmsg_with_hash
    out = Outgoing.new("dv", "hello")
    assert_equal "PRIVMSG #dv :hello", out.to_s
  end

  def test_to_s_with_priv_option_omits_hash
    out = Outgoing.new("alice", "hi there", priv: true)
    assert_equal "PRIVMSG alice :hi there", out.to_s
  end

  def test_to_s_with_mode_option_formats_as_mode
    out = Outgoing.new("dv", "+v alice", mode: true)
    assert_equal "MODE #dv +v alice", out.to_s
  end

  def test_transform_all_caps
    out = Outgoing.new("dv", "hello world")
    out.transform(true)
    assert_equal "PRIVMSG #dv :HELLO WORLD", out.to_s
  end

  def test_private_message_to_s
    out = PrivateMessage.new("alice", "secret")
    assert_equal "PRIVMSG alice :secret", out.to_s
  end

  def test_normal_message_to_s
    out = NormalMessage.new("dv", "broadcast")
    assert_equal "PRIVMSG #dv :broadcast", out.to_s
  end

  def test_mode_message_to_s
    out = ModeMessage.new("dv", "+v", "alice")
    assert_equal "MODE #dv +v alice", out.to_s
  end

  def test_topic_message_to_s
    out = TopicMessage.new("dv", "Welcome!", "alice")
    assert_equal "TOPIC #dv :Welcome!", out.to_s
  end
end
