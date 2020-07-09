package test

import (
	"flag"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var terraformDir = flag.String("directory", "", "Directory path of the terraform module to test")

func TestEndToEnd(t *testing.T) {
	t.Parallel()
	logger.Logf(t, "Start End To End Test")

	defer test_structure.RunTestStage(t, "teardown", func() {
		scalarModules := []string{"monitor", "kubernetes", "cassandra", "network"}

		for _, m := range scalarModules {
			terraformOptions := &terraform.Options{
				TerraformDir: *terraformDir + m,
				Vars:         map[string]interface{}{},
				NoColor:      true,
			}

			logger.Logf(t, "Destroying <%s> Infrastructure", m)
			terraform.DestroyE(t, terraformOptions)
		}

		logger.Logf(t, "Finished End To End Test")
	})

	test_structure.RunTestStage(t, "setup", func() {
		scalarModules := []string{"network", "cassandra", "kubernetes", "monitor"}

		for _, m := range scalarModules {
			terraformOptions := &terraform.Options{
				TerraformDir: *terraformDir + m,
				Vars:         map[string]interface{}{},
				NoColor:      true,
			}

			logger.Logf(t, "Creating <%s> Infrastructure", m)
			terraform.InitAndApply(t, terraformOptions)
		}

		logger.Logf(t, "Finished Creating Infrastructure: Tests will continue in 2 minutes")
		time.Sleep(120 * time.Second)
	})

	// test_structure.RunTestStage(t, "validate", func() {
	// 	t.Run("TestScalarDL", TestScalarDL)
	// 	// t.Run("TestPrometheusAlerts", TestPrometheusAlerts)
	// })
}

func lookupTargetValue(t *testing.T, module string, targetValue string) string {
	terraformOptions := &terraform.Options{
		TerraformDir: *terraformDir + module,
		Vars:         map[string]interface{}{},
		NoColor:      true,
	}

	return terraform.OutputRequired(t, terraformOptions, targetValue)
}
