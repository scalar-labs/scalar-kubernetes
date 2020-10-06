package test

import (
	"flag"
	"io/ioutil"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var terraformDir = flag.String("directory", "", "Directory path of the terraform module to test")

func TestEndToEnd(t *testing.T) {
	t.Parallel()
	logger.Logf(t, "Start End To End Test")

	defer test_structure.RunTestStage(t, "teardown", func() {
		scalarModules := []string{"kubernetes", "cassandra", "network"}

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
		scalarModules := []string{"network", "cassandra", "kubernetes"}

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

	test_structure.RunTestStage(t, "ansible", func() {
		logger.Logf(t, "Run Ansible playbooks")
		runAnsiblePlaybooks(t)
		time.Sleep(120 * time.Second)
	})

	test_structure.RunTestStage(t, "validate", func() {
		t.Run("TestScalarDL", TestScalarDL)
	})
}

func lookupTargetValue(t *testing.T, module string, targetValue string) string {
	terraformOptions := &terraform.Options{
		TerraformDir: *terraformDir + module,
		Vars:         map[string]interface{}{},
		NoColor:      true,
	}

	return terraform.OutputRequired(t, terraformOptions, targetValue)
}

func runAnsiblePlaybooks(t *testing.T) {
	err := ioutil.WriteFile("./kube_config", []byte(lookupTargetValue(t, "kubernetes", "kube_config")), 0644)
	if err != nil {
		t.Fatal(err)
	}

	err = ioutil.WriteFile("./inventory.ini", []byte(lookupTargetValue(t, "kubernetes", "inventory_ini")), 0644)
	if err != nil {
		t.Fatal(err)
	}

	// Install tools
	runAnsiblePlaybook(t, []string{"./playbooks/playbook-install-tools.yml", "-e", "base_local_directory=../test/src/integration"})

	// Deploy scalardl
	runAnsiblePlaybook(t, []string{"./playbooks/playbook-deploy-scalardl.yml", "-e", "base_local_directory=../test/modules/conf"})
}

func runAnsiblePlaybook(t *testing.T, playbookOptions []string) {
	args := []string{"-i", "./test/src/integration/inventory.ini"}

	ansibleCommand := shell.Command{
		Command:    "ansible-playbook",
		Args:       append(args, playbookOptions...),
		WorkingDir: "../../../",
	}

	shell.RunCommand(t, ansibleCommand)
}
