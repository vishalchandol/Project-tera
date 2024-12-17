#!/bin/bash
# Update the package list and install httpd (Apache)
yum update -y
yum install -y httpd

# Create a simple index.html page
echo "hello I am server 1" > /var/www/html/index.html

# Start the httpd service and enable it to start on boot
systemctl start httpd
systemctl enable httpd

