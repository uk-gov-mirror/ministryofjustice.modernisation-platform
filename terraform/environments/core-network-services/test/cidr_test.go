package test

import (
  "testing"

  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestCidr(t *testing.T) {
  // Construct the terraform options with default retryable errors to handle the most common
  // retryable errors in terraform testing.
  terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
    // Set the path to the Terraform code that will be tested.
    TerraformDir: "..",
  })

  // Set the static CIDRs
  liveDataVpcCidr := "10.230.0.0/19"
  nonLiveDataVpcCidr := "10.230.32.0/19"

  // Run "terraform init" and "terraform apply". Fail the test if there are any errors.
  // terraform.InitAndApply(t, terraformOptions)
  terraform.InitAndPlan(t, terraformOptions)

  // Run `terraform output` to get the values of output variables and check they have the expected values.
  // var vpcs []Vpcs
  remoteLiveDataVpcCidr := terraform.Output(t, terraformOptions, "live_data_vpc_cidr")
  remoteNonLiveDataVpcCidr := terraform.Output(t, terraformOptions, "non_live_data_vpc_cidr")

  assert.Equal(t, liveDataVpcCidr, remoteLiveDataVpcCidr)
  assert.Equal(t, nonLiveDataVpcCidr, remoteNonLiveDataVpcCidr)
}
