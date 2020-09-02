# typed: true
# frozen_string_literal: true

module OGR
  class NoneGeometry
    include OGR::Geometry

    # OGR doesn't seem to let you create NoneGeometries, so let's only allow
    # creation from a pointer.
    #
    # @param geometry_ptr [FFI::Pointer]
    def initialize(geometry_ptr)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
