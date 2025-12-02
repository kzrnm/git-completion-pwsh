# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
$script:gitCherryPickInprogressOptions = '--continue', '--quit', '--abort', '--skip' | Sort-Object
$script:gitAmInprogressOptions = '--skip', '--continue', '--resolved', '--abort', '--quit', '--show-current-patch' | Sort-Object

$script:gitRebaseInprogressOptions = '--continue', '--skip', '--abort', '--quit', '--show-current-patch' | Sort-Object
$script:gitRebaseInteractiveInprogressOptions = $script:gitRebaseInprogressOptions + '--edit-todo' | Sort-Object

$script:gitFormatPatchExtraOptions = '--full-index', '--not', '--all', '--no-prefix', '--src-prefix=', '--dst-prefix=', '--notes' | Sort-Object
$script:gitPullRebaseConfig = @(
    [pscustomobject]@{ListItemText = 'false'; Tooltip = 'Merge branch when "git pull"'; },
    [pscustomobject]@{ListItemText = 'true'; Tooltip = 'Rebase branch when "git pull"'; },
    [pscustomobject]@{ListItemText = 'merges'; Tooltip = 'Rebase branch with --rebase-merges when "git pull"'; },
    [pscustomobject]@{ListItemText = 'interactive'; Tooltip = 'Rebase in interactive mode'; }
) | Sort-Object ListItemText

$script:gitHttpProxyAuthMethod = @(
    [pscustomobject]@{ListItemText = 'anyauth'; Tooltip = 'Automatically pick a suitable authentication method'; },
    [pscustomobject]@{ListItemText = 'basic'; Tooltip = 'HTTP Basic authentication'; },
    [pscustomobject]@{ListItemText = 'digest'; Tooltip = 'HTTP Digest authentication; this prevents the password from being transmitted to the proxy in clear text'; },
    [pscustomobject]@{ListItemText = 'negotiate'; Tooltip = 'GSS-Negotiate authentication (compare the --negotiate option of curl)'; },
    [pscustomobject]@{ListItemText = 'ntlm'; Tooltip = 'NTLM authentication (compare the --ntlm option of curl)'; }
) | Sort-Object ListItemText

$script:gitColumnUiPatterns = @(
    [pscustomobject]@{ListItemText = 'always'; Tooltip = 'always show in columns'; },
    [pscustomobject]@{ListItemText = 'never'; Tooltip = 'never show in columns'; },
    [pscustomobject]@{ListItemText = 'auto'; Tooltip = 'show in columns if the output is to the terminal'; },
    [pscustomobject]@{ListItemText = 'column'; Tooltip = 'fill columns before rows'; },
    [pscustomobject]@{ListItemText = 'row'; Tooltip = 'fill rows before columns'; },
    [pscustomobject]@{ListItemText = 'plain'; Tooltip = 'show in one column'; },
    [pscustomobject]@{ListItemText = 'dense'; Tooltip = 'make unequal size columns to utilize more space'; },
    [pscustomobject]@{ListItemText = 'nodense'; Tooltip = 'make equal size columns'; }
) # | Sort-Object ListItemText # Comment out to fit the classification

