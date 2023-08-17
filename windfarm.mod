## set model windfarm
set MaintenanceTypes;
set MaintenanceSeverity;
set StaffTypes;
set StaffLevels;

param main_req{mt in MaintenanceTypes, ms in MaintenanceSeverity}; 		# maintenance required
param main_req_st{mt in MaintenanceTypes, st in StaffTypes};			# cnt staff per maintenance type
param main_req_xp{mt in MaintenanceTypes, ms in MaintenanceSeverity};		# maintenance in xp
param main_material_cost{MaintenanceTypes}; 					# maintenance cost
	
param staff_level_xp{StaffLevels};						# staff level XPs
param staff_cost{st in StaffTypes, sl in StaffLevels}; 				# staff cost
	
## variables
var total_main_req_xp{MaintenanceTypes};
var total_staff_xp{StaffTypes};
var total_staff{StaffTypes};
var total_staff_xp_task{MaintenanceTypes};

var staff_to_hire{StaffTypes, StaffLevels} >=0, integer;
var quantity{MaintenanceTypes} >= 0;

## conditions
# XP
s.t. RequiredXP{mt in MaintenanceTypes}: 
	total_main_req_xp[mt] = sum{ms in MaintenanceSeverity} (if main_req[mt,"severe"] <> 0 then main_req_xp[mt,"severe"] else main_req_xp[mt,"normal"]);

s.t. AvailableXP{st in StaffTypes}:
	total_staff_xp[st] = sum{sl in StaffLevels} staff_to_hire[st,sl] * staff_level_xp[sl];

s.t. AvailableXP_task{mt in MaintenanceTypes}:
	total_staff_xp_task[mt] = sum{st in StaffTypes} if main_req_st[mt,st] <> 0 then total_staff_xp[st] else 0 ;
	
s.t. AvailableXP_ge_RequiredXP{mt in MaintenanceTypes}:
	total_staff_xp_task[mt] >= total_main_req_xp[mt];

# staff	
#s.t. RequiredStaff{mt in MaintenanceTypes}:
#	task_main_req_st[mt] = sum{st in StaffTypes} main_req_st[mt,st];	

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

# to do:
# add var for staff => how many people needed to carry out minimum requirement with minimal costs
# add var for downtime per maintenance tasks

solve;

printf "total_staff_xp\n";
for{st in StaffTypes}{
	    printf "%s\t",st;
	    printf "%d",total_staff_xp[st];
	printf "\n";
}
printf "\n";

printf "total_main_req_xp\n";
for{mt in MaintenanceTypes}{
	    printf "%s\t",mt;
	    printf "%d",total_main_req_xp[mt];
	printf "\n";
}
printf "\n";

printf "total_staff_xp_task\n";
for{mt in MaintenanceTypes}{
	    printf "%s\t",mt;
	    printf "%d",total_staff_xp_task[mt];
	printf "\n";
}
printf "\n";

printf "staff_to_hire\n";
for{st in StaffTypes}{
	printf "%s\n",st;
	for{sl in StaffLevels}{
		printf "%d",staff_to_hire[st,sl];
		printf "\n";
	}
}
printf "\n";

end;
