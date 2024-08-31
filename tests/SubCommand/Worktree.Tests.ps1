using namespace System.Collections.Generic;

. "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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
            Expected = @{
                ListItemText = 'add';
                ToolTip      = 'Create a worktree at <path> and checkout <commit-ish> into it';
            },
            @{
                ListItemText = 'prune';
                ToolTip      = 'Prune worktree information';
            },
            @{
                ListItemText = 'list';
                ToolTip      = 'List details of each worktree';
            },
            @{
                ListItemText = 'lock';
                ToolTip      = 'lock it to prevent its administrative files from being pruned automatically';
            },
            @{
                ListItemText = 'unlock';
                ToolTip      = 'Unlock a worktree';
            },
            @{
                ListItemText = 'move';
                ToolTip      = 'Move a worktree to a new location';
            },
            @{
                ListItemText = 'remove';
                ToolTip      = 'Remove a worktree';
            },
            @{
                ListItemText = 'repair';
                ToolTip      = 'Repair worktree administrative files';
            } | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Line     = "re"
            Expected = @{
                ListItemText = 'remove';
                ToolTip      = 'Remove a worktree';
            },
            @{
                ListItemText = 'repair';
                ToolTip      = 'Repair worktree administrative files';
            } | ConvertTo-Completion -ResultType ParameterName
        }
    ) {
        "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
    }

    It 'ShortOptions:<Subcommand>' -ForEach @(
        @{
            Subcommand = "remove"
            Expected   = @{
                ListItemText = '-f';
                ToolTip      = 'force removal even if worktree is dirty or locked';
            },
            @{
                ListItemText = '-h';
                ToolTip      = 'show help';
            } | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Subcommand = "repair"
            Expected   = @{
                ListItemText = '-h';
                ToolTip      = 'show help';
            } | ConvertTo-Completion -ResultType ParameterName
        }
    ) {
        "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'WorktreePaths' {
        It '<_>' -ForEach @('lock', 'remove', 'unlock', 'move') {
            $expected = @("$workTreePath1", "$workTreePath2") | ConvertTo-Completion -ResultType ParameterValue
            "git $Command $_ " | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    $refs = 'HEAD', 'brn', 'main', 'wk', 'wt' | ConvertTo-Completion -ResultType ParameterValue
    $brn = 'brn' | ConvertTo-Completion -ResultType ParameterValue
    It '<Line>' -ForEach @(
        @{
            Line     = "add --re"
            Expected = @(
                '--reason=' | ConvertTo-Completion -ResultType ParameterName `
                    -ToolTip 'reason for locking'
            )
        },
        @{
            Line     = "list --p"
            Expected = @(
                '--porcelain' | ConvertTo-Completion -ResultType ParameterName `
                    -ToolTip 'machine-readable output'
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