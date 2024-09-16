// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Collections.Generic;
using System.Linq;

namespace Kzrnm.GitCompletion.Context;
public partial class CompletionContext
{

    private static string[]? _GitConfigSections;
    public string[] GitConfigSections => _GitConfigSections ??= ListGitConfigSections().OrderBy(c => c).ToArray();
    private IEnumerable<string> ListGitConfigSections()
    {
        using var p = GitRaw("--no-pager help --config-sections-for-completion", stderr: false);
        while (p.StandardOutput.ReadLine() is string line)
        {
            if (line.Length > 0)
                yield return line;
        }
    }

    private static string[]? _GitConfigVars;
    public string[] GitConfigVars => _GitConfigVars ??= ListGitConfigVars().OrderBy(c => c).ToArray();
    private IEnumerable<string> ListGitConfigVars()
    {
        using var p = GitRaw("--no-pager help --config-for-completion", stderr: false);
        while (p.StandardOutput.ReadLine() is string line)
        {
            if (line.Length > 0)
                yield return line;
        }
    }

    private ILookup<string?, string[]>? _GitConfigVarsGroup;
    public ILookup<string?, string[]> GitConfigVarsGroup => _GitConfigVarsGroup
        ??= GitConfigVars.Select(c => c.Split('.')).ToLookup(t => t.Length > 0 ? t[0] : null);


    private static string[]? _GitConfigVarsAll;
    public string[] GitConfigVarsAll => _GitConfigVarsAll ??= ListGitConfigVarsAll().ToArray();
    private IEnumerable<string> ListGitConfigVarsAll()
    {
        using var p = GitRaw("--no-pager help --config", stderr: false);

        while (p.StandardOutput.ReadLine() is string line)
        {
            if (line.Length > 0)
                yield return line;
        }
    }

    private ILookup<string?, string[]>? _GitConfigVarsAllGroup;
    public ILookup<string?, string[]> GitConfigVarsAllGroup => _GitConfigVarsAllGroup
        ??= GitConfigVarsAll.Select(c => c.Split('.')).ToLookup(t => t.Length > 0 ? t[0] : null);

    private static string[]? _ConfigSections;
    public string[] ConfigSections => _ConfigSections ??= ListConfigSections().ToArray();
    private IEnumerable<string> ListConfigSections()
    {
        using var p = GitRaw("--no-pager help  --config-sections-for-completion", stderr: false);
        while (p.StandardOutput.ReadLine() is string line)
        {
            if (line.Length > 0)
                yield return line;
        }
    }

    private static readonly Dictionary<string, string[]> _FirstLevelGitConfigVarsForSection = new();
    public string[] FirstLevelGitConfigVarsForSection(string section)
    {
        if (_FirstLevelGitConfigVarsForSection.TryGetValue(section, out var a))
        {
            return a;
        }
        return _FirstLevelGitConfigVarsForSection[section] = ListFirstLevelGitConfigVarsForSection(section).ToArray();
    }
    private IEnumerable<string> ListFirstLevelGitConfigVarsForSection(string section)
    {
        return GitConfigVarsGroup[section]
            ?.Select(t => t.Length > 1 ? t[1] : null)
            ?.OfType<string>()
            ?.Where(s => s.Length > 0) ?? [];
    }

    private static readonly Dictionary<string, string[]> _SecondLevelGitConfigVarsForSection = new();
    public string[] SecondLevelGitConfigVarsForSection(string section)
    {
        if (_SecondLevelGitConfigVarsForSection.TryGetValue(section, out var a))
        {
            return a;
        }
        return _SecondLevelGitConfigVarsForSection[section] = ListSecondLevelGitConfigVarsForSection(section).ToArray();
    }
    private IEnumerable<string> ListSecondLevelGitConfigVarsForSection(string section)
    {
        return GitConfigVarsAllGroup[section]
            ?.Select(t => t.Length > 2 ? t[2] : null)
            ?.OfType<string>()
            ?.Where(s => s.Length > 0) ?? [];
    }
}
