# Terraform demo

This was originally based on examples found at [An Introduction to Terraform](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180#.eo54nuvuj). I took it and updated parts of it for use with EC2-VPC.

# Usage
```
$ tf init -backend-config="region=<region>" \
 -backend-config="bucket=<bucket name>" \
 -backend-config="key=<path/to/file.tfstate>"
```
