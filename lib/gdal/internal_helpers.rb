require 'log_switch'

module GDAL
  module Logger
    include LogSwitch
  end

  module InternalHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Internal factory method for returning a pointer from +variable+, which could
      # be either of +klass+ class or a type of FFI::Pointer.
      def _pointer(klass, variable, warn_on_nil = true)
        if variable.kind_of?(klass)
          variable.c_pointer.autorelease = true
          variable.c_pointer
        elsif variable.kind_of? FFI::Pointer
          variable.autorelease = true
          variable
        else
          if warn_on_nil
            Logger.logger.debug "<#{name}._pointer> #{variable.inspect} is not a valid #{klass} or FFI::Pointer."
            Logger.logger.debug "<#{name}._pointer> Called at: #{caller(1, 1).first}"
          end

          nil
        end
      end

      # @param data_type [FFI::GDAL::GDALDataType]
      # @return [Symbol] The FFI Symbol that represents a data type.
      def _pointer_from_data_type(data_type, size = nil)
        pointer_type = _gdal_data_type_to_ffi(data_type)

        if size
          FFI::MemoryPointer.new(pointer_type, size)
        else
          FFI::MemoryPointer.new(pointer_type)
        end
      end

      # Maps GDAL DataTypes to FFI types.
      #
      # @param data_type [FFI::GDAL::GDALDataType]
      def _gdal_data_type_to_ffi(data_type)
        case data_type
        when :GDT_Byte then :uchar
        when :GDT_UInt16 then :uint16
        when :GDT_Int16 then :int16
        when :GDT_UInt32 then :uint32
        when :GDT_Int32 then :int32
        when :GDT_Float32 then :float
        when :GDT_Float64 then :double
        else
          :float
        end
      end

      # Check to see if the function is supported in the version of GDAL that we're
      # using.
      #
      # @param function_name [Symbol]
      # @return [Boolean]
      def _supported?(function_name)
        !FFI::GDAL.unsupported_gdal_functions.include?(function_name)
      end
    end
  end
end
