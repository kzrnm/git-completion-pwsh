BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'Resolve-GitAlias' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
        git config alias.sw 'switch'
        git config alias.swf 'sw -f'
        git config alias.swcf "'swf' '-c'"
        git config alias.ll '!ls -l'
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }


    Context 'Default' {
        It '<command>' -ForEach @(
            @{
                Command  = 'sw';
                Expected = 'switch';
            },
            @{
                Command  = 'swf';
                Expected = 'sw -f';
            },
            @{
                Command  = 'swcf';
                Expected = "'swf' '-c'";
            },
            @{
                Command  = 'll';
                Expected = '!ls -l';
            }
        ) {
            Resolve-GitAlias $command | Should -Be $expected
        }
    }

    Context 'ActualCommand' {
        It '<command>' -ForEach @(
            @{
                Command  = 'sw';
                Expected = 'switch';
            },
            @{
                Command  = 'swf';
                Expected = 'switch';
            },
            @{
                Command  = 'swcf';
                Expected = 'switch';
            },
            @{
                Command  = 'll';
                Expected = $null;
            }
        ) {
            Resolve-GitAlias $command -ActualCommand | Should -Be $expected
        }
    }
}
