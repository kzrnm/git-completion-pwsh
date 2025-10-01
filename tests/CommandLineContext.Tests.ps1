using namespace System.Management.Automation;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'CommandLineContext' {
    BeforeAll {
        InModuleScope git-completion {
            Mock Complete-GitCommandLine {
                param([Parameter(Position = 0)]$Context)
                return $Context
            }
        }

        $line = "git reset 12345e6 `$PWD 'foo %' `"foo bar`" -- @ @(1,2) @{a=1}"
        Set-Variable ast ([Language.Parser]::ParseInput($line, [ref]$null, [ref]$null).EndBlock.Statements.PipelineElements)
    }
    It 'Ast' {
        $result = Complete-Git -CommandAst $ast -CursorPosition $line.Length
        $result.Command | Should -Be 'reset'
        $result.CommandIndex | Should -Be 1
        $result.CurrentIndex | Should -Be 9
        $result.DoubledashIndex | Should -Be 6
        $result.gitCArgs | Should -Be $null
        $result.gitDir | Should -Be @()
        $result.SubcommandLikeIndex | Should -Be 2
        $result.Words | Should -Be @('git', 'reset', '12345e6', '$PWD', 'foo %', 'foo bar', '--', '@', '@(1,2)', '@{a=1}')

        $result = Complete-Git -CommandAst $ast -CursorPosition 30
        $result.Command | Should -Be 'reset'
        $result.CommandIndex | Should -Be 1
        $result.CurrentIndex | Should -Be 4
        $result.DoubledashIndex | Should -Be 6
        $result.gitCArgs | Should -Be $null
        $result.gitDir | Should -Be @()
        $result.SubcommandLikeIndex | Should -Be 2
        $result.Words | Should -Be @('git', 'reset', '12345e6', '$PWD', 'foo %', 'foo bar', '--', '@', '@(1,2)', '@{a=1}')

        $result = Complete-Git -CommandAst $ast -CursorPosition 31
        $result.Command | Should -Be 'reset'
        $result.CommandIndex | Should -Be 1
        $result.CurrentIndex | Should -Be 5
        $result.DoubledashIndex | Should -Be 7
        $result.gitCArgs | Should -Be $null
        $result.gitDir | Should -Be @()
        $result.SubcommandLikeIndex | Should -Be 2
        $result.Words | Should -Be @('git', 'reset', '12345e6', '$PWD', 'foo %', '', 'foo bar', '--', '@', '@(1,2)', '@{a=1}')
    }
}