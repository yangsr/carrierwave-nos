require 'mime/types'
require 'rest-client'
require 'rexml/document'
require 'rexml/xpath'

module CarrierWave
  module Nos
    class NosClient
      def initialize(access_key, secrete_key, bucket_name, host = 'nos-eastchina1.126.net')
        @access_key = access_key
        @secret_key = secrete_key
        @bucket_name = bucket_name
        @host = host
      end

      def put_file(file, object_key)
        if file.class != File
          raise ArgumentError.new("File object type needed, but got #{file.class}")
        end

        resp = if file.size > 100 * 1024 * 1024
                 upload_large_file(file, object_key)
               else
                 send_request('PUT', @bucket_name, object_key, file)
               end
        resp
      end

      # PUT:    send_request('PUT', 'BUCKET_NAME', 'conan.jpg', data)
      # param:  data = File.open(FILE_PATH, 'rb')
      # GET:    send_request('GET', 'BUCKET_NAME', 'conan.jpg', nil)
      # DELETE: send_request('DELETE', 'BUCKET_NAME', 'conan.jpg', nil)
      # HEAD:   send_request('HEAD',  'BUCKET_NAME', 'conan.jpg', nil)
      # POST:   send_request('POST', 'BUCKET_NAME', "#{object_key}?uploads", nil)
      # send request and get response
      def send_request(method, bucket, object_key, data = nil)
        unless %w[GET DELETE HEAD PUT POST].include?(method)
          raise ArgumentError.new('Only support following http method: GET DELETE HEAD PUT POST')
        end
        if data.nil?
          content_type = ''
        else
          mime = MIME::Types.type_for(object_key).first
          content_type = if mime.nil?
                           'application/octet-stream'
                         else
                           mime.content_type
                         end
        end
        # ruby url encode ignore '/', so replace '/' with '%2f' manually
        resource = "/#{bucket}/#{URI.encode(object_key).gsub('/', '%2F')}"
        headers = get_headers(method, resource, content_type, data.nil? ? nil : data.size)
        url = "#{@bucket_name}.#{@host}" + "/#{URI.encode(object_key).gsub('/', '%2F')}"

        if method == 'PUT'
          res = RestClient.put(url, data, headers)
        elsif method == 'GET'
          res = RestClient.get(url, headers)
        elsif method == 'DELETE'
          res = RestClient.delete(url, headers)
        elsif method == 'HEAD'
          res = RestClient.head(url, headers)
        elsif method == 'POST'
          res = RestClient.post(url, data, headers)
        end

        res
      end

      def upload_large_file(file, object_key)
        upload_id = init_multi_upload(object_key)
        if upload_id == false
          return 400
        end
        part_size = 50 * 1024 * 1024
        part_num = 1
        part_info = {}
        until file.eof?
          part_data = file.read(part_size)
          etag = upload_part(object_key, part_num, upload_id, part_data)
          if etag != false
            part_info[part_num] = etag
            part_num += 1
          else
            return 400
          end
        end
        complete_multi_upload(object_key, upload_id, part_info)
      end

      def init_multi_upload(object_key)
        resp = send_request('POST', @bucket_name, "#{object_key}?uploads", nil)
        if resp.code == 200
          doc = REXML::Document.new(resp.body)
          upload_id = REXML::XPath.first(doc, '//UploadId/text()')
          return upload_id
        else
          return false
        end
      end

      def upload_part(object_key, part_num, upload_id, data)
        resp = send_request('PUT', @bucket_name, "#{object_key}?partNumber=#{part_num}&uploadId=#{upload_id}", data)
        if resp.code == 200
          return resp.headers[:etag]
        else
          return false
        end
      end

      def complete_multi_upload(object_key, upload_id, part_info)
        data = '<CompleteMultipartUpload>'
        part_info.each do |part_num, etag|
          data += "<Part><PartNumber>#{part_num}</PartNumber><ETag>#{etag}</ETag></Part>"
        end
        data += '</CompleteMultipartUpload>'
        send_request('POST', @bucket_name, "#{object_key}?uploadId=#{upload_id}", data)
      end

      private

      def get_headers(method, resource, content_type = '', content_length = nil)
        date = Time.now.httpdate
        headers = {
          'Authorization' => get_authorization(method, resource, date, content_type),
          'Date'          => date,
          'Host'          => "#{@bucket_name}.#{@host}"
        }
        unless content_type.nil?
          headers['Content-Type'] = content_type
        end
        unless content_length.nil?
          headers['Content-Length'] = content_length
        end

        headers
      end

      def get_authorization(method, resource, date, content_type = '')
        content = {
          'http_verb'              => method,
          'content_md5'            => '',
          'content_type'           => content_type,
          'date'                   => date,
          'canonicalized_resource' => resource,
        }
        str_to_sign = content.values.join("\n")
        signature = Base64.encode64(OpenSSL::HMAC.digest('sha256', @secret_key, str_to_sign))

        "NOS #{@access_key}:#{signature}"
      end
    end
  end
end
