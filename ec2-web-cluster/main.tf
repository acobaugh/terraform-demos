provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "main" {
  cidr_block = "172.45.0.0/16"

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

resource "aws_subnet" "primary" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.45.1.0/24"
  availability_zone = "${data.aws_availability_zones.all.names[0]}"

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

resource "aws_subnet" "secondary" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.45.2.0/24"
  availability_zone = "${data.aws_availability_zones.all.names[1]}"

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

resource "aws_route_table_association" "primary" {
  subnet_id      = "${aws_subnet.primary.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_route_table_association" "secondary" {
  subnet_id      = "${aws_subnet.secondary.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  vpc_zone_identifier  = ["${aws_subnet.primary.id}", "${aws_subnet.secondary.id}"]

  min_size = 2
  max_size = 10

  target_group_arns = ["${aws_alb_target_group.example.arn}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = "${var.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = true
    propagate_at_launch = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAUNCH CONFIGURATION THAT DEFINES EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "example" {
  name = "${var.name}-launchconfig"
  image_id        = "${lookup(var.amis, var.region)}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World, this is $(hostname), $(uname -a)" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name   = "${var.name}"
  vpc_id = "${aws_vpc.main.id}"

  # Inbound HTTP from anywhere
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ELB TO ROUTE TRAFFIC ACROSS THE AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb" "example" {
  name            = "${var.name}-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.primary.id}", "${aws_subnet.secondary.id}"]

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

resource "aws_alb_target_group" "example" {
  name     = "${var.name}-alb-tg"
  port     = "${var.server_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path = "/"
  }

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}

resource "aws_alb_listener" "example" {
  load_balancer_arn = "${aws_alb.example.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.example.arn}"
    type             = "forward"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC AN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name   = "${var.name}-alb-sg"
  vpc_id = "${aws_vpc.main.id}"

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.name}"
    Env       = "${var.env}"
    Terraform = true
  }
}
