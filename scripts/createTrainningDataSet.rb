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
    estimator.number_points_histogram = 300 
    
    estimator.configure
    estimator.start
    
    file = Array.new 
    for i in 0 .. 3 
	file_single_wheel = File.new("Training_Set_"+ i.to_s+".txt", "a")
	file << file_single_wheel
    end
    output = "#"
    output = output +" time_window " + estimator.time_window.to_s
    output = output + " slip_threashold " + estimator.slip_threashold.to_s
    output = output + " numb_bins " + estimator.numb_bins.to_s
    output = output + " histogram_max_torque " + estimator.histogram_max_torque .to_s
    output = output + " number_points_histogram " + estimator.number_points_histogram.to_s
    for i in 0 .. 3 
	file[i].puts output
    end
    
    output = "Classification, " 
    for i in 0 .. estimator.numb_bins - 2 
	output = output + " bin_"+ i.to_s + ", "
    end
    output = output + " bin_"+ (estimator.numb_bins - 1).to_s 
    for i in 0 .. 3 
	file[i].puts output
    end    
    estimator.histogram_terrain_classification.connect_to :type => :buffer,:size => 10000 do|data,name|
	output = ""
	if data.terrain == :PATH 
	    output = "Standart, " 
	else
	    output = "Target, " 
	end
	for i in 0 .. estimator.numb_bins - 2 
	    output = output + data.histogram[i].to_s + ", "
	end
	output = output + data.histogram[i].to_s 
	file[data.wheel_idx].puts output
	data
    end
    
    log_replay.align( :use_sample_time )
   
    viz = Vizkit.control log_replay
    Vizkit.exec
    
end