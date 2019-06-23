import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/config;

import db;
import rule;
import history;

listener http:Listener httpListener = new(9090);

db:HistoryTableController historyController = new();
db:RuleTableController ruleController = new();

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
        response.setJsonPayload(
            untaint historyController.selectAll(),
            contentType = "application/json"
        );
        var result = caller -> respond(response);
        if (result is error) {
            log:printError("Failed to response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/histories"
    }
    resource function postHistories(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setJsonPayload({}, contentType = "application/json");

        var payload = request.getJsonPayload();
        if (payload is json) {
            response.statusCode = 201;
            var length = payload.length();
            var i = 0;
            while (i < length) {
                var command = <string> payload[i];
                _ = historyController.insert(
                    {
                        id: 0,
                        command: command,
                        category: history:detectCategory(command)
                    }
                );
                i += 1;
            }
        } else {
            response.statusCode = 500;
        }

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
            var history = history:HistoryRequest.convert(payload);
            if (history is history:HistoryRequest) {
                if (history.command == "") {
                    response.statusCode = 400;
                } else if (containsRule(history.command)){
                    response.statusCode = 400;
                } else {
                    response.statusCode = 201;
                    response.setJsonPayload(
                        historyController.insert(
                            {
                                id: 0,
                                command: history.command,
                                category: history:detectCategory(history.command)
                            }
                        ),
                        contentType = "application/json"
                    );
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

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/rules"
    }
    resource function getRules(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setJsonPayload(
            untaint ruleController.selectAll(),
            contentType = "application/json"
        );
        var result = caller -> respond(response);
        if (result is error) {
            log:printError("Failed to response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/rule"
    }
    resource function postRule(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setJsonPayload({}, contentType = "application/json");

        var payload = request.getJsonPayload();
        if (payload is json) {
            var rule = rule:Rule.convert(payload);
            if (rule is rule:Rule) {
                if (rule.rule == "") {
                    response.statusCode = 400;
                } else {
                    response.statusCode = 201;
                    response.setJsonPayload(
                        ruleController.insert(rule),
                        contentType = "application/json"
                    );
                }
            } else {
                log:printError("Failed to convert", err = rule);
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

function containsRule(string command) returns boolean {
    var rules = ruleController.selectAllAsObject();
    if (rules is error) {
        log:printError("Failed to fetch", err = rules);
        return false;
    } else {
        foreach var rule in rules {
            if (command.contains(rule.rule)) {
                return true;
            }
        }
    }
    return false;
}