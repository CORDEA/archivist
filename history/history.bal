public type HistoryRequest record {|
    string command;
    string category;
|};

public type History record {|
    *HistoryRequest;
    int id;
|};
