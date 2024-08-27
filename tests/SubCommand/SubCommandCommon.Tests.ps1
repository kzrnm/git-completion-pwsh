using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'SubCommandCommon-ls-files' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }


    It 'ShortOptions' {
        "git ls-files -" | Complete-FromLine | Should -BeCompletion @(
            @{
                CompletionText = "-c";
                ListItemText   = "-c";
                ResultType     = 'ParameterName';
                ToolTip        = "show cached files in the output (default)";
            }, 
            @{
                CompletionText = "-d";
                ListItemText   = "-d";
                ResultType     = 'ParameterName';
                ToolTip        = "show deleted files in the output";
            }, 
            @{
                CompletionText = "-f";
                ListItemText   = "-f";
                ResultType     = 'ParameterName';
                ToolTip        = "use lowercase letters for 'fsmonitor clean' files";
            }, 
            @{
                CompletionText = "-i";
                ListItemText   = "-i";
                ResultType     = 'ParameterName';
                ToolTip        = "show ignored files in the output";
            }, 
            @{
                CompletionText = "-k";
                ListItemText   = "-k";
                ResultType     = 'ParameterName';
                ToolTip        = "show files on the filesystem that need to be removed";
            }, 
            @{
                CompletionText = "-m";
                ListItemText   = "-m";
                ResultType     = 'ParameterName';
                ToolTip        = "show modified files in the output";
            }, 
            @{
                CompletionText = "-o";
                ListItemText   = "-o";
                ResultType     = 'ParameterName';
                ToolTip        = "show other files in the output";
            }, 
            @{
                CompletionText = "-s";
                ListItemText   = "-s";
                ResultType     = 'ParameterName';
                ToolTip        = "show staged contents' object name in the output";
            }, 
            @{
                CompletionText = "-t";
                ListItemText   = "-t";
                ResultType     = 'ParameterName';
                ToolTip        = "identify the file status with tags";
            }, 
            @{
                CompletionText = "-u";
                ListItemText   = "-u";
                ResultType     = 'ParameterName';
                ToolTip        = "show unmerged files in the output";
            }, 
            @{
                CompletionText = "-v";
                ListItemText   = "-v";
                ResultType     = 'ParameterName';
                ToolTip        = "use lowercase letters for 'assume unchanged' files";
            }, 
            @{
                CompletionText = "-x";
                ListItemText   = "-x";
                ResultType     = 'ParameterName';
                ToolTip        = "skip files matching pattern";
            }, 
            @{
                CompletionText = "-X";
                ListItemText   = "-X";
                ResultType     = 'ParameterName';
                ToolTip        = "read exclude patterns from <file>";
            },
            @{
                CompletionText = "-z";
                ListItemText   = "-z";
                ResultType     = 'ParameterName';
                ToolTip        = "separate paths with the NUL character";
            },
            @{
                CompletionText = "-h";
                ListItemText   = "-h";
                ResultType     = 'ParameterName';
                ToolTip        = "show help";
            }
        )
    }

    
    Describe 'CommonOption' {
        It '<Line>' -ForEach @(
            @{
                Line     = "--n"
                Expected = @(
                    @{
                        CompletionText = "--no-cached";
                        ListItemText   = "--no-cached";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] show cached files in the output (default)";
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
                Line     = "--ign"
                Expected = @(
                    @{
                        CompletionText = "--ignored";
                        ListItemText   = "--ignored";
                        ResultType     = 'ParameterName';
                        ToolTip        = "show ignored files in the output";
                    }
                )
            },
            @{
                Line     = "--no-ign"
                Expected = @(
                    @{
                        CompletionText = "--no-ignored";
                        ListItemText   = "--no-ignored";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] show ignored files in the output";
                    }
                )
            }
        ) {
            "git ls-files $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}