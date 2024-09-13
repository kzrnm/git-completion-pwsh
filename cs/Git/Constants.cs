// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
namespace Kzrnm.GitCompletion.Git;
internal class Constants
{
    // Options that go well for log, shortlog and gitk
    public static readonly string[] LogCommonOptions = [
        "--not",
        "--all",
        "--branches",
        "--tags",
        "--remotes",
        "--first-parent",
        "--merges",
        "--no-merges",
        "--max-count=",
        "--max-age=",
        "--since=",
        "--after=",
        "--min-age=",
        "--until=",
        "--before=",
        "--min-parents=",
        "--max-parents=",
        "--no-min-parents",
        "--no-max-parents",
        "--alternate-refs",
        "--ancestry-path",
        "--author-date-order",
        "--basic-regexp",
        "--bisect",
        "--boundary",
        "--exclude-first-parent-only",
        "--exclude-hidden",
        "--extended-regexp",
        "--fixed-strings",
        "--grep-reflog",
        "--ignore-missing",
        "--left-only",
        "--perl-regexp",
        "--reflog",
        "--regexp-ignore-case",
        "--remove-empty",
        "--right-only",
        "--show-linear-break",
        "--show-notes-by-default",
        "--show-pulls",
        "--since-as-filter",
        "--single-worktree",
    ];

    // Options that go well for log and gitk (not shortlog)
    public static readonly string[] LogGitkOptions = [
        "--dense",
        "--sparse",
        "--full-history",
        "--simplify-merges",
        "--simplify-by-decoration",
        "--left-right",
        "--notes",
        "--no-notes",
    ];
}
