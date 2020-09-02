# typed: false
# frozen_string_literal: true

module OGR
  module LayerMixins
    module OGRSQLMethods
      # @raise [OGR::Failure]
      def start_transaction
        transact { FFI::OGR::API.OGR_L_StartTransaction(@c_pointer) }
      end

      # @raise [OGR::Failure]
      def commit_transaction
        transact { FFI::OGR::API.OGR_L_CommitTransaction(@c_pointer) }
      end

      # @raise [OGR::Failure]
      def rollback_transaction
        transact { FFI::OGR::API.OGR_L_RollbackTransaction(@c_pointer) }
      end

      # The name of the underlying database column or "" if not supported.
      #
      # @return [String]
      def fid_column
        name, ptr = FFI::OGR::API.OGR_L_GetFIDColumn(@c_pointer)
        ptr.autorelease = false

        name
      end

      # The name of the underlying database column being used as the geometry
      # column.  Returns "" if not supported.
      #
      # @return [String]
      def geometry_column
        name, ptr = FFI::OGR::API.OGR_L_GetGeometryColumn(@c_pointer)
        ptr.autorelease = false

        name
      end

      private

      # @raise [OGR::Failure]
      def transact
        raise OGR::UnsupportedOperation, 'This layer does not support transactions.' unless supports_transactions?

        ogr_err = yield

        OGR::ErrorHandling.handle_ogr_err('Unable to set geometry directly on feature') do
          ogr_err
        end
      end
    end
  end
end
