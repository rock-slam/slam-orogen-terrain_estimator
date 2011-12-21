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
    for i in 0..31 #15
	svm_function_null << 0.0
    end

    svm_function_null
end

def string_to_svm(line) 
    svm_function_0 = Array.new
    for i in 0..31#15
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
    while count < 32 #16
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

def calculate_svm(histogram, svm_function, offset) 
   svm = offset
   for i in 0..31 #15
       svm = svm + histogram[i] * svm_function[i]
   end
   svm
end

svm_string=
	"[['-4.361032713' 'feature_17']
 ['-3.97505937534' 'feature_18']
 ['-2.96010541929' 'feature_19']
 ['-2.26099673659' 'feature_3']
 ['-1.74946667805' 'feature_20']
 ['-1.44864845452' 'feature_4']
 ['-1.34363937218' 'feature_8']
 ['-1.23446871394' 'feature_10']
 ['-1.08078726565' 'feature_6']
 ['-0.898210657649' 'feature_7']
 ['-0.870858034331' 'feature_26']
 ['-0.615664812313' 'feature_25']
 ['-0.540935676545' 'feature_28']
 ['-0.35465862602' 'feature_2']
 ['-0.232198145241' 'feature_31']
 ['-0.206867634655' 'feature_5']
 ['-0.0365309044061' 'feature_0']
 ['-0.0190467906935' 'feature_24']
 ['0.0902777723968' 'feature_29']
 ['0.573588972661' 'feature_15']
 ['0.960719298046' 'feature_9']
 ['1.13160747931' 'feature_12']
 ['1.49565893261' 'feature_11']
 ['2.1884234355' 'feature_27']
 ['2.27107068236' 'feature_14']
 ['2.43216249255' 'feature_13']
 ['2.86740920506' 'feature_23']
 ['4.41431764528' 'feature_21']
 ['5.76393793477' 'feature_22']]"


offset =4.02378276146

svm_function = 	string_to_svm(svm_string) 

plot = DataPlot.new()
plot.register1D( :target, {:title => "Target", :lt =>"l lt 2"} )
plot.register1D( :standard, {:title => "Standard", :lt =>"l lt 1"} )

@classification 


File.open(ARGV[0]).each { |line|
                          
    histogram = string_to_histogram(line) 
    svm = calculate_svm(histogram, svm_function, offset) 
    if @classification == "Target" 
	plot.addData(:target,[svm]) 
    else
	plot.addData(:standard,[svm]) 
    end
}

plot.show





















 