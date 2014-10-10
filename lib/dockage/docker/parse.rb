module Dockage
  module Docker
    module Parse
      class << self
        def parse_docker_ps(string)
          header = string.shift

          spaces = column_width = 0
          keys = {}
          header.chars.each_with_index do |char, i|
            if i == (header.size - 1) || (char !~ /\s/ && spaces > 1)
              keys.merge!(slice_column_from_string(header, i, column_width))
              column_width = 0
            end
            spaces = char =~ /\s/ ? spaces + 1 : 0
            column_width += 1
          end

          string.map do |container_string|
            container               = Hash[keys.map { |k, v| [k, container_string[v[:start]..v[:stop]].strip] }]
            container[:names]       = container[:names].to_s.split(',')
            container[:name]        = container[:names].reject{ |v| v.include?('/') }.first
            container[:linked_with] = container[:names].map{ |name| name.split('/')[0] }.compact
            container[:running]     = container[:status].downcase
                                                        .include?('up') ? true : false
            container
          end
        end

        def slice_column_from_string(string, index, column_width)
          start = index - column_width
          stop = index < string.length - 1 ? (index - 1) : -1
          header_key = string[start..stop].strip
                                          .downcase
                                          .gsub(/\s/, '_')
                                          .to_sym

          { header_key => { start: start, stop: stop } }
        end
      end
    end
  end
end
