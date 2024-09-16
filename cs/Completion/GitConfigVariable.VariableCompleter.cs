// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion;

internal static partial class GitConfigVariable
{
    public static IEnumerable<CompletionResult> CompleteConfigVariableName(CompletionContext context, string current, string prefix = "", string suffix = "")
    {
        var (first, second, third) = Split3VarName(current);
        return new ConfigVariableCompleter(context, first, second, third, prefix, suffix).Complete();
    }

    readonly record struct ConfigVariableCompleter(
        CompletionContext Context,
        string First,
        string? Second,
        string? Third,
        string Prefix = "",
        string Suffix = "")
    {
        private bool StartsWithSecond(string candidate) => candidate.StartsWith(Second);
        private bool StartsWithThird(string candidate) => candidate.StartsWith(Third);
        private CompletionResult BuildSecond(string candidate)
        {
            var completion = $"{First}.{candidate}";
            return new(
                $"{Prefix}{completion}{Suffix}",
                completion,
                CompletionResultType.ParameterName,
                Description(First, candidate, null) ?? completion
            );
        }
        private CompletionResult BuildSecondAsMiddle(string candidate)
        {
            var completion = $"{First}.{candidate}.";
            return new(
                $"{Prefix}{completion}",
                completion,
                CompletionResultType.ParameterName,
                Description(First, candidate, null) ?? completion
            );
        }
        private CompletionResult BuildThird(string candidate)
        {
            var completion = $"{First}.{Second}.{candidate}";
            return new(
                $"{Prefix}{completion}{Suffix}",
                completion,
                CompletionResultType.ParameterName,
                Description(First, Second, candidate)
            );
        }

        private IEnumerable<CompletionResult> CompleteConfigSections()
        {
            foreach (var candidate in Context.GitConfigSections)
            {
                if (candidate.StartsWith(First))
                {
                    var completion = $"{candidate}.";
                    yield return new(
                        $"{Prefix}{completion}",
                        completion,
                        CompletionResultType.ParameterName,
                        Description(candidate, "", null) ?? completion
                    );
                }
            }
        }
        private IEnumerable<CompletionResult> CompleteConfigVars()
        {
            string current;
            if (Third == null)
                current = $"{First}.{Second}";
            else
                current = $"{First}.{Second}.{Third}";

            foreach (var candidate in Context.GitConfigVars)
            {
                if (candidate.StartsWith(current))
                {
                    string? d2, d3;
                    if (Third == null)
                    {
                        d2 = candidate.Substring(First.Length + 1);
                        d3 = null;
                    }
                    else
                    {
                        d2 = Second;
                        d3 = candidate.Substring(First.Length + Second!.Length + 2);
                    }

                    yield return new(
                        $"{Prefix}{candidate}{Suffix}",
                        candidate,
                        CompletionResultType.ParameterName,
                        Description(First, d2, d3) ?? candidate
                    );
                }
            }
        }

        public IEnumerable<CompletionResult> Complete()
        {
            return (First, Second, Third)
switch
            {
                ("branch" or "guitool" or "difftool" or "man" or "mergetool" or "remote" or "submodule" or "url", { }, { })
                => Context.SecondLevelGitConfigVarsForSection(First)
                                        .Where(StartsWithThird)
                                        .Select(BuildThird),
                ("branch", { }, null) => Enumerable.Concat(
                                        Context.GitHeads(Second)
                                            .Select(BuildSecondAsMiddle),
                                        Context.FirstLevelGitConfigVarsForSection(First)
                                            .Where(StartsWithSecond)
                                            .Select(BuildSecond)),
                ("pager", { }, null) => Context.GitAllCommands("main", "others", "alias", "nohelpers")
                                            .Where(StartsWithSecond)
                                            .Select(BuildSecond),
                ("remote", { }, null) => Enumerable.Concat(
                                        Context.GitRemote()
                                            .Select(BuildSecondAsMiddle),
                                        Context.FirstLevelGitConfigVarsForSection(First)
                                            .Where(StartsWithSecond)
                                            .Select(BuildSecond)),
                ("submodule", { }, null) => Enumerable.Concat(
                                        Context.GitSubmodules()
                                            .Select(BuildSecondAsMiddle),
                                        Context.FirstLevelGitConfigVarsForSection(First)
                                            .Where(StartsWithSecond)
                                            .Select(BuildSecond)),
                ({ }, { }, _) => CompleteConfigVars(),
                _ => CompleteConfigSections(),
            };
        }

        static string? Description(string first, string? second, string? third)
        {
            return (first, second, third) switch
            {
                ("add", "ignoreErrors", null) => @"Tells git add to continue adding files when some files cannot be added due to indexing errors",
                ("add", "interactive", "useBuiltin") => @"Unused configuration variable",

                ("advice", "", null) => @"These variables control various optional help messages designed to aid new users",
                ("advice", "addEmbeddedRepo", null) => @"Shown when the user accidentally adds one git repo inside of another",
                ("advice", "addEmptyPathspec", null) => @"Shown when the user runs git add without providing the pathspec parameter",
                ("advice", "addIgnoredFile", null) => @"Shown when the user attempts to add an ignored file to the index",
                ("advice", "amWorkDir", null) => @"Shown when git-am fails to apply a patch file, to tell the user the location of the file",
                ("advice", "ambiguousFetchRefspec", null) => @"Shown when a fetch refspec for multiple remotes maps to the same remote-tracking branch namespace and causes branch tracking set-up to fail",
                ("advice", "checkoutAmbiguousRemoteBranchName", null) => @"Shown when the argument to git-checkout and git-switch ambiguously resolves to a remote tracking branch on more than one remote in situations where an unambiguous argument would have otherwise caused a remote-tracking branch to be checked out. See the checkout.defaultRemote configuration variable for how to set a given remote to be used by default in some situations where this advice would be printed",
                ("advice", "commitBeforeMerge", null) => @"Shown when git-merge refuses to merge to avoid overwriting local changes",
                ("advice", "detachedHead", null) => @"Shown when the user uses git-switch or git-checkout to move to the detached HEAD state, to tell the user how to create a local branch after the fact",
                ("advice", "diverging", null) => @"Shown when a fast-forward is not possible",
                ("advice", "fetchShowForcedUpdates", null) => @"Shown when git-fetch takes a long time to calculate forced updates after ref updates, or to warn that the check is disabled",
                ("advice", "forceDeleteBranch", null) => @"Shown when the user tries to delete a not fully merged branch without the force option set",
                ("advice", "ignoredHook", null) => @"Shown when a hook is ignored because the hook is not set as executable",
                ("advice", "implicitIdentity", null) => @"Shown when the user’s information is guessed from the system username and domain name, to tell the user how to set their identity configuration",
                ("advice", "mergeConflict", null) => @"Shown when various commands stop because of conflicts",
                ("advice", "nameTooLong", null) => @"Advice shown if a filepath operation is attempted where the path was too long",
                ("advice", "nestedTag", null) => @"Shown when a user attempts to recursively tag a tag object",
                ("advice", "pushAlreadyExists", null) => @"Shown when git-push rejects an update that does not qualify for fast-forwarding (e.g., a tag.)",
                ("advice", "pushFetchFirst", null) => @"Shown when git-push rejects an update that tries to overwrite a remote ref that points at an object we do not have",
                ("advice", "pushNeedsForce", null) => @"Shown when git-push rejects an update that tries to overwrite a remote ref that points at an object that is not a commit-ish, or make the remote ref point at an object that is not a commit-ish",
                ("advice", "pushNonFFCurrent", null) => @"Shown when git-push fails due to a non-fast-forward update to the current branch",
                ("advice", "pushNonFFMatching", null) => @"Shown when the user ran git-push and pushed `""matching refs`"" explicitly (i.e. used :, or specified a refspec that isn’t the current branch) and it resulted in a non-fast-forward error",
                ("advice", "pushRefNeedsUpdate", null) => @"Shown when git-push rejects a forced update of a branch when its remote-tracking ref has updates that we do not have locally",
                ("advice", "pushUnqualifiedRefname", null) => @"Shown when git-push gives up trying to guess based on the source and destination refs what remote ref namespace the source belongs in, but where we can still suggest that the user push to either refs/heads/* or refs/tags/* based on the type of the source object",
                ("advice", "pushUpdateRejected", null) => @"Set this variable to false if you want to disable pushNonFFCurrent, pushNonFFMatching, pushAlreadyExists, pushFetchFirst, pushNeedsForce, and pushRefNeedsUpdate simultaneously",
                ("advice", "refSyntax", null) => @"Shown when the user provides an illegal ref name, to tell the user about the ref syntax documentation",
                ("advice", "resetNoRefresh", null) => @"Shown when git-reset takes more than 2 seconds to refresh the index after reset, to tell the user that they can use the --no-refresh option",
                ("advice", "resolveConflict", null) => @"Shown by various commands when conflicts prevent the operation from being performed",
                ("advice", "rmHints", null) => @"Shown on failure in the output of git-rm, to give directions on how to proceed from the current state",
                ("advice", "sequencerInUse", null) => @"Shown when a sequencer command is already in progress",
                ("advice", "skippedCherryPicks", null) => @"Shown when git-rebase skips a commit that has already been cherry-picked onto the upstream branch",
                ("advice", "statusAheadBehind", null) => @"Shown when git-status computes the ahead/behind counts for a local ref compared to its remote tracking ref, and that calculation takes longer than expected. Will not appear if status.aheadBehind is false or the option --no-ahead-behind is given",
                ("advice", "statusHints", null) => @"Show directions on how to proceed from the current state in the output of git-status, in the template shown when writing commit messages in git-commit, and in the help message shown by git-switch or git-checkout when switching branches",
                ("advice", "statusUoption", null) => @"Shown when git-status takes more than 2 seconds to enumerate untracked files, to tell the user that they can use the -u option",
                ("advice", "submoduleAlternateErrorStrategyDie", null) => @"Shown when a submodule.alternateErrorStrategy option configured to ""die"" causes a fatal error",
                ("advice", "submoduleMergeConflict", null) => @"Advice shown when a non-trivial submodule merge conflict is encountered",
                ("advice", "submodulesNotUpdated", null) => @"Shown when a user runs a submodule command that fails because git submodule update --init was not run",
                ("advice", "suggestDetachingHead", null) => @"Shown when git-switch refuses to detach HEAD without the explicit --detach option",
                ("advice", "updateSparsePath", null) => @"Shown when either git-add or git-rm is asked to update index entries outside the current sparse checkout",
                ("advice", "waitingForEditor", null) => @"Shown when Git is waiting for editor input. Relevant when e.g. the editor is not launched inside the terminal",
                ("advice", "worktreeAddOrphan", null) => @"Shown when the user tries to create a worktree from an invalid reference, to tell the user how to create a new unborn branch instead",
                ("advice", "useCoreFSMonitorConfig", null) => @"Advice shown if the deprecated core.useBuiltinFSMonitor config setting is in use",

                ("alias", "", null) => @"Command aliases for the git command wrapper",

                ("am", "keepcr", null) => @"If true, git-am will call git-mailsplit for patches in mbox format with parameter --keep-cr",
                ("am", "threeWay", null) => @"When set to true, this setting tells git am to fall back on 3-way merge if the patch records the identity of blobs it is supposed to apply to and we have those blobs available locally (equivalent to giving the --3way option from the command line)",

                ("apply", "ignoreWhitespace", null) => @"When set to change, tells git apply to ignore changes in whitespace, in the same way as the --ignore-space-change option",
                ("apply", "whitespace", null) => @"Tells git apply how to handle whitespace, in the same way as the --whitespace option",

                ("attr", "tree", null) => @"A reference to a tree in the repository from which to read attributes, instead of the .gitattributes file in the working tree",

                ("blame", "blankBoundary", null) => @"Show blank commit object name for boundary commits in git-blame",
                ("blame", "coloring", null) => @"This determines the coloring scheme to be applied to blame output",
                ("blame", "date", null) => @"Specifies the format used to output dates in git-blame",
                ("blame", "showEmail", null) => @"Show the author email instead of author name in git-blame",
                ("blame", "showRoot", null) => @"Do not treat root commits as boundaries in git-blame",
                ("blame", "ignoreRevsFile", null) => @"Ignore revisions listed in the file, one unabbreviated object name per line, in git-blame",
                ("blame", "markUnblamableLines", null) => @"Mark lines that were changed by an ignored revision that we could not attribute to another commit with a * in the output of git-blame",
                ("blame", "markIgnoredLines", null) => @"Mark lines that were changed by an ignored revision that we attributed to another commit with a ? in the output of git-blame",

                ("branch", "autoSetupMerge", null) => @"Tells git branch, git switch and git checkout to set up new branches so that git-pull will appropriately merge from the starting point branch",
                ("branch", "autoSetupRebase", null) => @"When a new branch is created with git branch, git switch or git checkout that tracks another branch, this variable tells Git to set up pull to rebase instead of merge",
                ("branch", "sort", null) => @"This variable controls the sort ordering of branches when displayed by git-branch",
                ("branch", _, "remote") => @$"When on branch <{second}>, it tells git fetch and git push which remote to fetch from or push to",
                ("branch", _, "pushRemote") => @$"When on branch <{second}>, it overrides branch.{second}.remote for pushing",
                ("branch", _, "merge") => @$"Defines, together with branch.{second}.remote, the upstream branch for the given branch",
                ("branch", _, "mergeOptions") => @$"Sets default options for merging into branch <{second}>",
                ("branch", _, "rebase") => @$"When true, rebase the branch <{second}> on top of the fetched branch, instead of merging the default branch from the default remote when `""git pull`"" is run",
                ("branch", _, "description") => @$"Branch description, can be edited with git branch --edit-description",

                ("browser", _, "cmd") => @"Specify the command to invoke the specified browser",
                ("browser", _, "path") => @"Override the path for the given tool that may be used to browse HTML help or a working repository in gitweb",

                ("bundle", "", null) => @"The bundle.* keys may appear in a bundle list file found via the git clone --bundle-uri option",
                ("bundle", "version", null) => @"This integer value advertises the version of the bundle list format used by the bundle list",
                ("bundle", "mode", null) => @"This string value should be either all or any",
                ("bundle", "heuristic", null) => @"If this string-valued key exists, then the bundle list is designed to work well with incremental git fetch commands",

                ("bundle", _, "uri") => @$"This string value defines the URI by which Git can reach the contents of this <{second}>",
                ("bundle", _, { }) => @$"The bundle.{second}.* keys are used to describe a single item in the bundle list, grouped under <{second}> for identification purposes",


                ("checkout", "defaultRemote", null) => @"When you run git checkout <something> or git switch <something> and only have one remote, it may implicitly fall back on checking out and tracking e.g. origin/<something>",
                ("checkout", "guess", null) => @"Provides the default value for the --guess or --no-guess option in git checkout and git switch",
                ("checkout", "workers", null) => @"The number of parallel workers to use when updating the working tree",
                ("checkout", "thresholdForParallelism", null) => @"When running parallel checkout with a small number of files, the cost of subprocess spawning and inter-process communication might outweigh the parallelization gains",

                ("clean", "requireForce", null) => @"A boolean to make git-clean refuse to delete files unless -f is given",

                ("clone", "defaultRemoteName", null) => @"The name of the remote to create when cloning a repository",
                ("clone", "filterSubmodules", null) => @"If a partial clone filter is provided and --recurse-submodules is used, also apply the filter to submodules",
                ("clone", "rejectShallow", null) => @"Reject cloning a repository if it is a shallow one",

                ("color", "advice", null) => @"A boolean to enable/disable color in hints",
                ("color", "advice", "hint") => @"Use customized color for hints",
                ("color", "blame", "highlightRecent") => @"Specify the line annotation color for git blame --color-by-age depending upon the age of the line",
                ("color", "blame", "repeatedLines") => @"Use the specified color to colorize line annotations for git blame --color-lines",
                ("color", "branch", null) => @"A boolean to enable/disable color in the output of git-branch",
                ("color", "diff", null) => @"Whether to use ANSI escape sequences to add color to patches",
                ("color", "branch", { }) => @"Use customized color for branch coloration",
                ("color", "diff", { }) => @"Use customized color for diff colorization",
                ("color", "decorate", { }) => @"Use customized color for git log --decorate output",


                // "color.grep" {.  }
                ("color", "grep", { }) => @"Use customized color for grep colorization",
                // "color.interactive" {.  }
                ("color", "interactive", { }) => @"Use customized color for git add --interactive and git clean --interactive output",
                ("color", "pager", null) => @"A boolean to specify whether auto color modes should colorize output going to the pager",
                ("color", "push", null) => @"A boolean to enable/disable color in push errors",
                ("color", "push", "error") => @"Use customized color for push errors",
                // "color.remote" {.  }
                ("color", "remote", { }) => @"Use customized color for each remote keyword",
                ("color", "showBranch", null) => @"A boolean to enable/disable color in the output of git-show-branch",
                ("color", "status", null) => @"A boolean to enable/disable color in the output of git-status",
                ("color", "status", { }) => @"Use customized color for status colorization",
                ("color", "transport", null) => @"A boolean to enable/disable color when pushes are rejected",
                ("color", "transport", "rejected") => @"Use customized color when a push was rejected",
                ("color", "ui", null) => @"This variable determines the default value for variables such as color.diff and color.grep that control the use of color per command family",

                ("column", "ui", null) => @"Specify whether supported commands should output in columns",
                ("column", "branch", null) => @"Specify whether to output branch listing in git branch in columns",
                ("column", "clean", null) => @"Specify the layout when listing items in git clean -i, which always shows files and directories in columns",
                ("column", "status", null) => @"Specify whether to output untracked files in git status in columns",
                ("column", "tag", null) => @"Specify whether to output tag listings in git tag in columns",

                ("commit", "cleanup", null) => @"This setting overrides the default of the --cleanup option in git commit",
                ("commit", "gpgSign", null) => @"A boolean to specify whether all commits should be GPG signed",
                ("commit", "status", null) => @"A boolean to enable/disable inclusion of status information in the commit message template when using an editor to prepare the commit message",
                ("commit", "template", null) => @"Specify the pathname of a file to use as the template for new commit messages",
                ("commit", "verbose", null) => @"A boolean or int to specify the level of verbosity with git commit",

                ("commitGraph", "generationVersion", null) => @"Specifies the type of generation number version to use when writing or reading the commit-graph file",
                ("commitGraph", "maxNewFilters", null) => @"Specifies the default value for the --max-new-filters option of git commit-graph write (c.f., git-commit-graph)",
                ("commitGraph", "readChangedPaths", null) => @"If true, then git will use the changed-path Bloom filters in the commit-graph file",

                ("completion", "commands", null) => @"This is only used by git-completion.bash to add or remove commands from the list of completed commands",

                ("core", "fileMode", null) => @"Tells Git if the executable bit of files in the working tree is to be honored",
                // "core.hideDotFiles" {.  }
                ("core", "ignoreCase", null) => @"Internal variable which enables various workarounds to enable Git to work better on filesystems that are not case sensitive, like APFS, HFS+, FAT, NTFS, etc",
                // "core.precomposeUnicode" .{ }
                ("core", "protectHFS", null) => @"If set to true, do not allow checkout of paths that would be considered equivalent to .git on an HFS+ filesystem",
                ("core", "protectNTFS", null) => @"If set to true, do not allow checkout of paths that would cause problems with the NTFS filesystem",
                ("core", "fsmonitor", null) => @"If set to true, enable the built-in file system monitor daemon for this working directory",
                ("core", "fsmonitorHookVersion", null) => @"Sets the protocol version to be used when invoking the ""fsmonitor"" hook",
                ("core", "trustctime", null) => @"If false, the ctime differences between the index and the working tree are ignored; useful when the inode change time is regularly modified by something outside Git (file system crawlers and some backup systems)",
                ("core", "splitIndex", null) => @"If true, the split-index feature of the index will be used",
                ("core", "untrackedCache", null) => @"Determines what to do about the untracked cache feature of the index",
                ("core", "checkStat", null) => @"When missing or is set to default, many fields in the stat structure are checked to detect if a file has been modified since Git looked at it",
                ("core", "quotePath", null) => @"Commands that output paths, will quote ""unusual"" characters in the pathname by enclosing the pathname in double-quotes and escaping those characters with backslashes in the same way C escapes control characters or bytes with values larger than 0x80 (e.g. octal \302\265 for ""micro"" in UTF-8)",
                ("core", "eol", null) => @"Sets the line ending type to use in the working directory for files that are marked as text",
                ("core", "safecrlf", null) => @"If true, makes Git check if converting CRLF is reversible when end-of-line conversion is active",
                ("core", "autocrlf", null) => @"Setting this variable to ""true"" is the same as setting the text attribute to ""auto"" on all files and core.eol to ""crlf""",
                ("core", "checkRoundtripEncoding", null) => @"A comma and/or whitespace separated list of encodings that Git performs UTF-8 round trip checks on if they are used in an working-tree-encoding attribute",
                ("core", "symlinks", null) => @"If false, symbolic links are checked out as small plain files that contain the link text",
                ("core", "gitProxy", null) => @"A ""proxy command"" to execute (as command host port) instead of establishing direct connection to the remote server when using the Git protocol for fetching",
                ("core", "sshCommand", null) => @"If this variable is set, git fetch and git push will use the specified command instead of ssh when they need to connect to a remote system",
                ("core", "ignoreStat", null) => @"If true, Git will avoid using lstat() calls to detect if files have changed by setting the ""assume-unchanged"" bit for those tracked files which it has updated identically in both the index and working tree",
                ("core", "preferSymlinkRefs", null) => @"Instead of the default ""symref"" format for HEAD and other symbolic reference files, use symbolic links",
                ("core", "alternateRefsCommand", null) => @"When advertising tips of available history from an alternate, use the shell to execute the specified command instead of git-for-each-ref",
                ("core", "alternateRefsPrefixes", null) => @"When listing references from an alternate, list only references that begin with the given prefix",
                ("core", "bare", null) => @"If true this repository is assumed to be bare and has no working directory associated with it",
                ("core", "worktree", null) => @"Set the path to the root of the working tree",
                ("core", "logAllRefUpdates", null) => @"Enable the reflog",
                ("core", "repositoryFormatVersion", null) => @"Internal variable identifying the repository format and layout version",
                ("core", "sharedRepository", null) => @"When group (or true), the repository is made shareable between several users in a group (making sure all the files and objects are group-writable)",
                ("core", "warnAmbiguousRefs", null) => @"If true, Git will warn you if the ref name you passed it is ambiguous and might match multiple refs in the repository",
                ("core", "compression", null) => @"An integer -1..9, indicating a default compression level",
                ("core", "looseCompression", null) => @"An integer -1..9, indicating the compression level for objects that are not in a pack file",
                ("core", "packedGitWindowSize", null) => @"Number of bytes of a pack file to map into memory in a single mapping operation",
                ("core", "packedGitLimit", null) => @"Maximum number of bytes to map simultaneously into memory from pack files",
                ("core", "deltaBaseCacheLimit", null) => @"Maximum number of bytes per thread to reserve for caching base objects that may be referenced by multiple deltified objects",
                ("core", "bigFileThreshold", null) => @"The size of files considered ""big"", which as discussed below changes the behavior of numerous git commands, as well as how such files are stored within the repository",
                ("core", "excludesFile", null) => @"Specifies the pathname to the file that contains patterns to describe paths that are not meant to be tracked",
                ("core", "askPass", null) => @"Some commands that interactively ask for a password can be told to use an external program given via the value of this variable",
                ("core", "attributesFile", null) => @"Git looks into this file for attributes",
                ("core", "hooksPath", null) => @"Git will try to find your hooks in that directory",
                ("core", "editor", null) => @"Commands such as commit and tag that let you edit messages by launching an editor use the value",
                ("core", "commentChar", null) => @"Commands such as commit and tag that let you edit messages consider a line that begins with this character commented, and removes them after the editor returns (default #)",
                ("core", "commentString", null) => @"Commands such as commit and tag that let you edit messages consider a line that begins with this character commented, and removes them after the editor returns (default #)",
                ("core", "filesRefLockTimeout", null) => @"The length of time, in milliseconds, to retry when trying to lock an individual reference",
                ("core", "packedRefsTimeout", null) => @"The length of time, in milliseconds, to retry when trying to lock the packed-refs file",
                ("core", "pager", null) => @"Text viewer for use by Git commands",
                ("core", "whitespace", null) => @"A comma separated list of common whitespace problems to notice",
                ("core", "fsync", null) => @"A comma-separated list of components of the repository that should be hardened via the core.fsyncMethod when created or modified",
                ("core", "fsyncMethod", null) => @"A value indicating the strategy Git will use to harden repository data using fsync and related primitives",
                ("core", "fsyncObjectFiles", null) => @"This boolean will enable fsync() when writing object files. This setting is deprecated. Use core.fsync instead",
                ("core", "preloadIndex", null) => @"Enable parallel index preload for operations like git diff",
                ("core", "fscache", null) => @"Enable additional caching of file system data for some operations",
                ("core", "longpaths", null) => @"Enable long path (> 260) support for builtin commands in Git for Windows",
                ("core", "unsetenvvars", null) => @"Windows-only: comma-separated list of environment variable''s names that need to be unset before spawning any other process",
                ("core", "restrictinheritedhandles", null) => @"Windows-only: override whether spawned processes inherit only standard file handles (stdin, stdout and stderr) or all handles",
                ("core", "createObject", null) => @"You can set this to link, in which case a hardlink followed by a delete of the source are used to make sure that object creation will not overwrite existing objects",
                ("core", "notesRef", null) => @"When showing commit messages, also show notes which are stored in the given ref",
                ("core", "commitGraph", null) => @"If true, then git will read the commit-graph file (if it exists) to parse the graph structure of commits",
                ("core", "useReplaceRefs", null) => @"If set to false, behave as if the --no-replace-objects option was given on the command line",
                ("core", "multiPackIndex", null) => @"Use the multi-pack-index file to track multiple packfiles using a single index",
                ("core", "sparseCheckout", null) => @"Enable ""sparse checkout"" feature",
                ("core", "sparseCheckoutCone", null) => @"Enables the ""cone mode"" of the sparse checkout feature",
                ("core", "abbrev", null) => @"Set the length object names are abbreviated to",
                ("core", "maxTreeDepth", null) => @"The maximum depth Git is willing to recurse while traversing a tree",
                ("core", "WSLCompat", null) => @"Tells Git whether to enable wsl compatibility mode",

                ("credential", "helper", null) => @"Specify an external helper to be called when a username or password credential is needed",
                ("credential", "useHttpPath", null) => @"When acquiring credentials, consider the ""path"" component of an http or https URL to be important",
                ("credential", "username", null) => @"If no username is set for a network authentication, use this username by default",
                // "credential.*.*" { }

                ("credentialCache", "ignoreSIGHUP", null) => @"Tell git-credential-cache—​daemon to ignore SIGHUP, instead of quitting",
                ("credentialStore", "lockTimeoutMS", null) => @"The length of time, in milliseconds, for git-credential-store to retry when trying to lock the credentials file",

                ("diff", "autoRefreshIndex", null) => @"When using git diff to compare with work tree files, do not consider stat-only changes as changed",
                ("diff", "dirstat", null) => @"A comma separated list of --dirstat parameters specifying the default behavior of the --dirstat option to git-diff and friends",
                ("diff", "statNameWidth", null) => @"Limit the width of the filename part in --stat output",
                ("diff", "statGraphWidth", null) => @"Limit the width of the graph part in --stat output",
                ("diff", "context", null) => @"Generate diffs with <n> lines of context instead of the default of 3",
                ("diff", "interHunkContext", null) => @"Show the context between diff hunks, up to the specified number of lines, thereby fusing the hunks that are close to each other",
                ("diff", "external", null) => @"Diff generation is not performed using the internal diff machinery, but using the given command",
                ("diff", "ignoreSubmodules", null) => @"Sets the default value of --ignore-submodules",
                ("diff", "mnemonicPrefix", null) => @"If set, git diff uses a prefix pair that is different from the standard ""a/"" and ""b/"" depending on what is being compared",
                ("diff", "noPrefix", null) => @"If set, git diff does not show any source or destination prefix",
                ("diff", "srcPrefix", null) => @"If set, git diff uses this source prefix",
                ("diff", "dstPrefix", null) => @"If set, git diff uses this destination prefix",
                ("diff", "relative", null) => @"If set to true, git diff does not show changes outside of the directory and show pathnames relative to the current directory",
                ("diff", "orderFile", null) => @"File indicating how to order files within a diff",
                ("diff", "renameLimit", null) => @"The number of files to consider in the exhaustive portion of copy/rename detection; equivalent to the git diff option -l",
                ("diff", "renames", null) => @"Whether and how Git detects renames",
                ("diff", "suppressBlankEmpty", null) => @"A boolean to inhibit the standard behavior of printing a space before each empty output line",
                ("diff", "submodule", null) => @"Specify the format in which differences in submodules are shown",
                ("diff", "wordRegex", null) => @"A POSIX Extended Regular Expression used to determine what is a ""word"" when performing word-by-word difference calculations",
                // "diff.*.*" { }
                ("diff", "indentHeuristic", null) => @"Set this option to false to disable the default heuristics that shift diff hunk boundaries to make patches easier to read",
                ("diff", "algorithm", null) => @"Choose a diff algorithm",
                ("diff", "wsErrorHighlight", null) => @"Highlight whitespace errors in the context, old or new lines of the diff",
                ("diff", "colorMoved", null) => @"If set to either a valid <mode> or a true value, moved lines in a diff are colored differently, for details of valid modes see --color-moved in git-diff",
                // "diff.colorMovedWS" {  }
                ("diff", "tool", null) => @"Controls which diff tool is used by git-difftool",
                ("diff", "guitool", null) => @"Controls which diff tool is used by git-difftool when the -g/--gui flag is specified",

                ("difftool", _, "cmd") => @"Specify the command to invoke the specified diff tool",
                ("difftool", _, "path") => @"Override the path for the given tool",
                ("difftool", "trustExitCode", null) => @"Exit difftool if the invoked diff tool returns a non-zero exit status",
                ("difftool", "prompt", null) => @"Prompt before each invocation of the diff tool",
                ("difftool", "guiDefault", null) => @"Set true to use the diff.guitool by default (equivalent to specifying the --gui argument), or auto to select diff.guitool or diff.tool depending on the presence of a DISPLAY environment variable value",

                ("extensions", "objectFormat", null) => @"Specify the hash algorithm to use",
                ("extensions", "compatObjectFormat", null) => @"Specify a compatitbility hash algorithm to use",
                ("extensions", "refStorage", null) => @"Specify the ref storage format to use",
                ("extensions", "worktreeConfig", null) => @"If enabled, then worktrees will load config settings from the $GIT_DIR/config.worktree file in addition to the $GIT_COMMON_DIR/config file",

                ("fastimport", "unpackLimit", null) => @"If the number of objects imported by git-fast-import is below this limit, then the objects will be unpacked into loose object files",

                ("feature", "", null) => @"These groups are created by the Git developer community as recommended defaults and are subject to change",
                ("feature", "experimental", null) => @"Enable config options that are new to Git, and are being considered for future defaults",
                ("feature", "manyFiles", null) => @"Enable config options that optimize for repos with many files in the working directory",

                ("fetch", "recurseSubmodules", null) => @"Controls whether git fetch (and the underlying fetch in git pull) will recursively fetch into populated submodules",
                ("fetch", "fsckObjects", null) => @"If it is set to true, git-fetch-pack will check all fetched objects",
                ("fetch", "fsck", { }) => $"Acts like fsck.{third}, but is used by git-fetch-pack instead of git-fsck",
                ("fetch", "unpackLimit", null) => @"If the number of objects fetched over the Git native transfer is below this limit, then the objects will be unpacked into loose object files",
                ("fetch", "prune", null) => @"If true, fetch will automatically behave as if the --prune option was given on the command line",
                ("fetch", "pruneTags", null) => @"If true, fetch will automatically behave as if the refs/tags/*:refs/tags/* refspec was provided when pruning, if not set already",
                ("fetch", "all", null) => @"If true, fetch will attempt to update all available remotes",
                ("fetch", "output", null) => @"Control how ref update status is printed",
                ("fetch", "negotiationAlgorithm", null) => @"Control how information about the commits in the local repository is sent when negotiating the contents of the packfile to be sent by the server",
                ("fetch", "showForcedUpdates", null) => @"Set to false to enable --no-show-forced-updates in git-fetch and git-pull commands",
                ("fetch", "parallel", null) => @"Specifies the maximal number of fetch operations to be run in parallel at a time",
                ("fetch", "writeCommitGraph", null) => @"Set to true to write a commit-graph after every git fetch command that downloads a pack-file from a remote",
                ("fetch", "bundleURI", null) => @"This value stores a URI for downloading Git object data from a bundle URI before performing an incremental fetch from the origin Git server",
                ("fetch", "bundleCreationToken", null) => @"When using fetch.bundleURI to fetch incrementally from a bundle list that uses the ""creationToken"" heuristic, this config value stores the maximum creationToken value of the downloaded bundles",

                ("filter", _, "clean") => @"The command which is used to convert the content of a worktree file to a blob upon checkin",
                ("filter", _, "smudge") => @"The command which is used to convert the content of a blob object to a worktree file upon checkout",

                ("format", "attach", null) => @"Enable multipart/mixed attachments as the default for format-patch",
                ("format", "from", null) => @"Provides the default value for the --from option to format-patch",
                ("format", "forceInBodyFrom", null) => @"Provides the default value for the --force-in-body-from option to format-patch",
                ("format", "numbered", null) => @"A boolean which can enable or disable sequence numbers in patch subjects",
                ("format", "headers", null) => @"Additional email headers to include in a patch to be submitted by mail",
                ("format", "to", null) => @"Additional recipients to include in a patch to be submitted by mail",
                ("format", "cc", null) => @"Additional recipients to include in a patch to be submitted by mail",
                ("format", "subjectPrefix", null) => @"The default for format-patch is to output files with the [PATCH] subject prefix",
                ("format", "coverFromDescription", null) => @"The default mode for format-patch to determine which parts of the cover letter will be populated using the branch’s description",
                ("format", "signature", null) => @"The default for format-patch is to output a signature containing the Git version number",
                ("format", "signatureFile", null) => @"Works just like format.signature except the contents of the file specified by this variable will be used as the signature",
                ("format", "suffix", null) => @"The default for format-patch is to output files with the suffix `.patch`",
                ("format", "encodeEmailHeaders", null) => @"Encode email headers that have non-ASCII characters with ""Q-encoding"" (described in RFC 2047) for email transmission",
                ("format", "pretty", null) => @"The default pretty format for log/show/whatchanged command",
                ("format", "thread", null) => @"The default threading style for git format-patch",
                ("format", "signOff", null) => @"A boolean value which lets you enable the -s/--signoff option of format-patch by default",
                ("format", "coverLetter", null) => @"A boolean that controls whether to generate a cover-letter when format-patch is invoked, but in addition can be set to ""auto"", to generate a cover-letter only when there’’s more than one patch",
                ("format", "outputDirectory", null) => @"Set a custom directory to store the resulting files instead of the current working directory",
                ("format", "filenameMaxLength", null) => @"The maximum length of the output filenames generated by the format-patch command; defaults to 64",
                ("format", "useAutoBase", null) => @"A boolean value which lets you enable the --base=auto option of format-patch by default",
                ("format", "notes", null) => @"Provides the default value for the --notes option to format-patch",
                ("format", "mboxrd", null) => @"A boolean value which enables the robust ""mboxrd"" format when --stdout is in use to escape ""^>+From "" lines",
                ("format", "noprefix", null) => @"If set, do not show any source or destination prefix in patches",

                ("fsck", "skipList", null) => @"The path to a list of object names that are known to be broken in a non-fatal way and should be ignored",
                ("fsck", { }, _) => @"This feature is intended to support working with legacy repositories containing such data",


                ("fsmonitor", "allowRemote", null) => @"If true, the fsmonitor daemon allow git to work with network-mounted repositories",
                ("fsmonitor", "socketDir", null) => @"This Mac OS-specific option, if set, specifies the directory in which to create the Unix domain socket used for communication between the fsmonitor daemon and various Git commands",
                ("gc", "aggressiveDepth", null) => @"The depth parameter used in the delta compression algorithm used by git gc --aggressive",
                ("gc", "aggressiveWindow", null) => @"The window size parameter used in the delta compression algorithm used by git gc --aggressive",
                ("gc", "auto", null) => @"When there are approximately more than this many loose objects in the repository, git gc --auto will pack them",
                ("gc", "autoPackLimit", null) => @"When there are more than this many packs that are not marked with *.keep file in the repository, git gc --auto consolidates them into one larger pack",
                ("gc", "autoDetach", null) => @"Make git gc --auto return immediately and run in the background if the system supports it",
                ("gc", "bigPackThreshold", null) => @"If non-zero, all non-cruft packs larger than this limit are kept when git gc is run",
                ("gc", "writeCommitGraph", null) => @"If true, then gc will rewrite the commit-graph file when git-gc is run",
                ("gc", "logExpiry", null) => @"If the file gc.log exists, then git gc --auto will print its content and exit with status zero instead of running unless that file is more than gc.logExpiry old",
                ("gc", "packRefs", null) => @"Running git pack-refs in a repository renders it unclonable by Git versions prior to 1.5.1.2 over dumb transports such as HTTP",
                ("gc", "cruftPacks", null) => @"Store unreachable objects in a cruft pack (see git-repack) instead of as loose objects",
                ("gc", "maxCruftSize", null) => @"Limit the size of new cruft packs when repacking",
                ("gc", "pruneExpire", null) => @"Override the grace period with this config variable",
                // "gc.reflogExpire" { }
                // "gc.*.reflogExpire" { }
                // "gc.reflogExpireUnreachable" {  }
                // "gc.*.reflogExpireUnreachable" {  }
                ("gc", "recentObjectsHook", null) => @"When considering whether or not to remove an object, use the shell to execute the specified command(s)",
                ("gc", "repackFilter", null) => @"When repacking, use the specified filter to move certain objects into a separate packfile",
                ("gc", "repackFilterTo", null) => @"When repacking and using a filter, see gc.repackFilter, the specified location will be used to create the packfile containing the filtered out objects",
                ("gc", "rerereResolved", null) => @"Records of conflicted merge you resolved earlier are kept for this many days when git rerere gc is run",
                ("gc", "rerereUnresolved", null) => @"Records of conflicted merge you have not resolved are kept for this many days when git rerere gc is run",

                ("gitcvs", "commitMsgAnnotation", null) => @"Append this string to each commit message",
                ("gitcvs", "enabled", null) => @"Whether the CVS server interface is enabled for this repository",
                ("gitcvs", "logFile", null) => @"Path to a log file where the CVS server interface well… logs various stuff",
                ("gitcvs", "usecrlfattr", null) => @"If true, the server will look up the end-of-line conversion attributes for files to determine the -k modes to use",
                ("gitcvs", "allBinary", null) => @"This is used if gitcvs.usecrlfattr does not resolve the correct -kb mode to use",
                ("gitcvs", "dbName", null) => @"Database used by git-cvsserver to cache revision information derived from the Git repository",
                ("gitcvs", "dbDriver", null) => @"Used Perl DBI driver",
                ("gitcvs", "dbUser", null) => @"Database user",
                ("gitcvs", "dbPass", null) => @"Database password",
                ("gitcvs", "dbTableNamePrefix", null) => @"Database table name prefix",

                // "gitweb.category" { }
                // "gitweb.description" { }
                // "gitweb.owner" { }
                // "gitweb.url" { }
                // "gitweb.avatar" { }
                // "gitweb.blame" { }
                // "gitweb.grep" { }
                // "gitweb.highlight" { }
                // "gitweb.patches" { }
                // "gitweb.pickaxe" { }
                // "gitweb.remote_heads" { }
                // "gitweb.showSizes" { }
                // "gitweb.snapshot" { }

                ("gpg", "program", null) => @"Use this custom program instead of ""gpg"" found on $PATH when making or verifying a PGP signature",
                ("gpg", "format", null) => @"Specifies which key format to use when signing with --gpg-sign",
                ("gpg", _, "program") => @"Use this to customize the program used for the signing format you chose",
                ("gpg", "minTrustLevel", null) => @"Specifies a minimum trust level for signature verification",
                ("gpg", "ssh", "defaultKeyCommand") => @"This command will be run when user.signingkey is not set and a ssh signature is requested",
                ("gpg", "ssh", "allowedSignersFile") => @"A file containing ssh public keys which you are willing to trust",
                ("gpg", "ssh", "revocationFile") => @"Either a SSH KRL or a list of revoked public keys",

                ("grep", "lineNumber", null) => @"If set to true, enable -n option by default",
                ("grep", "column", null) => @"If set to true, enable the --column option by default",
                ("grep", "patternType", null) => @"Set the default matching behavior",
                ("grep", "extendedRegexp", null) => @"If set to true, enable --extended-regexp option by default",
                ("grep", "threads", null) => @"Number of grep worker threads to use",
                ("grep", "fullName", null) => @"If set to true, enable --full-name option by default",
                ("grep", "fallbackToNoIndex", null) => @"If set to true, fall back to git grep --no-index if git grep is executed outside of a git repository",

                ("gui", "commitMsgWidth", null) => @"Defines how wide the commit message window is in the git-gui",
                ("gui", "diffContext", null) => @"Specifies how many context lines should be used in calls to diff made by the git-gui",
                ("gui", "displayUntracked", null) => @"Determines if git-gui shows untracked files in the file list",
                ("gui", "encoding", null) => @"Specifies the default character encoding to use for displaying of file contents in git-gui and gitk",
                ("gui", "matchTrackingBranch", null) => @"Determines if new branches created with git-gui should default to tracking remote branches with matching names or not",
                ("gui", "newBranchTemplate", null) => @"Is used as a suggested name when creating new branches using the git-gui",
                ("gui", "pruneDuringFetch", null) => @"""true"" if git-gui should prune remote-tracking branches when performing a fetch",
                ("gui", "trustmtime", null) => @"Determines if git-gui should trust the file modification timestamp or not",
                ("gui", "spellingDictionary", null) => @"Specifies the dictionary used for spell checking commit messages in the git-gui",
                ("gui", "fastCopyBlame", null) => @"If true, git gui blame uses -C instead of -C -C for original location detection",
                ("gui", "copyBlameThreshold", null) => @"Specifies the threshold to use in git gui blame original location detection, measured in alphanumeric characters",
                ("gui", "blamehistoryctx", null) => @"Specifies the radius of history context in days to show in gitk for the selected commit, when the Show History Context menu item is invoked from git gui blame",

                ("guitool", _, "cmd") => @"Specifies the shell command line to execute when the corresponding item of the git-gui Tools menu is invoked",
                ("guitool", _, "needsFile") => @"Run the tool only if a diff is selected in the GUI",
                ("guitool", _, "noConsole") => @"Run the command silently, without creating a window to display its output",
                ("guitool", _, "noRescan") => @"Don’t rescan the working directory for changes after the tool finishes execution",
                ("guitool", _, "confirm") => @"Show a confirmation dialog before actually running the tool",
                ("guitool", _, "argPrompt") => @"Request a string argument from the user, and pass it to the tool through the ARGS environment variable",
                ("guitool", _, "revPrompt") => @"Request a single valid revision from the user, and set the REVISION environment variable",
                ("guitool", _, "revUnmerged") => @"Show only unmerged branches in the revPrompt subdialog",
                ("guitool", _, "title") => @"Specifies the title to use for the prompt dialog",
                ("guitool", _, "prompt") => @"Specifies the general prompt string to display at the top of the dialog, before subsections for argPrompt and revPrompt",

                ("help", "browser", null) => @"Specify the browser that will be used to display help in the web format",
                ("help", "format", null) => @"Override the default help format used by git-help",
                ("help", "autoCorrect", null) => @"If git detects typos and can identify exactly one valid command similar to the error, git will try to suggest the correct command or even run the suggestion automatically",
                ("help", "htmlPath", null) => @"Specify the path where the HTML documentation resides",

                ("http", "proxy", null) => @"Override the HTTP proxy",
                ("http", "proxyAuthMethod", null) => @"Set the method with which to authenticate against the HTTP proxy",
                ("http", "proxySSLCert", null) => @"The pathname of a file that stores a client certificate to use to authenticate with an HTTPS proxy",
                ("http", "proxySSLKey", null) => @"The pathname of a file that stores a private key to use to authenticate with an HTTPS proxy",
                ("http", "proxySSLCertPasswordProtected", null) => @"Enable Git’s password prompt for the proxy SSL certificate",
                ("http", "proxySSLCAInfo", null) => @"Pathname to the file containing the certificate bundle that should be used to verify the proxy with when using an HTTPS proxy",
                ("http", "emptyAuth", null) => @"Attempt authentication without seeking a username or password",
                ("http", "delegation", null) => @"Control GSSAPI credential delegation",
                ("http", "extraHeader", null) => @"Pass an additional HTTP header when communicating with a server",
                ("http", "cookieFile", null) => @"The pathname of a file containing previously stored cookie lines, which should be used in the Git http session, if they match the server",
                ("http", "saveCookies", null) => @"If set, store cookies received during requests to the file specified by http.cookieFile",
                ("http", "version", null) => @"Use the specified HTTP protocol version when communicating with a server",
                ("http", "curloptResolve", null) => @"Hostname resolution information that will be used first by libcurl when sending HTTP requests",
                ("http", "sslVersion", null) => @"The SSL version to use when negotiating an SSL connection",
                ("http", "sslCipherList", null) => @"A list of SSL ciphers to use when negotiating an SSL connection",
                ("http", "sslVerify", null) => @"Whether to verify the SSL certificate when fetching or pushing over HTTPS",
                ("http", "sslCert", null) => @"File containing the SSL certificate when fetching or pushing over HTTPS",
                ("http", "sslKey", null) => @"File containing the SSL private key when fetching or pushing over HTTPS",
                ("http", "sslCertPasswordProtected", null) => @"Enable Git’s password prompt for the SSL certificate",
                ("http", "sslCAInfo", null) => @"File containing the certificates to verify the peer with when fetching or pushing over HTTPS",
                ("http", "sslCAPath", null) => @"Path containing files with the CA certificates to verify the peer with when fetching or pushing over HTTPS",
                ("http", "sslBackend", null) => @"Name of the SSL backend to use",
                ("http", "schannelCheckRevoke", null) => @"Used to enforce or disable certificate revocation checks in cURL when http.sslBackend is set to ""schannel"" via ""true"" and ""false"", respectively",
                ("http", "schannelUseSSLCAInfo", null) => @"As of cURL v7.60.0, the Secure Channel backend can use the certificate bundle provided via http.sslCAInfo, but that would override the Windows Certificate Store",
                ("http", "sslAutoClientCert", null) => @"As of cURL v7.77.0, the Secure Channel backend won’t automatically send client certificates from the Windows Certificate Store anymore",
                ("http", "pinnedPubkey", null) => @"Public key of the https service",
                ("http", "sslTry", null) => @"Attempt to use AUTH SSL/TLS and encrypted data transfers when connecting via regular FTP protocol",
                ("http", "maxRequests", null) => @"How many HTTP requests to launch in parallel",
                ("http", "minSessions", null) => @"The number of curl sessions (counted across slots) to be kept across requests",
                ("http", "postBuffer", null) => @"Maximum size in bytes of the buffer used by smart HTTP transports when POSTing data to the remote system",
                ("http", "lowSpeedLimit, http", "lowSpeedTime") => @"If the HTTP transfer speed, in bytes per second, is less than http.lowSpeedLimit for longer than http.lowSpeedTime seconds, the transfer is aborted",
                ("http", "noEPSV", null) => @"A boolean which disables using of EPSV ftp command by curl",
                ("http", "userAgent", null) => @"The HTTP USER_AGENT string presented to an HTTP server",
                ("http", "followRedirects", null) => @"Whether git should follow HTTP redirects",
                // "http.*.*" { }

                ("i18n", "commitEncoding", null) => @"Character encoding the commit messages are stored in",
                ("i18n", "logOutputEncoding", null) => @"Character encoding the commit messages are converted to when running git log and friends",

                ("imap", "folder", null) => @"The folder to drop the mails into, which is typically the Drafts folder",
                ("imap", "tunnel", null) => @"Command used to set up a tunnel to the IMAP server through which commands will be piped instead of using a direct network connection to the server",
                ("imap", "host", null) => @"A URL identifying the server",
                ("imap", "user", null) => @"The username to use when logging in to the server",
                ("imap", "pass", null) => @"The password to use when logging in to the server",
                ("imap", "port", null) => @"An integer port number to connect to on the server",
                ("imap", "sslverify", null) => @"A boolean to enable/disable verification of the server certificate used by the SSL/TLS connection",
                ("imap", "preformattedHTML", null) => @"A boolean to enable/disable the use of html encoding when sending a patch",
                ("imap", "authMethod", null) => @"Specify the authentication method for authenticating with the IMAP server",

                ("include", "path", null) => @"Special variables to include other configuration files",
                ("include", _, "path") => @"Special variables to include other configuration files",

                ("index", "recordEndOfIndexEntries", null) => @"Specifies whether the index file should include an ""End Of Index Entry"" section.",
                ("index", "recordOffsetTable", null) => @"Specifies whether the index file should include an ""Index Entry Offset Table"" section.",
                ("index", "sparse", null) => @"When enabled, write the index using sparse-directory entries.",
                ("index", "threads", null) => @"Specifies the number of threads to spawn when loading the index.",
                ("index", "version", null) => @"Specify the version with which new index files should be initialized.",
                ("index", "skipHash", null) => @"When enabled, do not compute the trailing hash for the index file.",

                ("init", "templateDir", null) => @"Specify the directory from which templates will be copied.",
                ("init", "defaultBranch", null) => @"Allows overriding the default branch name.",

                ("instaweb", "browser", null) => @"Specify the program that will be used to browse your working repository in gitweb.",
                ("instaweb", "httpd", null) => @"The HTTP daemon command-line to start gitweb on your working repository.",
                ("instaweb", "local", null) => @"If true the web server started by git-instaweb will be bound to the local IP (127.0.0.1)",
                ("instaweb", "modulePath", null) => @"The default module path for git-instaweb to use instead of /usr/lib/apache2/modules.",
                ("instaweb", "port", null) => @"The port number to bind the gitweb httpd to.",

                ("interactive", "singleKey", null) => @"In interactive commands, allow the user to provide one-letter input with a single key (i.e., without hitting enter).",
                ("interactive", "diffFilter", null) => @"When an interactive command shows a colorized diff, git will pipe the diff through the shell command defined by this configuration variable.",

                ("log", "abbrevCommit", null) => @"If true, makes git-log, git-show, and git-whatchanged assume --abbrev-commit.",
                ("log", "date", null) => @"Set the default date-time mode for the log command.",
                ("log", "decorate", null) => @"Print out the ref names of any commits that are shown by the log command.",
                ("log", "initialDecorationSet", null) => @"If all is specified, then show all refs as decorations.",
                ("log", "excludeDecoration", null) => @"Exclude the specified patterns from the log decorations.",
                ("log", "diffMerges", null) => @"Set diff format to be used when --diff-merges=on is specified, see --diff-merges in git-log for details.",
                ("log", "follow", null) => @"If true, git log will act as if the --follow option was used when a single <path> is given.",
                ("log", "graphColors", null) => @"A list of colors, separated by commas, that can be used to draw history lines in git log --graph",
                ("log", "showRoot", null) => @"If true, the initial commit will be shown as a big creation event",
                ("log", "showSignature", null) => @"If true, makes git-log, git-show, and git-whatchanged assume --show-signature",
                ("log", "mailmap", null) => @"If true, makes git-log, git-show, and git-whatchanged assume --use-mailmap, otherwise assume --no-use-mailmap",

                ("lsrefs", "unborn", null) => @"May be ""advertise"" (the default), ""allow"", or ""ignore""",

                ("mailinfo", "scissors", null) => @"If true, makes git-mailinfo (and therefore git-am) act by default as if the --scissors option was provided on the command-line",
                ("mailmap", "file", null) => @"The location of an augmenting mailmap file",
                ("mailmap", "blob", null) => @"Like mailmap.file, but consider the value as a reference to a blob in the repository",
                ("maintenance", "auto", null) => @"This boolean config option controls whether some commands run git maintenance run --auto after doing their normal work",
                ("maintenance", "strategy", null) => @"This string config option provides a way to specify one of a few recommended schedules for background maintenance",
                ("maintenance", _, "enabled") => @"Whether the maintenance task is run when no --task option is specified to git maintenance run",
                ("maintenance", _, "schedule") => @"Whether or not the given runs during a git maintenance run --schedule=<frequency> command",
                ("maintenance", "commit-graph", "auto") => @"This integer config option controls how often the commit-graph task should be run as part of git maintenance run --auto",
                ("maintenance", "loose-objects", "auto") => @"This integer config option controls how often the loose-objects task should be run as part of git maintenance run --auto",
                ("maintenance", "incremental-repack", "auto") => @"This integer config option controls how often the incremental-repack task should be run as part of git maintenance run --auto",

                ("man", "viewer", null) => @"Specify the programs that may be used to display help in the man format",
                ("man", _, "cmd") => @"Specify the command to invoke the specified man viewer",
                ("man", _, "path") => @"Override the path for the given tool that may be used to display help in the man format",

                ("merge", "conflictStyle", null) => @"Specify the style in which conflicted hunks are written out to working tree files upon merge",
                ("merge", "defaultToUpstream", null) => @"If merge is called without any commit argument, merge the upstream branches configured for the current branch by using their last observed values stored in their remote-tracking branches",
                ("merge", "ff", null) => @"When set to false, this variable tells Git to create an extra merge commit in such a case",
                ("merge", "verifySignatures", null) => @"If true, this is equivalent to the --verify-signatures command line option",
                ("merge", "branchdesc", null) => @"In addition to branch names, populate the log message with the branch description text associated with them",
                ("merge", "log", null) => @"In addition to branch names, populate the log message with at most the specified number of one-line descriptions from the actual commits that are being merged",
                ("merge", "suppressDest", null) => @"The default merge message computed for merges into these integration branches will omit ""into<branch name>"" from its title",
                ("merge", "renameLimit", null) => @"The number of files to consider in the exhaustive portion of rename detection during a merge",
                ("merge", "renames", null) => @"Whether Git detects renames",
                ("merge", "directoryRenames", null) => @"Whether Git detects directory renames, affecting what happens at merge time to new files added to a directory on one side of history when that directory was renamed on the other side of history",
                ("merge", "renormalize", null) => @"Tell Git that canonical representation of files in the repository has changed over time",
                ("merge", "stat", null) => @"Whether to print the diffstat between ORIG_HEAD and the merge result at the end of the merge",
                ("merge", "autoStash", null) => @"When set to true, automatically create a temporary stash entry before the operation begins, and apply it after the operation ends",
                ("merge", "tool", null) => @"Controls which merge tool is used by git-mergetool",
                ("merge", "guitool", null) => @"Controls which merge tool is used by git-mergetool when the -g/--gui flag is specified",
                ("merge", "verbosity", null) => @"Controls the amount of output shown by the recursive merge strategy",
                ("merge", _, "name") => @"Defines a human-readable name for a custom low-level merge driver",
                ("merge", _, "driver") => @"Defines the command that implements a custom low-level merge driver",
                ("merge", _, "recursive") => @"Names a low-level merge driver to be used when performing an internal merge between common ancestors",
                ("mergetool", _, "path") => @"Override the path for the given tool",
                ("mergetool", _, "cmd") => @"Specify the command to invoke the specified merge tool",
                ("mergetool", _, "hideResolved") => @"Allows the user to override the global mergetool.hideResolved value for a specific tool",
                ("mergetool", _, "trustExitCode") => @"For a custom merge command, specify whether the exit code of the merge command can be used to determine whether the merge was successful",
                ("mergetool", "meld", "hasOutput") => @"Setting mergetool.meld.hasOutput to true tells Git to unconditionally use the --output option, and false avoids using --output",
                ("mergetool", "meld", "useAutoMerge") => @"When the --auto-merge is given, meld will merge all non-conflicting parts automatically, highlight the conflicting parts, and wait for user decision",
                ("mergetool", _, "layout") => @"Configure the split window layout for vimdiff’s <variant>, which is any of vimdiff, nvimdiff, gvimdiff",
                ("mergetool", "hideResolved", null) => @"During a merge, Git will automatically resolve as many conflicts as possible and write the MERGED file containing conflict markers around any conflicts that it cannot resolve; LOCAL and REMOTE normally represent the versions of the file from before Git’s conflict resolution",
                ("mergetool", "keepBackup", null) => @"After performing a merge, the original file with conflict markers can be saved as a file with a .orig extension",
                ("mergetool", "keepTemporaries", null) => @"When invoking a custom merge tool, Git uses a set of temporary files to pass to the tool",
                ("mergetool", "writeToTemp", null) => @"Git writes temporary BASE, LOCAL, and REMOTE versions of conflicting files in the worktree by default",
                ("mergetool", "prompt", null) => @"Prompt before each invocation of the merge resolution program",
                ("mergetool", "guiDefault", null) => @"Set true to use the merge.guitool by default, or auto to select merge.guitool or merge.tool depending on the presence of a DISPLAY environment variable value",

                ("notes", "mergeStrategy", null) => @"Which merge strategy to choose by default when resolving notes conflicts",
                ("notes", _, "mergeStrategy") => @"Which merge strategy to choose when doing a notes merge into refs/notes/<name>",
                ("notes", "displayRef", null) => @"Which ref (or refs, if a glob or specified more than once), in addition to the default set by core.notesRef or GIT_NOTES_REF, to read notes from when showing commit messages with the git log family of commands",
                ("notes", "rewrite", { }) => @"When rewriting commits with <command>, if this variable is false, git will not copy notes from the original to the rewritten commit",
                ("notes", "rewriteMode", null) => @"When copying notes during a rewrite, determines what to do if the target commit already has a note",
                ("notes", "rewriteRef", null) => @"When copying notes during a rewrite, specifies the (fully qualified) ref whose notes should be copied",
                ("pack", "window", null) => @"The size of the window used by git-pack-objects when no window size is given on the command line",
                ("pack", "depth", null) => @"The maximum delta depth used by git-pack-objects when no maximum depth is given on the command line",
                ("pack", "windowMemory", null) => @"The maximum size of memory that is consumed by each thread in git-pack-objects for pack window memory when no limit is given on the command line",
                ("pack", "compression", null) => @"An integer -1..9, indicating the compression level for objects in a pack file",
                ("pack", "allowPackReuse", null) => @"When true or ""single"", and when reachability bitmaps are enabled, pack-objects will try to send parts of the bitmapped packfile verbatim",
                ("pack", "island", null) => @"An extended regular expression configuring a set of delta islands",
                ("pack", "islandCore", null) => @"Specify an island name which gets to have its objects be packed first",
                ("pack", "deltaCacheSize", null) => @"The maximum memory in bytes used for caching deltas in git-pack-objects before writing them out to a pack",
                ("pack", "deltaCacheLimit", null) => @"The maximum size of a delta, that is cached in git-pack-objects",
                ("pack", "threads", null) => @"Specifies the number of threads to spawn when searching for best delta matches",
                ("pack", "indexVersion", null) => @"Specify the default pack index version",
                ("pack", "packSizeLimit", null) => @"The maximum size of a pack",
                ("pack", "useBitmaps", null) => @"When true, git will use pack bitmaps (if available) when packing to stdout (e.g., during the server side of a fetch)",
                ("pack", "useBitmapBoundaryTraversal", null) => @"When true, Git will use an experimental algorithm for computing reachability queries with bitmaps",
                ("pack", "useSparse", null) => @"When true, git will default to using the --sparse option in git pack-objects when the --revs option is present",
                ("pack", "preferBitmapTips", null) => @"When selecting which commits will receive bitmaps, prefer a commit at the tip of any reference that is a suffix of any value of this configuration over any other commits in the ""selection window""",
                ("pack", "writeBitmapHashCache", null) => @"When true, git will include a ""hash cache"" section in the bitmap index (if one is written)",
                ("pack", "writeBitmapLookupTable", null) => @"When true, Git will include a ""lookup table"" section in the bitmap index (if one is written)",
                ("pack", "readReverseIndex", null) => @"When true, git will read any .rev file(s) that may be available",
                ("pack", "writeReverseIndex", null) => @"When true, git will write a corresponding .rev file for each new packfile that it writes in all places except for git-fast-import and in the bulk checkin mechanism",

                ("pager", _, null) => $"Turns on or off pagination of the output of a particular Git subcommand {(second == "" ? "" : $"<{second}> ")}when writing to a tty",

                ("pretty", _, null) => @"Alias for a --pretty= format string, as specified in git-log",

                ("protocol", "allow", null) => @"If set, provide a user defined default policy for all protocols which don’t explicitly have a policy (protocol.<name>.allow)",

                ("protocol", _, "allow") => @"Set a policy to be used by protocol <name> with clone/fetch/push commands",
                ("protocol", "version", null) => @"If set, clients will attempt to communicate with a server using the specified protocol version",

                ("pull", "ff", null) => @"When set to false, this variable tells Git to create an extra merge commit in such a case",
                ("pull", "rebase", null) => @"When true, rebase branches on top of the fetched branch, instead of merging the default branch from the default remote when ""git pull"" is run",
                ("pull", "octopus", null) => @"The default merge strategy to use when pulling multiple branches at once",
                ("pull", "twohead", null) => @"The default merge strategy to use when pulling a single branch",
                ("push", "autoSetupRemote", null) => @"If set to ""true"" assume --set-upstream on default push when no upstream tracking exists for the current branch; this option takes effect with push.default options simple, upstream, and current",
                ("push", "default", null) => @"Defines the action git push should take if no refspec is given",
                ("push", "followTags", null) => @"If set to true, enable --follow-tags option by default",
                ("push", "gpgSign", null) => @"A true value causes all pushes to be GPG signed, as if --signed is passed to git-push",
                ("push", "pushOption", null) => @"When no --push-option=<option> argument is given from the command line, git push behaves as if each <value> of this variable is given as --push-option=<value>",
                ("push", "recurseSubmodules", null) => @"May be ""check"", ""on-demand"", ""only"", or ""no"", with the same behavior as that of ""push --recurse-submodules""",
                ("push", "useForceIfIncludes", null) => @"If set to ""true"", it is equivalent to specifying --force-if-includes as an option to git-push in the command line",
                ("push", "negotiate", null) => @"If set to ""true"", attempt to reduce the size of the packfile sent by rounds of negotiation in which the client and the server attempt to find commits in common",
                ("push", "useBitmaps", null) => @"If set to ""false"", disable use of bitmaps for ""git push"" even if pack.useBitmaps is ""true"", without preventing other git operations from using bitmaps",

                ("rebase", "backend", null) => @"Default backend to use for rebasing",
                ("rebase", "stat", null) => @"Whether to show a diffstat of what changed upstream since the last rebase",
                ("rebase", "autoSquash", null) => @"If set to true, enable the --autosquash option of git-rebase by default for interactive mode",
                ("rebase", "autoStash", null) => @"When set to true, automatically create a temporary stash entry before the operation begins, and apply it after the operation ends",
                ("rebase", "updateRefs", null) => @"If set to true enable --update-refs option by default",
                ("rebase", "missingCommitsCheck", null) => @"If set to ""warn"", git rebase -i will print a warning if some commits are removed",
                ("rebase", "instructionFormat", null) => @"A format string, as specified in git-log, to be used for the todo list during an interactive rebase",
                ("rebase", "abbreviateCommands", null) => @"If set to true, git rebase will use abbreviated command names in the todo list resulting",
                ("rebase", "rescheduleFailedExec", null) => @"Automatically reschedule exec commands that failed",
                ("rebase", "forkPoint", null) => @"If set to false set --no-fork-point option by default",
                ("rebase", "rebaseMerges", null) => @"Whether and how to set the --rebase-merges option by default",
                ("rebase", "maxLabelLength", null) => @"When generating label names from commit subjects, truncate the names to this length",

                ("receive", "advertiseAtomic", null) => @"If true, git-receive-pack will advertise the atomic push capability to its clients",
                ("receive", "advertisePushOptions", null) => @"When set to true, git-receive-pack will advertise the push options capability to its clients",
                ("receive", "autogc", null) => @"If true, git-receive-pack will run ""git maintenance run --auto"" after receiving data from git-push and updating refs",
                ("receive", "certNonceSeed", null) => @"By setting this variable to a string, git receive-pack will accept a git push --signed and verify it by using a ""nonce"" protected by HMAC using this string as a secret key",
                ("receive", "certNonceSlop", null) => @"When a git push --signed sends a push certificate with a ""nonce"" that was issued by a receive-pack serving the same repository within this many seconds, export the ""nonce"" found in the certificate to GIT_PUSH_CERT_NONCE to the hooks",
                ("receive", "fsckObjects", null) => @"If it is set to true, git-receive-pack will check all received objects",
                ("receive", "fsck", "skipList") => @"Acts like fsck.skipList, but is used by git-receive-pack instead of git-fsck",

                ("receive", "fsck", { }) => @"Acts like fsck.*, but is used by git-receive-pack instead of git-fsck",
                ("receive", "keepAlive", null) => @"After receiving the pack from the client, receive-pack may produce no output (if --quiet was specified) while processing the pack, causing some networks to drop the TCP connection",
                ("receive", "unpackLimit", null) => @"If the number of objects received in a push is below this limit then the objects will be unpacked into loose object files",
                ("receive", "maxInputSize", null) => @"If the size of the incoming pack stream is larger than this limit, then git-receive-pack will error out, instead of accepting the pack file",
                ("receive", "denyDeletes", null) => @"If set to true, git-receive-pack will deny a ref update that deletes the ref",
                ("receive", "denyDeleteCurrent", null) => @"If set to true, git-receive-pack will deny a ref update that deletes the currently checked out branch of a non-bare repository",
                ("receive", "denyCurrentBranch", null) => @"If set to true or ""refuse"", git-receive-pack will deny a ref update to the currently checked out branch of a non-bare repository",
                ("receive", "denyNonFastForwards", null) => @"If set to true, git-receive-pack will deny a ref update which is not a fast-forward",
                ("receive", "hideRefs", null) => @"This variable is the same as transfer.hideRefs, but applies only to receive-pack",
                ("receive", "procReceiveRefs", null) => @"This is a multi-valued variable that defines reference prefixes to match the commands in receive-pack",
                ("receive", "updateServerInfo", null) => @"If set to true, git-receive-pack will run git-update-server-info after receiving data from git-push and updating refs",
                ("receive", "shallowUpdate", null) => @"If set to true, .git/shallow can be updated when new refs require new shallow roots",
                ("remote", "pushDefault", null) => @"The remote to push to by default",
                ("remote", "<name>", "url") => @"The URL of a remote repository",
                ("remote", _, "pushurl") => @"The push URL of a remote repository",
                ("remote", _, "proxy") => @"For remotes that require curl (http, https and ftp), the URL to the proxy to use for that remote",
                ("remote", _, "proxyAuthMethod") => @"For remotes that require curl (http, https and ftp), the method to use for authenticating against the proxy in use (probably set in remote.<name>.proxy)",
                ("remote", _, "fetch") => @"The default set of ""refspec"" for git-fetch",
                ("remote", _, "push") => @"The default set of ""refspec"" for git-push",
                ("remote", _, "mirror") => @"If true, pushing to this remote will automatically behave as if the --mirror option was given on the command line",
                ("remote", _, "skipDefaultUpdate") => @"If true, this remote will be skipped by default when updating using git-fetch or the update subcommand of git-remote",
                ("remote", _, "skipFetchAll") => @"If true, this remote will be skipped by default when updating using git-fetch or the update subcommand of git-remote",
                ("remote", _, "receivepack") => @"The default program to execute on the remote side when pushing",
                ("remote", _, "uploadpack") => @"The default program to execute on the remote side when fetching",
                ("remote", _, "tagOpt") => @"Setting this value to --no-tags disables automatic tag following when fetching from remote",
                ("remote", _, "vcs") => @"Setting this to a value <vcs> will cause Git to interact with the remote with the git-remote-<vcs> helper",
                ("remote", _, "prune") => @"When set to true, fetching from this remote by default will also remove any remote-tracking references that no longer exist on the remote (as if the --prune option was given on the command line)",
                ("remote", _, "pruneTags") => @"When set to true, fetching from this remote by default will also remove any local tags that no longer exist on the remote if pruning is activated in general via remote.*.prune, fetch.prune or --prune",
                ("remote", _, "promisor") => @"When set to true, this remote will be used to fetch promisor objects",
                ("remote", _, "partialclonefilter") => @"The filter that will be applied when fetching from this promisor remote",
                ("remotes", _, null) => $@"The list of remotes which are fetched by `""git remote update {second}`""",
                // "repack.useDeltaBaseOffset" {  }
                ("repack", "packKeptObjects", null) => @"If set to true, makes git repack act as if --pack-kept-objects was passed",
                ("repack", "useDeltaIslands", null) => @"If set to true, makes git repack act as if --delta-islands was passed",
                ("repack", "writeBitmaps", null) => @"When true, git will write a bitmap index when packing all objects to disk",
                ("repack", "updateServerInfo", null) => @"If set to false, git-repack will not run git-update-server-info",
                ("repack", "cruftWindow", null) => @"Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line",
                ("repack", "cruftWindowMemory", null) => @"Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line",
                ("repack", "cruftDepth", null) => @"Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line",
                ("repack", "cruftThreads", null) => @"Parameters used by git-pack-objects when generating a cruft pack and the respective parameters are not given over the command line",

                ("rerere", "autoUpdate", null) => @"When set to true, git-rerere updates the index with the resulting contents after it cleanly resolves conflicts using previously recorded resolutions",
                ("rerere", "enabled", null) => @"Activate recording of resolved conflicts, so that identical conflict hunks can be resolved automatically, should they be encountered again",

                ("revert", "reference", null) => @"Setting this variable to true makes git revert behave as if the --reference option is given",

                ("safe", "bareRepository", null) => @"Specifies which bare repositories Git will work with",
                ("safe", "directory", null) => @"These config entries specify Git-tracked directories that are considered safe even if they are owned by someone other than the current user",

                ("sendemail", "identity", null) => @"A configuration identity",
                ("sendemail", "smtpEncryption", null) => @"See git-send-email for description",
                ("sendemail", "smtpSSLCertPath", null) => @"Path to ca-certificates (either a directory or a single file)",
                ("sendemail", _, { }) => @"Identity-specific versions of the sendemail.* parameters",
                ("sendemail", "multiEdit", null) => @"If true, a single editor instance will be spawned to edit files you have to edit (patches when --annotate is used, and the summary when --compose is used)",
                ("sendemail", "confirm", null) => @"Sets the default for whether to confirm before sending",
                ("sendemail", "aliasesFile", null) => @"To avoid typing long email addresses, point this to one or more email aliases files",
                ("sendemail", "aliasFileType", null) => @"Format of the file(s) specified in sendemail.aliasesFile",
                ("sendemail", "annotate", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "bcc", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "cc", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "ccCmd", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "chainReplyTo", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "envelopeSender", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "from", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "headerCmd", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "signedOffByCc", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "smtpPass", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "suppressCc", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "suppressFrom", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "to", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "toCmd", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "smtpDomain", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "smtpServer", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "smtpServerPort", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "smtpServerOption", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "smtpUser", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "thread", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "transferEncoding", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "validate", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "xmailer", null) => @"These configuration variables all provide a default for git-send-email command-line options",
                ("sendemail", "smtpBatchSize", null) => @"Number of messages to be sent per connection, after that a relogin will happen",
                ("sendemail", "smtpReloginDelay", null) => @"Seconds to wait before reconnecting to the smtp server",
                ("sendemail", "forbidSendmailVariables", null) => @"To avoid common misconfiguration mistakes, git-send-email will abort with a warning if any configuration options for ""sendmail"" exist",

                ("sendpack", "sideband", null) => @"Allows to disable the side-band-64k capability for send-pack even when it is advertised by the server",

                ("sequence", "editor", null) => @"Text editor used by git rebase -i for editing the rebase instruction file",

                ("showBranch", "default", null) => @"The default set of branches for git-show-branch",

                // "sparse.expectFilesOutsideOfPatterns" {  }

                ("splitIndex", "maxPercentChange", null) => @"When the split index feature is used, this specifies the percent of entries the split index can contain compared to the total number of entries in both the split index and the shared index before a new shared index is written",
                ("splitIndex", "sharedIndexExpire", null) => @"When the split index feature is used, shared index files that were not modified since the time this variable specifies will be removed when a new shared index file is created",

                ("ssh", "variant", null) => @"Override detection of OpenSSH options",

                ("stash", "showIncludeUntracked", null) => @"If this is set to true, the git stash show command will show the untracked files of a stash entry",
                ("stash", "showPatch", null) => @"If this is set to true, the git stash show command without an option will show the stash entry in patch form",
                ("stash", "showStat", null) => @"If this is set to true, the git stash show command without an option will show a diffstat of the stash entry",
                ("status", "relativePaths", null) => @"If true, git-status shows paths relative to the current directory",
                ("status", "short", null) => @"Set to true to enable --short by default in git-status",
                ("status", "branch", null) => @"Set to true to enable --branch by default in git-status",
                ("status", "aheadBehind", null) => @"Set to true to enable --ahead-behind and false to enable --no-ahead-behind by default in git-status for non-porcelain status formats",
                ("status", "displayCommentPrefix", null) => @"If set to true, git-status will insert a comment prefix before each output line",
                ("status", "renameLimit", null) => @"The number of files to consider when performing rename detection in git-status and git-commit",
                ("status", "renames", null) => @"Whether and how Git detects renames in git-status and git-commit",
                ("status", "showStash", null) => @"If set to true, git-status will display the number of entries currently stashed away",
                ("status", "showUntrackedFiles", null) => @"Whether to show files which are not currently tracked by Git",
                ("status", "submoduleSummary", null) => @"If this is set to a non-zero number or true (identical to -1 or an unlimited number), the submodule summary will be enabled and a summary of commits for modified submodules will be shown",

                ("submodule", _, "url") => @"The URL for a submodule",
                ("submodule", _, "update") => @"The method by which a submodule is updated by git submodule update, which is the only affected command, others such as git checkout --recurse-submodules are unaffected",
                ("submodule", _, "branch") => @"The remote branch name for a submodule, used by git submodule update --remote",
                ("submodule", _, "fetchRecurseSubmodules") => @"This option can be used to control recursive fetching of this submodule",
                ("submodule", _, "ignore") => @"Defines under what circumstances ""git status"" and the diff family show a submodule as modified",
                ("submodule", _, "active") => @"Boolean value indicating if the submodule is of interest to git commands",
                ("submodule", "active", null) => @"A repeated field which contains a pathspec used to match against a submodule’s path to determine if the submodule is of interest to git commands",
                ("submodule", "recurse", null) => @"A boolean indicating if commands should enable the --recurse-submodules option by default",
                ("submodule", "propagateBranches", null) => @"A boolean that enables branching support when using --recurse-submodules or submodule.recurse=true",
                ("submodule", "fetchJobs", null) => @"Specifies how many submodules are fetched/cloned at the same time",
                ("submodule", "alternateLocation", null) => @"Specifies how the submodules obtain alternates when submodules are cloned",
                ("submodule", "alternateErrorStrategy", null) => @"Specifies how to treat errors with the alternates for a submodule as computed via submodule.alternateLocation",

                ("tag", "forceSignAnnotated", null) => @"Specify whether annotated tags created should be GPG signed",
                ("tag", "sort", null) => @"Controls the sort ordering of tags when displayed by git-tag",
                ("tag", "gpgSign", null) => @"Specify whether all tags should be GPG signed",
                ("tar", "umask", null) => @"Restrict the permission bits of tar archive entries",

                ("trace2", "normalTarget", null) => @"Controls the normal target destination",
                ("trace2", "perfTarget", null) => @"Controls the performance target destination",
                ("trace2", "eventTarget", null) => @"Controls the event target destination",
                ("trace2", "normalBrief", null) => @"When true time, filename, and line fields are omitted from normal output",
                ("trace2", "perfBrief", null) => @"When true time, filename, and line fields are omitted from PERF output",
                ("trace2", "eventBrief", null) => @"When true time, filename, and line fields are omitted from event output",
                ("trace2", "eventNesting", null) => @"Specifies desired depth of nested regions in the event output",
                ("trace2", "configParams", null) => @"A comma-separated list of patterns of ""important"" config settings that should be recorded in the trace2 output",
                ("trace2", "envVars", null) => @"A comma-separated list of ""important"" environment variables that should be recorded in the trace2 output",
                ("trace2", "destinationDebug", null) => @"When true Git will print error messages when a trace target destination cannot be opened for writing",
                ("trace2", "maxFiles", null) => @"When writing trace files to a target directory, do not write additional traces if doing so would exceed this many files",
                ("transfer", "credentialsInUrl", null) => @"A configured URL can contain plaintext credentials in the form <protocol>://<user>:<password>@<domain>/<path>",
                ("transfer", "fsckObjects", null) => @"The fetch or receive will abort in the case of a malformed object or a link to a nonexistent object",
                ("transfer", "hideRefs", null) => @"String(s) receive-pack and upload-pack use to decide which refs to omit from their initial advertisements",
                ("transfer", "unpackLimit", null) => @"When fetch.unpackLimit or receive.unpackLimit are not set, the value of this variable is used instead",
                ("transfer", "advertiseSID", null) => @"When true, client and server processes will advertise their unique session IDs to their remote counterpart",
                ("transfer", "bundleURI", null) => @"When true, local git clone commands will request bundle information from the remote server (if advertised) and download bundles before continuing the clone through the Git protocol",
                ("transfer", "advertiseObjectInfo", null) => @"When true, the object-info capability is advertised by servers",
                ("uploadarchive", "allowUnreachable", null) => @"If true, allow clients to use git archive --remote to request any tree, whether reachable from the ref tips or not",
                ("uploadpack", "hideRefs", null) => @"This variable is the same as transfer.hideRefs, but applies only to upload-pack (and so affects only fetches, not pushes)",
                ("uploadpack", "allowTipSHA1InWant", null) => @"When uploadpack.hideRefs is in effect, allow upload-pack to accept a fetch request that asks for an object at the tip of a hidden ref (by default, such a request is rejected)",
                ("uploadpack", "allowReachableSHA1InWant", null) => @"Allow upload-pack to accept a fetch request that asks for an object that is reachable from any ref tip",
                ("uploadpack", "allowAnySHA1InWant", null) => @"Allow upload-pack to accept a fetch request that asks for any object at all",
                ("uploadpack", "keepAlive", null) => @"If true, upload-pack to send an empty keepalive packet every uploadpack.keepAlive seconds",
                ("uploadpack", "packObjectsHook", null) => @"If this option is set, when upload-pack would run git pack-objects to create a packfile for a client, it will run this shell command instead",
                ("uploadpack", "allowFilter", null) => @"If this option is set, upload-pack will support partial clone and partial fetch object filtering",

                ("uploadpackfilter", "allow", null) => @"Provides a default value for unspecified object filters",
                ("uploadpackfilter", _, "allow") => @"Explicitly allow or ban the object filter",

                ("uploadpackfilter", "tree", "maxDepth") => @"Only allow --filter=tree:<n> when <n> is no more than the value of uploadpackfilter.tree.maxDepth",
                ("uploadpack", "allowRefInWant", null) => @"If this option is set, upload-pack will support the ref-in-want feature of the protocol version 2 fetch command",

                ("url", _, "insteadOf") => @"Any URL that starts with this value will be rewritten to start",
                ("url", _, "pushInsteadOf") => @"Any URL that starts with this value will not be pushed to; the resulting URL will be pushed to",

                ("user", "name", null) => @"Determine what ends up in the author and committer fields of commit objects",
                ("user", "email", null) => @"Determine what ends up in the author and committer fields of commit objects",
                ("author", "name", null) => @"Determine what ends up in the author fields of commit objects",
                ("author", "email", null) => @"Determine what ends up in the author fields of commit objects",
                ("committer", "name", null) => @"Determine what ends up in the committer fields of commit objects",
                ("committer", "email", null) => @"Determine what ends up in the committer fields of commit objects",

                ("user", "useConfigOnly", null) => @"Instruct Git to avoid trying to guess defaults for user.email and user.name, and instead retrieve the values only from the configuration",
                ("user", "signingKey", null) => @"If git-tag or git-commit is not selecting the key you want it to automatically when creating a signed tag or commit, you can override the default selection with this variable",

                ("versionsort", "suffix", null) => @"Even when version sort is used in git-tag, tagnames with the same base version but different suffixes are still sorted lexicographically, resulting e.g. in prerelease tags appearing after the main release",

                ("web", "browser", null) => @"Specify a web browser that may be used by some commands. Currently only git-instaweb and git-help may use it",

                ("windows", "appendAtomically", null) => @"By default, append atomic API is used on windows. But it works only with local disk files, if you’re working on a network file system, you should set it false to turn it off",
                ("worktree", "guessRemote", null) => @"If no branch is specified and neither -b nor -B nor --detach is used, then git worktree add defaults to creating a new branch from HEAD",
                _ => null,
            };
        }
    }
}
