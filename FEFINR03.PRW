#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FEFINR03 บ Autor ณ Wilson A. Silva Jr.บ Data ณ  23/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Acessos e Permissoes por Usuarios.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function FEFINR03()

Local aArea 	:= GetArea()
Local aBoxParam := {}
Local aRetParam := {}
Local aCampos 	:= {}

Private oReport

Private cTmpGrp 	:= CriaTrab(,.F.)
Private cTmpUsr 	:= CriaTrab(,.F.)
Private cTmpXNU 	:= CriaTrab(,.F.)

Private aModulo := RetModName()

Private nAnalise := 1
Private nTipoImp := 1 // 1=Excel ou 2=PDF
Private cUsrIni  := Space(6)
Private cUsrFim  := Replicate("Z",6)
Private cGrpIni  := Space(6)
Private cGrpFim  := Replicate("Z",6)
Private cStatus  := "Ativos"
Private lImpOper := .T.
 
If MsgYesNo( "Este programa ir agerar um arquivo Excel contendo a lista dos programas disponiveis nos menus. Deseja Prosseguir?", "Auditoria em Menus" )

	AADD( aBoxParam, {3,"Anแlise"		,nAnalise					,{"Por Usuแrio","Por Grupo"},100,".T.",.F.} )
	AADD( aBoxParam, {3,"Impressใo"		,nTipoImp					,{"Excel","PDF"},100,".T.",.F.} )
	AADD( aBoxParam, {1,"Usuแrio De"	,cUsrIni					,"","","USR",".T.",100,.F.} )
	AADD( aBoxParam, {1,"Usuแrio At้"	,cUsrFim					,"","","USR",".T.",100,.F.} )
	AADD( aBoxParam, {1,"Grupo De"		,cGrpIni					,"","","GRP",".T.",100,.F.} )
	AADD( aBoxParam, {1,"Grupo At้"		,cGrpFim					,"","","GRP",".T.",100,.F.} )
	AADD( aBoxParam, {2,"Status"		,cStatus					,{"Todos","Ativos","Bloqueados"},100,".T.",.F.} )
	AADD( aBoxParam, {2,"Opera็ใo"		,IIf(lImpOper,"Sim","Nใo")	,{"Sim","Nใo"},100,".T.",.F.} )

	If ParamBox(aBoxParam,"Informe os Parโmetros",@aRetParam,,,,,,,,.F.)
		
		nAnalise := aRetParam[1]
		nTipoImp := aRetParam[2]
		cUsrIni  := aRetParam[3]
		cUsrFim  := aRetParam[4]
		cGrpIni  := aRetParam[5]
		cGrpFim  := aRetParam[6]
		cStatus  := aRetParam[7]
		lImpOper := aRetParam[8] == "Sim"

		/*==========================================================*/

		aCampos := {}
		AADD(aCampos, {"SY_GRUPO"	,"C", 006, 00}) // Grupo - Grupo de usuแrios
		AADD(aCampos, {"SY_GRPDES"	,"C", 030, 00}) // Desc. Grupo - Descri็ใo do Grupo
		AADD(aCampos, {"SY_STATUS"	,"C", 009, 00}) // Status - Status: Ativo ou Bloqueado
		AADD(aCampos, {"SY_MENU"	,"C", 050, 00}) // Menu - Menu de acesso do sistema
		AADD(aCampos, {"SY_MODULO"	,"C", 035, 00}) // M๓dulo - M๓dulo de acesso do sistema

		DBCreate(cTmpGrp,aCampos,"TOPCONN")
		
		DbUseArea(.T.,"TOPCONN",cTmpGrp,cTmpGrp,.F.,.F.)

		/*==========================================================*/
		
		aCampos := {}
		AADD(aCampos, {"SY_GRUPO"	,"C", 006, 00}) // Grupo - Grupo de usuแrios
		AADD(aCampos, {"SY_GRPDES"	,"C", 030, 00}) // Desc. Grupo - Descri็ใo do Grupo
		AADD(aCampos, {"SY_LOGIN"	,"C", 025, 00}) // Login - Id de acesso do usuแrio
		AADD(aCampos, {"SY_NOME"	,"C", 040, 00}) // Nome  - Nome completo do usuแrio
		AADD(aCampos, {"SY_DEPTO"	,"C", 040, 00}) // Departamento - Departamento do usuแrio
		AADD(aCampos, {"SY_CARGO"	,"C", 040, 00}) // Cargo - Cargo atual do usuแrio
		AADD(aCampos, {"SY_EMAIL"	,"C", 040, 00}) // E-mail - E-mail do usuแrio
		AADD(aCampos, {"SY_STATUS"	,"C", 009, 00}) // Status - Status: Ativo ou Bloqueado
		AADD(aCampos, {"SY_MENU"	,"C", 050, 00}) // Menu - Menu de acesso do sistema
		AADD(aCampos, {"SY_MODULO"	,"C", 035, 00}) // M๓dulo - M๓dulo de acesso do sistema

		DBCreate(cTmpUsr,aCampos,"TOPCONN")
		
		DbUseArea(.T.,"TOPCONN",cTmpUsr,cTmpUsr,.F.,.F.)

		/*==========================================================*/

		aCampos := {}
		AADD(aCampos, {"SY_MENU"	,"C", 050, 00}) // Menu - Menu de acesso do sistema
		AADD(aCampos, {"SY_SECAO"	,"C", 035, 00}) // Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
		AADD(aCampos, {"SY_SUBMENU"	,"C", 035, 00}) // Submenu - Nome da rotina a ser executada
		AADD(aCampos, {"SY_ROTINA"	,"C", 035, 00}) // Descri็ใo - Descri็ใo da rotina
		AADD(aCampos, {"SY_FUNCAO"	,"C", 035, 00}) // Fun็ใo - Nome t้cnico da Fun็ใo
		AADD(aCampos, {"SY_OPERAC"	,"C", 035, 00}) // Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
		AADD(aCampos, {"SY_ORDOPER"	,"C", 009, 00}) // Ordem da Opera็ใo

		DBCreate(cTmpXNU,aCampos,"TOPCONN")
		
		DbUseArea(.T.,"TOPCONN",cTmpXNU,cTmpXNU,.F.,.F.)

		/*==========================================================*/

		If nTipoImp == 1 // Excel
			Processa({|| RunReport()},"Processando ..." )
    		If nAnalise == 1
				Processa({|| UsrExcel() },"Gerando o Excel..." )
			Else
				Processa({|| GrpExcel() },"Gerando o Excel..." )
			EndIf
		Else
			oReport := Ljr780RptDef()
			oReport:PrintDialog()
		EndIf

		(cTmpGrp)->(DbCloseArea())
		(cTmpUsr)->(DbCloseArea())
		(cTmpXNU)->(DbCloseArea())

		If !TcDelFile(cTmpGrp)
			MsgInfo("Nใo foi possํvel a exclusใo da tabela temporแria.")
		EndIf
		
		If !TcDelFile(cTmpUsr)
			MsgInfo("Nใo foi possํvel a exclusใo da tabela temporแria.")
		EndIf
		
		If !TcDelFile(cTmpXNU)
			MsgInfo("Nใo foi possํvel a exclusใo da tabela temporแria.")
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRunReport บAutor  ณMauro Paladini      บ Data ณ  23/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar para processamento do relatorio             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RunReport()

	Local cTMP1  	:= GetNextAlias()
	Local cQuery 	:= ""

	Local aMenuAll
	Local aMenuGrp
	Local aBotoes

	Local nX, nY, nZ
    
	Private aUsuario := FwAllUsers()
	Private aGrupos	 := FWSFAllGrps()
	Private nOrdem 	 := 0

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Obter lista de todos os menus utilizados pelos grupos ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcRegua(Len(aGrupos))
 
	For nX := 1 To Len(aGrupos)

		IncProc( "Analisando grupo de usuarios" )
		
		cCodGrp  := aGrupos[nX][2]
		cDescGrp := aGrupos[nX][3]

		aGrpParam := FWGrpParam(cCodGrp)

		lBloq 	:= aGrpParam[1][3] == "1" .Or. (!Empty(aGrpParam[1][4]) .And. aGrpParam[1][4] <= DATE())

		//If cCodGrp == "000000"
		//	LOOP
		//EndIf

		If cCodGrp < cGrpIni .Or. cCodGrp > cGrpFim
			LOOP
		EndIf

		If cStatus == "Ativos" .And. lBloq
			LOOP
		EndIf

		If cStatus == "Bloqueados" .And. !lBloq
			LOOP
		EndIf

		aMenuGrp := FWGrpMenu(cCodGrp) // Menus do Grupo
	
		For nZ := 1 To Len(aMenuGrp)
			cCodMod := Substr(aMenuGrp[nZ],1,2)
			lUsado	:= IIf(Substr(aMenuGrp[nZ],3,1)=="X",.F.,.T.)
			cMenu	:= Lower(AllTrim(Capital(AllTrim(Substr(aMenuGrp[nZ],4,Len(aMenuGrp[nZ]))))))
			If lUsado
				If File(cMenu)
                    DbSelectArea(cTmpGrp)
                    RecLock(cTmpGrp,.T.)
                    	REPLACE SY_GRUPO    WITH cCodGrp // Grupo - Grupo de usuแrios
                        REPLACE SY_GRPDES   WITH cDescGrp // Desc. Grupo - Descri็ใo do Grupo
                        REPLACE SY_STATUS   WITH IIF(lBloq,"Bloqueado","Ativo") // Status - Status: Ativo ou Bloqueado
                        REPLACE SY_MENU     WITH cMenu // Menu - Menu de acesso do sistema
						REPLACE SY_MODULO	WITH ListaModulos(cCodMod) // M๓dulo - M๓dulo de acesso do sistema
                    MsUnLock()
				EndIf
			EndIf
		Next nZ
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Obter lista de todos os menus utilizados pelos usuarios ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcRegua(Len(aUsuario))

	For nX := 1 To Len(aUsuario)

		IncProc( "Analisando cadastro de usuarios" )
		
		aDados1 := aUsuario[nX][1]

		cCodUser:= aDados1[1]
		cLogin	:= aDados1[2]
		cNome	:= AllTrim(aDados1[4])
		cDepto	:= AllTrim(aDados1[12])
		cCargo	:= AllTrim(aDados1[13])
		cEMail	:= AllTrim(aDados1[14])
		dDtInc	:= AllTrim(aDados1[24])
		lBloq 	:= aDados1[17]

		If cCodUser == "000000"
			LOOP
		EndIf

		If cCodUser < cUsrIni .Or. cCodUser > cUsrFim
			LOOP
		EndIf

		If cStatus == "Ativos" .And. lBloq // Ativos
			LOOP
		EndIf

		If cStatus == "Bloqueados" .And. !lBloq // Bloqueados
			LOOP
		EndIf

		aDados2 := aUsuario[nX][2]
		aDados3 := aUsuario[nX][3] // Menus
		aDados4 := UsrRetGrp(cCodUser)

		If Len(aDados1[10]) == 0 // Grupos do Usuario

			For nY := 1 To Len(aDados3)
				cCodMod := Substr(aDados3[nY],1,2)
				lUsado	:= IIf(Substr(aDados3[nY],3,1)=="X",.F.,.T.)
				cMenu	:= Lower(AllTrim(Capital(AllTrim(Substr(aDados3[nY],4,Len(aDados3[nY]))))))
				If lUsado
					If File(cMenu)
                        DbSelectArea(cTmpUsr)
                        RecLock(cTmpUsr,.T.)
                            REPLACE SY_GRUPO    WITH "" // Grupo - Grupo de usuแrios
                            REPLACE SY_GRPDES   WITH "" // Desc. Grupo - Descri็ใo do Grupo
                            REPLACE SY_LOGIN    WITH cLogin // Login - Id de acesso do usuแrio
                            REPLACE SY_NOME     WITH cNome // Nome  - Nome completo do usuแrio
                            REPLACE SY_DEPTO    WITH cDepto // Departamento - Departamento do usuแrio
                            REPLACE SY_CARGO    WITH cCargo // Cargo - Cargo atual do usuแrio
                            REPLACE SY_EMAIL    WITH cEMail // E-mail - E-mail do usuแrio
                            REPLACE SY_STATUS   WITH IIF(lBloq,"Bloqueado","Ativo") // Status - Status: Ativo ou Bloqueado
                            REPLACE SY_MENU     WITH cMenu // Menu - Menu de acesso do sistema
							REPLACE SY_MODULO	WITH ListaModulos(cCodMod) // M๓dulo - M๓dulo de acesso do sistema
                        MsUnLock()
					EndIf
				EndIf
			Next nY
		Else
			For nY := 1 to Len(aDados4)
				aMenuGrp := FWGrpMenu(aDados4[nY]) // Menus do Grupo
				For nZ := 1 To Len(aMenuGrp)
					cCodMod := Substr(aMenuGrp[nZ],1,2)
					lUsado	:= IIf(Substr(aMenuGrp[nZ],3,1)=="X",.F.,.T.)
					cMenu	:= Lower(AllTrim(Capital(AllTrim(Substr(aMenuGrp[nZ],4,Len(aMenuGrp[nZ]))))))
					If lUsado
						If File(cMenu)
                            DbSelectArea(cTmpUsr)
                            RecLock(cTmpUsr,.T.)
                                REPLACE SY_GRUPO    WITH aDados4[nY] // Grupo - Grupo de usuแrios
                                REPLACE SY_GRPDES   WITH GrpRetName(aDados4[nY]) // Desc. Grupo - Descri็ใo do Grupo
                                REPLACE SY_LOGIN    WITH cLogin // Login - Id de acesso do usuแrio
                                REPLACE SY_NOME     WITH cNome // Nome  - Nome completo do usuแrio
                                REPLACE SY_DEPTO    WITH cDepto // Departamento - Departamento do usuแrio
                                REPLACE SY_CARGO    WITH cCargo // Cargo - Cargo atual do usuแrio
                                REPLACE SY_EMAIL    WITH cEMail // E-mail - E-mail do usuแrio
                                REPLACE SY_STATUS   WITH IIF(lBloq,"Bloqueado","Ativo") // Status - Status: Ativo ou Bloqueado
                                REPLACE SY_MENU     WITH cMenu // Menu - Menu de acesso do sistema
								REPLACE SY_MODULO	WITH ListaModulos(cCodMod) // M๓dulo - M๓dulo de acesso do sistema
                            MsUnLock()
						EndIf
					EndIf
				Next nZ
			Next nY
		EndIf

	Next nX

    cDirPath := GetSrvProfString("StartPath", "\system\")

    aMenuAll := Directory(cDirPath + "*.XNU", "D",Nil,.F.,1)

	ProcRegua(Len(aMenuAll))
	
	For nX := 1 To Len(aMenuAll)

        cArqMenu := Lower(cDirPath + AllTrim(aMenuAll[nX][1]))

		IncProc( "Lendo " + cArqMenu )

        If nAnalise == 1
            cQuery := " SELECT COUNT(1) SY_NUMREG FROM "+cTmpUsr+" USR (NOLOCK) WHERE SY_MENU = '"+cArqMenu+"' "
        Else
            cQuery := " SELECT COUNT(1) SY_NUMREG FROM "+cTmpGrp+" GRP (NOLOCK) WHERE SY_MENU = '"+cArqMenu+"' "
		EndIf

        DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP1,.F.,.T.)
		
		If (cTMP1)->(EOF()) .Or. (cTMP1)->SY_NUMREG == 0
            (cTMP1)->(DbCloseArea())
            LOOP
        EndIf

        (cTMP1)->(DbCloseArea())

		aEstrutura := XNULoad(cArqMenu)
		nOrdem := 0

		For nY := 1 To Len(aEstrutura)

			DO CASE
				CASE SubStr(UPPER(StrTran(aEstrutura[nY][1][1],"&")),1,4) == "ATUA"
					cTipo := "Atualizacoes"
				CASE SubStr(UPPER(StrTran(aEstrutura[nY][1][1],"&")),1,4) == "CONS"
					cTipo := "Consultas"
				CASE SubStr(UPPER(StrTran(aEstrutura[nY][1][1],"&")),1,4) == "RELA"
					cTipo := "Relatorios"
				CASE SubStr(UPPER(StrTran(aEstrutura[nY][1][1],"&")),1,4) == "MISC"
					cTipo := "Miscelaneas"
			ENDCASE
			
			XBuscFunc(aEstrutura[nY], cTipo)
		Next nY
	Next nX

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณUsrExcel บAutor  ณMauro Paladini      บ Data ณ  23/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar para processamento do relatorio             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function UsrExcel()

	Local oExcel 		:= FWMSEXCEL():New()
	Local cPathExcel	:= GetTempPath(.T.)
    Local cTMP1         := GetNextAlias()
	Local cDirDocs    	:= MsDocPath()

	Local aLinha

	Local nX
	Local nY
	Local a

	oExcel:AddworkSheet("Lista Usuarios")
	
	oExcel:AddTable ("Lista Usuarios","Lista Usuarios")
	
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Grupo"		,1,1) // Grupo - Grupo de usuแrios
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Desc. Grupo",1,1) // Desc. Grupo - Descri็ใo do Grupo
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Login"		,1,1) // Login - Id de acesso do usuแrio
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Nome"		,1,1) // Nome  - Nome completo do usuแrio
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Departamento",1,1) // Departamento - Departamento do usuแrio
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Cargo"		,1,1) // Cargo - Cargo atual do usuแrio
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","E-mail"		,1,1) // E-mail - E-mail do usuแrio
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Status"		,1,1) // Status - Status: Ativo ou Bloqueado
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Menu"		,1,1) // Menu - Menu de acesso do sistema
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","M๓dulo"		,1,1) // M๓dulo - M๓dulo de acesso do sistema
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Se็ใo"		,1,1) // Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Submenu"	,1,1) // Submenu - Nome da rotina a ser executada
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Descri็ใo"	,1,1) // Descri็ใo - Descri็ใo da rotina
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Fun็ใo"		,1,1) // Fun็ใo - Nome t้cnico da Fun็ใo

	If lImpOper
		oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Opera็ใo"	,1,1) // Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
	EndIf

    cQuery := " SELECT DISTINCT "+ CRLF		
    cQuery += "     USR.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     USR.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN, "+ CRLF 	// Login - Id de acesso do usuแrio
	cQuery += "     USR.SY_NOME, "+ CRLF 	// Nome  - Nome completo do usuแrio
	cQuery += "     USR.SY_DEPTO, "+ CRLF 	// Departamento - Departamento do usuแrio
	cQuery += "     USR.SY_CARGO, "+ CRLF 	// Cargo - Cargo atual do usuแrio
	cQuery += "     USR.SY_EMAIL, "+ CRLF 	// E-mail - E-mail do usuแrio
	cQuery += "     USR.SY_STATUS, "+ CRLF 	// Status - Status: Ativo ou Bloqueado
	cQuery += "     USR.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     USR.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
	cQuery += "     XNU.SY_SECAO, "+ CRLF	// Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
	cQuery += "     XNU.SY_SUBMENU, "+ CRLF // Submenu - Nome da rotina a ser executada
	cQuery += "     XNU.SY_ROTINA, "+ CRLF 	// Descri็ใo - Descri็ใo da rotina
	cQuery += "     XNU.SY_FUNCAO, "+ CRLF 	// Fun็ใo - Nome t้cnico da Fun็ใo
	cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo
    If lImpOper
		cQuery += "     ,XNU.SY_OPERAC "+ CRLF 	// Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
	EndIf
    cQuery += " FROM "+cTmpUsr+" USR (NOLOCK) "+ CRLF
    cQuery += " INNER JOIN "+cTmpXNU+" XNU (NOLOCK) "+ CRLF
    cQuery += "     ON XNU.SY_MENU = USR.SY_MENU "+ CRLF
    cQuery += " ORDER BY "+ CRLF
    cQuery += "     USR.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     USR.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN, "+ CRLF 	// Login - Id de acesso do usuแrio
	cQuery += "     USR.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     USR.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
    cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo
	
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP1,.F.,.T.)
		
	ProcRegua(RecCount())

	DbGoTop()
	
	While (cTMP1)->(!EOF())
		
		IncProc( "Usuario: " + Lower((cTMP1)->SY_LOGIN) )

		aLinha := IIF(lImpOper,Array(15),Array(14))

		aLinha[01] := (cTMP1)->SY_GRUPO 	// Grupo - Grupo de usuแrios
		aLinha[02] := (cTMP1)->SY_GRPDES 	// Desc. Grupo - Descri็ใo do Grupo
		aLinha[03] := (cTMP1)->SY_LOGIN 	// Login - Id de acesso do usuแrio
		aLinha[04] := (cTMP1)->SY_NOME 		// Nome  - Nome completo do usuแrio
		aLinha[05] := (cTMP1)->SY_DEPTO 	// Departamento - Departamento do usuแrio
		aLinha[06] := (cTMP1)->SY_CARGO 	// Cargo - Cargo atual do usuแrio
		aLinha[07] := (cTMP1)->SY_EMAIL 	// E-mail - E-mail do usuแrio
		aLinha[08] := (cTMP1)->SY_STATUS 	// Status - Status: Ativo ou Bloqueado
		aLinha[09] := (cTMP1)->SY_MENU 		// Menu - Menu de acesso do sistema
		aLinha[10] := (cTMP1)->SY_MODULO 	// M๓dulo - M๓dulo de acesso do sistema
		aLinha[11] := (cTMP1)->SY_SECAO		// Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
		aLinha[12] := (cTMP1)->SY_SUBMENU 	// Submenu - Nome da rotina a ser executada
		aLinha[13] := (cTMP1)->SY_ROTINA 	// Descri็ใo - Descri็ใo da rotina
		aLinha[14] := (cTMP1)->SY_FUNCAO 	// Fun็ใo - Nome t้cnico da Fun็ใo

		If lImpOper
			aLinha[15] := (cTMP1)->SY_OPERAC 	// Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
		EndIf

		oExcel:AddRow( "Lista Usuarios", "Lista Usuarios", aLinha )

		(cTMP1)->(DbSkip())
	EndDo
    
    (cTMP1)->(DbCloseArea())

	oExcel:Activate()

	cURLXML := '-'+ALLTRIM(CMONTH(DATE()))+ALLTRIM(STR(DAY(DATE())))+SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)

	//Cria o arquivo
	oExcel:Activate()
	oExcel:GetXMLFile(cDirDocs+"usuarios"+cURLXML+".xml")

	If __CopyFile(cDirDocs+"usuarios"+cURLXML+".xml",cPathExcel+"usuarios"+cURLXML+".xml")
		FErase(cDirDocs+"usuarios"+cURLXML+".xml")
	EndIf

	If ! ApOleClient( 'MsExcel' )
		MsgAlert( 'MsExcel nao instalado' )
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPathExcel+"usuarios"+cURLXML+".xml") // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGrpExcel บAutor  ณMauro Paladini      บ Data ณ  23/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar para processamento do relatorio             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GrpExcel()

	Local oExcel 		:= FWMSEXCEL():New()
	Local cPathExcel	:= GetTempPath(.T.)
	Local cDirDocs    	:= MsDocPath()
    Local cTMP1         := GetNextAlias()
    Local cTMP2         := GetNextAlias()

	Local aLinha

	Local nX
	Local nY
	Local a

	oExcel:AddworkSheet("Lista Grupos")
	
	oExcel:AddTable ("Lista Grupos","Lista Grupos")
	
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Grupo"		,1,1) // Grupo - Grupo de usuแrios
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Desc. Grupo",1,1) // Desc. Grupo - Descri็ใo do Grupo
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Status"		,1,1) // Status - Status: Ativo ou Bloqueado
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Menu"		,1,1) // Menu - Menu de acesso do sistema
	oExcel:AddColumn("Lista Grupos","Lista Grupos","M๓dulo"		,1,1) // M๓dulo - M๓dulo de acesso do sistema
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Se็ใo"		,1,1) // Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Submenu"	,1,1) // Submenu - Nome da rotina a ser executada
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Descri็ใo"	,1,1) // Descri็ใo - Descri็ใo da rotina
	oExcel:AddColumn("Lista Grupos","Lista Grupos","Fun็ใo"		,1,1) // Fun็ใo - Nome t้cnico da Fun็ใo

	If lImpOper
		oExcel:AddColumn("Lista Grupos","Lista Grupos","Opera็ใo"	,1,1) // Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
	EndIf

    cQuery := " SELECT DISTINCT "+ CRLF		
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     GRP.SY_STATUS, "+ CRLF 	// Status - Status: Ativo ou Bloqueado
	cQuery += "     GRP.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     GRP.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
	cQuery += "     XNU.SY_SECAO, "+ CRLF	// Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
	cQuery += "     XNU.SY_SUBMENU, "+ CRLF // Submenu - Nome da rotina a ser executada
	cQuery += "     XNU.SY_ROTINA, "+ CRLF 	// Descri็ใo - Descri็ใo da rotina
	cQuery += "     XNU.SY_FUNCAO, "+ CRLF 	// Fun็ใo - Nome t้cnico da Fun็ใo
	cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo
    If lImpOper
		cQuery += "     ,XNU.SY_OPERAC "+ CRLF 	// Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
	EndIf
    cQuery += " FROM "+cTmpGrp+" GRP (NOLOCK) "+ CRLF
    cQuery += " INNER JOIN "+cTmpXNU+" XNU (NOLOCK) "+ CRLF
    cQuery += "     ON XNU.SY_MENU = GRP.SY_MENU "+ CRLF
    cQuery += " ORDER BY "+ CRLF
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     GRP.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     GRP.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
	cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo

    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP1,.F.,.T.)
		
	ProcRegua(RecCount())

	DbGoTop()
	
	While (cTMP1)->(!EOF())
		
		IncProc( "Grupo: " + Lower((cTMP1)->SY_GRPDES) )

		aLinha := IIF(lImpOper,Array(10),Array(9))

		aLinha[01] := (cTMP1)->SY_GRUPO 	// Grupo - Grupo de usuแrios
		aLinha[02] := (cTMP1)->SY_GRPDES 	// Desc. Grupo - Descri็ใo do Grupo
		aLinha[03] := (cTMP1)->SY_STATUS 	// Status - Status: Ativo ou Bloqueado
		aLinha[04] := (cTMP1)->SY_MENU 		// Menu - Menu de acesso do sistema
		aLinha[05] := (cTMP1)->SY_MODULO 	// M๓dulo - M๓dulo de acesso do sistema
		aLinha[06] := (cTMP1)->SY_SECAO		// Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
		aLinha[07] := (cTMP1)->SY_SUBMENU 	// Submenu - Nome da rotina a ser executada
		aLinha[08] := (cTMP1)->SY_ROTINA 	// Descri็ใo - Descri็ใo da rotina
		aLinha[09] := (cTMP1)->SY_FUNCAO 	// Fun็ใo - Nome t้cnico da Fun็ใo

		If lImpOper
			aLinha[10] := (cTMP1)->SY_OPERAC 	// Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
		EndIf

		oExcel:AddRow( "Lista Grupos", "Lista Grupos", aLinha )

		(cTMP1)->(DbSkip())
	EndDo

    (cTMP1)->(DbCloseArea())

	oExcel:AddworkSheet("Lista Usuarios")
		
	oExcel:AddTable ("Lista Usuarios","Lista Usuarios")
		
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Grupo"		,1,1) // Grupo - Grupo de usuแrios
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Desc. Grupo",1,1) // Desc. Grupo - Descri็ใo do Grupo
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Login"		,1,1) // Login - Id de acesso do usuแrio
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Nome"		,1,1) // Nome  - Nome completo do usuแrio
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Departamento",1,1) // Departamento - Departamento do usuแrio
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Cargo"		,1,1) // Cargo - Cargo atual do usuแrio
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","E-mail"		,1,1) // E-mail - E-mail do usuแrio
    oExcel:AddColumn("Lista Usuarios","Lista Usuarios","Status"		,1,1) // Status - Status: Ativo ou Bloqueado

    cQuery := " SELECT DISTINCT "+ CRLF
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN, "+ CRLF 	// Login - Id de acesso do usuแrio
	cQuery += "     USR.SY_NOME, "+ CRLF 	// Nome  - Nome completo do usuแrio
	cQuery += "     USR.SY_DEPTO, "+ CRLF 	// Departamento - Departamento do usuแrio
	cQuery += "     USR.SY_CARGO, "+ CRLF 	// Cargo - Cargo atual do usuแrio
	cQuery += "     USR.SY_EMAIL, "+ CRLF 	// E-mail - E-mail do usuแrio
	cQuery += "     USR.SY_STATUS "+ CRLF 	// Status - Status: Ativo ou Bloqueado
    cQuery += " FROM "+cTmpGrp+" GRP (NOLOCK) "+ CRLF
    cQuery += " INNER JOIN "+cTmpUsr+" USR (NOLOCK) "+ CRLF
    cQuery += "     ON USR.SY_GRUPO = GRP.SY_GRUPO "+ CRLF
    cQuery += " ORDER BY "+ CRLF
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN "+ CRLF 	// Login - Id de acesso do usuแrio
    
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
		
	ProcRegua(RecCount())

	DbGoTop()
	
	While (cTMP2)->(!EOF())
		
		IncProc( "Usuarios: " + Lower((cTMP2)->SY_LOGIN) )

		aLinha := Array(8)

		aLinha[01] := (cTMP2)->SY_GRUPO 	// Grupo - Grupo de usuแrios
		aLinha[02] := (cTMP2)->SY_GRPDES 	// Desc. Grupo - Descri็ใo do Grupo
		aLinha[03] := (cTMP2)->SY_LOGIN 	// Login - Id de acesso do usuแrio
		aLinha[04] := (cTMP2)->SY_NOME 		// Nome  - Nome completo do usuแrio
		aLinha[05] := (cTMP2)->SY_DEPTO 	// Departamento - Departamento do usuแrio
		aLinha[06] := (cTMP2)->SY_CARGO 	// Cargo - Cargo atual do usuแrio
		aLinha[07] := (cTMP2)->SY_EMAIL 	// E-mail - E-mail do usuแrio
		aLinha[08] := (cTMP2)->SY_STATUS 	// Status - Status: Ativo ou Bloqueado

		oExcel:AddRow( "Lista Usuarios", "Lista Usuarios", aLinha )

		(cTMP2)->(DbSkip())
	EndDo

    (cTMP2)->(DbCloseArea())

	oExcel:Activate()

	cURLXML := '-'+ALLTRIM(CMONTH(DATE()))+ALLTRIM(STR(DAY(DATE())))+SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)

	//Cria o arquivo
	oExcel:Activate()
	oExcel:GetXMLFile(cDirDocs+"grupos_usuarios"+cURLXML+".xml")

	If __CopyFile(cDirDocs+"grupos_usuarios"+cURLXML+".xml",cPathExcel+"grupos_usuarios"+cURLXML+".xml")
		FErase(cDirDocs+"grupos_usuarios"+cURLXML+".xml")
	EndIf

	If ! ApOleClient( 'MsExcel' )
		MsgAlert( 'MsExcel nao instalado' )
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cPathExcel+"grupos_usuarios"+cURLXML+".xml") // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FEFINR03 บ Autor ณ Wilson A. Silva Jr.บ Data ณ  23/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Acessos e Permissoes por Usuarios.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ListaModulos(cModulo,nTipo)

