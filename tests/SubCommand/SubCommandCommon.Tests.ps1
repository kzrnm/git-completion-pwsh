using namespace System.Collections.Generic;

. "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'SubCommandCommon-check-ignore' {
    BeforeAll {
        Set-Variable 'Command' check-ignore
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }


    Describe 'ShortOptions' {
        It '<_>' -ForEach @('', 'foo') {
            $expected = @{
                ListItemText = "-n";
                ToolTip      = "show non-matching input paths";
            }, 
            @{
                ListItemText = "-q";
                ToolTip      = "suppress progress reporting";
            }, 
            @{
                ListItemText = "-v";
                ToolTip      = "be verbose";
            },
            @{
                ListItemText = "-z";
                ToolTip      = "terminate input and output records by a NUL character";
            },
            @{
                ListItemText = "-h";
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $_ -" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'CommonOption' {
        It '<Line>' -ForEach @(
            @{
                Line     = "--q"
                Expected = "--quiet" | ConvertTo-Completion -ResultType ParameterName -ToolTip "suppress progress reporting";
            },
            @{
                Line     = "--v"
                Expected = "--verbose" | ConvertTo-Completion -ResultType ParameterName -ToolTip "be verbose";
            },
            @{
                Line     = "--no"
                Expected = @{
                    ListItemText = "--non-matching";
                    ToolTip      = "show non-matching input paths";
                },
                @{
                    ListItemText = "--no-index";
                    ToolTip      = "ignore index when checking";
                }, @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text'
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = "--no-"
                Expected = @{
                    ListItemText = "--no-index";
                    ToolTip      = "ignore index when checking";
                },
                @{
                    ListItemText = "--no-quiet";
                    ToolTip      = "[NO] suppress progress reporting";
                },
                @{
                    ListItemText = "--no-verbose";
                    ToolTip      = "[NO] be verbose";
                },
                @{
                    ListItemText = "--no-stdin";
                    ToolTip      = "[NO] read file names from stdin";
                },
                @{
                    ListItemText = "--no-non-matching";
                    ToolTip      = "[NO] show non-matching input paths";
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}