# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
$script:gitCherryPickInprogressOptions = '--continue', '--quit', '--abort', '--skip'
$script:gitAmInprogressOptions = '--skip', '--continue', '--resolved', '--abort', '--quit', '--show-current-patch'

$script:gitRebaseInprogressOptions = '--continue', '--skip', '--abort', '--quit', '--show-current-patch'
$script:gitRebaseInteractiveInprogressOptions = $script:gitRebaseInprogressOptions + '--edit-todo'

$script:gitPushRecurseSubmodules = [pscustomobject[]]@(
    @{ListItemText = 'check'; Tooltip = 'verify that all submodule commits that changed in the revisions to be pushed are available on at least one remote of the submodule'; }
    @{ListItemText = 'on-demand'; Tooltip = 'all submodules that changed in the revisions to be pushed will be pushed'; }
    @{ListItemText = 'only'; Tooltip = 'all submodules will be pushed while the superproject is left unpushed'; }
    @{ListItemText = 'no'; Tooltip = '(default) no submodules are pushed'; }
)

$script:gitFetchRecurseSubmodules = [pscustomobject[]]@(
    @{ListItemText = 'yes'; Tooltip = 'all submodules are fetched'; }
    @{ListItemText = 'on-demand'; Tooltip = '(default) only changed submodules are fetched'; }
    @{ListItemText = 'no'; Tooltip = 'no submodules are fetched'; }
)

$script:gitConflictSolver = [pscustomobject[]]@(
    @{ListItemText = 'diff3'; Tooltip = "Adds the common ancestor's content, providing a three-way comparison"; }
    @{ListItemText = 'merge'; Tooltip = '(default) Showing only current changes and the incoming changes'; }
    @{ListItemText = 'zdiff3'; Tooltip = 'Similar to diff3 but minimizes the conflict markers by moving common surrounding lines outside the conflicted block'; }
)

