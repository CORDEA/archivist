import ballerina/http;
import ballerina/log;
import ballerina/config;

import db;

listener http:Listener httpListener = new(9090);

db:DbHelper dbHelper = new();

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
        response.setPayload(untaint dbHelper.selectAll());
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

        var payload = request.getJsonPayload();
        if (payload is json) {
            db:History|error history = db:History.convert(payload);
            if (history is db:History) {
                if (history.command == "") {
                    response.statusCode = 400;
                } else {
                    // insert
                    response.statusCode = 201;
                }
            } else {
                response.statusCode = 400;
            }
        } else {
            response.statusCode = 500;
        }

        var result = caller -> respond(response);
        if (result is error) {
            log:printError("Failed to response", err = result);
        }
    }
}