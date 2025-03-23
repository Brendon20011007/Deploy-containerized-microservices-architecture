# AWS EKS Microservices Architecture Setup Guide

This guide provides detailed instructions for setting up a complete microservices architecture on AWS EKS (Elastic Kubernetes Service) with Fargate, service mesh, and monitoring solutions.

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
2. AWS CLI installed and configured
3. kubectl installed
4. eksctl installed
5. Helm installed

## Infrastructure Setup

### 1. Configure AWS CLI
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-west-2)
# Enter your output format (json)
```

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

### 1. Create EKS Cluster using eksctl

Create a file named `cluster-config.yaml`:
```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: microservices-cluster
  region: us-west-2
fargateProfiles:
  - name: fp-default
    selectors:
      - namespace: default
      - namespace: monitoring
      - namespace: appmesh-system
iam:
  withOIDC: true
vpc:
  clusterEndpoints:
    publicAccess: true
    privateAccess: true
```

Deploy the cluster:
```bash
eksctl create cluster -f cluster-config.yaml
```

### 2. Configure kubectl
```bash
aws eks update-kubeconfig --name microservices-cluster --region us-west-2
```

## Service Mesh Implementation

### 1. Install AWS App Mesh Controller
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install appmesh-controller eks/appmesh-controller \
    --namespace appmesh-system \
    --create-namespace
```

### 2. Create App Mesh Resources
1. Create Mesh:
```yaml
apiVersion: appmesh.k8s.aws/v1beta2
kind: Mesh
metadata:
  name: microservices-mesh
spec:
  namespaceSelector:
    matchLabels:
      mesh: microservices-mesh
```

2. Create Virtual Services for each microservice
3. Configure Virtual Nodes and Virtual Routers

## Microservices Deployment

### 1. Create Namespaces
```bash
kubectl create namespace user-service
kubectl create namespace order-service
kubectl create namespace payment-service
```

### 2. Deploy Microservices

#### User Service
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: user-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: your-registry/user-service:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: user-service
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

#### Order Service
Similar deployment configuration for order-service

#### Payment Service
Similar deployment configuration for payment-service

### 3. Configure Horizontal Pod Autoscaling
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: user-service-hpa
  namespace: user-service
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: user-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 4. Configure AWS Load Balancer Controller
```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --namespace kube-system \
    --set clusterName=microservices-cluster
```

## Monitoring Setup

### 1. Install Prometheus and Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace
```

### 2. Configure CloudWatch Integration
1. Create IAM policy for CloudWatch:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        }
    ]
}
```

2. Install CloudWatch agent:
```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-daemonset.yaml
```

## Cleanup

To remove all resources:
```bash
# Delete EKS cluster
eksctl delete cluster --name microservices-cluster

# Delete VPC and related resources through AWS Console
```

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