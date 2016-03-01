require 'active_record'
require 'yaml'

task :default => :migrate

desc "Migrate the database"
task :migrate => :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end

task :environment do
  ActiveRecord::Base.configurations = YAML::load_file('config/database.yml')
  ActiveRecord::Base.establish_connection(:production)
  #ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))
end
