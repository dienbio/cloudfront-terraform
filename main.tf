# take ami default of amazone
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}


data "aws_iam_policy_document" "iam_policy" {
  statement {
    actions   = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:*"
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }

  statement {
    actions   = [
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}"]
  }

  statement {
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}"]
  }
}

# --- S3 bucket ---

data "aws_iam_policy_document" "s3_policy_cf_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}


data "aws_s3_bucket" "bucket_test_cloudfront" {
  bucket = "spx.antientf.tk"
}

# ## Take cert issued from amazon
data "aws_acm_certificate" "demo_cert" {
  domain            =  var.acm_domain_name
  statuses          = ["ISSUED"]
}

#create vpc 3 public_subnets and 3 private subnet 
# create 1 nat gatway
module "vpc" {
  source = "./modules/vpc/"

  name                          = var.vpc_name
  cidr                          = var.vpc_cidr
  azs                           = var.vpc_azs
  private_subnets               = var.vpc_private_subnets
  public_subnets                = var.vpc_public_subnets
  database_subnets              = var.vpc_database_subnets
  create_database_subnet_group  = var.vpc_create_database_subnet_group
  enable_nat_gateway            = var.vpc_enable_nat_gateway
  single_nat_gateway            = var.vpc_single_nat_gateway
}


# generate sg(http, https, ssh) from module secirty group of aws
module "security_group_for_ec2" {
  source  = "./modules/sg"

  name                = var.sg_name
  description         = var.sg_description
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = var.sg_ingress_cidr_blocks
  ingress_rules       = var.sg_ingress_rules
  egress_rules        = var.sg_egress_rules
}

# create certificate for my domain
# module "acm" {
#   source  = "./modules/acm"

#   domain_name         = var.acm_domain_name
#   validation_method   = var.acm_validation_method
#   tags = var.tags_acm
# }

# module "security_group_for_rds" {
#   source  = "./modules/sg"

#   name                = "sgSPXDBSG1"
#   description         = "Security group for example usage with rds instance"
#   vpc_id              = module.vpc.vpc_id

#   ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
#   ingress_rules       = ["mssql-tcp"]
#   egress_rules        = ["all-all"]
# }

# # create key pair "mykey" upload file public to aws
module "key-pair" {
  source     = "./modules/key-pair/"

  key_name   = var.key_name
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# module "rds" {
#   source                          = "./modules/rds/"

#   identifier                      = var.identifier
#   engine                          = var.rds_engine
#   engine_version                  = var.rds_engine_version
#   instance_class                  = var.rds_instance_class
#   allocated_storage               = var.rds_allocated_storage
#   storage_encrypted               = var.rds_storage_encrypted
#   # name                            = var.rds_name
#   username                        = var.rds_username
#   password                        = var.rds_password
#   port                            = var.rds_port
#   vpc_security_group_ids          = [module.security_group_for_rds.this_security_group_id]

#   maintenance_window              = var.rds_maintenance_window
#   backup_window                   = var.rds_backup_window

#   multi_az                        = var.rds_multi_az
#   backup_retention_period         = var.rds_backup_retention_period # disable backups to create DB faster 

#   tags = {
#     Account                       = var.tags_account
#     Product                       = var.tags_product
#     Environment                   = var.tags_environment
#   }

#   subnet_ids                      = module.vpc.database_subnets # DB subnet group
#   license_model                   = "license-included"
#   family                          = var.rds_family # DB parameter group
#   major_engine_version            = var.rds_major_engine_version # DB option group
#   final_snapshot_identifier       = var.rds_final_snapshot_identifier # Snapshot name upon DB deletion
#   deletion_protection             = var.rds_deletion_protection  # Database Deletion Protection
# }

# create asg with min 4 max 4
module "asg" {
  source = "./modules/asg/"

  name                = var.asg_name
  lc_name             = var.asg_lc_name
  image_id            = data.aws_ami.amazon_linux.id
  instance_type       = var.instance_type
  key_name            = module.key-pair.this_key_pair_key_name
  user_data           = local.user_data
  security_groups     = [module.security_group_for_ec2.this_security_group_id]
  # Auto scaling group
  vpc_zone_identifier = module.vpc.public_subnets
  health_check_type   = var.asg_health_check_type
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  force_delete        = var.asg_force_delete
  target_group_arns   = module.alb.target_group_arns

  tags = var.tags_asg
}

module "alb" {
  source = "./modules/alb/"

  name                  = var.alb_name
  vpc_id                = module.vpc.vpc_id
  security_groups       = [module.security_group_for_ec2.this_security_group_id]
  subnets               = slice(module.vpc.public_subnets,0,3)

  http_tcp_listeners    = var.alb_http_tcp_listeners
  target_groups         = var.alb_target_groups
  tags = {
    Name                = var.tags_name
    Account             = var.tags_account
    Product             = var.tags_product
    Environment         = var.tags_environment
  }
}

module "logging_cloudfront_elb" {
  source        = "./modules/s3"

  bucket        = var.logging_cloudfront_elb_bucket
  force_destroy = var.logging_cloudfront_elb_force_destroy
}

module "cloudfront_elb" {
  source = "./modules/cf/"

  aliases = ["appsync.antientf.tk"]
 
  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = false

  logging_config = {
    bucket = module.logging_cloudfront_elb.this_s3_bucket_bucket_domain_name
    prefix = "logging_cloudfront_elb"
  }

  origin = {
    appsync = {
      domain_name =  module.alb.this_lb_dns_name
      origin_id   = trimsuffix(module.alb.this_lb_dns_name, ".us-east-1.elb.amazonaws.com")
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["SSLv3"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = trimsuffix(module.alb.this_lb_dns_name, ".us-east-1.elb.amazonaws.com")
    viewer_protocol_policy = "allow-all"
    
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/content/*"
      target_origin_id       = trimsuffix(module.alb.this_lb_dns_name, ".us-east-1.elb.amazonaws.com")
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT","POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]

  viewer_certificate = {
    acm_certificate_arn = data.aws_acm_certificate.demo_cert.arn
    ssl_support_method  = "sni-only"
  }
}

module "logging_cloudfront_s3" {
  source        = "./modules/s3"

  bucket        = var.logging_cloudfront_s3_bucket
  force_destroy = var.logging_cloudfront_s3_force_destroy
}


module "cloudfront-s3" {
  source = "./modules/cf/"

  # aliases = ["${local.subdomain}.${local.domain_name}"]
  aliases = ["cdn.antientf.tk"]


  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
  }

  logging_config = {
    bucket = module.logging_cloudfront_s3.this_s3_bucket_bucket_domain_name
    prefix = "logging_cloudfront-s3"
  }

  origin = {
    appsync = {
      domain_name = data.aws_s3_bucket.bucket_test_cloudfront.bucket_domain_name
      origin_id   = trimsuffix(data.aws_s3_bucket.bucket_test_cloudfront.bucket_domain_name, ".s3.amazonaws.com")
      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
        cloudfront_access_identity_path = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = trimsuffix(data.aws_s3_bucket.bucket_test_cloudfront.bucket_domain_name, ".s3.amazonaws.com")
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  viewer_certificate = {
    acm_certificate_arn = data.aws_acm_certificate.demo_cert.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.bucket_name}"
}


resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_policy_cf_bucket.json
}
