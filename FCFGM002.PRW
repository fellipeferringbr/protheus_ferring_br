#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "AP5MAIL.CH"
#DEFINE CRLF CHR(13)+CHR(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FEEDIMntLinha³ Autor ³ Roberto. Soares   ³ Data ³22/10/2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria a linha que sera gravada no TXT.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FEEDIMntLinha(aArray)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cLinha                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FERRING                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FEEDIMntLinha(_aLinha,_cDelimitador)
Local _cLinha	:= ""
Local _nX		:= 0
Local _nTamX	:= Len(_aLinha)
Local _nY		:= 0
Local _nTamY	:= 0

For _nX := 1 to _nTamX
	_nTamY	:= Len(_aLinha[_nX])
	For _nY := 1 to _nTamY
		_cLinha += _aLinha[_nX][_nY]
		_cLinha += _cDelimitador//+CRLF
	Next _nY
Next _nX

_cLinha += CRLF

Return _cLinha


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FEEDIGrvTXT  ³ Autor ³ Leandro Drumond   ³ Data ³22/10/2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua gravacao do TXT.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FEEDIGrvTXT(cFile,cLinha)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FERRING                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FEEDIGrvTXT(_cFile, _cLinha)

Local _lRet			:= .T.

// Gera arquivo
_cDirLocal := GetMv("ES_UPBOMI") // Pasta par gravação do arquivo local    (\bomi\out\)
_cFile	:=	Alltrim(_cFile)
nHandle := 	MSFCREATE(_cDirLocal+_cFile)

If FERROR() # 0 .Or. nHandle < 0
	//conout('Erro ao criar arquivo para EDI FERRING X LUFT')
	FClose(nHandle)
	Return (.F.)
EndIf

FWrite(nHandle,_cLinha)

FClose(nHandle)

Return _lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FEEDIMove    ³ Autor ³ Leandro Drumond   ³ Data ³22/10/2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia TXT para area definida no parametro GL_DIRBOMI         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FEEDIMove(cFile,nTpOper) 			                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FERRING                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
User Function FEEDIMove(_cFile,nTpOper)

Local _cDirPath		:= ""													// diretorio para copia e posterior upload
Local _cDirAux		:= ""
Local _lRet			:= .T.													// retorno da funcao

