namespace Kzrnm.GitCompletion;

public class GitCompletionSettings
{
    public bool ShowAllOptions { set; get; }
    public bool ShowAllCommand { set; get; }
    public bool IgnoreCase { set; get; }
    public bool CheckoutNoGuess { set; get; }

    public string[]? AdditionalCommands { set; get; }
    public string[]? ExcludeCommands { set; get; }

    public static GitCompletionSettings EnvDefault() => new()
    {
        ShowAllOptions = Environment.GetEnvironmentVariable("GIT_COMPLETION_SHOW_ALL") is not null or "0",
        ShowAllCommand = Environment.GetEnvironmentVariable("GIT_COMPLETION_SHOW_ALL_COMMANDS") is not null or "0",
        IgnoreCase = Environment.GetEnvironmentVariable("GIT_COMPLETION_IGNORE_CASE") is not null or "0",
        CheckoutNoGuess = Environment.GetEnvironmentVariable("GIT_COMPLETION_CHECKOUT_NO_GUESS") is not null or "0",

        AdditionalCommands = [],
        ExcludeCommands = [],
    };
}
