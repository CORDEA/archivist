import ballerina/sql;
import ballerina/log;

public type RuleTableController object {
    public function insert(Rule rule) returns json {
        string sql = "INSERT INTO rules (Rule) VALUES (?)";
        var result = historyDB -> update(sql, rule.rule);
        if (result is sql:UpdateResult) {
            return { "result": true };
        } else {
            log:printError("Failed to insert", err = result);
            return { "result": false };
        }
    }

    public function selectAll() returns json {
        string sql = "SELECT * FROM rules";
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

    public function selectAllAsObject() returns table<Rule>|error {
        string sql = "SELECT * FROM rules";
        return historyDB -> select(sql, Rule);
    }
};
