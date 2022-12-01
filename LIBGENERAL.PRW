#Include "Protheus.ch"
#Include "TBICONN.CH"

//------------------------------------------------------------------------------------------
//  ARQUIVO FONTE PARA REUNIR ROTINAS DE USO GERAL.
//------------------------------------------------------------------------------------------
User Function LibGeneral() ; Return("Fonte com rotinas e classes de uso Geral.")
USer Function JobControl() ; Return( "Utilize a classe JobControl")

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} JobControl
@type			: Class
@Sample			: JobControl():New()
@description	: Esta classe tem como objetivo aplicar o controle de semáforo nas rotinas executadas via "JOB" "LockByName" / "UnLockByName"
e também responsavel pela gravação do flag de execução.

@Param			:
@return			: Object 
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: Jan/2021
@version		: Protheus 12
/*/
//------------------------------------------------------------------------------------------
Class JobControl From  LongNameClass

Data cClassName         As String
Data cIdJob             As String 
Data cUserExec          As String 
Data cTabSX5            As String
Data cRotina            As String
Data cMessage           As String 

Data nRecnoAtu          As Numeric 

Data lEmpresa           As Boolean 
Data lFilial            As Boolean 
Data lSetLock           As Boolean
Data lSetFlag           As Boolean 
Data lGrvAutoId         As Boolean

Data aSchedules         As Array 

Method New() Constructor                // Metodo construtor da classe - Inicializa as propriedades
Method Check()                          // Checa/valida propriedades para gravação do flag
Method GetJobs()                        // Retorna todos os jobs cadastrados no configurador
Method SetLock()                        // Informa se haverá lock de execução "Semaforo"
Method SetFlag()                        // Informa se haverá registro de log de execução ( via SX5)
Method Activate()                       // Da o start de execução p/ JOB informado via parametro
Method GetStatus()                      // Retorna mensagem de status de classe 
Method InsertSX5()                      // Grava IDJOb no SX5 para permitir o flag de execucao
Method UpdateFlag()                     // Atualiza SX5 com o flag de inicio e fim da execução
Method GetFunction()                    // Metdo auxiliar independete do processo - retorna nome da rotina para o IDJOB informado
Method GetTotExecDay()                  // Metodo auxiliar independete do processo - retorna qtdade de execuções de JOB IdJob informado
Method ShowFlsgSx5()                    // Exibe Browse com os todos Jobs que deverão ter sua execução monitorada.
EndClass

// -------------------------------------------------------------
// Metodo construtor da classe -  Inicializa as propriedades
// -------------------------------------------------------------
Method New(cIdJob) Class JobControl

	Default cIdJob      := ""


	::cClassName        := "JobControl"
	::cIdJob            := cIdJob
	::lEmpresa          := Nil
	::lFilial           := Nil 
	::lSetFlag          := Nil 
	::cTabSX5           := ""
	::cMessage          := ""
	::cRotina           := ""
	::nRecnoAtu         := 0
	::aSchedules        := ::GetJobs()
	::cUserExec         := AllTrim(PadR(IIF(Empty(cUserName),"JOB", cUserName ),15))
	::cTabSX5           := SuperGetMv("ES_SX5JOB",,"ZW")
	::lGrvAutoId        := SuperGetMv("ES_SX5INC",, .T.)

Return( Self )

// -------------------------------------------------------------
// Checa se o IDJob informado consta cadastrado no CFG e valida tabela SX5
// -------------------------------------------------------------
Method Check() Class JobControl

	Local aArea     := GetArea()
	Local nPos      := 0
	Local lExist    := .F. 
	Local aSX5
	//	DbSelectArea("SX5") // Tabela Generica
	//	DbSetOrder(1) 		// X5_TABELA + X5_CHAVE

	aSX5 := FWGetSX5(::cTabSX5)

	//	lExist :=  SX5->( DbSeek(xFilial("SX5") + ::cTabSX5 ) )
	if aSX5[1][2] == ::cTabSX5

		lExist:= .t.

	endif


	If ( lExist )

		nPos    := aScan( ::aSchedules, {  |x| x[1] == ::cIdJob } ) 
		lExist  := nPos > 0

		If ( lExist )

			::cRotina   := ::aSchedules[nPos][3]
			::cRotina   := SubStr( ::cRotina,1, At("(",::cRotina) - 1 ) 

			//			lExist :=  SX5->( DbSeek(xFilial("SX5") + ::cTabSX5 + ::cIdJob ) ) 

			aSX5 := FWGetSX5(::cTabSX5 , ::cIdJob)

			if aSX5[1][2] == ::cTabSX5 .and.  aSX5[1][3] ==  aSX5[1][2] 

				lExist:= .t.

			else

				lExist:= .t.

			endif


			If ( !lExist .And. ::lGrvAutoId) 

				lExist := ::InsertSX5( ::cTabSX5, ::cIdJob, ::cRotina )

			EndIf 

			::nRecnoAtu := SX5->( Recno() )

		Else 
			::cMessage := "Method Check - Job ID:  " +  ::cIdJob + " nao foi localizado no configurador. Flag de execucao nao sera gravado."
		EndIf 

	Else 

		::cMessage := "Method Check - A tabela " +  ::cTabSX5 + " nao foi cadastrada na tabela generica do SX5. Flag de execucao nao sera gravad"

	EndIf 

	RestArea(aArea)

Return(  lExist )

// -------------------------------------------------------------
// Retorna todos os jobs cadastrados no agendamento do SIGACFG 
// -------------------------------------------------------------
METHOD GetJobs() Class JobControl

	Local aArea     := {}
	Local aJobs     := {}


	If !(ExistFunc("FwOpenXX1"))
		DbSelectArea("XX1")
	Else
		FwOpenXX1()
	EndIf

	If !(ExistFunc("FwOpenXX2"))
		DbSelectArea("XX2")
	Else
		FwOpenXX2()
	EndIf

	cTmp    := GetNextAlias()

	cQuery := " SELECT XX1_CODIGO AS XX1CODIGO, XX1_USERID AS XX1USERID, XX1_ROTINA As XX1ROTINA, XX1_DATA AS XX1DATA, XX1_HORA AS XX1HORA,"
	cQuery += " XX1_RECORR AS XX1RECORR, XX1_RECORR AS XX1RECORR, XX1_ENV AS XX1ENV, XX1_PARAM AS XX1PARAM, XX1_MODULO AS XX1MODULO, XX1_ULTDIA AS XX1ULTDIA,XX1_ULTHOR AS XX1ULTHOR, XX1_STATUS AS XX1STATUS "
	cQuery += " FROM "+RetSQLName("XX1") + " XX1  "
	cQuery += " WHERE  D_E_L_E_T_= ' ' " 

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cTmp)
	While cTmp->(!EOF())
		aAdd( aJobs,{   AllTrim( cTmp->XX1CODIGO)     ,;	
		AllTrim( cTmp->XX1USERID)     ,;	
		AllTrim( cTmp->XX1ROTINA)     ,;	
		AllTrim( cTmp->XX1DATA)       ,;
		AllTrim( cTmp->XX1HORA)       ,;
		AllTrim( cTmp->XX1RECORR)     ,;	
		AllTrim( cTmp->XX1ENV)        ,;
		AllTrim( cTmp->XX1PARAM )     ,;	
		AllTrim( cTmp->XX1MODULO)     ,; 
		AllTrim( cTmp->XX1ULTDIA)     ,;	
		AllTrim( cTmp->XX1ULTHOR)     ,;	
		AllTrim( cTmp->XX1STATUS)     })       



		       cTmp->(dbSkip())
	End
	cTmp->(DbCloseArea())








	//aArea := {XX1->(GetArea()), XX2->(GetArea()), GetArea()}
	//
	//XX1->(DbSetOrder(1))
	//XX2->(DbSetOrder(1))
	//XX1->(DbGoTop())
	//
	//While XX1->(!EOF())
	//    
	//    aAdd( aJobs,{   AllTrim( XX1->XX1_CODIGO)     ,;	
	//                    AllTrim( XX1->XX1_USERID)     ,;	
	//                    AllTrim( XX1->XX1_ROTINA)     ,;	
	//                    AllTrim( XX1->XX1_DATA)       ,;
	//                    AllTrim( XX1->XX1_HORA)       ,;
	//                    AllTrim( XX1->XX1_RECORR)     ,;	
	//                    AllTrim( XX1->XX1_ENV)        ,;
	//                    AllTrim( XX1->XX1_PARAM )     ,;	
	//                    AllTrim( XX1->XX1_MODULO)     ,; 
	//                    AllTrim( XX1->XX1_ULTDIA)     ,;	
	//                    AllTrim( XX1->XX1_ULTHOR)     ,;	
	//                    AllTrim( XX1->XX1_STATUS)     })
	//        
	//    XX1->( DbSkip())
	//EndDo

	//AEval(aArea, {|aArea| RestArea(aArea), FwFreeArray(aArea)})

Return( aJobs )


// ---------------------------------------------------------
//
// ---------------------------------------------------------
Method SetLock( lEmpresa, lFilial, cIdJob ) Class JobControl

	Default cIdJob := ""

	::lSetLock := ( lEmpresa <> Nil .And. lFilial <> Nil )

	If ( ::lSetLock )

		//-- Substitui Name do semaforo padrão
		If !Empty( cIdJob ) ; ::cIdJob  := cIdJob ; EndIf 

		::lEmpresa  := lEmpresa
		::lFilial   := lFilial

	Else 
		::cMessage := "Method SetLock - Parametros de lock nao informado."
	EndIf 

Return( ::lSetLock )

// ---------------------------------------------------------
//
// ---------------------------------------------------------
Method SetFlag( lLocked ) Class JobControl

	::lSetFlag := lLocked 

	If ( ::lSetFlag )

		::lSetFlag := ::Check()

	EndIf 

Return( ::lSetFlag )


Method Activate( bRotina ) Class JobControl 

	Local lLock     := .F. 
	Local lUnLock   := .F.

	Local lRet  := .F.


	// ---------------------------------------------------------
	// Registra o flag de execucao da rotina
	// ---------------------------------------------------------
	::UpdateFlag( .T. /* Inicio  */ )


	// ---------------------------------------------------------
	// Registra o flag de execucao da rotina 
	// ---------------------------------------------------------
	If ( ::lSetLock )

		// -----------------------------------------------------
		// Solicita o lock da rotina - Bloqueia Execução
		// -----------------------------------------------------
		lLock := LockByName(::cIdJob, ::lEmpresa, ::lFilial)

		If ( lLock  )


			// -----------------------------------------------------
			// EFETIVA EXECUÇÃO DA ROTINA

			lRet := Eval( bRotina  )


			// -----------------------------------------------------
			// Solicita o Unlock da rotina - Libera rotina p/ proxima Exec. 
			// -----------------------------------------------------
			lUnLock := UnLockByName(::cIdJob, ::lEmpresa, ::lFilial )
		Else 
			::cMessage := "Method Activate - Nao foi possivel efetuar o lock da rotina pois a mesma se encontra em execucao. Aguarde..."
		EndIf 


	Else 

		// -----------------------------------------------------
		// EFETIVA EXECUÇÃO DA ROTINA
		lRet := Eval( bRotina  )

	EndIf 

	// ---------------------------------------------------------
	// Registra o flag de encerramento da rotina
	// ---------------------------------------------------------
	::UpdateFlag( .F. /* Fim  */ )


