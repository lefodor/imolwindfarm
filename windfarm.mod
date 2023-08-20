## set model windfarm
set MaintenanceTypes;
set MaintenanceSeverity;
set StaffTypes;
set StaffLevels;

param main_req{mt in MaintenanceTypes, ms in MaintenanceSeverity}; 		# cnt of maintenance required
param main_req_st{mt in MaintenanceTypes, st in StaffTypes};			# cnt of staff required per maintenance type
param main_req_xp{mt in MaintenanceTypes, ms in MaintenanceSeverity};		# required xp for maintenance task
param main_material_cost{MaintenanceTypes}; 					# maintenance cost
	
param staff_level_xp{StaffLevels};						# staff level XPs
param staff_cost{st in StaffTypes, sl in StaffLevels}; 				# staff cost
	
## variables
var total_main_req_xp{MaintenanceTypes};					# required XP points to carry out maintenance task
var total_staff_xp{StaffTypes};							# total available XP per staff types of hired personnel
var total_staff{StaffTypes};							# total cnt of hired personnel
var total_staff_xp_task{MaintenanceTypes};					# XP of hired personnel per staff category

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
	
s.t. AvailableStaff_ge_RequiredStaff{mt in MaintenanceTypes, st in StaffTypes}:
	total_staff[st] >= main_req_st[mt, st];
	
# minimum maintenance
s.t. RequiredMaintenanceDone{mt in MaintenanceTypes}: 
	quantity[mt] >= sum{ms in MaintenanceSeverity} main_req[mt,ms];

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

printf "staff_to_hire\n";
for{st in StaffTypes}{
	printf "%s\n",st;
	for{sl in StaffLevels}{
		printf "%s     ",sl;
		printf "%d",staff_to_hire[st,sl];
		printf "\n";
	}
	printf "\n";
}

printf "-----------------------------------------------------------------------\n";

end;
