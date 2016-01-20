function SonarStruct = hdssDefineSonarStruct
	SonarStruct = {
		% Sonar data fields
		% These are weighted means using sn0
		'cov0',							'meanw';
% 		'covn0',						'meanw';
		'int0',							'meanw'; 
% 		'sn0',							'meanw';

		% These are weighted means using sn
		'cov',							'meanw';
% 		'covn',							'meanw';
		'int',							'meanw'; 
% 		'sn',							'meanw';
		
		% VRU-corrected versions of cov/cov0
		'covs',							'meanw';
		'covs0',						'meanw';
		
		
% 		'rheader.rheader_size',			'first';
% 		'rheader.rec_num',				'first';
% 		'rheader.timemark',				'mean';
% 		'rheader.host_time',			'mean';
% 		'rheader.target_time',			'mean';
% 		'rheader.status',				'first';
% 		'rheader.spare',				'first';

		'TDS.system_type',				'first';
		'TDS.packet_ID',				'mean2';
		'TDS.time_mark',				'first';
		'TDS.time_host',				'first';
		'TDS.time_mark_year',			'first';

		'TDS.Gyro.packet_count',		'mean2';
		'TDS.Gyro.heading_cos',			'vector';
		'TDS.Gyro.heading_sin',			'vector';

		'TDS.ADAM.packet_count',		'mean2';
		'TDS.ADAM.accel_port_for',		'mean2';
		'TDS.ADAM.accel_stbd_for',		'mean2';
		'TDS.ADAM.accel_port_aft',		'mean2';
		'TDS.ADAM.accel_stbd_aft',		'mean2';
		'TDS.ADAM.openA2D1',			'mean2';
		'TDS.ADAM.openA2D2',			'mean2';
		'TDS.ADAM.pressure_port',		'mean2';
		'TDS.ADAM.pressure_stbd',		'mean2';
		'TDS.ADAM.temperature_port',	'mean2';
		'TDS.ADAM.temperature_stbd',	'mean2';
		'TDS.ADAM.temperature_spare',	'mean2';

		% Pitch/roll averaging is not strictly correct
		'TDS.TSS.packet_count',			'mean2';
		'TDS.TSS.pitch',				'mean2';
		'TDS.TSS.roll',					'mean2';
		'TDS.TSS.heave',				'mean2';
		'TDS.TSS.heading_cos',			'mean2';
		'TDS.TSS.heading_sin',			'mean2';

		'TDS.pcode.packet_count',		'mean2';
		'TDS.pcode.lat',				'vector';
		'TDS.pcode.lon',				'vector';
		'TDS.pcode.sog',				'vector';
		'TDS.pcode.cogT_cos',			'vector';
		'TDS.pcode.cogT_sin',			'vector';
		'TDS.pcode.time',				'mean2';
		'TDS.pcode.flag',				'mean2';

		% Pitch/roll averaging is not strictly correct
		'TDS.ADU2.packet_count',		'mean2';
		'TDS.ADU2.receive_time',		'mean2';
		'TDS.ADU2.heading_cos',			'vector';
		'TDS.ADU2.heading_sin',			'vector';
		'TDS.ADU2.pitch',				'mean2';
		'TDS.ADU2.roll',				'mean2';
		'TDS.ADU2.mrms',				'mean2';
		'TDS.ADU2.brms',				'mean2';
		'TDS.ADU2.attitude_reset_flag',	'mean2';
		
		% Datenum is computed from TDS.time_mark
		'datenum',						'first';
	};