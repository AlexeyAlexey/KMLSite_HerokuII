require 'active_record'
require 'yaml'
require 'logger'
require 'fileutils'

pathDir = File.dirname File.expand_path('../KMLSite.rb', __FILE__)


task :default => :migrate

task :migrate do

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
ActiveRecord::Base.establish_connection YAML.load_file('config/database.yml')
ActiveRecord::Migrator.migrate(pathDir + "/db/migrate/")

end


