# AWS EKS Microservices Architecture Setup Guide

This guide provides detailed instructions for setting up a complete microservices architecture on AWS EKS (Elastic Kubernetes Service) with Fargate, service mesh, and monitoring solutions using the AWS Management Console.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Infrastructure Setup](#infrastructure-setup)
3. [EKS Cluster Creation](#eks-cluster-creation)
4. [Service Mesh Implementation](#service-mesh-implementation)
5. [Microservices Deployment](#microservices-deployment)
6. [Monitoring Setup](#monitoring-setup)
7. [Cleanup](#cleanup)

## Prerequisites

1. AWS Account with appropriate permissions
2. kubectl installed
3. Helm installed

## Infrastructure Setup

### 1. Configure AWS Management Console
1. Log in to AWS Management Console
2. Ensure you have the necessary IAM permissions for EKS, VPC, and related services
3. Select your desired region (e.g., us-west-2)

### 2. Create VPC and Network Resources
1. Go to AWS Console → VPC
2. Create a new VPC:
   - Name: `eks-vpc`
   - CIDR: `10.0.0.0/16`
   - Enable DNS hostnames and DNS resolution
3. Create public and private subnets in different AZs
4. Create Internet Gateway and attach to VPC
5. Create NAT Gateway for private subnets
6. Configure route tables for public and private subnets

## EKS Cluster Creation

### 1. Create EKS Cluster using AWS Console
1. Go to AWS Console → EKS → Clusters
2. Click "Create cluster"
3. Configure cluster settings:
   - Name: `microservices-cluster`
   - Kubernetes version: Latest stable version
   - Role: Create new role with necessary permissions
   - VPC: Select the VPC created earlier
   - Subnets: Select public and private subnets
   - Security groups: Create new security groups
   - Enable Fargate profile
   - Enable logging for control plane

### 2. Configure kubectl
1. Go to your EKS cluster in the console
2. Click "View" next to your cluster
3. Click "Command" tab
4. Copy and run the `aws eks update-kubeconfig` command shown

## Service Mesh Implementation

### 1. Install AWS App Mesh Controller
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Go to "Add-ons" tab
4. Click "Get more add-ons"
5. Search for "AWS App Mesh"
6. Click "Add" and follow the installation wizard

### 2. Create App Mesh Resources
1. Go to AWS Console → App Mesh
2. Create new mesh:
   - Name: `microservices-mesh`
   - Select namespace selector
   - Configure mesh settings
3. Create Virtual Services for each microservice
4. Configure Virtual Nodes and Virtual Routers

## Microservices Deployment

### 1. Create Namespaces
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Go to "Namespaces" tab
4. Click "Create namespace"
5. Create namespaces:
   - user-service
   - order-service
   - payment-service

### 2. Deploy Microservices

#### User Service
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Go to "Workloads" tab
4. Click "Deploy"
5. Configure deployment:
   - Name: `user-service`
   - Namespace: `user-service`
   - Container image: your-registry/user-service:latest
   - Port: 8080
   - Resource limits and requests
   - Replicas: 2

#### Order Service
Similar deployment steps for order-service

#### Payment Service
Similar deployment steps for payment-service

### 3. Configure Horizontal Pod Autoscaling
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Go to "Workloads" tab
4. Select your deployment
5. Click "Scale"
6. Configure HPA:
   - Min replicas: 2
   - Max replicas: 10
   - Target CPU utilization: 70%

### 4. Configure AWS Load Balancer Controller
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Go to "Add-ons" tab
4. Click "Get more add-ons"
5. Search for "AWS Load Balancer Controller"
6. Click "Add" and follow the installation wizard

## Monitoring Setup

### 1. Install Prometheus and Grafana
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Go to "Add-ons" tab
4. Click "Get more add-ons"
5. Search for "Prometheus"
6. Click "Add" and follow the installation wizard

### 2. Configure CloudWatch Integration
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Go to "Add-ons" tab
4. Click "Get more add-ons"
5. Search for "CloudWatch"
6. Click "Add" and follow the installation wizard

## Cleanup

To remove all resources:
1. Go to AWS Console → EKS → Clusters
2. Select your cluster
3. Click "Delete"
4. Go to VPC console and delete VPC resources
5. Remove any remaining resources in CloudWatch, App Mesh, and other services

## Additional Notes

1. **Security Considerations**:
   - Use AWS Secrets Manager for sensitive data
   - Implement Network Policies
   - Enable AWS WAF for ALB
   - Use IAM roles for service accounts

2. **Cost Optimization**:
   - Use Spot instances where applicable
   - Implement resource limits and requests
   - Monitor and adjust autoscaling parameters

3. **Best Practices**:
   - Implement proper logging
   - Use health checks
   - Implement circuit breakers
   - Use proper resource limits

## Troubleshooting

Common issues and solutions:
1. Pod scheduling issues
2. Service mesh connectivity problems
3. Monitoring data collection issues
4. Load balancer configuration problems

For detailed troubleshooting steps, refer to AWS documentation and logs in CloudWatch. 