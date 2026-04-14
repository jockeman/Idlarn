# Suppress backtick shell calls (Outgoing and RawMessage write to ~/log/ on every new).
# This must happen before any project files are required.
module Kernel
  def `(cmd)
    ""
  end
end

$LOAD_PATH.unshift File.expand_path('..', __dir__)

require 'minitest/autorun'
require 'lib/base_plugin'
require 'lib/message'
require 'lib/outgoing'
require 'lib/raw_message'

# Minimal RawMessage factory used across tests.
# Avoids touching the full constructor side-effects (puts, shell log).
def build_raw_message(payload:, channel: "dv", nick: "testnick")
  raw = RawMessage.allocate
  raw.instance_variable_set(:@type,    "PRIVMSG")
  raw.instance_variable_set(:@nick,    nick)
  raw.instance_variable_set(:@uname,   "u")
  raw.instance_variable_set(:@host,    "h")
  raw.instance_variable_set(:@channel, channel)
  raw.instance_variable_set(:@payload, payload)
  raw
end

# Minimal user stub — satisfies Message and plugin contracts without ActiveRecord.
FakeUser = Struct.new(:nick, :dbuser, :dbid, :karma, :last_karma)
