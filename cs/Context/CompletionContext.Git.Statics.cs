// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Context;
public partial class CompletionContext
{
    private static string[]? _MergeStrategies;
    public string[] MergeStrategies => _MergeStrategies ??= ListMergeStrategies().ToArray();
    private IEnumerable<string> ListMergeStrategies()
    {
        Regex mergeStrategiesRegex = new(@".*:\s*(.*)\s*\.", RegexOptions.CultureInvariant);
        using var p = GitRaw("merge -s help", stderr: true, environmentVariables: [("LANG", "C"), ("LC_ALL", "C")]);
        while (p.StandardError.ReadLine() is string line)
        {
            if (line.Contains("Available strategies are: ")
                && mergeStrategiesRegex.Match(line) is { Success: true, Groups: var m })
            {
                foreach (var sp in m[1].Value.Split([' '], StringSplitOptions.RemoveEmptyEntries))
                {
                    yield return sp;
                }
            }
        }
    }

    public IEnumerable<string> GitAllCommands(params string[] categories)
    {
        var cmd = $"--list-cmds={string.Join(",", categories)}";
        using var p = Git(cmd, stderr: false);
        while (p.StandardOutput.ReadLine() is string line)
        {
            if (line.Length > 0)
            {
                yield return line;
            }
        }
    }
}
