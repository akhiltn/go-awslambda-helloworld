package main

import (
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"name"`
}

func HandleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("Hello World")
	response := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       "Hello World",
	}
	return response, nil
}

func main() {
	lambda.Start(HandleRequest)
}
