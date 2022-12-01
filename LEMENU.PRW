#include "rwmake.ch"
//#Include 'Protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ºCSVMenu   º Autor º Mauro Paladini Han º Data ³  23/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³Lista em formato CSV o conteudo dos arquivos XNU visando umaº±±
±±º          ³melhor visualizacao das rotinas disponiveis p/ os usuarios  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nil                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Static __lMnuInDB := MPMenuInDB()

User Function CSVMenu()

	Local cPerg := "XNU0000001"

	//aRetMod := RetModName()
	//aAllMenus := MPGetMenus()

	//	ValidPerg(cPerg)

	Pergunte(cPerg,.F.)

	@ 000,000 To 160,350 Dialog _WndMain TITLE "Auditoria em Menus"
	@ 005,005 To 040,165
	@ 015,010 Say OemToAnsi("Este programa ir agerar um arquivo CSV contendo a lista")
	@ 025,010 say OemToAnsi("dos programas disponiveis nos menus" )
	@ 055,080 Bmpbutton Type 1 Action ProcMenus()
	@ 055,110 Bmpbutton Type 2 Action Close(_WndMain)
	@ 055,140 Bmpbutton Type 5 Action Pergunte(cPerg,.T.)

	Activate Dialog _WndMain Centered

Return

Static Function ProcMenus()

	Close(_WndMain)
	Processa({|| RunReport()},"Processando ..." )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RunReport ºAutor  ³Mauro Paladini      º Data ³  23/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao auxiliar para processamento do relatorio             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunReport()

	//	Local cNomeArq	:= "MENUS.DBF"
	Local cNomeRel	:= "\LOGTRF\MENUS.CSV"
	Local aMenuAll	:= {}
	Local aAdminXnu	:= { "SIGAFAT","SIGAFIS" } //,"SIGACOM","SIGACON","SIGAGPE","SIGAEST","SIGAFAT","SIGAFIN","SIGAPON" }
	Local aCampos
	Local cRelTrb
	Local aMenuGrp
	Local a,b,c,z,x,s

	Local aUsuario := FWSFALLUSERS()//AllUsers()
	LOCAL	_nUsu 		:= 1 // PSWRET = DADOS USUARIO
	LOCAL	_nImp 		:= 2 // PSWRET = DADOS IMPRESSAO
	LOCAL 	_nMod 		:= 3 // PSWRET = DADOS MODULOS
	LOCAL 	_nSnp 		:= 4 // PSWRET = DADOS SENHAP
	LOCAL   _nTotUsr	:= Len(aUsuario)



	Private aAllGrupo	:= FWSFAllGrps()

	aCampos	:= {{"MENU","C",50,0},;
	{"GRUPO","C",35,0},/*submenu atualizacao,consulta,relatorio,miscelania*/;
	{"DESCRI","C",35,0},;
	{"MODO","C",1,0},;
	{"TIPO","C",15,0},;
	{"FUNCAO","C",12,0},;
	{"ACS","C",10,0},;
	{"MODULO","C",30,0},;
	{"ARQS","C",255,0},;
	{"A1","C",1,0},;
	{"A2","C",1,0},;
	{"A3","C",1,0},;
	{"A4","C",1,0},;
	{"A5","C",1,0},;
	{"A6","C",1,0},;
	{"A7","C",1,0},;
	{"A8","C",1,0},;
	{"A9","C",1,0},;
	{"A0","C",1,0},;
	{"LOGIN","C",20,0},;
	{"NOME","C",35,0},;
	{"DEPTO","C",30,0},;
	{"CARGO","C",30,0},;
	{"EMAIL","C",35,0},;
	{"DTCADAST","D",10,0},;
	{"GRPMENU","C",6,0},;
	{"STATUS","C",10,0}}

