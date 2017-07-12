# CarrierWave for Netease Object Storage Service(NOS)

This gem adds support for [Netease Object Storage Service](http://support.c.163.com/md.html#!平台服务/对象存储/产品简介/对象存储产品简介.md) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

> NOTE: 此 Gem 是一个 CarrierWave 的组件，你需要配合 CarrierWave 一起使用
>
> 更多关于网易云对象存储服务的介绍请去[网易蜂巢官网](https://c.163.com/)查看


## Installation

```ruby
gem 'carrierwave-nos'
```

## Configuration

在你的Rails工程目录下创建文件 `config/initializers/carrierwave.rb` 并填入下面的代码，修改对应的配置：

```
CarrierWave.configure do |config|
  config.storage        = :nos
  config.nos_access_key = ''
  config.nos_secret_key = ''
  config.nos_bucket     = '' # 你需要在 NOS 上面提前创建一个 Bucket
  config.nos_endpoint   = 'nos-eastchina1.126.net'
end
```

## License

[MIT License](http://opensource.org/licenses/MIT).
