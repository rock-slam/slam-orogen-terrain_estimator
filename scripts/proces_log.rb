#!/usr/bin/env ruby
#


require 'orocos/log'
require 'vizkit'
require 'orocos'
require 'plot.rb' 
include Orocos


BASE_DIR = File.expand_path('..', File.dirname(__FILE__))
ENV['PKG_CONFIG_PATH'] = "#{BASE_DIR}/build:#{ENV['PKG_CONFIG_PATH']}"
Orocos.initialize



Orocos.run('test_terrain_estimator') do |p|
  
    # log all the output ports
    Orocos.log_all_ports 

    # get the invidual tasks
    estimator = p.task 'terrain_estimator'

    logs = Array.new
    #logs <<  ARGV[0] + "external_camera.0.log"
#     logs << ARGV[0]+"lowlevel.0.log"
#     logs << ARGV[0]+"test_torque.0.log"
#     logs << ARGV[0]+"xsens_imu.0.log"
    # connect the tasks to the logs
    log_replay = Orocos::Log::Replay.open( ARGV[0] )
#     log_replay = Orocos::Log::Replay.open( logs ) 

    log_replay.hbridge.status_motors.connect_to( estimator.motor_status, :type => :data )
    log_replay.torque.ground_forces_estimated.connect_to( estimator.ground_forces_estimated, :type => :data )
    log_replay.hbridge.status_motors.connect_to( estimator.status, :type => :data )
    log_replay.xsens_imu.orientation_samples.connect_to( estimator.orientation_samples, :type => :data )
    
   # widget = Vizkit.display log_replay.external_camera.frame
    estimator.time_window = 0.01
    estimator.slip_threashold = 0.008
    estimator.terrain_type = :PATH
    
    estimator.numb_bins = 8
    estimator.histogram_max_torque = 60 
    estimator.number_points_histogram = 3000 
    
    estimator.configure
    estimator.start
    
    plot = PlotTerrain.new
    
    estimator.slip_detection.connect_to :type => :buffer,:size => 10000 do|data,name|
	plot.addSlipDetection( data ) 
	data
    end

    estimator.histogram_terrain_classification.connect_to :type => :buffer,:size => 10000 do|data,name|
	plot.addHistogramTerrainClassification( data ) 
	data
    end
    
    log_replay.align( :use_sample_time )
   
    viz = Vizkit.control log_replay
    #viz.speed = 0.1
    Vizkit.exec
    
    plot.show() 
end
