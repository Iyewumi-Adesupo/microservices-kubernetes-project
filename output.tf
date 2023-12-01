output "worker-nodes" {
  value = module.worker-nodes.*.worker-nodes-ip
}
output "HAProxy1-ip" {
  value = module.haproxy.HAProxy1-ip
}
output "HAProxy1-backup-ip" {
  value = module.haproxy.HAProxy1-backup-ip
}
output "master-nodes" {
  value = module.master-nodes.*.master-nodes-ip
}
output "bastion" {
  value = module.bastion.bastion-ip
}
output "ansible" {
  value = module.ansible.ansible-ip
}