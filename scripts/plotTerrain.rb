#!/usr/bin/env ruby
#


require 'orocos/log'
require 'vizkit'
require 'orocos'
require 'plotData.rb' 


def getLegAngel( external_encoder_value ) 

  legPos = external_encoder_value - ((external_encoder_value / (2 * Math::PI / 5)).round * (2 * Math::PI / 5))
    
    if(legPos < 0) 
	legPos = 2.0 * Math::PI / 5.0 + legPos
    end
      
    legPos = legPos * 180.0 / Math::PI
    legPos
end

log_replay = Orocos::Log::Replay.open( ARGV[0] ) 



plot = Array.new

plot_comb = DataPlot.new()
plot_comb.register2D( :path, {:title => "Path", :lt =>"p pointsize 1 pt 2"} )
plot_comb.register2D( :grass, {:title => "Grass", :lt =>"p pointsize 1 pt 1"} )
plot_comb.register2D( :path_slip, {:title => "Path Slip", :lt =>"p pointsize 1 pt 3"} )
plot_comb.register2D( :grass_slip, {:title => "Grass Slip", :lt =>"p pointsize 1 pt 4"} )
plot_rl = DataPlot.new()
plot_rl.register2D( :grass, {:title => "Rear Left Grass", :lt =>"p pointsize 1 pt 1"} )
plot_rl.register2D( :path, {:title => "Rear Left Path", :lt =>"p pointsize 1 pt 2"} )



plot << plot_rl 

plot_rr = DataPlot.new()
plot_rr.register2D( :grass, {:title => "Rear Right Grass", :lt =>"p pointsize 1 pt 1"} )
plot_rr.register2D( :path, {:title => "Rear Right Path", :lt =>"p pointsize 1 pt 2"} )



plot << plot_rr

plot_fr = DataPlot.new()
plot_fr.register2D( :grass, {:title => "Front Right Grass", :lt =>"p pointsize 1 pt 1"} )
plot_fr.register2D( :path, {:title => "Front Right Path", :lt =>"p pointsize 1 pt 2"} )



plot << plot_fr

plot_fl = DataPlot.new()

plot_fl.register2D( :grass, {:title => "Front Left Grass", :lt =>"p pointsize 1 pt 1"} )
plot_fl.register2D( :path, {:title => "Front Left Path", :lt =>"p pointsize 1 pt 2"} )

plot << plot_fl

log_replay.terrain_estimator.slip_detection.connect_to :type => :buffer,:size => 10000 do|data,name|
    for i in 0..3

	if( data.terrain_type == :PATH )
	    plot[i].addData(  :path, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if data
# 	    plot_comb.addData(  :path_slip, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if data.slip[i].slip
# 	    plot_comb.addData(  :path, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if !data.slip[i].slip
	else
	    plot[i].addData(  :grass, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if data
# 	    plot_comb.addData(  :grass_slip, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if data.slip[i].slip
# 	    plot_comb.addData(  :grass, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if !data.slip[i].slip
	end
    end
    data
end

	
# log_replay.terrain_estimator.physical_filter.connect_to :type => :buffer,:size => 10000 do|data,name|
# 
# 
# 	if( data.terrain == :PATH )
# 	    plot[data.wheel_idx].addData(  :path, [getLegAngel(data.encoder), data.traction]) if data
# # 	    plot_comb.addData(  :path_slip, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if data.slip[i].slip
# # 	    plot_comb.addData(  :path, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if !data.slip[i].slip
# 	else
# 	    plot[data.wheel_idx].addData(  :grass, [getLegAngel(data.encoder), data.traction]) if data
# # 	    plot_comb.addData(  :grass_slip, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if data.slip[i].slip
# # 	    plot_comb.addData(  :grass, [getLegAngel(data.slip[i].encoder), data.slip[i].traction_force]) if !data.slip[i].slip
# 	end
# 
#     data
# end


viz = Vizkit.control log_replay
#viz.speed = 0.1
Vizkit.exec

# plot_comb.save("oi_comb") 
for i in 0 .. 3 
    plot[i].save("oi"+i.to_s) 
    plot[i].show
end