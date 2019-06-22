import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new(9090);

@http:ServiceConfig { basePath: "/archivist" }
service archivist on httpListener {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/ping"
    }
    resource function ping(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.statusCode = 200;

        var result = caller -> respond(response);
        if (result is error) {
            log:printError("Failed to response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/histories"
    }
    resource function getHistories(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.statusCode = 200;

        var result = caller -> respond(response);
        if (result is error) {
            log:printError("Failed to response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/history"
    }
    resource function postHistory(http:Caller caller, http:Request request) {
        http:Response response = new;

        response.statusCode = 201;

        var result = caller -> respond(response);
        if (result is error) {
            log:printError("Failed to response", err = result);
        }
    }
}