Local nModulo 	:= Val(cModulo)
Local xRetorno 	:= ""

DEFAULT nTipo := 1

If nModulo > 0 .And. nModulo <= Len(aModulo)
	DO CASE
		CASE nTipo == 1 // Descri็ใo
			xRetorno := aModulo[nModulo][3]
		CASE nTipo == 2 // C๓digo
			xRetorno := SubStr(aModulo[nModulo][2],5,3)
	ENDCASE
EndIf

Return xRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ XBuscFuncบ Autor ณ Wilson A. Silva Jr.บ Data ณ  23/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Acessos e Permissoes por Usuarios.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function XBuscFunc(aEstrutura, cMenuPai)

Local nX
Local nY

Local cFuncao
Local aBotoes

If Len(aEstrutura) == 5	.And. aEstrutura[2] == "E" // Somente Itens habilitados
	For nX := 1 To Len(aEstrutura[3])
		XBuscFunc(aEstrutura[3][nX], aEstrutura[1][1])
	Next nX
ElseIf Len(aEstrutura) >= 7 .And. aEstrutura[2] == "E" // Somente Itens habilitados
	cFuncao := Upper(RTrim(aEstrutura[3]))
	aBotoes := {}

	If lImpOper //.And. !AllTrim(cTipo)$'Consultas|Relatorios|Miscelaneas'
		cCodMod := ListaModulos(RTrim(aEstrutura[6]),2)
		xStart:='startjob("U_X3LoadMenu",getenvserver(),.T.,cEmpAnt,cFilant,cCodMod,cFuncao)'
		aBotoes :=&xStart
	EndIf

	If ValType(aBotoes) <> "A" .Or. Len(aBotoes) == 0 .Or. ValType(aBotoes[1]) <> "A"
		aBotoes := {}
		AADD( aBotoes, Array(8) )
		aBotoes[1][1] := cTipo   
	EndIf

	For nY := 1 To Len(aBotoes)
		//Se menus com 10x :
        //Imprime as op็๕es do menudef (at้ 10) que estใo marcadas com x
        //Imprime as op็๕es do menudef > 10
        //Se menus com 20x imprime as op็๕es do menudef que estใo marcadas com x.
   
	 
	    If (len(aEstrutura[5]) = 10 .and. nY > 10) .or.; 
		   (len(aEstrutura[5]) = 10 .and. Upper(SubStr(aEstrutura[5],nY,1)) == "X") .or. ;
		   (len(aEstrutura[5]) > 10 .and. Upper(SubStr(aEstrutura[5],nY,1)) == "X") .or. ;
		   (len(aBotoes)) = 1

	

			nOrdem++

			DbSelectArea(cTmpXNU)
			RecLock(cTmpXNU,.T.)
				REPLACE SY_MENU		WITH cArqMenu // Menu - Menu de acesso do sistema
				REPLACE SY_SECAO	WITH cTipo // Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
				REPLACE SY_SUBMENU	WITH RTrim(cMenuPai) // Submenu - Nome da rotina a ser executada
				REPLACE SY_ROTINA	WITH RTrim(StrTran(aEstrutura[1][1],"&")) // Descri็ใo - Descri็ใo da rotina
				REPLACE SY_FUNCAO	WITH cFuncao // Fun็ใo - Nome t้cnico da Fun็ใo
				REPLACE SY_OPERAC	WITH aBotoes[nY][1] // Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
				REPLACE SY_ORDOPER	WITH StrZero(nOrdem,9) // Ordem da Opera็ใo
			MsUnLock()
		EndIf
	Next nY
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FEFINR02 บ Autor ณ Wilson A. Silva Jr.บ Data ณ  23/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Acessos e Permissoes por Usuarios.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function X3LoadMenu(cEmpTrab,cFilTrab,cCodMod,cFuncao)

