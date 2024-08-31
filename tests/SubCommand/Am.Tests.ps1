using namespace System.Collections.Generic;
using namespace System.IO;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | Convert-ToKebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Initialize-SimpleRepo $rootPath
        Push-Location $rootPath
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    It 'ShortOptions' {
        $expected = @(
            @{
                CompletionText = '-3';
                ListItemText   = '-3';
                ResultType     = 'ParameterName';
                ToolTip        = "allow fall back on 3way merging if needed";
            },
            @{
                CompletionText = '-c';
                ListItemText   = '-c';
                ResultType     = 'ParameterName';
                ToolTip        = "strip everything before a scissors line";
            },
            @{
                CompletionText = '-C';
                ListItemText   = '-C';
                ResultType     = 'ParameterName';
                ToolTip        = "pass it through git-apply";
            },
            @{
                CompletionText = '-i';
                ListItemText   = '-i';
                ResultType     = 'ParameterName';
                ToolTip        = "run interactively";
            },
            @{
                CompletionText = '-k';
                ListItemText   = '-k';
                ResultType     = 'ParameterName';
                ToolTip        = "pass -k flag to git-mailinfo";
            },
            @{
                CompletionText = '-m';
                ListItemText   = '-m';
                ResultType     = 'ParameterName';
                ToolTip        = "pass -m flag to git-mailinfo";
            },
            @{
                CompletionText = '-n';
                ListItemText   = '-n';
                ResultType     = 'ParameterName';
                ToolTip        = "bypass pre-applypatch and applypatch-msg hooks";
            },
            @{
                CompletionText = '-p';
                ListItemText   = '-p';
                ResultType     = 'ParameterName';
                ToolTip        = "pass it through git-apply";
            },
            @{
                CompletionText = '-q';
                ListItemText   = '-q';
                ResultType     = 'ParameterName';
                ToolTip        = "be quiet";
            },
            @{
                CompletionText = '-r';
                ListItemText   = '-r';
                ResultType     = 'ParameterName';
                ToolTip        = "synonyms for --continue";
            },
            @{
                CompletionText = '-s';
                ListItemText   = '-s';
                ResultType     = 'ParameterName';
                ToolTip        = "add a Signed-off-by trailer to the commit message";
            },
            @{
                CompletionText = '-S';
                ListItemText   = '-S';
                ResultType     = 'ParameterName';
                ToolTip        = "GPG-sign commits";
            },
            @{
                CompletionText = '-u';
                ListItemText   = '-u';
                ResultType     = 'ParameterName';
                ToolTip        = "recode into utf8 (default)";
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
                Line     = '--s';
                Expected = @(
                    @{
                        CompletionText = '--signoff';
                        ListItemText   = '--signoff';
                        ResultType     = 'ParameterName';
                        ToolTip        = "add a Signed-off-by trailer to the commit message";
                    },
                    @{
                        CompletionText = '--scissors';
                        ListItemText   = '--scissors';
                        ResultType     = 'ParameterName';
                        ToolTip        = "strip everything before a scissors line";
                    }
                )
            },
            @{
                Line     = '--q';
                Expected = @(
                    @{
                        CompletionText = '--quiet';
                        ListItemText   = '--quiet';
                        ResultType     = 'ParameterName';
                        ToolTip        = "be quiet";
                    },
                    @{
                        CompletionText = '--quoted-cr=';
                        ListItemText   = '--quoted-cr=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "pass it through git-mailinfo";
                    }
                )
            },
            @{
                Line     = '--no-s';
                Expected = @(
                    @{
                        CompletionText = '--no-signoff';
                        ListItemText   = '--no-signoff';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] add a Signed-off-by trailer to the commit message";
                    },
                    @{
                        CompletionText = '--no-scissors';
                        ListItemText   = '--no-scissors';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] strip everything before a scissors line";
                    }
                )
            },
            @{
                Line     = '--no';
                Expected = @(
                    @{
                        CompletionText = '--no-verify';
                        ListItemText   = '--no-verify';
                        ResultType     = 'ParameterName';
                        ToolTip        = "bypass pre-applypatch and applypatch-msg hooks"
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
                Line     = '--whitespace=';
                Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ForEach-Object {
                    @{
                        CompletionText = "--whitespace=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--whitespace ';
                Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--whitespace=w';
                Expected = 'warn' | ForEach-Object {
                    @{
                        CompletionText = "--whitespace=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--whitespace w';
                Expected = 'warn' | ForEach-Object {
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

    Describe 'Inprogress' {
        BeforeAll {
            New-Item '.git/rebase-apply' -ItemType Directory
        }
        BeforeAll {
            New-Item '.git/rebase-apply' -ItemType Directory
        }

        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-3';
                    ListItemText   = '-3';
                    ResultType     = 'ParameterName';
                    ToolTip        = "allow fall back on 3way merging if needed";
                },
                @{
                    CompletionText = '-c';
                    ListItemText   = '-c';
                    ResultType     = 'ParameterName';
                    ToolTip        = "strip everything before a scissors line";
                },
                @{
                    CompletionText = '-C';
                    ListItemText   = '-C';
                    ResultType     = 'ParameterName';
                    ToolTip        = "pass it through git-apply";
                },
                @{
                    CompletionText = '-i';
                    ListItemText   = '-i';
                    ResultType     = 'ParameterName';
                    ToolTip        = "run interactively";
                },
                @{
                    CompletionText = '-k';
                    ListItemText   = '-k';
                    ResultType     = 'ParameterName';
                    ToolTip        = "pass -k flag to git-mailinfo";
                },
                @{
                    CompletionText = '-m';
                    ListItemText   = '-m';
                    ResultType     = 'ParameterName';
                    ToolTip        = "pass -m flag to git-mailinfo";
                },
                @{
                    CompletionText = '-n';
                    ListItemText   = '-n';
                    ResultType     = 'ParameterName';
                    ToolTip        = "bypass pre-applypatch and applypatch-msg hooks";
                },
                @{
                    CompletionText = '-p';
                    ListItemText   = '-p';
                    ResultType     = 'ParameterName';
                    ToolTip        = "pass it through git-apply";
                },
                @{
                    CompletionText = '-q';
                    ListItemText   = '-q';
                    ResultType     = 'ParameterName';
                    ToolTip        = "be quiet";
                },
                @{
                    CompletionText = '-r';
                    ListItemText   = '-r';
                    ResultType     = 'ParameterName';
                    ToolTip        = "synonyms for --continue";
                },
                @{
                    CompletionText = '-s';
                    ListItemText   = '-s';
                    ResultType     = 'ParameterName';
                    ToolTip        = "add a Signed-off-by trailer to the commit message";
                },
                @{
                    CompletionText = '-S';
                    ListItemText   = '-S';
                    ResultType     = 'ParameterName';
                    ToolTip        = "GPG-sign commits";
                },
                @{
                    CompletionText = '-u';
                    ListItemText   = '-u';
                    ResultType     = 'ParameterName';
                    ToolTip        = "recode into utf8 (default)";
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
                    Line     = '--s';
                    Expected = @(
                        @{
                            CompletionText = '--skip';
                            ListItemText   = '--skip';
                            ResultType     = 'ParameterName';
                            ToolTip        = "skip the current patch";
                        },
                        @{
                            CompletionText = '--show-current-patch';
                            ListItemText   = '--show-current-patch';
                            ResultType     = 'ParameterName';
                            ToolTip        = "show the patch being applied";
                        }
                    )
                },
                @{
                    Line     = '--q';
                    Expected = @(
                        @{
                            CompletionText = '--quit';
                            ListItemText   = '--quit';
                            ResultType     = 'ParameterName';
                            ToolTip        = "abort the patching operation but keep HEAD where it is";
                        }
                    )
                },
                @{
                    Line     = '--no';
                    Expected = @()
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    
        Describe 'OptionValue' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--whitespace=';
                    Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ForEach-Object {
                        @{
                            CompletionText = "--whitespace=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--whitespace ';
                    Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--whitespace=w';
                    Expected = 'warn' | ForEach-Object {
                        @{
                            CompletionText = "--whitespace=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--whitespace w';
                    Expected = 'warn' | ForEach-Object {
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
}
