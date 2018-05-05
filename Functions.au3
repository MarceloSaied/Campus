	Func _logearse()
		_ConsoleWrite('++_logearse() = '& @crlf)
		$oIE = _IECreateEmbedded()
		$alto=600
		$ancho=1000
		$guiTemp=GUICreate("Embedded Web control Test",$ancho,$alto, (@DesktopWidth - 	$ancho) / 2, (@DesktopHeight - $alto) / 2, BitOR($WS_OVERLAPPEDWINDOW, 				$WS_CLIPSIBLINGS, $WS_CLIPCHILDREN))
		GUICtrlCreateObj($oIE, 10,10,$ancho -10, $alto-10)

		Global $GUI_Error_Message = GUICtrlCreateLabel("", 100, 500, 500, 30)
		GUICtrlSetColor(-1, 0xff0000)
;~ 		GUISetState() ;Show GUI
		_IENavigate($oIE, "http://www.ifts12online.com.ar/campus/index.php",1)
		Sleep(5000)
		Send("xxxxxxxxxxxxxx",0)
		Sleep(500)
		Send("{TAB}")
		Sleep(500)
		Send("xxxxxxxxxxxxxxxx",0)
		Sleep(500)
		Send("{TAB}")
		Sleep(500)
		Send("{ENTER}")
		Sleep(5000)
	EndFunc
	Func TraerCodigo($pagina,$arcivodesalida)
