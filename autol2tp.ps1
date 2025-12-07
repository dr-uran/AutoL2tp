#Имя пользователя и пароьль для VPN
$VPNuser = "username"
$VPNpass = "password"  

# Имя подключения
$VPNconnectionL2TPM = "GORELTEX_MAIN"
$VPNconnectionL2TPS = "GORELTEX_SLAVE"

# тип подключения                             
$VPNtypeL2TP ="l2tp"

# ip адрес или доменное имя                           
$SRVaddressL2TPM = "my.domain.com"
$SRVaddressL2TPS = "my2.domain.com"

# DNS суффикс
$dnssuf = "corp.exd.ru"

# ключ l2tp
$l2tp_key = "ключ"

# метод аутентификации
$auth_method = "MSChapv2"

# --- Proverka admin-prav ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = (Get-Process -Id $PID).Path
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`""
    $psi.Verb = "runas"
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    exit
}

if (Get-VpnConnection -Name $VPNconnectionL2TPM -AllUserConnection -ErrorAction Ignore -Verbose)
{ Remove-VpnConnection -Name $VPNconnectionL2TPM -AllUserConnection -ErrorAction Ignore -Verbose -Force }

Add-VpnConnection -Name $VPNconnectionL2TPM -ServerAddress $SRVaddressL2TPM -TunnelType $VPNtypeL2TP -AuthenticationMethod $auth_method -L2tpPsk $l2tp_key -EncryptionLevel "Optional" -DnsSuffix $dnssuf  -SplitTunneling -IdleDisconnectSeconds 900 -RememberCredential -AllUserConnection
rasdial $VPNconnectionL2TPM $VPNuser $VPNpass
rasdial $VPNconnectionL2TPM /disconnect
Pause