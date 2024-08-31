using namespace System.Collections.Generic;

. "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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
        Describe 'ShortOptions' {
            It 'Root' {
                $expected = "-h" | ConvertTo-Completion -ResultType ParameterName -ToolTip "show help"
                "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = 'get'
                    Expected = @{
                        ListItemText = "-f";
                        ToolTip      = "use given config file";
                    },
                    @{
                        ListItemText = "-t";
                        ToolTip      = "value is given this type";
                    },
                    @{
                        ListItemText = "-z";
                        ToolTip      = "terminate values with NUL byte";
                    },
                    @{
                        ListItemText = "-h";
                        ToolTip      = "show help";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = 'set'
                    Expected = @{
                        ListItemText = "-f";
                        ToolTip      = "use given config file";
                    },
                    @{
                        ListItemText = "-t";
                        ToolTip      = "value is given this type";
                    },
                    @{
                        ListItemText = "-h";
                        ToolTip      = "show help";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = 'unset'
                    Expected = @{
                        ListItemText = "-f";
                        ToolTip      = "use given config file";
                    },
                    @{
                        ListItemText = "-h";
                        ToolTip      = "show help";
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Line -" | Complete-FromLine | Should -BeCompletion $Expected
            }
        }

        Describe 'CompleteSubcommands' {
            It '<Line>' -ForEach @(
                @{
                    Line     = ''
                    Expected = @{
                        ListItemText = 'list';
                        ToolTip      = 'List all variables set in config file';
                    },
                    @{
                        ListItemText = 'get';
                        ToolTip      = 'Emits the value of the specified key';
                    },
                    @{
                        ListItemText = 'set';
                        ToolTip      = 'Set value for one or more config options';
                    },
                    @{
                        ListItemText = 'unset';
                        ToolTip      = 'Unset value for one or more config options';
                    },
                    @{
                        ListItemText = 'rename-section';
                        ToolTip      = 'Rename the given section to a new name';
                    },
                    @{
                        ListItemText = 'remove-section';
                        ToolTip      = 'Remove the given section from the configuration file';
                    },
                    @{
                        ListItemText = 'edit';
                        ToolTip      = 'Opens an editor to modify the specified config file';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = 's'
                    Expected = 'set' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'Set value for one or more config options'
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
            }
        }


        Describe 'Subcommand' {
            It '<Subcommand> <Line>' -ForEach @(
                @{
                    Line       = '--a';
                    Subcommand = 'get';
                    Expected   = '--all' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'return all values for multi-valued config options'
                },
                @{
                    Line       = '--no-a';
                    Subcommand = 'get';
                    Expected   = '--no-all' | ConvertTo-Completion -ResultType ParameterName -ToolTip '[NO] return all values for multi-valued config options'
                },
                @{
                    Line       = '--a';
                    Subcommand = 'set';
                    Expected   = @{
                        ListItemText = '--all';
                        ToolTip      = 'replace multi-valued config option with new value';
                    },
                    @{
                        ListItemText = '--append';
                        ToolTip      = 'add a new line without altering any existing values';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line       = '--no-a';
                    Subcommand = 'set';
                    Expected   = @{
                        ListItemText = '--no-all';
                        ToolTip      = '[NO] replace multi-valued config option with new value';
                    },
                    @{
                        ListItemText = '--no-append';
                        ToolTip      = '[NO] add a new line without altering any existing values';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line       = '--ty';
                    Subcommand = 'set';
                    Expected   = '--type=' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'value is given this type'
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $Expected
            }
        }

        Describe 'CommonOption' {
            Context '<Line>' -ForEach @(
                @{
                    Line     = "--lo"
                    Expected = "--local" | ConvertTo-Completion -ResultType ParameterName -ToolTip "use repository config file"
                },
                @{
                    Line     = "--glo"
                    Expected = "--global" | ConvertTo-Completion -ResultType ParameterName -ToolTip "use global config file"
                },
                @{
                    Line     = "--no-glo"
                    Expected = "--no-global" | ConvertTo-Completion -ResultType ParameterName -ToolTip "[NO] use global config file"
                }
            ) {
                It '<_>' -ForEach @(
                    "list", "get", "set", "unset",
                    "rename-section", "remove-section", "edit"
                ) {
                    $Subcommand = $_ 
                    "git $Command $Subcommand $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'EqualOptions' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'get --type ';
                    Expected = @()
                },
                @{
                    Line     = 'get --file ';
                    Expected = @()
                },
                @{
                    Line     = 'unset --file ';
                    Expected = @()
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion @()
            }
        }

        Describe 'VariableSubcommand' {
            Context '<Option> <Line>' -ForEach @(
                @{
                    Option   = ""
                    Line     = "ali"
                    Expected =
                    "alias.sw",
                    "alias.swf" | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Option   = "--local"
                    Line     = "ali"
                    Expected =
                    "alias.sw",
                    "alias.swf" | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Option   = "--file test.config"
                    Line     = ""
                    Expected = "alias.ll" | ConvertTo-Completion -ResultType ParameterValue -ToolTip "alias.ll"
                },
                @{
                    Option   = "--file=test.config"
                    Line     = ""
                    Expected = "alias.ll" | ConvertTo-Completion -ResultType ParameterValue -ToolTip "alias.ll"
                },
                @{
                    Option   = "-f test.config"
                    Line     = ""
                    Expected = "alias.ll" | ConvertTo-Completion -ResultType ParameterValue -ToolTip "alias.ll"
                }
            ) {
                It '<_>' -ForEach @('get', 'unset', 'get --no-url') {
                    $Subcommand = $_ 
                    "git $Command $Subcommand $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                Mock Get-GitHelp {
                    $short = [Dictionary[string, string]]::new()
                    (
                        @{Key = "-e"; Value = "open an editor"; },
                        @{Key = "-f"; Value = "use given config file"; },
                        @{Key = "-l"; Value = "list all"; },
                        @{Key = "-z"; Value = "terminate values with NUL byte"; }
                    ) | ForEach-Object {
                        $short[$_.Key] = $_.Value
                    }

                    $long = [Dictionary[string, string]]::new()
                    (
                        @{Key = "--includes"; Value = "respect include directives on lookup"; },
                        @{Key = "--int"; Value = "value is decimal number"; },
                        @{Key = "--local"; Value = "use repository config file"; }
                    ) | ForEach-Object {
                        $long[$_.Key] = $_.Value
                    }

                    return [GitHelp]::new(@(
                            [GitHelpOptions]@{
                                Subcommand = '';
                                Short      = $short;
                                Long       = $long;
                            }
                        ))
                } -ParameterFilter { 
                    $Command -eq 'config'
                }
            }
        }

        It 'ShortOptions' {
            $expected = @{
                ListItemText = "-e";
                ToolTip      = "open an editor";
            },
            @{
                ListItemText = "-f";
                ToolTip      = "use given config file";
            },
            @{
                ListItemText = "-l";
                ToolTip      = "list all";
            },
            @{
                ListItemText = "-z";
                ToolTip      = "terminate values with NUL byte";
            },
            @{
                ListItemText = "-h";
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'OptionOrVariable' {
            It '<Line>' -ForEach @(
                @{
                    Line     = "pu";
                    Expected = 
                    "pull.",
                    "push." | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "--in"
                    Expected = @{
                        ListItemText = "--int";
                        ToolTip      = "value is decimal number";
                    },
                    @{
                        ListItemText = "--includes";
                        ToolTip      = "respect include directives on lookup";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "--l"
                    Expected = @{
                        ListItemText = "--local";
                        ToolTip      = "use repository config file";
                    },
                    @{
                        ListItemText = "--list";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = "--no-l"
                    Expected = @{
                        ListItemText = "--no-local";
                        ToolTip      = "[NO] use repository config file";
                    },
                    @{
                        ListItemText = "--no-list";
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) { 
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'VariableOption' {
            Context '<Option> <Line>' -ForEach @(
                @{
                    Option   = ""
                    Line     = "ali"
                    Expected =
                    "alias.sw",
                    "alias.swf" | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Option   = "--local"
                    Line     = "ali"
                    Expected =
                    "alias.sw",
                    "alias.swf" | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Option   = "--file test.config"
                    Line     = ""
                    Expected = "alias.ll" | ConvertTo-Completion -ResultType ParameterValue -ToolTip "alias.ll"
                },
                @{
                    Option   = "--file=test.config"
                    Line     = ""
                    Expected = "alias.ll" | ConvertTo-Completion -ResultType ParameterValue -ToolTip "alias.ll"
                },
                @{
                    Option   = "-f test.config"
                    Line     = ""
                    Expected = "alias.ll" | ConvertTo-Completion -ResultType ParameterValue -ToolTip "alias.ll"
                }
            ) {
                It '<_>' -ForEach @('--get', '--get-all', '--unset', '--unset-all') {
                    $GetOption = $_
                    "git $Command $Option $GetOption $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    } 
}