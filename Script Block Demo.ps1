###############################################################################
##
##  Scriptblocks  - PowerShell Summit 2018
##     
##    Richard Siddaway
##
##   All code is made available as is without 
##     any warranty or guarantee
## 
###############################################################################

############################################################################### 
##  Script block basics
##
##  script block is list of statements in {}
$sb = {
  $x = 1 
  $y = 2
  $x + $y
}

## if use variable - just see code
$sb

## run script block
Invoke-Command -ScriptBlock $sb

## can also use call operator &
& $sb

## will use & from now on
##   less typing :-)

## basic function
##  only difference is name
##  and function key word
function f1 {
  $x = 1 
  $y = 2
  $x + $y
}

## usually just use function name
f1

##  call operator works
##  but not Invoke-Command
& f1

## digging into function
Get-Item -Path function:\f1 | Format-List *

##  Notice scriptblock !!!
Get-Item -Path function:\f1 | select name
Get-Item -Path function:\f1 | Format-List Scriptblock 

##
##  YOU CAN CHANGE THE FUNCTION
##

$function:f1 = {
  $x = 2 
  $y = 3
  $x * $y
}

f1

##  lets dig into script blocks
$sb | Get-Member

## another way to run script blocks
$sb.Invoke()

## assign results to variable
$a = & $sb
$a

## or
$b = $sb.Invoke()
$b

## parameters into a script block
$sb = {
  param (
    [int]$x = 1,
    [int]$y = 2
  )
  $x + $y
}

## default parameters work
& $sb 

& $sb 3 5 

## or 
Invoke-Command -ScriptBlock $sb -ArgumentList 3,5 

############################################################################### 
## compare with function
## script block CAN'T do this
function f1 ([int]$x = 1, [int]$y = 2) {
  $x + $y
} 

f1

## function better with param block
function f1  {
  param (
   [int]$x = 1, 
   [int]$y = 2
  )
  $x + $y
} 

f1

## script block can't do this
f1 -x 3 -y 5

## script block CAN use parameter validation
$sb = {
  param (
    [ValidateRange(1,5)]
    [int]$x = 1,
    [ValidateRange(2,6)]
    [int]$y = 2
  )
  $x + $y
}

& $sb

& $sb 4 7


## script block CAN use mandatory parameters
$sb = {
  [CmdletBinding()]
  param (
    [ValidateRange(1,5)]
    [int]$x = 1,
    
    [Parameter(Mandatory=$true)]
    [ValidateRange(2,6)]
    [int]$y = 2
  )
  $x + $y
}

& $sb 4 5

& $sb 4

## script block is anonymous function
##  some things such as parameter sets
##  don't make sense for script block

############################################################################### 
##
##  How do you handle scope 
##    in script blocks
##

##  
##  functions scan up scope
##
$x = 5

function f1 {
  $y = 6
  $x + $y
}

f1

##
## invoked script blocks do the same 
##


$sb = {
  $y = 6
  $x + $y
}

& $sb

Invoke-Command -ScriptBlock $sb


##
##  script blocks in  jobs
##


Start-Job -Name j1 -ScriptBlock $sb
Wait-Job -Name j1

Receive-Job -Name j1

Get-Job | Remove-Job

##
## to see what's happening
##

$sb = {
  "`$x = $x"
  $y = 6
  $x + $y
}

Start-Job -Name j1 -ScriptBlock $sb
Wait-Job -Name j1

Receive-Job -Name j1

Remove-Job -Name j1

##
## $x not in context
##  $using: added in PowerShell v3
##

$sb = {
  "`$x = $using:x"
  $y = 6
  $using:x + $y
}

Start-Job -Name j1 -ScriptBlock $sb
Wait-Job -Name j1

Receive-Job -Name j1

Remove-Job -Name j1

##
## Alternative is to 
##   use parameters

$sb = {
  param ( $x)
  $y = 6
  $x + $y
}

Start-Job -Name j1 -ScriptBlock $sb -ArgumentList $x
Wait-Job -Name j1

Receive-Job -Name j1

Remove-Job -Name j1

############################################################################### 
##
## when remoting variables defined in remote session
##   script block runs in own scope
##
$x = 5
$sb = {
  "`$x = $x"
  $y = 6
  $x + $y
}
Invoke-Command -ComputerName W16AS01 -ScriptBlock $sb

$sb = {
  "`$x = $using:x"
  $y = 6
  $using:x + $y
}
Invoke-Command -ComputerName W16AS01 -ScriptBlock $sb

##
##  NONEWSCOPE
##   only if no session or computername
##
$sb = {
  "`$x = $x"
  $y = 6
  $x + $y
}
Invoke-Command -ScriptBlock $sb -NoNewScope

Invoke-Command -ComputerName W16AS01 -ScriptBlock $sb -NoNewScope

############################################################################### 
##
##  script blocks in split
##
##  want to split on commas but leave in pairs
$str = 'Jack,Jill,Bill,Ben,Eric,Ernie,Cagney,Lacey'
$count=@(0)
$count
$str -split {$_ -eq ',' -AND ++$count[0] % 2 -eq 0}
$count

############################################################################
##  DYNAMIC MODULES
##
##  script module - when want persistant resources
##    NOT exposed at global level
$sb = {
  $c = 0
  function Get-NextCount {
    $script:c++
    $script:c
  }
  function Reset-Count {
    $script:c = 0
  }
}
$dm = New-Module -ScriptBlock $sb
Get-NextCount
1..10 | foreach { Get-NextCount}
Reset-Count
Get-NextCount

## view module
##  note name
Get-Module

$dm | Format-List

$dm | Import-Module
Get-Module

## explicit name
## and force import
Get-Module -Name '*dynamic*' | Remove-Module

$dm = New-Module -Name Summit2018  -ScriptBlock $sb|
Import-Module

Get-Module
Get-Command -Module Summit2018

Remove-Module -Name Summit2018

############################################################################### 
##
##  closure = inverse of object
##  closure = function with data attached
##  object = data with methods
##
##  useful when want to change something
##   post function definition 
function New-Counter {
  param ([int]$increment = 1)

    $count=0
    
    $sb = { 
      $script:count += $increment
       $count
    }
    
    $sb.GetNewClosure()
}

$c1 = New-Counter

$c1 | Get-Member

& $c1
& $c1
& $c1

$c1 | Get-Member

$c2 = New-Counter 2

& $c2
& $c2
& $c2

& $c1
& $c1

##
##  new closure creates a dynamic module &
##   all variables in caller's scope are copied into the new module
##

##
## when module loaded exported functions are closures
##  bound to module object. Closures are assigned to 
##  names of functions to import 


##  go to proxy demo
##   run out-default BEFORE demo !!