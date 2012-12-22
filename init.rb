require 'irb/completion'
ICF_ROOT = File.dirname(__FILE__)

$: << ICF_ROOT
Dir.glob("#{ICF_ROOT}/lib/*.rb").each{ |f| require f }
require 'icf'
include Db