$script:gitDiffAlgorithms = [pscustomobject[]]@(
    @{ListItemText = 'myers'; Tooltip = '(default) The basic greedy diff algorithm'; }
    @{ListItemText = 'minimal'; Tooltip = 'Spend extra time to make sure the smallest possible diff is produced'; }
    @{ListItemText = 'patience'; Tooltip = 'Use "patience diff" algorithm when generating patches'; }
    @{ListItemText = 'histogram'; Tooltip = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"'; }
)

$script:gitDiffSubmoduleFormats = [pscustomobject[]]@(
    @{ListItemText = 'diff'; Tooltip = 'Shows an inline diff of the changed contents of the submodule'; }
    @{ListItemText = 'log'; Tooltip = 'Lists the commits in the range like "git submodule summary" does'; }
    @{ListItemText = 'short'; Tooltip = '(default) Shows the names of the commits at the beginning and end of the range'; }
)

$script:gitColorMovedOpts = [pscustomobject[]]@(
    @{ListItemText = 'no'; }
    @{ListItemText = 'default'; }
    @{ListItemText = 'plain'; }
    @{ListItemText = 'blocks'; }
    @{ListItemText = 'zebra'; }
    @{ListItemText = 'dimmed-zebra'; }
)

$script:gitColorMovedWsOpts = [pscustomobject[]]@(
    @{ListItemText = 'no'; Tooltip = 'Do not ignore whitespace when performing move detection'; }
    @{ListItemText = 'ignore-space-at-eol'; Tooltip = 'Ignore changes in whitespace at EOL'; }
    @{ListItemText = 'ignore-space-change'; Tooltip = 'Ignore changes in amount of whitespace'; }
    @{ListItemText = 'ignore-all-space'; Tooltip = 'Ignore whitespace when comparing lines'; }
    @{ListItemText = 'allow-indentation-change'; Tooltip = 'Initially ignore any whitespace in the move detection, then group the moved code blocks only into a block if the change in whitespace is the same per line'; }
)
$script:gitColorMovedWsOpts = [pscustomobject[]]@(
    @{ListItemText = 'no'; }
    @{ListItemText = 'ignore-space-at-eol'; }
    @{ListItemText = 'ignore-space-change'; }
    @{ListItemText = 'ignore-all-space'; }
    @{ListItemText = 'allow-indentation-change'; }
)

$script:gitWsErrorHighlightOpts = [pscustomobject[]]@(
    @{ListItemText = 'context'; }
    @{ListItemText = 'old'; }
    @{ListItemText = 'new'; }
    @{ListItemText = 'all'; }
    @{ListItemText = 'default'; }
)

# Options for the diff machinery (diff, log, show, stash, range-diff, ...)
$script:gitDiffCommonOptions = [pscustomobject[]]@(
    @{ListItemText = '--stat'; }
    @{ListItemText = '--numstat'; }
    @{ListItemText = '--shortstat'; }
    @{ListItemText = '--summary'; }
    @{ListItemText = '--patch-with-stat'; }
    @{ListItemText = '--name-only'; }
    @{ListItemText = '--name-status'; }
    @{ListItemText = '--color'; }
    @{ListItemText = '--no-color'; }
    @{ListItemText = '--color-words'; }
    @{ListItemText = '--no-renames'; }
    @{ListItemText = '--check'; }
    @{ListItemText = '--color-moved'; }
    @{ListItemText = '--color-moved='; }
    @{ListItemText = '--no-color-moved'; }
    @{ListItemText = '--color-moved-ws='; }
    @{ListItemText = '--no-color-moved-ws'; }
    @{ListItemText = '--full-index'; }
    @{ListItemText = '--binary'; }
    @{ListItemText = '--abbrev'; }
    @{ListItemText = '--diff-filter='; }
    @{ListItemText = '--find-copies'; }
    @{ListItemText = '--find-object'; }
    @{ListItemText = '--find-renames'; }
    @{ListItemText = '--no-relative'; }
    @{ListItemText = '--relative'; }
    @{ListItemText = '--find-copies-harder'; }
    @{ListItemText = '--ignore-cr-at-eol'; }
    @{ListItemText = '--text'; }
    @{ListItemText = '--ignore-space-at-eol'; }
    @{ListItemText = '--ignore-space-change'; }
    @{ListItemText = '--ignore-all-space'; }
    @{ListItemText = '--ignore-blank-lines'; }
    @{ListItemText = '--exit-code'; }
    @{ListItemText = '--quiet'; }
    @{ListItemText = '--ext-diff'; }
    @{ListItemText = '--no-ext-diff'; }
    @{ListItemText = '--unified='; }
    @{ListItemText = '--no-prefix'; }
    @{ListItemText = '--src-prefix='; }
    @{ListItemText = '--dst-prefix='; }
    @{ListItemText = '--inter-hunk-context='; }
    @{ListItemText = '--function-context'; }
    @{ListItemText = '--patience'; }
    @{ListItemText = '--histogram'; }
    @{ListItemText = '--minimal'; }
    @{ListItemText = '--raw'; }
    @{ListItemText = '--word-diff'; }
    @{ListItemText = '--word-diff-regex='; }
    @{ListItemText = '--dirstat'; }
    @{ListItemText = '--dirstat='; }
    @{ListItemText = '--dirstat-by-file'; }
    @{ListItemText = '--dirstat-by-file='; }
    @{ListItemText = '--cumulative'; }
    @{ListItemText = '--diff-algorithm='; }
    @{ListItemText = '--default-prefix'; }
    @{ListItemText = '--submodule'; }
    @{ListItemText = '--submodule='; }
    @{ListItemText = '--ignore-submodules'; }
    @{ListItemText = '--indent-heuristic'; }
    @{ListItemText = '--no-indent-heuristic'; }
    @{ListItemText = '--textconv'; }
    @{ListItemText = '--no-textconv'; }
    @{ListItemText = '--break-rewrites'; }
    @{ListItemText = '--patch'; }
    @{ListItemText = '--no-patch'; }
    @{ListItemText = '--cc'; }
    @{ListItemText = '--combined-all-paths'; }
    @{ListItemText = '--anchored='; }
    @{ListItemText = '--compact-summary'; }
    @{ListItemText = '--ignore-matching-lines='; }
    @{ListItemText = '--irreversible-delete'; }
    @{ListItemText = '--line-prefix'; }
    @{ListItemText = '--no-stat'; }
    @{ListItemText = '--output='; }
    @{ListItemText = '--output-indicator-context='; }
    @{ListItemText = '--output-indicator-new='; }
    @{ListItemText = '--output-indicator-old='; }
    @{ListItemText = '--ws-error-highlight='; }
    @{ListItemText = '--pickaxe-all'; }
    @{ListItemText = '--pickaxe-regex'; }
    @{ListItemText = '--patch-with-raw'; }
)

# Options for diff/difftool
$script:gitDiffDifftoolOptions = [pscustomobject[]]@(
    @{ListItemText = '--cached'; }
    @{ListItemText = '--staged'; }
    @{ListItemText = '--base'; }
    @{ListItemText = '--ours'; }
    @{ListItemText = '--theirs'; }
    @{ListItemText = '--no-index'; }
    @{ListItemText = '--merge-base'; }
    @{ListItemText = '--ita-invisible-in-index'; }
    @{ListItemText = '--ita-visible-in-index'; }
) + $GitDiffCommonOptions

# Options that go well for log, shortlog and gitk
$script:gitLogCommonOptions = [pscustomobject[]]@(
    @{ListItemText = '--not'; }
    @{ListItemText = '--all'; }
    @{ListItemText = '--branches'; }
    @{ListItemText = '--tags'; }
    @{ListItemText = '--remotes'; }
    @{ListItemText = '--first-parent'; }
    @{ListItemText = '--merges'; }
    @{ListItemText = '--no-merges'; }
    @{ListItemText = '--max-count='; }
    @{ListItemText = '--max-age='; }
    @{ListItemText = '--since='; }
    @{ListItemText = '--after='; }
    @{ListItemText = '--min-age='; }
    @{ListItemText = '--until='; }
    @{ListItemText = '--before='; }
    @{ListItemText = '--min-parents='; }
    @{ListItemText = '--max-parents='; }
    @{ListItemText = '--no-min-parents'; }
    @{ListItemText = '--no-max-parents'; }
    @{ListItemText = '--alternate-refs'; }
    @{ListItemText = '--ancestry-path'; }
    @{ListItemText = '--author-date-order'; }
    @{ListItemText = '--basic-regexp'; }
    @{ListItemText = '--bisect'; }
    @{ListItemText = '--boundary'; }
    @{ListItemText = '--exclude-first-parent-only'; }
    @{ListItemText = '--exclude-hidden'; }
    @{ListItemText = '--extended-regexp'; }
    @{ListItemText = '--fixed-strings'; }
    @{ListItemText = '--grep-reflog'; }
    @{ListItemText = '--ignore-missing'; }
    @{ListItemText = '--left-only'; }
    @{ListItemText = '--perl-regexp'; }
    @{ListItemText = '--reflog'; }
    @{ListItemText = '--regexp-ignore-case'; }
    @{ListItemText = '--remove-empty'; }
    @{ListItemText = '--right-only'; }
    @{ListItemText = '--show-linear-break'; }
    @{ListItemText = '--show-notes-by-default'; }
    @{ListItemText = '--show-pulls'; }
    @{ListItemText = '--since-as-filter'; }
    @{ListItemText = '--single-worktree'; }
)

# Options that go well for log and gitk (not shortlog)
$script:gitLogGitkOptions = [pscustomobject[]]@(
    @{ListItemText = '--dense'; }
    @{ListItemText = '--sparse'; }
    @{ListItemText = '--full-history'; }
    @{ListItemText = '--simplify-merges'; }
    @{ListItemText = '--simplify-by-decoration'; }
    @{ListItemText = '--left-right'; }
    @{ListItemText = '--notes'; }
    @{ListItemText = '--no-notes'; }
)

# Options that go well for log and shortlog (not gitk)
$script:gitLogShortlogOptions = [pscustomobject[]]@(
    @{ListItemText = '--author='; }
    @{ListItemText = '--grep='; }
    @{ListItemText = '--all-match'; }
    @{ListItemText = '--invert-grep'; }
)

# Options accepted by log and show
$script:gitLogShowOptions = [pscustomobject[]]@(
    @{ListItemText = '--diff-merges'; }
    @{ListItemText = '--diff-merges='; }
    @{ListItemText = '--no-diff-merges'; }
    @{ListItemText = '--dd'; }
    @{ListItemText = '--remerge-diff'; }
    @{ListItemText = '--encoding='; }
)

$script:gitDiffMergesOpts = [pscustomobject[]]@(
    @{ListItemText = 'off'; }
    @{ListItemText = 'none'; }
    @{ListItemText = 'on'; }
    @{ListItemText = 'first-parent'; }
    @{ListItemText = '1'; }
    @{ListItemText = 'separate'; }
    @{ListItemText = 'm'; }
    @{ListItemText = 'combined'; }
    @{ListItemText = 'c'; }
    @{ListItemText = 'dense-combined'; }
    @{ListItemText = 'cc'; }
    @{ListItemText = 'remerge'; }
    @{ListItemText = 'r'; }
)

$script:gitLogPrettyFormats = [pscustomobject[]]@(
    @{ListItemText = 'oneline'; }
    @{ListItemText = 'short'; }
    @{ListItemText = 'medium'; }
    @{ListItemText = 'full'; }
    @{ListItemText = 'fuller'; }
    @{ListItemText = 'reference'; }
    @{ListItemText = 'email'; }
    @{ListItemText = 'raw'; }
    @{ListItemText = 'format:'; }
    @{ListItemText = 'tformat:'; }
    @{ListItemText = 'mboxrd'; }
)
$script:gitLogDateFormats = [pscustomobject[]]@(
    @{ListItemText = 'relative'; }
    @{ListItemText = 'iso8601'; }
    @{ListItemText = 'iso8601-strict'; }
    @{ListItemText = 'rfc2822'; }
    @{ListItemText = 'short'; }
    @{ListItemText = 'local'; }
    @{ListItemText = 'default'; }
    @{ListItemText = 'human'; }
    @{ListItemText = 'raw'; }
    @{ListItemText = 'unix'; }
    @{ListItemText = 'auto:'; }
    @{ListItemText = 'format:'; }
)
$script:gitSendEmailConfirmOptions = [pscustomobject[]]@(
    @{ListItemText = 'always'; }
    @{ListItemText = 'never'; }
    @{ListItemText = 'auto'; }
    @{ListItemText = 'cc'; }
    @{ListItemText = 'compose'; }
)
$script:gitSendEmailSuppressccOptions = [pscustomobject[]]@(
    @{ListItemText = 'author'; }
    @{ListItemText = 'self'; }
    @{ListItemText = 'cc'; }
    @{ListItemText = 'bodycc'; }
    @{ListItemText = 'sob'; }
    @{ListItemText = 'cccmd'; }
    @{ListItemText = 'body'; }
    @{ListItemText = 'all'; }
)


$script:gitMergetoolsCommon = [pscustomobject[]]@(
    @{ListItemText = 'diffuse'; }
    @{ListItemText = 'diffmerge'; }
    @{ListItemText = 'ecmerge'; }
    @{ListItemText = 'emerge'; }
    @{ListItemText = 'kdiff3'; }
    @{ListItemText = 'meld'; }
    @{ListItemText = 'opendiff'; }
    @{ListItemText = 'tkdiff'; }
    @{ListItemText = 'vimdiff'; }
    @{ListItemText = 'nvimdiff'; }
    @{ListItemText = 'gvimdiff'; }
    @{ListItemText = 'xxdiff'; }
    @{ListItemText = 'araxis'; }
    @{ListItemText = 'p4merge'; }
    @{ListItemText = 'bc'; }
    @{ListItemText = 'codecompare'; }
    @{ListItemText = 'smerge'; }
)

$script:gitWhitespacelist = [pscustomobject[]]@(
    @{ListItemText = 'nowarn'; }
    @{ListItemText = 'warn'; }
    @{ListItemText = 'error'; }
    @{ListItemText = 'error-all'; }
    @{ListItemText = 'fix'; }
)
$script:gitPatchformat = [pscustomobject[]]@(
    @{ListItemText = 'mbox'; }
    @{ListItemText = 'stgit'; }
    @{ListItemText = 'stgit-series'; }
    @{ListItemText = 'hg'; }
    @{ListItemText = 'mboxrd'; }
)
$script:gitShowcurrentpatch = [pscustomobject[]]@(
    @{ListItemText = 'diff'; }
    @{ListItemText = 'raw'; }
)
$script:gitQuotedCr = [pscustomobject[]]@(
    @{ListItemText = 'nowarn'; }
    @{ListItemText = 'warn'; }
    @{ListItemText = 'strip'; }
)

$script:gitUntrackedFileModes = [pscustomobject[]]@(
    @{ListItemText = 'all'; }
    @{ListItemText = 'no'; }
    @{ListItemText = 'normal'; }
)

$script:gitShowOpts = [pscustomobject[]]@(
    @{ListItemText = '--pretty='; }
    @{ListItemText = '--format='; }
    @{ListItemText = '--abbrev-commit'; }
    @{ListItemText = '--no-abbrev-commit'; }
    @{ListItemText = '--oneline'; }
    @{ListItemText = '--show-signature'; }
    @{ListItemText = '--expand-tabs'; }
    @{ListItemText = '--expand-tabs='; }
    @{ListItemText = '--no-expand-tabs'; }
) + $gitLogShowOptions + $gitDiffCommonOptions