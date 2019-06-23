public type HistoryRequest record {|
    string command;
|};

public type History record {|
    *HistoryRequest;
    string category;
    int id;
|};
