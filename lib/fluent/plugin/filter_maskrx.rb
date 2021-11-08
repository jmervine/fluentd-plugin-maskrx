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

      mask_record(config, record)
    end

    def filter_stream(tag, es)
      new_es = Fluent::MultiEventStream.new
      es.each do |time, record|
        log.debug("plugin=maskrx at=filter_stream record=\"#{record}\"")

        new_es.add(time, mask_record(record))
      end

      new_es
    end

    protected
    def mask_record(record)
      @mask_config_list.each do |config|
        record = mask_entry(config, record)
      end

      record
    end

    def mask_entry(config, record)
      keys = if config.keys.nil? || config.keys.empty?
               record.keys
             else
               config.keys
             end

      log.debug("plugin=maskrx at=mask_entry keys=\"#{keys}\"")

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
