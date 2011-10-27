/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#include <Eigen/Core>

using namespace terrain_estimator;
using namespace asguard; 
using namespace Eigen; 

Task::Task(std::string const& name)
    : TaskBase(name), slip_model(0), asg_odo(0), histogram(0)  
{
    
}

Task::Task(std::string const& name, RTT::ExecutionEngine* engine)
    : TaskBase(name, engine)
{
}

Task::~Task()
{
    delete slip_model; 
    delete asg_odo; 
    delete histogram; 
}

//The slip detection detects the slip after the physical event actually happened. 
//In theory the slip happened in the maximal shred force, considering normal force constant, so maximal traction force. 
//To estimate this maximal force that caused the slip, the maximal value of the current step and previous step are considered
//Compensating so for the delay in the detection 
bool Task::slipDetection(base::Time ts, double heading_change)
{
    asg_odo->setInitialEncoder(prev_encoder); 
    Vector4d translation = asg_odo->translationAxes(encoder); 
    bool global_slip = slip_model->slipDetection(translation, heading_change , _slip_threashold.value());
    
    if(global_slip)
    {
	for(int i = 0; i < 4; i++) 
	{
	    if(slip_model->hasWheelConsecutivelySliped(i))
	    {
		SlipDetected slip;
		slip.time = ts; 
		slip.wheel_idx = i; 
		slip.max_traction = steps.at(i).getMaximalTractionEitherStep();
		slip.min_traction = steps.at(i).getMinimalTractionEitherStep();
		_slip_detected.write(slip); 
		 
	    }
	}   
    }
    
    /** Slip Detection Debug Output */ 
    if( traction_count > 0) 
    {
	DebugSlipDetection debug_slip; 
	debug_slip.time = ts; 
	debug_slip.global_slip = global_slip; 
	debug_slip.terrain_type = _terrain_type.value(); 
	for( int i = 0; i < 4; i ++){
	    if(slip_model->hasWheelConsecutivelySliped(i))
		debug_slip.slip[i].slip = true; 
	    else 
		debug_slip.slip[i].slip = false; 
	    debug_slip.slip[i].traction_force = traction_force_avg[i] / traction_count;
	    debug_slip.slip[i].normal_force = normal_force_avg[i] / traction_count; 
	    debug_slip.slip[i].total_slip =  slip_model->total_slip[i]; 
	    debug_slip.slip[i].numb_slip_votes = slip_model->slip_votes[i]; 
	    debug_slip.slip[i].encoder = encoder[i]; 
	}
	_debug_slip_detection.write(debug_slip); 
    }
    
    for( int i = 0; i < 4; i++) 
    {
	traction_force_avg[i] = 0; 
	normal_force_avg[i] = 0; 
    }
    traction_count = 0;
    
    return global_slip; 
}

