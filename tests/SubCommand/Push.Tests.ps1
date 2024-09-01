using namespace System.Collections.Generic;

. "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
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

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-4';
            ToolTip      = "use IPv4 addresses only";
        },
        @{
            ListItemText = '-6';
            ToolTip      = "use IPv6 addresses only";
        },
        @{
            ListItemText = '-d';
            ToolTip      = "delete refs";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force updates";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "dry run";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "option to transmit";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "set upstream for git pull/status";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be more verbose";
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
                Line     = '--re';
                Expected = @{
                    ListItemText = '--repo=';
                    ToolTip      = "repository";
                },
                @{
                    ListItemText = '--recurse-submodules=';
                    ToolTip      = "control recursive pushing of submodules";
                },
                @{
                    ListItemText = '--receive-pack=';
                    ToolTip      = "receive pack program";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--re';
                Expected = @{
                    ListItemText = '--repo=';
                    ToolTip      = "repository";
                },
                @{
                    ListItemText = '--recurse-submodules=';
                    ToolTip      = "control recursive pushing of submodules";
                },
                @{
                    ListItemText = '--receive-pack=';
                    ToolTip      = "receive pack program";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-re';
                Expected = @{
                    ListItemText = '--no-repo';
                    ToolTip      = "[NO] repository";
                },
                @{
                    ListItemText = '--no-recurse-submodules';
                    ToolTip      = "[NO] control recursive pushing of submodules";
                },
                @{
                    ListItemText = '--no-receive-pack';
                    ToolTip      = "[NO] receive pack program";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--n';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "bypass pre-push hook";
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

    Describe 'OptionValue' {
        Describe 'noCompleteRefspec' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--mirror ';
                    Expected = 
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--mirror or';
                    Expected = 
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--mirror origin ';
                    Expected = @()
                },
                @{
                    Line     = '--all ';
                    Expected = 
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--all or';
                    Expected = 
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--all origin ';
                    Expected = @()
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--force-with-lease=';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--force-with-lease=$_"
                }
            },
            @{
                Line     = '--force-with-lease=or';
                Expected = 
                'ordinary/main',
                'origin/main' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--force-with-lease=$_"
                }
            },
            @{
                Line     = '--force-with-lease=ma:';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--force-with-lease=ma:$_"
                }
            },
            @{
                Line     = '--force-with-lease=ma:or';
                Expected = 
                'ordinary/main',
                'origin/main' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--force-with-lease=ma:$_"
                }
            },
            @{
                Line     = '--recurse-submodules ';
                Expected = 
                'check',
                'on-demand',
                'only' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--recurse-submodules c';
                Expected = 'check' | ConvertTo-Completion -ResultType ParameterValue -ToolTip "check"
            },
            @{
                Line     = '--recurse-submodules=';
                Expected = 
                @{
                    CompletionText = '--recurse-submodules=check';
                    ListItemText   = 'check';
                },
                @{
                    CompletionText = '--recurse-submodules=on-demand';
                    ListItemText   = 'on-demand';
                },
                @{
                    CompletionText = '--recurse-submodules=only';
                    ListItemText   = 'only';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--recurse-submodules=c';
                Expected = @{
                    CompletionText = '--recurse-submodules=check';
                    ListItemText   = 'check';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--repo=';
                Expected = 
                @{
                    CompletionText = '--repo=grm';
                    ListItemText   = 'grm';
                },
                @{
                    CompletionText = '--repo=ordinary';
                    ListItemText   = 'ordinary';
                },
                @{
                    CompletionText = '--repo=origin';
                    ListItemText   = 'origin';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--repo=or';
                Expected = 
                @{
                    CompletionText = '--repo=ordinary';
                    ListItemText   = 'ordinary';
                },
                @{
                    CompletionText = '--repo=origin';
                    ListItemText   = 'origin';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--repo ';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--repo or';
                Expected = 
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete ';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-d ';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'RemoteOrRefspec' {
        It '<Line>' -ForEach @(
            @{
                Line     = 'origin ';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin o';
                Expected = 
                'ordinary/main',
                'origin/main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin ^';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin ^o';
                Expected = 
                'ordinary/main',
                'origin/main' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin +';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "+$_"
                }
            },
            @{
                Line     = 'origin +o';
                Expected = 
                'ordinary/main',
                'origin/main' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "+$_"
                }
            },
            @{
                Line     = 'origin left:';
                Expected = 
                'HEAD',
                'main' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "left:$_"
                }
            },
            @{
                Line     = 'origin left:m';
                Expected = 
                'main' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "left:$_"
                }
            },
            @{
                Line     = 'or';
                Expected = 
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin refs';
                Expected = 
                'refs/heads/main',
                'refs/remotes/grm/main',
                'refs/remotes/ordinary/main',
                'refs/remotes/origin/main',
                'refs/tags/initial' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin refs/h';
                Expected = 
                'refs/heads/main' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Middle' {
        It '<Line>(cursor) <Right>' -ForEach @(
            @{
                Line     = 'o';
                Right    = @('main');
                Expected = 
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine -RightInputs $Right | Should -BeCompletion $expected
        }
    }
}
