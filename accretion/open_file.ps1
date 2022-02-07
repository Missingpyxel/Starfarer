Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.filter = "JSON (*.json)| *.json"
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileName
