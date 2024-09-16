// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Linq;

namespace Kzrnm.GitCompletion.Completion;

internal static class GitConstants
{
    public static string[] DiffAlgorithms => ["myers", "minimal", "patience", "histogram"];
    public static string[] DiffSubmoduleFormats => ["diff", "log", "short"];

    public static string[] PushRecurseSubmodules => ["check", "on-demand", "only"];
    public static string[] FetchRecurseSubmodules => ["yes", "on-demand", "no"];

    public static string[] ColorMovedOpts => ["no", "default", "plain", "blocks", "zebra", "dimmed-zebra"];

    public static string[] ColorMovedWsOpts => [
        "no", "ignore-space-at-eol", "ignore-space-change",
        "ignore-all-space", "allow-indentation-change"];

    public static string[] WsErrorHighlightOpts => ["context", "old", "new", "all", "default"];

    // Options for the diff machinery (diff, log, show, stash, range-diff, ...)
    public static string[] DiffCommonOptions => ["--stat", "--numstat", "--shortstat", "--summary",
        "--patch-with-stat", "--name-only", "--name-status", "--color",
        "--no-color", "--color-words", "--no-renames", "--check",
        "--color-moved", "--color-moved=", "--no-color-moved",
        "--color-moved-ws=", "--no-color-moved-ws",
        "--full-index", "--binary", "--abbrev", "--diff-filter=",
        "--find-copies", "--find-object", "--find-renames",
        "--no-relative", "--relative",
        "--find-copies-harder", "--ignore-cr-at-eol",
        "--text", "--ignore-space-at-eol", "--ignore-space-change",
        "--ignore-all-space", "--ignore-blank-lines", "--exit-code",
        "--quiet", "--ext-diff", "--no-ext-diff", "--unified=",
        "--no-prefix", "--src-prefix=", "--dst-prefix=",
        "--inter-hunk-context=", "--function-context",
        "--patience", "--histogram", "--minimal",
        "--raw", "--word-diff", "--word-diff-regex=",
        "--dirstat", "--dirstat=", "--dirstat-by-file",
        "--dirstat-by-file=", "--cumulative",
        "--diff-algorithm=", "--default-prefix",
        "--submodule", "--submodule=", "--ignore-submodules",
        "--indent-heuristic", "--no-indent-heuristic",
        "--textconv", "--no-textconv", "--break-rewrites",
        "--patch", "--no-patch", "--cc", "--combined-all-paths",
        "--anchored=", "--compact-summary", "--ignore-matching-lines=",
        "--irreversible-delete", "--line-prefix", "--no-stat",
        "--output=", "--output-indicator-context=",
        "--output-indicator-new=", "--output-indicator-old=",
        "--ws-error-highlight=",
        "--pickaxe-all", "--pickaxe-regex", "--patch-with-raw"];

    // Options for diff/difftool
    public static string[] DiffDifftoolOptions => new[]{
        "--cached", "--staged",
        "--base", "--ours", "--theirs", "--no-index", "--merge-base",
        "--ita-invisible-in-index", "--ita-visible-in-index"}.Concat(DiffCommonOptions).ToArray();

    // Options that go well for log, shortlog and gitk
    public static string[] LogCommonOptions => ["--not", "--all",
        "--branches", "--tags", "--remotes",
        "--first-parent", "--merges", "--no-merges",
        "--max-count=",
        "--max-age=", "--since=", "--after=",
        "--min-age=", "--until=", "--before=",
        "--min-parents=", "--max-parents=",
        "--no-min-parents", "--no-max-parents",
        "--alternate-refs", "--ancestry-path",
        "--author-date-order", "--basic-regexp",
        "--bisect", "--boundary", "--exclude-first-parent-only",
        "--exclude-hidden", "--extended-regexp",
        "--fixed-strings", "--grep-reflog",
        "--ignore-missing", "--left-only", "--perl-regexp",
        "--reflog", "--regexp-ignore-case", "--remove-empty",
        "--right-only", "--show-linear-break",
        "--show-notes-by-default", "--show-pulls",
        "--since-as-filter", "--single-worktree"];

    // Options that go well for log and gitk (not shortlog)
    public static string[] LogGitkOptions => ["--dense", "--sparse", "--full-history",
        "--simplify-merges", "--simplify-by-decoration",
        "--left-right", "--notes", "--no-notes"];

    // Options that go well for log and shortlog (not gitk)
    public static string[] LogShortlogOptions => ["--author=", "--committer=", "--grep=", "--all-match", "--invert-grep"];

    // Options accepted by log and show
    public static string[] LogShowOptions => ["--diff-merges", "--diff-merges=", "--no-diff-merges", "--dd", "--remerge-diff", "--encoding="];

    public static string[] DiffMergesOpts => ["off", "none", "on", "first-parent", "1", "separate", "m", "combined", "c", "dense-combined", "cc", "remerge", "r"];

    public static string[] LogPrettyFormats => ["oneline", "short", "medium", "full", "fuller", "reference", "email", "raw", "format:", "tformat:", "mboxrd"];
    public static string[] LogDateFormats => ["relative", "iso8601", "iso8601-strict", "rfc2822", "short", "local", "default", "human", "raw", "unix", "auto:", "format:"];
    public static string[] SendEmailConfirmOptions => ["always", "never", "auto", "cc", "compose"];
    public static string[] SendEmailSuppressccOptions => ["author", "self", "cc", "bodycc", "sob", "cccmd", "body", "all"];

    public static string[] MergetoolsCommon => [
        "diffuse", "diffmerge", "ecmerge", "emerge", "kdiff3", "meld", "opendiff",
        "tkdiff", "vimdiff", "nvimdiff", "gvimdiff", "xxdiff", "araxis", "p4merge", "bc", "codecompare", "smerge"];

    public static string[] Whitespacelist => ["nowarn", "warn", "error", "error-all", "fix"];
    public static string[] Patchformat => ["mbox", "stgit", "stgit-series", "hg", "mboxrd"];
    public static string[] Showcurrentpatch => ["diff", "raw"];
    public static string[] AmInprogressOptions => ["--skip", "--continue", "--resolved", "--abort", "--quit", "--show-current-patch"];
    public static string[] QuotedCr => ["nowarn", "warn", "strip"];

    public static string[] CherryPickInprogressOptions => ["--continue", "--quit", "--abort", "--skip"];

    public static string[] ConflictSolver => ["diff3", "merge", "zdiff3"];

    public static string[] UntrackedFileModes => ["all", "no", "normal"];

    public static string[] RebaseInprogressOptions => ["--continue", "--skip", "--abort", "--quit", "--show-current-patch"];
    public static string[] RebaseInteractiveInprogressOptions => RebaseInprogressOptions.Append("--edit-todo").ToArray();
}