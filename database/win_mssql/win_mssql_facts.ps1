#!powershell

# Copyright: (c) 2019, Jameson Pugh

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

# Create a new result object
$result = @{
  changed = $false
  ansible_facts = @{
    ansible_mssql =  @{
      instances = @{}
    }
  }
}

try {
  foreach ($instance in ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances)) {
	$instances += $instance
  }
  foreach ($instance in ((Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SQL Server').InstalledInstances)) {
	$instances += $instance
  }
} catch {
  Fail-Json -obj $result -message "Failed to get SQL instances on the target: $($_.Exception.Message)"
}

$result.ansible_facts.ansible_mssql.instances = $instances

# Return result
Exit-Json -obj $result