$script:gitMergeStrategies = @(
    [pscustomobject]@{ListItemText = 'ours'; Tooltip = 'favoring our version'; },
    [pscustomobject]@{ListItemText = 'theirs'; Tooltip = 'opposite of ours'; },
    [pscustomobject]@{ListItemText = 'subtree'; Tooltip = 'A more advanced form of subtree strategy'; },
    [pscustomobject]@{ListItemText = 'subtree='; Tooltip = 'A more advanced form of subtree strategy'; },
    [pscustomobject]@{ListItemText = 'patience'; Tooltip = 'Deprecated synonym for diff-algorithm=patience'; },
    [pscustomobject]@{ListItemText = 'histogram'; Tooltip = 'Deprecated synonym for diff-algorithm=histogram'; },
    [pscustomobject]@{ListItemText = 'diff-algorithm='; Tooltip = 'Use a different diff algorithm while merging'; },
    [pscustomobject]@{ListItemText = 'ignore-space-change'; Tooltip = 'Ignore changes in amount of whitespace'; },
    [pscustomobject]@{ListItemText = 'ignore-all-space'; Tooltip = 'Ignore whitespace when comparing lines'; },
    [pscustomobject]@{ListItemText = 'ignore-space-at-eol'; Tooltip = 'Ignore changes in whitespace at EOL'; },
    [pscustomobject]@{ListItemText = 'renormalize'; Tooltip = 'runs a virtual check-out and check-in of all three stages'; },
    [pscustomobject]@{ListItemText = 'no-renormalize'; Tooltip = '[NO] runs a virtual check-out and check-in of all three stages'; },
    [pscustomobject]@{ListItemText = 'no-renames'; Tooltip = 'Turn off rename detection'; },
    [pscustomobject]@{ListItemText = 'find-renames'; Tooltip = 'Turn on rename detection'; },
    [pscustomobject]@{ListItemText = 'find-renames='; Tooltip = 'Turn on rename detection, optionally setting the similarity threshold'; },
    [pscustomobject]@{ListItemText = 'rename-threshold='; Tooltip = 'Deprecated synonym for find-renames='; }
) | Sort-Object ListItemText

$script:gitPushRecurseSubmodules = @(
    [pscustomobject]@{ListItemText = 'check'; Tooltip = 'verify that all submodule commits that changed in the revisions to be pushed are available on at least one remote of the submodule'; }
    [pscustomobject]@{ListItemText = 'on-demand'; Tooltip = 'all submodules that changed in the revisions to be pushed will be pushed'; }
    [pscustomobject]@{ListItemText = 'only'; Tooltip = 'all submodules will be pushed while the superproject is left unpushed'; }
    [pscustomobject]@{ListItemText = 'no'; Tooltip = '(default) no submodules are pushed'; }
) | Sort-Object ListItemText

$script:gitFetchRecurseSubmodules = @(
    [pscustomobject]@{ListItemText = 'yes'; Tooltip = 'all submodules are fetched'; }
    [pscustomobject]@{ListItemText = 'on-demand'; Tooltip = '(default) only changed submodules are fetched'; }
    [pscustomobject]@{ListItemText = 'no'; Tooltip = 'no submodules are fetched'; }
) | Sort-Object ListItemText

$script:gitConflictSolver = @(
    [pscustomobject]@{ListItemText = 'diff3'; Tooltip = "Adds the common ancestor's content, providing a three-way comparison"; }
    [pscustomobject]@{ListItemText = 'merge'; Tooltip = '(default) Showing only current changes and the incoming changes'; }
    [pscustomobject]@{ListItemText = 'zdiff3'; Tooltip = 'Similar to diff3 but minimizes the conflict markers by moving common surrounding lines outside the conflicted block'; }
) | Sort-Object ListItemText

