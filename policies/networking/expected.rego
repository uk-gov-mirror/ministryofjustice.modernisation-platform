package main

expected = {
  "transit_gateway": {
    "garden-development": "10.233.0.0/26",
    "house-development": "10.233.0.64/26",
    "garden-production": "10.233.0.128/26",
    "house-production": "10.233.0.192/26"
  },
  "protected": {
    "garden-development": "10.232.0.0/23",
    "house-development": "10.232.2.0/23",
    "garden-production": "10.232.4.0/23",
    "house-production": "10.232.6.0/23"
  },
  "subnet_sets": {
    "garden-development": {
      "general": {
        "cidr": "10.234.0.0/21",
        "accounts": [
          "sprinkler-development",
          "bench-development"
        ]
      },
      "patio": {
        "cidr": "10.234.8.0/21",
        "accounts": [
          "heater-development"
        ]
      }
    },
    "house-development": {
      "general": {
        "cidr": "10.234.16.0/21",
        "accounts": [
          "cooker-development"
        ]
      }
    },
    "garden-production": {
      "general": {
        "cidr": "10.237.0.0/21",
        "accounts": [
          "sprinkler-production",
          "bench-production"
        ]
      },
      "patio": {
        "cidr": "10.237.8.0/21",
        "accounts": [
          "heater-production"
        ]
      }
    },
    "house-production": {
      "general": {
        "cidr": "10.237.16.0/21",
        "accounts": [
          "cooker-production"
        ]
      }
    }
  }
}
