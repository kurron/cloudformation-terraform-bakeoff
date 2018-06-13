output "vpc_id" {
    value = "${aws_vpc.main.id}"
    description = "ID of the generated VPC"
}

output "cidr" {
    value = "${aws_vpc.main.cidr_block}"
    description = "The VPC's network range expressed in CIDR notation"
}

output "main_route_table_id" {
    value = "${aws_vpc.main.main_route_table_id}"
    description = "ID of the VPC's main route table"
}

output "default_network_acl_id" {
    value = "${aws_vpc.main.default_network_acl_id}"
    description = "ID of the VPC's default network ACL"
}

output "default_security_group_id" {
    value = "${aws_vpc.main.default_security_group_id}"
    description = "ID of the VPC's default security group"
}

output "default_route_table_id" {
    value = "${aws_vpc.main.default_route_table_id}"
    description = "ID of the VPC's default route table"
}

output "public_subnet_ids" {
    value = ["${aws_subnet.public.*.id}"]
    description = "IDs of the VPC's public subnets"
}

output "private_subnet_ids" {
    value = ["${aws_subnet.private.*.id}"]
    description = "IDs of the VPC's private subnets"
}

output "availability_zones" {
    value = ["${aws_subnet.public.*.availability_zone}"]
    description = "AZs the VPC has subnets in"
}
