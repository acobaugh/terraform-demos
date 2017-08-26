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

...

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = tf-ec2-cluster-demo-alb-1506319064.us-east-1.elb.amazonaws.com
```

## Destroy

```console
$ terraform destroy -force

...

Destroy complete! Resources: 15 destroyed.
```
