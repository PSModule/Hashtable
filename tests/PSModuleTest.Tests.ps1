Describe 'Module' {
    It 'Function: New-PSModuleTest' {
        New-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
}
