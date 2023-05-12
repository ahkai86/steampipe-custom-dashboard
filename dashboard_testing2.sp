dashboard "dashboard_testing2"  {
  title = "Dashboard - Testing2"

  input "instance_arn" {
  query = aws_insights.query.ec2_instance_input
}

container {
    card {
      width = 2
      query = aws_insights.query.ec2_instance_status
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_type
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_total_cores_count
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_public_access
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_ebs_optimized
      args  = [self.input.instance_arn.value]
    }
}







container {
    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = aws_insights.query.ec2_instance_overview
        args  = [self.input.instance_arn.value]

      }

      table {
        title = "Tags"
        width = 6
        query = aws_insights.query.ec2_instance_tags
        args  = [self.input.instance_arn.value]
      }
    }

container {
      width = 6

      table {
        title = "Block Device Mappings"
        query = aws_insights.query.ec2_instance_block_device_mapping
        args  = [self.input.instance_arn.value]

        column "Volume ARN" {
          display = "none"
        }

        column "Volume ID" {
          // cyclic dependency prevents use of url_path, hardcode for now
          href = "/aws_insights.dashboard.ebs_volume_detail?input.volume_arn={{.'Volume ARN' | @uri}}"
        }
      }
    }
  }


container {
    width = 12
    table {
      title = "Network Interfaces"
      query = aws_insights.query.ec2_instance_network_interfaces
      args  = [self.input.instance_arn.value]

      column "VPC ID" {
        // cyclic dependency prevents use of url_path, hardcode for now
        href = "/aws_insights.dashboard.vpc_detail?input.vpc_id={{ .'VPC ID' | @uri }}"
      }
    }
  }

  container {
    width = 6
    table {
      title = "Security Groups"
      query = aws_insights.query.ec2_instance_security_groups
      args  = [self.input.instance_arn.value]

      column "Group ID" {
        // cyclic dependency prevents use of url_path, hardcode for now
        href = "/aws_insights.dashboard.vpc_security_group_detail?input.security_group_id={{.'Group ID' | @uri}}"
      }
    }
  }

  container {
    width = 6
    table {
      title = "CPU cores"
      query = aws_insights.query.ec2_instance_cpu_cores
      args  = [self.input.instance_arn.value]
    }
  }


// container {

//     graph {

//       title     = "Relationships"
//       type      = "graph"
//       direction = "TD"

//       node {
//         base = aws_insights.node.ebs_volume
//         args = {
//           ebs_volume_arns = with.aws_insights.ebs_volumes_for_ec2_instance.rows[*].volume_arn
//         }
//       }

      
//       edge {
//         base = aws_insights.edge.ec2_autoscaling_group_to_ec2_instance
//         args = {
//           ec2_instance_arns = [self.input.instance_arn.value]
//         }
//       }

//     }

//   }




}















# Input queries
query "ec2_instance_input" {
  sql = <<-EOQ
    select
      (title, private_ip_address,private_dns_name,public_dns_name,public_ip_address) as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'instance_id', instance_id,
        'private_ip_address', private_ip_address,
        'private_dns_name',private_dns_name,
        'public_dns_name' , public_dns_name,
        'public_ip_address', public_ip_address
      ) as tags
    from
      aws_ec2_instance
    order by
      title;
  EOQ
}