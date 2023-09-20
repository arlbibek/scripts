<#
.SYNOPSIS
This PowerShell script simplifies the process of installing applications (.exe files) from a specified directory.

.DESCRIPTION
The script creates a Windows Forms GUI that allows you to select and install .exe files from a chosen directory. 
It includes features like selecting all apps and providing real-time updates based on the directory path you specify.

.NOTES
Made with ❤️ by Bibek Aryal.
GitHub Repository: https://github.com/arlbibek/scripts/blob/master/install-from-dir.ps1
#>

# Check if the script is running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Script is not running as administrator. Restarting with elevated privileges..."
    Start-Process -FilePath PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs
    Exit
}

# Add this at the beginning of your script to indicate that the script is running with elevated privileges
Write-Host "Script started with elevated privileges."

Add-Type -AssemblyName System.Windows.Forms

# Define the initial path to the directory containing .exe files
$exeDirectory = "C:\Users\bibek\Downloads\apps\exe"

# Create a new Windows Forms window
$mainForm = New-Object Windows.Forms.Form
$mainForm.Text = "App Installer"
$mainForm.Size = New-Object Drawing.Size(400, 330)  # Increased the form height to accommodate the "Select All" checkbox

# Create a label with a larger font size
$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point(10, 10)
$label.Size = New-Object Drawing.Size(250, 20)
$label.Text = "Select apps to install"
$label.Font = New-Object Drawing.Font("Arial", 12, [Drawing.FontStyle]::Bold)
$mainForm.Controls.Add($label)

# Create a label with a larger font size
$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point(10, 30)
$label.Size = New-Object Drawing.Size(95, 15)
$label.Text = "Path to .exe: "
$label.Font = New-Object Drawing.Font("Arial", 10)
$mainForm.Controls.Add($label)

# Create a Windows Forms TextBox for the directory path
$textBox = New-Object Windows.Forms.TextBox
$textBox.Location = New-Object Drawing.Point(105, 30)
$textBox.Size = New-Object Drawing.Size(270, 15)
$textBox.Text = $exeDirectory
$mainForm.Controls.Add($textBox)

# Create a CheckedListBox with larger font size
$checkedListBox = New-Object Windows.Forms.CheckedListBox
$checkedListBox.Location = New-Object Drawing.Point(10, 55)
$checkedListBox.Size = New-Object Drawing.Size(365, 150)
$checkedListBox.Font = New-Object Drawing.Font("Arial", 12)
$mainForm.Controls.Add($checkedListBox)

# Function to update the CheckedListBox based on the directory path
function UpdateCheckedListBox {
    $newExeDirectory = $textBox.Text

    # Check if the directory exists
    if (Test-Path -Path $newExeDirectory -PathType Container) {
        # List all .exe files in the directory
        $exeFiles = Get-ChildItem -Path $newExeDirectory -Filter "*.exe" | Select-Object -Property Name

        if ($exeFiles.Count -eq 0) {
            $checkedListBox.Items.Clear()
            $checkedListBox.Items.Add("No .exe files found in the directory.")
        }
        else {
            $checkedListBox.Items.Clear()
            foreach ($exeFile in $exeFiles) {
                $checkedListBox.Items.Add($exeFile.Name)
            }
        }
    }
    else {
        $checkedListBox.Items.Clear()
        $checkedListBox.Items.Add("The specified directory does not exist.")
    }
}

# Add an event handler to update the CheckedListBox when the TextBox text changes
$textBox.Add_TextChanged({
        UpdateCheckedListBox
    })

# Call the function initially to populate the CheckedListBox
UpdateCheckedListBox

# Create a "Select All" checkbox with a larger font size
$selectAllCheckbox = New-Object Windows.Forms.CheckBox
$selectAllCheckbox.Location = New-Object Drawing.Point(10, 195)  # Adjusted the Y coordinate for spacing
$selectAllCheckbox.Size = New-Object Drawing.Size(150, 20)
$selectAllCheckbox.Text = "Select all"
$selectAllCheckbox.Font = New-Object Drawing.Font("Arial", 12)
$selectAllCheckbox.Add_Click({
        # Handle the "Select All" checkbox click event
        $selectAll = $selectAllCheckbox.Checked
        for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
            $checkedListBox.SetItemChecked($i, $selectAll)
        }
    })
$mainForm.Controls.Add($selectAllCheckbox)

# Create an "Install" button with a larger font size
$installButton = New-Object Windows.Forms.Button
$installButton.Location = New-Object Drawing.Point(200, 195)  # Adjusted the Y coordinate for spacing
$installButton.Size = New-Object Drawing.Size(175, 30)
$installButton.Text = "Install selected apps"
$installButton.Font = New-Object Drawing.Font("Arial", 12)

$installButton.Add_Click({
        # Get the selected apps from the CheckedListBox
        $selectedApps = $checkedListBox.CheckedItems

        if ($selectedApps.Count -eq 0) {
            [Windows.Forms.MessageBox]::Show("No apps selected for installation.", "Info", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        }
        else {
            # Get the directory path from the TextBox
            $exeDirectory = $textBox.Text

            # Install the selected apps
            foreach ($app in $selectedApps) {
                $selectedFile = $app.ToString()
                $fullPath = Join-Path -Path $exeDirectory -ChildPath $selectedFile

                Write-Host "Installing $selectedFile"
                Write-Host "Please proceed to the ($selectedFile) GUI for the further process."
                Start-Process -FilePath $fullPath -Wait
                Write-Host "$selectedFile installation completed (hopefully)."
            }

            [Windows.Forms.MessageBox]::Show("Installation completed.", "Info", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        }
    })

$mainForm.Controls.Add($installButton)

# Create a label with a larger font size
$lableMadeby = New-Object Windows.Forms.Label
$lableMadeby.Location = New-Object Drawing.Point(10, 250)
$lableMadeby.Size = New-Object Drawing.Size(300, 20)
$lableMadeby.Text = "Made with v3 by Bibek Aryal."
$lableMadeby.Font = New-Object Drawing.Font("Arial", 10)
$mainForm.Controls.Add($lableMadeby)

# Show the form
$mainForm.ShowDialog()

# Dispose of the form
$mainForm.Dispose()

# Add this at the end of your script to indicate that the script has completed
Write-Host "Script completed."
Write-Host "Made with ❤️ by Bibek Aryal."
