#ifndef __TERRAIN_TYPES__
#define __TERRAIN_TYPES__


#include <vector>
#include <base/eigen.h>
#include <base/time.h>
#include "terrain_estimator/TerrainConfiguration.hpp"
namespace terrain_estimator
{

    /**
     * @param terrain_types - the list of terrains types in the classification
     * @param min_number_of_votes - minimal number of votes needed for a terrain to be detected (each svm function counts as one vote) -
     * @param svm_classifier - a vector os svm configurations for classifying terrain types 
     */ 
    struct SVMClassifiers{
	std::vector< TerrainType > terrain_types; 
	int min_number_votes; 
	std::vector< SVMConfiguration > svm_classifier[4]; 
    }; 
    
    /**
     * The configuration for the histogram for terrain configuration
     * @param number_of_histogram - the number of histograms needed for a terrain classification
     * @param number_bins - the number of bins in the histogram
     * @param histogram_max_torque - the histogram upper limit
     * @param histogram_min_torque - the histogram lower limit
    */
    struct HistogramConfiguration{
	int number_of_histogram_combine; 
	int number_bins; 
	double histogram_max_torque;
	double histogram_min_torque; 
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
	double svm; 
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
	TerrainType terrain; 
	Wheelslip slip[4]; 
    }; 

    struct PhysicalFilter{
	std::vector<double> tractions;
	int wheel_idx; 
    }; 
    
}
#endif