void Task::terrainRecognition(base::Time ts)
{
 
    for( uint wheel_idx = 0; wheel_idx < 4; wheel_idx ++) 
    {
	if( slip_model->hasWheelConsecutivelySliped(wheel_idx))
	    has_wheel_slipped[wheel_idx] = true; 
	
	if( current_step_id[wheel_idx] != steps.at(wheel_idx).getCompletedStepId() ) 
	{
	    current_step_id[wheel_idx] = steps.at(wheel_idx).getCompletedStepId(); 
	    
	    if(has_wheel_slipped[wheel_idx]) 
	    {
		Step step= steps.at(wheel_idx).getCompletedStep(); 
		
		//only consider steps that don't go into positive traction ( positive traction = wheel rotating backwars) 
		//for the time being terrain recognition is only uni directional 
		if( step.max_traction < 5)
		{
		    //Debug Lines 
		    PhysicalFilter physical_filter; 
		    physical_filter.tractions = step.traction; 
		    physical_filter.wheel_idx = wheel_idx; 
		    _debug_physical_filter.write(physical_filter);
		    
		    //creates a histogram 
		    for(uint i = 0; i < step.traction.size(); i++) 
			histogram->addValue(step.traction.at(i));
		    
		    std::vector<double> normalized_histogram = histogram->getHistogram(); 
		    
		    histogram->clearHistogram();
		    
		    //adds the histogram for the terrain classification 
		    bool has_terrain_classification = terrain_classifiers.at(wheel_idx).addHistogram(normalized_histogram); 
		    
		    if( has_terrain_classification ) 
		    {
			TerrainClassificationHistogram histogram_out; 
			histogram_out.time = ts;
			histogram_out.wheel_idx = wheel_idx; 
			histogram_out.terrain = _terrain_type.value(); 
			histogram_out.histogram = terrain_classifiers.at(wheel_idx).getCombinedHistogram(); 
			_histogram_terrain_classification.write(histogram_out); 
			
		    }
		}
	    }
	    has_wheel_slipped[wheel_idx] = false; 
	}
    }
    
}
void Task::ground_forces_estimatedCallback(const base::Time &ts, const ::torque_estimator::GroundForces &ground_forces_estimated_sample)
{
  
    has_traction_force = true; 
    traction_count++;
    
    for( uint i = 0; i < 4; i++){
	traction_force_avg[i] = traction_force_avg[i] + ground_forces_estimated_sample.tractionForce.at(i); 
	normal_force_avg[i] = normal_force_avg[i] + ground_forces_estimated_sample.normalForce.at(i);
 	steps.at(i).addTraction( ground_forces_estimated_sample.tractionForce.at(i), encoder[i]);
    }
    
}
void Task::orientation_samplesCallback(const base::Time &ts, const ::base::samples::RigidBodyState &orientation_samples_sample)
{

    if(!has_traction_force) 
	return; 
    
    double heading = Matrix3d( orientation_samples_sample.orientation ).eulerAngles(2,1,0)[0] ; 
    
    if(!has_orientation)
    {
	has_orientation = true; 
	prev_heading =  heading;
	prev_encoder = encoder; 
	return; 
    }
    
    /** Slip detection */ 
    slipDetection(ts, heading - prev_heading); 

    prev_heading =  heading;
    prev_encoder = encoder; 
    

    /** Terrain Classification  */ 
    terrainRecognition(ts);
    

  
}

void Task::motor_statusCallback(const base::Time &ts, const ::base::actuators::Status &motor_status_sample)
{
    
    for( int i = 0; i < 4; i ++) 
	encoder[i] = motor_status_sample.states[i].positionExtern; 

}

/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See Task.hpp for more detailed
// documentation about them.

bool Task::configureHook()
{
    if (! TaskBase::configureHook())
        return false;
    
    has_orientation = false; 
    has_traction_force = false; 
    traction_count = 0;
    
    for( int i = 0; i < 4; i++) 
    {
	traction_force_avg[i] = 0; 
	normal_force_avg[i] = 0; 
	current_step_id[i] = 0; 
	has_wheel_slipped[i] = false; 

    }
    
    delete slip_model; 
    delete asg_odo; 
    delete histogram; 
    terrain_classifiers.clear(); 
    steps.clear(); 
    
    slip_model = new SlipDetectionModelBased( asguard_conf.trackWidth, asguard::FRONT_LEFT, asguard::FRONT_RIGHT, asguard::REAR_LEFT, asguard::REAR_RIGHT);
    asg_odo = new AsguardOdometry(asguard_conf.angleBetweenLegs, asguard_conf.wheelRadiusAvg); 
    histogram = new Histogram(_numb_bins.value(), _histogram_min_torque.value(), _histogram_max_torque.value()); 
    
    std::vector<double> svm_function; 
    for( int i = 0; i < 4; i++) 
    {
	HistogramTerrainClassification classifier( _number_of_histogram.value(), svm_function); 
	terrain_classifiers.push_back(classifier); 
	
	TractionForceGroupedIntoStep stepStack(asguard_conf.angleBetweenLegs); 
	steps.push_back(stepStack);
	
    }
    
    return true;
}

bool Task::startHook()
{

    if (! TaskBase::startHook())
        return false;
    return true;
}

void Task::updateHook()
{
    TaskBase::updateHook();
    

}
// void Task::errorHook()
// {
//     TaskBase::errorHook();
// }
// void Task::stopHook()
// {
//     TaskBase::stopHook();
// }
void Task::cleanupHook()
{
    TaskBase::cleanupHook();
    
}

