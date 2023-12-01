locals {
name = "ET2KPUA"
priv_sub01 = "subnet-08620843bd7f445ff"
priv_sub02 = "subnet-031f5fc4f0b813b64"
priv_sub03 = "subnet-0b7bb7032ddbd4e69"
pub_sub01 = "subnet-037cc2d4f1a11cd23"
pub_sub02 = "subnet-07dba2d1be0c17af6"
pub_sub03 = "subnet-016fba6bd8145ec6b"
vpc_id = "vpc-07686c02b0a7559f4"
}

data "aws_vpc" "vpc" {
  id = local.vpc_id
}
data "aws_subnet" "pubsub01" {
  id = local.pub_sub01
}
data "aws_subnet" "pubsub02" {
  id = local.pub_sub02
}
data "aws_subnet" "pubsub03" {
  id = local.pub_sub03
}
data "aws_subnet" "prvtsub01" {
  id = local.priv_sub01
}
data "aws_subnet" "prvtsub02" {
  id = local.priv_sub02
}
data "aws_subnet" "prvtsub03" {
  id = local.priv_sub03
}

module "worker-nodes" {
  source           = "./module/worker-nodes"
  instance-count   = 3
  ami              = "ami-00983e8a26e4c9bd9"
  instance_type    = "t2.medium"
  subnet_id        = [data.aws_subnet.prvtsub01.id, data.aws_subnet.prvtsub02.id, data.aws_subnet.prvtsub03.id]
  security_groups  = [module.sg-keypair.kube-nodes-sg]
  key_name         = module.sg-keypair.key-id
  tag-worker-nodes = "${local.name}-workernodes"
}

module "master-nodes" {
  source           = "./module/master-nodes"
  instance-count   = 3
  ami              = "ami-00983e8a26e4c9bd9"
  instance_type    = "t2.medium"
  subnet_id        = [data.aws_subnet.prvtsub01.id, data.aws_subnet.prvtsub02.id, data.aws_subnet.prvtsub03.id]
  security_groups  = [module.sg-keypair.kube-nodes-sg]
  key_name         = module.sg-keypair.key-id
  tag-master-nodes = "${local.name}-masternodes"
}

module "ansible" {
  source = "./module/ansible"
  ami    = "ami-00983e8a26e4c9bd9"
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.pubsub02.id
  security_groups = [module.sg-keypair.ansible-sg]
  key_name = module.sg-keypair.key-id
  tag-ansible-server = "${local.name}-ansible"
  priv-key           = module.vpc.private-key
  HAproxy1-IP        = module.HAProxy1.HAProxy1-ip
  HAproxy2-IP        = module.HAProxy1.HAProxy1-backup-ip
  master1-IP         = module.master-nodes.master-nodes-ip[0]
  master2-IP         = module.master-nodes.master-nodes-ip[1]
  master3-IP         = module.master-nodes.master-nodes-ip[2]
  worker1-IP         = module.worker-nodes.worker-nodes-ip[0]
  worker2-IP         = module.worker-nodes.worker-nodes-ip[1]
  worker3-IP         = module.worker-nodes.worker-nodes-ip[2]
  bastion_host       = module.bastion.bastion-ip
}

module "haproxy" {
  source              = "./module/haproxy"
  ami                 = "ami-00983e8a26e4c9bd9"
  instance_type       = "t2.medium"
  security_group_ids  = module.sg-keypair.kube-nodes-sg
  subnet_id1          = data.aws_subnet.prvtsub02.id
  subnet_id2          = data.aws_subnet.prvtsub03.id
  key_name            = module.sg-keypair.key-id
  master1             = module.master-nodes.master-nodes-ip[0]
  master2             = module.master-nodes.master-nodes-ip[1]
  master3             = module.master-nodes.master-nodes-ip[2]
  tag-HAProxy1        = "${local.name}-haproxy1"
  tag-HAProxy1-backup = "${local.name}-haproxy2"
}

module "bastion" {
  source               = "./module/bastion"
  ami                  = "ami-00983e8a26e4c9bd9"
  instance_type        = "t2.micro"
  subnets              = data.aws_subnet.pubsub02.id
  bastion-sg           = module.sg-keypair.bastion-sg
  key_name             = module.sg-keypair.key-id
  tag-bastion          = "${local.name}-bastion"
  private_key          = module.sg-keypair.private-key
}

module "sg-keypair" {
  source           = "./module/sg-keypair"
  vpc_id           = data.aws_vpc.vpc.id
  kube-nodes-sg   = "${local.name}-k8s-sg"
  bastion-sg      = "${local.name}-bastion-sg"
  ansible-sg      = "${local.name}-ansible-sg"
}

module "route53-ssl" {
  source                 = "./module/route53-ssl"
  domain_name            = "sophieplace.com"
  domain_name1           = "stage.sophieplace.com"
  stage_lb_dns_name      = module.environment-lb.stage-alb-dns
  stage_lb_zoneid        = module.environment-lb.stage-alb-zone-id
  domain_name2           = "prod.sophieplace.com"
  prod_lb_dns_name       = module.environment-lb.prod-lb-dns
  prod_lb_zoneid         = module.environment-lb.prod-lb-zone-id
  domain-name3           = "grafana.sophieplace.com"
  grafana_lb_dns_name    = module.monitor-lb.grafana-dns-name
  grafana_lb_zoneid      = module.monitor-lb.grafana-zone-id
  domain-name4           = "prometheus.sophieplace.com"
  prometheus_lb_dns_name = module.monitor-lb.prometheus-dns-name
  prometheus_lb_zoneid   = module.monitor-lb.prometheus-zone-id
  alt-domain = "*.sophieplace.com"
}

module "monitor-lb" {
  source    = "./module/monitor-lb"
  subnet_id = [data.aws_subnet.pubsub01.id, data.aws_subnet.pubsub02.id, data.aws_subnet.pubsub03.id]
  vpc_id    = data.aws_vpc.vpc.id
  security_group = [module.sg-keypair.kube-nodes-sg]
  certificate_arn = module.route53-ssl.certificate_arn
  worker_node1 = module.worker-nodes.worker-nodes-id[0]
  worker_node2 = module.worker-nodes.worker-nodes-id[1]
  worker_node3 = module.worker-nodes.worker-nodes-id[2]
}

module "environment-lb" {
  source = "./module/environment-lb"
  vpc_id = data.aws_vpc.vpc.id
  subnet_id = [data.aws_subnet.pubsub01.id, data.aws_subnet.pubsub02.id, data.aws_subnet.pubsub03.id]
  tag-prod-alb = "${local.name}-prod-alb"
  certificate_arn = module.route53-ssl.certificate_arn
  security_group = [module.sg-keypair.kube-nodes-sg]
  tag-stage-alb = "${local.name}-stage-alb"
  worker_node1 = module.worker-nodes.worker-nodes-id[0]
  worker_node2 = module.worker-nodes.worker-nodes-id[1]
  worker_node3 = module.worker-nodes.worker-nodes-id[2]
}
