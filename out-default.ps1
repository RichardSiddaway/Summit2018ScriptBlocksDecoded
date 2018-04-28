function Out-Default {
  [CmdletBinding(ConfirmImpact='Medium')]
  param(
     [Parameter(ValueFromPipeline=$true)]
     [System.Management.Automation.PSObject] $InputObject
  )
    
BEGIN {
   $wrappedCmdlet = $ExecutionContext.InvokeCommand.GetCmdlet('Out-Default')
   $sb = { & $wrappedCmdlet @PSBoundParameters }
   
   ## create steppable pipeline to run out-default
   $sp = $sb.GetSteppablePipeline()  
   ## start steppable pipeline function object -> steppable pipeline can 
   ##  write directly into function's error & output streams
   $sp.Begin($pscmdlet)

}
PROCESS {
   $doproc = $true
   if ($_ -is [System.Management.Automation.ErrorRecord]) {
      
      ## command not found
      if ($_.Exception -is [System.Management.Automation.CommandNotFoundException]) {
         $command = $_.Exception.CommandName
         
         ## directory or URL. Could add other options
         if (Test-Path -Path $command -PathType container) {
            Set-Location $command  
            $doproc = $false
         }
         elseif ($command -match '^http://|\.(com|org|net|edu)$') {
            if ($matches[0] -ne 'http://') {
               $command = 'HTTP://' + $command
            }
            [System.Diagnostics.Process]::Start($command)
            $doproc = $false
         }
      }
   }
   ## assign output to $last
   if ($doproc) {
      $global:LAST = $_;
      $sp.Process($_)
    }
}
END {
   $sp.End()
}
}