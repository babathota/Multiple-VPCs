# AWS Multi-VPC Architecture: Peering & Transit Gateway Lab
From the aws Workshop 
LINK https://catalog.workshops.aws/workshops/e4953d7d-f92f-4521-89a5-0002765de750/en-US/foundational/multivpc 

## 📌 Overview
This repository contains the Infrastructure as Code (IaC) used to provision, configure, and connect a multi-VPC environment in AWS. The project demonstrates advanced AWS networking concepts, transitioning from basic VPC Peering to a highly scalable AWS Transit Gateway (TGW) architecture across three distinct Virtual Private Clouds.

This lab is designed to validate routing, subnet-level security, and cross-VPC connectivity, serving as a foundational networking layer before deploying containerized workloads like Amazon ECS or EKS.

## 🏗️ Architecture Design
The infrastructure consists of three logically isolated VPCs:
* **VPC-A:** Represents the primary or shared-services network.
* **VPC-B:** Represents a secondary environment (e.g., application workloads).
* **VPC-C:** Represents an isolated or third-party environment.

### Connection Topologies Explored:
1. **VPC Peering:** Establishing direct, one-to-one networking between VPC-A and VPC-B.
2. **AWS Transit Gateway (TGW):** Implementing a central hub-and-spoke model to manage routing between VPC-A, VPC-B, and VPC-C efficiently without the operational overhead of managing multiple peering connections.

## 🛠️ Key Technologies & Concepts
* **Terraform:** Used for all infrastructure provisioning and state management.
* **Route Tables:** Granular management of local, public (IGW), private (NAT), and transit (TGW) routes.
* **Network ACLs (NACLs):** Stateless, subnet-level traffic control. Includes specific ICMP rules to explicitly allow/deny ping requests between specific CIDR blocks (e.g., allowing `10.2.0.0/16` while blocking others).
* **Security Groups:** Stateful, instance-level security.
* **ICMP Testing:** Verifying bidirectional connectivity and route propagation.