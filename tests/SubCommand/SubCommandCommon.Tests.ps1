using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

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
            $expected = @(
                @{
                    CompletionText = "-n";
                    ListItemText   = "-n";
                    ResultType     = 'ParameterName';
                    ToolTip        = "show non-matching input paths";
                }, 
                @{
                    CompletionText = "-q";
                    ListItemText   = "-q";
                    ResultType     = 'ParameterName';
                    ToolTip        = "suppress progress reporting";
                }, 
                @{
                    CompletionText = "-v";
                    ListItemText   = "-v";
                    ResultType     = 'ParameterName';
                    ToolTip        = "be verbose";
                },
                @{
                    CompletionText = "-z";
                    ListItemText   = "-z";
                    ResultType     = 'ParameterName';
                    ToolTip        = "terminate input and output records by a NUL character";
                },
                @{
                    CompletionText = "-h";
                    ListItemText   = "-h";
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command $_ -" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'CommonOption' {
        It '<Line>' -ForEach @(
            @{
                Line     = "--q"
                Expected = @(
                    @{
                        CompletionText = "--quiet";
                        ListItemText   = "--quiet";
                        ResultType     = 'ParameterName';
                        ToolTip        = "suppress progress reporting";
                    }
                )
            },
            @{
                Line     = "--v"
                Expected = @(
                    @{
                        CompletionText = "--verbose";
                        ListItemText   = "--verbose";
                        ResultType     = 'ParameterName';
                        ToolTip        = "be verbose";
                    }
                )
            },
            @{
                Line     = "--no"
                Expected = @(
                    @{
                        CompletionText = "--non-matching";
                        ListItemText   = "--non-matching";
                        ResultType     = 'ParameterName';
                        ToolTip        = "show non-matching input paths";
                    },
                    @{
                        CompletionText = "--no-index";
                        ListItemText   = "--no-index";
                        ResultType     = 'ParameterName';
                        ToolTip        = "ignore index when checking";
                    },
                    @{
                        CompletionText = "--no-";
                        ListItemText   = "--no-...";
                        ResultType     = 'Text';
                        ToolTip        = "--no-...";
                    }
                )
            },
            @{
                Line     = "--no-"
                Expected = @(
                    @{
                        CompletionText = "--no-index";
                        ListItemText   = "--no-index";
                        ResultType     = 'ParameterName';
                        ToolTip        = "ignore index when checking";
                    },
                    @{
                        CompletionText = "--no-quiet";
                        ListItemText   = "--no-quiet";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] suppress progress reporting";
                    },
                    @{
                        CompletionText = "--no-verbose";
                        ListItemText   = "--no-verbose";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] be verbose";
                    },
                    @{
                        CompletionText = "--no-stdin";
                        ListItemText   = "--no-stdin";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] read file names from stdin";
                    },
                    @{
                        CompletionText = "--no-non-matching";
                        ListItemText   = "--no-non-matching";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] show non-matching input paths";
                    }   
                )
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}