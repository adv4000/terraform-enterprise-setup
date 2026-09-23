resource "aws_security_group" "web" {
  name   = "${local.vars_account.environment}-ec2-web-sg"
  vpc_id = local.vpc_id
  tags   = merge({ Name = "${local.vars_account.environment}-ec2-web-sg" }, local.tags)
}

resource "aws_vpc_security_group_ingress_rule" "web" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.web.id
  description       = "Allow inbound HTTP/HTTPS"
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

#-------------------------------------------------------------------------------
resource "aws_launch_template" "web" {
  name                   = "${local.vars_account.environment}-webserver-lt"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = local.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = local.vars_account.environment
  }))
}

resource "aws_autoscaling_group" "web" {
  name                = "${local.vars_account.environment}-webserver-asg-ver-${aws_launch_template.web.latest_version}"
  min_size            = 2
  max_size            = 2
  min_elb_capacity    = 2
  health_check_type   = "ELB"
  vpc_zone_identifier = local.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  dynamic "tag" {
    for_each = merge({ Name = "${local.vars_account.environment}-webserver-asg-v${aws_launch_template.web.latest_version}" }, local.tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

#-------------------------------------------------------------------------------
resource "aws_lb" "web" {
  name               = "${local.vars_account.environment}-webserver-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = local.public_subnet_ids
}

resource "aws_lb_target_group" "web" {
  name                 = "${local.vars_account.environment}-webserver-tg"
  vpc_id               = local.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 10 # seconds
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

#-------------------------------------------------------------------------------
