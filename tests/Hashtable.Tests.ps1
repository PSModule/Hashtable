Describe 'Module' {
    Describe 'Merge-Hashtable' {
        It 'Merges two hashtable' {
            $Main = @{
                Action   = ''
                Location = 'Main'
                Mode     = 'Main'
            }
            $Override = @{
                Action   = ''
                Location = ''
                Mode     = 'Override'
            }
            $Result = Merge-Hashtable -Main $Main -Overrides $Override

            $Result.Action | Should -Be ''
            $Result.Location | Should -Be 'Main'
            $Result.Mode | Should -Be 'Override'
        }

        It 'Merges three hashtable' {
            $Main = @{
                Action   = ''
                Location = 'Main'
                Mode     = 'Main'
                Name     = 'Main'
            }
            $Override1 = @{
                Action   = ''
                Location = ''
                Mode     = 'Override1'
                Name     = 'Override1'
            }
            $Override2 = @{
                Action   = ''
                Location = ''
                Mode     = ''
                Name     = 'Override2'
            }
            $Result = Merge-Hashtable -Main $Main -Overrides $Override1, $Override2

            $Result.Action | Should -Be ''
            $Result.Location | Should -Be 'Main'
            $Result.Mode | Should -Be 'Override1'
            $Result.Name | Should -Be 'Override2'
        }
    }

    Describe 'ConvertTo-Hashtable' {
        It 'Can convert a small data structure to a hashtable' {
            $object = [PSCustomObject]@{
                Name        = 'John Doe'
                Age         = 30
                Address     = [PSCustomObject]@{
                    Street  = '123 Main St'
                    City    = 'Somewhere'
                    ZipCode = '12345'
                }
                Occupations = @(
                    [PSCustomObject]@{
                        Title   = 'Developer'
                        Company = 'TechCorp'
                    },
                    [PSCustomObject]@{
                        Title   = 'Consultant'
                        Company = 'ConsultCorp'
                    }
                )
            }

            $hashtable = $object | ConvertTo-Hashtable
            $hashtable.Name | Should -Be 'John Doe'
            $hashtable.Age | Should -Be 30
            $hashtable.Address.Street | Should -Be '123 Main St'
            $hashtable.Address.City | Should -Be 'Somewhere'
            $hashtable.Address.ZipCode | Should -Be '12345'
            $hashtable.Occupations[0].Title | Should -Be 'Developer'
            $hashtable.Occupations[0].Company | Should -Be 'TechCorp'
            $hashtable.Occupations[1].Title | Should -Be 'Consultant'
            $hashtable.Occupations[1].Company | Should -Be 'ConsultCorp'
        }
        It 'Can convert a bigger data structure to a hashtable' {
            $complexObject = [PSCustomObject]@{
                Person        = [PSCustomObject]@{
                    FirstName      = 'Alice'
                    LastName       = 'Smith'
                    Age            = 28
                    Contact        = [PSCustomObject]@{
                        Email = 'alice.smith@example.com'
                        Phone = [PSCustomObject]@{
                            Home   = '555-1234'
                            Mobile = '555-5678'
                        }
                    }
                    Address        = [PSCustomObject]@{
                        Street  = '456 Oak St'
                        City    = 'Anytown'
                        ZipCode = '67890'
                        Country = 'USA'
                    }
                    Occupations    = @(
                        [PSCustomObject]@{
                            Title    = 'Software Engineer'
                            Company  = 'TechCorp'
                            Location = 'New York'
                            Duration = [PSCustomObject]@{
                                Start = '2015-06-01'
                                End   = '2019-08-31'
                            }
                        },
                        [PSCustomObject]@{
                            Title    = 'Senior Developer'
                            Company  = 'CodeWorks'
                            Location = 'San Francisco'
                            Duration = [PSCustomObject]@{
                                Start = '2019-09-01'
                                End   = 'Present'
                            }
                        }
                    )
                    Hobbies        = @('Reading', 'Cycling', 'Hiking')
                    Certifications = @(
                        [PSCustomObject]@{
                            Name       = 'PMP'
                            IssuedBy   = 'PMI'
                            IssueDate  = '2020-01-15'
                            ExpiryDate = '2023-01-15'
                        },
                        [PSCustomObject]@{
                            Name       = 'AWS Certified Solutions Architect'
                            IssuedBy   = 'Amazon Web Services'
                            IssueDate  = '2021-03-10'
                            ExpiryDate = '2024-03-10'
                        }
                    )
                }
                Company       = [PSCustomObject]@{
                    Name      = 'Tech Innovations Inc.'
                    Founded   = '2010'
                    Industry  = 'Technology'
                    Employees = @(
                        [PSCustomObject]@{
                            EmployeeID = 'E001'
                            Name       = 'Bob Johnson'
                            Department = 'Engineering'
                            Title      = 'Chief Engineer'
                            Contact    = [PSCustomObject]@{
                                Email = 'bob.johnson@techinnovations.com'
                                Phone = '555-9876'
                            }
                        },
                        [PSCustomObject]@{
                            EmployeeID = 'E002'
                            Name       = 'Carol Williams'
                            Department = 'Marketing'
                            Title      = 'Marketing Manager'
                            Contact    = [PSCustomObject]@{
                                Email = 'carol.williams@techinnovations.com'
                                Phone = '555-3456'
                            }
                        }
                    )
                }
                Projects      = @(
                    [PSCustomObject]@{
                        ProjectName = 'Project Phoenix'
                        Budget      = 500000
                        TeamMembers = @('Alice', 'Bob', 'Carol')
                        Status      = 'In Progress'
                    },
                    [PSCustomObject]@{
                        ProjectName = 'Project Orion'
                        Budget      = 750000
                        TeamMembers = @('Alice', 'Dave', 'Eve')
                        Status      = 'Completed'
                    }
                )
                Miscellaneous = [PSCustomObject]@{
                    Notes       = @(
                        'This is a sample note.',
                        'Remember to update the project timeline.',
                        'Check on budget allocations next quarter.'
                    )
                    Attachments = @(
                        [PSCustomObject]@{
                            FileName = 'budget_report_q1.pdf'
                            FileSize = '1.2MB'
                        },
                        [PSCustomObject]@{
                            FileName = 'project_plan.docx'
                            FileSize = '350KB'
                        }
                    )
                }
            }
            $hashtable = ConvertTo-Hashtable -InputObject $complexObject
            $hashtable | Should -BeOfType 'Hashtable'
            $hashtable.Keys | Should -Contain 'Person'
            $hashtable.Keys | Should -Contain 'Company'
            $hashtable.Keys | Should -Contain 'Projects'
            $hashtable.Keys | Should -Contain 'Miscellaneous'
            $hashtable.Person.FirstName | Should -Be 'Alice'
            $hashtable.Person.Contact.Email | Should -Be 'alice.smith@example.com'
            $hashtable.Person.Contact.Phone.Home | Should -Be '555-1234'
            $hashtable.Person.Hobbies | Should -Contain 'Hiking'
            $hashtable.Person.Certifications.count | Should -Be 2
        }
    }

    Describe 'ConvertFrom-Hashtable' {
        Context 'ConvertFrom-Hashtable - simple usage' {
            It 'ConvertFrom-Hashtable - converts a flat hashtable to PSCustomObject' {
                $hashtable = @{ Name = 'John Doe'; Age = 30 }
                $result = $hashtable | ConvertFrom-Hashtable

                $result | Should -BeOfType [PSCustomObject]
                $result.Name | Should -Be 'John Doe'
                $result.Age | Should -Be 30
            }
        }

        Context 'ConvertFrom-Hashtable - nested hashtable conversion' {
            It 'ConvertFrom-Hashtable - correctly converts nested hashtables' {
                $hashtable = @{ Address = @{ Street = '123 Main St'; City = 'Somewhere' } }
                $result = $hashtable | ConvertFrom-Hashtable

                $result | Should -BeOfType [PSCustomObject]
                $result.Address | Should -BeOfType [PSCustomObject]
                $result.Address.Street | Should -Be '123 Main St'
                $result.Address.City | Should -Be 'Somewhere'
            }
        }

        Context 'ConvertFrom-Hashtable - array of hashtables' {
            It 'ConvertFrom-Hashtable - converts an array of hashtables to objects' {
                $hashtable = @{ Employees = @(@{ Name = 'Alice' }, @{ Name = 'Bob' }) }
                $result = $hashtable | ConvertFrom-Hashtable

                $result | Should -BeOfType [PSCustomObject]
                $result.Employees.Count | Should -Be 2
                $result.Employees[0] | Should -BeOfType [PSCustomObject]
                $result.Employees[0].Name | Should -Be 'Alice'
                $result.Employees[1].Name | Should -Be 'Bob'
            }
        }

        Context 'ConvertFrom-Hashtable - empty hashtable' {
            It 'ConvertFrom-Hashtable - returns an empty PSCustomObject when input is empty' {
                $result = @{} | ConvertFrom-Hashtable

                $result | Should -BeOfType [PSCustomObject]
                ($result.PSObject.Properties.Name.Count) | Should -Be 0
            }
        }
    }

    Describe 'Format-Hashtable' {
        Context 'An empty hashtable' {
            It 'returns an empty hashtable string' {
                $ht = @{}
                $expected = '@{}'

                $result = Format-Hashtable -Hashtable $ht
                $result | Should -Be $expected
            }
        }

        Context 'Simple Hashtable' {
            It 'formats a simple hashtable correctly' {
                $ht = [ordered]@{
                    Key1 = 'Value1'
                    Key2 = 123
                    Key3 = @{}
                    Key4 = $null
                }
                $expected = @'
@{
    Key1 = 'Value1'
    Key2 = 123
    Key3 = @{}
    Key4 = $null
}
'@.TrimEnd()

                $result = Format-Hashtable -Hashtable $ht
                $result | Should -Be $expected
            }
        }

        Context 'Nested Hashtable' {
            It 'formats a nested hashtable correctly' {
                $ht = [ordered]@{
                    Key1 = 'Value1'
                    Key2 = [ordered]@{
                        NestedKey1 = 'NestedValue1'
                        NestedKey2 = 'NestedValue2'
                        NestedKey3 = @{}
                        NestedKey4 = $null
                        NestedKey5 = ''
                    }
                }
                $expected = @'
@{
    Key1 = 'Value1'
    Key2 = @{
        NestedKey1 = 'NestedValue1'
        NestedKey2 = 'NestedValue2'
        NestedKey3 = @{}
        NestedKey4 = $null
        NestedKey5 = ''
    }
}
'@.TrimEnd()

                $result = Format-Hashtable -Hashtable $ht
                $result | Should -Be $expected
            }
        }

        Context 'Hashtable with Array' {
            It 'formats a hashtable containing an array correctly' {
                $ht = @{
                    Key3 = @(1, 2, 3)
                }
                $expected = @'
@{
    Key3 = @(
        1
        2
        3
    )
}
'@.TrimEnd()

                $result = Format-Hashtable -Hashtable $ht
                $result | Should -Be $expected
            }
        }

        Context 'Hashtable with Boolean' {
            It 'formats boolean values correctly' {
                $ht = @{
                    Key4 = $true
                }
                $expected = @'
@{
    Key4 = $true
}
'@.TrimEnd()

                $result = Format-Hashtable -Hashtable $ht
                $result | Should -Be $expected
            }
        }

        Context 'Escaping Single Quotes' {
            It 'escapes single quotes in string values' {
                $ht = @{
                    Key5 = "O'Reilly"
                }
                # Note: The function replaces one or more single quotes with two single quotes.
                $expected = @'
@{
    Key5 = 'O''Reilly'
}
'@.TrimEnd()

                $result = Format-Hashtable -Hashtable $ht
                $result | Should -Be $expected
            }
        }

        Context 'A complex hashtable structure' {
            It 'Should correctly format a complex nested hashtable' {
                # Arrange - Define the complex test hashtable
                $testHashtable = [ordered]@{
                    StringKey       = "Hello 'PowerShell'!"
                    NumberKey       = 42
                    BooleanKey      = $true
                    NullKey         = $null
                    ArrayKey        = @(
                        'FirstItem'
                        123
                        $false
                        @('NestedArray1', 'NestedArray2')
                        [ordered]@{
                            NestedHashtableKey1 = 'NestedValue1'
                            NestedHashtableKey2 = @(
                                @{ DeepNestedKey = 'DeepValue' }
                                999
                            )
                        }
                    )
                    NestedHashtable = [ordered]@{
                        SubKey1 = 'SubValue1'
                        SubKey2 = @(
                            'ArrayInsideHashtable1'
                            'ArrayInsideHashtable2'
                            ''
                            @{
                                EvenDeeper = "Yes, it's deep!"
                            }
                        )
                    }
                }

                # Act - Run the function
                $formatted = Format-Hashtable -Hashtable $testHashtable

                # Assert - Define the expected output
                $expectedOutput = @'
@{
    StringKey = 'Hello ''PowerShell''!'
    NumberKey = 42
    BooleanKey = $true
    ArrayKey = @(
        'FirstItem'
        123
        $false
        'NestedArray1'
        'NestedArray2'
        @{
            NestedHashtableKey1 = 'NestedValue1'
            NestedHashtableKey2 = @(
                @{
                    DeepNestedKey = 'DeepValue'
                }
                999
            )
        }
    )
    NestedHashtable = @{
        SubKey1 = 'SubValue1'
        SubKey2 = @(
            'ArrayInsideHashtable1'
            'ArrayInsideHashtable2'
            ''
            @{
                EvenDeeper = 'Yes, it''s deep!'
            }
        )
    }
}
'@.Trim() # Trim to remove any unintended whitespace

                # Compare function output to expected output
                $formatted | Should -BeExactly $expectedOutput
            }
        }
    }

    Describe 'Remove-HashtableEntry' {
        Context 'Remove-HashtableEntry - NullOrEmptyValues' {
            It 'Removes keys with null or empty values' {
                $Hashtable = @{
                    'Key1' = 'Value1'
                    'Key2' = 'Value2'
                    'Key3' = $null
                    'Key4' = 'Value4'
                    'Key5' = ''
                }
                $Hashtable | Remove-HashtableEntry -NullOrEmptyValues

                $Hashtable.Keys | Should -Not -Contain 'Key3'
                $Hashtable.Keys | Should -Not -Contain 'Key5'
                $Hashtable.Keys.Count | Should -Be 3
            }
        }

        Context 'Remove-HashtableEntry - RemoveTypes' {
            It 'Removes keys with specified value types' {
                $Hashtable = @{
                    'Key1' = 'Value1'
                    'Key2' = 42
                    'Key3' = $null
                    'Key4' = 'Value4'
                    'Key5' = 3.14
                }
                $Hashtable | Remove-HashtableEntry -Types 'Int32', 'Double'

                $Hashtable.Keys | Should -Not -Contain 'Key2'
                $Hashtable.Keys | Should -Not -Contain 'Key5'
                $Hashtable.Keys.Count | Should -Be 3
            }
        }

        Context 'Remove-HashtableEntry - RemoveNames' {
            It 'Removes specific keys by name' {
                $Hashtable = @{
                    'KeepThis'   = 'Value'
                    'RemoveThis' = 'Delete'
                }
                $Hashtable | Remove-HashtableEntry -Keys 'RemoveThis'

                $Hashtable.Keys | Should -Not -Contain 'RemoveThis'
                $Hashtable.Keys.Count | Should -Be 1
            }
        }

        Context 'Remove-HashtableEntry - KeepTypes' {
            It 'Removes keys not of specified types' {
                $Hashtable = @{
                    'Key1' = 'Value1'
                    'Key2' = 42
                    'Key3' = $null
                    'Key4' = 'Value4'
                    'Key5' = 3.14
                }
                $Hashtable | Remove-HashtableEntry -All -KeepTypes 'String'

                $Hashtable.Keys | Should -Contain 'Key1'
                $Hashtable.Keys | Should -Contain 'Key4'
                $Hashtable.Keys.Count | Should -Be 2
            }
        }

        Context 'Remove-HashtableEntry - KeepNames' {
            It 'Removes keys not matching specified names' {
                $Hashtable = @{
                    'KeepThis'   = 'Value'
                    'RemoveThis' = 'Delete'
                }
                $Hashtable | Remove-HashtableEntry -All -KeepKeys 'KeepThis'

                $Hashtable.Keys | Should -Contain 'KeepThis'
                $Hashtable.Keys | Should -Not -Contain 'RemoveThis'
                $Hashtable.Keys.Count | Should -Be 1
            }
        }
    }
}