Return( lRet )

// -------------------------------------------------------------
// Recupera mensagem de status da validação check
// -------------------------------------------------------------
Method GetStatus() Class JobControl
Return( ::cMessage )


// -------------------------------------------------------------
// Faz a inclusão de um novo registro na tabela de Flag de Exeucao de rotinas
// -------------------------------------------------------------
Method InsertSX5( cTabSx5, cIdJob, cRotina ) Class JobControl

	//DbSelectArea("SX5")
	//RecLock("SX5",.T.)
	//
	//SX5->X5_FILIAL 	:= xFilial("SX5")
	//SX5->X5_TABELA 	:= cTabSX5
	//SX5->X5_CHAVE  	:= cIdJob
	//SX5->X5_DESCRI 	:= cRotina
	//SX5->X5_DESCSPA := ""
	//SX5->X5_DESCENG := "" 
	//SX5->(MsUnLock())
	//SX5 - Uso DESCONTINUADO de leituraatribuição do metadados. Deve ser enserido somente pelo configurador
Return( .T. )

// -------------------------------------------------------------
// Atualiza tabela SX5 com status de execução da rotina
// -------------------------------------------------------------
Method UpdateFlag( lLocked ) Class JobControl

	Local aArea         := GetArea()
	Local lInRunning    := .F.


	If ( ::lSetFlag )

		//    DbSelectArea("SX5")
		//
		//    SX5->(  DbGoTo( ::nRecnoAtu  ) )


		If  ( lLocked )

			//Inclusão da Sx5 somente pelo configurador
			//        RecLock("SX5",.F.)
			//        SX5->X5_DESCSPA := ::cMessage :=  "INRUNNING " + ::cUserExec +"  Iniciado em: " + DtoC(Date())+"-"+SubStr(Time(),1,5)
			//        SX5->(MsUnLock())

		Else   

			lInRunning := Alltrim(Left(SX5->X5_DESCSPA,10)) == "INRUNNING"

			If ( lInRunning )
				//Inclusão da Sx5 somente pelo configurador
				//				RecLock("SX5",.F.)
				//				SX5->X5_DESCSPA	:= ::cMessage :=  "Ultima Exec: " + DtoC(Date())+"-"+SubStr(Time(),1,5)
				//				SX5->(MsUnLock())

			EndIf 

		EndIf 


		RestArea( aArea )

	EndIf 

