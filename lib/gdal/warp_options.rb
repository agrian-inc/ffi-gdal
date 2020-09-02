# typed: false
# frozen_string_literal: true

require_relative '../gdal'

module GDAL
  class WarpOptions
    attr_reader :c_struct, :source_dataset, :destination_dataset, :cutline

    def initialize(options = {})
      @c_struct = FFI::GDAL::WarpOptions.new
      @source_dataset = nil
      @destination_dataset = nil

      options.each_key do |k|
        assign_meth = "#{k}=".to_sym

        begin
          if respond_to?(assign_meth)
            send(assign_meth, options[k])
          else
            @c_struct[k] = options[k]
          end
        rescue ArgumentError => e
          new_message = "#{k}; #{e.message}"
          raise $ERROR_INFO, new_message, $ERROR_INFO.backtrace
        end
      end
    end

    def c_pointer
      @c_struct.to_ptr
    end

    # @param options [Hash]
    def warp_operation_options=(options)
      @c_struct[:warp_operation_options] = GDAL::Options.pointer(options)
    end

    # @return [Hash]
    def warp_operation_options
      options = @c_struct[:warp_operation_options]

      GDAL::Options.to_hash(options)
    end

    # @param dataset [GDAL::Dataset]
    def source_dataset=(dataset)
      @source_dataset = dataset
      @c_struct[:source_dataset] = dataset.c_pointer
    end

    # @param dataset [GDAL::Dataset]
    def destination_dataset=(dataset)
      @destination_dataset = dataset
      @c_struct[:destination_dataset] = dataset.c_pointer
    end

    # @param band_numbers [Array<Integer>]
    def source_bands=(band_numbers)
      bands_ptr = FFI::MemoryPointer.new(:int, band_numbers.length)
      bands_ptr.write_array_of_int(band_numbers)

      @c_struct[:source_bands] = bands_ptr
      @c_struct[:band_count] = band_numbers.length if band_numbers.length > @c_struct[:band_count]
    end

    # @return [Array<Integer>]
    def source_bands
      pointer = @c_struct[:source_bands]
      return [] if pointer.null?

      pointer.read_array_of_int(@c_struct[:band_count])
    end

    # @param band_numbers [Array<Integer>]
    def destination_bands=(band_numbers)
      bands_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.length)
      bands_ptr.write_array_of_int(band_numbers)

      @c_struct[:destination_bands] = bands_ptr
      @c_struct[:band_count] = band_numbers.length if band_numbers.length > @c_struct[:band_count]
    end

    # @return [Array<Integer>]
    def destination_bands
      pointer = @c_struct[:destination_bands]
      return [] if pointer.null?

      pointer.read_array_of_int(@c_struct[:band_count])
    end

    def transformer_arg=(transformation_object)
      @c_struct[:transformer_arg] = transformation_object.c_pointer

      @c_struct[:transformer] = transformation_object.function
    end

    # @param geometry [OGR::Geometry]
    def cutline=(geometry)
      raise 'Not a geom' unless geometry.is_a?(OGR::Geometry)

      @cutline = geometry

      @c_struct[:cutline] = geometry.c_pointer
    end

    # @param values [Array<Float>]
    def source_no_data_real=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:source_no_data_real] = values_ptr
    end

    # @return [Array<Float>]
    def source_no_data_real
      pointer = @c_struct[:source_no_data_real]
      return [] if pointer.null?

      pointer.read_array_of_double(@c_struct[:band_count])
    end

    # @param values [Array<Float>]
    def source_no_data_imaginary=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:source_no_data_imaginary] = values_ptr
    end

    # @return [Array<Float>]
    def source_no_data_imaginary
      pointer = @c_struct[:source_no_data_imaginary]
      return [] if pointer.null?

      pointer.read_array_of_double(@c_struct[:band_count])
    end

    # @param values [Array<Float>]
    def destination_no_data_real=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:destination_no_data_real] = values_ptr
    end

    # @return [Array<Float>]
    def destination_no_data_real
      pointer = @c_struct[:destination_no_data_real]
      return [] if pointer.null?

      pointer.read_array_of_double(@c_struct[:band_count])
    end

    # @param values [Array<Float>]
    def destination_no_data_imaginary=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:destination_no_data_imaginary] = values_ptr
    end

    # @return [Array<Float>]
    def destination_no_data_imaginary
      pointer = @c_struct[:destination_no_data_imaginary]
      return [] if pointer.null?

      pointer.read_array_of_double(@c_struct[:band_count])
    end

    # Set a Proc per source band; number of procs in +band_procs+ should equal
    # {band_count}.
    #
    # @param band_procs [Array<Proc>]
    def source_per_band_validity_mask_function=(band_procs)
      mask_func = FFI::GDAL::Warper::MaskFunc

      funcs = band_procs.map do |band_proc|
        FFI::Function.new(mask_func.result_type, mask_func.param_types, band_proc, blocking: true)
      end

      pointer = FFI::MemoryPointer.new(:pointer, band_procs.length)
      pointer.write_array_of_pointer(funcs)
      @c_struct[:source_per_band_validity_mask_function] = pointer
    end

    # Used for getting attributes of the internal WarpOptions struct.
    #
    # @param meth [Symbol] The FFI::GDAL::WarpOptions key.
    def method_missing(meth)
      super unless FFI::GDAL::WarpOptions.members.include?(meth)

      @c_struct[meth]
    end

    def respond_to_missing?(method_name, include_private = false) # rubocop:disable Style/OptionalBooleanParameter
      FFI::GDAL::WarpOptions.members.include?(method_name) || super
    end
  end
end
