import ballerina/config;
import ballerina/mysql;
import ballerina/sql;

public type DbHelper object {
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

    public function insert(History history) returns (boolean) {
        string sql = "INSERT INTO archivist (ID, Command, Category) VALUES (?,?,?)";
        var result = self.historyDB -> update(sql, history.id, history.command, history.category);
        return result is sql:UpdateResult;
    }

    public function selectAll() returns (json) {
        string sql = "SELECT * FROM archivist";
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
