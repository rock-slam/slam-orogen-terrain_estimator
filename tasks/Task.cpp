/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#include <Eigen/Core>

using namespace terrain_estimator;
using namespace asguard; 
using namespace Eigen; 

Task::Task(std::string const& name)
    : TaskBase(name), slip_model(0), asg_odo(0), histogram_traction(0), histogram_linear_velocity(0), histogram_angular_velocity(0)      
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
    delete histogram_traction; 
    delete histogram_linear_velocity; 
    delete histogram_angular_velocity; 
}

//The slip detection detects the slip after the physical event actually happened. 
//In theory the slip happened in the maximal shred force, considering normal force constant, so in the moment of maximal traction force. 
//To estimate this maximal force that caused the slip, the maximal value of the current step and previous step are considered
//Thus trying to compensate for the delay in the detection 
bool Task::slipDetection(base::Time ts, double heading_change, Vector4d translation)
{
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
	    debug_slip.terrain = _terrain_type.value(); 
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
    /** Slip Detection Debug Output */ 
    
    return global_slip; 
}

void Task::terrainRecognition(base::Time ts)
{
    //TODO FIX INDEX HACK 
    for( uint wheel_idx = 0; wheel_idx < 1; wheel_idx ++) 
    {
	if( slip_model->hasWheelConsecutivelySliped(wheel_idx))
	    has_wheel_slipped[wheel_idx] = true; 
	
	//verify if the robot is on a new step 
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
		    
		    //creates the histogram 
		    for(uint i = 0; i < step.traction.size(); i++) 
			histogram_traction->addValue(step.traction.at(i));
		    
		    for(uint i = 0; i < step.angular_velocity.size(); i++) 
		    {
			histogram_angular_velocity->addValue(step.angular_velocity.at(i));
			histogram_linear_velocity->addValue(step.linear_velocity.at(i));
		    }
		    
		    //A list of the last N histograms are combined into a single histogram for terrain classification   
     		    bool has_terrain_classification = histogram_classifiers.at(wheel_idx).addHistogram(histogram_traction->getHistogram(), histogram_angular_velocity->getHistogram(), histogram_linear_velocity->getHistogram() ); 
		    histogram_traction->clearHistogram();
		    histogram_angular_velocity->clearHistogram();
		    histogram_linear_velocity->clearHistogram();
		    
		    if( has_terrain_classification ) 
		    {
			TerrainType type = svm_classifiers.at(wheel_idx).getTerrainClassification(histogram_classifiers.at(wheel_idx).getCombinedHistogram()); 

			if(type == 0 ) 
			    unkwon[wheel_idx]++;
			else if ( type == 1) 
			    grass[wheel_idx]++;
			else if ( type == 2) 
			    path[wheel_idx]++;
			else if ( type == 3) 
			    pebles[wheel_idx]++;
			
			TerrainClassificationHistogram histogram_out; 
			histogram_out.time = ts;
			histogram_out.wheel_idx = wheel_idx; 
			histogram_out.svm = 0;
			histogram_out.terrain = _terrain_type.value(); 
			histogram_out.histogram = histogram_classifiers.at(wheel_idx).getCombinedHistogram();
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
	prev_time_orientation = ts; 
	return; 
    }
    
    /** Calculate the tranlation of the axes in the odometry */ 
    asg_odo->setInitialEncoder(prev_encoder); 
    Vector4d translation = asg_odo->translationAxes(encoder); 
    
    //calculate the robot velocities 
    double dt = (ts - prev_time_orientation).toSeconds(); 
    prev_time_orientation = ts; 
    double angular_velocity = fabs(heading - prev_heading) / dt; 
    double linear_velocity = translation.mean() / dt; 

    _linear_vel.write(linear_velocity); 
    _angular_vel.write(angular_velocity);
    
    
    //adds the velocities to the current step 
    for(int i = 0; i < 4; i++) 
	steps.at(i).addRobotVelocities( angular_velocity, linear_velocity);
    
    /** Slip detection */ 
    slipDetection(ts, heading - prev_heading, translation); 

    prev_heading =  heading;
    prev_encoder = encoder; 
    

    /** Terrain Classification  */ 
    terrainRecognition(ts);

}

void Task::motor_statusCallback(const base::Time &ts, const ::base::actuators::Status &motor_status_sample)
{
    
    for( int i = 0; i < 4; i ++) 
    {
	encoder[i] = motor_status_sample.states[i].positionExtern; 

    }
    
}

/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See Task.hpp for more detailed
// documentation about them.

bool Task::configureHook()
{
    if (! TaskBase::configureHook())
        return false;
    
    HistogramConfiguration histogram_angular_vel_conf = _histogram_angular_vel_conf.value(); 
    HistogramConfiguration histogram_linear_vel_conf = _histogram_angular_vel_conf.value(); 
    HistogramConfiguration histogram_traction_conf = _histogram_traction_conf.value(); 
    
    has_orientation = false; 
    has_traction_force = false; 
    traction_count = 0;
    
    // debug
    for( int i = 0; i < 4; i++) 
    {
	traction_force_avg[i] = 0; 
	normal_force_avg[i] = 0; 
	current_step_id[i] = 0; 
	has_wheel_slipped[i] = false; 

    }
    
    delete slip_model; 
    delete asg_odo; 
    delete histogram_traction; 
    delete histogram_angular_velocity;
    delete histogram_linear_velocity;
    
    histogram_classifiers.clear(); 
    steps.clear(); 
    svm_classifiers.clear(); 
    
    slip_model = new SlipDetectionModelBased( asguard_conf.trackWidth, asguard::FRONT_LEFT, asguard::FRONT_RIGHT, asguard::REAR_LEFT, asguard::REAR_RIGHT);
    asg_odo = new AsguardOdometry(asguard_conf.angleBetweenLegs, asguard_conf.wheelRadiusAvg); 
    histogram_traction = new Histogram(histogram_traction_conf.number_bins, histogram_traction_conf.histogram_min, histogram_traction_conf.histogram_max);
    histogram_linear_velocity = new Histogram(histogram_linear_vel_conf.number_bins, histogram_linear_vel_conf.histogram_min, histogram_linear_vel_conf.histogram_max); 
    histogram_angular_velocity = new Histogram(histogram_angular_vel_conf.number_bins, histogram_angular_vel_conf.histogram_min, histogram_angular_vel_conf.histogram_max); 

    SVMClassifiers svm_configuration = _svm_classifier.value(); 
    
    for( int wheel_idx = 0; wheel_idx < 4; wheel_idx++) 
    {
	HistogramTerrainClassification classifier( svm_configuration.number_of_histogram_combine); 
	histogram_classifiers.push_back(classifier); 
	
	SVMTerrainClassification svm(svm_configuration.terrain_types, svm_configuration.min_number_votes); 
	svm_classifiers.push_back(svm);
	svm_classifiers.at(wheel_idx).addSVMClassifier(svm_configuration.svm_classifier[wheel_idx]);
	
	TractionForceGroupedIntoStep stepStack(asguard_conf.angleBetweenLegs); 
	steps.push_back(stepStack);
    }

    // debug
    for(int i = 0; i < 4; i++)
    {
	path[i] = 0;  
	unkwon[i] = 0; 
	grass[i] = 0;  
	pebles[i] =0; 
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
void Task::stopHook()
{
    for(int wheel_idx = 0; wheel_idx < 4; wheel_idx++) 
	std::cout << wheel_idx <<" unkwon " << unkwon[wheel_idx] << " grass "<< grass[wheel_idx] << " path " << path[wheel_idx] << " pebles " << pebles[wheel_idx] << std::endl; 
    
    TaskBase::stopHook();
}
void Task::cleanupHook()
{
    TaskBase::cleanupHook();
    
}

