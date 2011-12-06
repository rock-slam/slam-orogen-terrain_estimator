#!/usr/bin/env ruby
#


require 'orocos/log'
require 'vizkit'
require 'orocos'
#require 'plot.rb'
require 'svm_configuration'
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
 
    logs << ARGV[0]+"lowlevel.0.log"
    logs << ARGV[0]+"test_torque.0.log"
    logs << ARGV[0]+"xsens_imu.0.log"
    # connect the tasks to the logs
 #    log_replay = Orocos::Log::Replay.open( ARGV[0] )
      log_replay = Orocos::Log::Replay.open( logs ) 

    log_replay.hbridge.status_motors.connect_to( estimator.motor_status, :type => :data ) 
    log_replay.torque.ground_forces_estimated.connect_to( estimator.ground_forces_estimated, :type => :data )
    #log_replay.hbridge.status_motors.connect_to( estimator.status, :type => :data )
    log_replay.xsens_imu.orientation_samples.connect_to( estimator.orientation_samples, :type => :data )
    
   # widget = Vizkit.display log_replay.external_camera.frame
    estimator.terrain_type = :PEBLES
    estimator.slip_threashold = 0.005 #0.008 
   
    svm_classifiers = estimator.svm_classifier
	svm_conf = Orocos.registry.get("terrain_estimator/SVMConfiguration")
	svm_classifier = estimator.svm_classifier 
	svm = svm_classifiers.svm_classifier
	    for wheel_idx in 0..3
		svm[wheel_idx] << svm_path_vs_grass(svm_conf.new, wheel_idx)
		#svm[wheel_idx] << svm_path_vs_pebles(svm_conf.new, wheel_idx)
		#svm[wheel_idx] << svm_grass_vs_pebles(svm_conf.new, wheel_idx)
	    end
	svm_classifier.svm_classifier = svm 
	svm_classifier.min_number_votes = 1
	terrain_types = svm_classifier.terrain_types
	    terrain_types << :UNKNOWN
	    terrain_types << :GRASS 
	    terrain_types << :PATH
# 	    terrain_types << :PEBLES
	svm_classifier.terrain_types = terrain_types
    estimator.svm_classifier = svm_classifier

    pp  estimator.svm_classifier
    
    configuration = estimator.configuration 
        configuration.number_of_histogram_combine = 3
	configuration.number_bins = 16
	configuration.histogram_max_torque = 0
	configuration.histogram_min_torque = -50 #-60
    estimator.configuration = configuration 
    
    estimator.configure
    estimator.start
    
#     plot = PlotTerrain.new 
#     
#     estimator.debug_slip_detection.connect_to :type => :buffer,:size => 10000 do|data,name|
# 	plot.addDebugSlipDetection( data ) 
# 	data
#     end
# 
#     estimator.histogram_terrain_classification.connect_to :type => :buffer,:size => 10000 do|data,name|
# 	#plot.addHistogramTerrainClassification( data ) 
# 	data
#     end
#     
#     estimator.slip_detected.connect_to :type => :buffer,:size => 10000 do|data,name|
# 	plot.addSlipDetected( data ) 
# 	data
#     end
# 
#     estimator.debug_physical_filter.connect_to :type => :buffer,:size => 10000 do|data,name|
# 	plot.addPhysicalFilter( data ) 
# 	data
#     end    
#     
    
    log_replay.align( :use_sample_time )
   
    viz = Vizkit.control log_replay
    #viz.speed = 0.1
    Vizkit.exec
    
#     plot.show() 
end
