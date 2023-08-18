# imolwindfarm

## Requirements
GLPK-utils installed on machine. E.g on Ubuntu run `sudo apt install glpk-utils` .

## How to call
The below code calls the model file `windfarm.mod` with data files `wfmaintenance.dat` and `wfstaff.dat` and writes `output.txt`.

`glpsol -m windfarm.mod -d wfmaintenance.dat -d wfstaff.dat -o output.txt`

# Windfarm maintenance tasks
Several maintenance jobs specific to windfarm are to be carried out with available staff.
Maintenance tasks are described by material costs and cost of staff.
Objective is to minimize total costs of maintenance including material and staff related costs
and to minimize total downtime of wind turbines.

## Maintenance jobs
Maintenance jobs can be divided to minimum maintenance requirements and ad-hoc maintenance jobs. 
Minimum maintenance jobs are easy to plan while ad-hoc maintenance jobs occur according to their probabilities.

## Staff
Staff is described by competence level (junior/middle/senior). The lower the competence level, the longer
the time required for the colleague to fix a maintenance job (a junior needs more time to carry out a 
task than a senior). Also, there exist training programs with certain cost that increases the competence
level of the staff, hence improving their time to complete a task.

## Sets
set MaintenanceTypes&emsp;&emsp;					{blades, gearbox, generator, sensors, wiring}  
set MaintenanceSeverity&emsp;&emsp;					{normal, severe}  
set StaffTypes&emsp;&emsp;						{electric, mechanic, storage, software}  
set StaffLevels&emsp;&emsp;						{junior, middle, senior}  

## Parameters
param main_req{MaintenanceTypes,MaintenanceSeverity}; 			# cnt of maintenance required
param main_req_st{MaintenanceTypes,StaffTypes};				# cnt of staff required per maintenance type and staff category
param main_req_xp{MaintenanceTypes,MaintenanceSeverity};		# required XP for maintenance task based on severity
param main_material_cost{MaintenanceTypes}; 				# material cost of maintenance tasks
	
param staff_level_xp{StaffLevels};					# staff level XPs
param staff_cost{StaffTypes,StaffLevels}; 				# staff cost per type and level
	
## Variables
var total_main_req_xp{MaintenanceTypes};				# required XP points to carry out maintenance task
var total_staff_xp{StaffTypes};						# total available XP per staff types of hired personnel
var total_staff{StaffTypes};						# total cnt of hired personnel
var total_staff_xp_task{MaintenanceTypes};*				# XP of hired personnel per category required for maintenance task
var staff_to_hire{StaffTypes, StaffLevels};				# cnt of staff needed as per type and level
var quantity{MaintenanceTypes};						# cnt maintenance tasks to be carried out 

* total_staff_xp_task: XP of hired personnel who are required for the given maintenance task => main_req_st[mt,st] != 0

## Conditions

## Objectives
