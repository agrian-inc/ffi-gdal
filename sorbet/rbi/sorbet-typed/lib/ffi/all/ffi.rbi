# typed: strong

class FFI::AbstractMemory
  sig { params(ary: T::Array[Integer]).returns(FFI::AbstractMemory) }
  def write_array_of_int(ary); end
end

class FFI::Pointer < FFI::AbstractMemory
  sig { params(pointer_or_type: T.any(FFI::Pointer, FFI::Type, Symbol), address: T.nilable(Integer)).void }
  def initialize(pointer_or_type, address = nil); end

  sig { params(autorelease: T::Boolean).returns(T::Boolean) }
  def autorelease=(autorelease); end
end

class FFI::MemoryPointer < FFI::Pointer
end
