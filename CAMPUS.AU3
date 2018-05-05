#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Minion-Icon.ico
#AutoIt3Wrapper_Outfile=campus.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/mergeonly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region includes
	#include <IE.au3>
	#include <GUIConstantsEx.au3>
	#include <WindowsConstants.au3>
	#Include <File.au3>
	#Include <array.au3>
	#include <Date.au3>
	#Include <_GetIntersection.au3>
#endregion
;~ $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")    ; Initialize a COM error handler
#region variables
	$dev=0
	$debugflag=0
	$version="0.1"
	$indexTemplate= @ScriptDir&"\index_base.txt"
	if $dev = 1 then $indexTemplate= @ScriptDir&"\index_base -cambiada.txt"
		ConsoleWrite('>>(' & @ScriptLineNumber & ') : $indexTemplate = ' & $indexTemplate & @crlf )
	$mandarPorMail=1
	$configINI="config.ini"
	$LogFile="Campus.log"
	$FlagMail=0
	$timerStartMail=0
	$oIE =""
	$guiTemp=""
	$nuevodato=0
	global $hLogFile=""
	#region  send mail
		$sSmtpServer =  "smtp.gmail.com"        ; address for the smtp-server to use - REQUIRED
		$sFromName =    "xxxxxxx"                    ; name from who the email was sent
		$sFromAddress = "xxxxxxx@gmail.com"  ; address from where the mail should come
		$sToAddress = "xxxxxxxxx@gmail.com"
		 ; destination address of the email - REQUIRED
		$sSubject =    IniRead($configINI,"mail","sSubject ","Cambios en el campus" )                 ; subject from the email - can be anything you want it to be
		$sAttachFiles = ""                     ; the file(s) you want to attach seperated with a ; (Semicolon) - leave blank if not needed
		$sCcAddress = IniRead($configINI,"mail","sCcAddress","" )                           ; address for cc - leave blank if not needed
		$sBccAddress =  IniRead($configINI,"mail","sBccAddress","" )                      ; address for bcc - leave blank if not needed
		$sImportance =  IniRead($configINI,"mail","sImportance","Normal"  )                 ; Send message priority: "High", "Normal", "Low"
		$sUsername =    "xxxxxx@gmail.com"     ; username for the account used from where the mail gets sent - REQUIRED
		$sPassword =    "xxxxxxxxxxxxx"                 ; password for the account used from where the mail gets sent - REQUIRED
		$iIPPort =      465                         ; GMAIL port used for sending the mail
		$bSSL = True                           ; GMAIL enables/disables secure socket layer sending - set to True if using httpS
		$bIsHTMLBody =  True
		$sBody = ""
	#Endregion
#endregion
#region Personal includes
	_initLog()
	#Include <sendmail.au3>
	#Include <functions.au3>
#endregion
$timerStartMail=TimerInit()
#region  main ------------------------------------
	While 1
		;~ --------------------- Revisar portal ------------------------------------------------------------------------------
		$varIndex = TraerCodigo("http://www.ifts12online.com.ar/campus/index.php","index1.txt")
		if Not CheckIfLogedIn() then
			_logearse()
			$varIndex = TraerCodigo("http://www.ifts12online.com.ar/campus/index.php","index1.txt")
		endif
		if CheckIfLogedIn() then
			If $varIndex then
				$var = compararArchivos($indexTemplate,@ScriptDir&"\index1.txt")
				$sBody = ""
				if $var = 1 then
					_ConsoleWrite( _now() & '   creando el mail '& @crlf)
					$sBody = " Hay cambios en la pagina principal del campus " & @cr
					$sBody &= "http://www.ifts12online.com.ar/campus/index.php" & @cr
					$sBody &= " " & @cr
					$varArr = encontrarMateriasHOT(@ScriptDir&"\index1.txt")
;~ 					_ArrayDisplay($varArr)
					for $i = 0 to UBound($varArr) - 1
						$MateriaHOT = StringRegExp($varArr[$i], '(?s)(?i)cid=AS[0-9]{3,}[EBIS]*?">(.*?)</a>', 3)
						$sBody &= "Curso : " &  $MateriaHOT[0] & @cr
						$nuevodato=1
					next
				endif
			endif
;~ -------------------------------- Revisar INBOX  --------------------------------------------------------------
			if $mandarPorMail=1 and $nuevodato=1 and $flagMail=0 then
				$FlagMail = 1
				$timerStartMail=TimerInit()
				_Sendmail()
				$nuevodato=0
			endif
			if TimerDiff($timerStartMail) > (15 * 60 * 1000) then $FlagMail = 0
			_ConsoleWrite(_now()&' sleeping' & @crlf )
			_IEAction($oIE, "stop")
			GUIDelete($guiTemp)

			sleep(60 * 15 * 1000)
		Else
			_ConsoleWrite(_now()&' no se pudo loguear' & @crlf )
			_IEAction($oIE, "stop")
			GUIDelete($guiTemp)

			sleep(60 * 2 * 1000)
		endif
	WEnd
#endregion
_EndLog()



