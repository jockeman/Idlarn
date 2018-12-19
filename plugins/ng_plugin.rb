# coding: utf-8
class NgPlugin < BasePlugin
  require 'shellwords'
  require 'dentaku'
  def initialize()
    super
    self.reg_all()
  end

  def reg_all()
    #reg_action :dc do |message|
    #  puts message.message.shellescape
    #  `dc -e #{message.message.shellescape}`
    #end
    reg_action :calc do |message|
      calculator = Dentaku::Calculator.new
      calculator.evaluate(message.message).to_s
    end
  end
end
