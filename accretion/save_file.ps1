Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.SaveFileDialog
$FileBrowser.filter = "JSON (*.json)| *.json"
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileName
