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
    foreach ($Path in (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*" }).PSPath) {  
      if ((Get-ItemProperty -Path $Path).'(default)' -eq $instance) {
        $instance_path = $Path
      }
    }
    if ($instance_path -eq $null -and $instance -eq 'MSSQLSERVER') {
      $instance_path = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*.$env:COMPUTERNAME" }).PSPath
    }
    $instance_port = (Get-ItemProperty -Path "$instance_path\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpPort).TcpPort
    if ($instance_port -eq '') {
      $instance_port = (Get-ItemProperty -Path "$instance_path\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpDynamicPorts).TcpDynamicPorts
    }
    if ($instance = 'MSSQLSERVER') {
      $instance_instance = "$env:COMPUTERNAME"
    } else {
      $instance_instance = "$env:COMPUTERNAME\$instance"
    }
	  $instance_info = @{
      name = $instance
      port = $instance_port
      reg_path = $instance_path -replace 'Microsoft.PowerShell.Core\\Registry::HKEY_LOCAL_MACHINE', "HKLM:"
      instance = $instance_instance
	  }
	  $instances.Add($instance_info)
  }
  foreach ($instance in ((Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SQL Server').InstalledInstances)) {
    foreach ($Path in (Get-ChildItem -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*" }).PSPath) {
      if ((Get-ItemProperty -Path $Path).'(default)' -eq $instance) {
        $instance_path = $Path
      }
    }
    if ($instance_path -eq $null -and $instance -eq 'MSSQLSERVER') {
      $instance_path = (Get-ChildItem -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SQL Server' | Where-Object { $_.Name -like "*MSSQL*.$env:COMPUTERNAME" }).PSPath
    }
    $instance_port = (Get-ItemProperty -Path "$instance_path\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpPort).TcpPort
    if ($instance_port -eq '') {
      $instance_port = (Get-ItemProperty -Path "$instance_path\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpDynamicPorts).TcpDynamicPorts
    }
    if ($instance = 'MSSQLSERVER') {
      $instance_instance = "$env:COMPUTERNAME"
    } else {
      $instance_instance = "$env:COMPUTERNAME\$instance"
    }
	  $instance_info = @{
      name = $instance
      port = $instance_port
      reg_path = $instance_path -replace 'Microsoft.PowerShell.Core\\Registry::HKEY_LOCAL_MACHINE', "HKLM:"
  	}
  	$instances.Add($instance_info)
  }
} catch {
  Fail-Json -obj $result -message "Failed to get SQL instances on the target: $($_.Exception.Message)"
}

$result.ansible_facts.ansible_mssql.instances = $instances

# Return result
Exit-Json -obj $result
