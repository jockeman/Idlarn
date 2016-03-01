require 'active_record'
Dir.glob("#{ICF_ROOT}/models/*.rb").each{ |f| require f }
module Db
  def self.included(base)
    base.class_eval do
      ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
      ActiveRecord::Base.establish_connection( :production )
#      ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))
    end
  end
end

