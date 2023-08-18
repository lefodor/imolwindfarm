# imolwindfarm

## Requirements
GLPK-utils installed on machine. E.g on Ubuntu run `sudo apt install glpk-utils` .

## How to call
The below code calls the model file `windfarm.mod` with data files `wfmaintenance.dat` and `wfstaff.dat` and writes `output.txt`.

`glpsol -m windfarm.mod -d wfmaintenance.dat -d wfstaff.dat -o output.txt`

# Windfarm problem setting
Several maintenance jobs specific to windfarm are to be carried out while minimizing costs. Costs are broken down to material and staff related components. Each maintenance job requires staff with different expertise and each job can be normal or severe maintenance that requires deeper knowledge from the staff to resolve. The staff also has an attribute called experience points or job expertise that can be junior/middle/senior the higher the level of experience the more XP is related but also higher staff costs are induced.  

## Maintenance jobs
Maintenance jobs can be divided to minimum maintenance requirements and ad-hoc maintenance jobs. 
Minimum maintenance jobs are easy to plan while ad-hoc maintenance jobs occur according to their probabilities.

## Staff
Staff is described by competence level (junior/middle/senior). The lower the competence level, the longer
the time required for the colleague to fix a maintenance job (a junior needs more time to carry out a 
task than a senior). Also, there exist training programs with certain cost that increases the competence
level of the staff, hence improving their time to complete a task.

## Sets
* set MaintenanceTypes							{blades, gearbox, generator, sensors, wiring}  
* set MaintenanceSeverity						{normal, severe}  
* set StaffTypes							{electric, mechanic, storage, software}  
* set StaffLevels							{junior, middle, senior}  

## Parameters
* param main_req{MaintenanceTypes,MaintenanceSeverity}; 		# cnt of maintenance required  
* param main_req_st{MaintenanceTypes,StaffTypes};			# cnt of staff required per maintenance type and staff category  
* param main_req_xp{MaintenanceTypes,MaintenanceSeverity};		# required XP for maintenance task based on severity  
* param main_material_cost{MaintenanceTypes}; 				# material cost of maintenance tasks  
* param staff_level_xp{StaffLevels};					# staff level XPs  
* param staff_cost{StaffTypes,StaffLevels}; 				# staff cost per type and level  
	
## Variables
* var total_main_req_xp{MaintenanceTypes};				# required XP points to carry out maintenance task  
* var total_staff_xp{StaffTypes};					# total available XP per staff types of hired personnel  
* var total_staff{StaffTypes};						# total cnt of hired personnel  
* var total_staff_xp_task{MaintenanceTypes};				# XP of hired personnel per category required for maintenance task  
XP of hired personnel who are required for the given maintenance task => main_req_st[mt,st] != 0
* var staff_to_hire{StaffTypes, StaffLevels};				# cnt of staff needed as per type and level  
* var quantity{MaintenanceTypes};					# cnt maintenance tasks to be carried out  

## Conditions
* *XP condition:* sufficient XP points to carry out upcoming maintenance tasks based on severity. It is only required to have enough XPs to carry out all types of maintenance task (based on severity), e.g. maintenance task "blades" normally requires 10 XPs whereas severe requires 80 XPs but no severe maintenance task is required for "blades" (in the main_req parameter) then the condition prescribes 10 XPs for this maintenance task. It does not matter how many maintenance jobs are expected, the hired staff has to have enough XPs to do all types of jobs. E.g. if normal maintenance task "blades" is expected 12 times and no severe "blades" task required, then XPs of hired personnel has to have at least 10 XPs (normal "blade" maintenance XP) and not 12 times 10 XPs. It will just take them more time to do all 12 normal "blades" job. 
* *Staff condition:* number of staff for a given type (no matter if junior/middle/senior) covers the required number of staff for each maintenance task. E.g. in order to be able carry out maintenance task "blades", main_req_st[MaintenanceType,StaffType] prescribes 3 mechanics and 4 storage personnel so at least 3 mechanis and 4 storage workers have to be hired.
* *Minimum maintenance:* maintenance jobs defined in main_req are carried out

## Objectives
Minimize total costs given by the aggregated sum of main_material_cost and staff_cost.
