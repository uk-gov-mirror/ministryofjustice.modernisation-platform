[
  {
    "name": "${app_name}-container",
    "image": "${app_image}:${container_version}",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${app_name}-ecs",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${server_port}
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/opa",
        "sourceVolume": "opa_volume"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "DB_HOST",
        "value": "${db_host}"
      },
      {
        "name": "DB_USER",
        "value": "${db_user}"
      },
      {
        "name": "DB_PASSWORD",
        "value": "${db_password}"
      },
      {
        "name": "HUB_PASSWORD",
        "value": "${opahub_password}"
      },
      {
        "name": "WL_PASSWORD",
        "value": "${wl_password}"
      },
      {
        "name": "USER_MEM_ARGS",
        "value": "${wl_mem_args}"
      }
    ]
  }
]
