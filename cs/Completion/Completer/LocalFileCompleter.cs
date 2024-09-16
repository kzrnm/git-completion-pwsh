// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion.Completer;

internal readonly record struct LocalFileCompleter(
    SessionState SessionState,
    string Current,
    CompletionResultType ResultType = CompletionResultType.ProviderItem,
    string Prefix = "",
    string BaseDir = "",
    bool RemovePrefix = true)
{
    public string Current { get; } = RemovePrefix && Current.StartsWith(Prefix) ? Current.Substring(Prefix.Length) : Current;

    public IEnumerable<CompletionResult> Complete(IEnumerable<string> candidates)
    {
        foreach (var file in candidates)
        {
            if (!file.StartsWith(Current)) continue;

            var fullpath = SessionState.Path.GetResolvedPSPathFromPSPath($"{BaseDir switch
            {
                { Length: 0 } => ".",
                var d => d,
            }}/{file}").FirstOrDefault()?.Path;

            var completion = $"{Prefix}{file}";
            var description = fullpath ?? file;

            yield return new CompletionResult(completion, file, ResultType, description.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar));
        }
    }
}
