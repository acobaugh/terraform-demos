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
## Set up environment

The simplest way to use this demo is to use an access key and secret in your environment (but there are other[1] ways).

Go here to learn more about AWS access keys and secrets. I highly recommend you do this for an IAM user and not your root account!

http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys

[1] https://www.terraform.io/docs/providers/aws/#authentication

```console
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"

```

## Region
If you do not wish to use us-east-1, change the value of the "region" variable in vars.tf.

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
