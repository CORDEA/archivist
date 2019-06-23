import ballerina/config;
import ballerina/mysql;
import ballerina/sql;
import ballerina/log;

public type HistoryTableController object {
    private mysql:Client historyDB;

    public function __init() {
        self.historyDB = new({
            host: config:getAsString("database.host", defaultValue = "localhost"),
            port: config:getAsInt("database.port", defaultValue = 3306),
            name: config:getAsString("database.name", defaultValue = "archivist"),
            username: config:getAsString("database.username", defaultValue = "root"),
            password: config:getAsString("database.password", defaultValue = "root"),
            dbOptions: { useSSL: false, allowPublicKeyRetrieval: true }
        });
    }

    public function insert(HistoryRequest history) returns json {
        string sql = "INSERT INTO histories (Command, Category) VALUES (?, ?)";
        var result = self.historyDB -> update(sql, history.command, history.category);
        if (result is sql:UpdateResult) {
            return { "result": true };
        } else {
            log:printError("Failed to insert", err = result);
            return { "result": false };
        }
    }

    public function selectAll() returns json {
        string sql = "SELECT * FROM histories";
        var result = self.historyDB -> select(sql, ());
        json returnValue = {};
        if (result is table<record {}>) {
            var jsonResult = json.convert(result);
            if (jsonResult is json) {
                returnValue = jsonResult;
            }
        }
        return returnValue;
    }
};
