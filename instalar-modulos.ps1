######################
# Autor @adrianlois_ #
######################

# Quitar restricciones de ejecuci�n de scripts
Set-ExecutionPolicy Unrestricted -scope LocalMachine -Force

# Instalaci�n de m�dulos 7Zip4Powershell y WinSCP.
Install-Module -Name 7Zip4Powershell -Verbose -Force
Install-Module -Name WinSCP -Verbose -Force