resource "oci_load_balancer_load_balancer" "swarm" {
  compartment_id = var.loadbalancer_compartment_id
  display_name   = "${var.loadbalancer_name_prefix}-lb-${var.loadbalancer_name_postfix}"
  shape          = var.loadbalancer_shape
  subnet_ids     = [var.loadbalancer_subnet_id]
  is_private     = "false"
  # Choose flexible as shape in var.lb_shape
  shape_details {
    #Required
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
  count = var.loadbalancer_enabled == true ? 1 : 0
}

resource "oci_load_balancer_backend_set" "oci_swarm_bes" {
  name             = "oci-swarm-whoami-http-80"
  load_balancer_id = oci_load_balancer_load_balancer.swarm[0].id
  policy           = "IP_HASH"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/whoami"
    return_code         = 200
    interval_ms         = 5000
    timeout_in_millis   = 2000
    retries             = 10
  }

  count = var.loadbalancer_enabled == true ? 1 : 0
}

resource "oci_load_balancer_backend" "oci-swarm-be" {
  load_balancer_id = oci_load_balancer_load_balancer.swarm[0].id
  backendset_name  = oci_load_balancer_backend_set.oci_swarm_bes[0].name
  ip_address       = var.loadbalancer_swarm_backend
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1

  count = var.loadbalancer_enabled == true ? 1 : 0
}

resource "oci_load_balancer_listener" "oci_swarm_listener_80" {
  load_balancer_id         = oci_load_balancer_load_balancer.swarm[0].id
  default_backend_set_name = oci_load_balancer_backend_set.oci_swarm_bes[0].name
  name                     = "oci-swarm-default-http-80"
  hostname_names           = [oci_load_balancer_hostname.oci_swarm_hostname[0].name]
  port                     = 80
  protocol                 = "HTTP"
  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
  rule_set_names = [oci_load_balancer_rule_set.oci_swarm_rule_set_80_443[0].name]

  count = var.loadbalancer_enabled == true ? 1 : 0
}

resource "oci_load_balancer_listener" "oci_swarm_listener_443" {
  load_balancer_id         = oci_load_balancer_load_balancer.swarm[0].id
  default_backend_set_name = oci_load_balancer_backend_set.oci_swarm_bes[0].name
  name                     = "oci-swarm-default-https-443"
  hostname_names           = [oci_load_balancer_hostname.oci_swarm_hostname[0].name]
  port                     = 443
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }

  ssl_configuration {
    certificate_name = oci_load_balancer_certificate.oci_swarm_certificate[0].certificate_name
  }

  count = var.loadbalancer_enabled == true ? 1 : 0
}

resource "oci_load_balancer_rule_set" "oci_swarm_rule_set_80_443" {
  items {
    action      = "REDIRECT"
    description = "Redirect HTTP Requests to HTTPS"
    conditions {
      attribute_name  = "PATH"
      attribute_value = "/"
      operator        = "PREFIX_MATCH"
    }
    redirect_uri {
      #host     = "{host}"
      #path     = "/{path}"
      #port     = "{port}"
      protocol = "HTTPS"
      #query    = "?{query}"
    }
    response_code = 301
  }
  load_balancer_id = oci_load_balancer_load_balancer.swarm[0].id
  name             = "oci-swarm-redirect-http-https"
  count            = var.loadbalancer_enabled == true ? 1 : 0
}

resource "oci_load_balancer_hostname" "oci_swarm_hostname" {
  #Required
  hostname         = var.loadbalancer_hostname_name
  load_balancer_id = oci_load_balancer_load_balancer.swarm[0].id
  name             = var.loadbalancer_hostname_name
  lifecycle {
    create_before_destroy = true
  }

  count = var.loadbalancer_enabled == true ? 1 : 0
}

resource "oci_load_balancer_certificate" "oci_swarm_certificate" {
  #Required
  certificate_name   = var.loadbalancer_certificate_name
  load_balancer_id   = oci_load_balancer_load_balancer.swarm[0].id
  private_key        = var.loadbalancer_certificate_private_key
  public_certificate = var.loadbalancer_certificate_public_certificate
  lifecycle {
    create_before_destroy = true
  }
  count = var.loadbalancer_enabled == true ? 1 : 0
}
