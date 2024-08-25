function Get-GitConfigVariableDescription {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [string]$Current
    )

    switch -Wildcard ($Current) {
        "add.ignoreErrors" { 'Tells git add to continue adding files when some files cannot be added due to indexing errors' }
        "add.interactive.useBuiltin" { 'Unused configuration variable' }

        "advice." { 'These variables control various optional help messages designed to aid new users' }
        "advice.addEmbeddedRepo" { 'Shown when the user accidentally adds one git repo inside of another' }
        "advice.addEmptyPathspec" { 'Shown when the user runs git add without providing the pathspec parameter' }
        "advice.addIgnoredFile" { 'Shown when the user attempts to add an ignored file to the index' }
        "advice.amWorkDir" { 'Shown when git-am fails to apply a patch file, to tell the user the location of the file' }
        "advice.ambiguousFetchRefspec" { 'Shown when a fetch refspec for multiple remotes maps to the same remote-tracking branch namespace and causes branch tracking set-up to fail' }
        "advice.checkoutAmbiguousRemoteBranchName" { 'Shown when the argument to git-checkout and git-switch ambiguously resolves to a remote tracking branch on more than one remote in situations where an unambiguous argument would have otherwise caused a remote-tracking branch to be checked out. See the checkout.defaultRemote configuration variable for how to set a given remote to be used by default in some situations where this advice would be printed' }
        "advice.commitBeforeMerge" { 'Shown when git-merge refuses to merge to avoid overwriting local changes' }
        "advice.detachedHead" { 'Shown when the user uses git-switch or git-checkout to move to the detached HEAD state, to tell the user how to create a local branch after the fact' }
        "advice.diverging" { 'Shown when a fast-forward is not possible' }
        "advice.fetchShowForcedUpdates" { 'Shown when git-fetch takes a long time to calculate forced updates after ref updates, or to warn that the check is disabled' }
        "advice.forceDeleteBranch" { 'Shown when the user tries to delete a not fully merged branch without the force option set' }
        "advice.ignoredHook" { 'Shown when a hook is ignored because the hook is not set as executable' }
        "advice.implicitIdentity" { "Shown when the user’s information is guessed from the system username and domain name, to tell the user how to set their identity configuration" }
        "advice.mergeConflict" { 'Shown when various commands stop because of conflicts' }
        "advice.nameTooLong" { 'Advice shown if a filepath operation is attempted where the path was too long' }
        "advice.nestedTag" { 'Shown when a user attempts to recursively tag a tag object' }
        "advice.pushAlreadyExists" { 'Shown when git-push rejects an update that does not qualify for fast-forwarding (e.g., a tag.)' }
        "advice.pushFetchFirst" { 'Shown when git-push rejects an update that tries to overwrite a remote ref that points at an object we do not have' }
        "advice.pushNeedsForce" { 'Shown when git-push rejects an update that tries to overwrite a remote ref that points at an object that is not a commit-ish, or make the remote ref point at an object that is not a commit-ish' }
        "advice.pushNonFFCurrent" { 'Shown when git-push fails due to a non-fast-forward update to the current branch' }
        "advice.pushNonFFMatching" { "Shown when the user ran git-push and pushed `"matching refs`" explicitly (i.e. used :, or specified a refspec that isn’t the current branch) and it resulted in a non-fast-forward error" }
        "advice.pushRefNeedsUpdate" { 'Shown when git-push rejects a forced update of a branch when its remote-tracking ref has updates that we do not have locally' }
        "advice.pushUnqualifiedRefname" { 'Shown when git-push gives up trying to guess based on the source and destination refs what remote ref namespace the source belongs in, but where we can still suggest that the user push to either refs/heads/* or refs/tags/* based on the type of the source object' }
        "advice.pushUpdateRejected" { 'Set this variable to false if you want to disable pushNonFFCurrent, pushNonFFMatching, pushAlreadyExists, pushFetchFirst, pushNeedsForce, and pushRefNeedsUpdate simultaneously' }
        "advice.refSyntax" { 'Shown when the user provides an illegal ref name, to tell the user about the ref syntax documentation' }
        "advice.resetNoRefresh" { 'Shown when git-reset takes more than 2 seconds to refresh the index after reset, to tell the user that they can use the --no-refresh option' }
        "advice.resolveConflict" { 'Shown by various commands when conflicts prevent the operation from being performed' }
        "advice.rmHints" { 'Shown on failure in the output of git-rm, to give directions on how to proceed from the current state' }
        "advice.sequencerInUse" { 'Shown when a sequencer command is already in progress' }
        "advice.skippedCherryPicks" { 'Shown when git-rebase skips a commit that has already been cherry-picked onto the upstream branch' }
        "advice.statusAheadBehind" { 'Shown when git-status computes the ahead/behind counts for a local ref compared to its remote tracking ref, and that calculation takes longer than expected. Will not appear if status.aheadBehind is false or the option --no-ahead-behind is given' }
        "advice.statusHints" { 'Show directions on how to proceed from the current state in the output of git-status, in the template shown when writing commit messages in git-commit, and in the help message shown by git-switch or git-checkout when switching branches' }
        "advice.statusUoption" { 'Shown when git-status takes more than 2 seconds to enumerate untracked files, to tell the user that they can use the -u option' }
        "advice.submoduleAlternateErrorStrategyDie" { 'Shown when a submodule.alternateErrorStrategy option configured to "die" causes a fatal error' }
        "advice.submoduleMergeConflict" { 'Advice shown when a non-trivial submodule merge conflict is encountered' }
        "advice.submodulesNotUpdated" { 'Shown when a user runs a submodule command that fails because git submodule update --init was not run' }
        "advice.suggestDetachingHead" { 'Shown when git-switch refuses to detach HEAD without the explicit --detach option' }
        "advice.updateSparsePath" { 'Shown when either git-add or git-rm is asked to update index entries outside the current sparse checkout' }
        "advice.waitingForEditor" { 'Shown when Git is waiting for editor input. Relevant when e.g. the editor is not launched inside the terminal' }
        "advice.worktreeAddOrphan" { 'Shown when the user tries to create a worktree from an invalid reference, to tell the user how to create a new unborn branch instead' }
        "advice.useCoreFSMonitorConfig" { 'Advice shown if the deprecated core.useBuiltinFSMonitor config setting is in use' }

        "alias." { 'Command aliases for the git command wrapper' }

        "am.keepcr" { 'If true, git-am will call git-mailsplit for patches in mbox format with parameter --keep-cr' }
        "am.threeWay" { 'When set to true, this setting tells git am to fall back on 3-way merge if the patch records the identity of blobs it is supposed to apply to and we have those blobs available locally (equivalent to giving the --3way option from the command line)' }
        
        "apply.ignoreWhitespace" { 'When set to change, tells git apply to ignore changes in whitespace, in the same way as the --ignore-space-change option' }
        "apply.whitespace" { 'Tells git apply how to handle whitespace, in the same way as the --whitespace option' }

        "attr.tree" { 'A reference to a tree in the repository from which to read attributes, instead of the .gitattributes file in the working tree' }

        "blame.blankBoundary" { 'Show blank commit object name for boundary commits in git-blame' }
        "blame.coloring" { 'This determines the coloring scheme to be applied to blame output' }
        "blame.date" { 'Specifies the format used to output dates in git-blame' }
        "blame.showEmail" { 'Show the author email instead of author name in git-blame' }
        "blame.showRoot" { 'Do not treat root commits as boundaries in git-blame' }
        "blame.ignoreRevsFile" { 'Ignore revisions listed in the file, one unabbreviated object name per line, in git-blame' }
        "blame.markUnblamableLines" { 'Mark lines that were changed by an ignored revision that we could not attribute to another commit with a * in the output of git-blame' }
        "blame.markIgnoredLines" { 'Mark lines that were changed by an ignored revision that we attributed to another commit with a ? in the output of git-blame' }

        "branch.autoSetupMerge" { 'Tells git branch, git switch and git checkout to set up new branches so that git-pull will appropriately merge from the starting point branch' }
        "branch.autoSetupRebase" { 'When a new branch is created with git branch, git switch or git checkout that tracks another branch, this variable tells Git to set up pull to rebase instead of merge' }
        "branch.sort" { 'This variable controls the sort ordering of branches when displayed by git-branch' }
        "branch.*.*" { 
            if ($Current -match "(branch)\.(.+)\.([^\.]+)") {
                # $section = $Matches[1]
                $second = $Matches[2]
                $third = $Matches[3]

                switch ($third) {
                    "remote" { "When on branch <$second>, it tells git fetch and git push which remote to fetch from or push to" }
                    "pushRemote" { "When on branch <$second>, it overrides branch.$second.remote for pushing" }
                    "merge" { "Defines, together with branch.$second.remote, the upstream branch for the given branch" }
                    "mergeOptions" { "Sets default options for merging into branch <$second>" }
                    "rebase" { "When true, rebase the branch <$second> on top of the fetched branch, instead of merging the default branch from the default remote when `"git pull`" is run" }
                    "description" { "Branch description, can be edited with git branch --edit-description" }
                }
            }
        }

        "browser.*.cmd" { 'Specify the command to invoke the specified browser' }
        "browser.*.path" { 'Override the path for the given tool that may be used to browse HTML help or a working repository in gitweb' }

        "bundle." { 'The bundle.* keys may appear in a bundle list file found via the git clone --bundle-uri option' }
        "bundle.version" { 'This integer value advertises the version of the bundle list format used by the bundle list' }
        "bundle.mode" { 'This string value should be either all or any' }
        "bundle.heuristic" { 'If this string-valued key exists, then the bundle list is designed to work well with incremental git fetch commands' }
        "bundle.*.*" { 
            if ($Current -match "(bundle)\.(.+)\.([^\.]+)") {
                # $section = $Matches[1]
                $second = $Matches[2]
                $third = $Matches[3]

                switch ($third) {
                    "uri" { "This string value defines the URI by which Git can reach the contents of this <$second>" }
                    Default { "The bundle.$second.* keys are used to describe a single item in the bundle list, grouped under <$second> for identification purposes" }
                }
            }
        }

        "checkout.defaultRemote" { 'When you run git checkout <something> or git switch <something> and only have one remote, it may implicitly fall back on checking out and tracking e.g. origin/<something>' }
        "checkout.guess" { 'Provides the default value for the --guess or --no-guess option in git checkout and git switch' }
        "checkout.workers" { 'The number of parallel workers to use when updating the working tree' }
        "checkout.thresholdForParallelism" { 'When running parallel checkout with a small number of files, the cost of subprocess spawning and inter-process communication might outweigh the parallelization gains' }

        "clean.requireForce" { 'A boolean to make git-clean refuse to delete files unless -f is given' }

        "clone.defaultRemoteName" { 'The name of the remote to create when cloning a repository' }
        "clone.filterSubmodules" { 'If a partial clone filter is provided and --recurse-submodules is used, also apply the filter to submodules' }
        "clone.rejectShallow" { 'Reject cloning a repository if it is a shallow one' }

        "color.advice" { 'A boolean to enable/disable color in hints' }
        "color.advice.hint" { 'Use customized color for hints' }
        "color.blame.highlightRecent" { 'Specify the line annotation color for git blame --color-by-age depending upon the age of the line' }
        "color.blame.repeatedLines" { 'Use the specified color to colorize line annotations for git blame --color-lines' }
        "color.branch" { 'A boolean to enable/disable color in the output of git-branch' }
        "color.branch.*" { 'Use customized color for branch coloration' }
        "color.diff" { 'Whether to use ANSI escape sequences to add color to patches' }
        "color.diff.*" { 'Use customized color for diff colorization' }
        "color.decorate.*" { 'Use customized color for git log --decorate output' }
        # "color.grep" {.  }
        "color.grep.*" { 'Use customized color for grep colorization' }
        # "color.interactive" {.  }
        "color.interactive.*" { 'Use customized color for git add --interactive and git clean --interactive output' }
        "color.pager" { 'A boolean to specify whether auto color modes should colorize output going to the pager' }
        "color.push" { 'A boolean to enable/disable color in push errors' }
        "color.push.error" { 'Use customized color for push errors' }
        # "color.remote" {.  }
        "color.remote.*" { 'Use customized color for each remote keyword' }
        "color.showBranch" { 'A boolean to enable/disable color in the output of git-show-branch' }
        "color.status" { 'A boolean to enable/disable color in the output of git-status' }
        "color.status.*" { 'Use customized color for status colorization' }
        "color.transport" { 'A boolean to enable/disable color when pushes are rejected' }
        "color.transport.rejected" { 'Use customized color when a push was rejected' }
        "color.ui" { 'This variable determines the default value for variables such as color.diff and color.grep that control the use of color per command family' }

        "column.ui" { 'Specify whether supported commands should output in columns' }
        "column.branch" { 'Specify whether to output branch listing in git branch in columns' }
        "column.clean" { 'Specify the layout when listing items in git clean -i, which always shows files and directories in columns' }
        "column.status" { 'Specify whether to output untracked files in git status in columns' }
        "column.tag" { 'Specify whether to output tag listings in git tag in columns' }

        "commit.cleanup" { 'This setting overrides the default of the --cleanup option in git commit' }
        "commit.gpgSign" { 'A boolean to specify whether all commits should be GPG signed' }
        "commit.status" { 'A boolean to enable/disable inclusion of status information in the commit message template when using an editor to prepare the commit message' }
        "commit.template" { 'Specify the pathname of a file to use as the template for new commit messages' }
        "commit.verbose" { 'A boolean or int to specify the level of verbosity with git commit' }

        "commitGraph.generationVersion" { 'Specifies the type of generation number version to use when writing or reading the commit-graph file' }
        "commitGraph.maxNewFilters" { 'Specifies the default value for the --max-new-filters option of git commit-graph write (c.f., git-commit-graph)' }
        "commitGraph.readChangedPaths" { 'If true, then git will use the changed-path Bloom filters in the commit-graph file' }

        "completion.commands" { 'This is only used by git-completion.bash to add or remove commands from the list of completed commands' }

        "core.fileMode" { 'Tells Git if the executable bit of files in the working tree is to be honored' }
        # "core.hideDotFiles" {.  }
        "core.ignoreCase" { 'Internal variable which enables various workarounds to enable Git to work better on filesystems that are not case sensitive, like APFS, HFS+, FAT, NTFS, etc' }
        # "core.precomposeUnicode" .{ }
        "core.protectHFS" { 'If set to true, do not allow checkout of paths that would be considered equivalent to .git on an HFS+ filesystem' }
        "core.protectNTFS" { 'If set to true, do not allow checkout of paths that would cause problems with the NTFS filesystem' }
        "core.fsmonitor" { 'If set to true, enable the built-in file system monitor daemon for this working directory' }
        "core.fsmonitorHookVersion" { 'Sets the protocol version to be used when invoking the "fsmonitor" hook' }
        "core.trustctime" { 'If false, the ctime differences between the index and the working tree are ignored; useful when the inode change time is regularly modified by something outside Git (file system crawlers and some backup systems)' }
        "core.splitIndex" { 'If true, the split-index feature of the index will be used' }
        "core.untrackedCache" { 'Determines what to do about the untracked cache feature of the index' }
        "core.checkStat" { 'When missing or is set to default, many fields in the stat structure are checked to detect if a file has been modified since Git looked at it' }
        "core.quotePath" { 'Commands that output paths, will quote "unusual" characters in the pathname by enclosing the pathname in double-quotes and escaping those characters with backslashes in the same way C escapes control characters or bytes with values larger than 0x80 (e.g. octal \302\265 for "micro" in UTF-8)' }
        "core.eol" { 'Sets the line ending type to use in the working directory for files that are marked as text' }
        "core.safecrlf" { 'If true, makes Git check if converting CRLF is reversible when end-of-line conversion is active' }
        "core.autocrlf" { 'Setting this variable to "true" is the same as setting the text attribute to "auto" on all files and core.eol to "crlf"' }
        "core.checkRoundtripEncoding" { 'A comma and/or whitespace separated list of encodings that Git performs UTF-8 round trip checks on if they are used in an working-tree-encoding attribute' }
        "core.symlinks" { 'If false, symbolic links are checked out as small plain files that contain the link text' }
        "core.gitProxy" { 'A "proxy command" to execute (as command host port) instead of establishing direct connection to the remote server when using the Git protocol for fetching' }
        "core.sshCommand" { 'If this variable is set, git fetch and git push will use the specified command instead of ssh when they need to connect to a remote system' }
        "core.ignoreStat" { 'If true, Git will avoid using lstat() calls to detect if files have changed by setting the "assume-unchanged" bit for those tracked files which it has updated identically in both the index and working tree' }
        "core.preferSymlinkRefs" { 'Instead of the default "symref" format for HEAD and other symbolic reference files, use symbolic links' }
        "core.alternateRefsCommand" { 'When advertising tips of available history from an alternate, use the shell to execute the specified command instead of git-for-each-ref' }
        "core.alternateRefsPrefixes" { 'When listing references from an alternate, list only references that begin with the given prefix' }
        "core.bare" { 'If true this repository is assumed to be bare and has no working directory associated with it' }
        "core.worktree" { 'Set the path to the root of the working tree' }
        "core.logAllRefUpdates" { 'Enable the reflog' }
        "core.repositoryFormatVersion" { "Internal variable identifying the repository format and layout version" }
        "core.sharedRepository" { 'When group (or true), the repository is made shareable between several users in a group (making sure all the files and objects are group-writable)' }
        "core.warnAmbiguousRefs" { 'If true, Git will warn you if the ref name you passed it is ambiguous and might match multiple refs in the repository' }
        "core.compression" { 'An integer -1..9, indicating a default compression level' }
        "core.looseCompression" { 'An integer -1..9, indicating the compression level for objects that are not in a pack file' }
        "core.packedGitWindowSize" { 'Number of bytes of a pack file to map into memory in a single mapping operation' }
        "core.packedGitLimit" { 'Maximum number of bytes to map simultaneously into memory from pack files' }
        "core.deltaBaseCacheLimit" { 'Maximum number of bytes per thread to reserve for caching base objects that may be referenced by multiple deltified objects' }
        "core.bigFileThreshold" { 'The size of files considered "big", which as discussed below changes the behavior of numerous git commands, as well as how such files are stored within the repository' }
        "core.excludesFile" { 'Specifies the pathname to the file that contains patterns to describe paths that are not meant to be tracked' }
        "core.askPass" { 'Some commands that interactively ask for a password can be told to use an external program given via the value of this variable' }
        "core.attributesFile" { 'Git looks into this file for attributes' }
        "core.hooksPath" { 'Git will try to find your hooks in that directory' }
        "core.editor" { 'Commands such as commit and tag that let you edit messages by launching an editor use the value' }
        "core.commentChar" { 'Commands such as commit and tag that let you edit messages consider a line that begins with this character commented, and removes them after the editor returns (default #)' }
        "core.commentString" { 'Commands such as commit and tag that let you edit messages consider a line that begins with this character commented, and removes them after the editor returns (default #)' }
        "core.filesRefLockTimeout" { 'The length of time, in milliseconds, to retry when trying to lock an individual reference' }
        "core.packedRefsTimeout" { 'The length of time, in milliseconds, to retry when trying to lock the packed-refs file' }
        "core.pager" { 'Text viewer for use by Git commands' }
        "core.whitespace" { 'A comma separated list of common whitespace problems to notice' }
        "core.fsync" { 'A comma-separated list of components of the repository that should be hardened via the core.fsyncMethod when created or modified' }
        "core.fsyncMethod" { 'A value indicating the strategy Git will use to harden repository data using fsync and related primitives' }
        "core.fsyncObjectFiles" { 'This boolean will enable fsync() when writing object files. This setting is deprecated. Use core.fsync instead' }
        "core.preloadIndex" { 'Enable parallel index preload for operations like git diff' }
        "core.fscache" { 'Enable additional caching of file system data for some operations' }
        "core.longpaths" { 'Enable long path (> 260) support for builtin commands in Git for Windows' }
        "core.unsetenvvars" { 'Windows-only: comma-separated list of environment variable''s names that need to be unset before spawning any other process' }
        "core.restrictinheritedhandles" { 'Windows-only: override whether spawned processes inherit only standard file handles (stdin, stdout and stderr) or all handles' }
        "core.createObject" { 'You can set this to link, in which case a hardlink followed by a delete of the source are used to make sure that object creation will not overwrite existing objects' }
        "core.notesRef" { 'When showing commit messages, also show notes which are stored in the given ref' }
        "core.commitGraph" { 'If true, then git will read the commit-graph file (if it exists) to parse the graph structure of commits' }
        "core.useReplaceRefs" { 'If set to false, behave as if the --no-replace-objects option was given on the command line' }
        "core.multiPackIndex" { 'Use the multi-pack-index file to track multiple packfiles using a single index' }
        "core.sparseCheckout" { 'Enable "sparse checkout" feature' }
        "core.sparseCheckoutCone" { 'Enables the "cone mode" of the sparse checkout feature' }
        "core.abbrev" { 'Set the length object names are abbreviated to' }
        "core.maxTreeDepth" { 'The maximum depth Git is willing to recurse while traversing a tree' }
        "core.WSLCompat" { 'Tells Git whether to enable wsl compatibility mode' }

        "credential.helper" { 'Specify an external helper to be called when a username or password credential is needed' }
        "credential.useHttpPath" { 'When acquiring credentials, consider the "path" component of an http or https URL to be important' }
        "credential.username" { 'If no username is set for a network authentication, use this username by default' }
        # "credential.*.*" { }

        "credentialCache.ignoreSIGHUP" { "Tell git-credential-cache—​daemon to ignore SIGHUP, instead of quitting" }
        "credentialStore.lockTimeoutMS" { 'The length of time, in milliseconds, for git-credential-store to retry when trying to lock the credentials file' }

        "diff.autoRefreshIndex" { 'When using git diff to compare with work tree files, do not consider stat-only changes as changed' }
        "diff.dirstat" { 'A comma separated list of --dirstat parameters specifying the default behavior of the --dirstat option to git-diff and friends' }
        "diff.statNameWidth" { 'Limit the width of the filename part in --stat output' }
        "diff.statGraphWidth" { 'Limit the width of the graph part in --stat output' }
        "diff.context" { 'Generate diffs with <n> lines of context instead of the default of 3' }
        "diff.interHunkContext" { 'Show the context between diff hunks, up to the specified number of lines, thereby fusing the hunks that are close to each other' }
        "diff.external" { 'Diff generation is not performed using the internal diff machinery, but using the given command' }
        "diff.ignoreSubmodules" { 'Sets the default value of --ignore-submodules' }
        "diff.mnemonicPrefix" { 'If set, git diff uses a prefix pair that is different from the standard "a/" and "b/" depending on what is being compared' }
        "diff.noPrefix" { "If set, git diff does not show any source or destination prefix" }
        "diff.srcPrefix" { 'If set, git diff uses this source prefix' }
        "diff.dstPrefix" { 'If set, git diff uses this destination prefix' }
        "diff.relative" { "If set to true, git diff does not show changes outside of the directory and show pathnames relative to the current directory" }
        "diff.orderFile" { 'File indicating how to order files within a diff' }
        "diff.renameLimit" { 'The number of files to consider in the exhaustive portion of copy/rename detection; equivalent to the git diff option -l' }
        "diff.renames" { 'Whether and how Git detects renames' }
        "diff.suppressBlankEmpty" { 'A boolean to inhibit the standard behavior of printing a space before each empty output line' }
        "diff.submodule" { 'Specify the format in which differences in submodules are shown' }
        "diff.wordRegex" { 'A POSIX Extended Regular Expression used to determine what is a "word" when performing word-by-word difference calculations' }
        # "diff.*.*" { }
        "diff.indentHeuristic" { 'Set this option to false to disable the default heuristics that shift diff hunk boundaries to make patches easier to read' }
        "diff.algorithm" { 'Choose a diff algorithm' }
        "diff.wsErrorHighlight" { 'Highlight whitespace errors in the context, old or new lines of the diff' }
        "diff.colorMoved" { 'If set to either a valid <mode> or a true value, moved lines in a diff are colored differently, for details of valid modes see --color-moved in git-diff' }
        # "diff.colorMovedWS" {  }
        "diff.tool" { 'Controls which diff tool is used by git-difftool' }
        "diff.guitool" { 'Controls which diff tool is used by git-difftool when the -g/--gui flag is specified' }

        "difftool.*.cmd" { 'Specify the command to invoke the specified diff tool' }
        "difftool.*.path" { 'Override the path for the given tool' }
        "difftool.trustExitCode" { 'Exit difftool if the invoked diff tool returns a non-zero exit status' }
        "difftool.prompt" { "Prompt before each invocation of the diff tool" }
        "difftool.guiDefault" { 'Set true to use the diff.guitool by default (equivalent to specifying the --gui argument), or auto to select diff.guitool or diff.tool depending on the presence of a DISPLAY environment variable value' }

        "extensions.objectFormat" { 'Specify the hash algorithm to use' }
        "extensions.compatObjectFormat" { 'Specify a compatitbility hash algorithm to use' }
        "extensions.refStorage" { 'Specify the ref storage format to use' }
        "extensions.worktreeConfig" { 'If enabled, then worktrees will load config settings from the $GIT_DIR/config.worktree file in addition to the $GIT_COMMON_DIR/config file' }

        "fastimport.unpackLimit" { 'If the number of objects imported by git-fast-import is below this limit, then the objects will be unpacked into loose object files' }

        "feature." { 'These groups are created by the Git developer community as recommended defaults and are subject to change' }
        "feature.experimental" { 'Enable config options that are new to Git, and are being considered for future defaults' }
        "feature.manyFiles" { 'Enable config options that optimize for repos with many files in the working directory' }

        "fetch.recurseSubmodules" { 'Controls whether git fetch (and the underlying fetch in git pull) will recursively fetch into populated submodules' }
        "fetch.fsckObjects" { 'If it is set to true, git-fetch-pack will check all fetched objects' }
        "fetch.fsck.*" {
            $msg = $Current.Substring('fetch.fsck.'.Length)
            "Acts like fsck.$msg, but is used by git-fetch-pack instead of git-fsck"
        }
        "fetch.unpackLimit" { 'If the number of objects fetched over the Git native transfer is below this limit, then the objects will be unpacked into loose object files' }
        "fetch.prune" { 'If true, fetch will automatically behave as if the --prune option was given on the command line' }
        "fetch.pruneTags" { 'If true, fetch will automatically behave as if the refs/tags/*:refs/tags/* refspec was provided when pruning, if not set already' }
        "fetch.all" { 'If true, fetch will attempt to update all available remotes' }
        "fetch.output" { 'Control how ref update status is printed' }
        "fetch.negotiationAlgorithm" { 'Control how information about the commits in the local repository is sent when negotiating the contents of the packfile to be sent by the server' }
        "fetch.showForcedUpdates" { 'Set to false to enable --no-show-forced-updates in git-fetch and git-pull commands' }
        "fetch.parallel" { 'Specifies the maximal number of fetch operations to be run in parallel at a time' }
        "fetch.writeCommitGraph" { 'Set to true to write a commit-graph after every git fetch command that downloads a pack-file from a remote' }
        "fetch.bundleURI" { 'This value stores a URI for downloading Git object data from a bundle URI before performing an incremental fetch from the origin Git server' }
        "fetch.bundleCreationToken" { 'When using fetch.bundleURI to fetch incrementally from a bundle list that uses the "creationToken" heuristic, this config value stores the maximum creationToken value of the downloaded bundles' }

        "filter.*.clean" { 'The command which is used to convert the content of a worktree file to a blob upon checkin' }
        "filter.*.smudge" { 'The command which is used to convert the content of a blob object to a worktree file upon checkout' }

        "format.attach" { 'Enable multipart/mixed attachments as the default for format-patch' }
        "format.from" { 'Provides the default value for the --from option to format-patch' }
        "format.forceInBodyFrom" { 'Provides the default value for the --force-in-body-from option to format-patch' }
        "format.numbered" { 'A boolean which can enable or disable sequence numbers in patch subjects' }
        "format.headers" { 'Additional email headers to include in a patch to be submitted by mail' }
        "format.to" { 'Additional recipients to include in a patch to be submitted by mail' }
        "format.cc" { 'Additional recipients to include in a patch to be submitted by mail' }
        "format.subjectPrefix" { 'The default for format-patch is to output files with the [PATCH] subject prefix' }
        "format.coverFromDescription" { "The default mode for format-patch to determine which parts of the cover letter will be populated using the branch’s description" }
        "format.signature" { 'The default for format-patch is to output a signature containing the Git version number' }
        "format.signatureFile" { "Works just like format.signature except the contents of the file specified by this variable will be used as the signature" }
        "format.suffix" { 'The default for format-patch is to output files with the suffix `.patch`' }
        "format.encodeEmailHeaders" { 'Encode email headers that have non-ASCII characters with "Q-encoding" (described in RFC 2047) for email transmission' }
        "format.pretty" { 'The default pretty format for log/show/whatchanged command' }
        "format.thread" { 'The default threading style for git format-patch' }
        "format.signOff" { 'A boolean value which lets you enable the -s/--signoff option of format-patch by default' }
        "format.coverLetter" { 'A boolean that controls whether to generate a cover-letter when format-patch is invoked, but in addition can be set to "auto", to generate a cover-letter only when there’’s more than one patch' }
        "format.outputDirectory" { 'Set a custom directory to store the resulting files instead of the current working directory' }
        "format.filenameMaxLength" { 'The maximum length of the output filenames generated by the format-patch command; defaults to 64' }
        "format.useAutoBase" { 'A boolean value which lets you enable the --base=auto option of format-patch by default' }
        "format.notes" { 'Provides the default value for the --notes option to format-patch' }
        "format.mboxrd" { 'A boolean value which enables the robust "mboxrd" format when --stdout is in use to escape "^>+From " lines' }
        "format.noprefix" { 'If set, do not show any source or destination prefix in patches' }

        "fsck.skipList" {
            'The path to a list of object names that are known to be broken in a non-fatal way and should be ignored'
            break
        }
        "fsck.*" { 'This feature is intended to support working with legacy repositories containing such data' }

        "fsmonitor.allowRemote" { 'If true, the fsmonitor daemon allow git to work with network-mounted repositories' }
        "fsmonitor.socketDir" { 'This Mac OS-specific option, if set, specifies the directory in which to create the Unix domain socket used for communication between the fsmonitor daemon and various Git commands' }
        "gc.aggressiveDepth" { 'The depth parameter used in the delta compression algorithm used by git gc --aggressive' }
        "gc.aggressiveWindow" { 'The window size parameter used in the delta compression algorithm used by git gc --aggressive' }
        "gc.auto" { 'When there are approximately more than this many loose objects in the repository, git gc --auto will pack them' }
        "gc.autoPackLimit" { 'When there are more than this many packs that are not marked with *.keep file in the repository, git gc --auto consolidates them into one larger pack' }
        "gc.autoDetach" { 'Make git gc --auto return immediately and run in the background if the system supports it' }
        "gc.bigPackThreshold" { 'If non-zero, all non-cruft packs larger than this limit are kept when git gc is run' }
        "gc.writeCommitGraph" { 'If true, then gc will rewrite the commit-graph file when git-gc is run' }
        "gc.logExpiry" { 'If the file gc.log exists, then git gc --auto will print its content and exit with status zero instead of running unless that file is more than gc.logExpiry old' }
        "gc.packRefs" { 'Running git pack-refs in a repository renders it unclonable by Git versions prior to 1.5.1.2 over dumb transports such as HTTP' }
        "gc.cruftPacks" { 'Store unreachable objects in a cruft pack (see git-repack) instead of as loose objects' }
        "gc.maxCruftSize" { 'Limit the size of new cruft packs when repacking' }
        "gc.pruneExpire" { 'Override the grace period with this config variable' }
        # "gc.reflogExpire" { }
        # "gc.*.reflogExpire" { }
        # "gc.reflogExpireUnreachable" {  }
        # "gc.*.reflogExpireUnreachable" {  }
        "gc.recentObjectsHook" { 'When considering whether or not to remove an object, use the shell to execute the specified command(s)' }
        "gc.repackFilter" { 'When repacking, use the specified filter to move certain objects into a separate packfile' }
        "gc.repackFilterTo" { 'When repacking and using a filter, see gc.repackFilter, the specified location will be used to create the packfile containing the filtered out objects' }
        "gc.rerereResolved" { 'Records of conflicted merge you resolved earlier are kept for this many days when git rerere gc is run' }
        "gc.rerereUnresolved" { 'Records of conflicted merge you have not resolved are kept for this many days when git rerere gc is run' }

        "gitcvs.commitMsgAnnotation" { 'Append this string to each commit message' }
        "gitcvs.enabled" { 'Whether the CVS server interface is enabled for this repository' }
        "gitcvs.logFile" { 'Path to a log file where the CVS server interface well… logs various stuff' }
        "gitcvs.usecrlfattr" { 'If true, the server will look up the end-of-line conversion attributes for files to determine the -k modes to use' }
        "gitcvs.allBinary" { 'This is used if gitcvs.usecrlfattr does not resolve the correct -kb mode to use' }
        "gitcvs.dbName" { 'Database used by git-cvsserver to cache revision information derived from the Git repository' }
        "gitcvs.dbDriver" { 'Used Perl DBI driver' }
        "gitcvs.dbUser" { 'Database user' }
        "gitcvs.dbPass" { 'Database password' }
        "gitcvs.dbTableNamePrefix" { 'Database table name prefix' }

        # "gitweb.category" { }
        # "gitweb.description" { }
        # "gitweb.owner" { }
        # "gitweb.url" { }
        # "gitweb.avatar" { }
        # "gitweb.blame" { }
        # "gitweb.grep" { }
        # "gitweb.highlight" { }
        # "gitweb.patches" { }
        # "gitweb.pickaxe" { }
        # "gitweb.remote_heads" { }
        # "gitweb.showSizes" { }
        # "gitweb.snapshot" { }

        "gpg.program" { 'Use this custom program instead of "gpg" found on $PATH when making or verifying a PGP signature' }
        "gpg.format" { 'Specifies which key format to use when signing with --gpg-sign' }
        "gpg.*.program" { 'Use this to customize the program used for the signing format you chose' }
        "gpg.minTrustLevel" { 'Specifies a minimum trust level for signature verification' }
        "gpg.ssh.defaultKeyCommand" { 'This command will be run when user.signingkey is not set and a ssh signature is requested' }
        "gpg.ssh.allowedSignersFile" { 'A file containing ssh public keys which you are willing to trust' }
        "gpg.ssh.revocationFile" { 'Either a SSH KRL or a list of revoked public keys' }

        "grep.lineNumber" { "If set to true, enable -n option by default" }
        "grep.column" { "If set to true, enable the --column option by default" }
        "grep.patternType" { 'Set the default matching behavior' }
        "grep.extendedRegexp" { 'If set to true, enable --extended-regexp option by default' }
        "grep.threads" { 'Number of grep worker threads to use' }
        "grep.fullName" { "If set to true, enable --full-name option by default" }
        "grep.fallbackToNoIndex" { 'If set to true, fall back to git grep --no-index if git grep is executed outside of a git repository' }

        "gui.commitMsgWidth" { 'Defines how wide the commit message window is in the git-gui' }
        "gui.diffContext" { 'Specifies how many context lines should be used in calls to diff made by the git-gui' }
        "gui.displayUntracked" { 'Determines if git-gui shows untracked files in the file list' }
        "gui.encoding" { 'Specifies the default character encoding to use for displaying of file contents in git-gui and gitk' }
        "gui.matchTrackingBranch" { 'Determines if new branches created with git-gui should default to tracking remote branches with matching names or not' }
        "gui.newBranchTemplate" { "Is used as a suggested name when creating new branches using the git-gui" }
        "gui.pruneDuringFetch" { '"true" if git-gui should prune remote-tracking branches when performing a fetch' }
        "gui.trustmtime" { 'Determines if git-gui should trust the file modification timestamp or not' }
        "gui.spellingDictionary" { 'Specifies the dictionary used for spell checking commit messages in the git-gui' }
        "gui.fastCopyBlame" { 'If true, git gui blame uses -C instead of -C -C for original location detection' }
        "gui.copyBlameThreshold" { 'Specifies the threshold to use in git gui blame original location detection, measured in alphanumeric characters' }
        "gui.blamehistoryctx" { 'Specifies the radius of history context in days to show in gitk for the selected commit, when the Show History Context menu item is invoked from git gui blame' }

        "guitool.*.cmd" { 'Specifies the shell command line to execute when the corresponding item of the git-gui Tools menu is invoked' }
        "guitool.*.needsFile" { 'Run the tool only if a diff is selected in the GUI' }
        "guitool.*.noConsole" { "Run the command silently, without creating a window to display its output" }
        "guitool.*.noRescan" { "Don’t rescan the working directory for changes after the tool finishes execution" }
        "guitool.*.confirm" { "Show a confirmation dialog before actually running the tool" }
        "guitool.*.argPrompt" { 'Request a string argument from the user, and pass it to the tool through the ARGS environment variable' }
        "guitool.*.revPrompt" { 'Request a single valid revision from the user, and set the REVISION environment variable' }
        "guitool.*.revUnmerged" { 'Show only unmerged branches in the revPrompt subdialog' }
        "guitool.*.title" { 'Specifies the title to use for the prompt dialog' }
        "guitool.*.prompt" { 'Specifies the general prompt string to display at the top of the dialog, before subsections for argPrompt and revPrompt' }

        "help.browser" { 'Specify the browser that will be used to display help in the web format' }
        "help.format" { 'Override the default help format used by git-help' }
        "help.autoCorrect" { 'If git detects typos and can identify exactly one valid command similar to the error, git will try to suggest the correct command or even run the suggestion automatically' }
        "help.htmlPath" { 'Specify the path where the HTML documentation resides' }

        "http.proxy" { 'Override the HTTP proxy' }
        "http.proxyAuthMethod" { 'Set the method with which to authenticate against the HTTP proxy' }
        "http.proxySSLCert" { 'The pathname of a file that stores a client certificate to use to authenticate with an HTTPS proxy' }
        "http.proxySSLKey" { 'The pathname of a file that stores a private key to use to authenticate with an HTTPS proxy' }
        "http.proxySSLCertPasswordProtected" { "Enable Git’s password prompt for the proxy SSL certificate" }
        "http.proxySSLCAInfo" { 'Pathname to the file containing the certificate bundle that should be used to verify the proxy with when using an HTTPS proxy' }
        "http.emptyAuth" { 'Attempt authentication without seeking a username or password' }
        "http.delegation" { 'Control GSSAPI credential delegation' }
        "http.extraHeader" { 'Pass an additional HTTP header when communicating with a server' }
        "http.cookieFile" { 'The pathname of a file containing previously stored cookie lines, which should be used in the Git http session, if they match the server' }
        "http.saveCookies" { 'If set, store cookies received during requests to the file specified by http.cookieFile' }
        "http.version" { 'Use the specified HTTP protocol version when communicating with a server' }
        "http.curloptResolve" { 'Hostname resolution information that will be used first by libcurl when sending HTTP requests' }
        "http.sslVersion" { 'The SSL version to use when negotiating an SSL connection' }
        "http.sslCipherList" { 'A list of SSL ciphers to use when negotiating an SSL connection' }
        "http.sslVerify" { 'Whether to verify the SSL certificate when fetching or pushing over HTTPS' }
        "http.sslCert" { 'File containing the SSL certificate when fetching or pushing over HTTPS' }
        "http.sslKey" { 'File containing the SSL private key when fetching or pushing over HTTPS' }
        "http.sslCertPasswordProtected" { "Enable Git’s password prompt for the SSL certificate" }
        "http.sslCAInfo" { 'File containing the certificates to verify the peer with when fetching or pushing over HTTPS' }
        "http.sslCAPath" { 'Path containing files with the CA certificates to verify the peer with when fetching or pushing over HTTPS' }
        "http.sslBackend" { 'Name of the SSL backend to use' }
        "http.schannelCheckRevoke" { 'Used to enforce or disable certificate revocation checks in cURL when http.sslBackend is set to "schannel" via "true" and "false", respectively' }
        "http.schannelUseSSLCAInfo" { 'As of cURL v7.60.0, the Secure Channel backend can use the certificate bundle provided via http.sslCAInfo, but that would override the Windows Certificate Store' }
        "http.sslAutoClientCert" { "As of cURL v7.77.0, the Secure Channel backend won’t automatically send client certificates from the Windows Certificate Store anymore" }
        "http.pinnedPubkey" { 'Public key of the https service' }
        "http.sslTry" { 'Attempt to use AUTH SSL/TLS and encrypted data transfers when connecting via regular FTP protocol' }
        "http.maxRequests" { 'How many HTTP requests to launch in parallel' }
        "http.minSessions" { 'The number of curl sessions (counted across slots) to be kept across requests' }
        "http.postBuffer" { 'Maximum size in bytes of the buffer used by smart HTTP transports when POSTing data to the remote system' }
        "http.lowSpeedLimit, http.lowSpeedTime" { 'If the HTTP transfer speed, in bytes per second, is less than http.lowSpeedLimit for longer than http.lowSpeedTime seconds, the transfer is aborted' }
        "http.noEPSV" { 'A boolean which disables using of EPSV ftp command by curl' }
        "http.userAgent" { 'The HTTP USER_AGENT string presented to an HTTP server' }
        "http.followRedirects" { 'Whether git should follow HTTP redirects' }
        # "http.*.*" { }

        "i18n.commitEncoding" { 'Character encoding the commit messages are stored in' }
        "i18n.logOutputEncoding" { "Character encoding the commit messages are converted to when running git log and friends" }

        "imap.folder" { 'The folder to drop the mails into, which is typically the Drafts folder' }
        "imap.tunnel" { 'Command used to set up a tunnel to the IMAP server through which commands will be piped instead of using a direct network connection to the server' }
        "imap.host" { 'A URL identifying the server' }
        "imap.user" { "The username to use when logging in to the server" }
        "imap.pass" { "The password to use when logging in to the server" }
        "imap.port" { 'An integer port number to connect to on the server' }
        "imap.sslverify" { 'A boolean to enable/disable verification of the server certificate used by the SSL/TLS connection' }
        "imap.preformattedHTML" { 'A boolean to enable/disable the use of html encoding when sending a patch' }
        "imap.authMethod" { 'Specify the authentication method for authenticating with the IMAP server' }

        "include.path" { 'Special variables to include other configuration files' }
        "include.*.path" { 'Special variables to include other configuration files' }

        "index.recordEndOfIndexEntries" { ' Specifies whether the index file should include an "End Of Index Entry" section. ' }
        "index.recordOffsetTable" { ' Specifies whether the index file should include an "Index Entry Offset Table" section. ' }
        "index.sparse" { ' When enabled, write the index using sparse-directory entries. ' }
        "index.threads" { ' Specifies the number of threads to spawn when loading the index. ' }
        "index.version" { ' Specify the version with which new index files should be initialized. ' }
        "index.skipHash" { ' When enabled, do not compute the trailing hash for the index file. ' }

        "init.templateDir" { ' Specify the directory from which templates will be copied. ' }
        "init.defaultBranch" { ' Allows overriding the default branch name. ' }

        "instaweb.browser" { ' Specify the program that will be used to browse your working repository in gitweb. ' }
        "instaweb.httpd" { ' The HTTP daemon command-line to start gitweb on your working repository. ' }
        "instaweb.local" { "If true the web server started by git-instaweb will be bound to the local IP (127.0.0.1)" }
        "instaweb.modulePath" { ' The default module path for git-instaweb to use instead of /usr/lib/apache2/modules. ' }
        "instaweb.port" { ' The port number to bind the gitweb httpd to. ' }

        "interactive.singleKey" { ' In interactive commands, allow the user to provide one-letter input with a single key (i.e., without hitting enter). ' }
        "interactive.diffFilter" { ' When an interactive command shows a colorized diff, git will pipe the diff through the shell command defined by this configuration variable. ' }

        "log.abbrevCommit" { ' If true, makes git-log, git-show, and git-whatchanged assume --abbrev-commit. ' }
        "log.date" { ' Set the default date-time mode for the log command. ' }
        "log.decorate" { ' Print out the ref names of any commits that are shown by the log command. ' }
        "log.initialDecorationSet" { ' If all is specified, then show all refs as decorations. ' }
        "log.excludeDecoration" { ' Exclude the specified patterns from the log decorations. ' }
        "log.diffMerges" { ' Set diff format to be used when --diff-merges=on is specified, see --diff-merges in git-log for details. ' }
        "log.follow" { ' If true, git log will act as if the --follow option was used when a single <path> is given. ' }
        "log.graphColors" { "A list of colors, separated by commas, that can be used to draw history lines in git log --graph" }
        "log.showRoot" { 'If true, the initial commit will be shown as a big creation event' }
        "log.showSignature" { "If true, makes git-log, git-show, and git-whatchanged assume --show-signature" }
        "log.mailmap" { 'If true, makes git-log, git-show, and git-whatchanged assume --use-mailmap, otherwise assume --no-use-mailmap' }

        "lsrefs.unborn" { 'May be "advertise" (the default), "allow", or "ignore"' }

        "mailinfo.scissors" { 'If true, makes git-mailinfo (and therefore git-am) act by default as if the --scissors option was provided on the command-line' }
        "mailmap.file" { 'The location of an augmenting mailmap file' }
        "mailmap.blob" { 'Like mailmap.file, but consider the value as a reference to a blob in the repository' }
        "maintenance.auto" { 'This boolean config option controls whether some commands run git maintenance run --auto after doing their normal work' }
        "maintenance.strategy" { 'This string config option provides a way to specify one of a few recommended schedules for background maintenance' }
        "maintenance.*.enabled" { 'Whether the maintenance task is run when no --task option is specified to git maintenance run' }
        "maintenance.*.schedule" { 'Whether or not the given runs during a git maintenance run --schedule=<frequency> command' }
        "maintenance.commit-graph.auto" { 'This integer config option controls how often the commit-graph task should be run as part of git maintenance run --auto' }
        "maintenance.loose-objects.auto" { 'This integer config option controls how often the loose-objects task should be run as part of git maintenance run --auto' }
        "maintenance.incremental-repack.auto" { 'This integer config option controls how often the incremental-repack task should be run as part of git maintenance run --auto' }

        "man.viewer" { 'Specify the programs that may be used to display help in the man format' }
        "man.*.cmd" { 'Specify the command to invoke the specified man viewer' }
        "man.*.path" { 'Override the path for the given tool that may be used to display help in the man format' }

        "merge.conflictStyle" { 'Specify the style in which conflicted hunks are written out to working tree files upon merge' }
        "merge.defaultToUpstream" { 'If merge is called without any commit argument, merge the upstream branches configured for the current branch by using their last observed values stored in their remote-tracking branches' }
        "merge.ff" { 'When set to false, this variable tells Git to create an extra merge commit in such a case' }
        "merge.verifySignatures" { 'If true, this is equivalent to the --verify-signatures command line option' }
        "merge.branchdesc" { 'In addition to branch names, populate the log message with the branch description text associated with them' }
        "merge.log" { 'In addition to branch names, populate the log message with at most the specified number of one-line descriptions from the actual commits that are being merged' }
        "merge.suppressDest" { 'The default merge message computed for merges into these integration branches will omit "into <branch name>" from its title' }
        "merge.renameLimit" { 'The number of files to consider in the exhaustive portion of rename detection during a merge' }
        "merge.renames" { 'Whether Git detects renames' }
        "merge.directoryRenames" { 'Whether Git detects directory renames, affecting what happens at merge time to new files added to a directory on one side of history when that directory was renamed on the other side of history' }
        "merge.renormalize" { 'Tell Git that canonical representation of files in the repository has changed over time' }
        "merge.stat" { 'Whether to print the diffstat between ORIG_HEAD and the merge result at the end of the merge' }
        "merge.autoStash" { 'When set to true, automatically create a temporary stash entry before the operation begins, and apply it after the operation ends' }
        "merge.tool" { 'Controls which merge tool is used by git-mergetool' }
        "merge.guitool" { 'Controls which merge tool is used by git-mergetool when the -g/--gui flag is specified' }
        "merge.verbosity" { 'Controls the amount of output shown by the recursive merge strategy' }
        "merge.*.name" { 'Defines a human-readable name for a custom low-level merge driver' }
        "merge.*.driver" { 'Defines the command that implements a custom low-level merge driver' }
        "merge.*.recursive" { 'Names a low-level merge driver to be used when performing an internal merge between common ancestors' }
        "mergetool.*.path" { 'Override the path for the given tool' }
        "mergetool.*.cmd" { 'Specify the command to invoke the specified merge tool' }
        "mergetool.*.hideResolved" { 'Allows the user to override the global mergetool.hideResolved value for a specific tool' }
        "mergetool.*.trustExitCode" { 'For a custom merge command, specify whether the exit code of the merge command can be used to determine whether the merge was successful' }
        "mergetool.meld.hasOutput" { 'Setting mergetool.meld.hasOutput to true tells Git to unconditionally use the --output option, and false avoids using --output' }
        "mergetool.meld.useAutoMerge" { 'When the --auto-merge is given, meld will merge all non-conflicting parts automatically, highlight the conflicting parts, and wait for user decision' }
        "mergetool.*.layout" { "Configure the split window layout for vimdiff’s <variant>, which is any of vimdiff, nvimdiff, gvimdiff" }
        "mergetool.hideResolved" { "During a merge, Git will automatically resolve as many conflicts as possible and write the MERGED file containing conflict markers around any conflicts that it cannot resolve; LOCAL and REMOTE normally represent the versions of the file from before Git’s conflict resolution" }
        "mergetool.keepBackup" { 'After performing a merge, the original file with conflict markers can be saved as a file with a .orig extension' }
        "mergetool.keepTemporaries" { 'When invoking a custom merge tool, Git uses a set of temporary files to pass to the tool' }
        "mergetool.writeToTemp" { 'Git writes temporary BASE, LOCAL, and REMOTE versions of conflicting files in the worktree by default' }
        "mergetool.prompt" { "Prompt before each invocation of the merge resolution program" }
        "mergetool.guiDefault" { "Set true to use the merge.guitool by default, or auto to select merge.guitool or merge.tool depending on the presence of a DISPLAY environment variable value" }

        "notes.mergeStrategy" { 'Which merge strategy to choose by default when resolving notes conflicts' }
        "notes.*.mergeStrategy" { 'Which merge strategy to choose when doing a notes merge into refs/notes/<name>' }
        "notes.displayRef" { 'Which ref (or refs, if a glob or specified more than once), in addition to the default set by core.notesRef or GIT_NOTES_REF, to read notes from when showing commit messages with the git log family of commands' }
        "notes.rewrite.*" { 'When rewriting commits with <command>, if this variable is false, git will not copy notes from the original to the rewritten commit' }
        "notes.rewriteMode" { 'When copying notes during a rewrite, determines what to do if the target commit already has a note' }
        "notes.rewriteRef" { 'When copying notes during a rewrite, specifies the (fully qualified) ref whose notes should be copied' }
        "pack.window" { 'The size of the window used by git-pack-objects when no window size is given on the command line' }
        "pack.depth" { 'The maximum delta depth used by git-pack-objects when no maximum depth is given on the command line' }
        "pack.windowMemory" { 'The maximum size of memory that is consumed by each thread in git-pack-objects for pack window memory when no limit is given on the command line' }
        "pack.compression" { 'An integer -1..9, indicating the compression level for objects in a pack file' }
        "pack.allowPackReuse" { 'When true or "single", and when reachability bitmaps are enabled, pack-objects will try to send parts of the bitmapped packfile verbatim' }
        "pack.island" { 'An extended regular expression configuring a set of delta islands' }
        "pack.islandCore" { 'Specify an island name which gets to have its objects be packed first' }
        "pack.deltaCacheSize" { 'The maximum memory in bytes used for caching deltas in git-pack-objects before writing them out to a pack' }
        "pack.deltaCacheLimit" { 'The maximum size of a delta, that is cached in git-pack-objects' }
        "pack.threads" { 'Specifies the number of threads to spawn when searching for best delta matches' }
        "pack.indexVersion" { 'Specify the default pack index version' }
        "pack.packSizeLimit" { 'The maximum size of a pack' }
        "pack.useBitmaps" { 'When true, git will use pack bitmaps (if available) when packing to stdout (e.g., during the server side of a fetch)' }
        "pack.useBitmapBoundaryTraversal" { 'When true, Git will use an experimental algorithm for computing reachability queries with bitmaps' }
        "pack.useSparse" { 'When true, git will default to using the --sparse option in git pack-objects when the --revs option is present' }
        "pack.preferBitmapTips" { 'When selecting which commits will receive bitmaps, prefer a commit at the tip of any reference that is a suffix of any value of this configuration over any other commits in the "selection window"' }
        "pack.writeBitmapHashCache" { 'When true, git will include a "hash cache" section in the bitmap index (if one is written)' }
        "pack.writeBitmapLookupTable" { 'When true, Git will include a "lookup table" section in the bitmap index (if one is written)' }
        "pack.readReverseIndex" { 'When true, git will read any .rev file(s) that may be available' }
        "pack.writeReverseIndex" { 'When true, git will write a corresponding .rev file for each new packfile that it writes in all places except for git-fast-import and in the bulk checkin mechanism' }

        "pager.*" {
            $cmd = $Current.Substring('pager.'.Length)
            if ($cmd) {
                $cmd = "<$cmd> "
            }
            "Turns on or off pagination of the output of a particular Git subcommand ${cmd}when writing to a tty"
        }

        "pretty.*" { 'Alias for a --pretty= format string, as specified in git-log' }

        "protocol.allow" { "If set, provide a user defined default policy for all protocols which don’t explicitly have a policy (protocol.<name>.allow)" }
        "protocol.*.allow" { 'Set a policy to be used by protocol <name> with clone/fetch/push commands' }
        "protocol.version" { 'If set, clients will attempt to communicate with a server using the specified protocol version' }

        "pull.ff" { 'When set to false, this variable tells Git to create an extra merge commit in such a case' }
        "pull.rebase" { 'When true, rebase branches on top of the fetched branch, instead of merging the default branch from the default remote when "git pull" is run' }
        "pull.octopus" { "The default merge strategy to use when pulling multiple branches at once" }
        "pull.twohead" { "The default merge strategy to use when pulling a single branch" }
        "push.autoSetupRemote" { 'If set to "true" assume --set-upstream on default push when no upstream tracking exists for the current branch; this option takes effect with push.default options simple, upstream, and current' }
        "push.default" { 'Defines the action git push should take if no refspec is given' }
        "push.followTags" { 'If set to true, enable --follow-tags option by default' }
        "push.gpgSign" { 'A true value causes all pushes to be GPG signed, as if --signed is passed to git-push' }
        "push.pushOption" { 'When no --push-option=<option> argument is given from the command line, git push behaves as if each <value> of this variable is given as --push-option=<value>' }
        "push.recurseSubmodules" { 'May be "check", "on-demand", "only", or "no", with the same behavior as that of "push --recurse-submodules"' }
        "push.useForceIfIncludes" { 'If set to "true", it is equivalent to specifying --force-if-includes as an option to git-push in the command line' }
        "push.negotiate" { 'If set to "true", attempt to reduce the size of the packfile sent by rounds of negotiation in which the client and the server attempt to find commits in common' }
        "push.useBitmaps" { 'If set to "false", disable use of bitmaps for "git push" even if pack.useBitmaps is "true", without preventing other git operations from using bitmaps' }

        "rebase.backend" { 'Default backend to use for rebasing' }
        "rebase.stat" { 'Whether to show a diffstat of what changed upstream since the last rebase' }
        "rebase.autoSquash" { 'If set to true, enable the --autosquash option of git-rebase by default for interactive mode' }
        "rebase.autoStash" { 'When set to true, automatically create a temporary stash entry before the operation begins, and apply it after the operation ends' }
        "rebase.updateRefs" { "If set to true enable --update-refs option by default" }
        "rebase.missingCommitsCheck" { 'If set to "warn", git rebase -i will print a warning if some commits are removed' }
        "rebase.instructionFormat" { 'A format string, as specified in git-log, to be used for the todo list during an interactive rebase' }
        "rebase.abbreviateCommands" { 'If set to true, git rebase will use abbreviated command names in the todo list resulting' }
        "rebase.rescheduleFailedExec" { 'Automatically reschedule exec commands that failed' }
        "rebase.forkPoint" { "If set to false set --no-fork-point option by default" }
        "rebase.rebaseMerges" { 'Whether and how to set the --rebase-merges option by default' }
        "rebase.maxLabelLength" { 'When generating label names from commit subjects, truncate the names to this length' }

        "receive.advertiseAtomic" { 'If true, git-receive-pack will advertise the atomic push capability to its clients' }
        "receive.advertisePushOptions" { 'When set to true, git-receive-pack will advertise the push options capability to its clients' }
        "receive.autogc" { 'If true, git-receive-pack will run "git maintenance run --auto" after receiving data from git-push and updating refs' }
        "receive.certNonceSeed" { 'By setting this variable to a string, git receive-pack will accept a git push --signed and verify it by using a "nonce" protected by HMAC using this string as a secret key' }
        "receive.certNonceSlop" { 'When a git push --signed sends a push certificate with a "nonce" that was issued by a receive-pack serving the same repository within this many seconds, export the "nonce" found in the certificate to GIT_PUSH_CERT_NONCE to the hooks' }
        "receive.fsckObjects" { 'If it is set to true, git-receive-pack will check all received objects' }
        "receive.fsck.skipList" {
            'Acts like fsck.skipList, but is used by git-receive-pack instead of git-fsck' 
            break
        }
        "receive.fsck.*" { 'Acts like fsck.*, but is used by git-receive-pack instead of git-fsck' }
        "receive.keepAlive" { 'After receiving the pack from the client, receive-pack may produce no output (if --quiet was specified) while processing the pack, causing some networks to drop the TCP connection' }
        "receive.unpackLimit" { 'If the number of objects received in a push is below this limit then the objects will be unpacked into loose object files' }
        "receive.maxInputSize" { 'If the size of the incoming pack stream is larger than this limit, then git-receive-pack will error out, instead of accepting the pack file' }
        "receive.denyDeletes" { 'If set to true, git-receive-pack will deny a ref update that deletes the ref' }
        "receive.denyDeleteCurrent" { "If set to true, git-receive-pack will deny a ref update that deletes the currently checked out branch of a non-bare repository" }
        "receive.denyCurrentBranch" { 'If set to true or "refuse", git-receive-pack will deny a ref update to the currently checked out branch of a non-bare repository' }
        "receive.denyNonFastForwards" { 'If set to true, git-receive-pack will deny a ref update which is not a fast-forward' }
        "receive.hideRefs" { 'This variable is the same as transfer.hideRefs, but applies only to receive-pack' }
        "receive.procReceiveRefs" { 'This is a multi-valued variable that defines reference prefixes to match the commands in receive-pack' }
        "receive.updateServerInfo" { "If set to true, git-receive-pack will run git-update-server-info after receiving data from git-push and updating refs" }
        "receive.shallowUpdate" { 'If set to true, .git/shallow can be updated when new refs require new shallow roots' }
        "remote.pushDefault" { 'The remote to push to by default' }
        "remote.<name>.url" { 'The URL of a remote repository' }
        "remote.*.pushurl" { 'The push URL of a remote repository' }
        "remote.*.proxy" { 'For remotes that require curl (http, https and ftp), the URL to the proxy to use for that remote' }
        "remote.*.proxyAuthMethod" { 'For remotes that require curl (http, https and ftp), the method to use for authenticating against the proxy in use (probably set in remote.<name>.proxy)' }
        "remote.*.fetch" { 'The default set of "refspec" for git-fetch' }
        "remote.*.push" { 'The default set of "refspec" for git-push' }
        "remote.*.mirror" { "If true, pushing to this remote will automatically behave as if the --mirror option was given on the command line" }
        "remote.*.skipDefaultUpdate" { "If true, this remote will be skipped by default when updating using git-fetch or the update subcommand of git-remote" }
        "remote.*.skipFetchAll" { "If true, this remote will be skipped by default when updating using git-fetch or the update subcommand of git-remote" }
        "remote.*.receivepack" { 'The default program to execute on the remote side when pushing' }
        "remote.*.uploadpack" { 'The default program to execute on the remote side when fetching' }
        "remote.*.tagOpt" { 'Setting this value to --no-tags disables automatic tag following when fetching from remote' }
        "remote.*.vcs" { "Setting this to a value <vcs> will cause Git to interact with the remote with the git-remote-<vcs> helper" }
        "remote.*.prune" { 'When set to true, fetching from this remote by default will also remove any remote-tracking references that no longer exist on the remote (as if the --prune option was given on the command line)' }
        "remote.*.pruneTags" { 'When set to true, fetching from this remote by default will also remove any local tags that no longer exist on the remote if pruning is activated in general via remote.*.prune, fetch.prune or --prune' }
        "remote.*.promisor" { "When set to true, this remote will be used to fetch promisor objects" }
        "remote.*.partialclonefilter" { 'The filter that will be applied when fetching from this promisor remote' }
    
        "remotes.*" {
            $msg = $Current.Substring('remotes.'.Length)
            "The list of remotes which are fetched by `"git remote update $msg`""
        }
        # "repack.useDeltaBaseOffset" {  }
        "repack.packKeptObjects" { 'If set to true, makes git repack act as if --pack-kept-objects was passed' }
        "repack.useDeltaIslands" { 'If set to true, makes git repack act as if --delta-islands was passed' }
        "repack.writeBitmaps" { 'When true, git will write a bitmap index when packing all objects to disk' }
        "repack.updateServerInfo" { 'If set to false, git-repack will not run git-update-server-info' }
        "repack.cruftWindow" { 'Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line' }
        "repack.cruftWindowMemory" { 'Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line' }
        "repack.cruftDepth" { 'Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line' }
        "repack.cruftThreads" { 'Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line' }

        "rerere.autoUpdate" { 'When set to true, git-rerere updates the index with the resulting contents after it cleanly resolves conflicts using previously recorded resolutions' }
        "rerere.enabled" { 'Activate recording of resolved conflicts, so that identical conflict hunks can be resolved automatically, should they be encountered again' }

        "revert.reference" { "Setting this variable to true makes git revert behave as if the --reference option is given" }

        "safe.bareRepository" { 'Specifies which bare repositories Git will work with' }
        "safe.directory" { 'These config entries specify Git-tracked directories that are considered safe even if they are owned by someone other than the current user' }

        "sendemail.identity" { 'A configuration identity' }
        "sendemail.smtpEncryption" { 'See git-send-email for description' }
        "sendemail.smtpSSLCertPath" { 'Path to ca-certificates (either a directory or a single file)' }
        "sendemail.*.*" { "Identity-specific versions of the sendemail.* parameters" }
        "sendemail.multiEdit" { 'If true, a single editor instance will be spawned to edit files you have to edit (patches when --annotate is used, and the summary when --compose is used)' }
        "sendemail.confirm" { 'Sets the default for whether to confirm before sending' }
        "sendemail.aliasesFile" { 'To avoid typing long email addresses, point this to one or more email aliases files' }
        "sendemail.aliasFileType" { 'Format of the file(s) specified in sendemail.aliasesFile' }
        "sendemail.annotate" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.bcc" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.cc" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.ccCmd" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.chainReplyTo" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.envelopeSender" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.from" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.headerCmd" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.signedOffByCc" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.smtpPass" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.suppressCc" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.suppressFrom" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.to" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.toCmd" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.smtpDomain" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.smtpServer" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.smtpServerPort" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.smtpServerOption" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.smtpUser" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.thread" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.transferEncoding" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.validate" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.xmailer" { 'These configuration variables all provide a default for git-send-email command-line options' }
        "sendemail.smtpBatchSize" { 'Number of messages to be sent per connection, after that a relogin will happen' }
        "sendemail.smtpReloginDelay" { 'Seconds to wait before reconnecting to the smtp server' }
        "sendemail.forbidSendmailVariables" { 'To avoid common misconfiguration mistakes, git-send-email will abort with a warning if any configuration options for "sendmail" exist' }

        "sendpack.sideband" { 'Allows to disable the side-band-64k capability for send-pack even when it is advertised by the server' }

        "sequence.editor" { 'Text editor used by git rebase -i for editing the rebase instruction file' }

        "showBranch.default" { 'The default set of branches for git-show-branch' }

        # "sparse.expectFilesOutsideOfPatterns" {  }

        "splitIndex.maxPercentChange" { 'When the split index feature is used, this specifies the percent of entries the split index can contain compared to the total number of entries in both the split index and the shared index before a new shared index is written' }
        "splitIndex.sharedIndexExpire" { 'When the split index feature is used, shared index files that were not modified since the time this variable specifies will be removed when a new shared index file is created' }

        "ssh.variant" { 'Override detection of OpenSSH options' }

        "stash.showIncludeUntracked" { 'If this is set to true, the git stash show command will show the untracked files of a stash entry' }
        "stash.showPatch" { 'If this is set to true, the git stash show command without an option will show the stash entry in patch form' }
        "stash.showStat" { 'If this is set to true, the git stash show command without an option will show a diffstat of the stash entry' }
        "status.relativePaths" { 'If true, git-status shows paths relative to the current directory' }
        "status.short" { 'Set to true to enable --short by default in git-status' }
        "status.branch" { 'Set to true to enable --branch by default in git-status' }
        "status.aheadBehind" { 'Set to true to enable --ahead-behind and false to enable --no-ahead-behind by default in git-status for non-porcelain status formats' }
        "status.displayCommentPrefix" { 'If set to true, git-status will insert a comment prefix before each output line' }
        "status.renameLimit" { 'The number of files to consider when performing rename detection in git-status and git-commit' }
        "status.renames" { 'Whether and how Git detects renames in git-status and git-commit ' }
        "status.showStash" { 'If set to true, git-status will display the number of entries currently stashed away' }
        "status.showUntrackedFiles" { 'Whether to show files which are not currently tracked by Git' }
        "status.submoduleSummary" { 'If this is set to a non-zero number or true (identical to -1 or an unlimited number), the submodule summary will be enabled and a summary of commits for modified submodules will be shown' }

        "submodule.*.url" { 'The URL for a submodule' }
        "submodule.*.update" { 'The method by which a submodule is updated by git submodule update, which is the only affected command, others such as git checkout --recurse-submodules are unaffected' }
        "submodule.*.branch" { 'The remote branch name for a submodule, used by git submodule update --remote' }
        "submodule.*.fetchRecurseSubmodules" { 'This option can be used to control recursive fetching of this submodule' }
        "submodule.*.ignore" { 'Defines under what circumstances "git status" and the diff family show a submodule as modified' }
        "submodule.*.active" { 'Boolean value indicating if the submodule is of interest to git commands' }
        "submodule.active" { "A repeated field which contains a pathspec used to match against a submodule’s path to determine if the submodule is of interest to git commands" }
        "submodule.recurse" { 'A boolean indicating if commands should enable the --recurse-submodules option by default' }
        "submodule.propagateBranches" { 'A boolean that enables branching support when using --recurse-submodules or submodule.recurse=true' }
        "submodule.fetchJobs" { 'Specifies how many submodules are fetched/cloned at the same time' }
        "submodule.alternateLocation" { 'Specifies how the submodules obtain alternates when submodules are cloned' }
        "submodule.alternateErrorStrategy" { 'Specifies how to treat errors with the alternates for a submodule as computed via submodule.alternateLocation' }

        "tag.forceSignAnnotated" { 'Specify whether annotated tags created should be GPG signed' }
        "tag.sort" { 'Controls the sort ordering of tags when displayed by git-tag' }
        "tag.gpgSign" { 'Specify whether all tags should be GPG signed' }
        "tar.umask" { 'Restrict the permission bits of tar archive entries' }

        "trace2.normalTarget" { 'Controls the normal target destination' }
        "trace2.perfTarget" { 'Controls the performance target destination' }
        "trace2.eventTarget" { 'Controls the event target destination' }
        "trace2.normalBrief" { 'When true time, filename, and line fields are omitted from normal output' }
        "trace2.perfBrief" { 'When true time, filename, and line fields are omitted from PERF output' }
        "trace2.eventBrief" { 'When true time, filename, and line fields are omitted from event output' }
        "trace2.eventNesting" { 'Specifies desired depth of nested regions in the event output' }
        "trace2.configParams" { 'A comma-separated list of patterns of "important" config settings that should be recorded in the trace2 output' }
        "trace2.envVars" { 'A comma-separated list of "important" environment variables that should be recorded in the trace2 output' }
        "trace2.destinationDebug" { 'When true Git will print error messages when a trace target destination cannot be opened for writing' }
        "trace2.maxFiles" { 'When writing trace files to a target directory, do not write additional traces if doing so would exceed this many files' }
        "transfer.credentialsInUrl" { 'A configured URL can contain plaintext credentials in the form <protocol>://<user>:<password>@<domain>/<path>' }
        "transfer.fsckObjects" { 'The fetch or receive will abort in the case of a malformed object or a link to a nonexistent object' }
        "transfer.hideRefs" { 'String(s) receive-pack and upload-pack use to decide which refs to omit from their initial advertisements' }
        "transfer.unpackLimit" { 'When fetch.unpackLimit or receive.unpackLimit are not set, the value of this variable is used instead' }
        "transfer.advertiseSID" { 'When true, client and server processes will advertise their unique session IDs to their remote counterpart' }
        "transfer.bundleURI" { 'When true, local git clone commands will request bundle information from the remote server (if advertised) and download bundles before continuing the clone through the Git protocol' }
        "transfer.advertiseObjectInfo" { 'When true, the object-info capability is advertised by servers' }
        "uploadarchive.allowUnreachable" { 'If true, allow clients to use git archive --remote to request any tree, whether reachable from the ref tips or not' }
        "uploadpack.hideRefs" { 'This variable is the same as transfer.hideRefs, but applies only to upload-pack (and so affects only fetches, not pushes)' }
        "uploadpack.allowTipSHA1InWant" { 'When uploadpack.hideRefs is in effect, allow upload-pack to accept a fetch request that asks for an object at the tip of a hidden ref (by default, such a request is rejected)' }
        "uploadpack.allowReachableSHA1InWant" { 'Allow upload-pack to accept a fetch request that asks for an object that is reachable from any ref tip' }
        "uploadpack.allowAnySHA1InWant" { 'Allow upload-pack to accept a fetch request that asks for any object at all' }
        "uploadpack.keepAlive" { 'If true, upload-pack to send an empty keepalive packet every uploadpack.keepAlive seconds' }
        "uploadpack.packObjectsHook" { 'If this option is set, when upload-pack would run git pack-objects to create a packfile for a client, it will run this shell command instead' }
        "uploadpack.allowFilter" { "If this option is set, upload-pack will support partial clone and partial fetch object filtering" }

        "uploadpackfilter.allow" { 'Provides a default value for unspecified object filters' }
        "uploadpackfilter.*.allow" { 'Explicitly allow or ban the object filter' }

        "uploadpackfilter.tree.maxDepth" { 'Only allow --filter=tree:<n> when <n> is no more than the value of uploadpackfilter.tree.maxDepth' }
        "uploadpack.allowRefInWant" { 'If this option is set, upload-pack will support the ref-in-want feature of the protocol version 2 fetch command' }

        "url.*.insteadOf" { 'Any URL that starts with this value will be rewritten to start' }
        "url.*.pushInsteadOf" { 'Any URL that starts with this value will not be pushed to; the resulting URL will be pushed to' }

        "user.name" { 'Determine what ends up in the author and committer fields of commit objects' }
        "user.email" { 'Determine what ends up in the author and committer fields of commit objects' }
        "author.name" { 'Determine what ends up in the author fields of commit objects' }
        "author.email" { 'Determine what ends up in the author fields of commit objects' }
        "committer.name" { 'Determine what ends up in the committer fields of commit objects' }
        "committer.email" { 'Determine what ends up in the committer fields of commit objects' }
        
        "user.useConfigOnly" { 'Instruct Git to avoid trying to guess defaults for user.email and user.name, and instead retrieve the values only from the configuration' }
        "user.signingKey" { 'If git-tag or git-commit is not selecting the key you want it to automatically when creating a signed tag or commit, you can override the default selection with this variable' }

        "versionsort.suffix" { 'Even when version sort is used in git-tag, tagnames with the same base version but different suffixes are still sorted lexicographically, resulting e.g. in prerelease tags appearing after the main release' }

        "web.browser" { 'Specify a web browser that may be used by some commands. Currently only git-instaweb and git-help may use it' }

        "windows.appendAtomically" { "By default, append atomic API is used on windows. But it works only with local disk files, if you’re working on a network file system, you should set it false to turn it off" }
        "worktree.guessRemote" { 'If no branch is specified and neither -b nor -B nor --detach is used, then git worktree add defaults to creating a new branch from HEAD' }
        Default { $null }
    }
}

function Get-GitConfigShortOptionsGit2_45 {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param()

    @(
        [PSCustomObject]@{Short = '-e'; Long = '--edit'; }
        [PSCustomObject]@{Short = '-f'; Long = '--file'; }
        [PSCustomObject]@{Short = '-l'; Long = '--list'; }
        [PSCustomObject]@{Short = '-z'; Long = '--null'; }
    ) | ForEach-Object {
        $desc = (Get-GitConfigOptionsDescription $_.Long)
        if (-not $desc) {
            $desc = $_.Short
        }
        [CompletionResult]::new(
            $_.Short,
            $_.Short,
            'ParameterName',
            $desc
        )
    }
}