Local aBotoes

PREPARE ENVIRONMENT EMPRESA cEmpTrab FILIAL cFilTrab MODULO cCodMod

aBotoes := FWLoadMenuDef(cFuncao)   

If cfuncao = "EICAM102"
   alert("eicam102")
Endif

RESET ENVIRONMENT

Return aBotoes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjr780RptDefบAutor  ณVendas e CRM      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para informar as celulas que serao utilizadas no re- บฑฑ
ฑฑบ          ณlatorio                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Ljr780RptDef()

Local oReport		// Objeto do relatorio
Local oSection1		// Objeto da secao 1
Local cMsg 		:= "Este programa ira emitir um relatorio de Lista de Usuแrios."
Local cNome 	:= "RelatorioUsrSOD-"+DtoS(dDataBase)+"-"+STRTRAN(TIME(),":","")
Local cTMP1  	:= GetNextAlias()
Local cTMP2 	:= GetNextAlias()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport:= TReport():New(cNome,"Lista de Usuแrios",Nil,{|oReport| Ljr780PrtRpt(oReport,cTMP1,cTMP2)}, cMsg )
oReport:SetLandScape()
oReport:DisableOrientation()
oReport:HideFooter()
oReport:SetTotalInLine(.F.)
oReport:ShowParamPage() // Imprimi pagina de parametros

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorio, informando que o arquivo principal utlizado eh o SL2 e o complementar o SB1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New(oReport,"Lista de Usuแrios",{cTMP1} )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
TRCell():New( 	oSection		, <cName>			, [ <cAlias> ]			, [ <cTitle> ],;
				[ <cPicture> ]	, [ <nSize> ]		, [ <.lPixel.> ]		, [ <bBlock> ],;
				[ <"cAlign"> ]	, [ <.lLineBreak.> ], [ <"cHeaderAlign"> ]	, [ <.lCellBreak.> ],;
				[ <nColSpace> ]	, [<.lAutoSize.>]	, [ <nClrBack> ]		, [ <nClrFore> ],;
				[<.lBold.>])
