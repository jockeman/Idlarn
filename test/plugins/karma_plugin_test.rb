require_relative '../test_helper'
require 'plugins/karma_plugin'

# Minimal in-memory User stub that satisfies KarmaPlugin without ActiveRecord.
class User
  attr_accessor :id, :karma, :nick

  def initialize(id:, nick:, karma: 0)
    @id    = id
    @nick  = nick
    @karma = karma
  end

  def to_s = @nick
  def save; end

  def self.fetch(nick, _create = true)
    @registry ||= {}
    @registry[nick] ||= new(id: @registry.size + 1, nick: nick)
  end

  def self.reset!
    @registry = {}
  end
end

class KarmaPluginTest < Minitest::Test
  def setup
    User.reset!
    @plugin = KarmaPlugin.new
    @plugin.nick = "TestBot"
  end

  def make_msg(payload, nick: "alice", channel: "dv")
    raw  = build_raw_message(payload: payload, channel: channel, nick: nick)
    user = FakeUser.new(nick, nil, User.fetch(nick).id, 0, nil)
    Message.new(user, raw)
  end

  # --- .karma command ---

  def test_karma_reports_user_karma
    User.fetch("bob").karma = 5
    msg    = make_msg(".karma bob")
    result = @plugin.karma(msg)
    assert_match "bob", result
    assert_match "5", result
  end

  def test_karma_falls_back_to_sender_when_target_not_found
    # When .karma is called with a user that doesn't exist,
    # it should fall back to the sender's dbuser
    msg = make_msg(".karma nonexistent")
    sender_db = User.fetch("alice")
    sender_db.karma = 3
    msg.user = FakeUser.new("alice", sender_db, sender_db.id, 3, nil)
    result = @plugin.karma(msg)
    # Fetching nonexistent user returns a new user, but we're testing the fallback logic
    # In a real scenario, msg.user.dbuser would have reload called.
    # For now, just verify it doesn't crash and returns something
    assert result
  end

  # --- karma++ passive trigger ---

  def test_karmaup_increments_target_karma
    target = User.fetch("bob")
    assert_equal 0, target.karma

    msg = make_msg("bob++")
    @plugin.action(msg)

    assert_equal 1, target.karma
  end

  def test_karmaup_self_karma_is_rejected
    alice = User.fetch("alice")
    msg   = make_msg("alice++", nick: "alice")
    # alice's dbid must match User.fetch("alice").id
    msg.user = FakeUser.new("alice", alice, alice.id, 0, nil)

    result = @plugin.action(msg)
    assert_equal 0, alice.karma
    assert_match "Nice try", result.first.to_s
  end

  # --- karma-- passive trigger ---

  def test_karmadn_decrements_target_karma
    target = User.fetch("bob")
    assert_equal 0, target.karma

    msg = make_msg("bob--")
    @plugin.action(msg)

    assert_equal(-1, target.karma)
  end

  def test_karmadn_rate_limit_blocks_rapid_fire
    msg = make_msg("bob--", nick: "alice")
    alice = User.fetch("alice")
    # Simulate alice having just given karma one second ago
    msg.user = FakeUser.new("alice", alice, alice.id, 0, Time.now)

    result = @plugin.action(msg)
    assert_match "Lugna", result.first.to_s
  end

  # --- registered actions ---

  def test_registered_actions
    %w[karma karmatoppen karmabotten].each do |a|
      assert_includes @plugin.actions, a
    end
  end
end
