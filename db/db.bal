import ballerina/config;
import ballerina/mysql;

mysql:Client historyDB = new({
    host: config:getAsString("database.host", defaultValue = "localhost"),
    port: config:getAsInt("database.port", defaultValue = 3306),
    name: config:getAsString("database.name", defaultValue = "archivist"),
    username: config:getAsString("database.username", defaultValue = "root"),
    password: config:getAsString("database.password", defaultValue = "root"),
    dbOptions: { useSSL: false, allowPublicKeyRetrieval: true }
});
