package grpc_helper

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os/exec"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
)

func GrpcJavaListContracts(t *testing.T, propertiesFile string) (string, string) {
	action := "list-contracts"

	options := []string{
		"--properties", propertiesFile,
	}

	return GrpcJavaTest(t, action, options...)
}

func GrpcJavaValidateAsset(t *testing.T, propertiesFile string, assetId string) (string, string) {
	action := "validate-ledger"

	options := []string{
		"--properties", propertiesFile,
		"--asset-id", assetId,
	}

	return GrpcJavaTest(t, action, options...)
}

func GrpcJavaExectueContract(t *testing.T, propertiesFile string, contractId string, contractArgument string) (string, string) {
	action := "execute-contract"

	options := []string{
		"--properties", propertiesFile,
		"--contract-id", contractId,
		"--contract-argument", contractArgument,
	}

	return GrpcJavaTest(t, action, options...)
}

func GrpcJavaRegisterContract(t *testing.T, propertiesFile string, contractId string, contractBinaryName string, contractClassFile string) (string, string) {
	action := "register-contract"

	options := []string{
		"--properties", propertiesFile,
		"--contract-id", contractId,
		"--contract-binary-name", contractBinaryName,
		"--contract-class-file", contractClassFile,
	}

	return GrpcJavaTest(t, action, options...)
}

func GrpcJavaRegisterCert(t *testing.T, propertiesFile string) (string, string) {
	action := "register-cert"

	options := []string{
		"--properties", propertiesFile,
	}

	return GrpcJavaTest(t, action, options...)
}

func GrpcJavaTest(t *testing.T, action string, options ...string) (string, string) {
	logger.Logf(t, "Starting Java %s %v", action, options)
	command := fmt.Sprintf(`scalardl-java-client-sdk/client/bin/%s`, action)
	cmd := exec.Command(command, options...)

	byteOutput, err := cmd.CombinedOutput()
	if err != nil {
		// It continues the test since it checks error cases as well
	}

	response_status := &struct {
		Code         string `json:"status_code"`
		ErrorMessage string `json:"error_message"`
	}{}

	if err := json.Unmarshal(byteOutput, &response_status); err != nil {
		t.Fatal(err)
	}

	logger.Logf(t, "%s", response_status.Code)
	logger.Logf(t, "%s", response_status.ErrorMessage)

	return response_status.Code, response_status.ErrorMessage
}

func GrpcWebTest(t *testing.T, url string, data string) (int, string) {
	statusCode, body, err := GrpcWebTestE(t, url, data)
	if err != nil {
		t.Fatal(err)
	}

	return statusCode, body
}

func GrpcWebTestE(t *testing.T, url string, data string) (int, string, error) {
	logger.Logf(t, "Making GRPC_WEB call to URL %s", url)

	client := &http.Client{}
	req, err := http.NewRequest("POST", url, bytes.NewBufferString(data))

	req.Header.Add("Content-Type", "application/grpc-web-text")
	req.Header.Add("X-User-Agent", "grpc-web-javascript/0.1")
	req.Header.Add("Connection", "keep-alive")
	req.Header.Add("Accept", "application/grpc-web-text")
	req.Header.Add("X-Grpc-Web", "1")

	resp, err := client.Do(req)
	if err != nil {
		return -1, "", err
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return -1, "", err
	}

	logger.Logf(t, "%s", string(body))
	message, _ := base64.StdEncoding.DecodeString(string(body))

	logger.Logf(t, "Reponse Status: %s", resp.Status)
	logger.Logf(t, "Reponse Body: %s", string(body))
	logger.Logf(t, "Reponse Message: %s", string(message))

	return resp.StatusCode, string(message), nil
}
