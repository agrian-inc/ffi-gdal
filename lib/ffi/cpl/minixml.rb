# typed: true
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module MiniXML
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #-------------------------------------------------------------------------
      # Enums
      #-------------------------------------------------------------------------
      XMLNodeType = enum :CXT_Element, 0,
                         :CXT_Text, 1,
                         :CXT_Attribute, 2,
                         :CXT_Comment, 3,
                         :CXT_Literal, 4

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_function :CPLParseXMLString, %i[string], CPL::XMLNode.ptr
      attach_function :CPLDestroyXMLNode, [CPL::XMLNode.ptr], :void
      attach_function :CPLGetXMLNode, [CPL::XMLNode.ptr, :string], CPL::XMLNode.ptr
      attach_function :CPLSearchXMLNode, [CPL::XMLNode.ptr, :string], CPL::XMLNode.ptr
      attach_function :CPLGetXMLValue, [CPL::XMLNode.ptr, :string, :string], :strptr
      attach_function :CPLCreateXMLNode, [CPL::XMLNode.ptr, CPL::XMLNode.ptr, :string], CPL::XMLNode.ptr
      attach_function :CPLSerializeXMLTree, [CPL::XMLNode.ptr], :string
      attach_function :CPLAddXMLChild, [CPL::XMLNode.ptr, CPL::XMLNode.ptr], :void
      attach_function :CPLRemoveXMLChild, [CPL::XMLNode.ptr, CPL::XMLNode.ptr], :bool
      attach_function :CPLAddXMLSibling, [CPL::XMLNode.ptr, CPL::XMLNode.ptr], :void
      attach_function :CPLCreateXMLElementAndValue,
                      [CPL::XMLNode.ptr, :string, :string],
                      CPL::XMLNode.ptr
      attach_function :CPLCloneXMLTree, [CPL::XMLNode.ptr], CPL::XMLNode.ptr
      attach_function :CPLSetXMLValue, [CPL::XMLNode.ptr, :string, :string], :bool
      attach_function :CPLStripXMLNamespace, [CPL::XMLNode.ptr, :string, :bool], :void
      attach_function :CPLCleanXMLElementName, %i[string], :void
      attach_function :CPLParseXMLFile, %i[string], CPL::XMLNode.ptr
      attach_function :CPLSerializeXMLTreeToFile, [CPL::XMLNode.ptr, :string], :bool
    end
  end
end
