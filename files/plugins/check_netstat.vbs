rem Usage   : CScript check_mk.vbs STATE ORIGIN PORT PASSERELLE1 PASSERELLE2 PASSERELLE3
rem Exemple : CScript check_mk.vbs ESTABLISHED 127.0.0.1 102 1.1.1.1 2.2.2.2 3.3.3.3

rem Test result state variable
test_retcode = 999

rem Add item (PASSERELLE) to array
Function AddItem(array, value)
    ReDim Preserve array(UBound(array) + 1)
    array(UBound(array)) = value
    AddItem = array
End Function

rem Execute Netstat test
Function CheckNetstat(check_state, check_origin_ip, check_origin_port, check_passerelle, check_passerelle_nmbr)
	rem Execute netstat test
	set wso = CreateObject("Wscript.Shell")
	set exe = wso.Exec("cmd /c netstat -ano | findstr """ & check_state & """ | findstr """ & check_origin_ip & """:""" & check_origin_port & """ | findstr """ & check_passerelle & "")
	netstat_out = LCase(exe.StdOut.ReadAll)
	
	rem Set the test result code
	if Len(netstat_out) > 0 then
		if test_retcode <> 99 then
			if check_state = "ESTABLISHED" then test_retcode = 1
			if check_state = "LISTENING"   then test_retcode = 2
		End if
		wscript.Echo "TEST STATE   : PASSED"
	Else
		test_retcode = 99
		wscript.Echo "TEST STATE   : FAILED"		
	End if
	
	rem Show parameters
	wscript.Echo "STATE        : " & check_state
	wscript.Echo "ORIGIN IP    : " & check_origin_ip
	wscript.Echo "ORIGIN PORT  : " & check_origin_port
	wscript.Echo "PASSERELLE " & check_passerelle_nmbr & " : " & check_passerelle
	wscript.Echo vbCrLf & "-------------------------------" & vbCrLf
End Function

rem MAIN FUNCTION
Function Main()
	rem Get cmd line arguments
	Set args = Wscript.Arguments

	rem Set the static cmd lines arguments
	state       = args.item(0)
	origin_ip   = args.item(1)
	origin_port = args.item(2)

	rem PASSERELLE Array declaration
	array_pass = Array()

	rem CREATE PASSERELLES ARRAY
	For i = 3 to args.count -1
	  array_pass = AddItem(array_pass, args.item(i))
	Next

	rem PRINT PASSERELLE ARRAY
	passerelle_nmbr = 1
	For i = 0 to ubound(array_pass)
	  Call CheckNetstat(state, origin_ip, origin_port, array_pass(i), passerelle_nmbr)
	  passerelle_nmbr = passerelle_nmbr + 1 
	Next
	
	rem Show the test(s) result returned code
	wscript.Echo "RETURN CODE  : " & test_retcode
	
	Call Wscript.Quit(test_retcode)
End Function

rem EXECUTE Main Function
Main()