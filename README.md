<h1 align="center" id="title">Microservices Kubernetes Project</h1>
<p id="description">Kubernetes is an orchestrating and containerised application managing tools which can be  used on on-premise server or across hybrid cloud environments. Kubeadm is a tool provided with Kubernetes to help users install a production ready Kubernetes cluster with best practices enforcement. This documentation will show you how you can install a Kubernetes Cluster on Ubuntu with kubeadm.

In this project, Jenkins will operate independently. The Jenkins server will run on the Red Hat operating system, while the other servers will be utilizing Ubuntu as their operating system.

 Here is an architectural diagram of the project below:

![image](https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/0558029c-671f-4109-b905-a4a9f9e10565)

![image](https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/54523343-de30-4620-8158-fb7aa622574b)

 
To deploy a Kubernetes cluster, two main servers are needed and they are:

Master Node: It's the starting point for all administrative tasks, and its responsibility is managing the Kubernetes cluster architecture.

Worker/Slave Node: Worker Node runs apps via Pods, and Master Node controls the Pods. Pods are scheduled on a physical server (slave node).

The setup for  this Kubernetes cluster will have seven servers:

 Three control plane machines (master node)

 Two HA-Proxy servers, in which one the HA-Proxy server that will load balance the master nodes while the second will be on redundancy. 

 We also utilize Keepalived, acting as a safeguard for the HA-Proxy servers. In the event of a failover on the active server, Keepalived facilitates communication with the backup HA-Proxy server using a shared virtual IP address. This communication ensures that the backup server takes over seamlessly until the primary server is restored.

Three Worker/Slave nodes are to be used for running containerised workloads

 The prerequisite for this implementation are:

1. Terraform must be installed and configured locally on the machine

2. AWS CLI most be installed and configure to access AWS Console on the local machine.

Terraform modules will be created using the Terraform registry to extract the resources nd modify them as well to our defined state.
In this project, Jenkins server will be a stand alone as it is our primary engine in deploying our infrastructure. The main.tf , output.tf , provider.tf , jenkins script , and iam role will be created.

<img width="949" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/dbd5fd5e-1749-47b3-a738-290816df33b1">


<img width="711" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/200317e1-d8bb-4c05-9fce-20787962fe8a">


<img width="938" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/91d5d740-ea69-4140-aa0f-b8160b296aa4">


<img width="921" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/7503588e-11df-49e6-a4cc-d38e3324ed27">


<img width="900" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/0929acfd-788d-415b-a5a2-bb12f82b87e7">


<img width="941" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/61beab45-5fe9-473c-8e6e-46f2f540e270">


<img width="734" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/432d066d-8452-4e92-a3d4-9945a51c6d6e">


<img width="732" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/7ebda029-36ee-44f1-8e64-30244f98bdc6">


<img width="596" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/846acd14-cd58-4397-9a46-70501dabce08">


<img width="703" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/5fe593ff-921d-4b86-af52-062d35049c82">


Also, HAProxy is a high-performance, open-source load balancer and reverse proxy for TCP and HTTP applications. Users can make use of HAProxy to improve the performance of websites and applications by distributing their workloads. Performance improvements include minimized response times and increased throughput. 

HA-Proxy is needed in this step up because we have will have more than one master node and HA-Proxy is needed to distribute traffic to other master node whenever the main master node is down. 
Then we will configure HA-Proxy to load balance the two master nodes in our setup. The code will be run to add the required configuration in “/etc/haproxy/haproxy.cfg" 
HA-Proxy script can be seen below:

<img width="745" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/4a4336ce-afb6-48a6-a402-72d9d68044e5">

<img width="730" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/f9ba7362-eb55-47b5-a62d-b0172f21cc40">

So the above screenshot shows the primary HA-Proxy server which serves as a load balancer for the master nodes and we also have the redundant HA-Proxy server where it spins up when the primary server has a failover. 

<img width="736" alt="image" src="https://github.com/Iyewumi-Adesupo/microservices-kubernetes-project/assets/135404420/4882a570-b30c-4b9b-9976-2d530f181f56">

Moreover, within this project, we intend to implement our infrastructure and applications through the CI/CD pipeline, incorporating parameterization into our actions. Our approach involves the installation of plugins using Terraform and AWS CLI, alongside the creation of necessary credentials. The utilization of POLL SCM for routine commits is crucial, as developers commit their changes from Terraform into their dedicated branch repositories. Following code reviews, these changes are pulled into the main branch, triggering the CI/CD pipeline for updates. The POLL SCM functionality plays a vital role in facilitating these routine commits to the infrastructure.
