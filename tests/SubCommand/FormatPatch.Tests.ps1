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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip "don't print the patch filenames"
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip "don't print the patch filenames"
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

        Describe-Revlist {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-k';
            ToolTip      = "don't strip/add [PATCH]";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "use [PATCH n/m] even with a single patch";
        },
        @{
            ListItemText = '-N';
            ToolTip      = "use [PATCH] even with multiple patches";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "store resulting files in <dir>";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "show patch format instead of default (patch + stat)";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "don't print the patch filenames";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "add a Signed-off-by trailer";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "mark the series as Nth re-roll";
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
                Line     = '--a';
                Expected = '--all',
                @{
                    ListItemText = '--add-header=';
                    ToolTip      = "add email header";
                },
                @{
                    ListItemText = '--attach';
                    ToolTip      = "attach the patch";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--t';
                Expected = @{
                    ListItemText = '--to=';
                    ToolTip      = "add To: header";
                },
                @{
                    ListItemText = '--thread';
                    ToolTip      = "enable message threading, styles: shallow, deep";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-t';
                Expected = @{
                    ListItemText = '--no-to';
                    ToolTip      = "[NO] add To: header";
                },
                @{
                    ListItemText = '--no-thread';
                    ToolTip      = "[NO] enable message threading, styles: shallow, deep";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                
                Line     = '--no';
                Expected = '--no-prefix',
                '--not',
                '--notes',
                @{
                    ListItemText = '--no-numbered';
                    ToolTip      = "use [PATCH] even with multiple patches";
                },
                @{
                    ListItemText = '--no-binary';
                    ToolTip      = "don't output binary diffs";
                },
                @{
                    ListItemText = '--no-stat';
                    ToolTip      = "show patch format instead of default (patch + stat)";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text';
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        Describe '<Option>' -ForEach @('--base', '--interdiff', '--range-diff' | ForEach-Object { @{Option = $_ } }) {
            Describe-Revlist -Ref {
                "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $Expected
            }

            Describe-Revlist -Ref -CompletionPrefix "$Option=" {
                "git $Command $Option=$Line" | Complete-FromLine | Should -BeCompletion $Expected
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--thread=';
                Expected = 'deep', 'shallow' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--thread=$_" }
            },
            @{
                Line     = '--thread=d';
                Expected = 'deep' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--thread=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}