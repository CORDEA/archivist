import ballerina/http;
import ballerina/io;
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
        response.setJsonPayload(untaint dbHelper.selectAll(), contentType = "application/json");
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
        response.setJsonPayload({}, contentType = "application/json");

        var payload = request.getJsonPayload();
        if (payload is json) {
            var history = db:HistoryRequest.convert(payload);
            if (history is db:HistoryRequest) {
                if (history.command == "") {
                    response.statusCode = 400;
                } else {
                    response.statusCode = 201;
                    if (db:isValidCategory(history.category)) {
                        history.category = history.category.toUpper();
                    } else {
                        history.category = db:detectCategory(history.command);
                    }
                    response.setJsonPayload(dbHelper.insert(history), contentType = "application/json");
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