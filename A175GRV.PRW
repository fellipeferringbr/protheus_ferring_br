#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "DBINFO.ch"
#INCLUDE "Tbiconn.ch"
#INCLUDE "RWMAKE.CH"
#DEFINE CRLF CHR(13)+CHR(10)

User Function A175GRV()
	Local aArea 		:= GetArea()
	Local aAreaSD7 	:= SD7->(GetArea())
	Local aAreaSB8 	:= SBF->(GetArea())
	Local _aCab 	:= {}
	Local _aItens 	:= {}
	Local cNumSD7	:= SD7->D7_NUMERO
	Local cProdSD7	:= SD7->D7_PRODUTO
	Local cAliasTrb	:= GetNextAlias()
	Local cQuery	:= ""
	Local nX		:= 0
	Local nPosTipo	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D7_TIPO"})
	Local nPosEst	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D7_ESTORNO"})
	
	Local lEntrou	:= .F.
	Local lUsaLuft	:= GetPar("ES_INTOPLO")		 // Se usa armazem Luft
	
	//Variáveis do projeto de inclusão da AGV
	Local cFileName := ""
	Local oEmail
	Local oTexto
	Local cDestEML := ""
	Local cTexto := ""
	
	Private _cDescOper := ""
	//Fim - Variáveis do projeto de inclusão da AGV
	
	Private _cLAmostra := FORMATIN(GetPar("ES_LAMOSTR"),"|")
	Private _cLRejeica := GetPar("ES_LREJEIC")
	Private _cLCQ      := GetPar("MV_CQ")  
	//Private nPosIdSD7  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_NUMSEQ"})  
	Private nPosSeq	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D7_SEQ"})
	Private _cNSeqSD7 := ""         
	
	
	/*BEGINDOC
	//³Alimentar data de fabricação³
	ENDDOC*/
	
	//query de update data de fabricação para lotes gravados no SB8 sem data de fabricação
	tcsqlexec("UPDATE SB8010 SET B8_DTFABR = (SELECT MAX(SB82.B8_DTFABR) FROM SB8010 SB82 WHERE SB82.D_E_L_E_T_=SB8010.D_E_L_E_T_ AND SB82.B8_PRODUTO=SB8010.B8_PRODUTO AND SB82.B8_LOTECTL=SB8010.B8_LOTECTL AND SB82.B8_DTVALID=SB8010.B8_DTVALID AND SB82.B8_FILIAL=SB8010.B8_FILIAL) WHERE SB8010.D_E_L_E_T_=' ' AND SB8010.B8_DTFABR=' '")
	
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
	//³Projeto CQ - Integração com LUFT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
	ENDDOC*/
	
	//Condição inclusa para a inclusão da AGV como operador logístico.
	If GetPar("MV_XUSAAGV")
	
