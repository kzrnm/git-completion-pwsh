# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
$script:gitPushRecurseSubmodules = [ordered]@{
    'check'     = 'verify that all submodule commits that changed in the revisions to be pushed are available on at least one remote of the submodule';
    'on-demand' = 'all submodules that changed in the revisions to be pushed will be pushed';
    'only'      = 'all submodules will be pushed while the superproject is left unpushed';
    'no'        = '(default) no submodules are pushed';
}

$script:gitFetchRecurseSubmodules = [ordered]@{
    'yes'       = 'all submodules are fetched';
    'on-demand' = '(default) only changed submodules are fetched';
    'no'        = 'no submodules are fetched';
}

$script:gitDiffAlgorithms = [ordered]@{
    'myers'     = '(default) The basic greedy diff algorithm';
    'minimal'   = 'Spend extra time to make sure the smallest possible diff is produced';
    'patience'  = 'Use "patience diff" algorithm when generating patches';
    'histogram' = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
}

$script:gitDiffSubmoduleFormats = [ordered]@{
    'diff'  = 'Shows an inline diff of the changed contents of the submodule';
    'log'   = 'Lists the commits in the range like "git submodule summary" does';
    'short' = '(default) Shows the names of the commits at the beginning and end of the range';
}

$script:gitColorMovedOpts = 'no', 'default', 'plain', 'blocks', 'zebra', 'dimmed-zebra'

$script:gitColorMovedWsOpts = 'no', 'ignore-space-at-eol', 'ignore-space-change',
'ignore-all-space', 'allow-indentation-change'

$script:gitWsErrorHighlightOpts = 'context', 'old', 'new', 'all', 'default'

# Options for the diff machinery (diff, log, show, stash, range-diff, ...)
$script:gitDiffCommonOptions = '--stat', '--numstat', '--shortstat', '--summary',
'--patch-with-stat', '--name-only', '--name-status', '--color',
'--no-color', '--color-words', '--no-renames', '--check',
'--color-moved', '--color-moved=', '--no-color-moved',
'--color-moved-ws=', '--no-color-moved-ws',
'--full-index', '--binary', '--abbrev', '--diff-filter=',
'--find-copies', '--find-object', '--find-renames',
'--no-relative', '--relative',
'--find-copies-harder', '--ignore-cr-at-eol',
'--text', '--ignore-space-at-eol', '--ignore-space-change',
'--ignore-all-space', '--ignore-blank-lines', '--exit-code',
'--quiet', '--ext-diff', '--no-ext-diff', '--unified=',
'--no-prefix', '--src-prefix=', '--dst-prefix=',
'--inter-hunk-context=', '--function-context',
'--patience', '--histogram', '--minimal',
'--raw', '--word-diff', '--word-diff-regex=',
'--dirstat', '--dirstat=', '--dirstat-by-file',
'--dirstat-by-file=', '--cumulative',
'--diff-algorithm=', '--default-prefix',
'--submodule', '--submodule=', '--ignore-submodules',
'--indent-heuristic', '--no-indent-heuristic',
'--textconv', '--no-textconv', '--break-rewrites',
'--patch', '--no-patch', '--cc', '--combined-all-paths',
'--anchored=', '--compact-summary', '--ignore-matching-lines=',
'--irreversible-delete', '--line-prefix', '--no-stat',
'--output=', '--output-indicator-context=',
'--output-indicator-new=', '--output-indicator-old=',
'--ws-error-highlight=',
'--pickaxe-all', '--pickaxe-regex', '--patch-with-raw'

# Options for diff/difftool
$script:gitDiffDifftoolOptions = @('--cached', '--staged',
    '--base', '--ours', '--theirs', '--no-index', '--merge-base',
    '--ita-invisible-in-index', '--ita-visible-in-index') + $GitDiffCommonOptions