;~ 		_ConsoleWrite('++TraerCodigo() = '& $arcivodesalida & @crlf)
		FileDelete(@ScriptDir&"\"&$arcivodesalida)
		Local $hDownload = InetGet($pagina, @ScriptDir & "\" &$arcivodesalida, 1, 1)
		Do
			 Sleep(250)
		Until InetGetInfo($hDownload, 2) ; Check if the download is complete.
		Local $nBytes = InetGetInfo($hDownload, 0)
		InetClose($hDownload) ; Close the handle to release resources.
		if $nBytes>0 then return 1
		return 0
	EndFunc
	Func compararArchivos($File1,$File2)
;~ 		_ConsoleWrite('++compararArchivos() = '& @crlf)
		Dim $arecords, $i
		$HayDiferencias = 0
		RunWait(@ComSpec & " /c " & 'FC /B "' & $File1 & '" "' & $File2 & '">tmp', @TempDir, @SW_HIDE)
		If Not _FileReadToArray(@TempDir & "\tmp",$aRecords) Then
			Return -1
		EndIf

		For $i = 1 To UBound ($arecords) -1
			 If StringInStr($arecords[$i], "FC: No differences") > 0 Then
				 _ConsoleWrite('!!(' & @ScriptLineNumber & ') : $arecords[$i] = ' & $arecords[$i] & @crlf )
				  $HayDiferencias = 0
				  ExitLoop
			  Else
;~ 					_ConsoleWrite('++(' & @ScriptLineNumber & ') : $arecords[$i] = ' & $arecords[$i] & @crlf )
				  $HayDiferencias = 1
				  ContinueLoop
			 EndIf
		Next
		If $HayDiferencias = 1 Then
			_ConsoleWrite('!!!!!!!! HayDiferencias diferencias !!!!!!!!!!!!!!!'& @crlf )
			Return 1
		 Else
			_ConsoleWrite('No hay diferencias' &  @crlf )
			Return 0
		EndIf
	EndFunc
	Func encontrarMateriasHOT($archivo)
;~ 		_ConsoleWrite('++encontrarMaterias() = '& $archivo & @crlf)
		Local $hFileOpen = FileOpen($archivo, $FO_READ)
		If $hFileOpen = -1 Then
			MsgBox(48, "", "An error occurred when reading the file." & $archivo)
			Return False
		EndIf
		Local $sFileRead = FileRead($hFileOpen)
		FileClose($hFileOpen)
		$MateriasArr = StringRegExp($sFileRead, '(?s)(?i)<dt class=" hot" >(.*?)</dt>', 3)
		For $j = 0 to UBound($MateriasArr) - 1
			_ConsoleWrite("  Col " & $j & ': ' & $MateriasArr[$j] & @CRLF)
		Next
		return $MateriasArr
	EndFunc
	Func encontrarMaterias($archivo)
		_ConsoleWrite('++encontrarMaterias() = '& $archivo & @crlf)
		Local $hFileOpen = FileOpen($archivo, $FO_READ)
		If $hFileOpen = -1 Then
			MsgBox(48, "", "An error occurred when reading the file." & $archivo)
			Return False
		EndIf
		Local $sFileRead = FileRead($hFileOpen)
		FileClose($hFileOpen)
		$MateriasLineasArr = StringRegExp($sFileRead, '(?s)(?i)<dt class="" >(.*?)</dt>', 3)
;~ 		_ArrayDisplay($MateriasLineasArr)
		$MateriasArr = StringRegExp($sFileRead, '(?s)(?i)cid=AS[0-9]{3,}[EBIS]*?">(.*?)</a>', 3)
		For $j = 0 to UBound($MateriasArr) - 1
			_ConsoleWrite("  Col " & $j & ': ' & $MateriasArr[$j] & @CRLF)
		Next
		return $MateriasArr
	EndFunc
	Func CheckIfLogedIn()
		_ConsoleWrite('++CheckIfLogedIn() = '& @crlf)
		Local $hFileOpen = FileOpen(@ScriptDir&"\index1.txt", $FO_READ)
		If $hFileOpen = -1 Then
;~ 			MsgBox(48, "", "An error occurred when reading the file." & @ScriptDir&"\index1.txt")
			Return False
		EndIf
		Local $sFileRead = FileRead($hFileOpen)
		If StringInStr($sFileRead, "Recordar contraseña") > 0 Then
			$logedin = 0
		Else
			$logedin = 1
		endif
		FileClose($hFileOpen)
		_ConsoleWrite(' $logedin = ' & $logedin & @crlf )
		return $logedin
	EndFunc
	Func CheckHot($archivo)
		_ConsoleWrite('++CheckHot() = '& @crlf)
		Local $hFileOpen = FileOpen($archivo, $FO_READ)
		If $hFileOpen = -1 Then
			MsgBox(48, "", "An error occurred when reading the file." & $archivo)
			Return False
		EndIf
		Local $sFileRead = FileRead($hFileOpen)
		If StringInStr($sFileRead, '<span class="item hot"') > 0 Then
			$hot = 0
		Else
			$hot = 1
		endif
		FileClose($hFileOpen)
		return $hot
	EndFunc
#region log
	Func _initLog()
		if $debugflag=1 then ConsoleWrite('++_initLog() = '& @crlf)
		$hLogFile = FileOpen($LogFile, 1+8)
		If $hLogFile = -1 Then
			if $debugflag=1 then ConsoleWrite("Error Unable to open file.")
			Exit
		EndIf
		if $debugflag=1 then ConsoleWrite('- LogFile = ' & $LogFile & @crlf )
		FileWriteLine($hLogFile,"===============================================================================" )
		FileWriteLine($hLogFile,"===============================================================================")
		FileWriteLine($hLogFile,_NowCalcDate()  & @TAB& "Start of activities"& @TAB& "Version: "& $version)
		FileWriteLine($hLogFile,"===============================================================================")
	EndFunc
	Func _ConsoleWrite($s_text,$logLevel="1")
		Switch $logLevel
			Case 1
				$levelcolor=">"
				$logLevelmsg="INFO"
			Case 2
				$levelcolor="-"
				$logLevelmsg="WARN"
			Case 3
				$levelcolor="!"
				$logLevelmsg="ERROR"
			Case Else
				$logLevelmsg="NA"
		EndSwitch
		FileWriteLine($hLogFile, _LogDate()&" ["& $logLevelmsg&"] " & $s_text )
		if $debugflag=1 then ConsoleWrite($levelcolor&"["& $logLevelmsg&"] " & $s_text & @CRLF)
	EndFunc   ;==>_ConsoleWrite
	Func _LogDate()
		$tCur = _Date_Time_GetLocalTime()
		$tCur = _Date_Time_SystemTimeToDateTimeStr($tCur)
		$date = "[" & stringreplace($tCur,"/","-") & "] "
		return $date
	EndFunc
	Func _EndLog()
		if $debugflag=1 then _ConsoleWrite('++_EndLog() = '& @crlf)
		FileWriteLine($hLogFile,"..............................................................................." )
		FileWriteLine($hLogFile,_NowCalcDate()   & @TAB& "End of activities")
		FileWriteLine($hLogFile,"..............................................................................." & @CRLF)
		FileClose($hLogFile)
	EndFunc
#endregion
