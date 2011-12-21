def svm_null()
    
    svm_function_null = Array.new
    for i in 0..31 #15
	svm_function_null << 0.0
    end

    svm_function_null
end

def string_to_svm(line) 
    svm_function_0 = Array.new
    for i in 0..31 #15
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

def svm_path_vs_grass(svm_conf, wheel_idx)
    
    string = Array.new 
    lower_threshold = Array.new
    upper_threshold = Array.new
    offset = Array.new 
    #Wheel 0
    offset <<   2.97851483598  
    upper_threshold << 0.5
    lower_threshold << -0.5 
    string << 
   	"[['-4.07262336861' 'feature_12']
 ['-3.12130931636' 'feature_17']
 ['-2.7740652616' 'feature_4']
 ['-1.85335671762' 'feature_15']
 ['-1.79830683106' 'feature_24']
 ['-1.7483705718' 'feature_2']
 ['-1.73168278099' 'feature_3']
 ['-1.47870483035' 'feature_6']
 ['-1.3659488264' 'feature_8']
 ['-1.17221192782' 'feature_7']
 ['-1.03843300487' 'feature_26']
 ['-0.957801486643' 'feature_25']
 ['-0.912126470636' 'feature_20']
 ['-0.867750402644' 'feature_5']
 ['-0.586006954002' 'feature_9']
 ['-0.350034660365' 'feature_18']
 ['-0.131578948349' 'feature_28']
 ['-0.114942528307' 'feature_29']
 ['-0.0826974117885' 'feature_31']
 ['-0.0423914370338' 'feature_30']
 ['0.375765607019' 'feature_19']
 ['1.03133939207' 'feature_23']
 ['1.2021386624' 'feature_11']
 ['1.23499653221' 'feature_21']
 ['1.33266133977' 'feature_10']
 ['1.60711505683' 'feature_0']
 ['1.71363480637' 'feature_13']
 ['1.7413682499' 'feature_22']
 ['4.16614972033' 'feature_27']
 ['4.57011166004' 'feature_1']
 ['7.22505772911' 'feature_14']]"


    #     #Wheel 1 
    offset <<  2.96986039047
    upper_threshold << 0.5
    lower_threshold << -0.5 
    string <<     
	"[['-2.69554605495' 'feature_8']
 ['-2.48893438038' 'feature_17']
 ['-2.46156368896' 'feature_5']
 ['-2.39009874149' 'feature_7']
 ['-2.07030499214' 'feature_6']
 ['-1.83633081854' 'feature_20']
 ['-1.70212469995' 'feature_24']
 ['-1.35178808123' 'feature_29']
 ['-1.32258540971' 'feature_9']
 ['-1.17708869449' 'feature_26']
 ['-1.17403784398' 'feature_11']
 ['-0.985050809737' 'feature_25']
 ['-0.804783497006' 'feature_28']
 ['-0.296895142966' 'feature_10']
 ['-0.263157896698' 'feature_30']
 ['-0.227208366145' 'feature_18']
 ['0.0572262364224' 'feature_19']
 ['0.244938778599' 'feature_22']
 ['0.519550911409' 'feature_15']
 ['0.585020818413' 'feature_4']
 ['1.24349902102' 'feature_13']
 ['1.61997363345' 'feature_14']
 ['1.63233377753' 'feature_23']
 ['1.65141790174' 'feature_2']
 ['2.27999850657' 'feature_12']
 ['2.61797706071' 'feature_21']
 ['4.51157120056' 'feature_3']
 ['6.28399641396' 'feature_27']]"

    
