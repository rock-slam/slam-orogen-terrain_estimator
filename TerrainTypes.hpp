#ifndef __TERRAIN_TYPES__
#define __TERRAIN_TYPES__


#include <vector>
#include <base/eigen.h>
#include <base/time.h>


namespace terrain_estimator
{

    
    
    struct SlipCorrectedOdometry{
	base::Time time; 
	double delta_theta_model;
	double delta_theta_measured;
	base::Vector2d odometry; 
	base::Vector2d corrected_odometry;
    };
    
    enum TerrainType{
	GRASS,
	PATH
    }; 
    
    struct Wheelslip{
	bool slip; 
	double traction_force; 
	double normal_force; 
	double total_slip; 
	double numb_slip_votes; 
	double encoder; 
    };
    
    struct SlipDetection{ 
	bool global_slip; 
	base::Time time; 
	TerrainType terrain_type; 
	Wheelslip slip[4]; 
    }; 
    
    struct TerrainClassificationHistogram{
	int wheel_idx; 
	TerrainType terrain; 
	std::vector<double> histogram;
    }; 
    
}
#endif
