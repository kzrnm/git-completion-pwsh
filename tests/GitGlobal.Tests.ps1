BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.Replace('\', '/').LastIndexOf('tests')))/tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'GirGlobal' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
        git config alias.sw "switch"
        git config alias.swf "switch -f"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }
    It '<line>' -ForEach @(
        @{
            Line     = "--ver";
            Expected = @(
                @{
                    CompletionText = "--version";
                    ListItemText   = "--version";
                    ResultType     = "ParameterName";
                    ToolTip        = "Prints the Git suite version.";
                }
            )
        },
        @{
            Line     = "--attr-sourc";
            Expected = @(
                @{
                    CompletionText = "--attr-source";
                    ListItemText   = "--attr-source <tree-ish>";
                    ResultType     = "ParameterName";
                    ToolTip        = "Read gitattributes from <tree-ish> instead of the worktree.";
                }
            )
        },
        @{
            Line     = "-";
            Expected = @(
                @{
                    CompletionText = "-v";
                    ListItemText   = "-v";
                    ResultType     = "ParameterName";
                    ToolTip        = "Prints the Git suite version.";
                },
                @{
                    CompletionText = "-h";
                    ListItemText   = "-h";
                    ResultType     = "ParameterName";
                    ToolTip        = "Prints the helps. If --all is given then all available commands are printed.";
                },
                @{
                    CompletionText = "-C";
                    ListItemText   = "-C <path>";
                    ResultType     = "ParameterName";
                    ToolTip        = "Run as if git was started in <path> instead of the current working directory.";
                },
                @{
                    CompletionText = "-c";
                    ListItemText   = "-c <name>=<value>";
                    ResultType     = "ParameterName";
                    ToolTip        = "Pass a configuration parameter to the command.";
                },
                @{
                    CompletionText = "-p";
                    ListItemText   = "-p";
                    ResultType     = "ParameterName";
                    ToolTip        = 'Pipe all output into less (or if set, $PAGER) if standard output is a terminal.';
                },
                @{
                    CompletionText = "-P";
                    ListItemText   = "-P";
                    ResultType     = "ParameterName";
                    ToolTip        = "Do not pipe Git output into a pager.";
                }
            )
        },
        @{
            Line     = "sw";
            Expected = @(
                @{
                    CompletionText = "sw";
                    ListItemText   = "sw";
                    ResultType     = "Text";
                    ToolTip        = "[alias] switch";
                },
                @{
                    CompletionText = "swf";
                    ListItemText   = "swf";
                    ResultType     = "Text";
                    ToolTip        = "[alias] switch -f";
                },
                @{
                    CompletionText = "switch";
                    ListItemText   = "switch";
                    ResultType     = "Text";
                    ToolTip        = "Switch branches";
                }
            );
        },
        @{
            Line     = "--notmatch";
            Expected = @();
        }
    ) {
        "git $line" | Complete-FromLine | Should -BeCompletion $expected
    }
}
