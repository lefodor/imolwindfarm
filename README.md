# imolwindfarm

## Requirements
GLPK-utils installed on machine. E.g on Ubuntu run `sudo apt install glpk-utils` .

## How to call
The below code calls the model file `windfarm.mod` with data files `wfmaintenance.dat` and `wfstaff.dat` and writes `output.txt`.

`glpsol -m windfarm.mod -d wfmaintenance.dat -d wfstaff.dat -o output.txt`

# Windfarm problem setting
Several maintenance jobs specific to windfarm are to be carried out while minimizing costs. Costs are broken down to material and staff related components. Each maintenance job requires staff with different expertise and each job can be normal or severe maintenance that requires deeper knowledge from the staff to resolve. The staff also has an attribute called experience points or job expertise that can be junior/middle/senior the higher the level of experience the more XP is related but also higher staff costs are associated.  

## Maintenance jobs
Maintenance jobs are divided into 5 types based on which expertise is required from the staff. Each of the 5 maintenance types are further grouped based on severity. Level of severity determines the XPs required from the staff to accomplish such task. Currently only 2 severity levels have been set for each task types, "normal" stands for regular task and "severe" stands for more difficult operations with higher required XP.  

## Staff
Staff is divided into 4 types: electrician is taking care of wiring and electrical repairs, mechanic is tasked with assembling/disassembling stuffs, storage workers are keeping the warehouse tidy and in order while software engineers are responsible for programming controlling software and calibrating the elements. Staff is also described by level of expertise, there are 3 categories with different experience points: junior, middle, senior. 

## Sets
* set MaintenanceTypes {blades, gearbox, generator, sensors, wiring}  
* set MaintenanceSeverity {normal, severe}  
* set StaffTypes {electric, mechanic, storage, software}  
* set StaffLevels {junior, middle, senior}  

## Parameters
* param main_req{MaintenanceTypes,MaintenanceSeverity}; # cnt of maintenance required  
* param main_req_st{MaintenanceTypes,StaffTypes}; # cnt of staff required per maintenance type and staff category  
* param main_req_xp{MaintenanceTypes,MaintenanceSeverity}; # required XP for maintenance task based on severity  
* param main_material_cost{MaintenanceTypes}; # material cost of maintenance tasks  
* param staff_level_xp{StaffLevels}; # staff level XPs  
* param staff_cost{StaffTypes,StaffLevels}; # staff cost per type and level  
* param main_burnout; # weight based on severity of maintenance task
* param burnout_coef; # total (severity weighted) tasks / staff cutoff  
	
## Variables
### Variables used by solver
* var staff_to_hire{StaffTypes, StaffLevels}; # cnt of staff needed as per type and level  
* var quantity{MaintenanceTypes}; # cnt maintenance tasks to be carried out  

### Redundant variables - improve readability
* var total_main_req_xp{MaintenanceTypes}; # required XP points to carry out maintenance task  
* var total_staff_xp{StaffTypes}; # total available XP per staff types of hired personnel  
* var total_staff{StaffTypes}; # total cnt of hired personnel  
* var total_staff_xp_task{MaintenanceTypes}; # XP of hired personnel per category required for maintenance task  
* var weighted_maintenance_tasks{MaintenanceTypes}; # nr of maintenance tasks weighted by burnout factor
* var total_req_wgt_staff{StaffTypes}; # total cnt of required staff for maintenance tasks weighted by severity
 
## Conditions
* *XP condition:* sufficient XP points to carry out upcoming maintenance tasks based on severity. It is only required to have enough XPs to carry out at least one of all types of maintenance task (based on severity), e.g. maintenance task "blades" normally requires 10 XPs whereas severe requires 80 XPs but when no severe maintenance task is scheduled for "blades" (main_req parameter is set to 0) then the condition prescribes 10 XPs for this maintenance task (normal severity level). It does not matter how many maintenance jobs are expected, the hired staff has to have enough XPs to do all types of jobs. E.g. if normal maintenance task "blades" is expected 12 times and no severe "blades" task required, then XPs of hired personnel has to have at least 10 XPs (normal "blade" maintenance XP) and not 12 times 10 XPs. It will just take them more time to do all 12 normal "blades" job. 
* *Staff condition:* number of staff for a given type (no matter if junior/middle/senior) covers the required number of staff for each maintenance task. E.g. in order to be able carry out maintenance task "blades", main_req_st[MaintenanceType,StaffType] prescribes 3 mechanics and 4 storage personnel so at least 3 mechanics and 4 storage workers have to be hired.
* *Minimum maintenance:* maintenance jobs defined in main_req are carried out
* *Burnout indicator:* staff is not overloaded, so the number of maintenance tasks are weighted based on severity. The number of tasks per staff member has to be lower than the parameter burnout_coef.

## Objectives
Minimize total costs given by the aggregated sum of main_material_cost and staff_cost given the above conditions.
