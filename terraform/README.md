# AWS EKS Microservices Architecture Deployment

This project demonstrates the deployment of a containerized microservices architecture using AWS EKS (Elastic Kubernetes Service) with Fargate. The infrastructure includes multiple microservices, service mesh integration, and comprehensive monitoring.

## Architecture Overview

The infrastructure consists of the following components:

- **Kubernetes Cluster**: AWS EKS with Fargate
- **Microservices**:
  - User Management Service
  - Order Processing Service
  - Payment Service
- **Service Mesh**: AWS App Mesh
- **Load Balancing**: AWS Application Load Balancer (ALB) with Ingress Controller
- **Monitoring**: AWS CloudWatch, Prometheus, and Grafana
- **Auto Scaling**: Horizontal Pod Autoscaler (HPA)

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version >= 1.0.0)
- kubectl installed
- Helm installed (for package management)

## Project Structure

```
.
├── README.md
├── terraform/
│   ├── main.tf           # Main Terraform configuration
│   ├── variables.tf      # Variable definitions
│   ├── outputs.tf        # Output definitions
│   ├── providers.tf      # Provider configurations
│   └── modules/
│       ├── eks/         # EKS cluster module
│       ├── appmesh/     # App Mesh configuration
│       ├── monitoring/  # Monitoring stack
│       └── services/    # Microservices deployment
└── kubernetes/
    ├── base/           # Base Kubernetes manifests
    └── overlays/       # Environment-specific overlays
```

## Deployment Steps

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Deploy EKS Cluster**
   ```bash
   terraform apply -target=module.eks
   ```

3. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

4. **Deploy Service Mesh**
   ```bash
   terraform apply -target=module.appmesh
   ```

5. **Deploy Monitoring Stack**
   ```bash
   terraform apply -target=module.monitoring
   ```

6. **Deploy Microservices**
   ```bash
   terraform apply -target=module.services
   ```

## Monitoring and Observability

- **CloudWatch**: Container insights and logs
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboard

Access Grafana dashboard:
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## Auto Scaling Configuration

Each microservice is configured with HPA:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: service-deployment
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

## Service Mesh Configuration

AWS App Mesh is configured with the following features:
- Service discovery
- Traffic management
- Circuit breaking
- Load balancing
- Observability

## Security Considerations

- Network policies implemented
- Pod security policies enabled
- Secrets management using AWS Secrets Manager
- IAM roles for service accounts (IRSA)

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## Achievement Summary

This project successfully demonstrates:

1. **Serverless Kubernetes**: Using EKS Fargate for reduced operational overhead
2. **Microservices Architecture**: Multiple services with proper isolation and communication
3. **Service Mesh**: Implemented AWS App Mesh for service discovery and traffic management
4. **Monitoring**: Comprehensive monitoring stack with CloudWatch, Prometheus, and Grafana
5. **Auto Scaling**: Implemented HPA for dynamic scaling based on demand
6. **Load Balancing**: ALB with Ingress Controller for proper traffic distribution
7. **Infrastructure as Code**: All infrastructure defined using Terraform
8. **Security**: Proper security configurations and best practices

## Contributing

Feel free to submit issues and enhancement requests! 