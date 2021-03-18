
variable "bucket_name" {
  default = "spx.antientf.tk"
}


variable "PATH_TO_PRIVATE_KEY" {
  default = "~/.ssh/id_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "~/.ssh/id_rsa.pub"
}

##################################################################
###########  EC2                                       ###########  
##################################################################


variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 3
}

variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
  default     = "demo"
}


variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}


variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  type        = bool
  default     = true
}


##################################################################
###########  RDS                                       ###########  
##################################################################

variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  type        = string
  default     = "spxdb"
}

variable "rds_engine" {
  description = "The database engine to use"
  type        = string
  default     = "sqlserver-se"
}


variable "rds_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "11.00.7493.4.v1"
}

variable "rds_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.m3.medium"
}

variable "rds_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = 200
}

variable "rds_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = false
}


variable "rds_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
  default     = "spxdb"
}


variable "rds_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "spuser"
}

variable "rds_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
  sensitive   = true
  default     = "YourPwdShouldBeLongAndSecure!"
}

variable "rds_port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = 1433
}

variable "rds_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 0
}

variable "rds_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "sqlserver-se-11.0"
}

variable "rds_major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
  default     = "11.00"
}

variable "rds_final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
  default     = "spxdb"
}

variable "rds_deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "rds_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "rds_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  type        = string
  default     = "03:00-06:00"
}

variable "tags_account" {
  description = "The name's tag of owner rds"
  type        = string
  default     = "MSI"
}

variable "tags_name" {
  description = "The name's tag of owner rds"
  type        = string
  default     = "WEB ELB"
}

variable "tags_environment" {
  description = "The name's tag of environment rds"
  type        = string
  default     = "TEST"
}
variable "tags_product" {
  description = "The name's tag of product rds"
  type        = string
  default     = "SPX"
}

##################################################################
###########  ALB                                       ###########  
##################################################################
variable "tags_alb" {
  description = "tag of lb"
  type        = map
  default     = {
    Project = "spx"
  }
}

variable "target_groups" {
  description = "this is a target groups"
  type        = any
  default     =  [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      tags = {
        InstanceTargetGroupTag = "InstanceTargetGroupTag"
      }
    },
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      tags = {
        InstanceTargetGroupTag = "InstanceTargetGroupTag"
      }
    }
  ]
}

variable "alb_name" {
  description = "The resource name and Name tag of the load balancer."
  type        = string
  default     = "spx"
}

### http 80 redirect to https 443

# variable "alb_http_tcp_listeners" {
#   description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
#   type        = any
#   default     = [
#     {
#       port               = 80
#       protocol           = "HTTP"
#       action_type = "redirect"  # Forward action is default, either when defined or undefined
#       target_group_index = 0
#       redirect = {
#         port        = "443"
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#   ]
# }

variable "alb_http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
  type        = any
  default     = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

variable "alb_target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port"
  type        = any
  default     = [
    {
      name_prefix          = "WebELB"
      backend_port         = 80
      backend_protocol     = "HTTP"
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]
}

# variable "alb_https_listener_rules" {
#   description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])"
#   type        = any
#   default     = [
#     {
#       https_listener_index = 0
#       priority             = 5000
#       actions = [{
#         type        = "redirect"
#         status_code = "HTTP_302"
#         host        = "www.antientf.tk"
#         path        = "/*"
#         query       = ""
#         protocol    = "HTTPS"
#       }]
#       conditions = [{
#         http_headers = [{
#           http_header_name = "x-Gimme-Fixed-Response"
#           values           = ["yes", "please", "right now"]
#         }]
#       }]
#     },
#   ]
# }



##################################################################
###########  ASG                                       ###########  
##################################################################

variable "tags_asg" {
  description = "tag of asg"
  type        = list
  default     = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]
}

variable "asg_name" {
  description = "Creates a unique name beginning with the specified prefix"
  type        = string
  default     = "example-with-elb"
}

variable "asg_lc_name" {
  description = "Creates a unique name for launch configuration beginning with the specified prefix"
  type        = string
  default     = "lcNginx "
}

variable "asg_instance_type" {
  description = "The size of instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "asg_health_check_type" {
  description = "Controls how health checking is done. Values are - EC2 and ELB"
  type        = string
  default     = "EC2"
}

variable "asg_min_size" {
  description = "The minimum size of the auto scale group"
  type        = string
  default     = 4
}

variable "asg_max_size" {
  description = "The maximum size of the auto scale group"
  type        = string
  default     = 4
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = string
  default     = 4
}

variable "asg_force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  type        = bool
  default     = true
}



##################################################################
###########  KEY                                       ###########  
##################################################################


variable "key_name" {
  description = "The name for the key pair."
  type        = string
  default     = "mykeypair"
}


##################################################################
###########  ACM                                       ###########  
##################################################################

variable "tags_acm" {
  description = "tag of acm"
  type        = map
  default     = {
    "name" = "demo tf"
  }
}

variable "acm_domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = "*.antientf.tk"
}

variable "acm_validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform."
  type        = string
  default     = "DNS"
}