//	cRelTrb	:= CriaTrab(aCampos,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre arquivo de trabalho para gravar os dados do relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	DbUseArea(.T.,"DBFCDX",cRelTrb,"TRB",.T.,.F.)
	oTempTable := FWTemporaryTable():New("TRB")
	oTemptable:SetFields(aCampos)
	oTempTable:AddIndex("index01",{"MENU"})
	oTempTable:Create()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o relatorio ja existe gerado em disco ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File(cNomeRel)
		Delete File &(cNomeRel)
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obter lista de todos os menus utilizados pelos usuarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF MV_PAR01 == 1
		ProcRegua(Len(aUsuario))
		For x := 1 To Len(_nTotUsr)

			PswSeek( aPapUsr[x][2] ) 	// POSICIONO NO USUÁRIO CORRETO
			aInf      := PswRet()		// RETORNO INFORMAÇÕES DO USUÁRIO POSICIONADO


			IncProc( "Analisando cadastro de usuarios" )
			//			aDados1 := aUsuario[x,1]
			aDados1 := aInf[_nUsu,1]

			IF aDados1[1] == '000000'
				x ++
				Loop
			EndIF

			IF aDados1[1] < MV_PAR03 .or. aDados1[1] > MV_PAR04
				x ++
				Loop
			EndIF

			//			aDados2 := aUsuario[_nUsu,2]
			//			aDados3 := aUsuario[_nMod,3] // Menus
			aDados2 := aInf[_nUsu]
			aDados3 := aInf[_nMod] // Menus
			aDados4 := UsrRetGrp(aDados1[1])

			IF aDados1[1] == '000060'
				a:=1
			EndIF	

			cLogin	:= aDados1[2]
			cNome	:= AllTrim(aDados1[4])
			cDepto	:= AllTrim(aDados1[12])
			cCargo	:= AllTrim(aDados1[13])
			cEMail	:= AllTrim(aDados1[14])
			dDtInc	:= AllTrim(aDados1[24])
			_Status := IF( aDados1[17], 'Bloqueado','Ativo')

			If Len(aDados1[10]) = 0 // Grupos do Usuario

				For s := 1 To Len(aDados3)
					cMenu	:= AllTrim(Capital(AllTrim(Substr(aDados3[s],4,Len(aDados3[s])))))
					lUsado	:= IIF(Substr(aDados3[s],3,1)=="X",.F.,.T.)
					If lUsado
						If File(cMenu)
							aAdd( aMenuAll,{ cMenu,cLogin,cNome,cDepto,cCargo,cEMail,_Status," " } )
						Endif
					Endif
				Next
			Else
				For z := 1 to Len(aDados4)
					aMenuGrp:= FWGrpMenu(aDados4[z]) // Menus do Grupo
					For s := 1 To Len(aMenuGrp)
						cMenu	:= AllTrim(Capital(AllTrim(Substr(aMenuGrp[s],4,Len(aMenuGrp[s])))))
						lUsado	:= IIF(Substr(aMenuGrp[s],3,1)=="X",.F.,.T.)
						If lUsado
							If File(cMenu)		// 1      2     3     4      5      6       7      8
								aAdd( aMenuAll,{ cMenu,cLogin,cNome,cDepto,cCargo,cEMail,_Status,aDados4[z]} )
							Endif
						Endif
					Next
				Next z
			EndIF

		Next

	Elseif MV_PAR01 == 2
		For x := 1 To Len(aAdminXnu)
			aAdd( aMenuAll,{ "\SYSTEM\" + aAdminXnu[x] + ".XNU" ,"Administrador","Administrador","Tecnologia","","" } )
		Next
	Else
		aAdd( aMenuAll,{ UPPER(AllTrim(MV_PAR02)) ,"Menu","Menu","Configurador","","" } )
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A funcao XNULoad ira retornar para o      ³
	//³ vetor aEstrutura 4 elementos referente a: ³
	//³ aEstrutura[1] = Atualizacoes              ³
	//³ aEstrutura[2] = Consultas                 ³
	//³ aEstrutura[3] = Relatorios                ³
	//³ aEstrutura[4] = Miscelaneas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua(Len(aMenuAll))
	For z := 1 To Len(aMenuAll)

		IncProc( "Lendo " + Lower(AllTrim(aMenuAll[z,1])) )
		aEstrutura := XNULoad(aMenuAll[z,1])

		For a := 1 To Len(aEstrutura)

			If a == 1
				cTipo := "Atualizacoes"
			Elseif a == 2
				cTipo := "Consultas"
			Elseif a == 3
				cTipo := "Relatorios"
			Elseif a == 4
				cTipo := "Miscelaneas"
			Endif

			aParte    := aEstrutura[a]
			aGrupos   := aParte[3]

			For b := 1 To Len(aGrupos)
				IF aGrupos[b][2] == 'E' // Somente Itens habilitados
					If ValType(aGrupos[b][3]) == "A"

						aFuncoes  := aGrupos[b][3]
						cGrupo    := aGrupos[b][1][1]

						If ValType(aFuncoes) == "A"
							For c := 1 To Len(aFuncoes)
								IF Len(aFuncoes[c]) >= 7 .and. aFuncoes[c][2] == 'E'  // Somente Itens habilitados
									aAlias		:= aFuncoes[c][4]
									cArquivo	:= ""
									aEval( aAlias,{ |h| cArquivo += h + " " },,)

									DbSelectArea("TRB")
									RecLock("TRB",.T.)
									TRB->MENU	:= aMenuAll[z,1]
									TRB->STATUS := aMenuAll[z,7]
									TRB->DESCRI	:= RTrim(aFuncoes[c][1][1])
									TRB->MODO	:= aFuncoes[c][2]
									TRB->TIPO	:= cTipo
									TRB->FUNCAO	:= Upper(RTrim(aFuncoes[c][3]))
									TRB->ACS	:= Upper(aFuncoes[c][5])
									TRB->GRPMENU:= aMenuAll[z,8]
									TRB->MODULO	:= ListaModulos(RTrim(aFuncoes[c][6]))  //RTrim(aFuncoes[c][6])
									TRB->ARQS	:= RTrim(cArquivo)
									TRB->GRUPO	:= RTrim(cGrupo)
									TRB->A1		:= Substr(Upper(aFuncoes[c][5]) ,1,1)
									TRB->A2		:= Substr(Upper(aFuncoes[c][5]) ,2,1)
									TRB->A3		:= Substr(Upper(aFuncoes[c][5]) ,3,1)
									TRB->A4		:= Substr(Upper(aFuncoes[c][5]) ,4,1)
									TRB->A5		:= Substr(Upper(aFuncoes[c][5]) ,5,1)
									TRB->A6		:= Substr(Upper(aFuncoes[c][5]) ,6,1)
									TRB->A7		:= Substr(Upper(aFuncoes[c][5]) ,7,1)
									TRB->A8		:= Substr(Upper(aFuncoes[c][5]) ,8,1)
									TRB->A9		:= Substr(Upper(aFuncoes[c][5]) ,9,1)
									TRB->A0		:= Substr(Upper(aFuncoes[c][5]) ,10,1)
									TRB->LOGIN	:= RTrim(aMenuAll[z,2])
									TRB->NOME	:= RTrim(Capital(aMenuAll[z,3]))
									TRB->DEPTO	:= RTrim(Capital(aMenuAll[z,4]))
									TRB->CARGO	:= RTrim(Capital(aMenuAll[z,5]))
									TRB->EMAIL	:= RTrim(lower(aMenuAll[z,6]))
									MsUnLock()
								Endif
							Next
						Endif
					Else
						IF RTrim(aGrupos[b][2]) =='E'
							DbSelectArea("TRB")
							RecLock("TRB",.T.)
							TRB->MENU	:= aMenuAll[z,1]
							TRB->STATUS := aMenuAll[z,7]
							TRB->DESCRI	:= RTrim(aGrupos[b][1][1])
							TRB->MODO	:= RTrim(aGrupos[b][2])
							TRB->TIPO	:= cTipo
							TRB->FUNCAO	:= RTrim(Upper(RTrim(aGrupos[b][3])))
							TRB->ACS	:= RTrim(Upper(aGrupos[b][5]))
							TRB->GRPMENU:= aMenuAll[z,8]
							TRB->MODULO	:= ListaModulos(RTrim(aGrupos[b][6]))
							TRB->ARQS	:= RTrim(cArquivo)
							TRB->GRUPO	:= RTrim(cGrupo)
							TRB->A1		:= Substr(Upper(aGrupos[b][5]) ,1,1)
							TRB->A2		:= Substr(Upper(aGrupos[b][5]) ,2,1)
							TRB->A3		:= Substr(Upper(aGrupos[b][5]) ,3,1)
							TRB->A4		:= Substr(Upper(aGrupos[b][5]) ,4,1)
							TRB->A5		:= Substr(Upper(aGrupos[b][5]) ,5,1)
							TRB->A6		:= Substr(Upper(aGrupos[b][5]) ,6,1)
							TRB->A7		:= Substr(Upper(aGrupos[b][5]) ,7,1)
							TRB->A8		:= Substr(Upper(aGrupos[b][5]) ,8,1)
							TRB->A9		:= Substr(Upper(aGrupos[b][5]) ,9,1)
							TRB->A0		:= Substr(Upper(aGrupos[b][5]) ,10,1)
							TRB->LOGIN	:= RTrim(aMenuAll[z,2])
							TRB->NOME	:= RTrim(Capital(aMenuAll[z,3]))
							TRB->DEPTO	:= RTrim(Capital(aMenuAll[z,4]))
							TRB->CARGO	:= RTrim(Capital(aMenuAll[z,5]))
							TRB->EMAIL	:= RTrim(lower(aMenuAll[z,6]))
							//a := IF(Empty(aGrupos[b][3]),"",FWMVCMenu( Upper(aGrupos[b][3]))	) 
							MsUnLock()
						EndIF
					Endif
				EndIF
			Next

		Next

	Next


	DbSelectArea("TRB")
	DbGoTop()
	Processa({|| Excel()},"Gerando o Excel..." )

	//Copy To &cNomeArq
	DbCloseArea()

Return

Static Function Excel()

	Local oExcel 		:= FWMSEXCEL():New()
	Local _cPathExcel	:= "C:\TEMP\"
	Local a
	Local x
	Local cLogin
	Local cNome
	Local cDepto
	Local cCargo
	Local cEMail
	Local _Status
	Local _aGrupos
	Local xc

	oExcel:AddworkSheet("Lista Usuarios")
	oExcel:AddTable ("Lista Usuarios","Lista Usuarios")
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","GRP.MENU",1,1)		
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","LOGIN",1,1)			//20
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","NOME",1,1)			//21
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","DEPTO",1,1)			//22
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","CARGO",1,1)			//23
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","EMAIL",1,1)			//24
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","STATUS",1,1)		//25
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","MENU",1,1) 			//01
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","MODULO",1,1)		//07
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","SEÇÃO",1,1)			//04
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","SUBMENU",1,1)		//09
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","DESCRICAO",1,1)		//02
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","MODO",1,1)			//03
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","FUNCAO",1,1)		//05

	//oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ACS",1,1)			//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","PESQUISA"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","VISUALIZAR"	,1,1)	//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","INCLUI"		,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ALTERA"		,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","EXCLUI"		,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_1"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_2"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_3"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_4"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_5"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_6"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_7"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_8"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_9"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPEC_10"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","CONSULTA"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","IMPRIMI"	,1,1)		//06
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","PROCESSA"	,1,1)		//06	
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ESPECIFICO"	,1,1)	//06	
	/*
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","ARQS",1,1)			//08

	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A1",1,1)			//10
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A2",1,1)			//11
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A3",1,1)			//12
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A4",1,1)			//13
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A5",1,1)			//14
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A6",1,1)			//15
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A7",1,1)			//16
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A8",1,1)			//17
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A9",1,1)			//18
	oExcel:AddColumn("Lista Usuarios","Lista Usuarios","A0",1,1)			//19
	*/

	dbSelectArea("TRB")
	dbGoTop()
	ProcRegua( RecCount()   )
	While !EOF()

		cPesq	:= "NÃO"
		cVisual	:= "NÃO"
		cIncluir:= "NÃO"
		cAltera	:= "NÃO"
		cExcluir:= "NÃO"
		cEspec1	:= "NÃO"
		cEspec2	:= "NÃO"
		cEspec3	:= "NÃO"
		cEspec4	:= "NÃO"
		cEspec5	:= "NÃO"
		cEspec6	:= "NÃO"
		cEspec7	:= "NÃO"
		cEspec8	:= "NÃO"
		cEspec9	:= "NÃO"
		cEspec0	:= "NÃO"

		IncProc( "Usuario " + Lower(TRB->LOGIN) )

		IF mv_par05 == 3 .and. AllTrim(TRB->STATUS) == 'Ativo'
			dbSkip()
			Loop
		ElseIF mv_par05 == 2 .and. AllTrim(TRB->STATUS) == 'Bloqueado'
			dbSkip()
			Loop
		EndIF

		IF mv_par06 = 2 .and. AllTrim(TRB->TIPO) <> 'Atualizacoes' // Imprime somente atualizaçoes
			dbSkip()
			Loop
		ElseIf mv_par06 = 3 .and. AllTrim(TRB->TIPO) <> 'Consultas' // Imprime somente Consulta
			dbSkip()
			Loop
		ElseIf mv_par06 = 4 .and. AllTrim(TRB->TIPO) <> 'Relatorios' // Imprime somente Relatorios
			dbSkip()
			Loop
		ElseIf mv_par06 = 5 .and. AllTrim(TRB->TIPO) <> 'Miscelaneas' // Imprime somente Miscelaneas
			dbSkip()
			Loop
		EndIF

		_aBotoes := {}
		_cBotoes := ""		
		lCadastro:= .F.																// Lista de programas que da erro no menudef
		IF !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas' .AND. !AllTrim(TRB->FUNCAO) $ "EASYCADWOR|EECAE100|EASYCADWOR|SPEDNFE|SPEDNFSE|FISA022"
			//ConOut(TRB->FUNCAO )
			_aBotoes := FWLoadMenuDef( TRB->FUNCAO )
			// MV_AUTOCOM = 2
			IF ValType(_aBotoes) <> "U"

				For a:=1 to Len(_aBotoes)
					//ConOut(AllTrim(_aBotoes[a,1]))
					IF AllTrim(_aBotoes[a,1]) $ "Pesquisar" //"Incluir | Alterar | Excluir |"
						cPesq		:= IF(SUBSTR(TRB->ACS,01,1)='X' ,'SIM','NÃO') //.and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
					ElseIF AllTrim(_aBotoes[a,1]) $ "Visualizar"
						cVisual		:= IF(SUBSTR(TRB->ACS,02,1)='X' ,'SIM','NÃO') ///.and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
					ElseIF AllTrim(_aBotoes[a,1]) $ "Incluir"
						cIncluir	:= IF(SUBSTR(TRB->ACS,03,1)='X' ,'SIM','NÃO') //.and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO') 		//06
					ElseIF AllTrim(_aBotoes[a,1]) $ "Alterar"
						cAltera		:= IF(SUBSTR(TRB->ACS,04,1)='X' ,'SIM','NÃO') //.and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO') 		//06
					ElseIF AllTrim(_aBotoes[a,1]) $ "Excluir"
						cExcluir	:= IF(SUBSTR(TRB->ACS,05,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 1
						cEspec1		:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 2
						cEspec2		:= IF(SUBSTR(TRB->ACS,02,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 3
						cEspec3		:= IF(SUBSTR(TRB->ACS,03,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 4
						cEspec4		:= IF(SUBSTR(TRB->ACS,04,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 5
						cEspec5		:= IF(SUBSTR(TRB->ACS,05,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 6
						cEspec6		:= IF(SUBSTR(TRB->ACS,06,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 7
						cEspec7		:= IF(SUBSTR(TRB->ACS,07,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')						
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 8
						cEspec8		:= IF(SUBSTR(TRB->ACS,08,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')						
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 9
						cEspec9		:= IF(SUBSTR(TRB->ACS,09,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					ElseIF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar | Incluir | Alterar | Excluir |" .AND. a = 10
						cEspec0		:= IF(SUBSTR(TRB->ACS,10,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
						_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "

					EndIF
					/*
					Else
					IF !AllTrim(_aBotoes[a,1]) $ "Pesquisar | Visualizar |"
					//ConOut("Botao:"+AllTrim(_aBotoes[a,1]))
					//IF ValType(EncodeUtf8(AllTrim(_aBotoes[a,1]))) = "C"
					_cBotoes += AllTrim(_aBotoes[a,1])+" | " //EncodeUtf8(AllTrim(_aBotoes[a,1]))+" | "
					//EndIF
					EndIF
					EndIF
					*/	
				Next a


			EndIF
		Else
			cConsulta	:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Atualizacoes|Relatorios|Miscelaneas','SIM','NÃO')
			cImprimi	:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Atualizacoes|Miscelaneas','SIM','NÃO')
			cProcessa	:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Atualizacoes|Relatorios','SIM','NÃO')


		EndIF	

		/*
		cPesq		:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
		cVisual		:= IF(SUBSTR(TRB->ACS,02,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
		cIncluir	:= IF(SUBSTR(TRB->ACS,03,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO') 		//06
		cAltera		:= IF(SUBSTR(TRB->ACS,04,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO') 		//06
		cExcluir	:= IF(SUBSTR(TRB->ACS,05,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Relatorios|Miscelaneas','SIM','NÃO')
		*/
		cConsulta	:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Atualizacoes|Relatorios|Miscelaneas','SIM','NÃO')
		cImprimi	:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Atualizacoes|Miscelaneas','SIM','NÃO')
		cProcessa	:= IF(SUBSTR(TRB->ACS,01,1)='X' .and. !AllTrim(TRB->TIPO)$'Consultas|Atualizacoes|Relatorios','SIM','NÃO')


		oExcel:AddRow("Lista Usuarios","Lista Usuarios", ;
		{TRB->GRPMENU, TRB->LOGIN,TRB->NOME,TRB->DEPTO,TRB->CARGO,;
		TRB->EMAIL,TRB->STATUS,TRB->MENU,TRB->MODULO,TRB->TIPO,;
		TRB->GRUPO,TRB->DESCRI,TRB->MODO,TRB->FUNCAO,;
		cPesq,cVisual,cIncluir,cAltera,cExcluir,cEspec1,cEspec2,cEspec3,cEspec4,cEspec5,;
		cEspec6,cEspec7,cEspec8,cEspec9,cEspec0,cConsulta,cImprimi,cProcessa, _cBotoes } )

		dbSkip()
	End

	oExcel:AddworkSheet("Grupos de Usuarios")
	oExcel:AddTable ("Grupos de Usuarios","Grupos")

	oExcel:AddColumn("Grupos de Usuarios","Grupos","Id do grupo",1,1)				//21
	oExcel:AddColumn("Grupos de Usuarios","Grupos","Grupo",1,1)						//22
	oExcel:AddColumn("Grupos de Usuarios","Grupos","Descrição do grupo",1,1)		//23

	For xc:=1 to Len(aAllGrupo)
		oExcel:AddRow("Grupos de Usuarios","Grupos",{ aAllGrupo[xc][2],aAllGrupo[xc][3],aAllGrupo[xc][4]})
	Next

	oExcel:Activate()

	cURLXML := '-'+ALLTRIM(CMONTH(DATE()))+ALLTRIM(STR(DAY(DATE())))+SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)
	//Cria o arquivo
	oExcel:Activate()
	oExcel:GetXMLFile("usuarios"+cURLXML+".xml")
	__CopyFile("usuarios"+cURLXML+".xml",_cPathExcel+"usuarios"+cURLXML+".xml")
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( 'MsExcel nao instalado' )
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( _cPathExcel+"usuarios"+cURLXML+".xml") // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Microsiga           º Data ³  02/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as perguntas do programa no dicionario de perguntas    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//Static Function ValidPerg( cPerg )
//
//	Local aArea := GetArea()
//	Local aPerg:= {}
//	Local _nLaco
//
//	aAdd(aPerg,{cPerg,"01","Analisar quais menus ?","mv_ch1","N",01,0,1,"C","","mv_par01","Todos","","","Padrao","","","Especifico","","","","","","","","  ",})
//	aAdd(aPerg,{cPerg,"02","Menu especíico       ?","mv_ch2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",})
//	aAdd(aPerg,{cPerg,"03","Usuário De       	 ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",})
//	aAdd(aPerg,{cPerg,"04","Usuário Até			 ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","",})
//	aAdd(aPerg,{cPerg,"05","Status               ?","mv_ch5","N",01,0,1,"C","","mv_par05","Todos","","","Ativos","","","Bloqueado","","","","","","","","  ",})
//	aAdd(aPerg,{cPerg,"06","Imprime Sub-menu     ?","mv_ch6","N",01,0,1,"C","","mv_par06","Todos","","","Atualizacao","","","Consulta","","","Relatorios","","","Miscelaneas","","  ",})
//
//	DbSelectArea("SX1")
//	For _nLaco:=1 to LEN(aPerg)
//		If !dbSeek(aPerg[_nLaco,1]+aPerg[_nLaco,2])
//			RecLock("SX1",.T.)
//			SX1->X1_Grupo     := aPerg[_nLaco,01]
//			SX1->X1_Ordem     := aPerg[_nLaco,02]
//			SX1->X1_Pergunt   := aPerg[_nLaco,03]
//			SX1->X1_PerSpa    := aPerg[_nLaco,03]
//			SX1->X1_PerEng    := aPerg[_nLaco,03]
//			SX1->X1_Variavl   := aPerg[_nLaco,04]
//			SX1->X1_Tipo      := aPerg[_nLaco,05]
//			SX1->X1_Tamanho   := aPerg[_nLaco,06]
//			SX1->X1_Decimal   := aPerg[_nLaco,07]
//			SX1->X1_Presel    := aPerg[_nLaco,08]
//			SX1->X1_Gsc       := aPerg[_nLaco,09]
//			SX1->X1_Valid     := aPerg[_nLaco,10]
//			SX1->X1_Var01     := aPerg[_nLaco,11]
//			SX1->X1_Def01     := aPerg[_nLaco,12]
//			SX1->X1_Cnt01     := aPerg[_nLaco,13]
//			SX1->X1_Var02     := aPerg[_nLaco,14]
//			SX1->X1_Def02     := aPerg[_nLaco,15]
//			SX1->X1_Cnt02     := aPerg[_nLaco,16]
//			SX1->X1_Var03     := aPerg[_nLaco,17]
//			SX1->X1_Def03     := aPerg[_nLaco,18]
//			SX1->X1_Cnt03     := aPerg[_nLaco,19]
//			SX1->X1_Var04     := aPerg[_nLaco,20]
//			SX1->X1_Def04     := aPerg[_nLaco,21]
//			SX1->X1_Cnt04     := aPerg[_nLaco,22]
//			SX1->X1_Var05     := aPerg[_nLaco,23]
//			SX1->X1_Def05     := aPerg[_nLaco,24]
//			SX1->X1_Cnt05     := aPerg[_nLaco,25]
//			SX1->X1_F3        := aPerg[_nLaco,26]
//			MsUnLock()
//		EndIf
//	Next
//	RestArea( aArea )
//Return

Static Function ListaModulos(cModulo)

	IF cModulo = '01'
		cNome := 'Ativo Fixo'
	ElseIF cModulo = '02'
		cNome := 'Compras'
	ElseIF cModulo = '04'
		cNome := 'Estoque e Custos'
	ElseIF cModulo = '05'
		cNome := 'Faturamento'
	ElseIF cModulo = '06'
		cNome := 'Financeiro'
	ElseIF cModulo = '07'
		cNome := 'Gestão de Pessoal'
	ElseIF cModulo = '09'
		cNome := 'Livros Fiscais'
	ElseIF cModulo = '10'
		cNome := 'Planejamento e Controle da Produção'
	ElseIF cModulo = '11'
		cNome := 'Veículos'
	ElseIF cModulo = '12'
		cNome := 'Controle de Lojas'
	ElseIF cModulo = '13'
		cNome := 'Call Center'
	ElseIF cModulo = '14'
		cNome := 'Oficina'
	ElseIF cModulo = '16'
		cNome := 'Ponto Eletrônico'
	ElseIF cModulo = '17'
		cNome := 'Easy Import Control'
	ElseIF cModulo = '18'
		cNome := 'Terminal de Consulta do Funcionário'
	ElseIF cModulo = '19'
		cNome := 'Manutenção de Ativos'
	ElseIF cModulo = '20'
		cNome := 'Recrutamento e Seleção de Pessoal'
	ElseIF cModulo = '21'
		cNome := 'Ispeção de Entradas'
	ElseIF cModulo = '22'
		cNome := 'Metrologia'
	ElseIF cModulo = '23'
		cNome := 'Front Loja'
	ElseIF cModulo = '24'
		cNome := 'Controle de Documentos'
	ElseIF cModulo = '25'
		cNome := 'Inspeção de Processos'
	ElseIF cModulo = '26'
		cNome := 'Treinamento'
	ElseIF cModulo = '28'
		cNome := 'Gestão de Serviços'
	ElseIF cModulo = '29'
		cNome := 'Easy Export Control'
	ElseIF cModulo = '30'
		cNome := 'Easy Financing'
	ElseIF cModulo = '31'
		cNome := 'Easy Accounting'
	ElseIF cModulo = '33'
		cNome := 'Plano de Saúde'
	ElseIF cModulo = '34'
		cNome := 'Contabilidade Gerencial'
	ElseIF cModulo = '35'
		cNome := 'Medicina e Segurança do Trabalho'
	ElseIF cModulo = '36'
		cNome := 'Controle de Não-Conformidades'
	ElseIF cModulo = '37'
		cNome := 'Controle de Auditoria'
	ElseIF cModulo = '39'
		cNome := 'OMS - Gestão de Distribuição'
	ElseIF cModulo = '40'
		cNome := 'Cargos e Salários'
	ElseIF cModulo = '41'
		cNome := 'Auto Peças'
	ElseIF cModulo = '42'
		cNome := 'WMS - Gestão de Armazenagem'
	ElseIF cModulo = '43'
		cNome := 'TMS - Gestão de Transporte'
	ElseIF cModulo = '44'
		cNome := 'Gestão de Projetos'
	ElseIF cModulo = '45'
		cNome := 'Controle de Direitos Autorais'
	ElseIF cModulo = '47'
		cNome := 'PPAP'
	ElseIF cModulo = '48'
		cNome := 'Réplica'
	ElseIF cModulo = '50'
		cNome := 'Easy Drawback Control'
	ElseIF cModulo = '51'
		cNome := 'Gestão Hospitalar'
	ElseIF cModulo = '53'
		cNome := 'Avaliação e Pesquisa de Desempenho'
	ElseIF cModulo = '55'
		cNome := 'Sistema de Fidelização e Análise de Crédito'
	ElseIF cModulo = '56'
		cNome := 'Gestão Ambiental'
	ElseIF cModulo = '57'
		cNome := 'Planejamento e Controle Orçamentário'
	ElseIF cModulo = '58'
		cNome := 'Gerenciamento de Pesquisa e Resultado'
	ElseIF cModulo = '64'
		cNome := 'Processos Trabalhistas'
	ElseIF cModulo = '66'
		cNome := 'Gestão de Riscos'
	ElseIF cModulo = '67'
		cNome := 'Gestão Agroindústria'
	ElseIF cModulo = '69'
		cNome := 'Gestão de Contratos'
	ElseIF cModulo = '70'
		cNome := 'Arquitetura Organizacional'
	ElseIF cModulo = '73'
		cNome := 'CRM'
	ElseIF cModulo = '76'
		cNome := 'Gestão Jurídica'
	ElseIF cModulo = '77'
		cNome := 'Pré Faturamento de Serviço'
	ElseIF cModulo = '78'
		cNome := 'Gestão de Frete Embarcador'
	ElseIF cModulo = '79'
		cNome := 'Chão de Fábrica'
	ElseIF cModulo = '80'
		cNome := 'Acessibilidade Visual'
	ElseIF cModulo = '81'
		cNome := 'Monitoramento de Desempenho Logístico'
	ElseIF cModulo = '84'
		cNome := 'TOTVS Automação Fiscal'
	ElseIF cModulo = '85'
		cNome := 'Easy Siscoserv'
	ElseIF cModulo = '90'
		cNome := 'Gestão Comercial do Varejo'
	ElseIf cModulo = '99'
		cNome := 'Configurador'
	Else
		cNome := 'Especifico'
	EndIF

Return (cNome)
