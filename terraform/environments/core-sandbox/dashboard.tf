resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "ccms-dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 2,
            "width": 8,
            "height": 5,
            "properties": {
                "title": "CPU Utilization",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "UTC",
                "metrics": [
                    [ { "id": "expr1m0", "label": "ccms-opa18-hub-cluster", "expression": "mm1m0 * 100 / mm0m0", "stat": "Average" } ],
                    [ "ECS/ContainerInsights", "CpuReserved", "ClusterName", "ccms-opa18-hub-cluster", { "id": "mm0m0", "visible": false, "stat": "Sum" } ],
                    [ ".", "CpuUtilized", ".", ".", { "id": "mm1m0", "visible": false, "stat": "Sum" } ]
                ],
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "copilot": true,
                "region": "eu-west-2"
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 2,
            "width": 8,
            "height": 5,
            "properties": {
                "title": "Memory Utilization",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "UTC",
                "metrics": [
                    [ { "id": "expr1m0", "label": "ccms-opa18-hub-cluster", "expression": "mm1m0 * 100 / mm0m0", "stat": "Average" } ],
                    [ "ECS/ContainerInsights", "MemoryReserved", "ClusterName", "ccms-opa18-hub-cluster", { "id": "mm0m0", "visible": false, "stat": "Sum" } ],
                    [ ".", "MemoryUtilized", ".", ".", { "id": "mm1m0", "visible": false, "stat": "Sum" } ]
                ],
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "copilot": true,
                "region": "eu-west-2"
            }
        },
        {
            "type": "metric",
            "x": 16,
            "y": 2,
            "width": 8,
            "height": 5,
            "properties": {
                "title": "Network",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "UTC",
                "metrics": [
                    [ { "id": "expr1m0", "label": "ccms-opa18-hub-cluster", "expression": "RATE(mm0m0) + RATE(mm1m0)", "stat": "Average" } ],
                    [ "ECS/ContainerInsights", "NetworkRxBytes", "ClusterName", "ccms-opa18-hub-cluster", { "id": "mm0m0", "visible": false, "stat": "Average" } ],
                    [ ".", "NetworkTxBytes", ".", ".", { "id": "mm1m0", "visible": false, "stat": "Average" } ]
                ],
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Bytes/Second"
                    }
                },
                "copilot": true,
                "region": "eu-west-2"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 7,
            "width": 8,
            "height": 5,
            "properties": {
                "title": "Container Instance Count",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "UTC",
                "metrics": [
                    [ "ECS/ContainerInsights", "ContainerInstanceCount", "ClusterName", "ccms-opa18-hub-cluster", { "stat": "Average" } ]
                ],
                "copilot": true,
                "region": "eu-west-2"
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 7,
            "width": 8,
            "height": 5,
            "properties": {
                "title": "Task Count",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "UTC",
                "metrics": [
                    [ "ECS/ContainerInsights", "TaskCount", "ClusterName", "ccms-opa18-hub-cluster", { "stat": "Average" } ]
                ],
                "copilot": true,
                "region": "eu-west-2"
            }
        },
        {
            "type": "metric",
            "x": 16,
            "y": 7,
            "width": 8,
            "height": 5,
            "properties": {
                "title": "Service Count",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "UTC",
                "metrics": [
                    [ "ECS/ContainerInsights", "ServiceCount", "ClusterName", "ccms-opa18-hub-cluster", { "stat": "Average" } ]
                ],
                "copilot": true,
                "region": "eu-west-2"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 2,
            "properties": {
                "markdown": "\n## CCMS Dashboard\n\nHere you will find monitoring of metrics relating to CCMS\n"
            }
        }
    ]
}
    EOF
}