_cTpOper := Alltrim(str(nTpOper))
//_cDirPath:=GetNewPar("MV_XFTPBOM","\ftpluft\") 
_cDirPath  :=GetNewPar("ES_PSPBOMI","\ftpluft\")
If 	!(__CopyFile(_cFile,_cDirPath+_cFile))
	_cDirAux := If(SubStr(_cDirPath,Len(_cDirPath),Len(_cDirPath)) == "\",SubStr(_cDirPath,1,Len(_cDirPath)-1),_cDirPath)
	If !ExistDir(_cDirAux)
		If	MAKEDIR(_cDirAux)!= 0
			_lRet := .F.
			//Conout("<<FEEDIMOVE>>...Falha na criacão da pasta " + _cDirAux + "...")
			u_StEnviFTP("0",_cFile,nTpOper)      
		Else
			_lRet := __CopyFile(_cFile,_cDirPath+_cFile)
			if _lRet
				u_StEnviFTP("0",_cFile,nTpOper)     //1
			Else
				u_StEnviFTP("1",_cFile,nTpOper)     //0
			Endif
		EndIf
	EndIf
Else
	_lRet := __CopyFile(_cFile,_cDirPath+_cFile)
	IF _lRet
		u_StEnviFTP("0",_cFile,nTpOper)    //1
	Else
		u_StEnviFTP("1",_cFile,nTpOper)    //0
	Endif
EndIf

Return _lRet
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FEEDICpyFTP  ³ Autor ³ Leandro Drumond   ³ Data ³22/10/2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia TXT para o FTP.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FEEDICpyFTP(cFile)			                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FERRING                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FEEDICpyFTP(_cFile,_cTipoFTP,nTPOper,_reczzd)

Local _cDirFTP		:= ""													// diretorio FTP para UPLOAD
Local _cDirFTPUPL	:= ""													// diretorio no FTP para receber arquivo UPLOAD
Local _cDirPath		:= ""													// diretorio para copia e posterior upload
Local _cDirAux		:= ""
Local _cDirBKP		:= ""
Local _lRet	:= .T.	  
Private _cDescOper  := ""												// retorno da funcao

DEFAULT _cTipoFTP   := "L" // LUFT

If _cTipoFTP == "L"
	_cDirLocal :=alltrim(GetNewPar("ES_UPBOMI","\ftpluft\out\"))
	_cDirPath  :=alltrim(GetNewPar("ES_PSPBOMI","/in"))
	_cDirFTPUPL:=alltrim(GetNewPar("ES_PSPBOMI","/in"))
	_cDirBkp   :=alltrim(GetNewPar("ES_ENVBOMI","\ftpluft\enviados\"))
Endif

If _lRet := FTPDirChange(_cDirFTPUPL)
	_cDirFTP:=FTPGetCurDir() 
 	If _lRet := FTPUpLoad(_cDirLocal+_cFile,_cFile)
	 		msgalert("UpLoad do arquivo " + _cFile + " efetuado com sucesso!",_cDescOper)
		If !ExistDir(_cDirBkp)
			MAKEDIR(_cDirBkp)
		EndIf 
		_cFile2 := dTOS(date())+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+"_"+_cFile
		__CopyFile(_cDirLocal + _cFile,_cDirBkp +_cFile2) //Copia backup p/ \bomi\enviados
		u_StEnviFTP("2",_cFile,nTPOper,_reczzd)
		Ferase(_cDirLocal+_cFile)        // apaga do \bomi\out
		Ferase(_cFile)
	Else
		msgalert("UpLoad FTP falha de execução!")
		u_StEnviFTP("1",_cFile,nTPOper,_reczzd)      
	Endif
Else
	//Conout("<<FEEDICPYFTP>>...Falha no acesso a pasta " + _cDirFTPUPL + "...")
	u_StEnviFTP("1",_cFile,nTPOper,_reczzd)         //0 
	Return(.F.)
Endif

Return _lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FEEDIConFTP  ³ Autor ³ Leandro Drumond   ³ Data ³22/10/2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Conecta no FTP da FERRING.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FEEDIConFTP(cFile)			                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FERRING                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FEEDIConFTP(_cTipoFTP)
Local _cSrvFTP		:= ""                                                   // Servidor FTP
Local _nPrtFTP		:= 0													// Porta FTP
Local _cUsrFTP		:= ""													// Usuario FTP
Local _cPswFTP		:= ""													// Senha FTP
Local _lRet			:= .T.

DEFAULT _cTipoFTP := "L"

If _cTipoFTP == "L"		// LUFT
	_cSrvFTP := alltrim(GetNewPar("MV_XFTPBOM","sftp.luftlogistics.com"))
	_nPrtFTP := GetNewPar("MV_XFPOBOM",21)
	_cUsrFTP := alltrim(GetNewPar("MV_XUSRBOM","ferring_t"))
	_cPswFTP := alltrim(GetNewPar("MV_XSENBOM","Calforim79"))
Endif

IF Empty(alltrim(_cSrvFTP)) .or. Empty(alltrim(_cUsrFTP)) .or. Empty(alltrim(_cPswFTP))
	msgalert("Parâmetros FTP não informados, verifique o conteúdo dos parâmetros MV_XFTPBOM,MV_XFPOBOM,MV_XUSRBOM e MV_XSENBOM","PARAMFTP")
	Return(.F.)
Endif

FTPDISCONNECT() //-Desconecta do servidor ftp

//If	FTPConnect( _cSrvFTP, _nPrtFTP, _cUsrFTP, _cPswFTP )
If	FTPConnect( _cSrvFTP, , _cUsrFTP, _cPswFTP )
	//Conout("<<FEEDICONFTP>>..Conexão FTP realizada com sucesso!...")
Else
	//Conout("<<FEEDICONFTP>>..Falha de conexao com FTP...")
	msgalert("Falha de conexao com FTP...","PARAMFTP")
	_lRet:=.F.
Endif

Return _lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FEGrvZZD     ³ Autor ³ Leandro Drumond   ³ Data ³06/01/2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava dados de envio/retorno de integracao na ZZD            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FEGrvZZD(_cFile, _cTipo, _cIntegra, _cChave)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FERRING                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FEGrvZZD(_cFile, _nTipo, _cIntegra, _cChave, _cTpMail, _lEnviaMail,cTPArq,cProd,_cLote)
Local _nHoraTrans 	:= ( Substr(Time(),1,2)+ ":" + Substr(Time(),4,2) )
Local _cTo			:= ""
Local _cMsgSend		:= ""      
Local _nRec         := 0

DEFAULT _lEnviaMail	:= .T.
DEFAULT _cTpMail := "2"  // Luft e usuários

If RecLock("ZZD" , .T. ) 
	ZZD->ZZD_FILIAL  	:= xFilial("ZZD")
	ZZD->ZZD_INTEGR  	:=  _cIntegra  // MCQ-Movimentos de CQ / BLT - Bloqueio de Lote
	ZZD->ZZD_TPARQ   	:=  cTPArq // QUALIDADE / BLOQQUEIO DE LOTES    
	ZZD->ZZD_PRODUT   	:= 	cProd  
	ZZD->ZZD_LOTECT     := _cLote
	ZZD->ZZD_DESCR  	:= _cDescOper
	ZZD->ZZD_ARQUIV	 	:= _cFile
	ZZD->ZZD_DATA    	:= dDataBase
	ZZD->ZZD_HORA    	:= _nHoraTrans
	ZZD->ZZD_LOG  	 	:= ""//_cChave
	ZZD->ZZD_STATUS  	:= "0" //If (ZZC->ZZC_RETOBR == "S","0","2")
	ZZD->( MsUnLock() )   
	_nrec               := ZZD->(RECNO())
	
 	/*	If _lEnviaMail
		_cTo := u_RetMailTo(_cTpMail)
		If !Empty(_cTo)
			_cMsgSend := "<html><body>Status do processo de envio dos arquivos FERRING X " + _cIntegra + ": <br><br>"
			_cMsgSend += "O arquivo <B>" + _cFile + " ( " + ZZC->ZZC_DESCR + " )</B> foi enviado com sucesso. <BR>"
			_cMsgSend += "</body></html>"
			u_EnviaMail( "Envio de arquivos de integração "+ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL), _cMsgSend, _cTo )
		EndIf
	EndIf */
	
EndIf

Return _nRec


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  DescOper ºAutor  ³Leandro Drumond     º Data ³  12/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descrição da aperação de acordo com parâm         º±±
±±º          ³ informado                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FERRING                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DescOper(cTPOper)   
	Local _cDescRet := ""
	_cArea := GetArea()
	 
	_cDescRet := Posicione("ZZC",1,xFilial("ZZC")+PADR(cTPOper,3),"ZZC_DESCR")
	RestArea(_cArea)
Return(_cDescRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetMailTo ºAutor  ³Leandro Drumond     º Data ³  12/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna remetentes do email de acordo com o tipo            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FERRING                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetMailTo(_cTpMail)
Local _cTo 		   := ""
Local _lEnviaMail  := .F.
_cDestina := ""   
_cTo := ""
DbSelectArea("ZZA")
DbSetOrder(1)      

IF ZZA->(DbSeek(xFilial("ZZA")+_cTpMail))  
    While ! ZZA->(EOF()) .AND. ZZA->ZZA_TIPO = _cTpMail
		If Empty(_cTo)
			_cTo := ZZA->ZZA_EMAIL
		Else
			_cTo += "," + ZZA->ZZA_EMAIL
		EndIf
		ZZA->(dbSkip())
	EndDo
Endif

if Empty(alltrim(_cTo))
	_cMensAler := "Destinatarios de e-mail não informados "+chr(13)+chr(10)
	_cMensAler += "verifique amarração Rotinas x usuários"
	MSGALERT(_cMensAler,"NOEMAIL") 
Endif    

Return _cTo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EnviaMail ºAutor  ³Leandro Drumond     º Data ³  22/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o envio do email										  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FERRING                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EnviaMail( _cAssunto, _cMsgMail, _cTo, _aAnexo )
Local _nX			:= 0
Local _cAnexo		:= ""
Local nX,nZ

DEFAULT _aAnexo := {}

Private _cSerMail	:= AllTrim(GetMV("MV_RELSERV"))
Private _cConta    	:= AllTrim(GetMV("MV_RELACNT"))
Private _cSenha		:= AllTrim(GetMV("MV_RELPSW"))
Private _lConectou	:= .F.
Private _lEnviado	:= .F.
Private _lRelAuth	:= .F.
Private _cMailError	:= ""


If !Empty(_cSerMail) .And. !Empty(_cConta) .And. !Empty(_cSenha)
	oMail:= tMailManager():New()
	oMail:SetUseSSL(.T.)
	oMail:SetUseTLS(.T.)
	oMail:Init( "", cMailServer, cMailConta, cMailSenha )
	nret := oMail:SMTPConnect()

	If nRet != 0
		MSGINFO(oMail:GetErrorString( nret ),'Erro!')
		_lConectou:=.F.
		Return (.F.)
	Endif

	nRet := oMail:SMTPAuth( cMailConta, cMailSenha )

	If nRet != 0
		cError("FA050FIN() - Erro.  Falha na Autenticação do Usuário","Atenção") 
		conout( "[AUTH][ERROR] " + str(nRet,6) , oServer:GetErrorString( nRet ) )
		lConect := .F.
		Return (.F.)
	Endif

	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom          := _cConta
	oMessage:cTo            := _cTo
	oMessage:cCc            := ""
	oMessage:cBcc           := ""
	oMessage:cSubject       := _cAssunto
	oMessage:cBody          := _cMsgMail
	For nZ:=1 to len(_aAnexo)
		If File(_aAnexo[nZ])
			nRet := oMsg:AttachFile(aAnexos[nAtual])
            If nRet < 0
                MessageBox( "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!",'Erro!',16)
			EndIf
        Else
            MessageBox("003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" ,'Erro!',16)
        EndIf
 	Next nZ

	conout( "[SEND] Sending ..." )
	nRet := oMessage:Send( oMail )
	If nRet != 0
		conout( "[SEND] Fail to send message" )
		conout( "[SEND][ERROR] " + str( nRet, 6 ), oServer:GetErrorString( nRet ) )
		_lEnviado:= .F.
	Else
		conout( "[SEND] Success to send message" )
	EndIf

	nRet := oMail:SmtpDisconnect()
	If nRet == 0
		conout( "Disconnect Successful" )
	Else
		conout( oMail:GetErrorString( nret ),'Erro!' )
	Endif


else
	//Erro na autenticacao da conta
	//GET MAIL ERROR cError
	Msgalert("Não foi possível conectar ao Servidor de email. Procure o Administrador da rede. Erro retornado: "+_cMailError)
	ConOut(cError)
	lConect := .F.
	_lEnviado:= .F.
EndIf	


Return (.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  StEnviFTP ºAutor  ³Microsiga           º Data ³  06/17/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza status de envio conforme retornor                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function StEnviFTP(_cStZZD,_cFile,nTPOper,_reczzd)
_cArea := GetArea()
If !Empty(_cDescOper)  // Se branco apenas reenvio do arquivo devido a falha
   _cDescOper := U_DescOper(nTPOper)  
EndIf
//DbSelectArea("ZZD")
//DbSetOrder(2)    
ZZD->(dbGoTo(_reczzd))
//if ZZD->(DbSeek(xFilial("ZZD")+Padr(_cFile,tamsx3("ZZD_ARQUIV")[1])))
	Reclock("ZZD",.F.)
	ZZD->ZZD_STATUS := _cStZZD  
	If !Empty(_cDescOper)
		ZZD->ZZD_DESCR := _cDescOper 
	EndIf
	MsUnlock()
 //	MSGALERT("Atualizou status ZZD - "+ _cStZZD+ " - Operacao "+_cDescOper)
//Endif
RestArea(_cArea)
Return()


// Atualiza status de envio- SD7
User Function AtuStReg(nRec,lRet,nTPOper,cAlias,cFile)
_cAreaSD7 := GetArea("SD7")
_cAreaSDD := GetArea("SDD")
if cAlias = "SD7"
	DbSelectArea("SD7")
	SD7->(DbGoTo(nRec))
	Reclock("SD7",.F.)
	SD7->D7_XSTENV := IIF(lRet,alltrim(str(nTPOper)),"0")
	SD7->D7_ARQENV := cFile
	MsUnlock()
Endif

// Atualiza status de envio- SDD
if cAlias = "SDD"
	DbSelectArea("SDD")
	SDD->(DbGoTo(nRec))
	Reclock("SDD",.F.)
    SDD->DD_XSTENV := IIF(lRet,alltrim(str(nTPOper)),"0")
    SDD->DD_ARQENV := cFile
	MsUnlock()
Endif

RestArea(_cAreaSD7)
RestArea(_cAreaSDD)
Return(.T.)

User Function TrfArqFTP(cFile,nTPOper,_reczzd)
Local _cDirPath  :=GetNewPar("ES_PSPBOMI","\ftpluft\")       //IN
Private lGdFTPCon		:= .F.   

// Efetua conexção com servidor FTP luft
lGdFTPCon := u_FEEDIConFTP("L")    //-Conecta no FTP 

IF	lGdFTPCon  //CONEXÃO OK
	lRet := u_FEEDICpyFTP(cFile,"L",nTPOper,_reczzd) //-Copia TXT para o FTP
	IF lRet
		__CopyFile(cFile,_cDirPath+cFile)
	Endif
Else
	u_StEnviFTP("1",cFile,nTPOper,_reczzd)   
Endif

If lGdFTPCon
	FTPDISCONNECT() //-Desconecta do servidor ftp
EndIf
Return(.T.)