*/
TRCell():New(oSection1,"SY_GRUPO"	,cTMP1, "Grupo"			,"",06	,NIL,{|| (cTMP1)->SY_GRUPO	},,,,,,,,,.T.) 	// Grupo - Grupo de usuแrios
TRCell():New(oSection1,"SY_GRPDES"	,cTMP1, "Desc. Grupo"	,"",30	,NIL,{|| (cTMP1)->SY_GRPDES	},,,,,,,,,.T.) 	// Desc. Grupo - Descri็ใo do Grupo
If nAnalise == 1
	TRCell():New(oSection1,"SY_LOGIN"	,cTMP1, "Login"			,"",25	,NIL,{|| (cTMP1)->SY_LOGIN	},,,,,,,,,.T.) 	// Login - Id de acesso do usuแrio
	TRCell():New(oSection1,"SY_NOME"	,cTMP1, "Nome"			,"",40	,NIL,{|| (cTMP1)->SY_NOME	},,,,,,,,,.T.) 	// Nome  - Nome completo do usuแrio
	//TRCell():New(oSection1,"SY_DEPTO"	,cTMP1, "Departamento"	,"",40	,NIL,{|| (cTMP1)->SY_DEPTO	},,,,,,,,,.T.) 	// Departamento - Departamento do usuแrio
	//TRCell():New(oSection1,"SY_CARGO"	,cTMP1, "Cargo"			,"",40	,NIL,{|| (cTMP1)->SY_CARGO	},,,,,,,,,.T.) 	// Cargo - Cargo atual do usuแrio
	//TRCell():New(oSection1,"SY_EMAIL"	,cTMP1, "E-mail"		,"",40	,NIL,{|| (cTMP1)->SY_EMAIL	},,,,,,,,,.T.) 	// E-mail - E-mail do usuแrio
