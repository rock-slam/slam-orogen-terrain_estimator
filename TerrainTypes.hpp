#ifndef __TERRAIN_TYPES__
#define __TERRAIN_TYPES__


#include <vector>
#include <base/eigen.h>
#include <base/time.h>


namespace terrain_estimator
{

    
    
    enum TerrainType{
	GRASS,
	PATH
    }; 
    
    /**
     * outputs a detected slip 
     * @param time - the time the slip was detected (not the time it happened) 
     * @param wheel_idx - the wheel index where the slip was detected
     * @param max_traction - the peak value within a wheel step, where a slip was detected
     * @param min_traction - the minimal value within a wheel step, where a slip was detected  
     */
    struct SlipDetected{
	base::Time time; 
	int wheel_idx; 
	double max_traction; 
	double min_traction; 
    }; 
    
    /**
    * @param time - the time the slip was detected (not the time it happened) 
     * @param wheel_idx - the wheel index where the terrain was classified
     * @param terrain - the terrain type 
     * @param histogram - the histogram used for the classification
     */
    struct TerrainClassificationHistogram{
	base::Time time; 
	int wheel_idx; 
	TerrainType terrain; 
	std::vector<double> histogram;
    }; 
    

    /** This are Debug Only Structures*/ 
    struct Wheelslip{
	bool slip; 
	double traction_force; 
	double normal_force; 
	double total_slip; 
	double numb_slip_votes; 
	double encoder; 
    };
    
    struct DebugSlipDetection{ 
	bool global_slip; 
	base::Time time; 
	TerrainType terrain_type; 
	Wheelslip slip[4]; 
    }; 

    
}
#endif
