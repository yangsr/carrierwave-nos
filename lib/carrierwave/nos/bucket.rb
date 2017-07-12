module CarrierWave
  module Nos
    class Bucket
      PATH_PREFIX = %r{^/}

      def initialize(uploader)
        @nos_access_key = uploader.nos_access_key
        @nos_secret_key = uploader.nos_secret_key
        @nos_endpoint = uploader.nos_endpoint
        @nos_bucket = uploader.nos_bucket
      end

      # 上传文件
      # params:
      # - path - remote 存储路径
      # - file - 需要上传文件的 File 对象
      # returns:
      # 图片的下载地址
      def put(path, file)
        path.sub!(PATH_PREFIX, '')

        res = oss_upload_client.put_file(file, path)

        if res.code == 200
          path_to_url(path)
        else
          raise 'Put file failed'
        end
      end

      # 根据配置返回完整的上传文件的访问地址
      def path_to_url(path)
        "#{@nos_bucket}.#{@nos_endpoint}/#{path}"
      end

      private

      def oss_upload_client
        return @oss_upload_client if defined?(@oss_upload_client)
        @oss_upload_client = NosClient.new(@nos_access_key, @nos_secret_key, @nos_bucket, @nos_endpoint)
      end
    end
  end
end