EndIf
TRCell():New(oSection1,"SY_STATUS"	,cTMP1, "Status"		,"",09	,NIL,{|| (cTMP1)->SY_STATUS	},,,,,,,,,.T.) 	// Status - Status: Ativo ou Bloqueado
//TRCell():New(oSection1,"SY_MENU"	,cTMP1, "Menu"			,"",50	,NIL,{|| (cTMP1)->SY_MENU	},,,,,,,,,.T.) 	// Menu - Menu de acesso do sistema
TRCell():New(oSection1,"SY_MODULO"	,cTMP1, "M๓dulo"		,"",35	,NIL,{|| (cTMP1)->SY_MODULO	},,,,,,,,,.T.) 	// M๓dulo - M๓dulo de acesso do sistema
TRCell():New(oSection1,"SY_SECAO"	,cTMP1, "Se็ใo"			,"",35	,NIL,{|| (cTMP1)->SY_SECAO	},,,,,,,,,.T.)	// Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
TRCell():New(oSection1,"SY_SUBMENU"	,cTMP1, "Submenu"		,"",35	,NIL,{|| (cTMP1)->SY_SUBMENU	},,,,,,,,,.T.) 	// Submenu - Nome da rotina a ser executada
TRCell():New(oSection1,"SY_ROTINA"	,cTMP1, "Descri็ใo"		,"",35	,NIL,{|| (cTMP1)->SY_ROTINA	},,,,,,,,,.T.) 	// Descri็ใo - Descri็ใo da rotina
TRCell():New(oSection1,"SY_FUNCAO"	,cTMP1, "Fun็ใo"		,"",35	,NIL,{|| (cTMP1)->SY_FUNCAO	},,,,,,,,,.T.)	// Fun็ใo - Nome t้cnico da Fun็ใo
If lImpOper
	TRCell():New(oSection1,"SY_OPERAC"	,cTMP1, "Opera็ใo"		,"",35	,NIL,{|| (cTMP1)->SY_OPERAC	},,,,,,,,,.T.) 	// Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
