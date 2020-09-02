# typed: true
# frozen_string_literal: true

require_relative '../../ext/ffi_library_function_checks'

module FFI
  module OGR
    module SRSAPI
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      # -----------------------------------------------------------------------
      # Enums
      # -----------------------------------------------------------------------
      AxisOrientation = enum :OAO_Other, 0,
                             :OAO_North, 1,
                             :OAO_South, 2,
                             :OAO_East, 3,
                             :OAO_West, 4,
                             :OAO_Up, 5,
                             :OAO_Down, 6

      DatumType = enum :ODT_HD_Min, 1000,
                       :ODT_HD_Other, 1000,
                       :ODT_HD_Classic, 1001,
                       :ODT_HD_Geocentric, 1002,
                       :ODT_HD_Max, 1999,
                       :ODT_VD_Min, 2000,
                       :ODT_VD_Other, 2000,
                       :ODT_VD_Orthometric, 2001,
                       :ODT_VD_Ellipsoidal, 2002,
                       :ODT_VD_AltitudeBarometric, 2003,
                       :ODT_VD_Normal, 2004,
                       :ODT_VD_GeoidModelDerived, 2005,
                       :ODT_VD_Depth, 2006,
                       :ODT_VD_Max, 2999,
                       :ODT_LD_Min, 10_000,
                       :ODT_LD_Max, 32_767

      # -----------------------------------------------------------------------
      # Constants
      # -----------------------------------------------------------------------
      SRS_UL = FFI::ConstGenerator.new('SRS_UL') do |gen|
        gen.include FFI::GDAL._file_with_constants('ogr_srs_api.h')
        gen.const :SRS_UL_METER,              '%s', nil, :METER_LABEL, &:inspect
        gen.const :SRS_UL_FOOT,               '%s', nil, :FOOT_LABEL, &:inspect
        gen.const :SRS_UL_FOOT_CONV,          '%s', nil, :METER_TO_FOOT, &:to_f
        gen.const :SRS_UL_NAUTICAL_MILE,      '%s', nil, :NAUTICAL_MILE_LABEL, &:inspect
        gen.const :SRS_UL_NAUTICAL_MILE_CONV, '%s', nil, :METER_TO_NAUTICAL_MILE, &:to_f
        gen.const :SRS_UL_LINK,               '%s', nil, :LINK_LABEL, &:inspect
        gen.const :SRS_UL_LINK_CONV,          '%s', nil, :METER_TO_LINK, &:to_f
        gen.const :SRS_UL_CHAIN,              '%s', nil, :CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_CHAIN_CONV,         '%s', nil, :METER_TO_CHAIN, &:to_f
        gen.const :SRS_UL_ROD,                '%s', nil, :ROD_LABEL, &:inspect
        gen.const :SRS_UL_ROD_CONV,           '%s', nil, :METER_TO_ROD, &:to_f
        gen.const :SRS_UL_LINK_Clarke,        '%s', nil, :LINK_CLARKE_LABEL, &:inspect
        gen.const :SRS_UL_LINK_Clarke_CONV,   '%s', nil, :METER_TO_LINK_CLARKE, &:to_f
        gen.const :SRS_UL_KILOMETER,          '%s', nil, :KILOMETER_LABEL, &:inspect
        gen.const :SRS_UL_KILOMETER_CONV,     '%s', nil, :METER_TO_KILOMETER, &:to_f
        gen.const :SRS_UL_DECIMETER,          '%s', nil, :DECIMETER_LABEL, &:inspect
        gen.const :SRS_UL_DECIMETER_CONV,     '%s', nil, :METER_TO_DECIMETER, &:to_f
        gen.const :SRS_UL_CENTIMETER,         '%s', nil, :CENTIMETER_LABEL, &:inspect
        gen.const :SRS_UL_CENTIMETER_CONV,    '%s', nil, :METER_TO_CENTIMETER, &:to_f
        gen.const :SRS_UL_MILLIMETER,         '%s', nil, :MILLIMETER_LABEL, &:inspect
        gen.const :SRS_UL_MILLIMETER_CONV,    '%s', nil, :METER_TO_MILLIMETER, &:to_f
        gen.const :SRS_UL_INTL_NAUT_MILE,     '%s', nil, :INTL_NAUTICAL_MILE_LABEL, &:inspect
        gen.const :SRS_UL_INTL_NAUT_MILE_CONV, '%s', nil, :METER_TO_INTL_NAUTICAL_MILE, &:to_f
        gen.const :SRS_UL_INTL_INCH,          '%s', nil, :INTL_INCH_LABEL, &:inspect
        gen.const :SRS_UL_INTL_INCH_CONV,     '%s', nil, :METER_TO_INTL_INCH, &:to_f
        gen.const :SRS_UL_INTL_FOOT,          '%s', nil, :INTL_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_INTL_FOOT_CONV,     '%s', nil, :METER_TO_INTL_FOOT, &:to_f
        gen.const :SRS_UL_INTL_YARD,          '%s', nil, :INTL_YARD_LABEL, &:inspect
        gen.const :SRS_UL_INTL_YARD_CONV,     '%s', nil, :METER_TO_INTL_YARD, &:to_f
        gen.const :SRS_UL_INTL_STAT_MILE,     '%s', nil, :INTL_STATUTE_MILE_LABEL, &:inspect
        gen.const :SRS_UL_INTL_STAT_MILE_CONV, '%s', nil, :METER_TO_INTL_STATUTE_MILE, &:to_f
        gen.const :SRS_UL_INTL_FATHOM,        '%s', nil, :INTL_FATHOM_LABEL, &:inspect
        gen.const :SRS_UL_INTL_FATHOM_CONV,   '%s', nil, :METER_TO_INTL_FATHOM, &:to_f
        gen.const :SRS_UL_INTL_CHAIN,         '%s', nil, :INTL_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_INTL_CHAIN_CONV,    '%s', nil, :METER_TO_INTL_CHAIN, &:to_f
        gen.const :SRS_UL_INTL_LINK,          '%s', nil, :INTL_LINK_LABEL, &:inspect
        gen.const :SRS_UL_INTL_LINK_CONV,     '%s', nil, :METER_TO_INTL_LINK, &:to_f
        gen.const :SRS_UL_US_INCH,            '%s', nil, :US_INCH_LABEL, &:inspect
        gen.const :SRS_UL_US_INCH_CONV,       '%s', nil, :METER_TO_US_INCH, &:to_f
        gen.const :SRS_UL_US_FOOT,            '%s', nil, :US_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_US_FOOT_CONV,       '%s', nil, :METER_TO_US_FOOT, &:to_f
        gen.const :SRS_UL_US_YARD,            '%s', nil, :US_YARD_LABEL, &:inspect
        gen.const :SRS_UL_US_YARD_CONV,       '%s', nil, :METER_TO_US_YARD, &:to_f
        gen.const :SRS_UL_US_CHAIN,           '%s', nil, :US_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_US_CHAIN_CONV,      '%s', nil, :METER_TO_US_CHAIN, &:to_f
        gen.const :SRS_UL_US_STAT_MILE,       '%s', nil, :US_STATUTE_MILE_LABEL, &:inspect
        gen.const :SRS_UL_US_STAT_MILE_CONV,  '%s', nil, :METER_TO_US_STATUTE_MILE, &:to_f
        gen.const :SRS_UL_INDIAN_YARD,        '%s', nil, :INDIAN_YARD_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_YARD_CONV,   '%s', nil, :METER_TO_INDIAN_YARD, &:to_f
        gen.const :SRS_UL_INDIAN_FOOT,        '%s', nil, :INDIAN_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_FOOT_CONV,   '%s', nil, :METER_TO_INDIAN_FOOT, &:to_f
        gen.const :SRS_UL_INDIAN_CHAIN,       '%s', nil, :INDIAN_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_CHAIN_CONV,  '%s', nil, :METER_TO_INDIAN_CHAIN, &:to_f
      end

      SRS_UL.calculate

      SRS_UA = FFI::ConstGenerator.new('SRS_UL') do |gen|
        gen.include FFI::GDAL._file_with_constants('ogr_srs_api.h')
        gen.const :SRS_UA_DEGREE,       '%s', nil, :DEGREE_LABEL, &:inspect
        gen.const :SRS_UA_DEGREE_CONV,  '%s', nil, :RADIAN_TO_DEGREE, &:to_f
        gen.const :SRS_UA_RADIAN,       '%s', nil, :RADIAN_LABEL, &:inspect
      end
      SRS_UA.calculate

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------
      typedef :pointer, :OGRSpatialReferenceH
      typedef :pointer, :OGRCoordinateTransformationH

      # -----------------------------------------------------------------------
      # Functions
      # -----------------------------------------------------------------------
      # ~~~~~~~~~~~~~
      # AxisOrientations
      # ~~~~~~~~~~~~~
      attach_function :OSRAxisEnumToName, [AxisOrientation], :strptr

      # ~~~~~~~~~~~~~
      # SpatialReference
      # ~~~~~~~~~~~~~
      attach_function :OSRNewSpatialReference, %i[string], :OGRSpatialReferenceH
      attach_function :OSRCloneGeogCS, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_function :OSRClone, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_function :OSRDestroySpatialReference, %i[OGRSpatialReferenceH], :void
      attach_function :OSRReference, %i[OGRSpatialReferenceH], :int
      attach_function :OSRDereference, %i[OGRSpatialReferenceH], :int
      attach_function :OSRRelease, %i[OGRSpatialReferenceH], :void

      attach_function :OSRValidate, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRFixupOrdering, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRFixup, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRStripCTParms, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err

      attach_function :OSRImportFromEPSG, %i[OGRSpatialReferenceH int], FFI::OGR::Core::Err
      attach_function :OSRImportFromEPSGA, %i[OGRSpatialReferenceH int], FFI::OGR::Core::Err
      attach_function :OSRImportFromWkt, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRImportFromProj4, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRImportFromESRI, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRImportFromPCI,
                      %i[OGRSpatialReferenceH string string pointer],
                      FFI::OGR::Core::Err
      attach_function :OSRImportFromUSGS,
                      %i[OGRSpatialReferenceH long long pointer long],
                      FFI::OGR::Core::Err
      attach_function :OSRImportFromXML, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRImportFromMICoordSys, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRImportFromERM,
                      %i[OGRSpatialReferenceH string string string],
                      FFI::OGR::Core::Err
      attach_function :OSRImportFromUrl, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err

      attach_function :OSRExportToWkt, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRExportToPrettyWkt, %i[OGRSpatialReferenceH pointer bool], FFI::OGR::Core::Err
      attach_function :OSRExportToProj4, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRExportToPCI,
                      %i[OGRSpatialReferenceH pointer pointer pointer],
                      FFI::OGR::Core::Err
      attach_function :OSRExportToUSGS,
                      %i[OGRSpatialReferenceH pointer pointer pointer pointer],
                      FFI::OGR::Core::Err
      attach_function :OSRExportToXML, %i[OGRSpatialReferenceH pointer buffer_out], FFI::OGR::Core::Err
      attach_function :OSRExportToMICoordSys, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRExportToERM,
                      %i[OGRSpatialReferenceH buffer_out buffer_out buffer_out],
                      FFI::OGR::Core::Err
      attach_function :OSRMorphToESRI, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRMorphFromESRI, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err

      attach_function :OSRSetAttrValue, %i[OGRSpatialReferenceH string string], FFI::OGR::Core::Err
      attach_function :OSRGetAttrValue, %i[OGRSpatialReferenceH string int], :string
      attach_function :OSRSetAngularUnits, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetAngularUnits, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetLinearUnits, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetLinearUnits, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetTargetLinearUnits, %i[OGRSpatialReferenceH string string double], FFI::OGR::Core::Err
      attach_function :OSRGetTargetLinearUnits, %i[OGRSpatialReferenceH string pointer], :double
      attach_function :OSRGetPrimeMeridian, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetLinearUnitsAndUpdateParameters,
                      %i[OGRSpatialReferenceH string double],
                      FFI::OGR::Core::Err
      attach_function :OSRGetSemiMajor, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRGetSemiMinor, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRGetInvFlattening, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetAuthority,
                      %i[OGRSpatialReferenceH string string int],
                      FFI::OGR::Core::Err
      attach_function :OSRGetAuthorityCode, %i[OGRSpatialReferenceH string], :strptr
      attach_function :OSRGetAuthorityName, %i[OGRSpatialReferenceH string], :strptr
      attach_function :OSRSetProjection, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetProjParm, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetProjParm,
                      %i[OGRSpatialReferenceH string double pointer],
                      :double
      attach_function :OSRSetNormProjParm, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetNormProjParm,
                      %i[OGRSpatialReferenceH string double pointer],
                      :double
      attach_function :OSRSetUTM, %i[OGRSpatialReferenceH int bool], FFI::OGR::Core::Err
      attach_function :OSRGetUTMZone, %i[OGRSpatialReferenceH pointer], :int
      attach_function :OSRSetStatePlane, %i[OGRSpatialReferenceH int bool], FFI::OGR::Core::Err
      attach_function :OSRSetStatePlaneWithUnits,
                      %i[OGRSpatialReferenceH int int string double],
                      FFI::OGR::Core::Err
      attach_function :OSRAutoIdentifyEPSG, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSREPSGTreatsAsLatLong, %i[OGRSpatialReferenceH], :bool
      attach_function :OSREPSGTreatsAsNorthingEasting, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRGetAxis,
                      %i[OGRSpatialReferenceH string int pointer],
                      :string

      attach_function :OSRSetACEA,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetAE,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetBonne,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetCEA,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetCS,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEC,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEckert,
                      %i[OGRSpatialReferenceH int double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEckertIV,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEckertVI,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEquirectangular,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEquirectangular2,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGS,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGH,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetIGH,
                      %i[OGRSpatialReferenceH],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGEOS,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGaussSchreiberTMercator,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGnomonic,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetHOM,
                      %i[OGRSpatialReferenceH double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetHOM2PNO,
                      %i[OGRSpatialReferenceH double double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetIWMPolyconic,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetKrovak,
                      %i[OGRSpatialReferenceH double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLAEA,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLCC,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLCC1SP,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLCCB,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetMC,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetMercator,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetMollweide,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetNZMG,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetOS,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetOrthographic,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetPolyconic,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetPS,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetRobinson,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetSinusoidal,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetStereographic,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetSOC,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTM,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTMVariant,
                      %i[OGRSpatialReferenceH string double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTMG,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTMSO,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetVDG,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetWagner,
                      %i[OGRSpatialReferenceH int double double],
                      FFI::OGR::Core::Err

      attach_function :OSRIsGeographic, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsLocal, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsProjected, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsCompound, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsGeocentric, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsVertical, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsSameGeogCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
      attach_function :OSRIsSameVertCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
      attach_function :OSRIsSame, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool

      attach_function :OSRSetLocalCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetProjCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetGeocCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetGeogCS,
                      %i[OGRSpatialReferenceH
                         string string string
                         double double string
                         double string double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetWellKnownGeogCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetFromUserInput, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRCopyGeogCSFrom, %i[OGRSpatialReferenceH OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRSetTOWGS84,
                      %i[OGRSpatialReferenceH double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRGetTOWGS84, %i[OGRSpatialReferenceH pointer int], FFI::OGR::Core::Err
      attach_function :OSRSetVertCS, %i[OGRSpatialReferenceH string string int], FFI::OGR::Core::Err
      attach_function :OSRSetCompoundCS,
                      %i[OGRSpatialReferenceH string OGRSpatialReferenceH OGRSpatialReferenceH],
                      FFI::OGR::Core::Err

      attach_function :OSRCleanup, [], :void

      # ~~~~~~~~~~~~~
      # CoordinateTransformations
      # ~~~~~~~~~~~~~
      attach_function :OCTDestroyCoordinateTransformation,
                      %i[OGRCoordinateTransformationH],
                      :void
      attach_function :OCTNewCoordinateTransformation,
                      %i[OGRSpatialReferenceH OGRSpatialReferenceH],
                      :OGRCoordinateTransformationH
      attach_function :OCTTransform,
                      %i[OGRCoordinateTransformationH int pointer pointer pointer],
                      :bool
      attach_function :OCTTransformEx,
                      %i[OGRCoordinateTransformationH int pointer pointer pointer pointer],
                      :bool

      # ~~~~~~~~~~~~~
      # Parameters
      # ~~~~~~~~~~~~~
      attach_function :OPTGetProjectionMethods, %i[], :pointer
      attach_function :OPTGetParameterList, %i[string pointer], :pointer
      attach_function :OPTGetParameterInfo,
                      %i[string string pointer pointer pointer],
                      :int
    end
  end
end