#     #Wheel 2 
    offset <<   1.30818517889 
    upper_threshold << 0.5
    lower_threshold << -0.5
     string << 
	"[['-3.82519445382' 'feature_2']
 ['-2.60571844745' 'feature_6']
 ['-2.46553822346' 'feature_17']
 ['-2.36317479415' 'feature_7']
 ['-1.90454210128' 'feature_4']
 ['-1.90406318477' 'feature_19']
 ['-1.84510692954' 'feature_1']
 ['-1.53364199253' 'feature_18']
 ['-1.50747810657' 'feature_5']
 ['-0.967674142745' 'feature_13']
 ['-0.965277813375' 'feature_28']
 ['-0.509047668476' 'feature_10']
 ['-0.471535582787' 'feature_3']
 ['-0.256410259753' 'feature_30']
 ['-0.221649110317' 'feature_24']
 ['-0.221167417071' 'feature_25']
 ['-0.0894309207797' 'feature_29']
 ['0.04735669195' 'feature_26']
 ['0.107212476432' 'feature_31']
 ['0.400986064889' 'feature_9']
 ['0.414772566572' 'feature_21']
 ['0.995718186732' 'feature_20']
 ['1.59936698436' 'feature_27']
 ['1.71628409061' 'feature_12']
 ['1.77203828821' 'feature_11']
 ['1.86656601473' 'feature_23']
 ['2.1340708749' 'feature_8']
 ['2.62618801585' 'feature_22']
 ['3.46810056313' 'feature_14']
 ['6.50799131001' 'feature_15']]"


    #Wheel 3 
    offset <<  4.02378276146
    upper_threshold << 0.5
    lower_threshold << -0.5 
    
    string << 
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


    svm_conf.offset = offset[wheel_idx]
    svm_conf.lower_threshold = lower_threshold[wheel_idx]
    svm_conf.lower_type = :GRASS
    svm_conf.upper_threshold =  upper_threshold[wheel_idx]
    svm_conf.upper_type = :PATH
    svm_conf.function =  string_to_svm(string[wheel_idx])
    svm_conf

end 

def svm_path_vs_pebles(svm_conf,  wheel_idx)
    
    string = Array.new 
    


    svm_conf.lower_threshold = lower_threshold[wheel_idx]
    svm_conf.lower_type = :PEBLES
    svm_conf.upper_threshold = upper_threshold[wheel_idx]
    svm_conf.upper_type = :PATH
    svm_conf.function = string_to_svm(string[wheel_idx])
    svm_conf
end 

def svm_grass_vs_pebles(svm_conf, wheel_idx)
    
    string_0 =
 	    " [['-6.60118925618' 'feature_1']
 ['-5.92190587242' 'feature_2']
 ['-3.52661665685' 'feature_3']
 ['-2.91859416269' 'feature_28']
 ['-2.90986093045' 'feature_23']
 ['-2.44907711624' 'feature_14']
 ['-2.39556909868' 'feature_22']
 ['-1.33291326113' 'feature_27']
 ['-1.22706870437' 'feature_20']
 ['-0.944745933942' 'feature_26']
 ['-0.738883710456' 'feature_8']
 ['-0.71184374392' 'feature_0']
 ['-0.405430775136' 'feature_15']
 ['-0.0774114672095' 'feature_29']
 ['0.232735500272' 'feature_19']
 ['0.237661670055' 'feature_9']
 ['0.366667772104' 'feature_21']
 ['0.680130067353' 'feature_4']
 ['0.768255714645' 'feature_13']
 ['0.842787794526' 'feature_12']
 ['1.51439372248' 'feature_25']
 ['1.80138765946' 'feature_17']
 ['1.82130287803' 'feature_5']
 ['2.63310431663' 'feature_7']
 ['3.44230440654' 'feature_10']
 ['3.75927380213' 'feature_24']
 ['4.1317068395' 'feature_18']
 ['4.32748063661' 'feature_6']
 ['5.60192048279' 'feature_11']]" 


#     if wheel_idx == 0 
	svm_function = string_to_svm(string_0)
#     else
# 	svm_function = svm_null
#     end
    
    svm_conf.lower_threshold = 2
    svm_conf.lower_type = :GRASS
    svm_conf.upper_threshold = 3
    svm_conf.upper_type = :PEBLES
    svm_conf.function = svm_function
    svm_conf
end 


