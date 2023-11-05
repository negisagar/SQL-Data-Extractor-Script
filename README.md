# SQL-Data-Extractor-Script
Powerful PowerShell script for extracting SQL table data to CSV. Simplify data extraction with ease.

# Simplified Data Extraction: Harnessing the Power of PowerShell for Seamless SQL Server Data Access
Creating a streamlined and efficient data extraction process is a crucial aspect of any data-driven project. As a developer, I often find myself at the crossroads of facilitating data access for our functional team, who are well-versed in tools like Alteryx and Power BI but not SQL or SSMS. Their primary focus is to create stunning dashboards and reports for our clients, and they frequently require data extracts from tables with millions of rows and numerous columns.

To address this need and make the data extraction process more seamless, I embarked on a journey to develop a PowerShell script that would streamline and orchestrate this entire workflow. The ultimate goal was to create a tool that anyone, regardless of their SQL expertise, could use to access the data they needed with ease. The result was an ingenious PowerShell script that not only simplifies the process but also enhances productivity.

![Image Alt Text](/images/Powershell.jpg)

## The Prerequisite
Before diving into the script, you need to ensure that the SQL Server Management Studio (SSMS) component “Invoke-Sqlcmd” is installed. This component is essential for executing SQL queries from within the PowerShell script. It provides a bridge between your PowerShell script and the SQL Server, enabling you to interact with your databases seamlessly.

GitHub link [here](https://gist.github.com/cunn1645/8d791a99271da8a57236ebce8f920718).
 contains all commands to run in PowerShell to install “Sqlcmd”.


## The Script — Streamlining Data Extraction
When I created this script, I used it for my internal project use and hardcoded the server instance, username and password. In future iteration of the development, it can be modified as an input.
Anyone can modify the script with their server details as shown below.

```powershell
# Define your server details
$ServerInstance = "YourServerName"
$Username = "YourUsername"
$Password = "YourPassword"
```

## Database Selection
Once these configurations are in place, the script lists the databases available on your server. It prompts you to select the specific database from which you want to extract data. The database selection is a one-time process. Once you've chosen your database, the script will remember it for future use.

```powershell
# List and select the database
$databases = Get-Databases
$selectedDb = Select-Database $databases
```

## Organizing the Data
Upon selecting the database, the magic happens. The script creates a folder on your desktop, named after the chosen database. Within this folder, sub-folders are generated, each corresponding to a schema within the database. These schema folders serve as containers for the PowerShell scripts associated with the tables in the respective schema.

```powershell
# Organize data into folders
Create-DatabaseFolder $selectedDb
$schemas = Get-Schemas $selectedDb
Create-SchemaFolders $selectedDb $schemas
```

![Sub-scripts created on desktop in a well-organized manner.](/images/organizing%20data.jpg)

## Generating PowerShell Scripts
Now, here's where the script takes its innovative approach. For each table in a schema, it dynamically generates a PowerShell script. These scripts can be used to export data from the respective table. It creates a folder structure for the script which can be seen on the above screenshot.
Honestly speaking a script in a script is a genius idea and I’m pretty proud of this.

## Exporting Data
When you run one of these table scripts, it creates another folder structure on your desktop. For example, you ran the table1.ps1 script as shown in the above screenshot. It follows the pattern of "DatabaseName_Export" -> "SchemaName," and within the schema folder, you'll find the exported CSV file of the table. This exported file can be utilized as needed.

![Csv file exported on desktop in an organized folder strucutre.](/images/exporting%20data.jpg)

The PowerShell script orchestrates this process, making it an invaluable tool for anyone who needs to access and export data frequently, regardless of their SQL expertise.

In summary, this PowerShell script not only simplifies the data extraction process but also empowers a broader audience within your team to access and work with data effectively. It's a testament to the power of automation and intelligent scripting in streamlining and enhancing data workflows.

With this tool in hand, the process of extracting and sharing data becomes a breeze, and everyone on the team can focus on what they do best, whether it’s building dashboards, creating reports, or developing data-driven solutions. The power of a well-crafted script can indeed be transformative.

So, the next time you find yourself needing to access data swiftly and efficiently, consider developing a script like this to supercharge your data workflow.

### Author’s note
The script was created with the help of ChatGPT where I spent some days with it by reiterating my idea and manually editing the script without prior knowledge of PowerShell scripting. ChatGPT is not that advance yet where I can give it my idea and it creates the whole script. I had to break my idea into pieces where I started with the export part first and then nested it into creating it as a reusable sub-script. Mail me at negi.sagar91@gmail.com if you need a thorough explanation on how I created this script with the help of ChatGPT.






