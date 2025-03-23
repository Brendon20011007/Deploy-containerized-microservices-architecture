# CloudWatch Container Insights
resource "aws_cloudwatch_log_group" "container_insights" {
  name              = "/aws/containerinsights/${var.cluster_name}/application"
  retention_in_days = 30

  tags = var.tags
}

# Prometheus and Grafana using Helm
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.7.0"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/values/prometheus-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.50.7"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/values/grafana-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus
  ]
}

# Kubernetes Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

# Service Account for Prometheus
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.prometheus_role.arn
    }
  }
}

# IAM Role for Prometheus
resource "aws_iam_role" "prometheus_role" {
  name = "${var.cluster_name}-prometheus-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:monitoring:prometheus"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Prometheus
resource "aws_iam_role_policy" "prometheus_policy" {
  name = "${var.cluster_name}-prometheus-policy"
  role = aws_iam_role.prometheus_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Outputs
output "prometheus_endpoint" {
  value = "http://${helm_release.prometheus.name}.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:9090"
}

output "grafana_endpoint" {
  value = "http://${helm_release.grafana.name}.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:80"
} 