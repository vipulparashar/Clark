#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "kube-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "eks-clark-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "subnet-clark" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/25"
  vpc_id            = "${aws_vpc.kube-vpc.id}"

  tags = "${
    map(
     "Name", "eks-clark-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "ig-clark" {
  vpc_id = "${aws_vpc.kube-vpc.id}"

  tags {
    Name = "eks-clark-ig"
  }
}

resource "aws_route_table" "route-clark" {
  vpc_id = "${aws_vpc.kube-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig-clark.id}"
  }
}

resource "aws_route_table_association" "route_association-clark" {
  count = 2

  subnet_id      = "${aws_subnet.subnet-clark.*.id[count.index]}"
  route_table_id = "${aws_route_table.route-clark.id}"
}

