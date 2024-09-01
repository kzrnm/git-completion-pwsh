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

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-4';
            ToolTip      = "use IPv4 addresses only";
        },
        @{
            ListItemText = '-6';
            ToolTip      = "use IPv6 addresses only";
        },
        @{
            ListItemText = '-b';
            ToolTip      = "checkout <branch> instead of the remote's HEAD";
        },
        @{
            ListItemText = '-c';
            ToolTip      = "set config inside the new repository";
        },
        @{
            ListItemText = '-j';
            ToolTip      = "number of submodules cloned in parallel";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "to clone from a local repository";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "don't create a checkout";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "use <name> instead of 'origin' to track upstream";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "setup as shared repository";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "path to git-upload-pack on the remote";
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
                Line     = '--q';
                Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip "be more quiet"
            },
            @{
                Line     = '--v';
                Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip "be more verbose"
            },
            @{
                Line     = '--t';
                Expected = 
                @{
                    ListItemText = '--template=';
                    ToolTip      = "directory from which templates will be used"
                },
                @{
                    ListItemText = '--tags';
                    ToolTip      = "opposite of --no-tags"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-t';
                Expected = 
                @{
                    ListItemText = '--no-tags';
                    ToolTip      = "don't clone any tags, and make later fetches not to follow them"
                },
                @{
                    ListItemText = '--no-template';
                    ToolTip      = "[NO] directory from which templates will be used"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-checkout';
                    ToolTip      = "don't create a checkout"
                },
                @{
                    ListItemText = '--no-hardlinks';
                    ToolTip      = "don't use local hardlinks, always copy"
                },
                @{
                    ListItemText = '--no-tags';
                    ToolTip      = "don't clone any tags, and make later fetches not to follow them"
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
}