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
##  ./examples/api-gateway-private-private/_versions.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.1.5"
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = ">= 2.8.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }
}
