## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./_variables.autoscale.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

variable "autoscale_enabled" {
  type        = bool
  description = "A boolean to enable/disable autoscale policy for ECS Service"
  default     = false
}

variable "autoscale_dimension" {
  type        = string
  description = "Dimension to autoscale on (valid options: cpu, memory)"
  default     = "memory"
}

variable "autoscale_min_capacity" {
  type        = number
  description = "Minimum number of running instances of a Service"
  default     = 1
}

variable "autoscale_max_capacity" {
  type        = number
  description = "Maximum number of running instances of a Service"
  default     = 2
}

variable "autoscale_scale_up_adjustment" {
  type        = number
  description = "Scaling adjustment to make during scale up event"
  default     = 1
}

variable "autoscale_scale_up_cooldown" {
  type        = number
  description = "Period (in seconds) to wait between scale up events"
  default     = 60
}

variable "autoscale_scale_down_adjustment" {
  type        = number
  description = "Scaling adjustment to make during scale down event"
  default     = -1
}

variable "autoscale_scale_down_cooldown" {
  type        = number
  description = "Period (in seconds) to wait between scale down events"
  default     = 300
}

variable "alarms_enabled" {
  type        = bool
  description = "A boolean to enable/disable service utilization SNS alarms"
  default     = false
}

variable "alarms_cpu_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of CPU utilization average"
  default     = 80
}

variable "alarms_cpu_utilization_high_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "alarms_cpu_utilization_high_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "alarms_cpu_utilization_high_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action"
  default     = []
}

variable "alarms_cpu_utilization_high_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action"
  default     = []
}

variable "alarms_cpu_utilization_low_threshold" {
  type        = number
  description = "The minimum percentage of CPU utilization average"
  default     = 20
}

variable "alarms_cpu_utilization_low_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "alarms_cpu_utilization_low_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "alarms_cpu_utilization_low_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action"
  default     = []
}

variable "alarms_cpu_utilization_low_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action"
  default     = []
}

variable "alarms_memory_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of Memory utilization average"
  default     = 80
}

variable "alarms_memory_utilization_high_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "alarms_memory_utilization_high_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "alarms_memory_utilization_high_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action"
  default     = []
}

variable "alarms_memory_utilization_high_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action"
  default     = []
}

variable "alarms_memory_utilization_low_threshold" {
  type        = number
  description = "The minimum percentage of Memory utilization average"
  default     = 20
}

variable "alarms_memory_utilization_low_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "alarms_memory_utilization_low_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "alarms_memory_utilization_low_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action"
  default     = []
}

variable "alarms_memory_utilization_low_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action"
  default     = []
}
