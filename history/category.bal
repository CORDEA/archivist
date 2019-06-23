public const string GIT = "GIT";
public const string TRANS = "TRANS";
public const string UNKNOWN = "UNKNOWN";

public type CATEGORY GIT|TRANS|UNKNOWN;

public function detectCategory(string command) returns CATEGORY {
    if (command.hasPrefix("git")) {
        return GIT;
    }
    if (command.hasPrefix("trans")) {
        return TRANS;
    }
    return UNKNOWN;
}
