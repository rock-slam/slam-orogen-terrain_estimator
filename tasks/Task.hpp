/* Generated from orogen/lib/orogen/templates/tasks/Task.hpp */

#ifndef TERRAIN_ESTIMATOR_TASK_TASK_HPP
#define TERRAIN_ESTIMATOR_TASK_TASK_HPP

#include "terrain_estimator/TaskBase.hpp"


#include "asguard/Configuration.hpp"
#include "asguard/Transformation.hpp"

#include "terrain_estimator/TerrainTypes.hpp"
#include "terrain_estimator/ModelBaseAnalysis.hpp" 
#include <Eigen/Core>
#include <vector>
namespace terrain_estimator {
      
    class Task : public TaskBase
    {
	friend class TaskBase;
	
    protected:
	EIGEN_MAKE_ALIGNED_OPERATOR_NEW
	
	asguard::Configuration config;
	
	/** if a new slip detection cycle was initialized */ 
	bool init; 
	
	/** The slip detections operates in time windows, this mark the time when a new slip detection started */ 
	base::Time init_time; 
	
	bool has_traction_force; 
	
	asguard::Configuration asguard_conf; 
	
	SlipDetectionModelBased *slip_model; 

	AsguardOdometry *asg_odo; 
	
	std::vector<HistogramTerrainClassification> histogram; 
	
	/** Physical filter - brakes the steps only in the moments there was a single wheel slip */
	/** if the wheel single wheel slipped */ 
	bool has_single_wheel_slipped[4]; 
	/** the current step of the wheel */ 
	int current_step[4]; 
	/** the tractions during the step */ 
	std::vector<double> traction[4]; 
	
	/** the initial heading*/ 
	double initial_heading; 
	/** current heading */ 
	double heading; 
	
	bool has_orientation; 
	
	virtual void ground_forces_estimatedCallback(const base::Time &ts, const ::torque_estimator::GroundForces &ground_forces_estimated_sample);
        virtual void motor_statusCallback(const base::Time &ts, const ::base::actuators::Status &motor_status_sample);
	virtual void orientation_samplesCallback(const base::Time &ts, const ::base::samples::RigidBodyState &orientation_samples_sample);
	
	//TODO This are for Debug purposes 
	double traction_force_avg[4]; 
	double normal_force_avg[4]; 
	double traction_count; 
	double init_traction; 
	Vector2d odometry; 
	Vector2d corrected_odometry; 

    public:
        Task(std::string const& name = "terrain_estimator::Task");
        Task(std::string const& name, RTT::ExecutionEngine* engine);

	~Task();

        /** This hook is called by Orocos when the state machine transitions
         * from PreOperational to Stopped. If it returns false, then the
         * component will stay in PreOperational. Otherwise, it goes into
         * Stopped.
         *
         * It is meaningful only if the #needs_configuration has been specified
         * in the task context definition with (for example):
         *
         *   task_context "TaskName" do
         *     needs_configuration
         *     ...
         *   end
         */
        bool configureHook();

        /** This hook is called by Orocos when the state machine transitions
         * from Stopped to Running. If it returns false, then the component will
         * stay in Stopped. Otherwise, it goes into Running and updateHook()
         * will be called.
         */
        bool startHook();

        /** This hook is called by Orocos when the component is in the Running
         * state, at each activity step. Here, the activity gives the "ticks"
         * when the hook should be called.
         *
         * The error(), exception() and fatal() calls, when called in this hook,
         * allow to get into the associated RunTimeError, Exception and
         * FatalError states. 
         *
         * In the first case, updateHook() is still called, and recover() allows
         * you to go back into the Running state.  In the second case, the
         * errorHook() will be called instead of updateHook(). In Exception, the
         * component is stopped and recover() needs to be called before starting
         * it again. Finally, FatalError cannot be recovered.
         */
        void updateHook();

        /** This hook is called by Orocos when the component is in the
         * RunTimeError state, at each activity step. See the discussion in
         * updateHook() about triggering options.
         *
         * Call recover() to go back in the Runtime state.
         */
        // void errorHook();

        /** This hook is called by Orocos when the state machine transitions
         * from Running to Stopped after stop() has been called.
         */
        // void stopHook();

        /** This hook is called by Orocos when the state machine transitions
         * from Stopped to PreOperational, requiring the call to configureHook()
         * before calling start() again.
         */
        void cleanupHook();
    };
}

#endif