EndIf

If nAnalise == 2
	oSection2 := TRSection():New(oReport,"Lista de Usuแrios",{cTMP2} )

	TRCell():New(oSection2,"SY_GRUPO"	,cTMP2, "Grupo"			,"",06	,NIL,{|| (cTMP2)->SY_GRUPO	},,,,,,,,,.T.) 	// Grupo - Grupo de usuแrios
	TRCell():New(oSection2,"SY_GRPDES"	,cTMP2, "Desc. Grupo"	,"",30	,NIL,{|| (cTMP2)->SY_GRPDES	},,,,,,,,,.T.) 	// Desc. Grupo - Descri็ใo do Grupo
	TRCell():New(oSection2,"SY_LOGIN"	,cTMP2, "Login"			,"",25	,NIL,{|| (cTMP2)->SY_LOGIN	},,,,,,,,,.T.) 	// Login - Id de acesso do usuแrio
	TRCell():New(oSection2,"SY_NOME"	,cTMP2, "Nome"			,"",40	,NIL,{|| (cTMP2)->SY_NOME	},,,,,,,,,.T.) 	// Nome  - Nome completo do usuแrio
	//TRCell():New(oSection2,"SY_DEPTO"	,cTMP2, "Departamento"	,"",40	,NIL,{|| (cTMP2)->SY_DEPTO	},,,,,,,,,.T.) 	// Departamento - Departamento do usuแrio
	//TRCell():New(oSection2,"SY_CARGO"	,cTMP2, "Cargo"			,"",40	,NIL,{|| (cTMP2)->SY_CARGO	},,,,,,,,,.T.) 	// Cargo - Cargo atual do usuแrio
	//TRCell():New(oSection2,"SY_EMAIL"	,cTMP2, "E-mail"		,"",40	,NIL,{|| (cTMP2)->SY_EMAIL	},,,,,,,,,.T.) 	// E-mail - E-mail do usuแrio
	TRCell():New(oSection2,"SY_STATUS"	,cTMP2, "Status"		,"",09	,NIL,{|| (cTMP2)->SY_STATUS	},,,,,,,,,.T.) 	// Status - Status: Ativo ou Bloqueado
