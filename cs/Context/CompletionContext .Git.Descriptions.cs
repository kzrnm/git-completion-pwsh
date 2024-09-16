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
    // Command
    private Dictionary<string, string>? _GitCommandDescriptionAll;
    private Dictionary<string, string> GitCommandDescriptionAll => _GitCommandDescriptionAll ??=
        ListGitCommandDescriptions().ToDictionary(t => t.Name, t => t.Value);
    private IEnumerable<(string Name, string Value)> ListGitCommandDescriptions()
    {
        using var p = Git("--no-pager help --verbose --all --no-external-commands --no-aliases");
        Regex regex = new(@"\s{2}(\S+)\s+(.+)", RegexOptions.CultureInvariant);
        while (p.StandardOutput.ReadLine() is string line)
        {
            if (regex.Match(line) is { Success: true, Groups: var m })
            {
                yield return (m[1].Value, m[2].Value);
            }
        }
    }

    public string? GitCommandDescription(string command)
    {
        GitCommandDescriptionAll.TryGetValue(command, out var result);
        return result;
    }
}
