# typed: false
# frozen_string_literal: true

module GDAL
  # @private
  module InternalHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Internal factory method for returning a pointer from +variable+, which could
      # be either of +klass+ class or a type of FFI::Pointer.
      #
      # @param klass [Class]
      # @param variable [Object]
      # @param warn_on_nil [Boolean] If +true+, print out warning that the method
      #   couldn't do what it's supposed to do.
      # @param autorelease [Boolean] Pass this on to the pointer.
      # @return [FFI::Pointer, nil]
      def _pointer(klass, variable, warn_on_nil: true, autorelease: true)
        case variable
        when klass
          variable.c_pointer.autorelease = autorelease
          variable.c_pointer
        when FFI::MemoryPointer
          variable.autorelease = autorelease
          variable
        when FFI::Pointer
          # This is a C-allocated pointer and needs to be freed using a C method,
          # and thus shouldn't be autorelease-freed.
          variable
        else
          if warn_on_nil && Logger.logging_enabled
            Logger.logger.debug "<#{name}._pointer> #{variable.inspect} is not a valid #{klass} or FFI::Pointer."
            Logger.logger.debug "<#{name}._pointer> Called at:"
            caller(1, 2).each { |line| Logger.logger.debug "<#{name}._pointer>\t#{line}" }
          end

          nil
        end
      end

      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @param size [Integer] Size of the pointer to allocate.
      # @return [FFI::MemoryPointer]
      def _pointer_from_data_type(data_type, size = nil)
        pointer_type = _gdal_data_type_to_ffi(data_type)

        size ? FFI::MemoryPointer.new(pointer_type, size) : FFI::MemoryPointer.new(pointer_type)
      end

      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @param size [Integer] Size of the pointer to allocate.
      # @return [FFI::Buffer]
      def _buffer_from_data_type(data_type, size = nil)
        pointer_type = _gdal_data_type_to_ffi(data_type)

        if size
          FFI::Buffer.alloc_inout(pointer_type, size)
        else
          FFI::Buffer.alloc_inout(pointer_type)
        end
      end

      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @param narray_args Args to pass to the NArray initializer.
      # @return [NArray]
      def _narray_from_data_type(data_type, *narray_args)
        init_meth = _gdal_data_type_to_narray(data_type)
        narray_args = 0 if narray_args.empty?

        NArray.send(init_meth, *narray_args)
      end

      # Takes an array of strings (or things that should be converted to
      # strings) and creates a char**.
      #
      # @param strings [Array<String>]
      # @return [FFI::MemoryPointer]
      def _string_array_to_pointer(strings)
        string_pointers = strings.map { |string| FFI::MemoryPointer.from_string(string.to_s) }
        string_pointers << nil
        array_pointer = FFI::MemoryPointer.new(:pointer, strings.size + 1)
        i = 0

        # fast-ruby says while is faster than each_with_index
        while i < string_pointers.length
          array_pointer[i].put_pointer(0, string_pointers[i])
          i += 1
        end

        array_pointer
      end

      # @param type [Symbol] FFI type of pointer to make a pointer to.
      # @return [FFI::MemoryPointer] Pointer to a pointer.
      def _pointer_pointer(type)
        pointer = FFI::MemoryPointer.new(type)
        pointer_ptr = FFI::MemoryPointer.new(:pointer)
        pointer_ptr.write_pointer(pointer)

        pointer_ptr
      end

      # @return [String, nil]
      def _read_pointer_pointer_safely(pointer_ptr, type)
        return if pointer_ptr.read_pointer.null?

        pointer_ptr.read_pointer.send("read_#{type}".to_sym)
      end

      # Convenience function for allocating a pointer to a string (**char),
      # yielding the pointer so it can written to (i.e. passed to a GDAL/OGR
      # function to be written to), then reads the string out of the buffer,
      # then calls FFI::CPL::VSI.VSIFree (which is an alias for
      # FFI::CPL::Conv.CPLFree).
      #
      # @yields [FFI::MemoryPointer]
      # @return [String]
      def _cpl_read_and_free_string
        result_ptr_ptr = GDAL._pointer_pointer(:string)
        result_ptr_ptr.autorelease = false

        yield result_ptr_ptr

        result = if result_ptr_ptr.null?
                   ''
                 else
                   GDAL._read_pointer_pointer_safely(result_ptr_ptr, :string)
                 end

        FFI::CPL::VSI.VSIFree(result_ptr_ptr)

        result
      end

      # Maps GDAL DataTypes to FFI types.
      #
      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @return [Symbol]
      def _gdal_data_type_to_ffi(data_type)
        case data_type
        when :GDT_Byte                    then :uchar
        when :GDT_UInt16                  then :uint16
        when :GDT_Int16, :GDT_CInt16      then :int16
        when :GDT_UInt32                  then :uint32
        when :GDT_Int32, :GDT_CInt32      then :int32
        when :GDT_Float32, :GDT_CFloat32  then :float
        when :GDT_Float64, :GDT_CFloat64  then :double
        else
          raise GDAL::InvalidDataType, "Unknown data type: #{data_type}"
        end
      end

      # Maps GDAL DataTypes to NArray types.
      #
      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @return [Symbol]
      def _gdal_data_type_to_narray(data_type)
        case data_type
        when :GDT_Byte                                then :byte
        when :GDT_Int16                               then :sint
        when :GDT_UInt16, :GDT_Int32, :GDT_UInt32     then :int
        when :GDT_Float32                             then :float
        when :GDT_Float64                             then :dfloat
        when :GDT_CInt16, :GDT_CInt32                 then :scomplex
        when :GDT_CFloat32                            then :complex
        when :GDT_CFloat64                            then :dcomplex
        else
          raise GDAL::InvalidDataType, "Unknown data type: #{data_type}"
        end
      end

      # Maps GDAL DataTypes to NArray type constants.
      #
      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @return [Symbol]
      def _gdal_data_type_to_narray_type_constant(data_type)
        case data_type
        when :GDT_Byte                            then NArray::BYTE
        when :GDT_Int16                           then NArray::SINT
        when :GDT_UInt16, :GDT_Int32, :GDT_UInt32 then NArray::INT
        when :GDT_Float32                         then NArray::FLOAT
        when :GDT_Float64                         then NArray::DFLOAT
        when :GDT_CInt16, :GDT_CInt32             then NArray::SCOMPLEX
        when :GDT_CFloat32                        then NArray::COMPLEX
        when :GDT_CFloat64                        then NArray::DCOMPLEX
        else
          raise GDAL::InvalidDataType, "Unknown data type: #{data_type}"
        end
      end

      # Helper method for reading an FFI pointer based on the GDAL DataType of
      # the pointer.
      #
      # @param pointer [FFI::Pointer] The pointer to read from.
      # @param data_type [FFI::GDAL::GDAL::DataType] The GDAL data type that
      #   determines what FFI type to use when reading.
      # @param length [Integer] The amount of data to read from the pointer. If
      #   > 1, the "read_array_of_" method will be called.
      # @return [Number, Array<Number>]
      def _read_pointer(pointer, data_type, length = 1)
        if length == 1
          pointer.send("read_#{_gdal_data_type_to_ffi(data_type)}")
        else
          pointer.send("read_array_of_#{_gdal_data_type_to_ffi(data_type)}", length)
        end
      end

      # Helper method for writing data to an FFI pointer based on the GDAL
      # DataType of the pointer.
      #
      # @param pointer [FFI::Pointer] The pointer to write to.
      # @param data_type [FFI::GDAL::GDAL::DataType] The GDAL data type that
      #   determines what FFI type to use when writing.
      # @param data [Integer] The data to write to the pointer. If it's an Array
      #   with size > 1, the "write_array_of_" method will be called.
      def _write_pointer(pointer, data_type, data)
        if data.is_a?(Array) && data.size > 1
          pointer.send("write_array_of_#{_gdal_data_type_to_ffi(data_type)}", data)
        else
          data = data.first if data.is_a?(Array)
          pointer.send("write_#{_gdal_data_type_to_ffi(data_type)}", data)
        end
      end

      # Check to see if the function is supported in the version of GDAL that we're
      # using.
      #
      # @param function_name [Symbol]
      # @return [Boolean]
      # TODO: Should the #respond_to? check all FFI::GDAL::* classes? What about
      #   OGR?
      def _supported?(function_name)
        !FFI::GDAL.unsupported_gdal_functions.include?(function_name) &&
          FFI::GDAL::GDAL.respond_to?(function_name)
      end

      # @param char [String] 'r' or 'w'
      # @return [Symbol] :GF_Read if 'r' or :GF_Write if 'w'.
      # @raise [GDAL::InvalidAccessFlag] If +char+ is not 'r' or 'w'.
      def _gdal_access_flag(char)
        case char
        when 'r' then :GF_Read
        when 'w' then :GF_Write
        else raise GDAL::InvalidAccessFlag, "Invalid access flag: #{char}"
        end
      end
    end
  end
end
