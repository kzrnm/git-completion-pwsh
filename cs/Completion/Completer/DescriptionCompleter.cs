// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Collections.Generic;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion.Completer;

internal readonly record struct DescribedText(string Text, string Description)
{
    public static implicit operator DescribedText(string text) => new(text, text);
}

internal readonly record struct DescriptionCompleter(
    string Current,
    CompletionResultType ResultType,
    string Prefix = "",
    string Suffix = "")
{
    public IEnumerable<CompletionResult> Complete(IEnumerable<DescribedText> candidates)
    {
        foreach (var candidate in candidates)
        {
            if (!candidate.Text.StartsWith(Current)) continue;
            var completion = $"{Prefix}{candidate.Text}{Suffix}";
            yield return new CompletionResult(completion, candidate.Text, ResultType, candidate.Description);
        }
    }
}
