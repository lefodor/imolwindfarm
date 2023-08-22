## set model windfarm
set MaintenanceTypes;
set MaintenanceSeverity;
set StaffTypes;
set StaffLevels;

param main_req{mt in MaintenanceTypes, ms in MaintenanceSeverity}; # cnt of maintenance required
param main_req_st{mt in MaintenanceTypes, st in StaffTypes}; # cnt of staff required per maintenance type
param main_req_xp{mt in MaintenanceTypes, ms in MaintenanceSeverity}; # required xp for maintenance task
param main_material_cost{MaintenanceTypes}; # maintenance cost
	
param staff_level_xp{StaffLevels};						
param staff_cost{st in StaffTypes, sl in StaffLevels}; 	
param main_burnout{MaintenanceSeverity};
param burnout_coef; 

## variables
var total_main_req_xp{MaintenanceTypes}; # required XP points to carry out maintenance task
var total_staff_xp{StaffTypes};	# total available XP per staff types of hired personnel
var total_req_staff_main{MaintenanceTypes}; # total required staff to carry out maintenance task
var total_staff{StaffTypes}; # total cnt of hired personnel
var total_staff_xp_task{MaintenanceTypes}; # XP of hired personnel per staff category
var weighted_maintenance_tasks{MaintenanceTypes}; # nr of maintenance tasks weighted by burnout factor
var total_req_wgt_staff{StaffTypes}; # total cnt of required staff for severity weighted maintenance tasks

var staff_to_hire{StaffTypes, StaffLevels} >=0, integer;
var quantity{MaintenanceTypes} >= 0;

## conditions
# XP: sufficient XP points to carry out upcoming maintenance tasks based on severity
s.t. RequiredXP{mt in MaintenanceTypes}: 
	total_main_req_xp[mt] = (if main_req[mt,"severe"] <> 0 then main_req_xp[mt,"severe"] else main_req_xp[mt,"normal"]);

s.t. AvailableXP{st in StaffTypes}:
	total_staff_xp[st] = sum{sl in StaffLevels} staff_to_hire[st,sl] * staff_level_xp[sl];

s.t. AvailableXP_task{mt in MaintenanceTypes}:
	total_staff_xp_task[mt] = sum{st in StaffTypes} if main_req_st[mt,st] <> 0 then total_staff_xp[st] else 0 ;
	
s.t. AvailableXP_ge_RequiredXP{mt in MaintenanceTypes}:
	total_staff_xp_task[mt] >= total_main_req_xp[mt];

# staff: enough personnel to cover staff requirements per maintenance tasks	
s.t. AvailableStaff{st in StaffTypes}:
	total_staff[st] = sum{sl in StaffLevels} staff_to_hire[st,sl];

s.t. TotalStaffperMain{mt in MaintenanceTypes}:
    total_req_staff_main[mt] = sum{st in StaffTypes} main_req_st[mt,st];
	
s.t. AvailableStaff_ge_RequiredStaff{mt in MaintenanceTypes, st in StaffTypes}:
	total_staff[st] >= main_req_st[mt, st];

# minimum maintenance
s.t. RequiredMaintenanceDone{mt in MaintenanceTypes}: 
	quantity[mt] >= sum{ms in MaintenanceSeverity} main_req[mt,ms];

## burnout indicators
s.t. StaffNoBurnout{mt in MaintenanceTypes}:
    weighted_maintenance_tasks[mt] = sum{ms in MaintenanceSeverity} main_req[mt,ms] * main_burnout[ms];

s.t. TotalReqWgtStaff{st in StaffTypes}:
    total_req_wgt_staff[st] = sum{mt in MaintenanceTypes} weighted_maintenance_tasks[mt] * main_req_st[mt,st];

# burnout
s.t. BurnOutNotAllowed2{st in StaffTypes}:
    total_req_wgt_staff[st] <= total_staff[st] * burnout_coef;

## Objective
minimize TotalCosts: 
	sum{st in StaffTypes, sl in StaffLevels} staff_to_hire[st,sl] * staff_cost[st,sl] +
	sum{mt in MaintenanceTypes} (main_material_cost[mt]) * quantity[mt] ;

solve;

printf "-----------------------------------------------------------------------\n";

printf "total_main_req_xp\n";
for{mt in MaintenanceTypes}{
	    printf "%s\t",mt;
	    printf "%d",total_main_req_xp[mt];
	printf "\n";
}
printf "\n";

printf "-----------------------------------------------------------------------\n";

printf "total_staff_xp\n";
for{st in StaffTypes}{
	    printf "%s\t",st;
	    printf "%d",total_staff_xp[st];
	printf "\n";
}
printf "\n";

printf "-----------------------------------------------------------------------\n";

printf "total_staff_xp_task\n";
for{mt in MaintenanceTypes}{
	    printf "%s\t",mt;
	    printf "%d",total_staff_xp_task[mt];
	printf "\n";
}
printf "\n";

printf "-----------------------------------------------------------------------\n";

printf "total_staff\n";
for{st in StaffTypes}{
	    printf "%s\t",st;
	    printf "%d",total_staff[st];
	printf "\n";
}
printf "\n";

printf "-----------------------------------------------------------------------\n";

printf "weighted_maintenance_tasks\n";
for{mt in MaintenanceTypes}{
	    printf "%s\t",mt;
	    printf "%d",weighted_maintenance_tasks[mt];
	printf "\n";
}
printf "\n";

printf "-----------------------------------------------------------------------\n";

printf "total_req_wgt_staff\n";
for{st in StaffTypes}{
	    printf "%s\t",st;
	    printf "%d",total_req_wgt_staff[st];
	printf "\n";
}
printf "\n";

printf "-----------------------------------------------------------------------\n";

printf "staff_to_hire and staff cost ===== %d\n", sum{st in StaffTypes,sl in StaffLevels} staff_to_hire[st,sl] * staff_cost[st,sl];
for{st in StaffTypes}{
	printf "%s",st;
	printf "   =========== %d\n",sum{sl in StaffLevels} staff_to_hire[st,sl] * staff_cost[st,sl];
	for{sl in StaffLevels}{
		printf "%s     ",sl;
		printf "%d",staff_to_hire[st,sl];
		printf ".......... %d",staff_to_hire[st,sl] * staff_cost[st,sl];
		printf "\n";
	}
	printf "\n";
}

printf "-----------------------------------------------------------------------\n";

printf "main_material_cost ===== %d\n", sum{mt in MaintenanceTypes}main_material_cost[mt] * quantity[mt];
printf {mt in MaintenanceTypes}: "%s......%d\n",mt,main_material_cost[mt] * quantity[mt];

printf "-----------------------------------------------------------------------\n";

printf "total costs = SUM(material costs) + SUM(staff costs) \n";
printf "%d = %d + %d\n",
sum{mt in MaintenanceTypes}main_material_cost[mt] * quantity[mt] + 
sum{st in StaffTypes,sl in StaffLevels} staff_to_hire[st,sl] * staff_cost[st,sl], sum{mt in MaintenanceTypes}main_material_cost[mt] * quantity[mt],
sum{st in StaffTypes,sl in StaffLevels} staff_to_hire[st,sl] * staff_cost[st,sl] ;

printf "-----------------------------------------------------------------------\n";


end;
