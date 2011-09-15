#!/usr/bin/env ruby
#


require 'orocos/log'
require 'vizkit'
require 'orocos'
require 'plotData.rb' 
include Orocos

def register2DPlot ( plot, title, x_axis, y_axis ) 
  
    plot.register2D( :w0, {:title => "Rear Left", :lt =>"p pointsize 1 pt 2"} )
    plot.register2D( :w1, {:title => "Rear Right", :lt =>"p pointsize 1 pt 1"} )
    plot.register2D( :w2, {:title => "Front Right", :lt =>"p pointsize 1 pt 3"} )
    plot.register2D( :w3, {:title => "Front Left", :lt =>"p pointsize 1 pt 4"} )
#       plot.register2D( :w0, {:title => "Rear Left", :lt =>"l  lt 2"} )
#     plot.register2D( :w1, {:title => "Rear Right", :lt =>"l  lt 1"} )
#     plot.register2D( :w2, {:title => "Front Right", :lt =>"l  lt 3"} )
#     plot.register2D( :w3, {:title => "Front Left", :lt =>"l  lt 4"} )
    plot.setTitle(title, "Helvetica,14")
    plot.setXLabel(x_axis, "Helvetica,14")
    plot.setYLabel(y_axis, "Helvetica,14")
    
end 

def register1DPlot ( plot, title, x_axis, y_axis ) 
  
#     plot.register2D( :w0, {:title => "Rear Left", :lt =>"p pointsize 0.1 pt 2"} )
#     plot.register2D( :w1, {:title => "Rear Right", :lt =>"p pointsize 0.1 pt 1"} )
#     plot.register2D( :w2, {:title => "Front Right", :lt =>"p pointsize 0.1 pt 3"} )
#     plot.register2D( :w3, {:title => "Front Left", :lt =>"p pointsize 0.1 pt 4"} )
      plot.register1D( :w0, {:title => "Rear Left", :lt =>"l  lt 2"} )
    plot.register1D( :w1, {:title => "Rear Right", :lt =>"l  lt 1"} )
    plot.register1D( :w2, {:title => "Front Right", :lt =>"l  lt 3"} )
    plot.register1D( :w3, {:title => "Front Left", :lt =>"l  lt 4"} )
    plot.setTitle(title, "Helvetica,14")
    plot.setXLabel(x_axis, "Helvetica,14")
    plot.setYLabel(y_axis, "Helvetica,14")
    
end 
def xTicsToLegPos( plot, num_tics ) 
    tics = "xtics ("
    for i in 0..num_tics 
	tics = tics + "'d' " + (i*72).to_s 
	tics = tics +",'v'" +(i*72 + 36).to_s
	if i < num_tics 
	  tics = tics + ","
	end
    end
    tics = tics + ")"
    plot.generalPurposeSet("xtics '36'")
    plot.generalPurposeSet(tics)
end 

@moving_avarege = Array.new 
def moving_avg( number, size ) 
    
    @moving_avarege << number 
    
    if(@moving_avarege.size > size) 
	@moving_avarege.delete_at(0)
    end
    if(@moving_avarege.size < size)  
	0 
    else
	
	avg = 0 
	for i in 0..size-1
	    avg = avg + @moving_avarege.at(i)
	end 
	avg = avg / size 
	avg
    end
end


def getLegPos( external_encoder_value ) 
  num_cicles = (external_encoder_value / (2 * Math::PI / 5)).floor

  legPos = external_encoder_value - ((external_encoder_value / (2 * Math::PI / 5)).round * (2 * Math::PI / 5))
    
    if(legPos < 0) 
	legPos = 2 * Math::PI / 5 + legPos
    end
   
    legPos = legPos + num_cicles*(2 * Math::PI / 5)  
    legPos
end
        
def getLegAnge( external_encoder_value ) 

  legPos = external_encoder_value - ((external_encoder_value / (2 * Math::PI / 5)).round * (2 * Math::PI / 5))
    
    if(legPos < 0) 
	legPos = 2 * Math::PI / 5 + legPos
    end
      
    legPos
end
BASE_DIR = File.expand_path('..', File.dirname(__FILE__))
ENV['PKG_CONFIG_PATH'] = "#{BASE_DIR}/build:#{ENV['PKG_CONFIG_PATH']}"
Orocos.initialize



