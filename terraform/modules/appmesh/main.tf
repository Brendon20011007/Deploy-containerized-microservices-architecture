resource "aws_appmesh_mesh" "main" {
  name = "${var.cluster_name}-mesh"

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }

  tags = var.tags
}

resource "aws_appmesh_virtual_service" "user_service" {
  name      = "user-service"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.user_service.name
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_virtual_service" "order_service" {
  name      = "order-service"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.order_service.name
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_virtual_service" "payment_service" {
  name      = "payment-service"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.payment_service.name
      }
    }
  }

  tags = var.tags
}

# Virtual Nodes
resource "aws_appmesh_virtual_node" "user_service" {
  name      = "user-service"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = "user-service"
        service_name   = "user-service"
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_virtual_node" "order_service" {
  name      = "order-service"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = "order-service"
        service_name   = "order-service"
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_virtual_node" "payment_service" {
  name      = "payment-service"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = "payment-service"
        service_name   = "payment-service"
      }
    }
  }

  tags = var.tags
}

# Virtual Routers
resource "aws_appmesh_virtual_router" "user_router" {
  name      = "user-router"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_virtual_router" "order_router" {
  name      = "order-router"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_virtual_router" "payment_router" {
  name      = "payment-router"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }
    }
  }

  tags = var.tags
}

# Routes
resource "aws_appmesh_route" "user_route" {
  name                = "user-route"
  mesh_name           = aws_appmesh_mesh.main.name
  virtual_router_name = aws_appmesh_virtual_router.user_router.name

  spec {
    http_route {
      match {
        prefix = "/users"
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.user_service.name
          weight       = 100
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_route" "order_route" {
  name                = "order-route"
  mesh_name           = aws_appmesh_mesh.main.name
  virtual_router_name = aws_appmesh_virtual_router.order_router.name

  spec {
    http_route {
      match {
        prefix = "/orders"
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.order_service.name
          weight       = 100
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_appmesh_route" "payment_route" {
  name                = "payment-route"
  mesh_name           = aws_appmesh_mesh.main.name
  virtual_router_name = aws_appmesh_virtual_router.payment_router.name

  spec {
    http_route {
      match {
        prefix = "/payments"
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.payment_service.name
          weight       = 100
        }
      }
    }
  }

  tags = var.tags
}

# Outputs
output "mesh_name" {
  value = aws_appmesh_mesh.main.name
}

output "mesh_arn" {
  value = aws_appmesh_mesh.main.arn
} 