##################################################################
###########  SG                                       ###########  
##################################################################

variable "sg_name" {
  description = "Name of security group"
  type        = string
  default = "NginxELB"
}

variable "sg_description" {
  description = "Description of security group"
  type        = string
  default     = "Security group for example usage with EC2 instance"
}

variable "sg_ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "sg_ingress_rules" {
  description = "List of ingress rules to create by name"
  type        = list(string)
  default     = ["http-80-tcp","https-443-tcp", "all-icmp", "ssh-tcp"]
}

variable "sg_egress_rules" {
  description = "List of egress rules to create by name"
  type        = list(string)
  default     = ["all-all"]
}


##################################################################
###########  VPC                                       ###########  
##################################################################

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "spx"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "192.168.0.0/16"
}

variable "vpc_azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24","192.168.6.0/24"]
}


variable "vpc_database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
  default     = ["192.168.15.0/24", "192.168.16.0/24", "192.168.17.0/24"]
}


variable "vpc_create_database_subnet_group" {
  description = "Controls if database subnet group should be created (n.b. database_subnets must also be set)"
  type        = bool
  default     = false
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}

##################################################################
###########  S3                                     ###########  
##################################################################


## s3 for logging cloudfront elastic load balancer
variable "logging_cloudfront_elb_bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = "logging-cloudfront-elb-terraform"
}

variable "logging_cloudfront_elb_force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = true
}

## s3 for logging cloudfront s3

variable "logging_cloudfront_s3_bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = "logging_cloudfront_s3_terraform"
}


variable "logging_cloudfront_s3_force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = true
}


##################################################################
########### CLOUDFRONT FOR ELASTIC LOAD BALANCER       ###########  
##################################################################

variable "cloudfront_elb_comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = "My awesome CloudFront made by TF"
}

variable "cloudfront_elb_enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}


variable "cloudfront_elb_is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = true
}

variable "cloudfront_elb_price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_All"
}


variable "cloudfront_elb_retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = false
}

variable "cloudfront_elb_wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = false
}


variable "cloudfront_elb_create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = false
}


variable "cloudfront_elb_prefix_logging_config" {
  description = "The prefix of logging config for cloudfront with elb"
  type        = string
  default     = "logging_cloudfront_elb"
}


variable "cloudfront_elb_custom_origin_config" {
  description = "The CloudFront custom origin configuration information"
  type        = any
  default     = 
  {
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "match-viewer"
    origin_ssl_protocols   = ["SSLv3"]
  }
}


variable "cloudfront_elb_default_cache_behavior_viewer_protocol_policy" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  type        = string
  default     = "allow-all"
}

// default cache behavior, cloudfront with elb

variable "cloudfront_elb_default_cache_behavior_allowed_methods" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cloudfront_elb_default_cache_behavior_cached_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
  default     = ["GET", "HEAD"]
}


variable "cloudfront_elb_default_cache_behavior_compress" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = bool
  default     = true
}


variable "cloudfront_elb_default_cache_behavior_query_string" {
  description = "Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior."
  type        = bool
  default     = true
}


// order cache behavior, cloudfront with elb

variable "cloudfront_elb_order_cache_behavior_viewer_protocol_policy" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  type        = string
  default     = "redirect-to-https"
}

variable "cloudfront_elb_order_cache_behavior_allowed_methods" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS", "PUT","POST", "PATCH", "DELETE"]
}

variable "cloudfront_elb_order_cache_behavior_cached_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
  default     = ["GET", "HEAD"]
}


variable "cloudfront_elb_order_cache_behavior_compress" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = bool
  default     = true
}


variable "cloudfront_elb_order_cache_behavior_query_string" {
  description = "Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior."
  type        = bool
  default     = true
}

// ssl support method, cloudfront with elastic load balancer

variable "cloudfront_elb_ssl_support_method" {
  description = "Specifies how you want CloudFront to serve HTTPS requests. One of vip or sni-only"
  type        = string
  default     = "sni-only"
}



##################################################################
########### CLOUDFRONT FOR S3                       ###########  
##################################################################



variable "cloudfront_s3_comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = "My awesome CloudFront with s3 made by TF"
}

variable "cloudfront_s3_enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}


variable "cloudfront_s3_is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = true
}

variable "cloudfront_s3_price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_All"
}


variable "cloudfront_s3_retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = false
}

variable "cloudfront_s3_wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = false
}


variable "cloudfront_s3_create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = true
}


variable "cloudfront_s3_prefix_logging_config" {
  description = "The prefix of logging config for cloudfront with elb"
  type        = string
  default     = "logging_cloudfront_elb"
}


// default cache behavior, cloudfront with s3

variable "cloudfront_s3_default_cache_behavior_allowed_methods" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cloudfront_s3_default_cache_behavior_cached_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
  default     = ["GET", "HEAD"]
}


variable "cloudfront_s3_default_cache_behavior_compress" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = bool
  default     = true
}


variable "cloudfront_s3_default_cache_behavior_query_string" {
  description = "Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior."
  type        = bool
  default     = true
}
