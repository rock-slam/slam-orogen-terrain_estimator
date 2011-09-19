#ifndef __TERRAIN_TYPES__
#define __TERRAIN_TYPES__


#include <vector>
#include <base/eigen.h>
#include <base/time.h>


namespace terrain_estimator
{
    struct WheelProperty{
	bool slip;  
	double traction_force; 
	double normal_force;
	double translation; 
	double current; 
	double encoder;
	double total_slip; 
	double corrected_translation; 
	double translation_uncertanty; 

    };
    
    
    struct SlipOutput{
	base::Time time; 
	bool slip[4];  
	double delta_theta_model;
	double delta_theta_measured;
	base::Vector2d odometry; 
	base::Vector2d corrected_odometry;
	std::vector<WheelProperty> wheel_property;  
    };
    
    
}
#endif
