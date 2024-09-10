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
                    Left     = '--list';
                    Right    = ' --';
                    Expected = '--list' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'list replace refs'
                },
                @{
                    Left     = '--list';
                    Right    = ' -- --all';
                    Expected = '--list' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'list replace refs'
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
        $Expected = @{
            ListItemText = '-d';
            ToolTip      = "delete replace refs";
        },
        @{
            ListItemText = '-e';
            ToolTip      = "edit existing object";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "replace the ref if it exists";
        },
        @{
            ListItemText = '-g';
            ToolTip      = "change a commit's parents";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "list replace refs";
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
                Line     = '--';
                Expected = @{
                    ListItemText = '--list';
                    ToolTip      = "list replace refs";
                },
                @{
                    ListItemText = '--delete';
                    ToolTip      = "delete replace refs";
                },
                @{
                    ListItemText = '--edit';
                    ToolTip      = "edit existing object";
                },
                @{
                    ListItemText = '--graft';
                    ToolTip      = "change a commit's parents";
                },
                @{
                    ListItemText = '--convert-graft-file';
                    ToolTip      = "convert existing graft file";
                },
                @{
                    ListItemText = '--raw';
                    ToolTip      = "do not pretty-print contents for --edit";
                },
                @{
                    ListItemText = '--format=';
                    ToolTip      = "use this format";
                },
                @{
                    ListItemText = '--no-raw';
                    ToolTip      = "[NO] do not pretty-print contents for --edit";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text';
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--d';
                Expected = @{
                    ListItemText = '--delete';
                    ToolTip      = "delete replace refs";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--r';
                Expected = @{
                    ListItemText = '--raw';
                    ToolTip      = "do not pretty-print contents for --edit";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-f';
                Expected = @{
                    ListItemText = '--no-format';
                    ToolTip      = "[NO] use this format";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-r';
                Expected = @{
                    ListItemText = '--no-raw';
                    ToolTip      = "[NO] do not pretty-print contents for --edit";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-raw';
                    ToolTip      = "[NO] do not pretty-print contents for --edit";
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

    Describe-Revlist -Ref
}