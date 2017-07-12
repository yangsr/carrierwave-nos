# coding: utf-8

require 'carrierwave'

module CarrierWave
  module Storage
    class Nos < Abstract
      def store!(file)
        f = NosFile.new(uploader, self, uploader.store_path)
        f.store(::File.open(file.file))
        f
      end

      def retrieve!(identifier)
        NosFile.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
