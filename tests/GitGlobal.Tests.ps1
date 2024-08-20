BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
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
        git config alias.swf "sw -f"
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
                    ResultType     = 'ParameterName';
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
                    ResultType     = 'ParameterName';
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
                    ResultType     = 'ParameterName';
                    ToolTip        = "Prints the Git suite version.";
                },
                @{
                    CompletionText = "-h";
                    ListItemText   = "-h";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Prints the helps. If --all is given then all available commands are printed.";
                },
                @{
                    CompletionText = "-C";
                    ListItemText   = "-C <path>";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Run as if git was started in <path> instead of the current working directory.";
                },
                @{
                    CompletionText = "-c";
                    ListItemText   = "-c <name>=<value>";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Pass a configuration parameter to the command.";
                },
                @{
                    CompletionText = "-p";
                    ListItemText   = "-p";
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Pipe all output into less (or if set, $PAGER) if standard output is a terminal.';
                },
                @{
                    CompletionText = "-P";
                    ListItemText   = "-P";
                    ResultType     = 'ParameterName';
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
                    ToolTip        = "[alias] sw -f";
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

    Describe 'GIT_COMPLETION_SHOW_ALL_COMMANDS' {
        Describe 'False' {
            It '<Text>' -ForEach @(
                @{
                    Text  = '0';
                    Value = '0';
                },
                @{
                    Text  = '$null';
                    Value = $null;
                }
            ) {
                $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = $Value
                "git diff" | Complete-FromLine | Should -BeCompletion @(
                    @{
                        CompletionText = "diff";
                        ListItemText   = "diff";
                        ResultType     = 'Text';
                        ToolTip        = "Show changes between commits, commit and working tree, etc";
                    },
                    @{
                        CompletionText = "difftool";
                        ListItemText   = "difftool";
                        ResultType     = 'Text';
                        ToolTip        = "difftool";
                    }
                )
            }
        }
        Describe 'True' {
            It '<Value>' -ForEach @(
                @{
                    Value = '1';
                },
                @{
                    Value = 'any';
                }
            ) {
                $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = $Value
                "git diff" | Complete-FromLine | Should -BeCompletion @(
                    @{
                        CompletionText = "diff";
                        ListItemText   = "diff";
                        ResultType     = 'Text';
                        ToolTip        = "Show changes between commits, commit and working tree, etc";
                    },
                    @{
                        CompletionText = "difftool";
                        ListItemText   = "difftool";
                        ResultType     = 'Text';
                        ToolTip        = "difftool";
                    },
                    @{
                        CompletionText = "diff-files";
                        ListItemText   = "diff-files";
                        ResultType     = 'Text';
                        ToolTip        = "diff-files";
                    },
                    @{
                        CompletionText = "diff-index";
                        ListItemText   = "diff-index";
                        ResultType     = 'Text';
                        ToolTip        = "diff-index";
                    },
                    @{
                        CompletionText = "diff-tree";
                        ListItemText   = "diff-tree";
                        ResultType     = 'Text';
                        ToolTip        = "diff-tree";
                    }
                )
            }
        }
        
        AfterAll {
            $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = ''
        }
    }
}
