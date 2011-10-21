/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#include <Eigen/Core>

using namespace terrain_estimator;
using namespace asguard; 
using namespace Eigen; 

Task::Task(std::string const& name)
    : TaskBase(name), slip_model(0), asg_odo(0) 
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
}


void Task::ground_forces_estimatedCallback(const base::Time &ts, const ::torque_estimator::GroundForces &ground_forces_estimated_sample)
{
  
    has_traction_force = true; 
    traction_count++;
    
    for( int i = 0; i < 4; i++){
	traction_force_avg[i] = traction_force_avg[i] + ground_forces_estimated_sample.tractionForce.at(i); 
	normal_force_avg[i] = normal_force_avg[i] + ground_forces_estimated_sample.normalForce.at(i);
 
    }
    
    	
    /** Histogram Terrain Classification output */ 	
    for(int i = 0; i < 4; i++ ) 
    { 
	histogram.at(i).addTraction( ground_forces_estimated_sample.tractionForce.at(i));

	if( histogram.at(i).getNumberPoints() > _number_points_histogram.value() ) 
	{
	    TerrainClassificationHistogram histogram_out; 
	    histogram_out.wheel_idx = i; 
	    histogram_out.terrain = _terrain_type.value(); 
	    histogram_out.histogram = histogram.at(i).getHistogram(); 
	    histogram.at(i).clearHistogram();
	    _histogram_terrain_classification.write(histogram_out); 
	}
    }
    
}
void Task::orientation_samplesCallback(const base::Time &ts, const ::base::samples::RigidBodyState &orientation_samples_sample)
{
     heading = Matrix3d( orientation_samples_sample.orientation ).eulerAngles(2,1,0)[0] ; 
     
     if ( !has_orientation)
	has_orientation = true; 
  
}

void Task::motor_statusCallback(const base::Time &ts, const ::base::actuators::Status &motor_status_sample)
{
    
    if( !has_traction_force )
	return; 
    
    if( !has_orientation ) 
	return; 
    
    Vector4d encoder; 
    for( int i = 0; i < 4; i ++) 
	encoder[i] = motor_status_sample.states[i].positionExtern; 

    if( !init ) 
    {
	init = true; 
	init_time = motor_status_sample.time; 
	
	//TODO CHECK THE TRACK WIDTH 
	initial_heading =  heading;
	asg_odo->setInitialEncoder(encoder); 
	
	for( int i = 0; i < 4; i++) {
	    traction_force_avg[i] = 0; 
	    normal_force_avg[i] = 0; 
	}
	traction_count = 0;
    }
    


    double dt = (motor_status_sample.time - init_time).toSeconds();
    if( dt >= _time_window.value() ) 
    {
	init = false;   

	Vector4d translation = asg_odo->translationAxes(encoder); 
	bool global_slip = slip_model->slipDetection(translation, heading - initial_heading , _slip_threashold.value());
	
	/** for Physical filter */ 
	if( global_slip ) 
	{
	    for( int i = 0; i < 4; i ++)
	    {
		if(slip_model->hasThisWheelSingleSliped(i))
		    has_single_wheel_slipped[i] = true; 
	    }
	}
	
	for( int i = 0; i < 4; i ++) 
	{
	    double step = floor( motor_status_sample.states[i].positionExtern / (2.0 * M_PI / 5.0));
	    if( current_step[i] != step ) 
	    {
		current_step[i] = step; 
		if(has_single_wheel_slipped[i]) 
		{
		    //calculate histogram 
		    //output to port 
		}
		traction[i].clear(); 
		has_single_wheel_slipped[i] = false; 
	    }
	    traction[i].push_back( traction_force_avg[i] / traction_count);
	}
	
	
	/** Slip Detection Output */ 
	if( traction_count > 0) 
	{
	    SlipDetection slip; 
	    slip.time = motor_status_sample.time; 
	    slip.global_slip = global_slip; 
	    slip.terrain_type = _terrain_type.value(); 
	    for( int i = 0; i < 4; i ++){
		if(slip_model->hasThisWheelSingleSliped(i))
		    slip.slip[i].slip = true; 
		else 
		    slip.slip[i].slip = false; 
		slip.slip[i].traction_force = traction_force_avg[i] / traction_count;
		slip.slip[i].normal_force = normal_force_avg[i] / traction_count; 
		slip.slip[i].total_slip =  slip_model->total_slip[i]; 
		slip.slip[i].numb_slip_votes = slip_model->slip_votes[i]; 
		slip.slip[i].encoder = encoder[i]; 
	    }
	    _slip_detection.write(slip); 
	}
	
	/** Slip Corrected Odometry Output */ 
 	SlipCorrectedOdometry sc_odo; 
	sc_odo.delta_theta_measured = slip_model->delta_theta_measured; 
	sc_odo.delta_theta_model= slip_model->delta_theta_model; 
	sc_odo.time = motor_status_sample.time; 
	Vector4d corrected_translation = Vector4d::Zero();
	
	for( int i = 0; i < 4; i ++){
	    if(slip_model->hasThisWheelSingleSliped(i))
	    {
		corrected_translation[i] = translation[i] + slip_model->total_slip[i];
	    }
	    else	
	    {
		corrected_translation[i] = translation[i];
	    }
	}	

	double avg_translation = 0; 
	double avg_corrected_translation = 0; 

	for(int i = 0; i < 4; i ++) 
	{
	    avg_translation = avg_translation + translation[i]; 
	    avg_corrected_translation = avg_corrected_translation + corrected_translation[i]; 
	}
	avg_translation = avg_translation / 4; 
	avg_corrected_translation = avg_corrected_translation / 4; 
	odometry[0] = odometry[0] + avg_translation*cos(heading-initial_heading); 
	corrected_odometry[0] = corrected_odometry[0] + avg_corrected_translation*cos(heading-initial_heading); 
	odometry[1] = odometry[1] + avg_corrected_translation*sin(heading-initial_heading); 
	corrected_odometry[1] = corrected_odometry[1] + avg_corrected_translation*sin(heading-initial_heading); 
	sc_odo.odometry = odometry; 
	sc_odo.corrected_odometry = corrected_odometry; 
	
 	_slip_corrected_odometry.write( sc_odo ); 

    }

}

/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See Task.hpp for more detailed
// documentation about them.

bool Task::configureHook()
{
    if (! TaskBase::configureHook())
        return false;
    
    init = false; 
    has_traction_force = false; 
    traction_count = 0;
    for( int i = 0; i < 4; i++) 
    {
      traction_force_avg[i] = 0; 
      normal_force_avg[i] = 0; 
    }
    delete slip_model; 
    delete asg_odo; 
    
    //TODO CHECK THE TRACK WIDTH 
    slip_model = new SlipDetectionModelBased( asguard_conf.trackWidth, asguard::FRONT_LEFT, asguard::FRONT_RIGHT, asguard::REAR_LEFT, asguard::REAR_RIGHT);
    asg_odo = new AsguardOdometry(asguard_conf.angleBetweenLegs, asguard_conf.wheelRadiusAvg); 
    
    for(int i = 0; i < 4; i++) 
    {
	HistogramTerrainClassification histogram_wheel(_numb_bins.value(), _histogram_max_torque.value()); 
	histogram.push_back(histogram_wheel);
	
	current_step[i] = -1; 
	has_single_wheel_slipped[i] = false; 
    }
    
    return true;
}

bool Task::startHook()
{
    corrected_odometry.setZero(); 
    odometry.setZero();
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

