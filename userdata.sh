#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo '<!doctype html><html><head><title>Welcome to Terraform</title></head><body><h1>Let's get it starting</h1></body></html>' > /var/www/html/index.html
