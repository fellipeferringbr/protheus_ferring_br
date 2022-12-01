#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

user function MA261EXC()
	Local aArea := GetArea()
	Local aAreaSD3 := SD3->(GetArea())
	Local cQuery := ""
	Local cFileName := ""
	Local oEmail
	Local oTexto
	Local cDestEML := ""
	Local cTexto := ""
	Local lTemArq := .F.
	
	Private _cDescOper := ""
	
	If GETMV("MV_XUSAAGV")
/*		//Identifica o movimento que está entrando no estoque. Iniciado por RE.
		cQuery := " SELECT "
		cQuery += "   R_E_C_N_O_ D3_RECNO "
		cQuery += " FROM "
		cQuery += "   "+ SD3->(RetSQLName("SD3"))
		cQuery += " WHERE "
		cQuery += "   D3_FILIAL = '"+ SD3->(xFILIAL("SD3")) +"' AND D3_COD = '"+ SD3->D3_COD +"' "
		cQuery += "   AND D3_DOC = '"+ SD3->D3_DOC +"' AND D3_NUMSEQ = '"+ SD3->D3_NUMSEQ +"' "
		cQuery += "   AND LEFT(D3_CF,2) = 'DE' AND D3_XDENVOL = ' ' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		TcQuery cQuery Alias TSD3A New
		TSD3A->(dbGoTop())
		While !TSD3A->(EOF())
			SD3->(dbGoTo(TSD3A->D3_RECNO))
			
			If Alltrim(SD3->D3_LOCAL) $ GETMV("MV_XALMVEN") .OR. Alltrim(SD3->D3_LOCAL) $ GETMV("MV_XALMREJ") .OR. Alltrim(SD3->D3_LOCAL) $ GETMV("MV_XALMANL")
				lTemArq := .T.
				cFileName := "BL"+ SUBSTR(DTOS(dDataBase),7,4) + SUBSTR(DTOS(dDataBase),5,2) + "_" + STRTRAN(TIME(),":") +".TXT"
	
				oTexto := EPARQTXT():NEW( Alltrim(GETMV("MV_XOUTAGV"))+ cFileName )
				oTexto:CRIARTXT()
	
				//Rejeitados
				If Alltrim(SD3->D3_LOCAL) $ GETMV("MV_XALMVEN")
					oTexto:INCLINHA( 	PADR( SD3->D3_COD , 15) +;
					                    PADR( SD3->D3_LOTECTL , 20 ) +;
					                    "L" +;
					                	SPACE(11)  +;
										SPACE(5) )
									
					cTexto += "O lote "+ SD3->D3_LOTECTL +" do produto "+ Alltrim(SD3->D3_COD) +" foi Lote Liberado em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName			
				
					// Cria registro no monitor de integração.
			   		u_FEGrvZZD(cFileName,, "L" , "" ,"", .F.,"SD3", SD3->D3_COD , SD3->D3_LOTECTL )				
				Elseif Alltrim(SD3->D3_LOCAL) $ GETMV("MV_XALMREJ")
					oTexto:INCLINHA( 	PADR( SD3->D3_COD , 15) +;
					                    PADR( SD3->D3_LOTECTL , 20 ) +;
					                    "R" +;
					                	SPACE(11)  +;
										SPACE(5) )
									
					cTexto += "O lote "+ SD3->D3_LOTECTL +" do produto "+ Alltrim(SD3->D3_COD) +" foi Lote Rejeitado em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName

					// Cria registro no monitor de integração.
			   		u_FEGrvZZD(cFileName,, "R" , "" ,"", .F.,"SD3", SD3->D3_COD , SD3->D3_LOTECTL )
				Elseif Alltrim(SD3->D3_LOCAL) $ GETMV("MV_XALMANL")
					oTexto:INCLINHA( 	PADR( SD3->D3_COD , 15) +;
					                    PADR( SD3->D3_LOTECTL , 20 ) +;
					                    "Y" +;
					                	SPACE(11)  +;
										SPACE(5) )
									
					cTexto += "O lote "+ SD3->D3_LOTECTL +" do produto "+ Alltrim(SD3->D3_COD) +" foi Lote Em analise (Retorno a origem) em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName

					// Cria registro no monitor de integração.
			   		u_FEGrvZZD(cFileName,, "Y" , "" ,"", .F.,"SD3", SD3->D3_COD , SD3->D3_LOTECTL )
				Endif	
				oTexto:FECHATXT()
		
				//Atualiza status do registro
				SD3->(Reclock("SD3",.F.))
				SD3->D3_XDENVOL := dDataBase
				SD3->D3_XHENVOL := Time()
				SD3->D3_XAENVOL := cFileName
				SD3->(MsUnlock())
			Endif
			
			TSD3A->(dbSkip())
		Enddo
		TSD3A->(dbCloseArea())
	
		If lTemArq
			//Envia arquivo para o FTP do Operador Logístico
			If U_FESTA006( "D3Q" , "BL*.TXT" , "MA261EXC" , "Interface Status Lotes" )
				// Envia e-mail de notificação
				cDestEML := U_RETMAILTO("D3Q")	
			
				oEmail := CONEMAIL():NEW( GETMV("MV_RELSERV") , GETMV("MV_RELACNT") , GETMV("MV_RELPSW") )
				If oEmail:CONECTAR()
				    oEmail:ENVIAR( GETMV("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
				    oEmail:DESCONEC()
				Endif
			Endif
		Endif */
	Endif
	
	RestArea(aAreaSD3)
	RestArea(aArea)	
return