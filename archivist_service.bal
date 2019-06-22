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
    host: config:getAsString("DATABASE_HOST", defaultValue = "localhost"),
    port: config:getAsInt("DATABSE_PORT", defaultValue = 3306),
    name: config:getAsString("DATABASE_NAME", defaultValue = "archivist"),
    username: config:getAsString("DATABASE_USERNAME", defaultValue = "root"),
    password: config:getAsString("DATABASE_PASSWORD", defaultValue = "root"),
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