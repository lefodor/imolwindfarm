# set model windfarm
set MaintenanceTypes;
set StaffTypes;
set 

# minimum maintenance required
param req_m{MaintenanceTypes};

# staff required / maintenance tasks
param req_st{m in MaintenanceTypes, s in StaffTypes};

# staff available
#param avail_st{StaffTypes};

# maintenance cost
param cost_material{MaintenanceTypes};

# staff cost
param cost_staff{StaffTypes};

# total staff required
param req_total_staff{m in MaintenanceTypes, s in StaffTypes} := req_st[m,s] * req_m[m];

# total material cost
param cost_total_material{m in MaintenanceTypes} := req_m[m] * cost_material[m];

# total staff cost
param cost_total_staff{m in MaintenanceTypes, s in StaffTypes} := req_total_staff[m,s] * cost_staff[s];

# if staff_required >= staff_available => budget for new contracts

# variables solver
var quantity{MaintenanceTypes} >= 0;

# conditions
#s.t. RequiredStaff: sum{m in MaintenanceTypes, s in StaffType} quantity[m] * req_st[s] <= avail_st[s];
s.t. RequiredMaintenanceDone{m in MaintenanceTypes}: quantity[m] >= req_m[m]; 

# minimize MaintenanceCosts / Downtime
minimize MaintenanceCosts: sum{m in MaintenanceTypes, s in StaffTypes} (cost_total_material[m] + cost_total_staff[m,s]) * quantity[m];
#minimize Downtime: sum{m in MaintenanceTypes} cost_m[m] * quantity[m];

# to do:
# add var for staff => how many people needed to carry out minimum requirement with minimal costs
# add var for downtime per maintenance tasks


end;