Return()

// -------------------------------------------------------------
// Recupera a rotina com base no ID JOB Informado
// -------------------------------------------------------------
Method GetFunction( cIdJob ) Class JobControl

	Local nPos := 0 
	Local cRet := ""

	Default cIdJob := ""

	If !Empty(cIdJob)

		nPos    := aScan( ::aSchedules, {  |x| x[1] == cIdJob } ) 

		If ( nPos > 0 )
			cRet := ::aSchedules[nPos][3]
			cRet := SubStr( cRet,1, At("(",cRet) - 1 ) 
		EndIf 

	Else 
		cRet := ::cRotina
	EndIf 

Return( cRet )


// -------------------------------------------------------------
// 
// -------------------------------------------------------------
Method GetTotExecDay( dDate, cStatus, cIdJob ) Class JobControl

	Local cAliasQry := ""
	Local cQuery    := ""
	Local nQtdExec  := 0

	Default dDate   := CTOD("")
	Default cStatus := ""
	Default cIdJob  := ::cIdJob

	If ( TCCanOpen( "SCHDTSK" ) )

		cAliasQry		:= GetNextAlias() 

		//-------------------------------------------------------------------
		// Monta a query para recuperar a hora de execução do agendamento. 
		//-------------------------------------------------------------------			
		cQuery := " SELECT COUNT(*) As TOTEXEC" 
		cQuery += " FROM SCHDTSK"
		cQuery += " WHERE "
		cQuery += "		TSK_CODIGO  = '" + SubStr( cIdJob, 1, 6 ) + "'" 

		If ( !Empty(dDate) )
			cQuery += "	AND	TSK_DIA     = '" + DTOS(dDate) + "'"             
		EndIf 

		If ( !Empty(cStatus))
			cQuery += "	AND	TSK_STATUS  = '" + cStatus + "'" 
		EndIf 

		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .F.)

		//-------------------------------------------------------------------
		// Recupera a qtdade de execução da tarefa Job. 
		//-------------------------------------------------------------------		
		nQtdExec :=   (cAliasQry)->TOTEXEC  


		(cAliasQry)->( DBCloseArea() )
	EndIf 


Return( nQtdExec )

Method ShowFlsgSx5() Class JobControl

	If !IsBlind()
		U_FCFGA001( .T./*lButtonView*/ )
	EndIf

Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
EXEMPLO DE UTILIZAÇÃO DA CLASSE JOBCONTROL
/*/
//------------------------------------------------------------------------------------------
User Function TestJob(aParam)

	Local oControl	:= Nil
	Local cEmpJob 	:= Iif(aParam = NIL, "01", aParam[1])	
	Local cFilJob 	:= Iif(aParam = NIL, "08", aParam[2])
	Local bJob      := {||ConOut("Executando... ") }

	Default aParam := {}

	// -------------------------------------------------------------------
	// EXECUTA VIA JOB
	// --------------------------------------------------------------------
	If aParam <> NIL 

		If ( Select("SM0") == 0 )

			PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob FUNNAME "U_TestJob" 

			oControl	:= JobControl():New("000038" )

			oControl:SetLock( lEmpresa, lFilial  )
			oControl:SetFlag( lActive )
			oControl:Activate( bJob )
			oControl:GetStatus()


			oControl := Nil 
			FreeObj(oControl)


			RESET ENVIRONMENT 

		EndIf 

	EndIf	

Return()
