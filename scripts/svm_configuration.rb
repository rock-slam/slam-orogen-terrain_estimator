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

def svm_path_vs_grass(svm_conf, wheel_idx)
    
    string = Array.new 
    lower_threshold = Array.new
    upper_threshold = Array.new
    offset = Array.new 
    #Wheel 0
    offset << 0 
    upper_threshold << 0.5 #0.5
    lower_threshold << -1#-0.5 
    string << 
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


#     "[['-9.74229648754' 'feature_2']
#     ['-4.9275994771' 'feature_3']
#     ['-3.64682893506' 'feature_4']
#     ['-3.62903607934' 'feature_28']
#     ['-3.3726587038' 'feature_17']
#     ['-3.24758633826' 'feature_14']
#     ['-3.21187823493' 'feature_27']
#     ['-2.8321904197' 'feature_20']
#     ['-1.74972239047' 'feature_1']
#     ['-1.45855576262' 'feature_15']
#     ['-1.28490489799' 'feature_19']
#     ['0.166571042854' 'feature_21']
#     ['0.605899084012' 'feature_18']
#     ['0.928511839848' 'feature_26']
#     ['1.38526200412' 'feature_13']
#     ['1.50607120854' 'feature_6']
#     ['1.72605046013' 'feature_8']
#     ['2.09214982366' 'feature_25']
#     ['2.12996734574' 'feature_9']
#     ['2.51363693478' 'feature_23']
#     ['2.78613147744' 'feature_7']
#     ['3.06111599657' 'feature_11']
#     ['3.66939473276' 'feature_12']
#     ['3.79732608887' 'feature_5']
#     ['3.82025309876' 'feature_24']
#     ['4.20364369575' 'feature_22']
#     ['4.71126997024' 'feature_10']]"

	    
    #     #Wheel 1 
    offset << 0 
    upper_threshold << -2
    lower_threshold << -2.5 
    string << 
    string[0]
#     "[['-8.49068986358' 'feature_2']
# 	['-5.864882693' 'feature_15']
# 	['-5.78397064988' 'feature_28']
# 	['-4.74695563405' 'feature_17']
# 	['-3.76456915824' 'feature_1']
# 	['-3.48509687824' 'feature_4']
# 	['-2.86154318685' 'feature_19']
# 	['-2.32844274218' 'feature_6']
# 	['-2.24479872427' 'feature_3']
# 	['-2.08483121222' 'feature_18']
# 	['-1.74575973473' 'feature_27']
# 	['-0.873736103471' 'feature_20']
# 	['0.228573491707' 'feature_0']
# 	['0.345892930602' 'feature_5']
# 	['0.452102321027' 'feature_21']
# 	['0.69505284885' 'feature_11']
# 	['1.63524108116' 'feature_9']
# 	['1.67524783762' 'feature_26']
# 	['2.38060573356' 'feature_12']
# 	['2.38900553306' 'feature_8']
# 	['2.41885493681' 'feature_25']
# 	['2.55866936794' 'feature_23']
# 	['3.14152600339' 'feature_7']
# 	['3.29009382335' 'feature_13']
# 	['3.43562607522' 'feature_24']
# 	['4.84070906965' 'feature_10']
# 	['7.23177998581' 'feature_14']
# 	['7.55629339821' 'feature_22']]"
    
#     #Wheel 2 
    offset << 0 
    upper_threshold << -2
    lower_threshold << -3 
     string << 
     string[0]
# 	"[['-10.0516661476' 'feature_3']
# 	['-5.89673429137' 'feature_17']
# 	['-5.80962123867' 'feature_4']
# 	['-5.24059186946' 'feature_27']
# 	['-4.40421311409' 'feature_28']
# 	['-3.96691629909' 'feature_2']
# 	['-2.19427901327' 'feature_15']
# 	['-2.03619933648' 'feature_18']
# 	['-0.713565882546' 'feature_26']
# 	['-0.685690439394' 'feature_5']
# 	['-0.440553689006' 'feature_14']
# 	['-0.158889529994' 'feature_0']
# 	['0.0989538232387' 'feature_1']
# 	['0.145391784283' 'feature_19']
# 	['0.366850386004' 'feature_20']
# 	['0.461915345629' 'feature_6']
# 	['0.531425648681' 'feature_8']
# 	['1.48703174171' 'feature_11']
# 	['2.02856388409' 'feature_23']
# 	['2.47992427743' 'feature_21']
# 	['2.6019523289' 'feature_12']
# 	['2.90957220831' 'feature_7']
# 	['2.912203545' 'feature_22']
# 	['3.25957743954' 'feature_25']
# 	['4.34227645332' 'feature_9']
# 	['4.94053347831' 'feature_10']
# 	['5.93395720448' 'feature_13']
# 	['7.09879544153' 'feature_24']]"


    #Wheel 3 
    offset << 0 
    upper_threshold << -0.5
    lower_threshold << -2 
    
    string << 
    string[0]
# 	"[['-9.08186335154' 'feature_2']
# 	['-8.20550727781' 'feature_3']
# 	['-6.88247001053' 'feature_17']
# 	['-5.73852219592' 'feature_27']
# 	['-4.18382781731' 'feature_4']
# 	['-3.0169450916' 'feature_28']
# 	['-2.29661293803' 'feature_1']
# 	['-2.01699714262' 'feature_5']
# 	['-0.777482258554' 'feature_15']
# 	['-0.297139758131' 'feature_26']
# 	['-0.0523153017275' 'feature_31']
# 	['0.404029583784' 'feature_6']
# 	['0.634002162998' 'feature_19']
# 	['0.8603699118' 'feature_18']
# 	['1.11810263352' 'feature_23']
# 	['1.14334015815' 'feature_20']
# 	['1.47880275383' 'feature_14']
# 	['1.51787261066' 'feature_21']
# 	['1.60878010419' 'feature_22']
# 	['1.75595798587' 'feature_9']
# 	['2.77346345499' 'feature_7']
# 	['2.7938591284' 'feature_13']
# 	['3.11497382411' 'feature_12']
# 	['3.60527792775' 'feature_8']
# 	['4.01802524929' 'feature_25']
# 	['4.51584584638' 'feature_10']
# 	['5.08689822412' 'feature_24']
# 	['6.12007988938' 'feature_11']]"


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


