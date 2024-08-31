using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | Convert-ToKebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }
    Describe '_' {
        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-v';
                    ListItemText   = '-v';
                    ResultType     = 'ParameterName';
                    ToolTip        = "be verbose; must be placed before a subcommand";
                },
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @(
                        @{
                            CompletionText = '--verbose';
                            ListItemText   = '--verbose';
                            ResultType     = 'ParameterName';
                            ToolTip        = "be verbose; must be placed before a subcommand";
                        },
                        @{
                            CompletionText = '--no-verbose';
                            ListItemText   = '--no-verbose';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] be verbose; must be placed before a subcommand";
                        }
                    )
                },
                @{
                    Line     = '--v';
                    Expected = @(
                        @{
                            CompletionText = '--verbose';
                            ListItemText   = '--verbose';
                            ResultType     = 'ParameterName';
                            ToolTip        = "be verbose; must be placed before a subcommand";
                        }
                    )
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Subcommands' {
            Context '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = @(
                        @{Subcommand = 'add'; Description = 'Add a remote'; },
                        @{Subcommand = 'rename'; Description = 'Rename the remote name'; },
                        @{Subcommand = 'remove'; Description = 'Remove the remote name'; },
                        @{Subcommand = 'set-head'; Description = 'Sets or deletes the default branch for the named remote'; },
                        @{Subcommand = 'set-branches'; Description = 'Changes the list of branches tracked by the named remote'; },
                        @{Subcommand = 'get-url'; Description = 'Retrieves the URLs for a remote'; },
                        @{Subcommand = 'set-url'; Description = 'Changes URLs for the remote'; },
                        @{Subcommand = 'show'; Description = 'Gives some information'; },
                        @{Subcommand = 'prune'; Description = 'Deletes stale references'; },
                        @{Subcommand = 'update'; Description = 'Fetch updates for remotes or remote groups'; }
                    ) | ForEach-Object {
                        @{
                            CompletionText = $_.Subcommand;
                            ListItemText   = $_.Subcommand;
                            ResultType     = 'ParameterName';
                            ToolTip        = $_.Description;
                        }
                    }
                },
                @{
                    Line     = 'set-';
                    Expected = @(
                        @{Subcommand = 'set-head'; Description = 'Sets or deletes the default branch for the named remote'; },
                        @{Subcommand = 'set-branches'; Description = 'Changes the list of branches tracked by the named remote'; },
                        @{Subcommand = 'set-url'; Description = 'Changes URLs for the remote'; }
                    ) | ForEach-Object {
                        @{
                            CompletionText = $_.Subcommand;
                            ListItemText   = $_.Subcommand;
                            ResultType     = 'ParameterName';
                            ToolTip        = $_.Description;
                        }
                    }
                }
            ) {
                It '<_>' -ForEach @(
                    '',
                    '-v',
                    '--verbose',
                    '--no-verbose'
                ) {
                    "git $Command $_ $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }

    Describe 'add' {
        BeforeAll {
            Set-Variable Subcommand 'add'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-f';
                    ListItemText   = '-f';
                    ResultType     = 'ParameterName';
                    ToolTip        = "fetch the remote branches";
                },
                @{
                    CompletionText = '-m';
                    ListItemText   = '-m';
                    ResultType     = 'ParameterName';
                    ToolTip        = "master branch";
                },
                @{
                    CompletionText = '-t';
                    ListItemText   = '-t';
                    ResultType     = 'ParameterName';
                    ToolTip        = "branch(es) to track";
                },
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--t';
                    Expected = @(
                        @{
                            CompletionText = '--tags';
                            ListItemText   = '--tags';
                            ResultType     = 'ParameterName';
                            ToolTip        = "import all tags and associated objects when fetching";
                        },
                        @{
                            CompletionText = '--track=';
                            ListItemText   = '--track=';
                            ResultType     = 'ParameterName';
                            ToolTip        = "branch(es) to track";
                        }
                    )
                },
                @{
                    Line     = '--no-t';
                    Expected = @(
                        @{
                            CompletionText = '--no-tags';
                            ListItemText   = '--no-tags';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] import all tags and associated objects when fetching";
                        },
                        @{
                            CompletionText = '--no-track';
                            ListItemText   = '--no-track';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] branch(es) to track";
                        }
                    )
                },
                @{
                    Line     = '--n';
                    Expected = @(
                        @{
                            CompletionText = '--no-fetch';
                            ListItemText   = '--no-fetch';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] fetch the remote branches";
                        },
                        @{
                            CompletionText = '--no-';
                            ListItemText   = '--no-...';
                            ResultType     = 'Text';
                            ToolTip        = "--no-...";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'None' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '.. ';
                    Expected = @()
                },
                @{
                    Line     = '--fetch ';
                    Expected = @()
                },
                @{
                    Line     = '';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'prune' {
        BeforeAll {
            Set-Variable Subcommand 'prune'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-n';
                    ListItemText   = '-n';
                    ResultType     = 'ParameterName';
                    ToolTip        = "dry run";
                },
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @(
                        @{
                            CompletionText = '--dry-run';
                            ListItemText   = '--dry-run';
                            ResultType     = 'ParameterName';
                            ToolTip        = "dry run";
                        },
                        @{
                            CompletionText = '--no-dry-run';
                            ListItemText   = '--no-dry-run';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] dry run";
                        }
                    )
                },
                @{
                    Line     = '--no';
                    Expected = @(
                        @{
                            CompletionText = '--no-dry-run';
                            ListItemText   = '--no-dry-run';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] dry run";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'remove' {
        BeforeAll {
            Set-Variable Subcommand 'remove'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'rename' {
        BeforeAll {
            Set-Variable Subcommand 'rename'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @(
                        @{
                            CompletionText = '--progress';
                            ListItemText   = '--progress';
                            ResultType     = 'ParameterName';
                            ToolTip        = "force progress reporting";
                        },
                        @{
                            CompletionText = '--no-progress';
                            ListItemText   = '--no-progress';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] force progress reporting";
                        }
                    )
                },
                @{
                    Line     = '--p';
                    Expected = @(
                        @{
                            CompletionText = '--progress';
                            ListItemText   = '--progress';
                            ResultType     = 'ParameterName';
                            ToolTip        = "force progress reporting";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'set-head' {
        BeforeAll {
            Set-Variable Subcommand 'set-head'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-a';
                    ListItemText   = '-a';
                    ResultType     = 'ParameterName';
                    ToolTip        = "set refs/remotes/<name>/HEAD according to remote";
                },
                @{
                    CompletionText = '-d';
                    ListItemText   = '-d';
                    ResultType     = 'ParameterName';
                    ToolTip        = "delete refs/remotes/<name>/HEAD";
                },
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--d';
                    Expected = @(
                        @{
                            CompletionText = '--delete';
                            ListItemText   = '--delete';
                            ResultType     = 'ParameterName';
                            ToolTip        = "delete refs/remotes/<name>/HEAD";
                        }
                    )
                },
                @{
                    Line     = '--no-d';
                    Expected = @(
                        @{
                            CompletionText = '--no-delete';
                            ListItemText   = '--no-delete';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] delete refs/remotes/<name>/HEAD";
                        }
                    )
                },
                @{
                    Line     = '--no';
                    Expected = @(
                        @{
                            CompletionText = '--no-auto';
                            ListItemText   = '--no-auto';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] set refs/remotes/<name>/HEAD according to remote";
                        },
                        @{
                            CompletionText = '--no-';
                            ListItemText   = '--no-...';
                            ResultType     = 'Text';
                            ToolTip        = "--no-...";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrRefspec' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'origin ';
                    Expected = @(
                        'HEAD',
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin m';
                    Expected = @(
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin +';
                    Expected = @(
                        'HEAD',
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "+$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin +m';
                    Expected = @(
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "+$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin left:';
                    Expected = @(
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/main',
                        'ordinary/main',
                        'origin/main',
                        'initial'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "left:$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin left:m';
                    Expected = @(
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "left:$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'or';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'set-branches' {
        BeforeAll {
            Set-Variable Subcommand 'set-branches'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @(
                        @{
                            CompletionText = '--add';
                            ListItemText   = '--add';
                            ResultType     = 'ParameterName';
                            ToolTip        = "add branch";
                        },
                        @{
                            CompletionText = '--no-add';
                            ListItemText   = '--no-add';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] add branch";
                        }
                    )
                },
                @{
                    Line     = '--a';
                    Expected = @(
                        @{
                            CompletionText = '--add';
                            ListItemText   = '--add';
                            ResultType     = 'ParameterName';
                            ToolTip        = "add branch";
                        }
                    )
                },
                @{
                    Line     = '--no';
                    Expected = @(
                        @{
                            CompletionText = '--no-add';
                            ListItemText   = '--no-add';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] add branch";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrRefspec' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'origin ';
                    Expected = @(
                        'HEAD',
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin m';
                    Expected = @(
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin +';
                    Expected = @(
                        'HEAD',
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "+$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin +m';
                    Expected = @(
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "+$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin left:';
                    Expected = @(
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/main',
                        'ordinary/main',
                        'origin/main',
                        'initial'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "left:$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'origin left:m';
                    Expected = @(
                        'main'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "left:$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'or';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'get-url' {
        BeforeAll {
            Set-Variable Subcommand 'get-url'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--a';
                    Expected = @(
                        @{
                            CompletionText = '--all';
                            ListItemText   = '--all';
                            ResultType     = 'ParameterName';
                            ToolTip        = "return all URLs";
                        }
                    )
                },
                @{
                    Line     = '--no-a';
                    Expected = @(
                        @{
                            CompletionText = '--no-all';
                            ListItemText   = '--no-all';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] return all URLs";
                        }
                    )
                },
                @{
                    Line     = '--no';
                    Expected = @(
                        @{
                            CompletionText = '--no-push';
                            ListItemText   = '--no-push';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] query push URLs rather than fetch URLs";
                        },
                        @{
                            CompletionText = '--no-';
                            ListItemText   = '--no-...';
                            ResultType     = 'Text';
                            ToolTip        = "--no-...";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'set-url' {
        BeforeAll {
            Set-Variable Subcommand 'set-url'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--a';
                    Expected = @(
                        @{
                            CompletionText = '--add';
                            ListItemText   = '--add';
                            ResultType     = 'ParameterName';
                            ToolTip        = "add URL";
                        }
                    )
                },
                @{
                    Line     = '--no-a';
                    Expected = @(
                        @{
                            CompletionText = '--no-add';
                            ListItemText   = '--no-add';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] add URL";
                        }
                    )
                },
                @{
                    Line     = '--no';
                    Expected = @(
                        @{
                            CompletionText = '--no-push';
                            ListItemText   = '--no-push';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] manipulate push URLs";
                        },
                        @{
                            CompletionText = '--no-';
                            ListItemText   = '--no-...';
                            ResultType     = 'Text';
                            ToolTip        = "--no-...";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'show' {
        BeforeAll {
            Set-Variable Subcommand 'show'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-n';
                    ListItemText   = '-n';
                    ResultType     = 'ParameterName';
                    ToolTip        = "do not query remotes";
                },
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected = @(
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'update' {
        BeforeAll {
            Set-Variable Subcommand 'update'
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-p';
                    ListItemText   = '-p';
                    ResultType     = 'ParameterName';
                    ToolTip        = "prune remotes after fetching";
                },
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @(
                        @{
                            CompletionText = '--prune';
                            ListItemText   = '--prune';
                            ResultType     = 'ParameterName';
                            ToolTip        = "prune remotes after fetching";
                        },
                        @{
                            CompletionText = '--no-prune';
                            ListItemText   = '--no-prune';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] prune remotes after fetching";
                        }
                    )
                },
                @{
                    Line     = '--p';
                    Expected = @(
                        @{
                            CompletionText = '--prune';
                            ListItemText   = '--prune';
                            ResultType     = 'ParameterName';
                            ToolTip        = "prune remotes after fetching";
                        }
                    )
                },
                @{
                    Line     = '--no';
                    Expected = @(
                        @{
                            CompletionText = '--no-prune';
                            ListItemText   = '--no-prune';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] prune remotes after fetching";
                        }
                    )
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrGroup' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'origin d';
                    Expected = @(
                        'default'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'or or';
                    Expected = @(
                        'ordinary',
                        'origin',
                        'ors'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = 'or';
                    Expected = @(
                        'ordinary',
                        'origin',
                        'ors'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '';
                    Expected = @(
                        'grm',
                        'ordinary',
                        'origin',
                        'default',
                        'ors'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}
