require 'openssl'
require 'base64'

module Pay
  module Utils
    def generate_out_trade_no type
      t = Time.now
      batch_no = t.strftime('%Y%m%d%H%M%S') + t.nsec.to_s
      "#{type}_#{batch_no.ljust(24, rand(10).to_s)}"
    end

    def check_required_options options, names
      names.each do |name|
        raise StandardError.new("Pay Warn: missing required option: #{name}") unless options.has_key?(name.to_sym) && !options[name.to_sym].nil? && !options[name.to_sym].to_s.strip.empty?
      end
    end

    def stringify params
      params.sort.map do |key, value|
        "#{key}=#{value}" if value != "" && !value.nil?
      end.compact.join('&')
    end

    def change_key_to_sym hash
      hash.inject({}) do |new_options,(key, val)|
        new_options[key.to_sym] = val
        new_options
      end
    end
  end
end