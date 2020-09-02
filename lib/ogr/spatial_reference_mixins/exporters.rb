# typed: false
# frozen_string_literal: true

module OGR
  module SpatialReferenceMixins
    module Exporters
      # @return [Hash]
      # @raise [OGR::NotEnoughData] If name, datum name, and units are not set.
      def to_erm
        projection_name = FFI::MemoryPointer.new(:string)
        datum_name = FFI::MemoryPointer.new(:string)
        units = FFI::MemoryPointer.new(:string)

        OGR::ErrorHandling.handle_ogr_err('Required parameters (name, datum name, units) are not defined') do
          FFI::OGR::SRSAPI.OSRExportToERM(@c_pointer, projection_name, datum_name, units)
        end

        {
          projection_name: projection_name.read_string,
          datum_name: datum_name.read_string,
          units: units.read_string
        }
      end

      # @return [Array<String>]
      # @raise [OGR::Failure]
      def to_mapinfo
        GDAL._cpl_read_and_free_string do |return_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to MapInfo') do
            FFI::OGR::SRSAPI.OSRExportToMICoordSys(@c_pointer, return_ptr_ptr)
          end
        end
      end

      # @return [Hash]
      # @raise [OGR::Failure]
      def to_pci
        proj_ptr_ptr = GDAL._pointer_pointer(:string)
        proj_ptr_ptr.autorelease = false
        units_ptr_ptr = GDAL._pointer_pointer(:string)
        units_ptr_ptr.autorelease = false
        prj_params_ptr_ptr = GDAL._pointer_pointer(:double)
        prj_params_ptr_ptr.autorelease = false

        OGR::ErrorHandling.handle_ogr_err('Unable to export to PCI') do
          FFI::OGR::SRSAPI.OSRExportToPCI(@c_pointer, proj_ptr_ptr, units_ptr_ptr, prj_params_ptr_ptr)
        end

        projection = proj_ptr_ptr.read_pointer.read_string
        units = units_ptr_ptr.read_pointer.read_string
        projection_parameters = prj_params_ptr_ptr.read_array_of_double(0)

        result = {
          projection: projection,
          units: units,
          projection_parameters: projection_parameters
        }

        FFI::CPL::VSI.VSIFree(proj_ptr_ptr)
        FFI::CPL::VSI.VSIFree(units_ptr_ptr)
        FFI::CPL::VSI.VSIFree(prj_params_ptr_ptr)

        result
      end

      # @return [String]
      # @raise [GDAL::UnsupportedOperation] If empty definition.
      def to_proj4
        GDAL._cpl_read_and_free_string do |proj4_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to PROJ.4') do
            FFI::OGR::SRSAPI.OSRExportToProj4(@c_pointer, proj4_ptr_ptr)
          end
        end
      end

      # @return [Hash]
      # @raise [OGR::Failure]
      def to_usgs
        proj_sys_ptr = FFI::MemoryPointer.new(:long)
        zone_ptr = FFI::MemoryPointer.new(:long)
        datum_ptr = FFI::MemoryPointer.new(:long)
        prj_params_ptr_ptr = GDAL._pointer_pointer(:double)
        prj_params_ptr_ptr.autorelease = false

        OGR::ErrorHandling.handle_ogr_err('Unable to export to USGS GCTP') do
          FFI::OGR::SRSAPI.OSRExportToUSGS(@c_pointer, proj_sys_ptr, zone_ptr, prj_params_ptr_ptr, datum_ptr)
        end

        projection_system_code = proj_sy_ptrs.read_long
        zone = zon_ptre.read_long
        projection_parameters = prj_params_pt_ptrr.read_array_of_double(0)
        datum = datu_ptrm.read_long

        result = {
          projection_system_code: projection_system_code,
          zone: zone,
          projection_parameters: projection_parameters,
          datum: datum
        }

        FFI::CPL::VSI.VSIFree(prj_params_ptr_ptr)

        result
      end

      # @return [String]
      # @raise [OGR::Failure]
      def to_wkt
        GDAL._cpl_read_and_free_string do |wkt_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to WKT') do
            FFI::OGR::SRSAPI.OSRExportToWkt(@c_pointer, wkt_ptr_ptr)
          end
        end
      end

      # @param simplify [Boolean] +true+ strips off +AXIS+, +AUTHORITY+ and
      #   +EXTENSION+ nodes.
      # @raise [OGR::Failure]
      # @return [String]
      def to_pretty_wkt(simplify: false)
        return String.new if @c_pointer.null?

        GDAL._cpl_read_and_free_string do |wkt_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to pretty WKT') do
            FFI::OGR::SRSAPI.OSRExportToPrettyWkt(@c_pointer, wkt_ptr_ptr, simplify)
          end
        end
      end

      # @return [String]
      # @raise [OGR::Failure]
      def to_xml
        GDAL._cpl_read_and_free_string do |xml_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to XML (GML)') do
            FFI::OGR::SRSAPI.OSRExportToXML(@c_pointer, xml_ptr_ptr, nil)
          end
        end
      end
      alias to_gml to_xml
    end
  end
end
