require 'fluent/plugin/filter'

module Fluent::Plugin
  class MaskRxFilter < Filter
    Fluent::Plugin.register_filter('maskrx', self)

    config_section :mask, param_name: :mask_config_list, required: true, multi: true do
      config_param :keys,    :array,  default: nil
      config_param :pattern, :regexp, default: nil
      config_param :mask,    :string, default: '********'
    end

    def initialize
      super
    end

    def configure(conf)
      super

      patterns = []
      @mask_config_list.each do |config|
        raise Fluent::ConfigError, "pattern is required" if config.pattern.nil?

        patterns.push(config.pattern)
      end

      log.info("plugin=maskrx at=configure patterns=\"#{patterns}\"")
    end

    def filter(_, _, record)
      log.debug("plugin=maskrx at=filter record=\"#{record}\"")

      @mask_config_list.each do |config|
        record = mask_record(config, record)
      end

      record
    end

    protected
    def mask_record(config, record)
      keys = (config.keys.nil? ? record.keys : config.keys)
      log.debug("plugin=maskrx at=mask_record keys=\"#{keys}\"")

      keys.each do |key|
        record[key] = mask_key_value(config.pattern, config.mask, record[key]) unless record[key].nil?
      end

      return record
    end

    def mask_key_value(pattern, mask, value)
      match = value.match(pattern)

      return value unless match

      match = match.to_a
      match = match.to_a.drop(1) if match.size > 1

      match.each do |m|
        value.gsub!(m, mask)
      end

      log.debug("plugin=maskrx at=mask_key_value pattern=#{pattern} value=\"#{value}\"")

      return value
    end
  end
end
