module CarrierWave
  module Storage
    class NosFile < CarrierWave::SanitizedFile
      attr_reader :path

      def initialize(uploader, base, path)
        @uploader = uploader
        @base     = base
        @path     = URI.encode(path)
      end

      def read
        object = bucket.get(@path)
        @headers = object.headers
        object
      end

      def store(file)
        bucket.put(@path, file)
      end

      def url(_opts = {})
        bucket.path_to_url(@path)
      end

      private

      def headers
        @headers ||= {}
      end

      def bucket
        return @bucket if defined? @bucket

        @bucket = CarrierWave::Nos::Bucket.new(@uploader)
      end
    end
  end
end
