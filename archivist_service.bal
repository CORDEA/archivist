import ballerina/http;
import ballerina/log;
import ballerina/config;
import ballerina/mysql;
import ballerina/sql;

listener http:Listener httpListener = new(9090);

type History record {
    int id;
    string command;
    string category;
};

mysql:Client historyDB = new({
    host: config:getAsString("database.host", defaultValue = "localhost"),
    port: config:getAsInt("database.port", defaultValue = 3306),
    name: config:getAsString("database.name", defaultValue = "archivist"),
    username: config:getAsString("database.username", defaultValue = "root"),
    password: config:getAsString("database.password", defaultValue = "root"),
    dbOptions: { useSSL: false, allowPublicKeyRetrieval: true }
});

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
            History|error history = History.convert(payload);
            if (history is History) {
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