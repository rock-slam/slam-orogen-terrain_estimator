#!/usr/bin/env ruby
#

require 'orocos/log'
require 'vizkit'
require 'orocos'
 require 'plot.rb'
require 'svm_configuration'
include Orocos

def svm_null()
    
    svm_function_null = Array.new
    for i in 0..15#31
	svm_function_null << 0.0
    end

    svm_function_null
end

def string_to_svm(line) 
    svm_function_0 = Array.new
    for i in 0..15#31
	svm_function_0 << 0.0
    end
    
    place = 0 
    place = line.index("'",place+1)
    while place !=nil
	start_numb = place + 1 
	place = line.index("'",place+1) 
	end_numb = place -  1
	place = line.index("'",place+1) 
	start_feature = place + 1 
	place = line.index("'",place+1) 
	end_feature = place -  1
	place = line.index("'",place+1)
	number =  line[start_numb..end_numb].to_f
	feature = line[start_feature..end_feature]
	end_indx = end_feature
	start_indx = feature.index("_") + 1
	index = feature[start_indx..end_indx].to_i
	svm_function_0[index] = number
    end

    svm_function_0
    
end

def string_to_histogram(line) 
    histogram = Array.new 
    
    count  = 0 
    place = 0 
    while count < 16#32
	start_numb = place + 1 
	place = line.index(",",place+1) 
	end_numb = place -  1
	number =  line[start_numb..end_numb].to_f
	histogram << number
	count = count + 1
    end
    @classification = line[end_numb+2..line.size - 2]
    histogram
end 

def calculate_svm(histogram, svm_function) 
   svm = 0 
   for i in 0..15#31
       svm = svm + histogram[i] * svm_function[i]
   end
   svm
end

svm_string =
	
"[['-4.49391487049' 'feature_4']
 ['-4.12914985647' 'feature_5']
 ['-0.102034145555' 'feature_3']
 ['0.486386369817' 'feature_14']
 ['0.666560626121' 'feature_15']
 ['0.682968918589' 'feature_12']
 ['0.692575462633' 'feature_7']
 ['0.717169407323' 'feature_10']
 ['0.805823101387' 'feature_6']
 ['0.822940267175' 'feature_8']
 ['0.915021206717' 'feature_9']
 ['1.14095909723' 'feature_13']
 ['1.7946939717' 'feature_11']]" 



	
svm_function = 	string_to_svm(svm_string) 

plot = DataPlot.new()
plot.register1D( :target, {:title => "Target", :lt =>"l lt 2"} )
plot.register1D( :standard, {:title => "Standard", :lt =>"l lt 1"} )

@classification 


File.open(ARGV[0]).each { |line|
                          
    histogram = string_to_histogram(line) 
    svm = calculate_svm(histogram, svm_function) 
    if @classification == "Target" 
	plot.addData(:target,[svm]) 
    else
	plot.addData(:standard,[svm]) 
    end
}

plot.show





















 