# typed: false
# frozen_string_literal: true

require 'gdal/warp_options'

RSpec.describe GDAL::WarpOptions do
  shared_examples 'a WarpOptions object' do
    it 'inits proper types' do
      expect(subject.warp_operation_options).to be_a Hash

      expect(subject.source_bands).to be_a Array
      expect(subject.destination_bands).to be_a Array

      expect(subject.source_no_data_real).to be_a Array
      expect(subject.source_no_data_imaginary).to be_a Array
      expect(subject.destination_no_data_real).to be_a Array
      expect(subject.destination_no_data_imaginary).to be_a Array

      expect(subject.progress).to be_a FFI::Function
      expect(subject.progress_arg).to be_a FFI::Pointer
      expect(subject.transformer).to be_a FFI::Function
      expect(subject.transformer_arg).to be_a FFI::Pointer

      expect(subject.source_per_band_validity_mask_function).to be_a FFI::Pointer
      expect(subject.source_per_band_validity_mask_function_arg).to be_a FFI::Pointer
      expect(subject.source_validity_mask_function).to be_a FFI::Function
      expect(subject.source_validity_mask_function_arg).to be_a FFI::Pointer
      expect(subject.source_density_mask_function).to be_a FFI::Function
      expect(subject.source_density_mask_function_arg).to be_a FFI::Pointer

      expect(subject.destination_density_mask_function).to be_a FFI::Function
      expect(subject.destination_density_mask_function_arg).to be_a FFI::Pointer
      expect(subject.destination_validity_mask_function).to be_a FFI::Function
      expect(subject.destination_validity_mask_function_arg).to be_a FFI::Pointer

      expect(subject.pre_warp_chunk_processor).to be_a FFI::Function
      expect(subject.pre_warp_processor_arg).to be_a FFI::Pointer
      expect(subject.post_warp_chunk_processor).to be_a FFI::Function
      expect(subject.post_warp_processor_arg).to be_a FFI::Pointer
    end
  end

  describe '#initialize' do
    context 'with no options' do
      it_behaves_like 'a WarpOptions object'

      it 'inits a FFI::GDAL::WarpOptions struct internally, with nothing set' do
        expect(subject.warp_operation_options).to eq({})

        expect(subject.warp_memory_limit).to be_zero
        expect(subject.resample_alg).to eq(:GRA_NearestNeighbor) # 0 enum
        expect(subject.working_data_type).to eq(:GDT_Unknown) # 0 enum

        expect(subject.source_dataset).to be_nil
        expect(subject.destination_dataset).to be_nil

        expect(subject.band_count).to be_zero
        expect(subject.source_bands).to be_empty
        expect(subject.destination_bands).to be_empty

        expect(subject.source_alpha_band).to be_zero
        expect(subject.destination_alpha_band).to be_zero

        expect(subject.source_no_data_real).to eq([])
        expect(subject.source_no_data_imaginary).to eq([])
        expect(subject.destination_no_data_real).to eq([])
        expect(subject.destination_no_data_imaginary).to eq([])

        expect(subject.progress).to_not be_null
        expect(subject.progress_arg).to be_null

        expect(subject.transformer).to be_null
        expect(subject.transformer_arg).to be_null

        expect(subject.source_per_band_validity_mask_function).to be_null
        expect(subject.source_per_band_validity_mask_function_arg).to be_null

        expect(subject.source_validity_mask_function).to be_null
        expect(subject.source_validity_mask_function_arg).to be_null

        expect(subject.source_density_mask_function).to be_null
        expect(subject.source_density_mask_function_arg).to be_null

        expect(subject.destination_density_mask_function).to be_null
        expect(subject.destination_density_mask_function_arg).to be_null

        expect(subject.destination_validity_mask_function).to be_null
        expect(subject.destination_validity_mask_function_arg).to be_null

        expect(subject.pre_warp_chunk_processor).to be_null
        expect(subject.pre_warp_processor_arg).to be_null
        expect(subject.post_warp_chunk_processor).to be_null
        expect(subject.post_warp_processor_arg).to be_null

        expect(subject.cutline).to be_nil
        expect(subject.cutline_blend_distance).to eq(0.0)
      end
    end

    context 'passing in options that are also accessor methods' do
      let(:warp_operation_options) do
        {
          init_dest: 'NODATA',
          write_flush: 'YES',
          skip_nosource: 'NO',
          sample_grid: 'YES'
        }
      end

      let(:memory_driver) { GDAL::Driver.by_name('MEM') }
      let(:source_dataset) { memory_driver.create_dataset 'source', 10, 20 }
      let(:dest_dataset) { memory_driver.create_dataset 'dest', 20, 30 }
      let(:cutline) { OGR::LineString.new }
      let(:spb_validity_mask_function1) { proc { true } }
      let(:spb_validity_mask_function2) { proc { false } }

      after do
        source_dataset.close
        dest_dataset.close
      end

      subject do
        described_class.new warp_operation_options: warp_operation_options,
                            source_dataset: source_dataset,
                            destination_dataset: dest_dataset,
                            source_bands: [1, 2, 3],
                            destination_bands: [2, 4, 6],
                            cutline: cutline,
                            source_no_data_real: [123.456, 78.9, -999.9],
                            source_no_data_imaginary: [1.2, 3.4, -5.6],
                            destination_no_data_real: [11.1, 22.2, 33.3],
                            destination_no_data_imaginary: [-44.4, -55.5, -66.6],
                            source_per_band_validity_mask_function: [
                              spb_validity_mask_function1,
                              spb_validity_mask_function2
                            ]
      end

      it_behaves_like 'a WarpOptions object'

      it 'sets warp_operation_options' do
        expect(subject.warp_operation_options).to eq(warp_operation_options)
      end

      it 'sets source_dataset and the internal pointer' do
        expect(subject.source_dataset).to eq(source_dataset)
        expect(subject.c_struct[:source_dataset]).to eq(source_dataset.c_pointer)
      end

      it 'sets destination_dataset' do
        expect(subject.destination_dataset).to eq(dest_dataset)
        expect(subject.c_struct[:destination_dataset]).to eq(dest_dataset.c_pointer)
      end

      it 'sets source_bands' do
        expect(subject.source_bands).to eq([1, 2, 3])
      end

      it 'sets destination_bands' do
        expect(subject.destination_bands).to eq([2, 4, 6])
      end

      it 'sets band_count and the internal to 3' do
        expect(subject.band_count).to eq 3
        expect(subject.c_struct[:band_count]).to eq 3
      end

      it 'sets cutline and its internal pointer' do
        expect(subject.cutline).to eq(cutline)
        expect(subject.c_struct[:cutline]).to eq(cutline.c_pointer)
      end

      it 'sets source_no_data_real' do
        expect(subject.source_no_data_real).to eq([123.456, 78.9, -999.9])
      end

      it 'sets source_no_data_imaginary' do
        expect(subject.source_no_data_imaginary).to eq([1.2, 3.4, -5.6])
      end

      it 'sets destination_no_data_real' do
        expect(subject.destination_no_data_real).to eq([11.1, 22.2, 33.3])
      end

      it 'sets destination_no_data_imaginary' do
        expect(subject.destination_no_data_imaginary).to eq([-44.4, -55.5, -66.6])
      end

      it 'sets source_per_band_validity_mask_function' do
        function_ptr = subject.source_per_band_validity_mask_function
        expect(function_ptr).to be_a(FFI::Pointer)

        function = function_ptr.read_pointer
        expect(function).to_not be_null
      end
    end

    context 'passing in options that are NOT accessor methods' do
      def make_int_pointer(int)
        i = FFI::MemoryPointer.new(:int)
        i.write_int(int)
        i
      end

      let(:progress) { proc { true } }
      let(:test_mask_function) { proc { true } }

      let(:source_per_band_validity_mask_function_arg) { make_int_pointer(5) }
      let(:source_validity_mask_function_arg) { make_int_pointer(3) }
      let(:source_density_mask_function_arg) { make_int_pointer(2) }
      let(:destination_validity_mask_function_arg) { make_int_pointer(4) }
      let(:destination_density_mask_function_arg) { make_int_pointer(11) }
      let(:pre_warp_processor_arg) { make_int_pointer(7) }
      let(:post_warp_processor_arg) { make_int_pointer(9) }

      subject do
        described_class.new warp_memory_limit: 123,
                            resample_alg: :GRA_Lanczos,
                            working_data_type: :GDT_CInt32,
                            band_count: 3,
                            source_alpha_band: 1,
                            destination_alpha_band: 5,
                            progress: progress,
                            progress_arg: FFI::CPL::Progress::ScaledProgress,
                            source_per_band_validity_mask_function_arg: source_per_band_validity_mask_function_arg,
                            source_validity_mask_function: test_mask_function,
                            source_validity_mask_function_arg: source_validity_mask_function_arg,
                            source_density_mask_function: test_mask_function,
                            source_density_mask_function_arg: source_density_mask_function_arg,
                            destination_validity_mask_function: test_mask_function,
                            destination_validity_mask_function_arg: destination_validity_mask_function_arg,
                            destination_density_mask_function: test_mask_function,
                            destination_density_mask_function_arg: destination_density_mask_function_arg,
                            pre_warp_chunk_processor: proc { :CE_Warning },
                            pre_warp_processor_arg: pre_warp_processor_arg,
                            post_warp_chunk_processor: proc { :CE_Failure },
                            post_warp_processor_arg: post_warp_processor_arg,
                            cutline_blend_distance: 3.3
      end

      it_behaves_like 'a WarpOptions object'

      it 'sets warp_memory_limit' do
        expect(subject.warp_memory_limit).to eq(123)
      end

      it 'sets resample_alg' do
        expect(subject.resample_alg).to eq(:GRA_Lanczos)
      end

      it 'sets working_data_type' do
        expect(subject.working_data_type).to eq(:GDT_CInt32)
      end

      it 'sets band_count' do
        expect(subject.band_count).to eq(3)
      end

      it 'sets source_alpha_band' do
        expect(subject.source_alpha_band).to eq(1)
      end

      it 'sets destination_alpha_band' do
        expect(subject.destination_alpha_band).to eq(5)
      end

      it 'sets progress_arg' do
        expect(subject.progress_arg).to eq(FFI::CPL::Progress::ScaledProgress)
      end

      it 'sets source_per_band_validity_mask_function_arg' do
        pointer = subject.source_per_band_validity_mask_function_arg
        pointer.autorelease = false
        expect(pointer.read_int).to eq 5
      end

      it 'sets source_validity_mask_function' do
        expect(subject.source_validity_mask_function).to_not be_null
      end

      it 'sets source_validity_mask_function_arg' do
        pointer = subject.source_validity_mask_function_arg
        pointer.autorelease = false
        expect(pointer.read_int).to eq 3
      end

      it 'sets source_density_mask_function' do
        expect(subject.source_density_mask_function).to_not be_null
      end

      it 'sets source_density_mask_function_arg' do
        pointer = subject.source_density_mask_function_arg
        pointer.autorelease = false
        expect(pointer.read_int).to eq 2
      end

      it 'sets destination_validity_mask_function' do
        expect(subject.destination_validity_mask_function).to_not be_null
      end

      it 'sets destination_validity_mask_function_arg' do
        pointer = subject.destination_validity_mask_function_arg
        pointer.autorelease = false
        expect(pointer.read_int).to eq 4
      end

      it 'sets destination_density_mask_function' do
        expect(subject.destination_density_mask_function).to_not be_null
      end

      it 'sets destination_density_mask_function_arg' do
        pointer = subject.destination_density_mask_function_arg
        pointer.autorelease = false
        expect(pointer.read_int).to eq 11
      end

      it 'sets pre_warp_chunk_processor' do
        expect(subject.pre_warp_chunk_processor.call(nil, nil)).to eq(:CE_Warning)
      end

      it 'sets pre_warp_chunk_processor_arg' do
        expect(subject.pre_warp_processor_arg).to_not be_null
      end

      it 'sets post_warp_chunk_processor' do
        expect(subject.post_warp_chunk_processor.call(nil, nil)).to eq(:CE_Failure)
      end

      it 'sets post_warp_chunk_processor_arg' do
        expect(subject.post_warp_processor_arg).to_not be_null
      end

      it 'sets cutline_blend_distance' do
        expect(subject.cutline_blend_distance).to eq(3.3)
      end
    end
  end
end