EndIf

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjr780PrtRptบAutor  ณVendas e CRM        บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Ljr780PrtRpt(oReport,cTMP1,cTMP2)

Local oSection1 := Nil
Local oSection2 := Nil 
Local cQuery    := ""

Processa({|| RunReport()},"Processando ..." )

If nAnalise == 1
	oSection1 := oReport:Section(1)	// Define a secao 1 do relatorio

	cQuery := " SELECT DISTINCT "+ CRLF		
	cQuery += "     USR.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     USR.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN, "+ CRLF 	// Login - Id de acesso do usuแrio
	cQuery += "     USR.SY_NOME, "+ CRLF 	// Nome  - Nome completo do usuแrio
	cQuery += "     USR.SY_DEPTO, "+ CRLF 	// Departamento - Departamento do usuแrio
	cQuery += "     USR.SY_CARGO, "+ CRLF 	// Cargo - Cargo atual do usuแrio
	cQuery += "     USR.SY_EMAIL, "+ CRLF 	// E-mail - E-mail do usuแrio
	cQuery += "     USR.SY_STATUS, "+ CRLF 	// Status - Status: Ativo ou Bloqueado
	cQuery += "     USR.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     USR.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
	cQuery += "     XNU.SY_SECAO, "+ CRLF	// Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
	cQuery += "     XNU.SY_SUBMENU, "+ CRLF // Submenu - Nome da rotina a ser executada
	cQuery += "     XNU.SY_ROTINA, "+ CRLF 	// Descri็ใo - Descri็ใo da rotina
	cQuery += "     XNU.SY_FUNCAO, "+ CRLF 	// Fun็ใo - Nome t้cnico da Fun็ใo
	cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo
	If lImpOper
		cQuery += "     ,XNU.SY_OPERAC "+ CRLF 	// Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
	EndIf
	cQuery += " FROM "+cTmpUsr+" USR (NOLOCK) "+ CRLF
	cQuery += " INNER JOIN "+cTmpXNU+" XNU (NOLOCK) "+ CRLF
	cQuery += "     ON XNU.SY_MENU = USR.SY_MENU "+ CRLF
	cQuery += " ORDER BY "+ CRLF
	cQuery += "     USR.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     USR.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN, "+ CRLF 	// Login - Id de acesso do usuแrio
	cQuery += "     USR.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     USR.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
	cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP1,.F.,.T.)
	
	oSection1:Init()
	While !oReport:Cancel() .And. (cTMP1)->(!EOF())
		oSection1:PrintLine()		
		oReport:IncMeter()
		(cTMP1)->(DbSkip())
	EndDo
	oSection1:Finish()

	(cTMP1)->(DbCloseArea())
