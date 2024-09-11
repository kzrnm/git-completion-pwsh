using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
    }

    Describe 'Subcommands' {
        It '<Line>' -ForEach @(
            @{
                Line     = ""
                Expected = @{
                    ListItemText = 'add';
                    ToolTip      = "add the given repository as a submodule";
                },
                @{
                    ListItemText = 'status';
                    ToolTip      = "show the status of the submodules";
                },
                @{
                    ListItemText = 'init';
                    ToolTip      = "initialize the submodules";
                },
                @{
                    ListItemText = 'deinit';
                    ToolTip      = "unregister the given submodules";
                },
                @{
                    ListItemText = 'update';
                    ToolTip      = "update the registered submodules";
                },
                @{
                    ListItemText = 'set-branch';
                    ToolTip      = "sets the default remote tracking branch for the submodule";
                },
                @{
                    ListItemText = 'set-url';
                    ToolTip      = "sets the url of the specified submodule to <newurl>";
                },
                @{
                    ListItemText = 'summary';
                    ToolTip      = "show commit summary between the given commit";
                },
                @{
                    ListItemText = 'foreach';
                    ToolTip      = "evaluates an arbitrary shell command in each checked out submodule";
                },
                @{
                    ListItemText = 'sync';
                    ToolTip      = "synchronizes submodules' remote URL configuration setting to the value specified in .gitmodules";
                },
                @{
                    ListItemText = 'absorbgitdirs';
                    ToolTip      = "move the git directory of the submodule into its superproject’s `$GIT_DIR/modules path";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = "s"
                Expected = @{
                    ListItemText = 'status';
                    ToolTip      = "show the status of the submodules";
                },
                @{
                    ListItemText = 'set-branch';
                    ToolTip      = "sets the default remote tracking branch for the submodule";
                },
                @{
                    ListItemText = 'set-url';
                    ToolTip      = "sets the url of the specified submodule to <newurl>";
                },
                @{
                    ListItemText = 'summary';
                    ToolTip      = "show commit summary between the given commit";
                },
                @{
                    ListItemText = 'sync';
                    ToolTip      = "synchronizes submodules' remote URL configuration setting to the value specified in .gitmodules";
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'add' {
        BeforeAll {
            Set-Variable Subcommand 'add'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--branch',
                    '--force',
                    '--name',
                    '--reference',
                    '--depth' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--r';
                    Expected =
                    '--reference' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'status' {
        BeforeAll {
            Set-Variable Subcommand 'status'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--cached',
                    '--recursive' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--r';
                    Expected =
                    '--recursive' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'init' {
        BeforeAll {
            Set-Variable Subcommand 'init'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'deinit' {
        BeforeAll {
            Set-Variable Subcommand 'deinit'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--force',
                    '--all' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--a';
                    Expected =
                    '--all' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'update' {
        BeforeAll {
            Set-Variable Subcommand 'update'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--init',
                    '--remote',
                    '--no-fetch',
                    '--recommend-shallow',
                    '--no-recommend-shallow',
                    '--force',
                    '--rebase',
                    '--merge',
                    '--reference',
                    '--depth',
                    '--recursive',
                    '--jobs' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--r';
                    Expected =
                    '--remote',
                    '--recommend-shallow',
                    '--rebase',
                    '--reference',
                    '--recursive' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'set-branch' {
        BeforeAll {
            Set-Variable Subcommand 'set-branch'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--default',
                    '--branch' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--b';
                    Expected =
                    '--branch' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'set-url' {
        BeforeAll {
            Set-Variable Subcommand 'set-url'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'summary' {
        BeforeAll {
            Set-Variable Subcommand 'summary'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--cached',
                    '--files',
                    '--summary-limit' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--s';
                    Expected =
                    '--summary-limit' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'foreach' {
        BeforeAll {
            Set-Variable Subcommand 'foreach'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--recursive' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--r';
                    Expected =
                    '--recursive' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'sync' {
        BeforeAll {
            Set-Variable Subcommand 'sync'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--recursive' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--r';
                    Expected =
                    '--recursive' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    
    Describe 'absorbgitdirs' {
        BeforeAll {
            Set-Variable Subcommand 'absorbgitdirs'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}