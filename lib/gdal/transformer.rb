# typed: true
# frozen_string_literal: true

require_relative '../gdal'

module GDAL
  class Transformer
    # @param transformer_arg [FFI::Pointer]
    def self.destroy_transformer(transformer_arg)
      FFI::GDAL::Alg.GDALDestroyTransformer(transformer_arg)
    end
  end
end
