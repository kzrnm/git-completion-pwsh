# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        $ErrorActionPreference = 'SilentlyContinue'
        mkdir ($rootPath = "$TestDrive/gitRoot")
        Push-Location $rootPath
        git init --initial-branch=main
        git commit -m "initial" --allow-empty
        git branch brn

        $workTreePath1 = "$TestDrive/wkt".Replace('\', '/')
        $workTreePath2 = "$TestDrive/wkt2".Replace('\', '/')
        git worktree add -B wk $workTreePath1 2>$null
        git worktree add -B wt $workTreePath2 2>$null

        $headCommit = git show -s brn --oneline --no-decorate
        function replace-Tooltip {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
            param ([Parameter(ValueFromPipeline)] $Object)

            process {
                if ($Object.ListItemText -in 'HEAD', 'main', 'brn', 'wk', 'wt') {
                    $Object.ToolTip = $headCommit
                }
                $Object
            }
        }
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    $refs = @{
        ListItemText = 'HEAD';
        ToolTip      = '4de2038 initial';
    },
    @{
        ListItemText = 'brn';
        ToolTip      = '4de2038 initial';
    },
    @{
        ListItemText = 'main';
        ToolTip      = '4de2038 initial';
    },
    @{
        ListItemText = 'wk';
        ToolTip      = '4de2038 initial';
    },
    @{
        ListItemText = 'wt';
        ToolTip      = '4de2038 initial';
    } | ConvertTo-Completion -ResultType ParameterValue
    $brn = @{
        ListItemText = 'brn';
        ToolTip      = '4de2038 initial';
    } | ConvertTo-Completion -ResultType ParameterValue

    Describe 'Subcommands' {
        It '<Line>' -ForEach @(
            @{
                Line     = ""
                Expected = @{
                    ListItemText = 'add';
                    ToolTip      = 'create a worktree at <path> and checkout <commit-ish> into it';
                },
                @{
                    ListItemText = 'prune';
                    ToolTip      = 'prune worktree information';
                },
                @{
                    ListItemText = 'list';
                    ToolTip      = 'list details of each worktree';
                },
                @{
                    ListItemText = 'lock';
                    ToolTip      = 'lock it to prevent its administrative files from being pruned automatically';
                },
                @{
                    ListItemText = 'unlock';
                    ToolTip      = 'unlock a worktree';
                },
                @{
                    ListItemText = 'move';
                    ToolTip      = 'move a worktree to a new location';
                },
                @{
                    ListItemText = 'remove';
                    ToolTip      = 'remove a worktree';
                },
                @{
                    ListItemText = 'repair';
                    ToolTip      = 'repair worktree administrative files';
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = "re"
                Expected = @{
                    ListItemText = 'remove';
                    ToolTip      = 'remove a worktree';
                },
                @{
                    ListItemText = 'repair';
                    ToolTip      = 'repair worktree administrative files';
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = 'add --re';
                    Right    = ' --';
                    Expected = @{
                        ListItemText = '--reason='; 
                        ToolTip      = 'reason for locking';
                    },
                    @{
                        ListItemText = '--relative-paths';
                        ToolTip      = 'use relative paths for worktrees';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Left     = 'add --re';
                    Right    = ' -- --all';
                    Expected = @{
                        ListItemText = '--reason='; 
                        ToolTip      = 'reason for locking';
                    },
                    @{
                        ListItemText = '--relative-paths';
                        ToolTip      = 'use relative paths for worktrees';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Left     = 'prune --ver';
                    Right    = ' --';
                    Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'report pruned working trees'
                },
                @{
                    Left     = 'prune --ver';
                    Right    = ' -- --all';
                    Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'report pruned working trees'
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
                Expected = @()
            },
            @{
                Line     = 'src -- --';
                Expected = @()
            },
            @{
                Line     = 'src -- ';
                Expected = @()
            },
            @{
                Line     = '-- ';
                Expected = @()
            },
            @{
                Line     = 'add -- -';
                Expected = @()
            },
            @{
                Line     = 'add -- ';
                Expected = @()
            },
            @{
                Line     = 'add src -- ';
                Expected = $refs
            },
            @{
                Line     = 'add -- src ';
                Expected = $refs
            },
            @{
                Line     = 'add -- -b ';
                Expected = $refs
            },
            @{
                Line     = 'add -- --reason ';
                Expected = $refs
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion ($Expected | replace-Tooltip)
        }
    }

    Describe 'ShortOptions' {
        It '<Subcommand>' -ForEach @(
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
    }

    Describe 'Files' {
        It '<_>' -ForEach @('prune', 'list', 'repair') {
            $expected = @()
            "git $Command $_ " | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'WorktreePaths' {
        Describe '<Subcommand>' -ForEach @('lock', 'remove', 'unlock', 'move' | ForEach-Object { @{Subcommand = $_ } }) {
            It 'DoubleDash' {
                $expected = @("$workTreePath1", "$workTreePath2") | ConvertTo-Completion -ResultType ParameterValue
                "git $Command $Subcommand -- " | Complete-FromLine | Should -BeCompletion $expected
            }

            It '_' {
                $expected = @("$workTreePath1", "$workTreePath2") | ConvertTo-Completion -ResultType ParameterValue
                "git $Command $Subcommand " | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    It '<Line>' -ForEach @(
        @{
            Line     = "add --re"
            Expected = @{
                ListItemText = '--reason='; 
                ToolTip      = 'reason for locking';
            },
            @{
                ListItemText = '--relative-paths';
                ToolTip      = 'use relative paths for worktrees';
            } | ConvertTo-Completion -ResultType ParameterName
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
        },
        @{
            Line     = "move foo -- "
            Expected = @()
        },
        @{
            Line     = "move -- foo "
            Expected = @()
        }
    ) {
        "git $Command $Line" | Complete-FromLine | Should -BeCompletion ($expected | replace-Tooltip)
    }
}