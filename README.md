
Name:         PSLogger
Version:      0.1
Author:       Kevin Doblosky (kdoblosky@gmail.com)
Source:       https://github.com/kdoblosky/PSLogger
Last Updated: 2013-09-29


Easily create strongly typed PowerShell Logger functions that can be reused in scripts
or in the console.

Includes function New-Logger. Pass it a name for a logger, a location to store the 
generated script and logfile, and a hashmap containing property names and type, and
it will generate two functions, Add-$loggername and Get-$loggername.

These functions are added to the current global scope, saved to a script file, and  
optionally added to the current user profile.


Example use:

PS D:\PowerShellScripts> $arguments = @{"Title" = "String"; "Author" = "String"; "DateStarted" = "DateTime"; "DateCompleted" = "DateTime"}

PS D:\PowerShellScripts> New-Logger -LoggerName Books -AddToProfile -Arguments $arguments
Created functions Add-Books and Get-Books
Functions stored in D:\PowerShellScripts\Books-Script.ps1
Functions loaded into current session
Functions already listed in profile

PS D:\PowerShellScripts> Add-Books -Title "The Count of Monte Cristo" -Author "Alexander Dumas" -DateStarted "2013-08-30" -DateCompleted (Get-Date)

PS D:\PowerShellScripts> Add-Books -Title "The Moon is a Harsh Mistress" -Author "Robert Heinlein" -DateStarted "2013-08-20" -DateCompleted "2013-08-29"

PS D:\PowerShellScripts> Get-Books


LogTime       : 2013-09-29 01:24:46
DateStarted   : 8/30/2013 7:00:00 AM
Title         : The Count of Monte Cristo
DateCompleted : 9/29/2013 8:24:46 PM
Author        : Alexander Dumas

LogTime       : 2013-09-29 01:25:23
DateStarted   : 8/20/2013 7:00:00 AM
Title         : The Moon is a Harsh Mistress
DateCompleted : 8/29/2013 7:00:00 AM
Author        : Robert Heinlein
