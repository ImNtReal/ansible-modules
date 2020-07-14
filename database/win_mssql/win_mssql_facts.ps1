#!powershell

# Copyright: (c) 2019, Jameson Pugh

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

# Create a new result object
$result = @{
  changed = $false
  ansible_facts = @{
    ansible_mssql =  @{
      instances = @()
    }
  }
}

$instances = [System.Collections.ArrayList]@()

try {
  foreach ($instance in ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances)) {
    $instance_path = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*.$instance" }).PSPath
    if ($instance_path -eq '' -and $instance -eq 'MSSQLSERVER') {
      $instance_path = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*.$env:COMPUTERNAME" }).PSPath
    }
    $instance_port = (Get-ItemProperty -Path "$instance_path\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpPort).TcpPort
	  $instance_info = @{
      name = $instance
      port = $instance_port
	  }
	  $instances.Add($instance_info)
  }
  foreach ($instance in ((Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SQL Server').InstalledInstances)) {
    $instance_path = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*.$instance" }).PSPath
    if ($instance_path -eq '' -and $instance -eq 'MSSQLSERVER') {
      $instance_path = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*.$env:COMPUTERNAME" }).PSPath
    }
    $instance_port = (Get-ItemProperty -Path "$instance_path\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpPort).TcpPort
	  $instance_info = @{
      name = $instance
      port = $instance_port
  	}
  	$instances.Add($instance_info)
  }
} catch {
  Fail-Json -obj $result -message "Failed to get SQL instances on the target: $($_.Exception.Message)"
}

$result.ansible_facts.ansible_mssql.instances = $instances

# Return result
Exit-Json -obj $result