//////////////////////////////////////////////
		For nX := 1 TO Len(aCols)				
			// Liberacao de CQ
			IF aCols[nX][nPosTipo] == 1 .AND. aCols[nX][nPosEst] == ' '
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona registros referente a LIBERACAO DE CQ ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := " SELECT "
				cQuery += "   R_E_C_N_O_ AS REC "
				cQuery += " FROM "
				cQuery += "   "+ RetSqlName("SD7") +" "
				cQuery += " WHERE "
				cQuery += "   D7_FILIAL = '"+xFilial("SD7")+"' "
				cQuery += "   AND D7_TIPO = '1' AND D7_ESTORNO <> 'S' AND D7_SEQ = '"+aCols[nX][nPosSeq]+"' "
				// Sobre se for liberação d amostra
				cQuery += "   AND D7_LOCDEST NOT IN "+ FORMATIN(GetPar("MV_XALMAMO"),"/") +" "
				cQuery += "   AND D7_XDENVOL = ' ' "
				cQuery += "   AND D7_NUMERO = '"+ SD7->D7_NUMERO +"' AND D7_PRODUTO = '"+ SD7->D7_PRODUTO +"' "
				cQuery += "   AND D_E_L_E_T_ = ' ' "			
				TcQuery cQuery New Alias TSD7 New
				TSD7->(dbGoTop())
				While !TSD7->(EOF()) 
					If TSD7->REC > 0
						SD7->(dbGoTo(TSD7->REC))
						
						cFileName := "BL"+ SUBSTR(DTOS(dDataBase),7,4) + SUBSTR(DTOS(dDataBase),5,2) + "_" + STRTRAN(TIME(),":") +".TXT"
	
						oTexto := EPARQTXT():NEW( Alltrim(GetPar("MV_XOUTAGV"))+ cFileName )
						oTexto:CRIARTXT()
						oTexto:INCLINHA( 	PADR( SD7->D7_PRODUTO , 15) +;
						                    PADR( SD7->D7_LOTECTL , 20 ) +;
						                    "L" +;
						                	SPACE(11)  +;
											SPACE(5) )
								
						cTexto := "O lote "+ SD7->D7_LOTECTL +", quantidade "+ Alltrim(STR(SD7->D7_QTDE)) +", do produto "+ Alltrim(SD7->D7_PRODUTO) +" foi Liberado em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName	
						oTexto:FECHATXT()
						
				   		// Cria registro no monitor de integração.
						u_FEGrvZZD(cFileName,, "L" , "" ,"", .F.,"SD7", SD7->D7_PRODUTO , SD7->D7_LOTECTL )
		
						//Atualiza status do registro
						SD7->(Reclock("SD7",.F.))
						SD7->D7_XDENVOL := dDataBase
						SD7->D7_XHENVOL := Time()
						SD7->D7_XAENVOL := cFileName
						SD7->(MsUnlock())
					
						//Envia arquivo para o FTP do Operador Logístico
						If U_FESTA006( "D3Q" , "BL*.TXT" , "MPROCSDD" , "Interface Status Lotes" )
							// Envia e-mail de notificação
							cDestEML := U_RETMAILTO("D3Q")	
						
							oEmail := CONEMAIL():NEW( GetPar("MV_RELSERV") , GetPar("MV_RELACNT") , GetPar("MV_RELPSW") )
							If oEmail:CONECTAR()
							    oEmail:ENVIAR( GetPar("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
							    oEmail:DESCONEC()
							Endif
						Endif
					Endif
				
					TSD7->(dbSkip())
				Enddo
				TSD7->(dbCloseArea())
			Endif
			
			// Estorno de CQ SAINDO DO ALMOXARIFADO 01 PARA QUALQUER OUTROS
			IF aCols[nX][nPosTipo] == 1 .AND. aCols[nX][nPosEst] == 'X'  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona registros referentes a ESTORNO DA LIBERACAO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*				cQuery := " SELECT "
				cQuery += "   MAX(R_E_C_N_O_) as REC "
				cQuery += " FROM "
				cQuery += "   "+ RetSqlName("SD7") +" "
				cQuery += " WHERE "
				cQuery += "   D7_FILIAL = '"+xFilial("SD7")+"' "
				cQuery += "   AND D7_TIPO = '6' AND D7_ESTORNO = 'S'  "
				cQuery += "   AND D7_LOCDEST IN "+ FORMATIN(GetPar("MV_CQ"),"/") +" "
			   	//cQuery += "   AND D7_XDENVOL <> ' ' "
				cQuery += "   AND D7_NUMERO = '"+ SD7->D7_NUMERO +"' AND D7_PRODUTO = '"+ SD7->D7_PRODUTO +"' "
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcQuery cQuery New Alias TSD7 New
				TSD7->(dbGoTop())
				While !TSD7->(EOF()) 
					If TSD7->REC > 0
						SD7->(dbGoTo(TSD7->REC)) */
					
					If aCols[ nX , GDFieldPos("D7_REC_WT") ] > 0
						SD7->(dbGoTo( aCols[ nX , GDFieldPos("D7_REC_WT") ] ))
					
						cFileName := "BL"+ SUBSTR(DTOS(dDataBase),7,4) + SUBSTR(DTOS(dDataBase),5,2) + "_" + STRTRAN(TIME(),":") +".TXT"
	
						oTexto := EPARQTXT():NEW( Alltrim(GetPar("MV_XOUTAGV"))+ cFileName )
						oTexto:CRIARTXT()
						oTexto:INCLINHA( 	PADR( SD7->D7_PRODUTO , 15) +;
						                    PADR( SD7->D7_LOTECTL , 20 ) +;
						                    "Q" +;
						                	SPACE(11)  +;
											SPACE(5) )
								
						cTexto := "O lote "+ SD7->D7_LOTECTL +", quantidade "+ Alltrim(STR(SD7->D7_QTDE)) +", do produto "+ Alltrim(SD7->D7_PRODUTO) +" foi Quarentenado em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName	
						oTexto:FECHATXT()
						
						// Cria registro no monitor de integração.
						u_FEGrvZZD(cFileName,, "B" , "" ,"", .F.,"SD7", SD7->D7_PRODUTO , SD7->D7_LOTECTL )
		
						//Atualiza status do registro 						
						SD7->(Reclock("SD7",.F.))
						SD7->D7_XDENVOL := dDataBase
						SD7->D7_XHENVOL := Time()
						SD7->D7_XAENVOL := cFileName
						SD7->(MsUnlock())
					
						//Envia arquivo para o FTP do Operador Logístico
						If U_FESTA006( "D3Q" , "BL*.TXT" , "MPROCSDD" , "Interface Status Lotes" )
							// Envia e-mail de notificação
							cDestEML := U_RETMAILTO("D3Q")	
						
							oEmail := CONEMAIL():NEW( GetPar("MV_RELSERV") , GetPar("MV_RELACNT") , GetPar("MV_RELPSW") )
							If oEmail:CONECTAR()
							    oEmail:ENVIAR( GetPar("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
							    oEmail:DESCONEC()
							Endif
						Endif
					Endif
					
					//TSD7->(dbSkip())
				//Enddo
				//TSD7->(dbCloseArea())
			Endif
			
			// Rejeicao de CQ
			IF aCols[nX][nPosTipo] == 2 .AND. aCols[nX][nPosEst] == ' '        
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona registros REJEICAO DE CQ ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := " SELECT "
				cQuery += "   R_E_C_N_O_ AS REC "
				cQuery += " FROM "
				cQuery += "   "+ RetSqlName("SD7") +" "
				cQuery += " WHERE "
				cQuery += "   D7_FILIAL = '"+xFilial("SD7")+"' "
				cQuery += "   AND D7_TIPO = '2' AND D7_ESTORNO <> 'S' AND D7_SEQ = '"+ aCols[nX][nPosSeq] +"' "
				// Sobre se for liberação d amostra
			    //	cQuery += " AND D7_LOCDEST = '" +_cLRejeica+"' "
			  	cQuery += "   AND D7_XSTENV = ' ' "
				cQuery += "   AND D7_NUMERO = '"+ SD7->D7_NUMERO +"' AND D7_PRODUTO = '"+ SD7->D7_PRODUTO +"' "
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcQuery cQuery New Alias TSD7 New
				TSD7->(dbGoTop())
				While !TSD7->(EOF())
					If TSD7->REC > 0
						SD7->(dbGoTo(TSD7->REC))
						
						//O arquivo de bloqueio para a AGV é gerado somente em caso de rejeição total
					    If SD7->D7_SALDO == 0
							cFileName := "BL"+ SUBSTR(DTOS(dDataBase),7,4) + SUBSTR(DTOS(dDataBase),5,2) + "_" + STRTRAN(TIME(),":") +".TXT"
		
							oTexto := EPARQTXT():NEW( Alltrim(GetPar("MV_XOUTAGV"))+ cFileName )
							oTexto:CRIARTXT()
							oTexto:INCLINHA( 	PADR( SD7->D7_PRODUTO , 15) +;
							                    PADR( SD7->D7_LOTECTL , 20 ) +;
							                    "R" +;
							                	SPACE(11)  +;
												SPACE(5) )
									
							cTexto := "O lote "+ SD7->D7_LOTECTL +", quantidade "+ Alltrim(STR(SD7->D7_QTDE)) +", do produto "+ Alltrim(SD7->D7_PRODUTO) +" foi Rejeitado Total em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName	
							oTexto:FECHATXT()
							
							// Cria registro no monitor de integração.
							u_FEGrvZZD(cFileName,, "B" , "" ,"", .F.,"SD7", SD7->D7_PRODUTO , SD7->D7_LOTECTL )
			
							//Atualiza status do registro
							SD7->(Reclock("SD7",.F.))
							SD7->D7_XDENVOL := dDataBase
							SD7->D7_XHENVOL := Time()
							SD7->D7_XAENVOL := cFileName
							SD7->(MsUnlock())
						
							//Envia arquivo para o FTP do Operador Logístico
							If U_FESTA006( "D3Q" , "BL*.TXT" , "MPROCSDD" , "Interface Status Lotes" )
								// Envia e-mail de notificação
								cDestEML := U_RETMAILTO("D3Q")	
							
								oEmail := CONEMAIL():NEW( GetPar("MV_RELSERV") , GetPar("MV_RELACNT") , GetPar("MV_RELPSW") )
								If oEmail:CONECTAR()
								    oEmail:ENVIAR( GetPar("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
								    oEmail:DESCONEC()
								Endif
							Endif
						Else
							If Empty(SD7->D7_XEMLNOT)
								// Envia somente notificação
								cTexto := "O lote "+ SD7->D7_LOTECTL +", quantidade "+ Alltrim(STR(SD7->D7_QTDE)) +", do produto "+ Alltrim(SD7->D7_PRODUTO) +" foi Rejeitado Parcial em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName	
								
								// Envia e-mail de notificação
								cDestEML := U_RETMAILTO("D3Q")	
								
								oEmail := CONEMAIL():NEW( GetPar("MV_RELSERV") , GetPar("MV_RELACNT") , GetPar("MV_RELPSW") )
								If oEmail:CONECTAR()
								    oEmail:ENVIAR( GetPar("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
								    oEmail:DESCONEC()
								Endif
								
								//Atualiza status do notificação do e-mail de rejeição
								SD7->(Reclock("SD7",.F.))
								SD7->D7_XEMLNOT := dDataBase
								SD7->(MsUnlock())
							Endif
						Endif
					Endif
				
					TSD7->(dbSkip())
				Enddo
				TSD7->(dbCloseArea())
			Endif
			
			// estorno de Rejeicao de CQ
			IF aCols[nX][nPosTipo] == 2 .AND. aCols[nX][nPosEst] == 'X'
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona registros a ESTORNO DA REJEICAO ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*				cQuery := " SELECT "
				cQuery += "   MAX(R_E_C_N_O_) AS REC "
				cQuery += " FROM "
				cQuery += "   "+ RetSqlName("SD7") +" "+CRLF
				cQuery += " WHERE "
				cQuery += "   D7_FILIAL = '"+ xFilial("SD7") +"' "
				cQuery += "   AND D7_TIPO = '7' AND D7_ESTORNO = 'S' 
				//AND D7_SEQ = '"+aCols[nX][nPosSeq]+"' "+CRLF
				// Sobre se for liberação d amostra
			    //	cQuery += " AND D7_LOCDEST = '" +_cLCQ+"' "+CRLF
				//cQuery += "   AND D7_XDENVOL <> ' ' "
				cQuery += "   AND D7_NUMERO = '"+ SD7->D7_NUMERO +"' AND D7_PRODUTO = '"+ SD7->D7_PRODUTO +"' "
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcQuery cQuery New Alias TSD7 New
				TSD7->(dbGoTop())
				While !TSD7->(EOF())
					If TSD7->REC > 0  
						SD7->(dbGoTo(TSD7->REC)) */
					
					If aCols[ nX , GDFieldPos("D7_REC_WT") ] > 0
						SD7->(dbGoTo( aCols[ nX , GDFieldPos("D7_REC_WT") ] ))
						
						//O arquivo para AGV é gerado somente quando a rejeição tiver enviado para a AGV, ou seja, garantindo que foi rejeição total
					    If !Empty(SD7->D7_XAENVOL)
							cFileName := "BL"+ SUBSTR(DTOS(dDataBase),7,4) + SUBSTR(DTOS(dDataBase),5,2) + "_" + STRTRAN(TIME(),":") +".TXT"
		
							oTexto := EPARQTXT():NEW( Alltrim(GetPar("MV_XOUTAGV"))+ cFileName )
							oTexto:CRIARTXT()
							oTexto:INCLINHA( 	PADR( SD7->D7_PRODUTO , 15) +;
							                    PADR( SD7->D7_LOTECTL , 20 ) +;
							                    "Q" +;
							                	SPACE(11)  +;
												SPACE(5) )
									
							cTexto := "O lote "+ SD7->D7_LOTECTL +", quantidade "+ Alltrim(STR(SD7->D7_QTDE)) +", do produto "+ Alltrim(SD7->D7_PRODUTO) +" foi estorno da Rejeição Total em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName	
							oTexto:FECHATXT()
							
							// Cria registro no monitor de integração.
							u_FEGrvZZD(cFileName,, "B" , "" ,"", .F.,"SD7", SD7->D7_PRODUTO , SD7->D7_LOTECTL )
			
							//Atualiza status do registro
							SD7->(Reclock("SD7",.F.))
							SD7->D7_XDENVOL := dDataBase
							SD7->D7_XHENVOL := Time()
							SD7->D7_XAENVOL := cFileName
							SD7->(MsUnlock())
						
							//Envia arquivo para o FTP do Operador Logístico
							If U_FESTA006( "D3Q" , "BL*.TXT" , "MPROCSDD" , "Interface Status Lotes" )
								// Envia e-mail de notificação
								cDestEML := U_RETMAILTO("D3Q")	
							
								oEmail := CONEMAIL():NEW( GetPar("MV_RELSERV") , GetPar("MV_RELACNT") , GetPar("MV_RELPSW") )
								If oEmail:CONECTAR()
								    oEmail:ENVIAR( GetPar("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
								    oEmail:DESCONEC()
								Endif
							Endif
						Else
							//If Empty(SD7->D7_XEMLNOT)
								// Envia somente notificação
								cTexto := "O lote "+ SD7->D7_LOTECTL +", quantidade "+ Alltrim(STR(SD7->D7_QTDE)) +", do produto "+ Alltrim(SD7->D7_PRODUTO) +" foi estorno da Rejeição Parcial em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName
								
								// Envia e-mail de notificação
								cDestEML := U_RETMAILTO("D3Q")	
								
								oEmail := CONEMAIL():NEW( GetPar("MV_RELSERV") , GetPar("MV_RELACNT") , GetPar("MV_RELPSW") )
								If oEmail:CONECTAR()
								    oEmail:ENVIAR( GetPar("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
								    oEmail:DESCONEC()
								Endif
								
								//Atualiza status do notificação do e-mail de rejeição
								SD7->(Reclock("SD7",.F.))
								SD7->D7_XEMLNOT := dDataBase
								SD7->(MsUnlock())
							//Endif						
						Endif
					Endif
					
					//TSD7->(dbSkip())
				//Enddo
				//TSD7->(dbCloseArea())
			Endif
		Next
//////////////////////////////////////////////
	
	Else
		IF lUsaLuft
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ chama a funcao que gera o arquivo de integracao	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		
			For nX := 1 TO Len(aCols)   
			   
				_cNSeqSD7 := aCols[nX][nPosSeq]     
				
				// Liberacao de CQ
				IF aCols[nX][nPosTipo] == 1 .AND. aCols[nX][nPosEst] == ' '
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Abertura do Arquivo de Trabalho                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If(Select(cAliasTrb) > 0,(cAliasTrb)->(dbCloseArea()),"")
				   
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona registros referente a LIBERACAO DE CQ ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := " SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SD7")+" "+CRLF
					cQuery += " WHERE D_E_L_E_T_ = ' '  AND D7_FILIAL = '"+xFilial("SD7")+"' "+CRLF
					cQuery += " AND D7_TIPO = '1' AND D7_ESTORNO <> 'S' AND D7_SEQ = '"+aCols[nX][nPosSeq]+"' "+CRLF
					// Sobre se for liberação d amostra
					cQuery += " AND D7_LOCDEST NOT IN "+ _cLAmostra +" "+CRLF
					cQuery += " AND D7_XSTENV = ' ' " //IN('0','1') "
					cQuery += " AND D7_NUMERO = '"+ SD7->D7_NUMERO +"' AND D7_PRODUTO = '"+ SD7->D7_PRODUTO +"' "+CRLF			
					TcQuery cQuery New Alias (cAliasTrb)
					
					If (cAliasTrb)->(!EOF()) .and. (cAliasTrb)->REC > 0
						U_FCFGM001(.T.,1,(cAliasTrb)->REC)
					Endif
				Endif
				
				// Estorno de CQ
				IF aCols[nX][nPosTipo] == 1 .AND. aCols[nX][nPosEst] == 'X'  
			 //	   	msgalert ("estorno Liberação")
				 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Abertura do Arquivo de Trabalho                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If(Select(cAliasTrb) > 0,(cAliasTrb)->(dbCloseArea()),"")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona registros referentes a ESTORNO DA LIBERACAO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := " SELECT MAX(R_E_C_N_O_) as REC FROM "+RetSqlName("SD7")+" "+CRLF
					cQuery += " WHERE D_E_L_E_T_ = ' '  AND D7_FILIAL = '"+xFilial("SD7")+"' "+CRLF
					cQuery += " AND D7_TIPO = '6' AND D7_ESTORNO = 'S'  "+CRLF
					cQuery += " AND D7_LOCDEST = '" +_cLCQ+"' "+CRLF
				   	cQuery += " AND D7_XSTENV IN('1','0') "
					cQuery += " AND D7_NUMERO = '"+SD7->D7_NUMERO+"' AND D7_PRODUTO = '"+SD7->D7_PRODUTO+"' "+CRLF
					
			  //		msgalert (cQuery,"estorno Liberação")
					TcQuery cQuery New Alias (cAliasTrb)
					
					If (cAliasTrb)->(!EOF()) .and. (cAliasTrb)->REC > 0
						U_FCFGM001(.F.,2,(cAliasTrb)->REC)
					Endif
					
				Endif
				
				// Rejeicao de CQ
				IF aCols[nX][nPosTipo] == 2 .AND. aCols[nX][nPosEst] == ' '        
						//	msgalert ("rejeicao de CQ")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Abertura do Arquivo de Trabalho                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    If(Select(cAliasTrb) > 0,(cAliasTrb)->(dbCloseArea()),"")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona registros REJEICAO DE CQ ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := " SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SD7")+" "+CRLF
					cQuery += " WHERE D_E_L_E_T_ = ' '  AND D7_FILIAL = '"+xFilial("SD7")+"' "+CRLF
					cQuery += " AND D7_TIPO = '2' AND D7_ESTORNO <> 'S' AND D7_SEQ = '"+aCols[nX][nPosSeq]+"' "+CRLF
					// Sobre se for liberação d amostra
				    //	cQuery += " AND D7_LOCDEST = '" +_cLRejeica+"' "+CRLF
				  	cQuery += " AND D7_XSTENV = ' ' "
					cQuery += " AND D7_NUMERO = '"+SD7->D7_NUMERO+"' AND D7_PRODUTO = '"+SD7->D7_PRODUTO+"' "+CRLF
					
					TcQuery cQuery New Alias (cAliasTrb)
					
					If (cAliasTrb)->(!EOF()).and. (cAliasTrb)->REC > 0
						U_FCFGM001(.T.,3,(cAliasTrb)->REC)
					Endif
				Endif
				
				// estorno de Rejeicao de CQ
				IF aCols[nX][nPosTipo] == 2 .AND. aCols[nX][nPosEst] == 'X'
					_cNSeqSD7 := aCols[nX][nPosSeq] 
			   //	   	msgalert ("estorno da rejeicao de cq")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Abertura do Arquivo de Trabalho                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If(Select(cAliasTrb) > 0,(cAliasTrb)->(dbCloseArea()),"")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona registros a ESTORNO DA REJEICAO ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := " SELECT MAX(R_E_C_N_O_) AS REC FROM "+RetSqlName("SD7")+" "+CRLF
					cQuery += " WHERE D_E_L_E_T_ = ' '  AND D7_FILIAL = '"+xFilial("SD7")+"' "+CRLF
					cQuery += " AND D7_TIPO = '7' AND D7_ESTORNO = 'S' 
					//AND D7_SEQ = '"+aCols[nX][nPosSeq]+"' "+CRLF
					// Sobre se for liberação d amostra
				  //	cQuery += " AND D7_LOCDEST = '" +_cLCQ+"' "+CRLF
					cQuery += " AND D7_XSTENV IN('3','0') "
					cQuery += " AND D7_NUMERO = '"+SD7->D7_NUMERO+"' AND D7_PRODUTO = '"+SD7->D7_PRODUTO+"' "+CRLF
					
					TcQuery cQuery New Alias (cAliasTrb)
					
					If (cAliasTrb)->(!EOF()) .and. (cAliasTrb)->REC > 0
						U_FCFGM001(.F.,4,(cAliasTrb)->REC)
					Endif
				Endif
				
			Next
			
		Endif
	Endif
	RestArea(aAreaSB8)
	RestArea(aAreaSD7)
	RestArea(aArea)    
	Msgalert("Movimentos de CQ concluído!","Mov. CQ")
Return(.T.)


Static Function GetPar(cPar)
return(getmv(cPar))
