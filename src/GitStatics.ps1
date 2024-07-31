
class CommandOption {
    [string] $Short
    [string] $Long
    [string] $Description
    [string] $Value

    CommandOption ([string]$short, [string]$long, $description, $value) {
        $this.Short = $Short
        $this.Long = $Long
        $this.Description = $Description
        $this.Value = $Value
    }

    [System.Management.Automation.CompletionResult] ToLongCompletion([string]$Prefix) {
        if ($this.Long -and ($this.Long -clike "$Prefix*")) {
            return [System.Management.Automation.CompletionResult]::new(
                $this.Long,
                $this.Long + "$(if($this.Value){" $($this.Value)"})",
                "ParameterName",
                "$(if($this.Description){$this.Description}else{$this.Long})"
            )
        }
        return $null
    }

    [System.Management.Automation.CompletionResult] ToShortCompletion() {
        if ($this.Short) {
            return [System.Management.Automation.CompletionResult]::new(
                $this.Short,
                $this.Short + "$(if($this.Value){" $($this.Value)"})",
                "ParameterName",
                "$(if($this.Description){$this.Description}else{$this.Short})"
            )
        }
        return $null
    }
}

function New-CommandOption {
    [CmdletBinding()]
    param (
        [string]$Short = '',
        [string]$Long = '',
        [string]$Desc = '',
        [string]$Value = ''
    )
    [CommandOption]::new($Short, $Long, $Desc, $Value)
}

# $script:gitDiffAlgorithms="myers minimal patience histogram"

$script:gitDiffSubmoduleFormats = "diff", "log", "short"

# $script:gitColorMovedOpts="no default plain blocks zebra dimmed-zebra"

# $script:gitColorMovedWsOpts="no ignore-space-at-eol ignore-space-change
# 			ignore-all-space allow-indentation-change"

# $script:gitWsErrorHighlightOpts="context old new all default"

# # Options for the diff machinery (diff, log, show, stash, range-diff, ...)
# $script:gitDiffCommonOptions="--stat --numstat --shortstat --summary
# 			--patch-with-stat --name-only --name-status --color
# 			--no-color --color-words --no-renames --check
# 			--color-moved --color-moved= --no-color-moved
# 			--color-moved-ws= --no-color-moved-ws
# 			--full-index --binary --abbrev --diff-filter=
# 			--find-copies --find-object --find-renames
# 			--no-relative --relative
# 			--find-copies-harder --ignore-cr-at-eol
# 			--text --ignore-space-at-eol --ignore-space-change
# 			--ignore-all-space --ignore-blank-lines --exit-code
# 			--quiet --ext-diff --no-ext-diff --unified=
# 			--no-prefix --src-prefix= --dst-prefix=
# 			--inter-hunk-context= --function-context
# 			--patience --histogram --minimal
# 			--raw --word-diff --word-diff-regex=
# 			--dirstat --dirstat= --dirstat-by-file
# 			--dirstat-by-file= --cumulative
# 			--diff-algorithm= --default-prefix
# 			--submodule --submodule= --ignore-submodules
# 			--indent-heuristic --no-indent-heuristic
# 			--textconv --no-textconv --break-rewrites
# 			--patch --no-patch --cc --combined-all-paths
# 			--anchored= --compact-summary --ignore-matching-lines=
# 			--irreversible-delete --line-prefix --no-stat
# 			--output= --output-indicator-context=
# 			--output-indicator-new= --output-indicator-old=
# 			--ws-error-highlight=
# 			--pickaxe-all --pickaxe-regex --patch-with-raw
# "

# # Options for diff/difftool
# $script:gitDiffDifftoolOptions="--cached --staged
# 			--base --ours --theirs --no-index --merge-base
# 			--ita-invisible-in-index --ita-visible-in-index
# 			$GitDiffCommonOptions"

# # Options that go well for log, shortlog and gitk
# $script:gitLogCommonOptions="
# 	--not --all
# 	--branches --tags --remotes
# 	--first-parent --merges --no-merges
# 	--max-count=
# 	--max-age= --since= --after=
# 	--min-age= --until= --before=
# 	--min-parents= --max-parents=
# 	--no-min-parents --no-max-parents
# 	--alternate-refs --ancestry-path
# 	--author-date-order --basic-regexp
# 	--bisect --boundary --exclude-first-parent-only
# 	--exclude-hidden --extended-regexp
# 	--fixed-strings --grep-reflog
# 	--ignore-missing --left-only --perl-regexp
# 	--reflog --regexp-ignore-case --remove-empty
# 	--right-only --show-linear-break
# 	--show-notes-by-default --show-pulls
# 	--since-as-filter --single-worktree
# "
# # Options that go well for log and gitk (not shortlog)
# $script:gitLogGitkOptions="
# 	--dense --sparse --full-history
# 	--simplify-merges --simplify-by-decoration
# 	--left-right --notes --no-notes
# "
# # Options that go well for log and shortlog (not gitk)
# $script:gitLogShortlogOptions="
# 	--author= --committer= --grep=
# 	--all-match --invert-grep
# "
# # Options accepted by log and show
# $script:gitLogShowOptions="
# 	--diff-merges --diff-merges= --no-diff-merges --dd --remerge-diff
# 	--encoding=
# "

# $script:gitDiffMergesOpts="off none on first-parent 1 separate m combined c dense-combined cc remerge r"

# $script:gitLogPrettyFormats="oneline short medium full fuller reference email raw format: tformat: mboxrd"
$script:gitLogDateFormats = "relative", "iso8601", "iso8601-strict", "rfc2822", "short", "local", "default", "human", "raw", "unix", "auto:", "format:"
$script:gitSendEmailConfirmOptions = "always", "never", "auto", "cc", "compose"
$script:gitSendEmailSuppressccOptions = "author", "self", "cc", "bodycc", "sob", "cccmd", "body", "all"

$script:gitOptionsDecriptionTable = @{}