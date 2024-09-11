# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress informational messages'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress informational messages'
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
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe-Revlist -Ref {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-a';
            ToolTip      = "list both remote-tracking and local branches";
        },
        @{
            ListItemText = '-c';
            ToolTip      = "copy a branch and its reflog";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "copy a branch, even if target exists";
        },
        @{
            ListItemText = '-d';
            ToolTip      = "delete fully merged branch";
        },
        @{
            ListItemText = '-D';
            ToolTip      = "delete branch (even if not merged)";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force creation, move/rename, deletion";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "sorting and filtering are case insensitive";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "list branch names";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "move/rename a branch and its reflog";
        },
        @{
            ListItemText = '-M';
            ToolTip      = "move/rename a branch, even if target exists";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "suppress informational messages";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "act on remote-tracking branches";
        },
        @{
            ListItemText = '-t';
            ToolTip      = "set branch tracking configuration";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "change the upstream info";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "show hash and subject, give twice for upstream branch";
        },
        @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--v';
                Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip "show hash and subject, give twice for upstream branch"
            },
            @{
                Line     = '--m';
                Expected = 
                @{
                    ListItemText = '--move';
                    ToolTip      = "move/rename a branch and its reflog"
                },
                @{
                    ListItemText = '--merged';
                    ToolTip      = "print only branches that are merged"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-m';
                Expected = 
                @{
                    ListItemText = '--no-merged';
                    ToolTip      = "print only branches that are not merged"
                },
                @{
                    ListItemText = '--no-move';
                    ToolTip      = "[NO] move/rename a branch and its reflog"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-contains';
                    ToolTip      = "print only branches that don't contain the commit"
                },
                @{
                    ListItemText = '--no-merged';
                    ToolTip      = "print only branches that are not merged"
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text'
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--set-upstream-to=';
                Expected =
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/develop',
                'ordinary/develop',
                'origin/develop',
                'initial',
                'zeta' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--set-upstream-to=$_" }
            },
            @{
                Line     = '--set-upstream-to=o';
                Expected =
                'ordinary/develop',
                'origin/develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--set-upstream-to=$_" }
            },
            @{
                Line     = '--set-upstream-to=^';
                Expected =
                '^HEAD',
                '^FETCH_HEAD',
                '^main',
                '^grm/develop',
                '^ordinary/develop',
                '^origin/develop',
                '^initial',
                '^zeta' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--set-upstream-to=$_" }
            },
            @{
                Line     = '--set-upstream-to=^o';
                Expected =
                '^ordinary/develop',
                '^origin/develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--set-upstream-to=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe-Revlist -Ref {
            "git $Command --set-upstream-to $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist -Ref

    Describe 'OnlyLocalRef' {
        Describe '<Option>' -ForEach @(
            '-d', '-D', '--delete', '-m', '-M', '--move', '-c', '-C', '--copy' | ForEach-Object { @{Option = "$_"; } }
        ) {
            It 'Left' {
                $Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
                "git $Command $Option " | Complete-FromLine | Should -BeCompletion $expected
            }

            It 'Right' {
                $Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
                "git $Command " | Complete-FromLine -Right " $Option" | Should -BeCompletion $expected
            }

            It 'Remote:<Remote>' -ForEach @('--remotes', '-r' | ForEach-Object { @{Remote = $_; } }) {
                $Expected =
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/develop',
                'ordinary/develop',
                'origin/develop',
                'initial',
                'zeta' | ConvertTo-Completion -ResultType ParameterValue
                "git $Command $Remote $Option " | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'RemoteShort' -ForEach @(
            'd', 'D', 'm', 'M', 'c', 'C' | ForEach-Object { 
                @{Option = "-r$_"; },
                @{Option = "-$_r"; }
            }
        ) {
            $Expected =
            'HEAD',
            'FETCH_HEAD',
            'main',
            'grm/develop',
            'ordinary/develop',
            'origin/develop',
            'initial',
            'zeta' | ConvertTo-Completion -ResultType ParameterValue
            "git $Command $Option " | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}