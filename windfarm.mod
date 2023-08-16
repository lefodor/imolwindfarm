## set model windfarm
set MaintenanceTypes;
	param req_m{MaintenanceTypes}; 		# minimum maintenance required
	param cost_material{MaintenanceTypes}; 	# maintenance cost
	
set StaffTypes;
	#param avail_st{StaffTypes};   # staff available
	param cost_staff{StaffTypes}; # staff cost
	#param cost_staff_jun{StaffTypes}; # staff cost junior
	#param cost_staff_mid{StaffTypes}; # staff cost middle
	#param cost_staff_sen{StaffTypes}; # staff cost senior
	
#set Time; Time to finish 1 unit of maintenance for junior/middle/senior staff

# staff required / maintenance tasks
param req_st{m in MaintenanceTypes, s in StaffTypes};

# total staff required
param req_total_staff{m in MaintenanceTypes, s in StaffTypes} := req_st[m,s] * req_m[m];

# total material cost
param cost_total_material{m in MaintenanceTypes} := req_m[m] * cost_material[m];

# total staff cost
param cost_total_staff{m in MaintenanceTypes, s in StaffTypes} := req_total_staff[m,s] * cost_staff[s];

# if staff_required >= staff_available => budget for new contracts

## variables solver
var quantity{MaintenanceTypes} >= 0;

## conditions
#s.t. RequiredStaff: sum{m in MaintenanceTypes, s in StaffType} quantity[m] * req_st[s] <= avail_st[s];
s.t. RequiredMaintenanceDone{m in MaintenanceTypes}: quantity[m] >= req_m[m]; 

## Objective
# minimize MaintenanceCosts / Downtime
minimize MaintenanceCosts: sum{m in MaintenanceTypes, s in StaffTypes} (cost_total_material[m] + cost_total_staff[m,s]) * quantity[m];
#minimize Downtime: sum{m in MaintenanceTypes} cost_m[m] * quantity[m];

# to do:
# add var for staff => how many people needed to carry out minimum requirement with minimal costs
# add var for downtime per maintenance tasks


end;
