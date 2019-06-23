import ballerina/sql;
import ballerina/log;

public type HistoryTableController object {
    public function insert(HistoryRequest history) returns json {
        string sql = "INSERT INTO histories (Command, Category) VALUES (?, ?)";
        var result = historyDB -> update(sql, history.command, history.category);
        if (result is sql:UpdateResult) {
            return { "result": true };
        } else {
            log:printError("Failed to insert", err = result);
            return { "result": false };
        }
    }

    public function selectAll() returns json {
        string sql = "SELECT * FROM histories";
        var result = historyDB -> select(sql, ());
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
