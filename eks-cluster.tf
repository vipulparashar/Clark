#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "iam-clark-clu" {
  name = "eks-clark-iam-clu"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "iam-clark-clu-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.iam-clark-clu.name}"
}

resource "aws_iam_role_policy_attachment" "iam-clark-clu-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.iam-clark-clu.name}"
}

resource "aws_security_group" "sg-clark-clu" {
  name        = "eks-clark-sg-clu"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.kube-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "eks-clark-clu-egress"
  }
}


resource "aws_security_group_rule" "eks-clark-clu-ingress-workstation-https" {
  cidr_blocks       = "${var.local-workstation}"
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg-clark-clu.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks-clark-clu" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.iam-clark-clu.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.sg-clark-clu.id}"]
    subnet_ids         = ["${aws_subnet.subnet-clark.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.iam-clark-clu-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.iam-clark-clu-AmazonEKSServicePolicy",
  ]
}

