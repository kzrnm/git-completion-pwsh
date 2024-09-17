// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System;
using System.Linq;

namespace Kzrnm.GitCompletion.Context;


public enum IndexFilesOptions
{
    None,
    Cached,
    CachedAndUntracked,
    Updated,
    Modified,
    Untracked,
    Ignored,
    All,
    AllWithIgnored,
    Staged,
    Committable,
}

public partial class CompletionContext
{
    /// <summary>
    /// __git_index_files
    /// __git_ls_files_helper
    /// </summary>
    /// <returns>sorted files</returns>
    public string[] GitIndexFiles(string current, string? baseDir, IndexFilesOptions options)
    {
        string[] baseDirOpts = baseDir == null ? [] : ["-C", baseDir];
        var pattern = current == "" ? "." : $"{current}*";
        string cmdResult = options switch
        {
            IndexFilesOptions.None => LsFiles([], baseDirOpts, pattern),
            IndexFilesOptions.Cached => LsFiles(["--cached"], baseDirOpts, pattern),
            IndexFilesOptions.CachedAndUntracked => LsFiles(["--cached", "--others", "--directory"], baseDirOpts, pattern),
            IndexFilesOptions.Updated => LsFiles(["--others", "--modified", "--no-empty-directory"], baseDirOpts, pattern),
            IndexFilesOptions.Modified => LsFiles(["--modified"], baseDirOpts, pattern),
            IndexFilesOptions.Untracked => LsFiles(["--others", "--directory"], baseDirOpts, pattern),
            IndexFilesOptions.Ignored => LsFiles(["--ignored", "--others", "--exclude=*"], baseDirOpts, pattern),
            IndexFilesOptions.All => LsFiles(["--cached", "--directory", "--no-empty-directory", "--others"], baseDirOpts, pattern),
            IndexFilesOptions.AllWithIgnored => LsFiles(["--cached", "--directory", "--no-empty-directory", "--others", "--ignored", "--exclude=*"], baseDirOpts, pattern),
            IndexFilesOptions.Staged => Staged(baseDirOpts, pattern),
            IndexFilesOptions.Committable => Committable(baseDirOpts, pattern),
            _ => "",
        };

        var result = cmdResult.Split(['\0'], StringSplitOptions.RemoveEmptyEntries)
            .Where(f => !string.IsNullOrEmpty(f))
            .Select(f => $"{baseDir}{f}")
            .ToArray();

        Array.Sort(result, StringComparer.Ordinal);
        return result;

        string LsFiles(string[] options, string[] baseDirOpts, string pattern)
        {
            using var p = Git($"{baseDirOpts} ls-files -z --exclude-standard {options} \"--\" {pattern}");
            return p.StandardOutput.ReadToEnd();
        }
        string Staged(string[] baseDirOpts, string pattern)
        {
            using var p = Git($"{baseDirOpts} diff --staged -z --name-only --relative \"--\" {pattern}");
            return p.StandardOutput.ReadToEnd();
        }
        string Committable(string[] baseDirOpts, string pattern)
        {
            using var p = Git($"{baseDirOpts} diff-index -z --name-only --relative HEAD \"--\" {pattern}");
            return p.StandardOutput.ReadToEnd();
        }
    }
}