Orocos::Process.spawn('test_terrain_estimator') do |p|
  
    # log all the output ports
    Orocos.log_all_ports 

    # get the invidual tasks
    estimator = p.task 'terrain_estimator'

    logs = Array.new
    #logs <<  ARGV[0] + "external_camera.0.log"
    logs << ARGV[0]+"lowlevel.0.log"
    logs << ARGV[0]+"test_torque.0.log"
    logs << ARGV[0]+"xsens_imu.0.log"
    # connect the tasks to the logs
    log_replay = Orocos::Log::Replay.open( logs ) 

    log_replay.hbridge.status_motors.connect_to( estimator.motor_status, :type => :data )
    log_replay.torque.ground_forces_estimated.connect_to( estimator.ground_forces_estimated, :type => :data )
    log_replay.hbridge.status_motors.connect_to( estimator.status, :type => :data )
    log_replay.xsens_imu.orientation_samples.connect_to( estimator.orientation_samples, :type => :data )
    
   # widget = Vizkit.display log_replay.external_camera.frame
    estimator.time_window = 0.1
    estimator.slip_threashold = 0.008
    
    estimator.configure
    estimator.start
    
    sample = 0
    plot_traction = DataPlot.new()
    register2DPlot(plot_traction, ARGV[0], "angular position (degree)", "Traction Force (N)") 
    #xTicsToLegPos(plot_traction, 25) 

    plot_current = DataPlot.new()
    register2DPlot(plot_current, ARGV[0], "angular position (degree)", "current (A)") 
   # xTicsToLegPos(plot_current, 25) 

    
    plot_terrain = DataPlot.new()
    register2DPlot(plot_terrain, ARGV[0],"Normal Force (N)", "Traction Force (N)") 

    plot_normal = DataPlot.new()
    register2DPlot(plot_normal, ARGV[0], "angular position (degree)", "Normal Force (N)") 
    #xTicsToLegPos(plot_normal, 25) 

    plot_translation = DataPlot.new()
    register2DPlot(plot_translation, ARGV[0], "sample", "Translation (m)")     

    plot_tot_slip = DataPlot.new()
    register2DPlot(plot_tot_slip, ARGV[0], "sample", "hypostesis total slip (m) ")     
    
    plot_tot_translation = DataPlot.new()
    register1DPlot(plot_tot_translation, ARGV[0], "sample", "Total Translation (m)")   
    
    plot_tot_translation_corrected = DataPlot.new()
    register1DPlot(plot_tot_translation_corrected, ARGV[0], "sample", "Total Translation Corrected(m)")    
    
    tot_translation = Array.new 
    tot_translation_corrected = Array.new 

    for i in 0..3 
	tot_translation[i] = 0
	tot_translation_corrected[i] = 0
    end
    
    plot_delta_theta = DataPlot.new()
    plot_delta_theta.register1D( :model, {:title => "Delta Theta Model", :lt =>"l  lt 2"} )
    plot_delta_theta.register1D( :measured, {:title => "Delta Theta Measured", :lt =>"l  lt 1"} )

    prev_leg_pos = 0 
    v =  0 
    has_prev_leg = false 
    prev_time = 0
    plot_vel = DataPlot.new()
    plot_vel.register1D( :fl, {:title => "Angular Velocity", :lt =>"l lt 2 linesize 0.1"} )

    plot_odometry = DataPlot.new()
    plot_odometry.register2D( :od, {:title => "Odometry", :lt =>"l  lt 2"} )
    plot_odometry.register2D( :corrected, {:title => "Corrected Odometry", :lt =>"l  lt 1"} )
    
    plot_key = Array.new
    plot_key << :w0
    plot_key << :w1
    plot_key << :w2
    plot_key << :w3
    
    estimator.slip_output.connect_to :type => :buffer,:size => 10000 do|data,name|
	
      if ( has_prev_leg )
	    dt_pos = data.wheel_property[2].encoder - prev_leg_pos
	    dt_time = (data.time - prev_time).to_f
	    prev_leg_pos = data.wheel_property[2].encoder
	    prev_time = data.time
	    v = dt_pos/ 0.001
	    
	    plot_vel.addData( :fl,  [getLegPos(data.wheel_property[2].encoder)*180/Math::PI,moving_avg(v, 100)] ) 
	    
      else
	  prev_leg_pos = data.wheel_property[2].encoder
	  has_prev_leg = true
	  prev_time = data.time 
      end
# 	  
	#pp data
#       pp data.wheel_property[0].traction_force

        for i in 0..3
	    #plot_traction.addData(  plot_key[i], [getLegPos(data.wheel_property[i].encoder)*180/Math::PI, data.wheel_property[i].traction_force]) if data
	    #plot_normal.addData(   plot_key[i], [getLegPos(data.wheel_property[i].encoder)*180/Math::PI, data.wheel_property[i].normal_force]) if data
	    plot_traction.addData(  plot_key[i], [sample, data.wheel_property[i].traction_force]) if data
	    plot_normal.addData(   plot_key[i], [sample, data.wheel_property[i].normal_force]) if data
	    plot_current.addData(   plot_key[i], [getLegPos(data.wheel_property[i].encoder)*180/Math::PI, data.wheel_property[i].current]) if data
	    plot_translation.addData(  plot_key[i],  [ sample, data.wheel_property[i].corrected_translation]) if data
	    plot_tot_slip.addData(  plot_key[i],  [ sample, data.wheel_property[i].total_slip]) if data
	    tot_translation[i] = tot_translation[i] + data.wheel_property[i].translation
	    tot_translation_corrected[i] = tot_translation_corrected[i] + data.wheel_property[i].corrected_translation
	    plot_tot_translation.addData(  plot_key[i], tot_translation[i]) if data
	    plot_tot_translation_corrected.addData(  plot_key[i], tot_translation_corrected[i]) if data
	    plot_terrain.addData(  plot_key[i], [data.wheel_property[i].normal_force, data.wheel_property[i].traction_force]) if data

	end

	plot_odometry.addData( :od, [data.odometry.data[0], data.odometry.data[1]])
	plot_odometry.addData( :corrected, [data.corrected_odometry.data[0], data.corrected_odometry.data[1]])
	
	plot_delta_theta.addData( :model, data.delta_theta_model*180/Math::PI) 
	plot_delta_theta.addData( :measured, data.delta_theta_measured*180/Math::PI) 
	
	sample= sample + 1 
	
	data
    end
    
    log_replay.align( :use_sample_time )
   
    viz = Vizkit.control log_replay
    viz.speed = 0.1
    Vizkit.exec
    
    
#     plot_odometry.show()
#     plot_translation.show()
#     plot_delta_theta.show()
#     plot_tot_slip.show()
#     plot_tot_translation.show()
#     plot_tot_translation_corrected.show()
# #     plot_vel.show()
#     plot_traction.show()
#      plot_normal.show()
#     plot_current.show()
     plot_terrain.show()
# #      plot_position.save("oi")
#      plot_traction3D.save("oi2")
    
end
