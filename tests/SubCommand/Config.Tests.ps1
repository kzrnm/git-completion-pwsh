BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'Config' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
        git config alias.sw "switch"
        git config alias.swf "sw -f"
        git config --file test.config alias.ll "!ls"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'Git2.46.0' {
        BeforeAll {
            InModuleScope git-completion {
                Mock gitVersion { return [version]::new(2, 46, 0) }
                Mock gitResolveBuiltinsImpl {
                    if ($Command.Length -lt 2) {
                        return 'list get set unset rename-section remove-section edit'
                    }
                    else {
                        switch ($Command[1]) {
                            'list' { ' --global --system --local --worktree --file= --blob= --null --name-only --show-origin --show-scope --show-names --type= --bool --int --bool-or-int --bool-or-str --path --expiry-date --includes --no-global -- --no-system --no-local --no-worktree --no-file --no-blob --no-null --no-name-only --no-show-origin --no-show-scope --no-show-names --no-type --no-includes' }
                            'get' { ' --global --system --local --worktree --file= --blob= --all --regexp --value= --fixed-value --url= --null --name-only --show-origin --show-scope --show-names --type= --bool --int --bool-or-int --bool-or-str --path --expiry-date --includes --default= --no-global -- --no-system --no-local --no-worktree --no-file --no-blob --no-all --no-regexp --no-value --no-fixed-value --no-url --no-null --no-name-only --no-show-origin --no-show-scope --no-show-names --no-type --no-includes --no-default' }
                            'set' { ' --global --system --local --worktree --file= --blob= --type= --bool --int --bool-or-int --bool-or-str --path --expiry-date --all --value= --fixed-value --comment= --append --no-global -- --no-system --no-local --no-worktree --no-file --no-blob --no-type --no-all --no-value --no-fixed-value --no-comment --no-append' }
                            'unset' { ' --global --system --local --worktree --file= --blob= --all --value= --fixed-value --no-global -- --no-system --no-local --no-worktree --no-file --no-blob --no-all --no-value --no-fixed-value' }
                            'rename-section' { ' --global --system --local --worktree --file= --blob= --no-global -- --no-system --no-local --no-worktree --no-file --no-blob' }
                            'remove-section' { ' --global --system --local --worktree --file= --blob= --no-global -- --no-system --no-local --no-worktree --no-file --no-blob' }
                            'edit' { ' --global --system --local --worktree --file= --blob= --no-global -- --no-system --no-local --no-worktree --no-file --no-blob' }
                            Default { '' }
                        }
                    }
                } -ParameterFilter { 
                    $Command[0] -eq 'config'
                }
            }
        }

        It 'ShortOptions' {
            "git config -" | Complete-FromLine | Should -BeCompletion @(
                @{
                    CompletionText = "-e";
                    ListItemText   = "-e";
                    ResultType     = 'ParameterName';
                    ToolTip        = "open an editor";
                },
                @{
                    CompletionText = "-f";
                    ListItemText   = "-f";
                    ResultType     = 'ParameterName';
                    ToolTip        = "use given config file";
                },
                @{
                    CompletionText = "-l";
                    ListItemText   = "-l";
                    ResultType     = 'ParameterName';
                    ToolTip        = "list all";
                },
                @{
                    CompletionText = "-z";
                    ListItemText   = "-z";
                    ResultType     = 'ParameterName';
                    ToolTip        = "terminate values with NUL byte";
                }
            )
        }

        Describe 'Subcommand' {
            It '<Line>' -ForEach @(
                @{
                    Line     = ''
                    Expected = @(
                        @{
                            CompletionText = 'list';
                            ListItemText   = 'list';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'List all variables set in config file.';
                        },
                        @{
                            CompletionText = 'get';
                            ListItemText   = 'get';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'Emits the value of the specified key.';
                        },
                        @{
                            CompletionText = 'set';
                            ListItemText   = 'set';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'Set value for one or more config options.';
                        },
                        @{
                            CompletionText = 'unset';
                            ListItemText   = 'unset';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'Unset value for one or more config options.';
                        },
                        @{
                            CompletionText = 'rename-section';
                            ListItemText   = 'rename-section';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'Rename the given section to a new name.';
                        },
                        @{
                            CompletionText = 'remove-section';
                            ListItemText   = 'remove-section';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'Remove the given section from the configuration file.';
                        },
                        @{
                            CompletionText = 'edit';
                            ListItemText   = 'edit';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'Opens an editor to modify the specified config file.';
                        }
                    )
                },
                @{
                    Line     = 's'
                    Expected = @(
                        @{
                            CompletionText = 'set';
                            ListItemText   = 'set';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'Set value for one or more config options.';
                        }
                    )
                }
            ) {
                "git config $Line" | Complete-FromLine | Should -BeCompletion $Expected
            }
        }

        Describe 'CommonOption' {
            Context '<Line>' -ForEach @(
                @{
                    Line     = "--lo"
                    Expected = @(
                        @{
                            CompletionText = "--local";
                            ListItemText   = "--local";
                            ResultType     = 'ParameterName';
                            ToolTip        = "use repository config file";
                        }
                    )
                },
                @{
                    Line     = "--glo"
                    Expected = @(
                        @{
                            CompletionText = "--global";
                            ListItemText   = "--global";
                            ResultType     = 'ParameterName';
                            ToolTip        = "use global config file";
                        }
                    )
                },
                @{
                    Line     = "--no-glo"
                    Expected = @(
                        @{
                            CompletionText = "--no-global";
                            ListItemText   = "--no-global";
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] use global config file";
                        }
                    )
                }
            ) {
                It '<_>' -ForEach @(
                    "list", "get", "set", "unset",
                    "rename-section", "remove-section", "edit"
                ) {
                    $Subcommand = $_ 
                    "git config $Subcommand $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        
        Describe 'VariableSubcommand' {
            Context '<Option> <Line>' -ForEach @(
                @{
                    Option   = ""
                    Line     = "ali"
                    Expected = @(
                        @{
                            CompletionText = "alias.sw";
                            ListItemText   = "alias.sw";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.sw";
                        },
                        @{
                            CompletionText = "alias.swf";
                            ListItemText   = "alias.swf";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.swf";
                        }
                    )
                },
                @{
                    Option   = "--local"
                    Line     = "ali"
                    Expected = @(
                        @{
                            CompletionText = "alias.sw";
                            ListItemText   = "alias.sw";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.sw";
                        },
                        @{
                            CompletionText = "alias.swf";
                            ListItemText   = "alias.swf";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.swf";
                        }
                    )
                },
                @{
                    Option   = "--file test.config"
                    Line     = ""
                    Expected = @(
                        @{
                            CompletionText = "alias.ll";
                            ListItemText   = "alias.ll";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.ll";
                        }
                    )
                },
                @{
                    Option   = "--file=test.config"
                    Line     = ""
                    Expected = @(
                        @{
                            CompletionText = "alias.ll";
                            ListItemText   = "alias.ll";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.ll";
                        }
                    )
                },
                @{
                    Option   = "-f test.config"
                    Line     = ""
                    Expected = @(
                        @{
                            CompletionText = "alias.ll";
                            ListItemText   = "alias.ll";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.ll";
                        }
                    )
                }
            ) {
                It '<_>' -ForEach @('get', 'unset') {
                    $Subcommand = $_ 
                    "git config $Subcommand $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }
    Describe 'Git2.45.x' {
        BeforeAll {
            InModuleScope git-completion {
                Mock gitVersion { return [version]::new(2, 45, 999) }
                Mock gitResolveBuiltinsImpl { 
                    return @(
                        ' --global --system --local --worktree --file --blob --get --get-all --get-regexp --get-urlmatch' +
                        ' --replace-all --add --unset --unset-all --rename-section --remove-section --list --fixed-value --edit' +
                        ' --get-color --get-colorbool --type --bool --int --bool-or-int --bool-or-str --path --expiry-date --null' +
                        ' --name-only --includes --show-origin --show-scope --default --comment --no-global -- --no-system --no-local' +
                        ' --no-worktree --no-file --no-blob --no-get --no-get-all --no-get-regexp --no-get-urlmatch --no-replace-all' +
                        ' --no-add --no-unset --no-unset-all --no-rename-section --no-remove-section --no-list --no-fixed-value' +
                        ' --no-edit --no-get-color --no-get-colorbool --no-type --no-null --no-name-only --no-includes --no-show-origin' +
                        ' --no-show-scope --no-default --no-comment'
                    ) 
                } -ParameterFilter { 
                    ($Command.Length -eq 1) -and ($Command[0] -eq 'config')
                }
            }
        }

        It 'ShortOptions' {
            "git config -" | Complete-FromLine | Should -BeCompletion @(
                @{
                    CompletionText = "-e";
                    ListItemText   = "-e";
                    ResultType     = 'ParameterName';
                    ToolTip        = "open an editor";
                },
                @{
                    CompletionText = "-f";
                    ListItemText   = "-f";
                    ResultType     = 'ParameterName';
                    ToolTip        = "use given config file";
                },
                @{
                    CompletionText = "-l";
                    ListItemText   = "-l";
                    ResultType     = 'ParameterName';
                    ToolTip        = "list all";
                },
                @{
                    CompletionText = "-z";
                    ListItemText   = "-z";
                    ResultType     = 'ParameterName';
                    ToolTip        = "terminate values with NUL byte";
                }
            )
        }

        Describe 'OptionOrVariable' {
            It '<Line>' -ForEach @(
                @{
                    Line     = "pu";
                    Expected = @(
                        @{
                            CompletionText = "pull.";
                            ListItemText   = "pull.";
                            ResultType     = 'ParameterName';
                            ToolTip        = "pull.";
                        },
                        @{
                            CompletionText = "push.";
                            ListItemText   = "push.";
                            ResultType     = 'ParameterName';
                            ToolTip        = "push.";
                        }
                    );
                },
                @{
                    Line     = "--in"
                    Expected = @(
                        @{
                            CompletionText = "--int";
                            ListItemText   = "--int";
                            ResultType     = 'ParameterName';
                            ToolTip        = "value is decimal number";
                        },
                        @{
                            CompletionText = "--includes";
                            ListItemText   = "--includes";
                            ResultType     = 'ParameterName';
                            ToolTip        = "respect include directives on lookup";
                        }
                    )
                },
                @{
                    Line     = "--l"
                    Expected = @(
                        @{
                            CompletionText = "--local";
                            ListItemText   = "--local";
                            ResultType     = 'ParameterName';
                            ToolTip        = "use repository config file";
                        },
                        @{
                            CompletionText = "--list";
                            ListItemText   = "--list";
                            ResultType     = 'ParameterName';
                            ToolTip        = "list all";
                        }
                    )
                },
                @{
                    Line     = "--no-l"
                    Expected = @(
                        @{
                            CompletionText = "--no-local";
                            ListItemText   = "--no-local";
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] use repository config file";
                        },
                        @{
                            CompletionText = "--no-list";
                            ListItemText   = "--no-list";
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] list all";
                        }
                    )
                }
            ) { 
                "git config $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'VariableOption' {
            Context '<Option> <Line>' -ForEach @(
                @{
                    Option   = ""
                    Line     = "ali"
                    Expected = @(
                        @{
                            CompletionText = "alias.sw";
                            ListItemText   = "alias.sw";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.sw";
                        },
                        @{
                            CompletionText = "alias.swf";
                            ListItemText   = "alias.swf";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.swf";
                        }
                    )
                },
                @{
                    Option   = "--local"
                    Line     = "ali"
                    Expected = @(
                        @{
                            CompletionText = "alias.sw";
                            ListItemText   = "alias.sw";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.sw";
                        },
                        @{
                            CompletionText = "alias.swf";
                            ListItemText   = "alias.swf";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.swf";
                        }
                    )
                },
                @{
                    Option   = "--file test.config"
                    Line     = ""
                    Expected = @(
                        @{
                            CompletionText = "alias.ll";
                            ListItemText   = "alias.ll";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.ll";
                        }
                    )
                },
                @{
                    Option   = "--file=test.config"
                    Line     = ""
                    Expected = @(
                        @{
                            CompletionText = "alias.ll";
                            ListItemText   = "alias.ll";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.ll";
                        }
                    )
                },
                @{
                    Option   = "-f test.config"
                    Line     = ""
                    Expected = @(
                        @{
                            CompletionText = "alias.ll";
                            ListItemText   = "alias.ll";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "alias.ll";
                        }
                    )
                }
            ) {
                It '<_>' -ForEach @('--get', '--get-all', '--unset', '--unset-all') {
                    $GetOption = $_
                    "git config $Option $GetOption $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    } 
}