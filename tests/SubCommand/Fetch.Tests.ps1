using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | Convert-ToKebabCase)
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
        $expected = @(
            @{
                CompletionText = '-4';
                ListItemText   = '-4';
                ResultType     = 'ParameterName';
                ToolTip        = "use IPv4 addresses only";
            },
            @{
                CompletionText = '-6';
                ListItemText   = '-6';
                ResultType     = 'ParameterName';
                ToolTip        = "use IPv6 addresses only";
            },
            @{
                CompletionText = '-a';
                ListItemText   = '-a';
                ResultType     = 'ParameterName';
                ToolTip        = "append to .git/FETCH_HEAD instead of overwriting";
            },
            @{
                CompletionText = '-f';
                ListItemText   = '-f';
                ResultType     = 'ParameterName';
                ToolTip        = "force overwrite of local reference";
            },
            @{
                CompletionText = '-j';
                ListItemText   = '-j';
                ResultType     = 'ParameterName';
                ToolTip        = "number of submodules fetched in parallel";
            },
            @{
                CompletionText = '-k';
                ListItemText   = '-k';
                ResultType     = 'ParameterName';
                ToolTip        = "keep downloaded pack";
            },
            @{
                CompletionText = '-m';
                ListItemText   = '-m';
                ResultType     = 'ParameterName';
                ToolTip        = "fetch from multiple remotes";
            },
            @{
                CompletionText = '-n';
                ListItemText   = '-n';
                ResultType     = 'ParameterName';
                ToolTip        = "do not fetch all tags (--no-tags)";
            },
            @{
                CompletionText = '-o';
                ListItemText   = '-o';
                ResultType     = 'ParameterName';
                ToolTip        = "option to transmit";
            },
            @{
                CompletionText = '-p';
                ListItemText   = '-p';
                ResultType     = 'ParameterName';
                ToolTip        = "prune remote-tracking branches no longer on remote";
            },
            @{
                CompletionText = '-P';
                ListItemText   = '-P';
                ResultType     = 'ParameterName';
                ToolTip        = "prune local tags no longer on remote and clobber changed tags";
            },
            @{
                CompletionText = '-q';
                ListItemText   = '-q';
                ResultType     = 'ParameterName';
                ToolTip        = "be more quiet";
            },
            @{
                CompletionText = '-t';
                ListItemText   = '-t';
                ResultType     = 'ParameterName';
                ToolTip        = "fetch all tags and associated objects";
            },
            @{
                CompletionText = '-u';
                ListItemText   = '-u';
                ResultType     = 'ParameterName';
                ToolTip        = "allow updating of HEAD ref";
            },
            @{
                CompletionText = '-v';
                ListItemText   = '-v';
                ResultType     = 'ParameterName';
                ToolTip        = "be more verbose";
            },
            @{
                CompletionText = '-h';
                ListItemText   = '-h';
                ResultType     = 'ParameterName';
                ToolTip        = "show help";
            }
        )
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--f';
                Expected = @(
                    @{
                        CompletionText = '--force';
                        ListItemText   = '--force';
                        ResultType     = 'ParameterName';
                        ToolTip        = "force overwrite of local reference";
                    },
                    @{
                        CompletionText = '--filter=';
                        ListItemText   = '--filter=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "object filtering";
                    }
                )
            },
            @{
                Line     = '--no-f';
                Expected = @(
                    @{
                        CompletionText = '--no-force';
                        ListItemText   = '--no-force';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] force overwrite of local reference";
                    },
                    @{
                        CompletionText = '--no-filter';
                        ListItemText   = '--no-filter';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] object filtering";
                    }
                )
            },
            @{
                Line     = '--no';
                Expected = @(
                    @{
                        CompletionText = '--no-verbose';
                        ListItemText   = '--no-verbose';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] be more verbose";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                        ToolTip        = "--no-...";
                    }
                )
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
                    @{
                        CompletionText = 'yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    },
                    @{
                        CompletionText = 'on-demand';
                        ListItemText   = 'on-demand';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "on-demand";
                    },
                    @{
                        CompletionText = 'no';
                        ListItemText   = 'no';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "no";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules y';
                Expected = @(
                    @{
                        CompletionText = 'yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules=';
                Expected = @(
                    @{
                        CompletionText = '--recurse-submodules=yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    },
                    @{
                        CompletionText = '--recurse-submodules=on-demand';
                        ListItemText   = 'on-demand';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "on-demand";
                    },
                    @{
                        CompletionText = '--recurse-submodules=no';
                        ListItemText   = 'no';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "no";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules=y';
                Expected = @(
                    @{
                        CompletionText = '--recurse-submodules=yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    }
                )
            },
            @{
                Line     = '--multiple ';
                Expected = @(
                    'grm',
                    'ordinary',
                    'origin'
                ) | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--multiple or';
                Expected = @(
                    'ordinary',
                    'origin'
                ) | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
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
                ) | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin m';
                Expected = @(
                    'main:main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin +';
                Expected = @(
                    'HEAD:HEAD',
                    'main:main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "+$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin +m';
                Expected = @(
                    'main:main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "+$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
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
                ) | ForEach-Object {
                    @{
                        CompletionText = "left:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin left:m';
                Expected = @(
                    'main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "left:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'or';
                Expected = @(
                    'ordinary',
                    'origin'
                ) | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '';
                Expected = @(
                    'grm',
                    'ordinary',
                    'origin'
                ) | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}