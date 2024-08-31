using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | Convert-ToKebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Push-Location $rootPath
        git init --initial-branch=main
        git commit -m "initial" --allow-empty
        git branch brn

        $workTreePath1 = "$TestDrive/wkt".Replace('\', '/')
        $workTreePath2 = "$TestDrive/wkt2".Replace('\', '/')
        git worktree add -B wk $workTreePath1 2>$null
        git worktree add -B wt $workTreePath2 2>$null
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    It 'Subcommands:<Line>' -ForEach @(
        @{
            Line     = ""
            Expected = @(
                @{
                    CompletionText = 'add';
                    ListItemText   = 'add';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Create a worktree at <path> and checkout <commit-ish> into it';
                },
                @{
                    CompletionText = 'prune';
                    ListItemText   = 'prune';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Prune worktree information';
                },
                @{
                    CompletionText = 'list';
                    ListItemText   = 'list';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'List details of each worktree';
                },
                @{
                    CompletionText = 'lock';
                    ListItemText   = 'lock';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'lock it to prevent its administrative files from being pruned automatically';
                },
                @{
                    CompletionText = 'unlock';
                    ListItemText   = 'unlock';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Unlock a worktree';
                },
                @{
                    CompletionText = 'move';
                    ListItemText   = 'move';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Move a worktree to a new location';
                },
                @{
                    CompletionText = 'remove';
                    ListItemText   = 'remove';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Remove a worktree';
                },
                @{
                    CompletionText = 'repair';
                    ListItemText   = 'repair';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Repair worktree administrative files';
                }
            )
        },
        @{
            Line     = "re"
            Expected = @(
                @{
                    CompletionText = 'remove';
                    ListItemText   = 'remove';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Remove a worktree';
                },
                @{
                    CompletionText = 'repair';
                    ListItemText   = 'repair';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Repair worktree administrative files';
                }
            )
        }
    ) {
        "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
    }

    It 'ShortOptions:<Subcommand>' -ForEach @(
        @{
            Subcommand = "remove"
            Expected   = @(
                @{
                    CompletionText = "-f";
                    ListItemText   = "-f";
                    ResultType     = 'ParameterName';
                    ToolTip        = "force removal even if worktree is dirty or locked";
                },
                @{
                    CompletionText = "-h";
                    ListItemText   = "-h";
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
        },
        @{
            Subcommand = "repair"
            Expected   = @(
                @{
                    CompletionText = "-h";
                    ListItemText   = "-h";
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
        }
    ) {
        "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
    }

    
    Context 'WorktreePaths' {
        It '<_>' -ForEach @('lock', 'remove', 'unlock', 'move') {
            $expected = @(
                @{
                    CompletionText = $workTreePath1;
                    ListItemText   = $workTreePath1;
                    ResultType     = 'ParameterValue';
                    ToolTip        = $workTreePath1;
                },
                @{
                    CompletionText = $workTreePath2;
                    ListItemText   = $workTreePath2;
                    ResultType     = 'ParameterValue';
                    ToolTip        = $workTreePath2;
                }
            )
            "git $Command $_ " | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    $refs = @(
        @{
            CompletionText = 'HEAD';
            ListItemText   = 'HEAD';
            ResultType     = 'ParameterValue';
            ToolTip        = 'HEAD';
        },
        @{
            CompletionText = 'brn';
            ListItemText   = 'brn';
            ResultType     = 'ParameterValue';
            ToolTip        = 'brn';
        },
        @{
            CompletionText = 'main';
            ListItemText   = 'main';
            ResultType     = 'ParameterValue';
            ToolTip        = 'main';
        },
        @{
            CompletionText = 'wk';
            ListItemText   = 'wk';
            ResultType     = 'ParameterValue';
            ToolTip        = 'wk';
        },
        @{
            CompletionText = 'wt';
            ListItemText   = 'wt';
            ResultType     = 'ParameterValue';
            ToolTip        = 'wt';
        }
    )
    $brn = @(
        @{
            CompletionText = 'brn';
            ListItemText   = 'brn';
            ResultType     = 'ParameterValue';
            ToolTip        = 'brn';
        }
    )
    It '<Line>' -ForEach @(
        @{
            Line     = "add --re"
            Expected = @(
                @{
                    CompletionText = '--reason=';
                    ListItemText   = '--reason=';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'reason for locking'
                }
            )
        },
        @{
            Line     = "list --p"
            Expected = @(
                @{
                    CompletionText = '--porcelain';
                    ListItemText   = '--porcelain';
                    ResultType     = 'ParameterName';
                    ToolTip        = 'machine-readable output'
                }
            )
        },
        @{
            Line     = "add "
            Expected = @()
        },
        @{
            Line     = "add foo "
            Expected = $refs
        },
        @{
            Line     = "add foo b"
            Expected = $brn
        },
        @{
            Line     = "add -q "
            Expected = @()
        },
        @{
            Line     = "add --checkout "
            Expected = @()
        },
        @{
            Line     = "add -q bar "
            Expected = $refs
        },
        @{
            Line     = "add --checkout bar "
            Expected = $refs
        },
        @{
            Line     = "add -q bar b"
            Expected = $brn
        },
        @{
            Line     = "add --checkout bar b"
            Expected = $brn
        },
        @{
            Line     = "add --reason val "
            Expected = @()
        },
        @{
            Line     = "add --reason val bar "
            Expected = $refs
        },
        @{
            Line     = "add --reason val bar b"
            Expected = $brn
        },
        @{
            Line     = "add --reason=val "
            Expected = @()
        },
        @{
            Line     = "add --reason=val bar "
            Expected = $refs
        },
        @{
            Line     = "add --reason=val bar b"
            Expected = $brn
        },
        @{
            Line     = "add -b "
            Expected = $refs 
        },
        @{
            Line     = "add -B "
            Expected = $refs 
        },
        @{
            Line     = "add -b b"
            Expected = $brn
        },
        @{
            Line     = "add -B b"
            Expected = $brn
        },
        @{
            Line     = "move foo "
            Expected = @()
        }
    ) {
        "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
    }
}