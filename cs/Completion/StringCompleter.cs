using System.Collections.Generic;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion;

internal static class StringCompleter
{
    public static StringCompleter<EmptyDescriptionBuilder> Create(
        string Current,
        CompletionResultType ResultType,
        string Prefix = "",
        string Suffix = "",
        HashSet<string>? Exclude = null,
        bool RemovePrefix = true)
        => new(
            Current,
            ResultType,
            Prefix,
            Suffix,
            Exclude,
            RemovePrefix);

    public static StringCompleter<T> Create<T>(
        string Current,
        CompletionResultType ResultType,
        string Prefix = "",
        string Suffix = "",
        HashSet<string>? Exclude = null,
        bool RemovePrefix = true) where T : struct, IDescriptionBuilder
        => new(
            Current,
            ResultType,
            Prefix,
            Suffix,
            Exclude,
            RemovePrefix);
}

internal readonly record struct StringCompleter<T>(
    string Current,
    CompletionResultType ResultType,
    string Prefix = "",
    string Suffix = "",
    HashSet<string>? Exclude = null,
    bool RemovePrefix = true)
        where T : struct, IDescriptionBuilder
{
    public string Current { get; } = RemovePrefix && Current.StartsWith(Prefix) ? Current.Substring(Prefix.Length) : Current;

    public IEnumerable<CompletionResult> Complete(IEnumerable<string> candidates)
    {
        foreach (var candidate in candidates)
        {
            if (!candidate.StartsWith(Current)) continue;
            var completion = $"{Prefix}{candidate}{Suffix}";
            if (Exclude?.Contains(completion) == true) continue;

            var description = new T().Description(candidate) ?? candidate;

            yield return new CompletionResult(completion, candidate, ResultType, description);
        }
    }
}
