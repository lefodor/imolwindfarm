# imolwindfarm
glpsol -m windfarm.mod -d windfarm.dat -o output.txt

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
