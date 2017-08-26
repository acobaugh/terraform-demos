# Terraform demo

This was originally based on examples found at [An Introduction to
Terraform](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180#.eo54nuvuj).
I took it and updated parts of it for use with EC2-VPC.

There is currently one example:
* ec2-web-cluster - creates a VPC, subnets in that VPC, ec2 AMI instances running a simple web server serving static html, in an autoscaling group, behind an ALB with cookie-based persistence.

# Note
I am still learning and experimenting with terraform and the multitude of best
practices for project and directory layout. This will likely evolve over time.
Feel free to provide feedback and suggestions. I want to keep this simple to
make it easy to reduce the number of concepts one is exposed to in order to
maximize understanding of terraform itself.

# Usage
## Optional
Initialize remote state using S3 backend. Partial config is used to avoid
storing secrets in remote.tf. 

If you do not want to use remote state, simply change or rename remote.tf.

```console
$ cd ec2-web-cluster/
$ terraform init -backend-config="region=<region>" \
 -backend-config="bucket=<bucket name>" \
 -backend-config="key=<path/to/file.tfstate>"
```

## Plan
Plan introspects current state of the resources defined in \*.tf and comes up
with a "plan" to bring reality in line with configuration

Note that your plan output may be different. Play around with the settings in vars.tf if you want to change region, AMIs used, etc.

```console
$ terraform plan -no-color
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.aws_availability_zones.all: Refreshing state...
The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

+ aws_security_group.alb
      description:                           "Managed by Terraform"
      egress.#:                              "1"
      egress.482069346.cidr_blocks.#:        "1"
      egress.482069346.cidr_blocks.0:        "0.0.0.0/0"
      egress.482069346.from_port:            "0"
      egress.482069346.ipv6_cidr_blocks.#:   "0"
      egress.482069346.prefix_list_ids.#:    "0"
      egress.482069346.protocol:             "-1"
      egress.482069346.security_groups.#:    "0"
      egress.482069346.self:                 "false"
      egress.482069346.to_port:              "0"
      ingress.#:                             "1"
      ingress.2214680975.cidr_blocks.#:      "1"
      ingress.2214680975.cidr_blocks.0:      "0.0.0.0/0"
      ingress.2214680975.from_port:          "80"
      ingress.2214680975.ipv6_cidr_blocks.#: "0"
      ingress.2214680975.protocol:           "tcp"
      ingress.2214680975.security_groups.#:  "0"
      ingress.2214680975.self:               "false"
      ingress.2214680975.to_port:            "80"
      name:                                  "tf-ec2-cluster-demo-alb-sg"
      owner_id:                              "<computed>"
      tags.%:                                "3"
      tags.Env:                              "demo"
      tags.Name:                             "tf-ec2-cluster-demo"
      tags.Terraform:                        "1"
      vpc_id:                                "${aws_vpc.main.id}"

  + aws_alb.example
      arn:                        "<computed>"
      arn_suffix:                 "<computed>"
      dns_name:                   "<computed>"
      enable_deletion_protection: "false"
      idle_timeout:               "60"
      internal:                   "false"
      ip_address_type:            "<computed>"
      name:                       "tf-ec2-cluster-demo-alb"
      security_groups.#:          "<computed>"
      subnets.#:                  "<computed>"
      tags.%:                     "3"
      tags.Env:                   "demo"
      tags.Name:                  "tf-ec2-cluster-demo"
      tags.Terraform:             "1"
      vpc_id:                     "<computed>"
      zone_id:                    "<computed>"

  + aws_alb_listener.example
      arn:                               "<computed>"
      default_action.#:                  "1"
      default_action.0.target_group_arn: "${aws_alb_target_group.example.arn}"
      default_action.0.type:             "forward"
      load_balancer_arn:                 "${aws_alb.example.arn}"
      port:                              "80"
      protocol:                          "HTTP"
      ssl_policy:                        "<computed>"

  + aws_alb_target_group.example
      arn:                                "<computed>"
      arn_suffix:                         "<computed>"
      deregistration_delay:               "300"
      health_check.#:                     "1"
      health_check.0.healthy_threshold:   "5"
      health_check.0.interval:            "30"
      health_check.0.matcher:             "200"
      health_check.0.path:                "/"
      health_check.0.port:                "traffic-port"
      health_check.0.protocol:            "HTTP"
      health_check.0.timeout:             "5"
      health_check.0.unhealthy_threshold: "2"
      name:                               "tf-ec2-cluster-demo-alb-tg"
      port:                               "8080"
      protocol:                           "HTTP"
      stickiness.#:                       "1"
      stickiness.0.cookie_duration:       "86400"
      stickiness.0.enabled:               "true"
      stickiness.0.type:                  "lb_cookie"
      tags.%:                             "3"
      tags.Env:                           "demo"
      tags.Name:                          "tf-ec2-cluster-demo"
      tags.Terraform:                     "1"
      vpc_id:                             "${aws_vpc.main.id}"

  + aws_autoscaling_group.example
      arn:                                "<computed>"
      availability_zones.#:               "<computed>"
      default_cooldown:                   "<computed>"
      desired_capacity:                   "<computed>"
      force_delete:                       "false"
      health_check_grace_period:          "300"
      health_check_type:                  "<computed>"
      launch_configuration:               "${aws_launch_configuration.example.id}"
      load_balancers.#:                   "<computed>"
      max_size:                           "10"
      metrics_granularity:                "1Minute"
      min_size:                           "2"
      name:                               "<computed>"
      protect_from_scale_in:              "false"
      tag.#:                              "3"
      tag.2346415513.key:                 "Terraform"
      tag.2346415513.propagate_at_launch: "true"
      tag.2346415513.value:               "1"
      tag.3877267498.key:                 "Env"
      tag.3877267498.propagate_at_launch: "true"
      tag.3877267498.value:               "demo"
      tag.3919096830.key:                 "Name"
      tag.3919096830.propagate_at_launch: "true"
      tag.3919096830.value:               "tf-ec2-cluster-demo"
      target_group_arns.#:                "<computed>"
      vpc_zone_identifier.#:              "<computed>"
      wait_for_capacity_timeout:          "10m"

  + aws_launch_configuration.example
      associate_public_ip_address: "false"
      ebs_block_device.#:          "<computed>"
      ebs_optimized:               "<computed>"
      enable_monitoring:           "true"
      image_id:                    "ami-7b4d7900"
      instance_type:               "t2.micro"
      key_name:                    "<computed>"
      name:                        "tf-ec2-cluster-demo-launchconfig"
      root_block_device.#:         "<computed>"
      security_groups.#:           "<computed>"
      user_data:                   "6734ba54a4e4612bf7f5ac3859bbf69582a2634a"

  + aws_internet_gateway.gw
      tags.%:         "3"
      tags.Env:       "demo"
      tags.Name:      "tf-ec2-cluster-demo"
      tags.Terraform: "1"
      vpc_id:         "${aws_vpc.main.id}"

  + aws_vpc.main
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "172.45.0.0/16"
      default_network_acl_id:           "<computed>"
      default_route_table_id:           "<computed>"
      default_security_group_id:        "<computed>"
      dhcp_options_id:                  "<computed>"
      enable_classiclink:               "<computed>"
      enable_classiclink_dns_support:   "<computed>"
      enable_dns_hostnames:             "<computed>"
      enable_dns_support:               "true"
      instance_tenancy:                 "<computed>"
      ipv6_association_id:              "<computed>"
      ipv6_cidr_block:                  "<computed>"
      main_route_table_id:              "<computed>"
      tags.%:                           "3"
      tags.Env:                         "demo"
      tags.Name:                        "tf-ec2-cluster-demo"
      tags.Terraform:                   "1"

  + aws_route_table_association.primary
      route_table_id: "${aws_route_table.rt.id}"
      subnet_id:      "${aws_subnet.primary.id}"

  + aws_subnet.primary
      assign_ipv6_address_on_creation: "false"
      availability_zone:               "us-east-1a"
      cidr_block:                      "172.45.1.0/24"
      ipv6_cidr_block:                 "<computed>"
      ipv6_cidr_block_association_id:  "<computed>"
      map_public_ip_on_launch:         "false"
      tags.%:                          "3"
      tags.Env:                        "demo"
      tags.Name:                       "tf-ec2-cluster-demo"
      tags.Terraform:                  "1"
      vpc_id:                          "${aws_vpc.main.id}"

  + aws_route_table.rt
      propagating_vgws.#:                          "<computed>"
      route.#:                                     "1"
      route.~2599208424.cidr_block:                "0.0.0.0/0"
      route.~2599208424.egress_only_gateway_id:    ""
      route.~2599208424.gateway_id:                "${aws_internet_gateway.gw.id}"
      route.~2599208424.instance_id:               ""
      route.~2599208424.ipv6_cidr_block:           ""
      route.~2599208424.nat_gateway_id:            ""
      route.~2599208424.network_interface_id:      ""
      route.~2599208424.vpc_peering_connection_id: ""
      tags.%:                                      "3"
      tags.Env:                                    "demo"
      tags.Name:                                   "tf-ec2-cluster-demo"
      tags.Terraform:                              "1"
      vpc_id:                                      "${aws_vpc.main.id}"

  + aws_route_table_association.secondary
      route_table_id: "${aws_route_table.rt.id}"
      subnet_id:      "${aws_subnet.secondary.id}"

  + aws_security_group.instance
      description:                          "Managed by Terraform"
      egress.#:                             "<computed>"
      ingress.#:                            "1"
      ingress.516175195.cidr_blocks.#:      "1"
      ingress.516175195.cidr_blocks.0:      "0.0.0.0/0"
      ingress.516175195.from_port:          "8080"
      ingress.516175195.ipv6_cidr_blocks.#: "0"
      ingress.516175195.protocol:           "tcp"
      ingress.516175195.security_groups.#:  "0"
      ingress.516175195.self:               "false"
      ingress.516175195.to_port:            "8080"
      name:                                 "tf-ec2-cluster-demo"
      owner_id:                             "<computed>"
      tags.%:                               "3"
      tags.Env:                             "demo"
      tags.Name:                            "tf-ec2-cluster-demo"
      tags.Terraform:                       "1"
      vpc_id:                               "${aws_vpc.main.id}"

  + aws_subnet.secondary
      assign_ipv6_address_on_creation: "false"
      availability_zone:               "us-east-1b"
      cidr_block:                      "172.45.2.0/24"
      ipv6_cidr_block:                 "<computed>"
      ipv6_cidr_block_association_id:  "<computed>"
      map_public_ip_on_launch:         "false"
      tags.%:                          "3"
      tags.Env:                        "demo"
      tags.Name:                       "tf-ec2-cluster-demo"
      tags.Terraform:                  "1"
      vpc_id:                          "${aws_vpc.main.id}"
Plan: 14 to add, 0 to change, 0 to destroy.
```

## Apply

```console
$ terraform apply
data.aws_availability_zones.all: Refreshing state...
aws_vpc.main: Creating...
  assign_generated_ipv6_cidr_block: "" => "false"
  cidr_block:                       "" => "172.45.0.0/16"
  default_network_acl_id:           "" => "<computed>"
  default_route_table_id:           "" => "<computed>"
  default_security_group_id:        "" => "<computed>"
  dhcp_options_id:                  "" => "<computed>"
  enable_classiclink:               "" => "<computed>"
  enable_classiclink_dns_support:   "" => "<computed>"
  enable_dns_hostnames:             "" => "<computed>"
  enable_dns_support:               "" => "true"
  instance_tenancy:                 "" => "<computed>"
  ipv6_association_id:              "" => "<computed>"
  ipv6_cidr_block:                  "" => "<computed>"
  main_route_table_id:              "" => "<computed>"
  tags.%:                           "" => "3"
  tags.Env:                         "" => "demo"
  tags.Name:                        "" => "tf-ec2-cluster-demo"
  tags.Terraform:                   "" => "1"
aws_vpc.main: Creation complete (ID: vpc-dbac83a2)
aws_internet_gateway.gw: Creating...
  tags.%:         "0" => "3"
  tags.Env:       "" => "demo"
  tags.Name:      "" => "tf-ec2-cluster-demo"
  tags.Terraform: "" => "1"
  vpc_id:         "" => "vpc-dbac83a2"
aws_subnet.secondary: Creating...
  assign_ipv6_address_on_creation: "" => "false"
  availability_zone:               "" => "us-east-1b"
  cidr_block:                      "" => "172.45.2.0/24"
  ipv6_cidr_block:                 "" => "<computed>"
  ipv6_cidr_block_association_id:  "" => "<computed>"
  map_public_ip_on_launch:         "" => "false"
  tags.%:                          "" => "3"
  tags.Env:                        "" => "demo"
  tags.Name:                       "" => "tf-ec2-cluster-demo"
  tags.Terraform:                  "" => "1"
  vpc_id:                          "" => "vpc-dbac83a2"
aws_subnet.primary: Creating...
  assign_ipv6_address_on_creation: "" => "false"
  availability_zone:               "" => "us-east-1a"
  cidr_block:                      "" => "172.45.1.0/24"
  ipv6_cidr_block:                 "" => "<computed>"
  ipv6_cidr_block_association_id:  "" => "<computed>"
  map_public_ip_on_launch:         "" => "false"
  tags.%:                          "" => "3"
  tags.Env:                        "" => "demo"
  tags.Name:                       "" => "tf-ec2-cluster-demo"
  tags.Terraform:                  "" => "1"
  vpc_id:                          "" => "vpc-dbac83a2"
aws_security_group.instance: Creating...
  description:                          "" => "Managed by Terraform"
  egress.#:                             "" => "<computed>"
  ingress.#:                            "" => "1"
  ingress.516175195.cidr_blocks.#:      "" => "1"
  ingress.516175195.cidr_blocks.0:      "" => "0.0.0.0/0"
  ingress.516175195.from_port:          "" => "8080"
  ingress.516175195.ipv6_cidr_blocks.#: "" => "0"
  ingress.516175195.protocol:           "" => "tcp"
  ingress.516175195.security_groups.#:  "" => "0"
  ingress.516175195.self:               "" => "false"
  ingress.516175195.to_port:            "" => "8080"
  name:                                 "" => "tf-ec2-cluster-demo"
  owner_id:                             "" => "<computed>"
  tags.%:                               "" => "3"
  tags.Env:                             "" => "demo"
  tags.Name:                            "" => "tf-ec2-cluster-demo"
  tags.Terraform:                       "" => "1"
  vpc_id:                               "" => "vpc-dbac83a2"
aws_alb_target_group.example: Creating...
  arn:                                "" => "<computed>"
  arn_suffix:                         "" => "<computed>"
  deregistration_delay:               "" => "300"
  health_check.#:                     "" => "1"
  health_check.0.healthy_threshold:   "" => "5"
  health_check.0.interval:            "" => "30"
  health_check.0.matcher:             "" => "200"
  health_check.0.path:                "" => "/"
  health_check.0.port:                "" => "traffic-port"
  health_check.0.protocol:            "" => "HTTP"
  health_check.0.timeout:             "" => "5"
  health_check.0.unhealthy_threshold: "" => "2"
  name:                               "" => "tf-ec2-cluster-demo-alb-tg"
  port:                               "" => "8080"
  protocol:                           "" => "HTTP"
  stickiness.#:                       "" => "1"
  stickiness.0.cookie_duration:       "" => "86400"
  stickiness.0.enabled:               "" => "true"
  stickiness.0.type:                  "" => "lb_cookie"
  tags.%:                             "" => "3"
  tags.Env:                           "" => "demo"
  tags.Name:                          "" => "tf-ec2-cluster-demo"
  tags.Terraform:                     "" => "1"
  vpc_id:                             "" => "vpc-dbac83a2"
aws_security_group.alb: Creating...
  description:                           "" => "Managed by Terraform"
  egress.#:                              "" => "1"
  egress.482069346.cidr_blocks.#:        "" => "1"
  egress.482069346.cidr_blocks.0:        "" => "0.0.0.0/0"
  egress.482069346.from_port:            "" => "0"
  egress.482069346.ipv6_cidr_blocks.#:   "" => "0"
  egress.482069346.prefix_list_ids.#:    "" => "0"
  egress.482069346.protocol:             "" => "-1"
  egress.482069346.security_groups.#:    "" => "0"
  egress.482069346.self:                 "" => "false"
  egress.482069346.to_port:              "" => "0"
  ingress.#:                             "" => "1"
  ingress.2214680975.cidr_blocks.#:      "" => "1"
  ingress.2214680975.cidr_blocks.0:      "" => "0.0.0.0/0"
  ingress.2214680975.from_port:          "" => "80"
  ingress.2214680975.ipv6_cidr_blocks.#: "" => "0"
  ingress.2214680975.protocol:           "" => "tcp"
  ingress.2214680975.security_groups.#:  "" => "0"
  ingress.2214680975.self:               "" => "false"
  ingress.2214680975.to_port:            "" => "80"
  name:                                  "" => "tf-ec2-cluster-demo-alb-sg"
  owner_id:                              "" => "<computed>"
  tags.%:                                "" => "3"
  tags.Env:                              "" => "demo"
  tags.Name:                             "" => "tf-ec2-cluster-demo"
  tags.Terraform:                        "" => "1"
  vpc_id:                                "" => "vpc-dbac83a2"
aws_internet_gateway.gw: Creation complete (ID: igw-f56b6593)
aws_route_table.rt: Creating...
  propagating_vgws.#:                       "" => "<computed>"
  route.#:                                  "" => "1"
  route.95846927.cidr_block:                "" => "0.0.0.0/0"
  route.95846927.egress_only_gateway_id:    "" => ""
  route.95846927.gateway_id:                "" => "igw-f56b6593"
  route.95846927.instance_id:               "" => ""
  route.95846927.ipv6_cidr_block:           "" => ""
  route.95846927.nat_gateway_id:            "" => ""
  route.95846927.network_interface_id:      "" => ""
  route.95846927.vpc_peering_connection_id: "" => ""
  tags.%:                                   "" => "3"
  tags.Env:                                 "" => "demo"
  tags.Name:                                "" => "tf-ec2-cluster-demo"
  tags.Terraform:                           "" => "1"
  vpc_id:                                   "" => "vpc-dbac83a2"
aws_subnet.primary: Creation complete (ID: subnet-a698d1fc)
aws_subnet.secondary: Creation complete (ID: subnet-6061a804)
aws_route_table.rt: Creation complete (ID: rtb-013df57a)
aws_route_table_association.secondary: Creating...
  route_table_id: "" => "rtb-013df57a"
  subnet_id:      "" => "subnet-6061a804"
aws_route_table_association.primary: Creating...
  route_table_id: "" => "rtb-013df57a"
  subnet_id:      "" => "subnet-a698d1fc"
aws_alb_target_group.example: Creation complete (ID: arn:aws:elasticloadbalancing:us-east-1:...2-cluster-demo-alb-tg/3593d6c13a4d3a30)
aws_route_table_association.secondary: Creation complete (ID: rtbassoc-bb6602c1)
aws_security_group.alb: Creation complete (ID: sg-42503032)
aws_alb.example: Creating...
  arn:                        "" => "<computed>"
  arn_suffix:                 "" => "<computed>"
  dns_name:                   "" => "<computed>"
  enable_deletion_protection: "" => "false"
  idle_timeout:               "" => "60"
  internal:                   "" => "false"
  ip_address_type:            "" => "<computed>"
  name:                       "" => "tf-ec2-cluster-demo-alb"
  security_groups.#:          "" => "1"
  security_groups.2103885544: "" => "sg-42503032"
  subnets.#:                  "" => "2"
  subnets.1591650387:         "" => "subnet-6061a804"
  subnets.3209314858:         "" => "subnet-a698d1fc"
  tags.%:                     "" => "3"
  tags.Env:                   "" => "demo"
  tags.Name:                  "" => "tf-ec2-cluster-demo"
  tags.Terraform:             "" => "1"
  vpc_id:                     "" => "<computed>"
  zone_id:                    "" => "<computed>"
aws_route_table_association.primary: Creation complete (ID: rtbassoc-8b6206f1)
aws_security_group.instance: Creation complete (ID: sg-084d2d78)
aws_launch_configuration.example: Creating...
  associate_public_ip_address: "" => "false"
  ebs_block_device.#:          "" => "<computed>"
  ebs_optimized:               "" => "<computed>"
  enable_monitoring:           "" => "true"
  image_id:                    "" => "ami-7b4d7900"
  instance_type:               "" => "t2.micro"
  key_name:                    "" => "<computed>"
  name:                        "" => "tf-ec2-cluster-demo-launchconfig"
  root_block_device.#:         "" => "<computed>"
  security_groups.#:           "" => "1"
  security_groups.203659489:   "" => "sg-084d2d78"
  user_data:                   "" => "6734ba54a4e4612bf7f5ac3859bbf69582a2634a"
aws_launch_configuration.example: Creation complete (ID: tf-ec2-cluster-demo-launchconfig)
aws_autoscaling_group.example: Creating...
  arn:                                "" => "<computed>"
  default_cooldown:                   "" => "<computed>"
  desired_capacity:                   "" => "<computed>"
  force_delete:                       "" => "false"
  health_check_grace_period:          "" => "300"
  health_check_type:                  "" => "<computed>"
  launch_configuration:               "" => "tf-ec2-cluster-demo-launchconfig"
  load_balancers.#:                   "" => "<computed>"
  max_size:                           "" => "10"
  metrics_granularity:                "" => "1Minute"
  min_size:                           "" => "2"
  name:                               "" => "<computed>"
  protect_from_scale_in:              "" => "false"
  tag.#:                              "" => "3"
  tag.2346415513.key:                 "" => "Terraform"
  tag.2346415513.propagate_at_launch: "" => "true"
  tag.2346415513.value:               "" => "1"
  tag.3877267498.key:                 "" => "Env"
  tag.3877267498.propagate_at_launch: "" => "true"
  tag.3877267498.value:               "" => "demo"
  tag.3919096830.key:                 "" => "Name"
  tag.3919096830.propagate_at_launch: "" => "true"
  tag.3919096830.value:               "" => "tf-ec2-cluster-demo"
  target_group_arns.#:                "" => "1"
  target_group_arns.4128248536:       "" => "arn:aws:elasticloadbalancing:us-east-1:172401002233:targetgroup/tf-ec2-cluster-demo-alb-tg/3593d6c13a4d3a30"
  vpc_zone_identifier.#:              "" => "2"
  vpc_zone_identifier.1591650387:     "" => "subnet-6061a804"
  vpc_zone_identifier.3209314858:     "" => "subnet-a698d1fc"
  wait_for_capacity_timeout:          "" => "10m"
aws_alb.example: Still creating... (10s elapsed)
aws_autoscaling_group.example: Still creating... (10s elapsed)
aws_alb.example: Still creating... (20s elapsed)
aws_autoscaling_group.example: Still creating... (20s elapsed)
aws_alb.example: Still creating... (30s elapsed)
aws_autoscaling_group.example: Still creating... (30s elapsed)
aws_alb.example: Still creating... (40s elapsed)
aws_autoscaling_group.example: Still creating... (40s elapsed)
aws_alb.example: Still creating... (50s elapsed)
aws_autoscaling_group.example: Still creating... (50s elapsed)
aws_alb.example: Still creating... (1m0s elapsed)
aws_autoscaling_group.example: Still creating... (1m0s elapsed)
aws_alb.example: Still creating... (1m10s elapsed)
aws_autoscaling_group.example: Still creating... (1m10s elapsed)
aws_alb.example: Still creating... (1m20s elapsed)
aws_autoscaling_group.example: Still creating... (1m20s elapsed)
aws_autoscaling_group.example: Creation complete (ID: tf-asg-00e82d7befb62a37d74badff59)
aws_alb.example: Still creating... (1m30s elapsed)
aws_alb.example: Still creating... (1m40s elapsed)
aws_alb.example: Still creating... (1m50s elapsed)
aws_alb.example: Still creating... (2m0s elapsed)
aws_alb.example: Still creating... (2m10s elapsed)
aws_alb.example: Creation complete (ID: arn:aws:elasticloadbalancing:us-east-1:...-ec2-cluster-demo-alb/aeb16e6585df4d1b)
aws_alb_listener.example: Creating...
  arn:                               "" => "<computed>"
  default_action.#:                  "" => "1"
  default_action.0.target_group_arn: "" => "arn:aws:elasticloadbalancing:us-east-1:172401002233:targetgroup/tf-ec2-cluster-demo-alb-tg/3593d6c13a4d3a30"
  default_action.0.type:             "" => "forward"
  load_balancer_arn:                 "" => "arn:aws:elasticloadbalancing:us-east-1:172401002233:loadbalancer/app/tf-ec2-cluster-demo-alb/aeb16e6585df4d1b"
  port:                              "" => "80"
  protocol:                          "" => "HTTP"
  ssl_policy:                        "" => "<computed>"
aws_alb_listener.example: Creation complete (ID: arn:aws:elasticloadbalancing:us-east-1:...-alb/aeb16e6585df4d1b/c516361b8a545077)

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = tf-ec2-cluster-demo-alb-1506319064.us-east-1.elb.amazonaws.com
```

## Destroy

```console
$ terraform destroy -force

```
