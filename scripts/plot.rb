#!/usr/bin/env ruby
#

require 'plotData.rb' 


def dt( data ) 
    if @init_time == 0.0 
	@init_time = data.time.to_f
    end
    dt = data.time.to_f - @init_time
    dt
end


def register2DPlot ( title, x_axis, y_axis,  points = false  ) 
    plot = DataPlot.new()
    if ( points ) 
	plot.register2D( :w0, {:title => "Rear Left", :lt =>"p pointsize 1 pt 2"} )
	plot.register2D( :w1, {:title => "Rear Right", :lt =>"p pointsize 1 pt 1"} )
	plot.register2D( :w2, {:title => "Front Right", :lt =>"p pointsize 1 pt 3"} )
	plot.register2D( :w3, {:title => "Front Left", :lt =>"p pointsize 1 pt 4"} )
    else
	plot.register2D( :w0, {:title => "Rear Left", :lt =>"l  lt 2"} )
	plot.register2D( :w1, {:title => "Rear Right", :lt =>"l  lt 1"} )
	plot.register2D( :w2, {:title => "Front Right", :lt =>"l  lt 3"} )
	plot.register2D( :w3, {:title => "Front Left", :lt =>"l  lt 4"} )
    end
    plot.setTitle(title, "Helvetica,14")
    plot.setXLabel(x_axis, "Helvetica,14")
    plot.setYLabel(y_axis, "Helvetica,14")
    plot
end 

def getWheel( i ) 
    wheel = "" 
    if i == 0  
	wheel = "Rear Left"
    elsif i == 1 
	wheel = "Rear Right"
    elsif i == 2 
	wheel = "Front Right"
    else i == 3 
	wheel = "Front Left"
    end
    wheel

end 
def register1DPlot ( title, x_axis, y_axis, points = false ) 
    plot = DataPlot.new()
    if( points ) 
	plot.register1D( :w0, {:title => "Rear Left", :lt =>"p pointsize 0.1 pt 2"} )
	plot.register1D( :w1, {:title => "Rear Right", :lt =>"p pointsize 0.1 pt 1"} )
	plot.register1D( :w2, {:title => "Front Right", :lt =>"p pointsize 0.1 pt 3"} )
	plot.register1D( :w3, {:title => "Front Left", :lt =>"p pointsize 0.1 pt 4"} )
    else
	plot.register1D( :w0, {:title => "Rear Left", :lt =>"l  lt 2"} )
	plot.register1D( :w1, {:title => "Rear Right", :lt =>"l  lt 1"} )
	plot.register1D( :w2, {:title => "Front Right", :lt =>"l  lt 3"} )
	plot.register1D( :w3, {:title => "Front Left", :lt =>"l  lt 4"} )
    end
    plot.setTitle(title, "Helvetica,14")
    plot.setXLabel(x_axis, "Helvetica,14")
    plot.setYLabel(y_axis, "Helvetica,14")
    plot
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
        
def getLegAngel( external_encoder_value ) 

  legPos = external_encoder_value - ((external_encoder_value / (2 * Math::PI / 5)).round * (2 * Math::PI / 5))
    
    if(legPos < 0) 
	legPos = 2 * Math::PI / 5 + legPos
    end
      
    legPos
end


def registerHistogram( plot, size, title )
    plot.setTitle(title, "Helvetica,14")
    for i in 0..size - 1 
	bin_id = "bin "+(i+1).to_s 
	title = bin_id 
	#plot.register1D( bin_id, {:title => title} )
	plot.register1D( bin_id, {:title => ""} )
	
    end
    
end
	
    
    
def configureHistogramPlot( plot, y_max_range ) 
    plot.setXRange([-0.5, 0.5])
    plot.setYRange([0, y_max_range])
    plot.generalPurposeSet( "xtics 0" )
    plot.generalPurposeSet( "bmargin 3" )
    plot.generalPurposeSet( "rmargin 3" )
    plot.generalPurposeSet( "boxwidth 0.9 absolute" )
    plot.generalPurposeSet( "style fill solid 1.00 border -1")
    plot.generalPurposeSet( "datafile missing '-'")
    plot.generalPurposeSet( "style data histograms")
	
end 
    
def addDataHistogramPlot(plot, data ) 
    for i in 0..data.size-1
	bin_id = "bin "+(i+1).to_s 
	if data[i] == 0 
	    plot.addData(  bin_id, 0.001)
	else
	    plot.addData(  bin_id, data[i])
	end
	
    end
end 

def registerTractionSlip(wheel_idx, title)
   	plot = DataPlot.new()
	plot.register2D( :traction, {:title => getWheel(wheel_idx)+" Traction", :lt =>"p pointsize 1 pt 2"} )
	plot.register2D( :slip, {:title => getWheel(wheel_idx)+ " Slipped", :lt =>"p pointsize 1 pt 1"} )
	plot.register2D( :peak, {:title => getWheel(wheel_idx)+" Peak", :lt =>"p pointsize 1 pt 3"} )
	plot.register2D( :Bottom, {:title => getWheel(wheel_idx)+" Bottom", :lt =>"p pointsize 1 pt 4"} )
	plot.setTitle(title, "Helvetica,14")
	plot.setXLabel("time (s)", "Helvetica,14")
	plot.setYLabel("Traction (N)", "Helvetica,14") 
	plot
