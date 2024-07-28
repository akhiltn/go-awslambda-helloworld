package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(HandleRequest)
}

type MyEvent struct {
	Name string `json:"name"`
}

func HandleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Printf("Processing Lambda Request %v\n", request)
	response := events.APIGatewayProxyResponse{}
	if request.HTTPMethod == "GET" {
		msg := "Hello World"
		resposeBody := ResposeBody{
			Message: &msg,
		}
		jbytes, err := json.Marshal(resposeBody)
		if err != nil {
			return events.APIGatewayProxyResponse{}, err
		}
		response = events.APIGatewayProxyResponse{
			StatusCode: 200,
			Body:       string(jbytes),
		}
	} else {
		var person Person
		err := json.Unmarshal([]byte(request.Body), &person)
		if err != nil {
			return events.APIGatewayProxyResponse{}, err
		}
		msg := fmt.Sprintf("Hello %v %v", *person.FirstName, *person.LastName)
		resposeBody := ResposeBody{
			Message: &msg,
		}
		jbytes, err := json.Marshal(resposeBody)
		if err != nil {
			return events.APIGatewayProxyResponse{}, err
		}
		response = events.APIGatewayProxyResponse{
			StatusCode: 200,
			Body:       string(jbytes),
		}
	}
	return response, nil
}

type Person struct {
	FirstName *string `json:"first_name"`
	LastName  *string `json:"last_name"`
}

type ResposeBody struct {
	Message *string `json:"message"`
}
