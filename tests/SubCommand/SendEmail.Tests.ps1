# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

function noSendEmail {
    $ErrorActionPreference = 'SilentlyContinue'
    git send-email --dump-aliases 2>$null | Out-Null
    return $LASTEXITCODE -ne 0
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote -Skip:(noSendEmail) {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
        @'
aqualion@deava: apollo@deava silvia@deava linghua@deava
souseibu@deava.go.jp: akira@deava.go.jp maia@deava.co.jp subete@nesta.jp
'@ | Out-File "$TestDrive/sendmail" -Encoding ascii
        git config set sendemail.aliasFileType sendmail
        git config set sendemail.aliasesFile "$TestDrive/sendmail".Replace('\', '/')
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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip "* Output one line of info per email."
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip "* Output one line of info per email."
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
                Expected = @()
            },
            @{
                Line     = 'src -- --';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe-Revlist {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    # `git send-email --git-completion-helper` is not stable.
    # Describe 'Options' {
    #     It '<Line>' -ForEach @(
    #         @{
    #             Line     = '--a';
    #             Expected = '--all',
    #             @{
    #                 ListItemText = '--annotate';
    #                 ToolTip      = "* Review each patch that will be sent in an editor.";
    #             },
    #             '--add-header=',
    #             '--attach' | ConvertTo-Completion -ResultType ParameterName
    #         }
    #     ) {
    #         "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
    #     }
    # }

    Describe 'OptionValue' {
        Describe 'DumpAlias:<Option>' -ForEach @('--to', '--cc', '--bcc', '--from' | ForEach-Object { @{Option = $_ } }) {
            It '=<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = 'aqualion@deava', 'souseibu@deava.go.jp' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$Option=$_" }
                },
                @{
                    Line     = 's';
                    Expected = 'souseibu@deava.go.jp' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$Option=$_" }
                }
            ) {
                "git $Command $Option=$Line" | Complete-FromLine | Should -BeCompletion $expected
            }

            It '=<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = 'aqualion@deava', 'souseibu@deava.go.jp' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 's';
                    Expected = 'souseibu@deava.go.jp' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--thread=';
                Expected = 'deep', 'shallow' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--thread=$_" }
            },
            @{
                Line     = '--thread=d';
                Expected = 'deep' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--thread=$_" }
            },
            @{
                Line     = '--smtp-encryption=';
                Expected = 'ssl', 'tls' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--smtp-encryption=$_" }
            },
            @{
                Line     = '--smtp-encryption=s';
                Expected = 'ssl' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--smtp-encryption=$_" }
            },
            @{
                Line     = '--smtp-encryption ';
                Expected = 'ssl', 'tls' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--smtp-encryption s';
                Expected = 'ssl' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--suppress-cc=';
                Expected = 'author', 'self', 'cc', 'bodycc', 'sob', 'cccmd', 'body', 'all' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--suppress-cc=$_" }
            },
            @{
                Line     = '--suppress-cc=a';
                Expected = 'author', 'all' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--suppress-cc=$_" }
            },
            @{
                Line     = '--suppress-cc ';
                Expected = 'author', 'self', 'cc', 'bodycc', 'sob', 'cccmd', 'body', 'all' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--suppress-cc a';
                Expected = 'author', 'all' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--confirm=';
                Expected = 'always', 'never', 'auto', 'cc', 'compose' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--confirm=$_" }
            },
            @{
                Line     = '--confirm=a';
                Expected = 'always', 'auto' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--confirm=$_" }
            },
            @{
                Line     = '--confirm ';
                Expected = 'always', 'never', 'auto', 'cc', 'compose' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--confirm a';
                Expected = 'always', 'auto' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}