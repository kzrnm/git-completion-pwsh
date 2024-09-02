using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

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

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor) <Right>' -ForEach @(
                @{
                    Left     = 'create';
                    Right    = ' --';
                    Expected = 'create' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'create'
                },
                @{
                    Left     = 'create';
                    Right    = ' -- --all';
                    Expected = 'create' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'create'
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
            },
            @{
                Line     = 'src -- ';
                Expected = @()
            },
            @{
                Line     = '-- ';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'create' {
        "git $Command create " | Complete-FromLine | Should -BeCompletion @()
    }

    Describe 'Revlist' {
        . "${RepoRoot}testtools/Revlist.ps1" -Prefix 'create foo '
        . "${RepoRoot}testtools/Revlist.ps1" -Prefix 'create foo -q '
        . "${RepoRoot}testtools/Revlist.ps1" -Prefix 'create -- foo '
        . "${RepoRoot}testtools/Revlist.ps1" -Prefix 'create -- -q '
        . "${RepoRoot}testtools/Revlist.ps1" -Prefix 'create foo -- '
    }
}