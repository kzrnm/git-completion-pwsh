// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Context;
public partial class CompletionContext
{
    public IEnumerable<string> GitRemote()
    {
        using var p = Git("remote");
        while (p.StandardOutput.ReadLine() is { Length: > 0 } line)
        {
            yield return line;
        }
    }

    // __git_pseudoref_exists
    public bool GitPseudorefExists(string @ref)
    {
        var headFile = $"{RepoPath}/HEAD";
        string? head = null;
        if (File.Exists(headFile))
        {
            try
            {
                using var fs = new StreamReader(headFile);
                head = fs.ReadLine();
            }
            catch (FileNotFoundException)
            {
            }
        }

        // If the reftable is in use, we have to shell out to 'git rev-parse'
        // to determine whether the ref exists instead of looking directly in
        // the filesystem to determine whether the ref exists. Otherwise, use
        // Bash builtins since executing Git commands are expensive on some
        // platforms.
        if (head == "ref: refs/heads/.invalid")
        {
            using var p = Git($"show-ref --exists {@ref}");
            return p.ExitCode == 0;
        }

        return File.Exists($"{RepoPath}/{@ref}");
    }

    static readonly Regex lsTreeRegex = new(@"(?<mode>\S+) (?<type>\S+) (?<name>\S+)\t(?<path>.+)", RegexOptions.CultureInvariant);
    public IEnumerable<string> LsTreeFiles(string treeIsh)
    {
        string[] lsTree;
        using (var p = Git($"ls-tree {treeIsh} -z"))
        {
            lsTree = p.StandardOutput.ReadToEnd().Split(['\0'], StringSplitOptions.RemoveEmptyEntries);
        }
        foreach (var line in lsTree)
        {
            if (lsTreeRegex.Match(line) is { Success: true, Groups: var m })
            {
                var path = m["path"].Value;
                if (m["type"].Value == "tree")
                {
                    path += "/";
                }
                yield return path;
            }
        }
    }

    enum ListRefsFrom
    {
        Path,
        Remote,
        Url,
    }

    static readonly Regex hatRefsPrefixRegex = new(@"\^?refs(/.*)?", RegexOptions.CultureInvariant);
    static readonly Regex refsPrefixRegex = new(@"refs(/.*)?", RegexOptions.CultureInvariant);
    static readonly Regex spaceSplitterRegex = new(@"^\S+\s+(.+)", RegexOptions.CultureInvariant);

    // __git_refs
    // Lists refs from the local (by default) or from a remote repository.
    // It accepts 0, 1 or 2 arguments:
    // 1: The remote to list refs from (optional; ignored, if set but empty).
    // Can be the name of a configured remote, a path, or a URL.
    // 2: In addition to local refs, list unique branches from refs/remotes/ for
    //    'git checkout's tracking DWIMery (optional; ignored, if set but empty).
    // 3: A prefix to be added to each listed ref (optional).
    // 4: List only refs matching this word (optional; list all refs if unset or
    // empty).
    // 5: A suffix to be appended to each listed ref (optional; ignored, if set
    // but empty).
    //
    // Use gitCompleteRefs() instead.
    public IEnumerable<string> Refs(string current, string remote = "")
    {
        var prefix = "";
        var listRefsFrom = ListRefsFrom.Path;
        var match = current;
        var umatch = current;
        string? ignoreCase = null;

        var dir = RepoPath;
        if (remote.Length == 0)
        {
            if (dir.Length == 0)
            {
                yield break;
            }
        }
        else
        {
            if (GitRemote().Contains(remote))
            {
                // configured remote takes precedence over a
                // local directory with the same name
                listRefsFrom = ListRefsFrom.Remote;
            }
            else if (Directory.Exists($"{remote}/.git"))
            {
                dir = $"{remote}/.git";
            }
            else if (Directory.Exists(remote))
            {
                dir = remote;
            }
            else
            {
                listRefsFrom = ListRefsFrom.Url;
            }
        }

        if (Settings.IgnoreCase)
        {
            ignoreCase = "--ignore-case";
            umatch = current.ToUpperInvariant();
        }

        if (listRefsFrom == ListRefsFrom.Path)
        {
            if (current.StartsWith("^"))
            {
                current = current.Substring(1);
                match = match.Substring(1);
                umatch = umatch.Substring(1);
                prefix = "^";
            }

            string format;
            string[] @refs;
            if (hatRefsPrefixRegex.IsMatch(current))
            {
                format = "refname";
                @refs = [$"{match}*", $"{match}*/**"];
            }
            else
            {
                var heads = new string[] { "HEAD", "FETCH_HEAD", "ORIG_HEAD", "MERGE_HEAD", "REBASE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD", "BISECT_HEAD", "AUTO_MERGE" };
                foreach (var head in heads)
                {
                    if (head.StartsWith(match) || head.StartsWith(umatch))
                    {
                        if (File.Exists($"{dir}/{head}"))
                        {
                            yield return $"{prefix}{head}";
                        }
                    }
                }

                format = "refname:strip=2";
                @refs = [
                    $"refs/tags/{match}*",
                    $"refs/tags/{match}*/**",
                    $"refs/heads/{match}*",
                    $"refs/heads/{match}*/**",
                    $"refs/remotes/{match}*",
                    $"refs/remotes/{match}*/**"
                ];
            }
            var formatArgs = $"--format={prefix}%({format})";
            using var p = Git(overrideGitDir: dir, $"for-each-ref {formatArgs} {ignoreCase} {@refs}");
            while (p.StandardOutput.ReadLine() is { Length: > 0 } line)
            {
                yield return line;
            }
        }

        if (refsPrefixRegex.IsMatch(current))
        {
            using var p = Git($"ls-remote {remote} {$"{match}*"}");
            while (p.StandardOutput.ReadLine() is { Length: > 0 } line)
            {
                if (spaceSplitterRegex.Match(line) is { Success: true, Groups: var m })
                {
                    var h = m[1].Value;
                    if (!h.EndsWith("^{}"))
                    {
                        yield return h;
                    }
                }
            }
        }
        else if (listRefsFrom == ListRefsFrom.Remote)
        {
            if ("HEAD".StartsWith(match))
            {
                yield return "HEAD";
            }
            using var p = Git($"""for-each-ref "--format=%(refname:strip=3)" {ignoreCase} {
                [$"refs/remotes/{remote}/{match}*",
                $"refs/remotes/{remote}/{match}*/**"
                ]}""");
            while (p.StandardOutput.ReadLine() is { Length: > 0 } line)
            {
                yield return line;
            }
        }
        else
        {
            string? querySymref = null;
            if ("HEAD".StartsWith(match))
            {
                querySymref = "HEAD";
            }

            using var p = Git($"ls-remote {remote} {querySymref} {$"refs/tags/{match}*"} {$"refs/heads/{match}*"} {$"refs/remotes/{match}*"}");
            while (p.StandardOutput.ReadLine() is { Length: > 0 } line)
            {
                if (spaceSplitterRegex.Match(line) is { Success: true, Groups: var m })
                {
                    var h = m[1].Value;
                    if (!line.EndsWith("^{}"))
                    {
                        if (h.StartsWith("refs/") && h.IndexOf('/', 5) is > 0 and var ix)
                        {
                            yield return h.Substring(ix);
                        }
                        else
                        {
                            yield return line;
                        }
                    }
                }
            }
        }
    }
}
