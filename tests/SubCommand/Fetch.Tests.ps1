using namespace System.Collections.Generic;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
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

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'origin -- -';
                Expected = @()
            },
            @{
                Line     = 'origin -- --';
                Expected = @()
            },
            @{
                Line     = '-- -';
                Expected = @()
            },
            @{
                Line     = '-- --';
                Expected = @()
            },
            @{
                Line     = '-- --recurse-submodules ';
                Expected = @(
                    'grm',
                    'ordinary',
                    'origin'
                ) | ConvertTo-Completion -ResultType ParameterValue
            }
            @{
                Line     = '-- ';
                Expected = @(
                    'grm',
                    'ordinary',
                    'origin'
                ) | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
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
            ListItemText = '-a';
            ToolTip      = "append to .git/FETCH_HEAD instead of overwriting";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force overwrite of local reference";
        },
        @{
            ListItemText = '-j';
            ToolTip      = "number of submodules fetched in parallel";
        },
        @{
            ListItemText = '-k';
            ToolTip      = "keep downloaded pack";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "fetch from multiple remotes";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "do not fetch all tags (--no-tags)";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "option to transmit";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "prune remote-tracking branches no longer on remote";
        },
        @{
            ListItemText = '-P';
            ToolTip      = "prune local tags no longer on remote and clobber changed tags";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-t';
            ToolTip      = "fetch all tags and associated objects";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "allow updating of HEAD ref";
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
                Line     = '--f';
                Expected = @{
                    ListItemText = '--force';
                    ToolTip      = "force overwrite of local reference";
                },
                @{
                    ListItemText = '--filter=';
                    ToolTip      = "object filtering";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-f';
                Expected = @{
                    ListItemText = '--no-force';
                    ToolTip      = "[NO] force overwrite of local reference";
                },
                @{
                    ListItemText = '--no-filter';
                    ToolTip      = "[NO] object filtering";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-verbose';
                    ToolTip      = "[NO] be more verbose";
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
        It '<Line>' -ForEach @(
            @{
                Line     = '--recurse-submodules ';
                Expected = @(
                    'yes',
                    'on-demand',
                    'no' | ConvertTo-Completion -ResultType ParameterValue
                )
            },
            @{
                Line     = '--recurse-submodules y';
                Expected = 'yes' | ConvertTo-Completion -ResultType ParameterValue -ToolTip "yes"
            },
            @{
                Line     = '--recurse-submodules=';
                Expected = @{
                    CompletionText = '--recurse-submodules=yes';
                    ListItemText   = 'yes';
                },
                @{
                    CompletionText = '--recurse-submodules=on-demand';
                    ListItemText   = 'on-demand';
                },
                @{
                    CompletionText = '--recurse-submodules=no';
                    ListItemText   = 'no';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--recurse-submodules=y';
                Expected = @{
                    CompletionText = '--recurse-submodules=yes';
                    ListItemText   = 'yes';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--multiple ';
                Expected = @(
                    'grm',
                    'ordinary',
                    'origin'
                ) | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--multiple or';
                Expected = @(
                    'ordinary',
                    'origin'
                ) | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--all ';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'RemoteOrRefspec' {
        It '<Line>' -ForEach @(
            @{
                Line     = 'origin ';
                Expected = @(
                    'HEAD:HEAD',
                    'main:main'
                ) | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin m';
                Expected = @(
                    'main:main'
                ) | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin +';
                Expected = @(
                    'HEAD:HEAD',
                    'main:main'
                ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
            },
            @{
                Line     = 'origin +m';
                Expected = @(
                    'main:main'
                ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
            },
            @{
                Line     = 'origin left:';
                Expected = @(
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/main',
                    'ordinary/main',
                    'origin/main',
                    'initial'
                ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
            },
            @{
                Line     = 'origin left:m';
                Expected = @(
                    'main'
                ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
            },
            @{
                Line     = 'or';
                Expected = @(
                    'ordinary',
                    'origin'
                ) | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '';
                Expected = @(
                    'grm',
                    'ordinary',
                    'origin'
                ) | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}