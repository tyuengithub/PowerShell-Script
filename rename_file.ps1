get-childitem 'C:\Projects\Endeca\compare indexes\WebZ20L12\*.*' | foreach { rename-item $_ $_.Name.Replace("WebZ20L12.", "") }

get-childitem 'C:\Projects\Endeca\compare indexes\WebZ1L1\*.*' | foreach { rename-item $_ $_.Name.Replace("WebZ1L1.", "") }

get-childitem 'C:\Projects\Endeca\compare indexes\WebZ2L11\*.*' | foreach { rename-item $_ $_.Name.Replace("WebZ2L11.", "") }


get-childitem 'C:\Projects\Endeca\compare indexes\WebZ2L10.prod\*.*' | foreach { rename-item $_ $_.Name.Replace("WebZ2L10.", "") }

get-childitem 'C:\Projects\Endeca\compare indexes\WebZ2L10.qa\*.*' | foreach { rename-item $_ $_.Name.Replace("WebZ2L10.", "") }
