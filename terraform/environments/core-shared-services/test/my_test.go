package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

var accountName string = "374269020027"

func TestTerraformAccountID(t *testing.T) {

	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	//defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Get the ID of the current account from output
	currentAccID := terraform.Output(t, terraformOptions, "current-account-id")

	if currentAccID != accountName {

		println("AccountID incorrect: %s", currentAccID)
	}
	println("AccountID is correct: %d", accountName)
}
