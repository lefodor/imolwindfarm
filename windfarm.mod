## set model windfarm
set MaintenanceTypes;
set MaintenanceSeverity;
set StaffTypes;
set StaffLevels;

param main_req{mt in MaintenanceTypes, ms in MaintenanceSeverity}; 	# maintenance required
param main_req_st{mt in MaintenanceTypes, st in StaffTypes};		# cnt staff per maintenance type
param main_req_xp{mt in MaintenanceTypes, ms in MaintenanceSeverity};	# maintenance in xp
param main_material_cost{MaintenanceTypes}; 				# maintenance cost
	
param staff_level_xp{StaffLevels};
param staff_level{st in StaffTypes, sl in StaffLevels} in StaffLevels;	# staff available
param staff_cost{st in StaffTypes, sl in StaffLevels}; 			# staff cost
	
## variables
var total_main_req_xp{MaintenanceTypes} >=0;
var total_main_req_st{MaintenanceTypes} >=0;
var total_staff_xp{StaffTypes};
var total_staff{StaffTypes};
var main_st_req_matrix{mt in MaintenanceTypes, st in StaffTypes}, binary;

var quantity{MaintenanceTypes} >= 0;

## conditions
s.t. RequiredXP{mt in MaintenanceTypes}: 
	total_main_req_xp[mt] = sum{ms in MaintenanceSeverity} (main_req[mt,ms] * main_req_xp[mt,ms]);
	
s.t. RequiredStaff{mt in MaintenanceTypes}:
	total_main_req_st[mt] = sum{st in StaffTypes} main_req_st[mt,st] * sum{ms in MaintenanceSeverity} main_req[mt,ms];
	
#s.t. AvailableXP{st in StaffTypes}:
#	total_staff_xp[st] = sum{sl in StaffLevels} staff_level[st,sl] * staff_level_xp[sl];
	
#s.t. AvailableStaff{st in StaffTypes}:
#	total_staff[st] = sum{sl in StaffLevels} staff_level[st,sl];
	
s.t. BinMatrixMainSt{mt in MaintenanceTypes, st in StaffTypes}:
	main_st_req_matrix[mt,st] = (if main_req_st[mt,st] > 0 then 1 else 0);
	
#s.t. AvailXP_ge_RequiredXP{}:
	
s.t. RequiredMaintenanceDone{mt in MaintenanceTypes}: 
	quantity[mt] >= sum{ms in MaintenanceSeverity} main_req[mt,ms];

## Objective
# minimize MaintenanceCosts / Downtime
minimize MaintenanceCosts: sum{mt in MaintenanceTypes} (main_material_cost[mt]) * quantity[mt];
#minimize Downtime: sum{m in MaintenanceTypes} cost_m[m] * quantity[m];

# to do:
# add var for staff => how many people needed to carry out minimum requirement with minimal costs
# add var for downtime per maintenance tasks

solve;

for{mt in MaintenanceTypes}{
    for{st in StaffTypes}
        printf "%d",main_st_req_matrix[mt, st];
    printf "\n";
}

end;