Else
	oSection1 := oReport:Section(1)	// Define a secao 1 do relatorio
	oSection2 := oReport:Section(2)	// Define a secao 2 do relatorio

    cQuery := " SELECT DISTINCT "+ CRLF		
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     GRP.SY_STATUS, "+ CRLF 	// Status - Status: Ativo ou Bloqueado
	cQuery += "     GRP.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     GRP.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
	cQuery += "     XNU.SY_SECAO, "+ CRLF	// Se็ใo - Se็ใo: Atualiza็๕es, Consultas, Relat๓rios ou Miscelaneas
	cQuery += "     XNU.SY_SUBMENU, "+ CRLF // Submenu - Nome da rotina a ser executada
	cQuery += "     XNU.SY_ROTINA, "+ CRLF 	// Descri็ใo - Descri็ใo da rotina
	cQuery += "     XNU.SY_FUNCAO, "+ CRLF 	// Fun็ใo - Nome t้cnico da Fun็ใo
	cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo
    If lImpOper
		cQuery += "     ,XNU.SY_OPERAC "+ CRLF 	// Opera็ใo - Nome da opera็ใo. Exemplo: Incluir, Alterar, Excluir, Etc
	EndIf
    cQuery += " FROM "+cTmpGrp+" GRP (NOLOCK) "+ CRLF
    cQuery += " INNER JOIN "+cTmpXNU+" XNU (NOLOCK) "+ CRLF
    cQuery += "     ON XNU.SY_MENU = GRP.SY_MENU "+ CRLF
    cQuery += " ORDER BY "+ CRLF
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     GRP.SY_MENU, "+ CRLF 	// Menu - Menu de acesso do sistema
	cQuery += "     GRP.SY_MODULO, "+ CRLF 	// M๓dulo - M๓dulo de acesso do sistema
	cQuery += "     XNU.SY_ORDOPER "+ CRLF 	// Ordem da Opera็ใo

    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP1,.F.,.T.)

	cQuery := " SELECT DISTINCT "+ CRLF
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN, "+ CRLF 	// Login - Id de acesso do usuแrio
	cQuery += "     USR.SY_NOME, "+ CRLF 	// Nome  - Nome completo do usuแrio
	cQuery += "     USR.SY_DEPTO, "+ CRLF 	// Departamento - Departamento do usuแrio
	cQuery += "     USR.SY_CARGO, "+ CRLF 	// Cargo - Cargo atual do usuแrio
	cQuery += "     USR.SY_EMAIL, "+ CRLF 	// E-mail - E-mail do usuแrio
	cQuery += "     USR.SY_STATUS "+ CRLF 	// Status - Status: Ativo ou Bloqueado
    cQuery += " FROM "+cTmpGrp+" GRP (NOLOCK) "+ CRLF
    cQuery += " INNER JOIN "+cTmpUsr+" USR (NOLOCK) "+ CRLF
    cQuery += "     ON USR.SY_GRUPO = GRP.SY_GRUPO "+ CRLF
    cQuery += " ORDER BY "+ CRLF
    cQuery += "     GRP.SY_GRUPO, "+ CRLF 	// Grupo - Grupo de usuแrios
	cQuery += "     GRP.SY_GRPDES, "+ CRLF 	// Desc. Grupo - Descri็ใo do Grupo
	cQuery += "     USR.SY_LOGIN "+ CRLF 	// Login - Id de acesso do usuแrio
    
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
	
	oSection1:Init()
	While !oReport:Cancel() .And. (cTMP1)->(!EOF())
		oSection1:PrintLine()
		oReport:IncMeter()
		(cTMP1)->(DbSkip())
	EndDo
	oSection1:Finish()

	oSection2:Init()
	While !oReport:Cancel() .And. (cTMP2)->(!EOF())
		oSection2:PrintLine()
		oReport:IncMeter()
		(cTMP2)->(DbSkip())
	EndDo
	oSection2:Finish()

	(cTMP1)->(DbCloseArea())
	(cTMP2)->(DbCloseArea())
EndIf

Return .T.
