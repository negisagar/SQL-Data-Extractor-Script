


# ASCII Art with Thick Border
Write-Host "
+-----------------------------------------------------------------------------+
|           _______ _______ ______         _______                            |
|              |    |_____| |_____] |      |______                            |
|              |    |     | |_____] |_____ |______                            |
|                                                                             |
|  _______ _     _ _______  ______ _______ _______ _______  _____   ______    |
|  |______  \___/     |    |_____/ |_____| |          |    |     | |_____/    |
|  |______ _/   \_    |    |    \_ |     | |_____     |    |_____| |    \_    |
|                                                                             |
+-----------------------------------------------------------------------------+
"


# Server details
$serverInstance = "YourServerName"
$username = "YourUsername"
$password = "YourPassword"

# Set server details
$ServerInstance = $serverInstance
$Username = $username
$Password = $password





# Function to get databases
function Get-Databases {
    $query = "SELECT name FROM sys.databases;"
    return Invoke-Sqlcmd -Query $query -ServerInstance $ServerInstance -Username $Username -Password $Password
}

# Function to get tables from a database
function Get-Tables($database) {
    $query = "SELECT TABLE_NAME, TABLE_SCHEMA FROM $database.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';"
    return Invoke-Sqlcmd -Query $query -ServerInstance $ServerInstance -Database $database -Username $Username -Password $Password
}

# Function to get schemas from a database
function Get-Schemas($database) {
    $query = "SELECT DISTINCT TABLE_SCHEMA FROM $database.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';"
    return Invoke-Sqlcmd -Query $query -ServerInstance $ServerInstance -Database $database -Username $Username -Password $Password
}

# Function to create a PowerShell script for each table in the schema sub-folder
function Create-ExportScripts($database, $schema, $folderPath) {
    $tables = Get-Tables $database
    foreach ($table in $tables) {
        if ($table.TABLE_SCHEMA -eq $schema.TABLE_SCHEMA) {
            $scriptContent = @"
`$Query = "SELECT * FROM ${database}.$($schema.TABLE_SCHEMA).$($table.TABLE_NAME);"
`$ServerInstance = "$ServerInstance"
`$Database = "$database"
`$Username = "$Username"
`$Password = "$Password"
`$ExportPath = "$env:USERPROFILE\Desktop\${database}_Exports\$($schema.TABLE_SCHEMA)\$($table.TABLE_NAME).csv"

# Create export directory if it does not exist
`$ExportDir = "$env:USERPROFILE\Desktop\${database}_Exports\$($schema.TABLE_SCHEMA)"
if (-not (Test-Path -Path `$ExportDir -PathType Container)) {
    New-Item -Path `$ExportDir -ItemType Directory
}

# Capture the start time
`$startTime = Get-Date

# Execute the export command
Invoke-Sqlcmd -Query `$Query -ServerInstance `$ServerInstance -Database `$Database -Username `$Username -Password `$Password | Export-Csv -Path `$ExportPath -NoTypeInformation

# Execute the export command and count records
`$result = Invoke-Sqlcmd -Query `$Query -ServerInstance `$ServerInstance -Database `$Database -Username `$Username -Password `$Password


# Calculate and display the elapsed time
`$endTime = Get-Date
`$elapsedTime = `$endTime - `$startTime


# Check if the result is not empty and contains records
if (`$result -ne `$null -and `$result.Count -gt 0) {
    `$elapsedSeconds = `$elapsedTime.TotalSeconds
    `$elapsedHours = [math]::Floor(`$elapsedSeconds / 3600)
    `$elapsedMinutes = [math]::Floor((`$elapsedSeconds % 3600) / 60)
    `$elapsedSeconds = `$elapsedSeconds % 60

    `$elapsedTimeString = ""
    if (`$elapsedHours -gt 0) {
        `$elapsedTimeString += "`$elapsedHours hour(s) "
    }
    if (`$elapsedMinutes -gt 0) {
        `$elapsedTimeString += "`$elapsedMinutes minute(s) "
    }
    `$elapsedTimeString += "`$elapsedSeconds second(s)"

    Write-Host "Export completed successfully! Time taken: `$elapsedTimeString"
    Write-Host "Number of records loaded: `$(`$result.Count)"
} else {
    Write-Host "No records were loaded."
}

# Prompt the user to press any key to exit
Write-Host "Press any key to exit..."
`[Console]::ReadKey() | Out-Null
"@
            $scriptPath = Join-Path -Path $folderPath -ChildPath ("$($table.TABLE_NAME).ps1")
            $scriptContent | Out-File -FilePath $scriptPath -Encoding utf8
        }
    }
}

# Get and display the list of databases
$databases = Get-Databases
Write-Host "Available Databases:"
Write-Host
#$databases | ForEach-Object { Write-Host $_.name }
$databases | ForEach-Object { $index = [array]::IndexOf($databases, $_) + 1; Write-Host "$index. $($_.name)" }

# Prompt the user to select a database by number
while ($true) {
    Write-Host
    $selectedDatabaseIndex = Read-Host "Please enter the number of the database you want to select"
    Write-Host

    # Validate the input as an integer
    if ([int]::TryParse($selectedDatabaseIndex, [ref]$null)) {
        $selectedDatabaseIndex = [int]$selectedDatabaseIndex

        # Check if the input number is within the valid range
        if ($selectedDatabaseIndex -ge 1 -and $selectedDatabaseIndex -le $databases.Count) {
            # Get the selected database name
            $selectedDatabase = $databases[$selectedDatabaseIndex - 1].name
            break  # Exit the loop if the input is valid
        }
    }

    Write-Host "Invalid input. Please enter a valid number within the range (1 to $($databases.Count))."
}


# Get the selected database name
$selectedDatabase = $databases[$selectedDatabaseIndex - 1].name

# Validate the selected database
if ($databases.name -contains $selectedDatabase) {
    # Get and display the tables in the selected database
    $tables = Get-Tables $selectedDatabase
    Write-Host "Tables in ${selectedDatabase}:"
    $tables | ForEach-Object { Write-Host $_.TABLE_NAME }
    
    # Create a folder on the desktop with the name of the selected database
    $desktopPath = "$env:USERPROFILE\Desktop"
    $folderPath = Join-Path -Path $desktopPath -ChildPath $selectedDatabase
    
    # Remove folder if it already exists, then create a new one
    if (Test-Path -Path $folderPath -PathType Container) {
        Remove-Item -Path $folderPath -Recurse -Force
    }
    
    New-Item -Path $folderPath -ItemType Directory
    Write-Host "Folder created at $folderPath"
    
    # Create sub-folders for each schema in the selected database and create export scripts in each sub-folder
    $schemas = Get-Schemas $selectedDatabase
    foreach ($schema in $schemas) {
        $schemaFolder = Join-Path -Path $folderPath -ChildPath $schema.TABLE_SCHEMA
        New-Item -Path $schemaFolder -ItemType Directory
        Write-Host "Sub-folder created for schema at $schemaFolder"
        
        # Call the function to create export scripts in the schema sub-folder
        Create-ExportScripts $selectedDatabase $schema $schemaFolder
    }
    Write-Host
    Write-Host "Script Generation successfull! Check Desktop"
} else {
    Write-Host "Invalid database selected."
}
