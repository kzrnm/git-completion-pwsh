. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'ConfigVariable' -Skip:$SkipHeavyTest -Tag Config {
    BeforeAll {
        Initialize-Home

        $ErrorActionPreference = 'SilentlyContinue'
        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
        git submodule add https://github.com/github/nagios-plugins-github.git sub 2>$null
        git submodule add https://github.com/github/nagios-plugins-github.git sum 2>$null
        git commit -m submodules
        git branch -c dev

        $submoduleCommit = git show -s dev --oneline --no-decorate
        function replace-Tooltip {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
            param ([Parameter(ValueFromPipeline)] $Object)

            process {
                if ($Object.ListItemText -in 'dev', 'HEAD', 'main') {
                    $Object.ToolTip = $submoduleCommit
                }
                $Object
            }
        }
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe '<Name>' -ForEach @(
        @{
            Name      = 'Root';
            Head      = 'git -c ';
            Converter = [scriptblock] {
                return $expected | replace-Tooltip
            };
        }
        @{
            Name      = 'CloneLong';
            Head      = 'git clone --config ';
            Converter = [scriptblock] {
                return $expected | replace-Tooltip
            };
        }
        @{
            Name      = 'CloneLongEqual';
            Head      = 'git clone --config=';
            Converter = [scriptblock] {
                return $expected | replace-Tooltip | ForEach-Object { 
                    $_ | ConvertTo-Completion -ResultType $_.ResultType -CompletionText ("--config=" + $_.CompletionText)
                }
            };
        }

        @{
            Name      = 'CloneShort';
            Head      = 'git clone -c ';
            Converter = [scriptblock] {
                return $expected | replace-Tooltip
            };
        }
    ) {

        Describe 'Value' {
            It '<line>' -ForEach @(
                @{
                    Line     = 'branch.main.remote=';
                    Expected = 'grm', 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.remote=$_" }
                },
                @{
                    Line     = 'branch.main.remote=or';
                    Expected = 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.remote=$_" }
                },
                @{
                    Line     = 'branch.main.pushremote=';
                    Expected = 'grm', 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.pushremote=$_" }
                },
                @{
                    Line     = 'branch.main.pushremote=or';
                    Expected = 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.pushremote=$_" }
                },
                @{
                    Line     = 'branch.main.pushdefault=';
                    Expected = 'grm', 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.pushdefault=$_" }
                },
                @{
                    Line     = 'branch.main.pushdefault=or';
                    Expected = 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.pushdefault=$_" }
                },
                @{
                    Line     = 'remote.pushdefault=';
                    Expected = 'grm', 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "remote.pushdefault=$_" }
                },
                @{
                    Line     = 'remote.pushdefault=or';
                    Expected = 'ordinary', 'origin' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "remote.pushdefault=$_" }
                },
                @{
                    Line     = 'branch.main.merge=';
                    Expected = 'HEAD',
                    'FETCH_HEAD', 
                    'dev', 
                    'main',
                    'grm/HEAD', 
                    'grm/develop', 
                    'ordinary/HEAD', 
                    'ordinary/develop', 
                    'origin/HEAD', 
                    'origin/develop', 
                    'initial', 
                    'zeta' | ForEach-Object {
                        switch ($_) {
                            'dev' {
                                @{
                                    ListItemText = 'dev';
                                    ToolTip      = 'cf862b2 submodules';
                                }
                            }
                            Default { $RemoteCommits[$_] }
                        }
                    } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.merge=$_" }
                },
                @{
                    Line     = 'branch.main.merge=or';
                    Expected = 'ordinary/HEAD', 'ordinary/develop', 'origin/HEAD', 'origin/develop' |
                    ForEach-Object { $RemoteCommits[$_] } |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.merge=$_" }
                },
                @{
                    Line     = 'branch.main.rebase=';
                    Expected = 'false', 'true', 'merges', 'interactive' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.rebase=$_" }
                },
                @{
                    Line     = 'branch.main.rebase=t';
                    Expected = 'true' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "branch.main.rebase=$_" }
                },
                @{
                    Line     = 'remote.origin.fetch=';
                    Expected = 'refs/heads' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "remote.origin.fetch=$_" }
                },
                @{
                    Line     = 'remote.origin.fetch=r';
                    Expected = 'refs/heads/develop:refs/remotes/origin/develop' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "remote.origin.fetch=$_" }
                },
                @{
                    Line     = 'pull.twohead=';
                    Expected = 'octopus', 'ours', 'recursive', 'resolve', 'subtree' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "pull.twohead=$_" }
                },
                @{
                    Line     = 'pull.twohead=r';
                    Expected = 'recursive', 'resolve' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "pull.twohead=$_" }
                },
                @{
                    Line     = 'pull.octopus=';
                    Expected = 'octopus', 'ours', 'recursive', 'resolve', 'subtree' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "pull.octopus=$_" }
                },
                @{
                    Line     = 'pull.octopus=r';
                    Expected = 'recursive', 'resolve' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "pull.octopus=$_" }
                },
                @{
                    Line     = 'color.pager=';
                    Expected = 'false', 'true' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.pager=$_" }
                },
                @{
                    Line     = 'color.pager=t';
                    Expected = 'true' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.pager=$_" }
                },
                @{
                    Line     = 'color.diff.old=';
                    Expected = 'normal', 'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white', 'bold', 'dim', 'ul', 'blink', 'reverse' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.diff.old=$_" }
                },
                @{
                    Line     = 'color.diff.old=r';
                    Expected = 'red', 'reverse' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.diff.old=$_" }
                },
                @{
                    Line     = 'color.remote.hint=';
                    Expected = 'normal', 'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white', 'bold', 'dim', 'ul', 'blink', 'reverse' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.remote.hint=$_" }
                },
                @{
                    Line     = 'color.remote.hint=r';
                    Expected = 'red', 'reverse' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.remote.hint=$_" }
                },
                @{
                    Line     = 'color.advice=';
                    Expected = 'false', 'true', 'always', 'never', 'auto' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.advice=$_" }
                },
                @{
                    Line     = 'color.advice=a';
                    Expected = 'always', 'auto' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.advice=$_" }
                },
                @{
                    Line     = 'color.push=';
                    Expected = 'false', 'true', 'always', 'never', 'auto' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.push=$_" }
                },
                @{
                    Line     = 'color.push=a';
                    Expected = 'always', 'auto' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "color.push=$_" }
                },
                @{
                    Line     = 'diff.algorithm=';
                    Expected = @{
                        CompletionText = "diff.algorithm=histogram";
                        ListItemText   = 'histogram';
                        ToolTip        = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
                    },
                    @{
                        CompletionText = "diff.algorithm=minimal";
                        ListItemText   = 'minimal';
                        ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                    },
                    @{
                        CompletionText = "diff.algorithm=myers";
                        ListItemText   = 'myers';
                        ToolTip        = '(default) The basic greedy diff algorithm';
                    },
                    @{
                        CompletionText = "diff.algorithm=patience";
                        ListItemText   = 'patience';
                        ToolTip        = 'Use "patience diff" algorithm when generating patches';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'diff.algorithm=m';
                    Expected = @{
                        CompletionText = "diff.algorithm=minimal";
                        ListItemText   = 'minimal';
                        ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                    },
                    @{
                        CompletionText = "diff.algorithm=myers";
                        ListItemText   = 'myers';
                        ToolTip        = '(default) The basic greedy diff algorithm';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'diff.submodule=';
                    Expected = @{
                        ListItemText = 'diff';
                        Tooltip      = 'Shows an inline diff of the changed contents of the submodule';
                    },
                    @{
                        ListItemText = 'log';
                        Tooltip      = 'Lists the commits in the range like "git submodule summary" does';
                    },
                    @{
                        ListItemText = 'short';
                        Tooltip      = '(default) Shows the names of the commits at the beginning and end of the range';
                    } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "diff.submodule=$_" }
                },
                @{
                    Line     = 'diff.submodule=d';
                    Expected = @{
                        ListItemText = 'diff';
                        Tooltip      = 'Shows an inline diff of the changed contents of the submodule';
                    } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "diff.submodule=$_" }
                },
                @{
                    Line     = 'http.proxyAuthMethod=';
                    Expected = @{
                        CompletionText = "http.proxyAuthMethod=anyauth";
                        ListItemText   = 'anyauth';
                        ToolTip        = 'Automatically pick a suitable authentication method';
                    },
                    @{
                        CompletionText = "http.proxyAuthMethod=basic";
                        ListItemText   = 'basic';
                        ToolTip        = 'HTTP Basic authentication';
                    },
                    @{
                        CompletionText = "http.proxyAuthMethod=digest";
                        ListItemText   = 'digest';
                        ToolTip        = 'HTTP Digest authentication; this prevents the password from being transmitted to the proxy in clear text';
                    },
                    @{
                        CompletionText = "http.proxyAuthMethod=negotiate";
                        ListItemText   = 'negotiate';
                        ToolTip        = 'GSS-Negotiate authentication (compare the --negotiate option of curl)';
                    },
                    @{
                        CompletionText = "http.proxyAuthMethod=ntlm";
                        ListItemText   = 'ntlm';
                        ToolTip        = 'NTLM authentication (compare the --ntlm option of curl)';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'http.proxyAuthMethod=d';
                    Expected = @{
                        CompletionText = "http.proxyAuthMethod=digest";
                        ListItemText   = 'digest';
                        ToolTip        = 'HTTP Digest authentication; this prevents the password from being transmitted to the proxy in clear text';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'help.format=';
                    Expected = 'man', 'info', 'web', 'html' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "help.format=$_" }
                },
                @{
                    Line     = 'help.format=m';
                    Expected = 'man' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "help.format=$_" }
                },
                @{
                    Line     = 'log.date=';
                    Expected = 'auto:', 'default', 'format:', 'human', 'iso8601', 'iso8601-strict', 'local', 'raw', 'relative', 'rfc2822', 'short', 'unix' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "log.date=$_" }
                },
                @{
                    Line     = 'log.date=i';
                    Expected = 'iso8601', 'iso8601-strict' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "log.date=$_" }
                },
                @{
                    Line     = 'sendemail.aliasfiletype=';
                    Expected = 'mutt', 'mailrc', 'pine', 'elm', 'gnus' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.aliasfiletype=$_" }
                },
                @{
                    Line     = 'sendemail.aliasfiletype=m';
                    Expected = 'mutt', 'mailrc' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.aliasfiletype=$_" }
                },
                @{
                    Line     = 'sendemail.confirm=';
                    Expected = 'always', 'auto', 'cc', 'compose', 'never' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.confirm=$_" }
                },
                @{
                    Line     = 'sendemail.confirm=a';
                    Expected = 'always', 'auto' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.confirm=$_" }
                },
                @{
                    Line     = 'sendemail.suppresscc=';
                    Expected = 'all', 'author', 'body', 'bodycc', 'cc', 'cccmd', 'self', 'sob' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.suppresscc=$_" }
                },
                @{
                    Line     = 'sendemail.suppresscc=a';
                    Expected = 'all', 'author' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.suppresscc=$_" }
                },
                @{
                    Line     = 'sendemail.transferencoding=';
                    Expected = '7bit', '8bit', 'quoted-printable', 'base64' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.transferencoding=$_" }
                },
                @{
                    Line     = 'sendemail.transferencoding=7';
                    Expected = '7bit' |
                    ConvertTo-Completion -ResultType ParameterValue -CompletionText { "sendemail.transferencoding=$_" }
                },
                @{
                    Line     = 'branch.main.notmatch=';
                    Expected = @();
                }
            ) {
                "$Head$Line" | Complete-FromLine | Should -BeCompletion ($Converter.Invoke())
            }
        }

        Describe 'Name' {
            It '<line>' -ForEach @(
                @{
                    Line     = "pu";
                    Expected =
                    "pull.", "push." | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "branch.main.r";
                    Expected = @{
                        CompletionText = "branch.main.rebase=";
                        ListItemText   = "branch.main.rebase";
                        ToolTip        = 'When true, rebase the branch <main> on top of the fetched branch, instead of merging the default branch from the default remote when "git pull" is run';
                    },
                    @{
                        CompletionText = "branch.main.remote=";
                        ListItemText   = "branch.main.remote";
                        ToolTip        = "When on branch <main>, it tells git fetch and git push which remote to fetch from or push to";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "guitool.pwsh.";
                    Expected = @{
                        CompletionText = "guitool.pwsh.argPrompt=";
                        ListItemText   = "guitool.pwsh.argPrompt";
                        ToolTip        = "Request a string argument from the user, and pass it to the tool through the ARGS environment variable";
                    },
                    @{
                        CompletionText = "guitool.pwsh.cmd=";
                        ListItemText   = "guitool.pwsh.cmd";
                        ToolTip        = "Specifies the shell command line to execute when the corresponding item of the git-gui Tools menu is invoked";
                    },
                    @{
                        CompletionText = "guitool.pwsh.confirm=";
                        ListItemText   = "guitool.pwsh.confirm";
                        ToolTip        = "Show a confirmation dialog before actually running the tool";
                    },
                    @{
                        CompletionText = "guitool.pwsh.needsFile=";
                        ListItemText   = "guitool.pwsh.needsFile";
                        ToolTip        = "Run the tool only if a diff is selected in the GUI";
                    },
                    @{
                        CompletionText = "guitool.pwsh.noConsole=";
                        ListItemText   = "guitool.pwsh.noConsole";
                        ToolTip        = "Run the command silently, without creating a window to display its output";
                    },
                    @{
                        CompletionText = "guitool.pwsh.noRescan=";
                        ListItemText   = "guitool.pwsh.noRescan";
                        ToolTip        = "Don’t rescan the working directory for changes after the tool finishes execution";
                    },
                    @{
                        CompletionText = "guitool.pwsh.prompt=";
                        ListItemText   = "guitool.pwsh.prompt";
                        ToolTip        = "Specifies the general prompt string to display at the top of the dialog, before subsections for argPrompt and revPrompt";
                    },
                    @{
                        CompletionText = "guitool.pwsh.revPrompt=";
                        ListItemText   = "guitool.pwsh.revPrompt";
                        ToolTip        = "Request a single valid revision from the user, and set the REVISION environment variable";
                    },
                    @{
                        CompletionText = "guitool.pwsh.revUnmerged=";
                        ListItemText   = "guitool.pwsh.revUnmerged";
                        ToolTip        = "Show only unmerged branches in the revPrompt subdialog";
                    },
                    @{
                        CompletionText = "guitool.pwsh.title=";
                        ListItemText   = "guitool.pwsh.title";
                        ToolTip        = "Specifies the title to use for the prompt dialog";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "guitool.pwsh.r";
                    Expected = @{
                        CompletionText = "guitool.pwsh.revPrompt=";
                        ListItemText   = "guitool.pwsh.revPrompt";
                        ToolTip        = "Request a single valid revision from the user, and set the REVISION environment variable";
                    },
                    @{
                        CompletionText = "guitool.pwsh.revUnmerged=";
                        ListItemText   = "guitool.pwsh.revUnmerged";
                        ToolTip        = "Show only unmerged branches in the revPrompt subdialog";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "difftool.pwsh.";
                    Expected = @{
                        CompletionText = "difftool.pwsh.cmd=";
                        ListItemText   = "difftool.pwsh.cmd";
                        ToolTip        = "Specify the command to invoke the specified diff tool";
                    },
                    @{
                        CompletionText = "difftool.pwsh.path=";
                        ListItemText   = "difftool.pwsh.path";
                        ToolTip        = "Override the path for the given tool";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "difftool.pwsh.c";
                    Expected = @{
                        CompletionText = "difftool.pwsh.cmd=";
                        ListItemText   = "difftool.pwsh.cmd";
                        ToolTip        = "Specify the command to invoke the specified diff tool";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "man.pwsh.";
                    Expected = @{
                        CompletionText = "man.pwsh.cmd=";
                        ListItemText   = "man.pwsh.cmd";
                        ToolTip        = "Specify the command to invoke the specified man viewer";
                    },
                    @{
                        CompletionText = "man.pwsh.path=";
                        ListItemText   = "man.pwsh.path";
                        ToolTip        = "Override the path for the given tool that may be used to display help in the man format";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "man.pwsh.c";
                    Expected = @{
                        CompletionText = "man.pwsh.cmd=";
                        ListItemText   = "man.pwsh.cmd";
                        ToolTip        = "Specify the command to invoke the specified man viewer";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "mergetool.pwsh.";
                    Expected = @{
                        CompletionText = "mergetool.pwsh.cmd=";
                        ListItemText   = "mergetool.pwsh.cmd";
                        ToolTip        = "Specify the command to invoke the specified merge tool";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.hideResolved=";
                        ListItemText   = "mergetool.pwsh.hideResolved";
                        ToolTip        = "Allows the user to override the global mergetool.hideResolved value for a specific tool";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.path=";
                        ListItemText   = "mergetool.pwsh.path";
                        ToolTip        = "Override the path for the given tool";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.trustExitCode=";
                        ListItemText   = "mergetool.pwsh.trustExitCode";
                        ToolTip        = "For a custom merge command, specify whether the exit code of the merge command can be used to determine whether the merge was successful";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.layout=";
                        ListItemText   = "mergetool.pwsh.layout";
                        ToolTip        = "Configure the split window layout for vimdiff’s <variant>, which is any of vimdiff, nvimdiff, gvimdiff";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.hasOutput=";
                        ListItemText   = "mergetool.pwsh.hasOutput";
                        ToolTip        = "mergetool.pwsh.hasOutput";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.useAutoMerge=";
                        ListItemText   = "mergetool.pwsh.useAutoMerge";
                        ToolTip        = "mergetool.pwsh.useAutoMerge";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "mergetool.pwsh.c";
                    Expected = @{
                        CompletionText = "mergetool.pwsh.cmd=";
                        ListItemText   = "mergetool.pwsh.cmd";
                        ToolTip        = "Specify the command to invoke the specified merge tool";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "remote.pwsh.";
                    Expected = @{
                        CompletionText = "remote.pwsh.fetch=";
                        ListItemText   = "remote.pwsh.fetch";
                        ToolTip        = 'The default set of "refspec" for git-fetch';
                    }, @{
                        CompletionText = "remote.pwsh.followRemoteHEAD=";
                        ListItemText   = "remote.pwsh.followRemoteHEAD";
                        ToolTip        = 'How git-fetch should handle updates to remotes/<name>/HEAD';
                    },
                    @{
                        CompletionText = "remote.pwsh.mirror=";
                        ListItemText   = "remote.pwsh.mirror";
                        ToolTip        = "If true, pushing to this remote will automatically behave as if the --mirror option was given on the command line";
                    },
                    @{
                        CompletionText = "remote.pwsh.partialclonefilter=";
                        ListItemText   = "remote.pwsh.partialclonefilter";
                        ToolTip        = "The filter that will be applied when fetching from this promisor remote";
                    },
                    @{
                        CompletionText = "remote.pwsh.promisor=";
                        ListItemText   = "remote.pwsh.promisor";
                        ToolTip        = "When set to true, this remote will be used to fetch promisor objects";
                    },
                    @{
                        CompletionText = "remote.pwsh.proxy=";
                        ListItemText   = "remote.pwsh.proxy";
                        ToolTip        = "For remotes that require curl (http, https and ftp), the URL to the proxy to use for that remote";
                    },
                    @{
                        CompletionText = "remote.pwsh.proxyAuthMethod=";
                        ListItemText   = "remote.pwsh.proxyAuthMethod";
                        ToolTip        = "For remotes that require curl (http, https and ftp), the method to use for authenticating against the proxy in use (probably set in remote.<name>.proxy)";
                    },
                    @{
                        CompletionText = "remote.pwsh.prune=";
                        ListItemText   = "remote.pwsh.prune";
                        ToolTip        = "When set to true, fetching from this remote by default will also remove any remote-tracking references that no longer exist on the remote (as if the --prune option was given on the command line)";
                    },
                    @{
                        CompletionText = "remote.pwsh.pruneTags=";
                        ListItemText   = "remote.pwsh.pruneTags";
                        ToolTip        = "When set to true, fetching from this remote by default will also remove any local tags that no longer exist on the remote if pruning is activated in general via remote.*.prune, fetch.prune or --prune";
                    },
                    @{
                        CompletionText = "remote.pwsh.push=";
                        ListItemText   = "remote.pwsh.push";
                        ToolTip        = 'The default set of "refspec" for git-push';
                    },
                    @{
                        CompletionText = "remote.pwsh.pushurl=";
                        ListItemText   = "remote.pwsh.pushurl";
                        ToolTip        = "The push URL of a remote repository";
                    },
                    @{
                        CompletionText = "remote.pwsh.receivepack=";
                        ListItemText   = "remote.pwsh.receivepack";
                        ToolTip        = "The default program to execute on the remote side when pushing";
                    },
                    @{
                        CompletionText = "remote.pwsh.serverOption=";
                        ListItemText   = "remote.pwsh.serverOption";
                        ToolTip        = 'The default set of server options used when fetching from this remote';
                    },
                    @{
                        CompletionText = "remote.pwsh.skipDefaultUpdate=";
                        ListItemText   = "remote.pwsh.skipDefaultUpdate";
                        ToolTip        = "If true, this remote will be skipped by default when updating using git-fetch or the update subcommand of git-remote";
                    },
                    @{
                        CompletionText = "remote.pwsh.skipFetchAll=";
                        ListItemText   = "remote.pwsh.skipFetchAll";
                        ToolTip        = "If true, this remote will be skipped by default when updating using git-fetch or the update subcommand of git-remote";
                    },
                    @{
                        CompletionText = "remote.pwsh.tagOpt=";
                        ListItemText   = "remote.pwsh.tagOpt";
                        ToolTip        = "Setting this value to --no-tags disables automatic tag following when fetching from remote";
                    },
                    @{
                        CompletionText = "remote.pwsh.uploadpack=";
                        ListItemText   = "remote.pwsh.uploadpack";
                        ToolTip        = "The default program to execute on the remote side when fetching";
                    },
                    @{
                        CompletionText = "remote.pwsh.url=";
                        ListItemText   = "remote.pwsh.url";
                        ToolTip        = "remote.pwsh.url";
                    },
                    @{
                        CompletionText = "remote.pwsh.vcs=";
                        ListItemText   = "remote.pwsh.vcs";
                        ToolTip        = "Setting this to a value <vcs> will cause Git to interact with the remote with the git-remote-<vcs> helper";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "remote.pwsh.u";
                    Expected = @{
                        CompletionText = "remote.pwsh.uploadpack=";
                        ListItemText   = "remote.pwsh.uploadpack";
                        ToolTip        = "The default program to execute on the remote side when fetching";
                    },
                    @{
                        CompletionText = "remote.pwsh.url=";
                        ListItemText   = "remote.pwsh.url";
                        ToolTip        = "remote.pwsh.url";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "submodule.posh.";
                    Expected = @{
                        CompletionText = "submodule.posh.active=";
                        ListItemText   = "submodule.posh.active";
                        ToolTip        = "Boolean value indicating if the submodule is of interest to git commands";
                    },
                    @{
                        CompletionText = "submodule.posh.branch=";
                        ListItemText   = "submodule.posh.branch";
                        ToolTip        = "The remote branch name for a submodule, used by git submodule update --remote";
                    },
                    @{
                        CompletionText = "submodule.posh.fetchRecurseSubmodules=";
                        ListItemText   = "submodule.posh.fetchRecurseSubmodules";
                        ToolTip        = "This option can be used to control recursive fetching of this submodule";
                    },
                    @{
                        CompletionText = "submodule.posh.ignore=";
                        ListItemText   = "submodule.posh.ignore";
                        ToolTip        = 'Defines under what circumstances "git status" and the diff family show a submodule as modified';
                    },
                    @{
                        CompletionText = "submodule.posh.update=";
                        ListItemText   = "submodule.posh.update";
                        ToolTip        = "The method by which a submodule is updated by git submodule update, which is the only affected command, others such as git checkout --recurse-submodules are unaffected";
                    },
                    @{
                        CompletionText = "submodule.posh.url=";
                        ListItemText   = "submodule.posh.url";
                        ToolTip        = "The URL for a submodule";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "submodule.posh.u";
                    Expected = @{
                        CompletionText = "submodule.posh.update=";
                        ListItemText   = "submodule.posh.update";
                        ToolTip        = "The method by which a submodule is updated by git submodule update, which is the only affected command, others such as git checkout --recurse-submodules are unaffected";
                    },
                    @{
                        CompletionText = "submodule.posh.url=";
                        ListItemText   = "submodule.posh.url";
                        ToolTip        = "The URL for a submodule";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "url.git@github.com:.";
                    Expected = @{
                        CompletionText = "url.git@github.com:.insteadOf=";
                        ListItemText   = "url.git@github.com:.insteadOf";
                        ToolTip        = "Any URL that starts with this value will be rewritten to start";
                    },
                    @{
                        CompletionText = "url.git@github.com:.pushInsteadOf=";
                        ListItemText   = "url.git@github.com:.pushInsteadOf";
                        ToolTip        = "Any URL that starts with this value will not be pushed to; the resulting URL will be pushed to";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "url.git@github.com:.i";
                    Expected = @{
                        CompletionText = "url.git@github.com:.insteadOf=";
                        ListItemText   = "url.git@github.com:.insteadOf";
                        ToolTip        = "Any URL that starts with this value will be rewritten to start";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "branch.";
                    Expected =
                    "branch.dev.",
                    "branch.main.",
                    @{
                        CompletionText = "branch.autoSetupMerge=";
                        ListItemText   = "branch.autoSetupMerge";
                        ToolTip        = "Tells git branch, git switch and git checkout to set up new branches so that git-pull will appropriately merge from the starting point branch";
                    },
                    @{
                        CompletionText = "branch.autoSetupRebase=";
                        ListItemText   = "branch.autoSetupRebase";
                        ToolTip        = "When a new branch is created with git branch, git switch or git checkout that tracks another branch, this variable tells Git to set up pull to rebase instead of merge";
                    },
                    @{
                        CompletionText = "branch.sort=";
                        ListItemText   = "branch.sort";
                        ToolTip        = "This variable controls the sort ordering of branches when displayed by git-branch";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "branch.m";
                    Expected =
                    "branch.main." | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "branch.a";
                    Expected = @{
                        CompletionText = "branch.autoSetupMerge=";
                        ListItemText   = "branch.autoSetupMerge";
                        ToolTip        = "Tells git branch, git switch and git checkout to set up new branches so that git-pull will appropriately merge from the starting point branch";
                    },
                    @{
                        CompletionText = "branch.autoSetupRebase=";
                        ListItemText   = "branch.autoSetupRebase";
                        ToolTip        = "When a new branch is created with git branch, git switch or git checkout that tracks another branch, this variable tells Git to set up pull to rebase instead of merge";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "remote.";
                    Expected =
                    "remote.grm.", "remote.ordinary.", "remote.origin.", @{
                        CompletionText = "remote.pushDefault=";
                        ListItemText   = "remote.pushDefault";
                        ToolTip        = "The remote to push to by default";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "remote.o";
                    Expected =
                    "remote.ordinary.", "remote.origin." | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "remote.p";
                    Expected = @{
                        CompletionText = "remote.pushDefault=";
                        ListItemText   = "remote.pushDefault";
                        ToolTip        = "The remote to push to by default";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "submodule.";
                    Expected =
                    "submodule.sub.",
                    "submodule.sum.",
                    @{
                        CompletionText = "submodule.active=";
                        ListItemText   = "submodule.active";
                        ToolTip        = "A repeated field which contains a pathspec used to match against a submodule’s path to determine if the submodule is of interest to git commands";
                    },
                    @{
                        CompletionText = "submodule.alternateErrorStrategy=";
                        ListItemText   = "submodule.alternateErrorStrategy";
                        ToolTip        = "Specifies how to treat errors with the alternates for a submodule as computed via submodule.alternateLocation";
                    },
                    @{
                        CompletionText = "submodule.alternateLocation=";
                        ListItemText   = "submodule.alternateLocation";
                        ToolTip        = "Specifies how the submodules obtain alternates when submodules are cloned";
                    },
                    @{
                        CompletionText = "submodule.fetchJobs=";
                        ListItemText   = "submodule.fetchJobs";
                        ToolTip        = "Specifies how many submodules are fetched/cloned at the same time";
                    },
                    @{
                        CompletionText = "submodule.propagateBranches=";
                        ListItemText   = "submodule.propagateBranches";
                        ToolTip        = "A boolean that enables branching support when using --recurse-submodules or submodule.recurse=true";
                    },
                    @{
                        CompletionText = "submodule.recurse=";
                        ListItemText   = "submodule.recurse";
                        ToolTip        = "A boolean indicating if commands should enable the --recurse-submodules option by default";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "submodule.s";
                    Expected =
                    "submodule.sub.",
                    "submodule.sum." | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "submodule.r";
                    Expected = @{
                        CompletionText = "submodule.recurse=";
                        ListItemText   = "submodule.recurse";
                        ToolTip        = "A boolean indicating if commands should enable the --recurse-submodules option by default";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "tag.";
                    Expected = @{
                        CompletionText = "tag.forceSignAnnotated=";
                        ListItemText   = "tag.forceSignAnnotated";
                        ToolTip        = "Specify whether annotated tags created should be GPG signed";
                    },
                    @{
                        CompletionText = "tag.gpgSign=";
                        ListItemText   = "tag.gpgSign";
                        ToolTip        = "Specify whether all tags should be GPG signed";
                    },
                    @{
                        CompletionText = "tag.sort=";
                        ListItemText   = "tag.sort";
                        ToolTip        = "Controls the sort ordering of tags when displayed by git-tag";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "revert.r";
                    Expected = @{
                        CompletionText = "revert.reference=";
                        ListItemText   = "revert.reference";
                        ToolTip        = "Setting this variable to true makes git revert behave as if the --reference option is given";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "pu";
                    Expected =
                    "pull.", "push." | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "browser.";
                    Expected = @(
                    )
                },
                @{
                    Line     = "notmatch";
                    Expected = @();
                }
            ) {
                "$Head$Line" | Complete-FromLine | Should -BeCompletion ($Converter.Invoke())
            }

            Describe 'CommandWithAlias' {
                BeforeAll {
                    git config alias.pr 'pull origin'
                }
                AfterAll {
                    git config --unset alias.pr
                }

                It '<line>' -ForEach @(
                    @{
                        Line     = "pager.pr";
                        Expected = @{
                            CompletionText = "pager.pr=";
                            ListItemText   = "pager.pr";
                            ToolTip        = "Turns on or off pagination of the output of a particular Git subcommand <pr> when writing to a tty";
                        },
                        @{
                            CompletionText = "pager.prune=";
                            ListItemText   = "pager.prune";
                            ToolTip        = "Turns on or off pagination of the output of a particular Git subcommand <prune> when writing to a tty";
                        },
                        @{
                            CompletionText = "pager.prune-packed=";
                            ListItemText   = "pager.prune-packed";
                            ToolTip        = "Turns on or off pagination of the output of a particular Git subcommand <prune-packed> when writing to a tty";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "$Head$Line" | Complete-FromLine | Should -BeCompletion ($Converter.Invoke())
                }
            }

            Describe 'CommandWithoutAlias' {
                It '<line>' -ForEach @(
                    @{
                        Line     = "pager.pr";
                        Expected = @{
                            CompletionText = "pager.prune=";
                            ListItemText   = "pager.prune";
                            ToolTip        = "Turns on or off pagination of the output of a particular Git subcommand <prune> when writing to a tty";
                        },
                        @{
                            CompletionText = "pager.prune-packed=";
                            ListItemText   = "pager.prune-packed";
                            ToolTip        = "Turns on or off pagination of the output of a particular Git subcommand <prune-packed> when writing to a tty";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "$Head$Line" | Complete-FromLine | Should -BeCompletion ($Converter.Invoke())
                }
            }
        }
    }
}