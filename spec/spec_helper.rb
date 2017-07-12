require 'rubygems'
require 'rspec'
require 'active_record'
require 'carrierwave'
require 'carrierwave/orm/activerecord'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'carrierwave-nos'

module Rails
  class <<self
    def root
      # current spec folder
      [File.expand_path(__FILE__).split('/')[0..-3].join('/'), 'spec'].join('/')
    end
  end
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

CarrierWave.configure do |config|
  config.storage        = :nos
  config.nos_access_key = ''
  config.nos_secret_key = ''
  config.nos_bucket     = ''
  config.nos_endpoint   = 'nos-eastchina1.126.net'
end

def load_file(fname)
  File.open([Rails.root, fname].join('/'))
end
