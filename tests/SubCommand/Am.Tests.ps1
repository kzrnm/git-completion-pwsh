using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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
        $expected = @{
            ListItemText = '-3';
            ToolTip      = "allow fall back on 3way merging if needed";
        },
        @{
            ListItemText = '-c';
            ToolTip      = "strip everything before a scissors line";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "pass it through git-apply";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "run interactively";
        },
        @{
            ListItemText = '-k';
            ToolTip      = "pass -k flag to git-mailinfo";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "pass -m flag to git-mailinfo";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "bypass pre-applypatch and applypatch-msg hooks";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "pass it through git-apply";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be quiet";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "synonyms for --continue";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "add a Signed-off-by trailer to the commit message";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG-sign commits";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "recode into utf8 (default)";
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
                Line     = '--s';
                Expected = @{
                    ListItemText   = '--signoff';
                    ToolTip        = "add a Signed-off-by trailer to the commit message";
                },
                @{
                    ListItemText   = '--scissors';
                    ToolTip        = "strip everything before a scissors line";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--q';
                Expected = @{
                    ListItemText   = '--quiet';
                    ToolTip        = "be quiet";
                },
                @{
                    ListItemText   = '--quoted-cr=';
                    ToolTip        = "pass it through git-mailinfo";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-s';
                Expected = @{
                    ListItemText   = '--no-signoff';
                    ToolTip        = "[NO] add a Signed-off-by trailer to the commit message";
                },
                @{
                    ListItemText   = '--no-scissors';
                    ToolTip        = "[NO] strip everything before a scissors line";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "bypass pre-applypatch and applypatch-msg hooks"
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
                Line     = '--whitespace=';
                Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--whitespace=$_"
                }
            },
            @{
                Line     = '--whitespace ';
                Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--whitespace=w';
                Expected = 'warn' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--whitespace=$_"
                }
            },
            @{
                Line     = '--whitespace w';
                Expected = 'warn' | ConvertTo-Completion -ResultType ParameterValue
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
            $expected = @{
                ListItemText = '-3';
                ToolTip      = "allow fall back on 3way merging if needed";
            },
            @{
                ListItemText = '-c';
                ToolTip      = "strip everything before a scissors line";
            },
            @{
                ListItemText = '-C';
                ToolTip      = "pass it through git-apply";
            },
            @{
                ListItemText = '-i';
                ToolTip      = "run interactively";
            },
            @{
                ListItemText = '-k';
                ToolTip      = "pass -k flag to git-mailinfo";
            },
            @{
                ListItemText = '-m';
                ToolTip      = "pass -m flag to git-mailinfo";
            },
            @{
                ListItemText = '-n';
                ToolTip      = "bypass pre-applypatch and applypatch-msg hooks";
            },
            @{
                ListItemText = '-p';
                ToolTip      = "pass it through git-apply";
            },
            @{
                ListItemText = '-q';
                ToolTip      = "be quiet";
            },
            @{
                ListItemText = '-r';
                ToolTip      = "synonyms for --continue";
            },
            @{
                ListItemText = '-s';
                ToolTip      = "add a Signed-off-by trailer to the commit message";
            },
            @{
                ListItemText = '-S';
                ToolTip      = "GPG-sign commits";
            },
            @{
                ListItemText = '-u';
                ToolTip      = "recode into utf8 (default)";
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
                    Line     = '--s';
                    Expected = @{
                        ListItemText = '--skip';
                        ToolTip      = "skip the current patch";
                    },
                    @{
                        ListItemText = '--show-current-patch';
                        ToolTip      = "show the patch being applied";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected = '--quit' | ConvertTo-Completion -ResultType ParameterName -ToolTip "abort the patching operation but keep HEAD where it is"
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
                        "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--whitespace=$_"
                    }
                },
                @{
                    Line     = '--whitespace ';
                    Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--whitespace=w';
                    Expected = 'warn' | ForEach-Object {
                        "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--whitespace=$_"
                    }
                },
                @{
                    Line     = '--whitespace w';
                    Expected = 'warn' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}
