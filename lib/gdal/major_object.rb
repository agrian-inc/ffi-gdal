require_relative '../ffi/gdal'

module GDAL
  module MajorObject
    # @return [Array<String>]
    def metadata_domain_list
      unless defined? FFI::GDAL.GDALGetMetadataDomainList
        warn "GDALGetMetadataDomainList is't defined. GDAL::MajorObject#metadata_domain_list disabled."
        return []
      end

      list_pointer = FFI::GDAL.GDALGetMetadataDomainList(c_pointer)
      return [] if list_pointer.null?

      strings = list_pointer.get_array_of_string(0)

      strings.compact.delete_if(&:empty?)
    end

    # @param domain [String] Name of the domain to get metadata for.
    # @return [Hash]
    def metadata(domain = '')
      m = FFI::GDAL.GDALGetMetadata(c_pointer, domain)
      return {} if m.null?

      data_array = m.get_array_of_string(0)

      data_array.each_with_object({}) do |key_value_pair, obj|
        key, value = key_value_pair.split('=', 2)

        begin
          obj[key] = MultiXml.parse(value)
        rescue MultiXml::ParseError
          obj[key] = value
        end
      end
    end

    # @param name [String]
    # @param domain [String]
    # @return [String]
    def metadata_item(name, domain = '')
      FFI::GDAL.GDALGetMetadataItem(c_pointer, name, domain)
    end

    def set_metadata_item(name, value, domain = '')
      FFI::GDAL.GDALSetMetadataItem(c_pointer, name, value.to_s, domain)
    end

    # @return [Hash{domain => Array<String>}]
    def all_metadata
      sub_metadata = metadata_domain_list.each_with_object({}) do |subdomain, obj|
        metadata_array = metadata(subdomain)
        obj[subdomain] = metadata_array
      end

      { DEFAULT: metadata }.merge(sub_metadata)
    end

    # @return [String]
    def description
      FFI::GDAL.GDALGetDescription(c_pointer)
    end

    # @param new_description [String]
    def description=(new_description)
      FFI::GDAL.GDALSetDescription(c_pointer, new_description.to_s)
    end

    def null?
      c_pointer.null?
    end
  end
end