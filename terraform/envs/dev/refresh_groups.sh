#!/usr/bin/env sh

aws autoscaling start-instance-refresh --strategy Rolling --auto-scaling-group-name fhandle-asg
aws autoscaling start-instance-refresh --strategy Rolling --auto-scaling-group-name fquery-asg
aws autoscaling start-instance-refresh --strategy Rolling --auto-scaling-group-name web-asg
