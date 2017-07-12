require 'carrierwave/nos/bucket'
require 'carrierwave/nos/configuration'
require 'carrierwave/nos/nos_client'
require 'carrierwave/nos/version'
require 'carrierwave/storage/nos'
require 'carrierwave/storage/nos_file'

CarrierWave::Uploader::Base.send(:include, CarrierWave::Nos::Configuration)
