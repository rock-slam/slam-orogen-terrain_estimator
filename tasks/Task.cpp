/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#include <fftw3.h>

using namespace terrain_estimator;

Task::Task(std::string const& name)
    : TaskBase(name)
{
}

Task::Task(std::string const& name, RTT::ExecutionEngine* engine)
    : TaskBase(name, engine), vibration(0)
{
}

Task::~Task()
{
}

void Task::acceleration_samplesTransformerCallback(const base::Time &ts, const ::base::samples::IMUSensors &acceleration_samples_sample)
{

    
    asguard::Transformation tf;
    Eigen::Vector3d acc( acceleration_samples_sample.acc);
    
    std::cout << (tf.xsens2Body * acc).transpose()<< std::endl; ; 

    Eigen::Transform3d world2Body;
    bool hasWorld2Body = _world2body.get(ts, world2Body, true);
    Eigen::Vector3d gravity_world(0,0, 9.81); 
    //TODO VERIFY IF THIS IS CORRECT IN AN INCLINED PLANE 
    //std::cout << world2Body.rotation() * gravity_world << std::endl; 
    
    Eigen::Transform3d xsens2Body;
    bool hasXsens2Body = _xsens2body.get(ts, xsens2Body, true);
    
    std::cout <<( xsens2Body.rotation() * acc ).transpose()<< std::endl; 
    
    
}

/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See Task.hpp for more detailed
// documentation about them.

bool Task::configureHook()
{
    if (! TaskBase::configureHook())
        return false;
    
    vibration = new VibrationAnalysis(_vibration_configuration.value()); 
    
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
    
    delete vibration; 
}

