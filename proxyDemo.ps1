###############################################################################
##
##  Proxy Demo  - PowerShell Summit 2018
##   make result of last command available in variable
##     
##    Richard Siddaway
##
##   All code is made available as is without 
##     any warranty or guarantee
## 
###############################################################################

## use last result
##  arithmetic
2 + 2
$last + 3
$last + 6
$last * 7

## use last result
##  admin
'notepad'

Start-Process $last
Get-Process $last
Stop-Process $last
                                                                            
Get-Location                                                                            
Push-Location                                                                           

C:\Source                                                                               

Get-Location                                                                            
Pop-Location 

##
##  show out-default 
##