# Options that go well for log, shortlog and gitk
$script:gitLogCommonOptions = '--not', '--all',
'--branches', '--tags', '--remotes',
'--first-parent', '--merges', '--no-merges',
'--max-count=',
'--max-age=', '--since=', '--after=',
'--min-age=', '--until=', '--before=',
'--min-parents=', '--max-parents=',
'--no-min-parents', '--no-max-parents',
'--alternate-refs', '--ancestry-path',
'--author-date-order', '--basic-regexp',
'--bisect', '--boundary', '--exclude-first-parent-only',
'--exclude-hidden', '--extended-regexp',
'--fixed-strings', '--grep-reflog',
'--ignore-missing', '--left-only', '--perl-regexp',
'--reflog', '--regexp-ignore-case', '--remove-empty',
'--right-only', '--show-linear-break',
'--show-notes-by-default', '--show-pulls',
'--since-as-filter', '--single-worktree'

# Options that go well for log and gitk (not shortlog)
$script:gitLogGitkOptions = '--dense', '--sparse', '--full-history',
'--simplify-merges', '--simplify-by-decoration',
'--left-right', '--notes', '--no-notes'

# Options that go well for log and shortlog (not gitk)
$script:gitLogShortlogOptions = '--author=', '--committer=', '--grep=', '--all-match', '--invert-grep'

# Options accepted by log and show
$script:gitLogShowOptions = '--diff-merges', '--diff-merges=', '--no-diff-merges',
'--dd', '--remerge-diff', '--encoding='

$script:gitDiffMergesOpts = 'off', 'none', 'on', 'first-parent', '1', 'separate', 'm', 'combined', 'c', 'dense-combined', 'cc', 'remerge', 'r'

$script:gitLogPrettyFormats = 'oneline', 'short', 'medium', 'full', 'fuller', 'reference', 'email', 'raw', 'format:', 'tformat:', 'mboxrd'
$script:gitLogDateFormats = 'relative', 'iso8601', 'iso8601-strict', 'rfc2822', 'short', 'local', 'default', 'human', 'raw', 'unix', 'auto:', 'format:'
$script:gitSendEmailConfirmOptions = 'always', 'never', 'auto', 'cc', 'compose'
$script:gitSendEmailSuppressccOptions = 'author', 'self', 'cc', 'bodycc', 'sob', 'cccmd', 'body', 'all'


$script:gitMergetoolsCommon = 'diffuse', 'diffmerge', 'ecmerge', 'emerge', 'kdiff3', 'meld', 'opendiff',
'tkdiff', 'vimdiff', 'nvimdiff', 'gvimdiff', 'xxdiff', 'araxis', 'p4merge', 'bc', 'codecompare', 'smerge'

$script:gitWhitespacelist = 'nowarn', 'warn', 'error', 'error-all', 'fix'
$script:gitPatchformat = 'mbox', 'stgit', 'stgit-series', 'hg', 'mboxrd'
$script:gitShowcurrentpatch = 'diff', 'raw'
$script:gitAmInprogressOptions = '--skip', '--continue', '--resolved', '--abort', '--quit', '--show-current-patch'
$script:gitQuotedCr = 'nowarn', 'warn', 'strip'

$script:gitCherryPickInprogressOptions = '--continue', '--quit', '--abort', '--skip'

$script:gitConflictSolver = @(
    [PSCustomObject]@{
        ListItemText = 'diff3';
        Tooltip      = "Adds the common ancestor's content, providing a three-way comparison";
    }
    [PSCustomObject]@{
        ListItemText = 'merge';
        Tooltip      = '(default) Showing only current changes and the incoming changes';
    }
    [PSCustomObject]@{
        ListItemText = 'zdiff3';
        Tooltip      = 'Similar to diff3 but minimizes the conflict markers by moving common surrounding lines outside the conflicted block';
    }
)

$script:gitUntrackedFileModes = 'all', 'no', 'normal'

$script:gitRebaseInprogressOptions = '--continue', '--skip', '--abort', '--quit', '--show-current-patch'
$script:gitRebaseInteractiveInprogressOptions = $script:gitRebaseInprogressOptions + '--edit-todo'


$script:gitShowOpts = @(
    '--pretty=', '--format=', '--abbrev-commit', '--no-abbrev-commit', '--oneline', '--show-signature',
    '--expand-tabs', '--expand-tabs=', '--no-expand-tabs'
) + $gitLogShowOptions + $gitDiffCommonOptions