% layout of the headers in the Hdss sonar files.

% rheader
rheaderlayout = {
	'uint32'		'rheader_size' 1;
	'uint32'		'rec_num' 1;
	'uint32'		'timemark' 1;					%	timemark from hydra sonar record
	'uint32'		'host_time' 1;					%	from time_address
	'uint32'		'target_time' 1;				%	tests if buffer is synchronous 
	'uint32'		'status' 1;						%	tests if buffer is synchronous 
	'uint32'		'spare' 26;						%	tests if buffer is synchronous 
};

% TDSdata_4Sonar_Struct
tdslayout = {
	'uint32'		'system_type' 1;				%	0 = little endian, 1 = big endian
	'uint32'		'packet_ID' 1;
	'uint32'		'time_mark' 1;					%	TDS time
	'uint32'		'time_host' 1;
	'int32'			'time_mark_year' 1;
	
	% Gyro4SendStruct
	'uint32'		'Gyro.packet_count' 1;			%	# packets
	'float32'		'Gyro.heading_cos' 1;
	'float32'		'Gyro.heading_sin' 1;
	
	% ADAM4SendStruct
	'uint32'		'ADAM.packet_count' 1;			%	# packets
	'float32'		'ADAM.accel_port_for' 1;		%	° Tilt from vertical
	'float32'		'ADAM.accel_stbd_for' 1;		%	° Tilt from vertical
	'float32'		'ADAM.accel_port_aft' 1;		%	° Tilt from vertical
	'float32'		'ADAM.accel_stbd_aft' 1;		%	° Tilt from vertical
	'float32'		'ADAM.openA2D1' 1;				%	volts
	'float32'		'ADAM.openA2D2' 1;				%	volts
	'float32'		'ADAM.pressure_port' 1;			%	volts
	'float32'		'ADAM.pressure_stbd' 1;			%	volts
	'float32'		'ADAM.temperature_port' 1;		%	°C
	'float32'		'ADAM.temperature_stbd' 1;		%	°C
	'float32'		'ADAM.temperature_spare' 1;		%	°C
	
	% TSS4SendStruct
	'uint32'		'TSS.packet_count' 1;			%	# packets
	'float32'		'TSS.pitch' 1;
	'float32'		'TSS.roll' 1;
	'float32'		'TSS.heave' 1;
	'float32'		'TSS.heading_cos' 1;
	'float32'		'TSS.heading_sin' 1;
	
	% PCode4SendStruct
	'uint32'		'pcode.packet_count' 1;			%	# packets
	'float64'		'pcode.lat' 1;					%	ddmm.mmmmmm
	'float64'		'pcode.lon' 1;					%	ddmm.mmmmmm
	'float32'		'pcode.sog' 1;					%	cm/s
	'float32'		'pcode.cogT_cos' 1;				%	degrees, true
	'float32'		'pcode.cogT_sin' 1;				%	degrees, true
	'float32'		'pcode.time' 1;					%	hhmmss.ss
	'int32'			'pcode.flag' 1;					%	0: not navigating, 1: raw - (comment later) 2: cdma (low res), 3: pcode (high res)

	% ADU24SendStruct
	'uint32'		'ADU2.packet_count' 1;			%	# packets
	'float32'		'ADU2.receive_time' 1;			%	ashtech ADU2 GPS receive time in seconds
	'float32'		'ADU2.heading_cos' 1;			%	ashtech ADU2 heading cosine
	'float32'		'ADU2.heading_sin' 1;			%	ashtech ADU2 heading cosine
	'float32'		'ADU2.pitch' 1;					%	ashtech ADU2 pitch in degrees
	'float32'		'ADU2.roll' 1;					%	ashtech ADU2 pitch in degrees
	'float32'		'ADU2.mrms' 1;					%	ashtech ADU2 measurement RMS error in meters
	'float32'		'ADU2.brms' 1;					%	ashtech ADU2 baseline RMS error in meters
	'float32'		'ADU2.attitude_reset_flag' 1;	%	ashtech ADU2 attitude reset flag
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5  

% dasRecStruct
daslayout = {
	'*char'			'data_Type_System' 32;			%	define big/little endian
	'int32'			'dasrec_size' 1;				%	header size
	
	% SonarRecordStruct	
	'int32'			'Record.SonarRecordStruct_size' 1;		% size of SonarRecordStruct struct
	'*char'			'Record.run_name' 256;
    'int32'			'Record.warnmin' 1;
    'float32'		'Record.max_FileSize' 1;
    'int32'			'Record.rec_sens' 1;			%	1 = record sensors
    'int32'			'Record.rec_janus' 1;			%	1 = record janus doppler
    'int32'			'Record.rec_slant' 1;			%	1 = record slant doppler
    'int32'			'Record.rec_raw' 1;				%	1 = record raw data
	'int32'			'Record.data1_flag' 1;			%	first data set
	'int32'			'Record.data2_flag' 1;			%	second data set
	'*char'			'Record.path_copy1' 256;
	'*char'			'Record.path_copy2' 256;
		% New flags added here on 2008/07/01
	'int32'			'Record.cov1_flag' 1;			%	first cov flag
	'int32'			'Record.cov2_flag' 1;			%	second cov flag
	'*char'			'Record.cov1_path' 256;
	'*char'			'Record.cov2_path' 256;
	
	% SonarComStruct
	'int32'			'SonarCom.sonar_com_size' 1;	%	size of sonar com struct
	'int32'			'SonarCom.das_serialNum' 1;		%	serial number
	'uint32'		'SonarCom.time' 1;				%	time
	'int32'			'SonarCom.rec_header_size' 1;	%	record header size	(bytes)
	'int32'			'SonarCom.reclength' 1;			%	record size	(bytes)
    'int32'			'SonarCom.n_seq' 1; 			%	# of sequences per ensemble
    'int32'			'SonarCom.sample_period' 1;		%	sample periods in milliseconds
    'int32'			'SonarCom.seq_length' 1;		%	sequence length (samples)
    'int32'			'SonarCom.samples_to_acquire' 1;		%	# of samples to record
    'int32'			'SonarCom.n_ensmb' 1;			%	# of ensembles to record
    'int32'			'SonarCom.xmitfreq' 1;			%	transmit frequency, hz
	'int32'			'SonarCom.mixfreq' 1;			%	mixer frequency, hz	
    'int32'			'SonarCom.n_modes' 1;			%	# of modes, currently  one mode
    'int32'			'SonarCom.n_aux' 1;				%	# of auxillary controls
    '*char'			'SonarCom.run_notes' 1024;		%	run notes
    'int32'			'SonarCom.n_xducers' 1;			%	# of xducers, from start-up file
    'int32'			'SonarCom.n_data_channels' 1;	%	# of 16 bit  data channels from a2d usually 2 per receiver
    'int32'			'SonarCom.databuffsize' 1;		%	size of data buffer    
    'uint32'		'SonarCom.start_DateTime' 1;	%	run start time
    '*char'			'SonarCom.sodad_version_str' 256;
    'int32' 		'SonarCom.UserLevel' 1;			%	Simple User Interface == 1, Advanced == 0
    'int32'			'SonarCom.PowerLevel' 1;		%	Power Level last set in controller.
    '*char'			'SonarCom.SonarType' 32;		%	switch for sonar:  0 == 50kHz, 1 == 140 kHz
	
	% SonarTDS_SetupStruct
	'int32'			'TDS.SonarTDS_SetupStruct_size' 1;		% the size of SonarTDSStruct struct
    'int32'			'TDS.TDS_on' 1;						%	use 'char' for Boolean type
	'int32'			'TDS.UDPportNum' 1;				%	UDP port to get TDS data
    'int32'			'TDS.sync_flag' 1;	
    'int32'			'TDS.n_time_marks' 1;			%	number of time marks per sequence
    'int32'			'TDS.TDSrecs' 1;					%	number of TDS records appended to each data record
    'int32'			'TDS.cir_buff_size' 1;			%	circular buffer size
    'int32'			'TDS.hold_off' 1;				%	number of milliseconds to hold off at the end of the sequence
    'int32'			'TDS.sync_mode' 1;				%	controller sync mode -- 0: no sync 1: standard sync

	% SonarTxStruct
	'int32'			'Tx.sonar_tx_size' 1;			%	the size of sonar tx struct
    'int32'			'Tx.relay_delay' 1;
    'int32'			'Tx.autorelay' 1;
    'int32'			'Tx.post_xmt_gate_delay' 1;
	'int32'			'Tx.start_time' 1;				%	transmit start time
	'int32'			'Tx.bit_width' 1;				%	transmit bit width
	'*char'			'Tx.code' 32;					%	transmit code string
	'int32'			'Tx.code_reps' 1;				%	 # of subcode repeats
	'int32'			'Tx.tone_reps' 1;				%	transmit repeats
	'int32'			'Tx.trep_period' 1;				%	transmit repeat period     
	'int32'			'Tx.n_bits' 1;					%	code length
	'int32'			'Tx.bit_smoothing_fact' 1;
	'int32'			'Tx.dac_slct' 1;
	'int32'			'Tx.gate_slct' 1;
    'int32'			'Tx.MaxPower' 1;

	% SonarHardwareStruct
	'int32'			'Hardware.SonarHardwareStruct_size' 1;		% the size of SonarHardwareStruct struct
	'int32'			'Hardware.data_link_flag' 1;
	'int32'			'Hardware.controller_flag' 1;
	
	% Data_link_setup_struct
	'int32'			'Hardware.Data_link_setup_struct_size' 1;	% the size of Data_link_setup_struct struct
	'*char'			'Hardware.Data_link.IPaddr' 32;
	'int32'			'Hardware.Data_link.readPort' 1;
	'int32'			'Hardware.Data_link.sendPort' 1;
	'int32'			'Hardware.Data_link.resetPort' 1;
	'int32'			'Hardware.Data_link.data_mode' 1;
	
	% Controller_setup_struct
	'int32'			'Hardware.Controller_setup_struct_size' 1;	%	the size of Controller_setup_struct struct
	'*char'			'Hardware.Controller.PortName' 32;			%	serial port
	'*char'			'Hardware.Controller.SerialPort' 1432;		%	just leave these contents alone
	'int32'			'Hardware.Controller.xtal_freq' 1;
	'int32'			'Hardware.Controller.tx_map_period' 1;
	'int32'			'Hardware.Controller.n_data_channels' 1;	%	# of 16 bit  data channels from a2d usually 2 per receiver

	% SonarProcessingStruct
	'int32'			'SonarProcessingStruct_size' 1;		%	the size of SonarProcessingStruct struct
	'int32'			'samples_to_process' 1;				%	 # of AD samples to process 
	'int32'			'time_lag' 1;						%	time lag (code bits) 
	'int32'			'range_average' 1;					%	 # of AD samples per range bin 
	'int32'			'n_bins' 1;							%	 # of range bins 
	'float32'		'bin_size_meters' 1;				%	range bin size in meters 
	'int32'			'filter_type' 1;					%	filter selector: 0 for no filter 1 for cheby etc
	'int32'			'cov_proc_type' 1;					%	covariance proc selector
	% beam_seg_params[4]
	'int32'			'beam(1).beam_seg_params_size' 1;	%	the size of beam_seg_params struct
    'float32'		'beam(1).depression' 1;
    'float32'		'beam(1).azimuth' 1;
    'float32'		'beam(1).seg0_weight' 1;
    'float32'		'beam(1).seg1_weight' 1;
    'float32'		'beam(1).seg0_phase' 1;
    'float32'		'beam(1).seg1_phase' 1;
	'int32'			'beam(2).beam_seg_params_size' 1;	%	the size of beam_seg_params struct
    'float32'		'beam(2).depression' 1;
    'float32'		'beam(2).azimuth' 1;
    'float32'		'beam(2).seg0_weight' 1;
    'float32'		'beam(2).seg1_weight' 1;
    'float32'		'beam(2).seg0_phase' 1;
    'float32'		'beam(2).seg1_phase' 1;
	'int32'			'beam(3).beam_seg_params_size' 1;	%	the size of beam_seg_params struct
    'float32'		'beam(3).depression' 1;
    'float32'		'beam(3).azimuth' 1;
    'float32'		'beam(3).seg0_weight' 1;
    'float32'		'beam(3).seg1_weight' 1;
    'float32'		'beam(3).seg0_phase' 1;
    'float32'		'beam(3).seg1_phase' 1;
	'int32'			'beam(4).beam_seg_params_size' 1;	%	the size of beam_seg_params struct
    'float32'		'beam(4).depression' 1;
    'float32'		'beam(4).azimuth' 1;
    'float32'		'beam(4).seg0_weight' 1;
    'float32'		'beam(4).seg1_weight' 1;
    'float32'		'beam(4).seg0_phase' 1;
    'float32'		'beam(4).seg1_phase' 1;
    'int32'			'combine_segments' 1;
	'*char'			'data_format_str' 1024;
};