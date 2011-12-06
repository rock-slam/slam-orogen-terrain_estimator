#!/usr/bin/env ruby
#


require 'orocos/log'
require 'vizkit'
require 'orocos'

include Orocos


BASE_DIR = File.expand_path('..', File.dirname(__FILE__))
ENV['PKG_CONFIG_PATH'] = "#{BASE_DIR}/build:#{ENV['PKG_CONFIG_PATH']}"
Orocos.initialize




logs = Array.new

# connect the tasks to the logs
log_replay = Orocos::Log::Replay.open( ARGV[0] )

file = Array.new 
for i in 0 .. 3 
    file_single_wheel = File.new("Training_Set_"+ i.to_s+".csv", "a")
    file << file_single_wheel
end

logs = Array.new
for i in 0 .. 3 
    logs << Array.new
end

log_replay.terrain_estimator.histogram_terrain_classification.connect_to :type => :buffer,:size => 10000 do|data,name|
    output = ""

    for i in 0 .. data.histogram.size - 1 
	output = output + data.histogram[i].to_s + ","
    end
    if data.terrain == :PATH 
	output = output + "Target" 
    else
	output = output + "Standard " 
    end
    logs[data.wheel_idx] << output
    data
end

log_replay.align( :use_sample_time )

viz = Vizkit.control log_replay
Vizkit.exec

for i in 0..3
    size= logs[i].size 
    for j in 0..logs[i].size/2
	file[i].puts logs[i][j]
	file[i].puts logs[i][size -j -1]	
    end
end




