package test

import (
	"fmt"
	"io/ioutil"
	"testing"

	"modules/grpc_helper"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/stretchr/testify/assert"
)

func TestScalarDL(t *testing.T) {
	t.Run("scalardl", func(t *testing.T) {
		t.Run("ScalarDLWithJavaClient", TestScalarDLWithJavaClientExpectStatusCodeIsValid)
		t.Run("ScalarDLWithGrpcWebClient", TestScalarDLWithGrpcWebClientExpectStatusCodeIsValid)
	})
}

func TestScalarDLWithJavaClientExpectStatusCodeIsValid(t *testing.T) {
	expectedRegisterCertStatusCode := []string{"OK", "CERTIFICATE_ALREADY_REGISTERED"}
	expectedRegisterContractStatusCode := []string{"OK", "CONTRACT_ALREADY_REGISTERED"}
	expectedExecuteContractStatusCode := "OK"
	expectedValidateLedgerStatusCode := "OK"
	expectedListContractsStatusCode := "OK"

	contractID := "test-contract1"
	contractBinaryName := "com.org1.contract.StateUpdater"
	contractClassFile := "./resources/StateUpdater.class"
	assetID := "over9000"
	assetArgument := fmt.Sprintf(`{"asset_id": "%s", "state": 9001}`, assetID)
	propertiesFile := "./resources/test.properties"

	externalIP := getExternalIP(t)

	logger.Logf(t, "URL: %s", externalIP)
	writePropertiesFile(t, externalIP)

	code, _ := grpc_helper.GrpcJavaRegisterCert(t, propertiesFile)
	assert.Contains(t, expectedRegisterCertStatusCode, code)

	code, _ = grpc_helper.GrpcJavaRegisterContract(t, propertiesFile, contractID, contractBinaryName, contractClassFile)
	assert.Contains(t, expectedRegisterContractStatusCode, code)

	code, _ = grpc_helper.GrpcJavaExectueContract(t, propertiesFile, contractID, assetArgument)
	assert.Equal(t, expectedExecuteContractStatusCode, code)

	code, _ = grpc_helper.GrpcJavaValidateAsset(t, propertiesFile, assetID)
	assert.Equal(t, expectedValidateLedgerStatusCode, code)

	code, _ = grpc_helper.GrpcJavaListContracts(t, propertiesFile)
	assert.Equal(t, expectedListContractsStatusCode, code)
}

func TestScalarDLWithGrpcWebClientExpectStatusCodeIsValid(t *testing.T) {
	expectedStatusCode := 200

	externalIP := getExternalIP(t)

	logger.Logf(t, "URL: %s", externalIP)

	//Register Certificate
	requestData := "AAAAAFIKBW1kYm94EAEiRzBFAiEAx4josbxWPEuZ7w/imnl5B/xY0FKbQLkuK/E/UFUHbmwCIGBludc3JD3pkTYqmeT186g+rDaoFkLqHg4xCQ8uCL3w"
	listContractURL := fmt.Sprintf(`http://%s:50051/rpc.Ledger/ListContracts`, externalIP)

	statuCode, _ := grpc_helper.GrpcWebTest(t, listContractURL, requestData)

	assert.Equal(t, expectedStatusCode, statuCode)
}

func writePropertiesFile(t *testing.T, host string) {
	properties := []byte(fmt.Sprintf(`
  scalar.dl.client.server.host=%s
  scalar.dl.client.server.port=50051
  scalar.dl.client.server.privileged_port=50052
  scalar.dl.client.cert_holder_id=test
  scalar.dl.client.cert_version=1
  scalar.dl.client.cert_path=./resources/Test.pem
  scalar.dl.client.private_key_path=./resources/Test-key.pem
  `, host))

	err := ioutil.WriteFile("./resources/test.properties", properties, 0644)
	if err != nil {
		t.Fatal(err)
	}
}

func getExternalIP(t *testing.T) string {
	bastionIP := lookupTargetValue(t, "network", "bastion_ip")

	publicHost := ssh.Host{
		Hostname:    bastionIP,
		SshAgent:    true,
		SshUserName: "centos",
	}

	commandGetExternalIP := "kubectl get services prod-scalardl-envoy --output jsonpath='{.status.loadBalancer.ingress[0].ip}'"

	output, _ := ssh.CheckSshCommandE(t, publicHost, commandGetExternalIP)

	logger.Logf(t, "URL: %s", output)

	return output
}
