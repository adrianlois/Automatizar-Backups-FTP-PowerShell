######################
# Autor @adrianlois_ #
######################
# Backup PowerShell v2.1 #
##########################

#################################
## Inicio Establecer Variables ##

# Fecha y hora
    $FechaActual = Get-Date -uformat "%d-%m-%Y"
    $FechaHoraActual = Get-Date -uformat "%d/%m/%Y - %H:%M:%S"
# Paths
    $PathLocalDatos = "PathLocalDatos"
    $PathRemotoFTP = "PathRemotoFTP"
    $PathTempFichero7z = "PathTempFichero7z"
    $PathFicherosPasswd = "PathFicherosPassword"
    $NombreBackupTemp = "Backup_"
    $TempFichero7z = "$PathtempFichero7z$NombreBackupTemp$FechaActual.7z"
# Credenciales
    $Passwd7z = Get-Content "$PathFicherosPasswd\passwd-7z" | ConvertTo-SecureString -Key (Get-Content "$PathFicherosPasswd\cifrado.key")
    $HostServidorFTP = "HostServidorFTP"
    $UsuarioFTP = "UsuarioFTP"
    $PasswdFTP = "passwd-ftp"
    $UsuarioEmail = "UsuarioEmail@gmail.com" 
    $PasswdEmail = "passwd-email"
# Asunto y cuerpo del Email
    $AsuntoEmail = "AsuntoEmail"
    $CuerpoEmail = "CuerpoEmail"
# Convertir a string segura, obtenci�n de password desde los ficheros cifrados
    $SecPasswdFTP = Get-Content "$PathFicherosPasswd\$PasswdFTP" | ConvertTo-SecureString -Key (Get-Content "$PathFicherosPasswd\cifrado.key")
    $CredencialesFTP = New-Object System.Management.Automation.PsCredential($UsuarioFTP,$SecPasswdFTP)
    $SecPasswdEmail = Get-Content "$PathFicherosPasswd\$PasswdEmail" | ConvertTo-SecureString -Key (Get-Content "$PathFicherosPasswd\cifrado.key")
    $CredencialesEmail = New-Object System.Management.Automation.PSCredential ($UsuarioEmail, $SecPasswdEmail)
# Log
    $LogBackupFTP = "$PathtempFichero7z$NombreBackupTemp$FechaActual.log"
# Comprobaciones Test-Path
    $TestBackup7z = "$PathTempFichero7z$NombreBackupTemp*.7z"
    $TestBackupLog = "$PathTempFichero7z$NombreBackupTemp*.log"

## Fin Establecer Varibles ##
#############################


# Comprobrar si ya existe alg�n fichero de log o backup anteriores
if (Test-Path ($TestBackup7z, $TestBackupLog)) { 
    Remove-Item -Path ($TestBackup7z, $TestBackupLog) -Recurse -Force 
    }

## Compresi�n de datos ##
Compress-7Zip -Path $pathLocalDatos -ArchiveFileName $TempFichero7z -Password $Passwd7z -EncryptFilenames

## Enviar backup al servidor FTP ##
    # Crear nueva sesi�n FTP
    New-WinSCPSession -SessionOption (New-WinSCPSessionOption -HostName $HostServidorFTP -Protocol Ftp -Credential $CredencialesFTP) -SessionLogPath $LogBackupFTP -DebugLogLevel 2
    # Subir el fichero comprimido de datos al servidor FTP
    Send-WinSCPItem -LocalPath $TempFichero7z -RemotePath $PathRemotoFTP
    # Cerrar sesi�n FTP
    Remove-WinSCPSession

## Enviar log de backup v�a email Gmail ##
Send-MailMessage -From $UsuarioEmail -To $UsuarioEmail -Subject "$AsuntoEmail - $FechaHoraActual" -Body "$CuerpoEmail - $FechaHoraActual" -Attachments $LogBackupFTP -SmtpServer smtp.gmail.com -UseSsl -Credential $CredencialesEmail

## Eliminar logs ##
# Conservar el fichero de log, eliminar solo el fichero temporal backup 7z
Remove-Item -Path $TempFichero7z -Recurse -Force
# En el caso de querer eliminar tambi�n el log de backup, descomentar la siguiente l�nea
# Remove-Item -Path $logBackupFTP -Recurse -Force

# Salir
exit
