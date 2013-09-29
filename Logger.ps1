# TODO: Test $Location, check for existence of log file
#       If it does exist, warn user that structure may be changing
#       If it does not already exist, initialize it with comment
#       detailing structure of log file, and that it was created by this function
#
# TODO: Create option to write to custom system log, instead of text file
#
# TODO: Allow separate locations for logfile and script file
#
Function New-Logger ($LoggerName, $Arguments="", $Location="", [switch]$AddToProfile)
{
<#
.DESCRIPTION
Generates two cmdlets to write and read to a custom logfile, with the defined parameters. 
Entries are stored in the logfile as JSON, so are read back as objects.

.PARAMETER LoggerName
Specifies the name for the logger. Should not include any extension. The log file will be called $LoggerName.log, and 
two functions will be generated: Write-$LoggerName and Read-$LoggerName

.PARAMETER Arguments
Hashmap, where Name specifies the name of a field in the log, and 
Value specifies the data type of the field. If not provided, user will be prompted to enter information for fields

.PARAMETER Location
Specifies the location of the script file, and the log. If blank, uses the users current directory

.PARAMETER AddToProfile
If true, adds a line to curent profile dot sourcing the script

.EXAMPLE
> $bookArgs = @{
    "Title" = "string";
    "Author" = "string";
    "Year" = "int";
    "Genre" = "string"
}

> Create-Logger -LoggerName Book -Arguments $bookArgs -AddToProfile

Creates functions Write-Book and Read-Book, adds a line to profile, dotsourcing script file


.NOTES
Written by Kevin Doblosky (kdoblosky@gmail.com). Licensed under GPLv3 (http://www.gnu.org/licenses/gpl.html).
#>

    Function GetLoggerArgumentsFromUser
    {
	    #$arguments = @()
        $arguments = @{}

        $loop = $true
	    while ($loop)
	    {
		    Write-Host "Enter argument name (hit Enter when done):"
		    $name = Read-Host
            if ($name -eq "")
            {
                $loop = $false
            }
            else
            {
		        Write-Host
		        Write-Host "Enter argument type (string, Int, Switch, decimal):"
		        $type = Read-Host
                Write-Host

                # TODO: Check for duplicates and warn user
                $arguments.Add($name, $type)
            }
	    }
    
        Write-Output $arguments
    }

    Function GetArgumentString($argName, $argType)
    {
        $typeNotation = ""
        if (! [String]::IsNullOrWhiteSpace($argType))
        {
            # TODO: Validate that it's a valid type
            $typeNotation = "[$argType] "
        }

        "$typeNotation`$$argName"
    }


    if ($Arguments -eq "") {$Arguments = GetLoggerArgumentsFromUser}

    # argList is used to build parameters string for Write-LoggerName function
    # It is an array, with each entry of the form "[Type] $Name"
    
    $argList = ($Arguments.GetEnumerator() | ForEach-Object { GetArgumentString -argName ($_.Name) -argType ($_.Value) }) -join ", "

    # If location isn't specified, use current folder
    if ($Location -eq "") {$Location = (Get-Item .).FullName + "\"}

    # Set filename to use for storing the log
    $logFileName = $Location + $LoggerName + ".log"
    
    # Set filename to use for storing the scripts
    $scriptFileName = $Location + $LoggerName + "-Script.ps1"


    # Create Write-LoggerName Function
    $text =  @"
    # Functions generated by PSLogger (https://github.com/kdoblosky/PSLogger)
    # PSLogger created by Kevin Doblosky
    # Creation Date: $((Get-Date).ToString("yyyy-MM-dd hh:mm:ss"))
    

    function global:Add-$LoggerName($argList)
    {
        `$timeStamp = (Get-Date).ToString("yyyy-MM-dd hh:mm:ss")

        # Build object from parameters
        `$obj = New-Object -TypeName PSObject
        `$obj | Add-Member -MemberType NoteProperty -Name LogTime -Value `$timeStamp

        $(
            # Loop through Arguments, and add property to the object for each
            $Arguments.GetEnumerator() | ForEach-Object {
                "        `$obj | Add-Member -MemberType NoteProperty -Name $($_.Name) -Value `$$($_.Name) `n"
            }
            
        )

        # Convert object to json
        `$json = `$obj | ConvertTo-Json -Compress

        # Write to log file
        Add-Content -Path $logFileName -Value `$json 
    }


    # Create Read-LoggerName Function
    function global:Get-$LoggerName()
    {
        # Generated by Create-Logger cmdlet
        Get-Content $logFileName | Where-Object { !(`$_.StartsWith("#")) } | ForEach-Object { ConvertFrom-Json -InputObject `$_ }
    }
"@

    # Write generated functions to text file
    Set-Content -Value $text -Path $scriptFileName

    Write-Output "Created functions Write-$LoggerName and Read-$LoggerName"
    Write-Output "Functions stored in $scriptFileName"

    # Dot source the file name, so that functions get loaded.
. $scriptFileName

    Write-Output "Functions loaded into current session"

    if ($AddToProfile)
    {
        # Backup profile
        if (Test-Path $profile)
        {
            # Escape slashes and dots in filename
            $stringToMatch = ". $( $scriptFileName.Replace("\", "\\").Replace(".", "\.") )"
            if (! (Get-Content $profile | Select-String -Pattern $stringToMatch -Quiet))
            {
                $profileBackup = (Get-Item $profile).DirectoryName + "\" + (Get-Item $profile).BaseName + ".bak"
                Copy-Item -Path $profile -Destination $profileBackup
                Add-Content -Path $profile -Value ". $scriptFileName"
                Write-Output "Functions dot sourced in profile, so they will be available in all future sessions"
            }
            else
            {
                Write-Output "Functions already listed in profile"
            }
        }
        
        
    }
    
}