end
class PlotTerrain 
    def initialize
	@init_time = 0.0 
	@sample = 0
	@sample_ang_vel = 0
	@sample_lin_vel = 0
	
	@plot_time_traction_slip = Array.new
	for i in 0 .. 3 
	    plot = registerTractionSlip(i,ARGV[0]) 
	    @plot_time_traction_slip << plot
	    
	end
	
	@plot_time_traction = register2DPlot(ARGV[0], "time (s) ", "Traction (N)") 
	
	@plot_time_Nvotes = register2DPlot(ARGV[0], "time (s) ", "Number Votes (N)") 

	@plot_time_totSlip= register2DPlot(ARGV[0], "time (s)", "hypostesis total slip (m) ")     
	
	@plot_legPos_traction = register2DPlot(ARGV[0], "leg position (rad) ", "Traction (N)") 

	@plot_physicalFilter =  register2DPlot(ARGV[0],"Step", "Traction (N)",true) 
	
	@plot_vel = DataPlot.new()	
	@plot_vel.register1D( :w0, {:title => "Linear Velocity", :lt =>"l  lt 1"} )
	@plot_vel.setXLabel("time (s)", "Helvetica,14")
	@plot_vel.setYLabel("Velocity m/s (s)", "Helvetica,14") 

	@plot_vel_filter = DataPlot.new()	
	@plot_vel_filter.register2D( :w0, {:title => "Linear Velocity", :lt =>"l  lt 1"} )
	@plot_vel_filter.setXLabel("sample (s)", "Helvetica,14")
	@plot_vel_filter.setYLabel("Velocity m/s (s)", "Helvetica,14") 
	
	@plot_ang_vel = DataPlot.new()	
	@plot_ang_vel.register1D( :w1, {:title => "Angular Velocity", :lt =>"l  lt 2"} )
	@plot_ang_vel.setXLabel("time (s)", "Helvetica,14")
	@plot_ang_vel.setYLabel("Velocity rad/s (s)", "Helvetica,14") 

	@plot_ang_vel_filter = DataPlot.new()	
	@plot_ang_vel_filter.register1D( :w0, {:title => "Angular Velocity", :lt =>"l  lt 2"} )
	@plot_ang_vel_filter.setXLabel("sample", "Helvetica,14")
	@plot_ang_vel_filter.setYLabel("Velocity rad/s (s)", "Helvetica,14") 
	
	@plot_key = Array.new
	@plot_key << :w0
	@plot_key << :w1
	@plot_key << :w2
	@plot_key << :w3
	
    end 
    
    def addLinearVelocity( data )
  	@plot_vel.addData(:w0, [data] )
    end 
    
    def addAngularVelocity( data ) 
 	@plot_ang_vel.addData(:w1, [data] )
    end 
    
    def addSlipCorrectedOdometry( data ) 
	
	
    end 
    
    def addPhysicalFilter( data ) 
	if data.wheel_idx == 0 
	    #@plot_physicalFilter.addData( @plot_key[data.wheel_idx], [getLegPos(data.encoder), data.traction] ) 
	    for i in 0 .. data.tractions.size - 1 
		@sample = @sample + 1 
		@plot_physicalFilter.addData( @plot_key[data.wheel_idx], [@sample, data.tractions[i]] ) 
	    end
	    @sample = @sample + 100 

# 	    for i in 0 .. data.angular_velocities.size - 1 
# 		@plot_ang_vel_filter.addData( :w0, [@sample_ang_vel, data.angular_velocities[i]] ) 
# 		@sample_ang_vel = @sample_ang_vel + 1
# 		@plot_lin_vel_filter.addData( :w0, [@sample_lin_vel, data.linear_velocities[i]] ) 
# 		@sample_lin_vel = @sample_lin_vel + 1
# 	    end
# 	    @sample_ang_vel = @sample_ang_vel + 100
# 	    @sample_lin_vel = @sample_lin_vel + 100
	end
    end 
    
    def addHistogramTerrainClassification( data ) 
	histogram_plot_wheel = DataPlot.new()
	registerHistogram(histogram_plot_wheel, data.histogram.size, data.wheel_idx.to_s) 
	configureHistogramPlot(histogram_plot_wheel,1)
	addDataHistogramPlot(histogram_plot_wheel, data.histogram)
	histogram_plot_wheel.show()
    end 
    
    def addDebugSlipDetection( data ) 
	
	for i in 0..0
	    @plot_time_traction.addData(  @plot_key[i], [dt(data), data.slip[i].traction_force]) if data
	    @plot_time_totSlip.addData( @plot_key[i], [dt(data), data.slip[i].total_slip]) if data
	    @plot_time_Nvotes.addData( @plot_key[i], [dt(data), data.slip[i].numb_slip_votes]) if data
	    @plot_legPos_traction.addData( @plot_key[i], [getLegAngel(data.slip[i].encoder) * 180.0 / Math::PI, data.slip[i].traction_force]) if data
	    @plot_time_traction_slip[i].addData( :traction, [dt(data),  data.slip[i].traction_force]) if !data.slip[i].slip                                          
	    @plot_time_traction_slip[i].addData( :slip, [dt(data),  data.slip[i].traction_force]) if data.slip[i].slip
	end


    end 
    
    def addSlipDetected( data )
        @plot_time_traction_slip[data.wheel_idx].addData( :peak, [dt(data),  data.max_traction]) 
	@plot_time_traction_slip[data.wheel_idx].addData( :Bottom, [dt(data),  data.min_traction]) 
    end 
    
    def show() 

#	@plot_time_traction.show
# 	@plot_time_Nvotes.show
# 	@plot_normal_traction.show
#  	@plot_time_totSlip.show
	pp @plot_vel          
 	@plot_vel.show 
	@plot_ang_vel.show
	
	@plot_physicalFilter.show
# 	@plot_ang_vel_filter.show
# 	@plot_lin_vel_filter.show
	
	for i in 0..3
	    @plot_time_traction_slip[i].show
	end

    end 
end 