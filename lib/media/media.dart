typedef OnProgressChanged = void Function(double current, double max);
typedef OnCompleted = void Function();
typedef OnError = void Function(String error);

const invalidArgument = 'Data can only be a type of String(url) or File';
