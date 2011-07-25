#!/usr/bin/env ruby
#


require 'orocos/log'
require 'vizkit'
require 'orocos'

include Orocos


BASE_DIR = File.expand_path('..', File.dirname(__FILE__))
ENV['PKG_CONFIG_PATH'] = "#{BASE_DIR}/build:#{ENV['PKG_CONFIG_PATH']}"
Orocos.initialize



Orocos::Process.spawn('test_terrain_estimator') do |p|
  
    # log all the output ports
    Orocos.log_all_ports 

    # get the invidual tasks
    estimator = p.task 'terrain_estimator'


    # connect the tasks to the logs
    log_replay = Orocos::Log::Replay.open( ARGV[0]+"/xsens_imu.0.log" ) 

    log_replay.xsens_imu.calibrated_sensors.connect_to( estimator.acceleration_samples, :type => :buffer, :size => 10 )
    log_replay.xsens_imu.orientation_samples.connect_to( estimator.orientation_samples, :type => :buffer, :size => 10 )
     
    vib_conf = estimator.vibration_configuration
    vib_conf.lines_per_terrain_sample = 100
    vib_conf.min_line_advance = 50
    vib_conf.n_fft_points = 128
    vib_conf.max_gait_STD = 999
    vib_conf.max_angular_velocity_STD = 999 
    estimator.vibration_configuration = vib_conf; 
    
    estimator.configure
    estimator.start


    log_replay.align( :use_sample_time )

    Vizkit.control log_replay
    Vizkit.exec
    
end
