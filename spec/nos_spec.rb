require 'spec_helper'

describe CarrierWave::Nos do
  def setup_db
    ActiveRecord::Schema.define(version: 1) do
      create_table :photos do |t|
        t.column :image, :string
        t.column :content_type, :string
      end
    end
  end

  def drop_db
    ActiveRecord::Base.connection.data_sources.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  class PhotoUploader < CarrierWave::Uploader::Base
    def store_dir
      'photos'
    end

    def filename
      @name ||= "#{md5}#{File.extname(super)}" if super
    end

    def md5
      @md5 ||= Digest::MD5.hexdigest model.send(mounted_as).read.to_s
    end
  end

  class Photo < ActiveRecord::Base
    mount_uploader :image, PhotoUploader
  end

  before :all do
    setup_db
  end

  after :all do
    drop_db
  end

  describe 'Upload Image' do
    context 'should upload image' do
      before(:all) do
        @file = load_file('foo.jpg')
        @photo = Photo.new(image: @file)
      end

      it 'should upload file' do
        expect(@photo.save).to eq true
        expect(@photo[:image].present?).to eq true
      end
    end
  end
end
