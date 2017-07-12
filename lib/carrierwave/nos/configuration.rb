module CarrierWave
  module Nos
    module Configuration
      extend ActiveSupport::Concern

      included do
        add_config :nos_access_key
        add_config :nos_secret_key
        add_config :nos_endpoint
        add_config :nos_bucket

        configure do |config|
          config.storage_engines[:nos] = 'CarrierWave::Storage::Nos'
        end
      end
    end
  end
end
