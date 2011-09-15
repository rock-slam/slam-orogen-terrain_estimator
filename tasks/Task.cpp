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

void Task::statusCallback(const base::Time &ts, const ::base::actuators::Status &status_sample)
{
    for( int i = 0; i < 4; i++)
      current[i]= status_sample.states.at(i).current; 
}

void Task::ground_forces_estimatedCallback(const base::Time &ts, const ::torque_estimator::GroundForces &ground_forces_estimated_sample)
{
  
    has_traction_force = true; 
    traction_count++;
    
    for( int i = 0; i < 4; i++){
// 	traction_force_avg[i] = traction_force_avg[i] + ground_forces_estimated_sample.tractionForce.at(i); 
// 	normal_force_avg[i] = normal_force_avg[i] + ground_forces_estimated_sample.normalForce.at(i);
	traction_force_avg[i] =  ground_forces_estimated_sample.tractionForce.at(i); 
	normal_force_avg[i] =  ground_forces_estimated_sample.normalForce.at(i); 
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
    
    if ( uncalibrated_encoder ) 
    {
	uncalibrated_encoder = false; 
	for( int i = 0; i < 4; i++ )
	    init_external_encouder[i] = motor_status_sample.states[i].positionExtern; 
    } 
    
    Vector4d encoder; 
    for( int i = 0; i < 4; i ++) 
	encoder[i] = motor_status_sample.states[i].positionExtern - init_external_encouder[i]; 

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
	init_traction = traction_force_avg[0]; 
    
    }


    //only calculate the distance between 0.1 ms time windows 
    double dt = (motor_status_sample.time - init_time).toSeconds();
    if( dt >= _time_window.value() ) 
    {
	Vector4d translation = asg_odo->translationAxes(encoder); 
	bool slip = slip_model->slipDetection(translation, heading - initial_heading , _slip_threashold.value());
	  
	std::cout << slip << std::endl; 

 	SlipOutput slip_out; 
	slip_out.delta_theta_measured = slip_model->delta_theta_measured; 
	slip_out.delta_theta_model= slip_model->delta_theta_model; 
	WheelProperty wp; 
	for(int i = 0; i < 4; i++) 
	    slip_out.wheel_property.push_back(wp);
	slip_out.time = motor_status_sample.time; 
	
	for( int i = 0; i < 4; i ++){
	    slip_out.wheel_property[i].slip = false;  	
	    
	    slip_out.wheel_property[i].total_slip = slip_model->total_slip[i]; 
	    if(slip_model->hasThisWheelSingleSliped(i))
	    {
		slip_out.wheel_property[i].corrected_translation = translation[i] + slip_model->total_slip[i];
		slip_out.wheel_property[i].traction_force = traction_force_avg[i] / traction_count;
		slip_out.wheel_property[i].normal_force = normal_force_avg[i] / traction_count; 

	    }
	    else	
	    {
		slip_out.wheel_property[i].corrected_translation = translation[i]; 
		slip_out.wheel_property[i].traction_force = 0;
		slip_out.wheel_property[i].normal_force = 0; 

	    }
	    slip_out.wheel_property[i].translation = translation[i]; 
// 	    slip_out.wheel_property[i].traction_force = traction_force_avg[i];
// 	    slip_out.wheel_property[i].normal_force = normal_force_avg[i]; 
	    slip_out.wheel_property[i].encoder = motor_status_sample.states[i].positionExtern - init_external_encouder[i];
	    slip_out.wheel_property[i].current = current[i]; 
	}	

	double avg_translation = 0; 
	double avg_corrected_translation = 0; 
	for(int i = 0; i < 4; i ++) 
	{
	    avg_translation = avg_translation + translation[i]; 
	    avg_corrected_translation = avg_corrected_translation + slip_out.wheel_property[i].corrected_translation; 
	}
	avg_translation = avg_translation / 4; 
	avg_corrected_translation = avg_corrected_translation / 4; 
	odometry[0] = odometry[0] + avg_translation*cos(heading-initial_heading); 
	corrected_odometry[0] = corrected_odometry[0] + avg_corrected_translation*cos(heading-initial_heading); 
	odometry[1] = odometry[1] + avg_corrected_translation*sin(heading-initial_heading); 
	corrected_odometry[1] = corrected_odometry[1] + avg_corrected_translation*sin(heading-initial_heading); 
	slip_out.odometry = odometry; 
	slip_out.corrected_odometry = corrected_odometry; 
	
 	_slip_output.write( slip_out ); 
//       if( dt > 0.01 ) 
	init = false;   
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
    uncalibrated_encoder = true;
    has_traction_force = false; 
    traction_count = 0;
    for( int i = 0; i < 4; i++) 
    {
      traction_force_avg[i] = 0; 
      normal_force_avg[i] = 0; 
      current[i] = 0; 
    }
    delete slip_model; 
    delete asg_odo; 
    //TODO CHECK THE TRACK WIDTH 
    slip_model = new SlipDetectionModelBased( asguard_conf.trackWidth, asguard::FRONT_LEFT, asguard::FRONT_RIGHT, asguard::REAR_LEFT, asguard::REAR_RIGHT);
    asg_odo = new AsguardOdometry(asguard_conf.angleBetweenLegs, asguard_conf.wheelRadiusAvg); 
    
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

