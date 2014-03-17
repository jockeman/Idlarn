# coding: utf-8
class NgPlugin < BasePlugin
  require 'shellwords'
  def initialize()
    super
    self.reg_all()
  end

  def reg_all()
    reg_action :dc do |message|
      puts message.message.shellescape
      #`echo #{message.message.shellescape} | dc`
      `dc -e #{message.message.shellescape}`
    end
  end
end
