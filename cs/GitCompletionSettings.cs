// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System;

namespace Kzrnm.GitCompletion;

public class GitCompletionSettings
{
    public static GitCompletionSettings Default => new()
    {
        ShowAllOptions = Environment.GetEnvironmentVariable("GIT_COMPLETION_SHOW_ALL") is not null or "0",
        ShowAllCommand = Environment.GetEnvironmentVariable("GIT_COMPLETION_SHOW_ALL_COMMANDS") is not null or "0",
        IgnoreCase = Environment.GetEnvironmentVariable("GIT_COMPLETION_IGNORE_CASE") is not null or "0",
        CheckoutNoGuess = Environment.GetEnvironmentVariable("GIT_COMPLETION_CHECKOUT_NO_GUESS") is not null or "0",
    };
    public string? GitPath { get; set; }
    internal string GitInvoketionPath => GitPath ?? "git";
    public bool ShowAllOptions { get; set; }
    public bool ShowAllCommand { get; set; }
    public bool IgnoreCase { get; set; }
    public bool CheckoutNoGuess { get; set; }

    public string[] AdditionalCommands { get; set; } = [];
    public string[] ExcludeCommands { get; set; } = [];
}