$script:gitDiffAlgorithms = @(
    [pscustomobject]@{ListItemText = 'myers'; Tooltip = '(default) The basic greedy diff algorithm'; }
    [pscustomobject]@{ListItemText = 'minimal'; Tooltip = 'Spend extra time to make sure the smallest possible diff is produced'; }
    [pscustomobject]@{ListItemText = 'patience'; Tooltip = 'Use "patience diff" algorithm when generating patches'; }
    [pscustomobject]@{ListItemText = 'histogram'; Tooltip = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"'; }
) | Sort-Object ListItemText

$script:gitDiffSubmoduleFormats = @(
    [pscustomobject]@{ListItemText = 'diff'; Tooltip = 'Shows an inline diff of the changed contents of the submodule'; }
    [pscustomobject]@{ListItemText = 'log'; Tooltip = 'Lists the commits in the range like "git submodule summary" does'; }
    [pscustomobject]@{ListItemText = 'short'; Tooltip = '(default) Shows the names of the commits at the beginning and end of the range'; }
) | Sort-Object ListItemText

$script:gitColorMovedOpts = @(
    [pscustomobject]@{ListItemText = 'no'; Tooltip = 'Moved lines are not highlighted'; }
    [pscustomobject]@{ListItemText = 'default'; Tooltip = 'A synonym for zebra'; }
    [pscustomobject]@{ListItemText = 'plain'; Tooltip = 'Any line that is added in one location and was removed in another location will be colored with color.diff.newMoved'; }
    [pscustomobject]@{ListItemText = 'blocks'; Tooltip = 'Blocks of moved text of at least 20 alphanumeric characters are detected greedily'; }
    [pscustomobject]@{ListItemText = 'zebra'; Tooltip = 'Blocks of moved text are detected as in blocks mode'; }
    [pscustomobject]@{ListItemText = 'dimmed-zebra'; Tooltip = 'Similar to zebra, but additional dimming of uninteresting parts of moved code is performed'; }
) | Sort-Object ListItemText

$script:gitColorMovedWsOpts = @(
    [pscustomobject]@{ListItemText = 'no'; Tooltip = 'Do not ignore whitespace when performing move detection'; }
    [pscustomobject]@{ListItemText = 'ignore-space-at-eol'; Tooltip = 'Ignore changes in whitespace at EOL'; }
    [pscustomobject]@{ListItemText = 'ignore-space-change'; Tooltip = 'Ignore changes in amount of whitespace'; }
    [pscustomobject]@{ListItemText = 'ignore-all-space'; Tooltip = 'Ignore whitespace when comparing lines'; }
    [pscustomobject]@{ListItemText = 'allow-indentation-change'; Tooltip = 'Initially ignore any whitespace in the move detection, then group the moved code blocks only into a block if the change in whitespace is the same per line'; }
) | Sort-Object ListItemText

$script:gitWsErrorHighlightOpts = @(
    [pscustomobject]@{ListItemText = 'context'; Tooltip = 'Highlight whitespace errors in the context'; }
    [pscustomobject]@{ListItemText = 'old'; Tooltip = 'Highlight whitespace errors in the old lines of the diff'; }
    [pscustomobject]@{ListItemText = 'new'; Tooltip = 'Highlight whitespace errors in the new lines of the diff'; }
    [pscustomobject]@{ListItemText = 'all'; Tooltip = 'A synonym for old,new,context'; }
    [pscustomobject]@{ListItemText = 'default'; Tooltip = 'A synonym for new'; }
) | Sort-Object ListItemText

$script:gitDiffMergesOpts = @(
    [pscustomobject]@{ListItemText = 'off'; }
    [pscustomobject]@{ListItemText = 'none'; }
    [pscustomobject]@{ListItemText = 'on'; }
    [pscustomobject]@{ListItemText = 'first-parent'; }
    [pscustomobject]@{ListItemText = '1'; }
    [pscustomobject]@{ListItemText = 'separate'; }
    [pscustomobject]@{ListItemText = 'm'; }
    [pscustomobject]@{ListItemText = 'combined'; }
    [pscustomobject]@{ListItemText = 'c'; }
    [pscustomobject]@{ListItemText = 'dense-combined'; }
    [pscustomobject]@{ListItemText = 'cc'; }
    [pscustomobject]@{ListItemText = 'remerge'; }
    [pscustomobject]@{ListItemText = 'r'; }
) | Sort-Object ListItemText

$script:gitLogDateFormats = @(
    [pscustomobject]@{ListItemText = 'relative'; }
    [pscustomobject]@{ListItemText = 'iso8601'; }
    [pscustomobject]@{ListItemText = 'iso8601-strict'; }
    [pscustomobject]@{ListItemText = 'rfc2822'; }
    [pscustomobject]@{ListItemText = 'short'; }
    [pscustomobject]@{ListItemText = 'local'; }
    [pscustomobject]@{ListItemText = 'default'; }
    [pscustomobject]@{ListItemText = 'human'; }
    [pscustomobject]@{ListItemText = 'raw'; }
    [pscustomobject]@{ListItemText = 'unix'; }
    [pscustomobject]@{ListItemText = 'auto:'; }
    [pscustomobject]@{ListItemText = 'format:'; }
) | Sort-Object ListItemText

$script:gitLogPrettyFormats = @(
    [pscustomobject]@{ListItemText = 'oneline'; }
    [pscustomobject]@{ListItemText = 'short'; }
    [pscustomobject]@{ListItemText = 'medium'; }
    [pscustomobject]@{ListItemText = 'full'; }
    [pscustomobject]@{ListItemText = 'fuller'; }
    [pscustomobject]@{ListItemText = 'reference'; }
    [pscustomobject]@{ListItemText = 'email'; }
    [pscustomobject]@{ListItemText = 'raw'; }
    [pscustomobject]@{ListItemText = 'format:'; }
    [pscustomobject]@{ListItemText = 'tformat:'; }
    [pscustomobject]@{ListItemText = 'mboxrd'; }
) | Sort-Object ListItemText

$script:gitSendEmailConfirmOptions = @(
    [pscustomobject]@{ListItemText = 'always'; }
    [pscustomobject]@{ListItemText = 'never'; }
    [pscustomobject]@{ListItemText = 'auto'; }
    [pscustomobject]@{ListItemText = 'cc'; }
    [pscustomobject]@{ListItemText = 'compose'; }
) | Sort-Object ListItemText

$script:gitSendEmailSuppressccOptions = @(
    [pscustomobject]@{ListItemText = 'author'; }
    [pscustomobject]@{ListItemText = 'self'; }
    [pscustomobject]@{ListItemText = 'cc'; }
    [pscustomobject]@{ListItemText = 'bodycc'; }
    [pscustomobject]@{ListItemText = 'sob'; }
    [pscustomobject]@{ListItemText = 'cccmd'; }
    [pscustomobject]@{ListItemText = 'body'; }
    [pscustomobject]@{ListItemText = 'all'; }
) | Sort-Object ListItemText

$script:gitMergetoolsCommon = @(
    [pscustomobject]@{ListItemText = 'diffuse'; }
    [pscustomobject]@{ListItemText = 'diffmerge'; }
    [pscustomobject]@{ListItemText = 'ecmerge'; }
    [pscustomobject]@{ListItemText = 'emerge'; }
    [pscustomobject]@{ListItemText = 'kdiff3'; }
    [pscustomobject]@{ListItemText = 'meld'; }
    [pscustomobject]@{ListItemText = 'opendiff'; }
    [pscustomobject]@{ListItemText = 'tkdiff'; }
    [pscustomobject]@{ListItemText = 'vimdiff'; }
    [pscustomobject]@{ListItemText = 'nvimdiff'; }
    [pscustomobject]@{ListItemText = 'gvimdiff'; }
    [pscustomobject]@{ListItemText = 'xxdiff'; }
    [pscustomobject]@{ListItemText = 'araxis'; }
    [pscustomobject]@{ListItemText = 'p4merge'; }
    [pscustomobject]@{ListItemText = 'bc'; }
    [pscustomobject]@{ListItemText = 'codecompare'; }
    [pscustomobject]@{ListItemText = 'smerge'; }
) | Sort-Object ListItemText

$script:gitMergetoolsDiffTool = $gitMergetoolsCommon + [pscustomobject]@{ListItemText = 'kompare'; } | Sort-Object ListItemText
$script:gitMergetoolsMergeTool = $gitMergetoolsCommon + [pscustomobject]@{ListItemText = 'tortoisemerge'; } | Sort-Object ListItemText

$script:gitUntrackedFileModes = @(
    [pscustomobject]@{ListItemText = 'all'; }
    [pscustomobject]@{ListItemText = 'no'; }
    [pscustomobject]@{ListItemText = 'normal'; }
) | Sort-Object ListItemText

# Options for git am
$script:gitWhitespacelist = @(
    [pscustomobject]@{ListItemText = 'nowarn'; }
    [pscustomobject]@{ListItemText = 'warn'; }
    [pscustomobject]@{ListItemText = 'error'; }
    [pscustomobject]@{ListItemText = 'error-all'; }
    [pscustomobject]@{ListItemText = 'fix'; }
) | Sort-Object ListItemText

$script:gitPatchformat = @(
    [pscustomobject]@{ListItemText = 'mbox'; }
    [pscustomobject]@{ListItemText = 'stgit'; }
    [pscustomobject]@{ListItemText = 'stgit-series'; }
    [pscustomobject]@{ListItemText = 'hg'; }
    [pscustomobject]@{ListItemText = 'mboxrd'; }
) | Sort-Object ListItemText

$script:gitShowcurrentpatch = @(
    [pscustomobject]@{ListItemText = 'diff'; }
    [pscustomobject]@{ListItemText = 'raw'; }
) | Sort-Object ListItemText

$script:gitQuotedCr = @(
    [pscustomobject]@{ListItemText = 'nowarn'; }
    [pscustomobject]@{ListItemText = 'warn'; }
    [pscustomobject]@{ListItemText = 'strip'; }
) | Sort-Object ListItemText

# Options that go well for log and gitk (not shortlog)
$script:gitLogGitkOptions = @(
    [pscustomobject]@{ListItemText = '--dense'; }
    [pscustomobject]@{ListItemText = '--sparse'; }
    [pscustomobject]@{ListItemText = '--full-history'; }
    [pscustomobject]@{ListItemText = '--simplify-merges'; }
    [pscustomobject]@{ListItemText = '--simplify-by-decoration'; }
    [pscustomobject]@{ListItemText = '--left-right'; }
    [pscustomobject]@{ListItemText = '--notes'; }
    [pscustomobject]@{ListItemText = '--no-notes'; }
) | Sort-Object ListItemText

# Options for the diff machinery (diff, log, show, stash, range-diff, ...)
$script:gitDiffCommonOptions = @(
    [pscustomobject]@{ListItemText = '--stat'; }
    [pscustomobject]@{ListItemText = '--numstat'; }
    [pscustomobject]@{ListItemText = '--shortstat'; }
    [pscustomobject]@{ListItemText = '--summary'; }
    [pscustomobject]@{ListItemText = '--patch-with-stat'; }
    [pscustomobject]@{ListItemText = '--name-only'; }
    [pscustomobject]@{ListItemText = '--name-status'; }
    [pscustomobject]@{ListItemText = '--color'; }
    [pscustomobject]@{ListItemText = '--no-color'; }
    [pscustomobject]@{ListItemText = '--color-words'; }
    [pscustomobject]@{ListItemText = '--no-renames'; }
    [pscustomobject]@{ListItemText = '--check'; }
    [pscustomobject]@{ListItemText = '--color-moved'; }
    [pscustomobject]@{ListItemText = '--color-moved='; }
    [pscustomobject]@{ListItemText = '--no-color-moved'; }
    [pscustomobject]@{ListItemText = '--color-moved-ws='; }
    [pscustomobject]@{ListItemText = '--no-color-moved-ws'; }
    [pscustomobject]@{ListItemText = '--full-index'; }
    [pscustomobject]@{ListItemText = '--binary'; }
    [pscustomobject]@{ListItemText = '--abbrev'; }
    [pscustomobject]@{ListItemText = '--diff-filter='; }
    [pscustomobject]@{ListItemText = '--find-copies'; }
    [pscustomobject]@{ListItemText = '--find-object'; }
    [pscustomobject]@{ListItemText = '--find-renames'; }
    [pscustomobject]@{ListItemText = '--no-relative'; }
    [pscustomobject]@{ListItemText = '--relative'; }
    [pscustomobject]@{ListItemText = '--find-copies-harder'; }
    [pscustomobject]@{ListItemText = '--ignore-cr-at-eol'; }
    [pscustomobject]@{ListItemText = '--text'; }
    [pscustomobject]@{ListItemText = '--ignore-space-at-eol'; }
    [pscustomobject]@{ListItemText = '--ignore-space-change'; }
    [pscustomobject]@{ListItemText = '--ignore-all-space'; }
    [pscustomobject]@{ListItemText = '--ignore-blank-lines'; }
    [pscustomobject]@{ListItemText = '--exit-code'; }
    [pscustomobject]@{ListItemText = '--quiet'; }
    [pscustomobject]@{ListItemText = '--ext-diff'; }
    [pscustomobject]@{ListItemText = '--no-ext-diff'; }
    [pscustomobject]@{ListItemText = '--unified='; }
    [pscustomobject]@{ListItemText = '--no-prefix'; }
    [pscustomobject]@{ListItemText = '--src-prefix='; }
    [pscustomobject]@{ListItemText = '--dst-prefix='; }
    [pscustomobject]@{ListItemText = '--inter-hunk-context='; }
    [pscustomobject]@{ListItemText = '--function-context'; }
    [pscustomobject]@{ListItemText = '--patience'; }
    [pscustomobject]@{ListItemText = '--histogram'; }
    [pscustomobject]@{ListItemText = '--minimal'; }
    [pscustomobject]@{ListItemText = '--raw'; }
    [pscustomobject]@{ListItemText = '--word-diff'; }
    [pscustomobject]@{ListItemText = '--word-diff-regex='; }
    [pscustomobject]@{ListItemText = '--dirstat'; }
    [pscustomobject]@{ListItemText = '--dirstat='; }
    [pscustomobject]@{ListItemText = '--dirstat-by-file'; }
    [pscustomobject]@{ListItemText = '--dirstat-by-file='; }
    [pscustomobject]@{ListItemText = '--cumulative'; }
    [pscustomobject]@{ListItemText = '--diff-algorithm='; }
    [pscustomobject]@{ListItemText = '--default-prefix'; }
    [pscustomobject]@{ListItemText = '--submodule'; }
    [pscustomobject]@{ListItemText = '--submodule='; }
    [pscustomobject]@{ListItemText = '--ignore-submodules'; }
    [pscustomobject]@{ListItemText = '--indent-heuristic'; }
    [pscustomobject]@{ListItemText = '--no-indent-heuristic'; }
    [pscustomobject]@{ListItemText = '--textconv'; }
    [pscustomobject]@{ListItemText = '--no-textconv'; }
    [pscustomobject]@{ListItemText = '--break-rewrites'; }
    [pscustomobject]@{ListItemText = '--patch'; }
    [pscustomobject]@{ListItemText = '--no-patch'; }
    [pscustomobject]@{ListItemText = '--cc'; }
    [pscustomobject]@{ListItemText = '--combined-all-paths'; }
    [pscustomobject]@{ListItemText = '--anchored='; }
    [pscustomobject]@{ListItemText = '--compact-summary'; }
    [pscustomobject]@{ListItemText = '--ignore-matching-lines='; }
    [pscustomobject]@{ListItemText = '--irreversible-delete'; }
    [pscustomobject]@{ListItemText = '--line-prefix'; }
    [pscustomobject]@{ListItemText = '--no-stat'; }
    [pscustomobject]@{ListItemText = '--output='; }
    [pscustomobject]@{ListItemText = '--output-indicator-context='; }
    [pscustomobject]@{ListItemText = '--output-indicator-new='; }
    [pscustomobject]@{ListItemText = '--output-indicator-old='; }
    [pscustomobject]@{ListItemText = '--ws-error-highlight='; }
    [pscustomobject]@{ListItemText = '--pickaxe-all'; }
    [pscustomobject]@{ListItemText = '--pickaxe-regex'; }
    [pscustomobject]@{ListItemText = '--patch-with-raw'; }
) | Sort-Object { $_.ListItemText -creplace '=', ' ' }

# Options for diff/difftool
$script:gitDiffDifftoolOptions = @(
    [pscustomobject]@{ListItemText = '--cached'; }
    [pscustomobject]@{ListItemText = '--staged'; }
    [pscustomobject]@{ListItemText = '--base'; }
    [pscustomobject]@{ListItemText = '--ours'; }
    [pscustomobject]@{ListItemText = '--theirs'; }
    [pscustomobject]@{ListItemText = '--no-index'; }
    [pscustomobject]@{ListItemText = '--merge-base'; }
    [pscustomobject]@{ListItemText = '--ita-invisible-in-index'; }
    [pscustomobject]@{ListItemText = '--ita-visible-in-index'; }
) + $GitDiffCommonOptions | Sort-Object { $_.ListItemText -creplace '=', ' ' }

# Options that go well for log, shortlog and gitk
$script:gitLogCommonOptions = @(
    [pscustomobject]@{ListItemText = '--not'; }
    [pscustomobject]@{ListItemText = '--all'; }
    [pscustomobject]@{ListItemText = '--branches'; }
    [pscustomobject]@{ListItemText = '--tags'; }
    [pscustomobject]@{ListItemText = '--remotes'; }
    [pscustomobject]@{ListItemText = '--first-parent'; }
    [pscustomobject]@{ListItemText = '--merges'; }
    [pscustomobject]@{ListItemText = '--no-merges'; }
    [pscustomobject]@{ListItemText = '--max-count='; }
    [pscustomobject]@{ListItemText = '--max-age='; }
    [pscustomobject]@{ListItemText = '--since='; }
    [pscustomobject]@{ListItemText = '--after='; }
    [pscustomobject]@{ListItemText = '--min-age='; }
    [pscustomobject]@{ListItemText = '--until='; }
    [pscustomobject]@{ListItemText = '--before='; }
    [pscustomobject]@{ListItemText = '--min-parents='; }
    [pscustomobject]@{ListItemText = '--max-parents='; }
    [pscustomobject]@{ListItemText = '--no-min-parents'; }
    [pscustomobject]@{ListItemText = '--no-max-parents'; }
    [pscustomobject]@{ListItemText = '--alternate-refs'; }
    [pscustomobject]@{ListItemText = '--ancestry-path'; }
    [pscustomobject]@{ListItemText = '--author-date-order'; }
    [pscustomobject]@{ListItemText = '--basic-regexp'; }
    [pscustomobject]@{ListItemText = '--bisect'; }
    [pscustomobject]@{ListItemText = '--boundary'; }
    [pscustomobject]@{ListItemText = '--exclude-first-parent-only'; }
    [pscustomobject]@{ListItemText = '--exclude-hidden'; }
    [pscustomobject]@{ListItemText = '--extended-regexp'; }
    [pscustomobject]@{ListItemText = '--fixed-strings'; }
    [pscustomobject]@{ListItemText = '--grep-reflog'; }
    [pscustomobject]@{ListItemText = '--ignore-missing'; }
    [pscustomobject]@{ListItemText = '--left-only'; }
    [pscustomobject]@{ListItemText = '--perl-regexp'; }
    [pscustomobject]@{ListItemText = '--reflog'; }
    [pscustomobject]@{ListItemText = '--regexp-ignore-case'; }
    [pscustomobject]@{ListItemText = '--remove-empty'; }
    [pscustomobject]@{ListItemText = '--right-only'; }
    [pscustomobject]@{ListItemText = '--show-linear-break'; }
    [pscustomobject]@{ListItemText = '--show-notes-by-default'; }
    [pscustomobject]@{ListItemText = '--show-pulls'; }
    [pscustomobject]@{ListItemText = '--since-as-filter'; }
    [pscustomobject]@{ListItemText = '--single-worktree'; }
) | Sort-Object { $_.ListItemText -creplace '=', ' ' }

# Options that go well for log and shortlog (not gitk)
$script:gitLogShortlogOptions = @(
    [pscustomobject]@{ListItemText = '--author='; }
    [pscustomobject]@{ListItemText = '--grep='; }
    [pscustomobject]@{ListItemText = '--all-match'; }
    [pscustomobject]@{ListItemText = '--invert-grep'; }
    [pscustomobject]@{ListItemText = '--exclude'; }
    [pscustomobject]@{ListItemText = '--glob='; }
) | Sort-Object { $_.ListItemText -creplace '=', ' ' }

$script:gitShortlogOptions = $gitLogCommonOptions + $gitLogShortlogOptions + @(
    [pscustomobject]@{ListItemText = '--committer'; }
    [pscustomobject]@{ListItemText = '--numbered'; }
    [pscustomobject]@{ListItemText = '--summary'; }
    [pscustomobject]@{ListItemText = '--email'; }
    [pscustomobject]@{ListItemText = '--no-committer'; }
    [pscustomobject]@{ListItemText = '--no-numbered'; }
    [pscustomobject]@{ListItemText = '--no-summary'; }
    [pscustomobject]@{ListItemText = '--no-email'; }
) | Sort-Object { $_.ListItemText -creplace '=', ' ' }

# Options accepted by log and show
$script:gitLogShowOptions = @(
    [pscustomobject]@{ListItemText = '--diff-merges'; }
    [pscustomobject]@{ListItemText = '--diff-merges='; }
    [pscustomobject]@{ListItemText = '--no-diff-merges'; }
    [pscustomobject]@{ListItemText = '--dd'; }
    [pscustomobject]@{ListItemText = '--remerge-diff'; }
    [pscustomobject]@{ListItemText = '--encoding='; }
) | Sort-Object { $_.ListItemText -creplace '=', ' ' }

$script:gitStashListOptions = $gitLogCommonOptions + $gitDiffCommonOptions | Sort-Object { $_.ListItemText -creplace '=', ' ' }

$script:gitShowOpts = @(
    [pscustomobject]@{ListItemText = '--pretty='; }
    [pscustomobject]@{ListItemText = '--format='; }
    [pscustomobject]@{ListItemText = '--abbrev-commit'; }
    [pscustomobject]@{ListItemText = '--no-abbrev-commit'; }
    [pscustomobject]@{ListItemText = '--oneline'; }
    [pscustomobject]@{ListItemText = '--show-signature'; }
    [pscustomobject]@{ListItemText = '--expand-tabs'; }
    [pscustomobject]@{ListItemText = '--expand-tabs='; }
    [pscustomobject]@{ListItemText = '--no-expand-tabs'; }
) + $gitLogShowOptions + $gitDiffCommonOptions | Sort-Object { $_.ListItemText -creplace '=', ' ' }

$script:gitLogOptions = $gitLogCommonOptions + $gitLogShortlogOptions + $gitLogGitkOptions + $gitLogShowOptions + $gitDiffCommonOptions + @(
    [pscustomobject]@{ListItemText = '--committer='; }
    [pscustomobject]@{ListItemText = '--root'; }
    [pscustomobject]@{ListItemText = '--topo-order'; }
    [pscustomobject]@{ListItemText = '--date-order'; }
    [pscustomobject]@{ListItemText = '--reverse'; }
    [pscustomobject]@{ListItemText = '--follow'; }
    [pscustomobject]@{ListItemText = '--full-diff'; }
    [pscustomobject]@{ListItemText = '--abbrev-commit'; }
    [pscustomobject]@{ListItemText = '--no-abbrev-commit'; }
    [pscustomobject]@{ListItemText = '--abbrev='; }
    [pscustomobject]@{ListItemText = '--relative-date'; }
    [pscustomobject]@{ListItemText = '--date='; }
    [pscustomobject]@{ListItemText = '--pretty='; }
    [pscustomobject]@{ListItemText = '--format='; }
    [pscustomobject]@{ListItemText = '--oneline'; }
    [pscustomobject]@{ListItemText = '--show-signature'; }
    [pscustomobject]@{ListItemText = '--cherry-mark'; }
    [pscustomobject]@{ListItemText = '--cherry-pick'; }
    [pscustomobject]@{ListItemText = '--graph'; }
    [pscustomobject]@{ListItemText = '--decorate'; }
    [pscustomobject]@{ListItemText = '--decorate='; }
    [pscustomobject]@{ListItemText = '--no-decorate'; }
    [pscustomobject]@{ListItemText = '--walk-reflogs'; }
    [pscustomobject]@{ListItemText = '--no-walk'; }
    [pscustomobject]@{ListItemText = '--no-walk='; }
    [pscustomobject]@{ListItemText = '--do-walk'; }
    [pscustomobject]@{ListItemText = '--parents'; }
    [pscustomobject]@{ListItemText = '--children'; }
    [pscustomobject]@{ListItemText = '--expand-tabs'; }
    [pscustomobject]@{ListItemText = '--expand-tabs='; }
    [pscustomobject]@{ListItemText = '--no-expand-tabs'; }
    [pscustomobject]@{ListItemText = '--clear-decorations'; }
    [pscustomobject]@{ListItemText = '--decorate-refs='; }
    [pscustomobject]@{ListItemText = '--decorate-refs-exclude='; }
    [pscustomobject]@{ListItemText = '--merge'; }
) | Sort-Object { $_.ListItemText -creplace '=', ' ' }