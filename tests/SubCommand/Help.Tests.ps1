using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Push-Location $rootPath
        git init --initial-branch=main
        git config alias.sw "switch"
        git config alias.swf "sw -f"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe '<Command>' -ForEach @('help', '--help' | ForEach-Object { @{Command = $_ } }) {
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-a';
                ToolTip      = "print all available commands";
            },
            @{
                ListItemText = '-c';
                ToolTip      = "print all configuration variable names";
            },
            @{
                ListItemText = '-g';
                ToolTip      = "print list of useful guides";
            },
            @{
                ListItemText = '-i';
                ToolTip      = "show info page";
            },
            @{
                ListItemText = '-m';
                ToolTip      = "show man page";
            },
            @{
                ListItemText = '-v';
                ToolTip      = "print command description";
            },
            @{
                ListItemText = '-w';
                ToolTip      = "show manual in web browser";
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
                    Line     = '--al';
                    Expected = @{
                        ListItemText = '--all';
                        ToolTip      = "print all available commands";
                    },
                    @{
                        ListItemText = '--aliases';
                        ToolTip      = "show aliases in --all";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--config';
                        ToolTip      = "print all configuration variable names";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-v';
                    Expected = @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] print command description";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-external-commands';
                        ToolTip      = "[NO] show external commands in --all";
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

        Describe 'Commands' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'sw';
                    Expected =
                    @{
                        ListItemText = "switch";
                        ToolTip      = "Switch branches";
                    },
                    @{
                        ListItemText = "sw";
                        ToolTip      = "[alias] switch";
                    },
                    @{
                        ListItemText = "swf";
                        ToolTip      = "[alias] sw -f";
                    } | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}