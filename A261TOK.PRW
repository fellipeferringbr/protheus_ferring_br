#INCLUDE "PROTHEUS.CH"
#DEFINE ENTER CHR(13) + CHR(10)     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA261TOK   บAutor  ณLeandro Fini   บ Data ณ  26/02/15        บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  PE de Validacao na transfer๊ncia mod 2 entre armaz้ns     บฑฑ
ฑฑบ             conforme chamado: INC252488 e INC251595                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Ferring                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



User Function A261TOK()

Local lRet 		:= .T.
Local i			:= 0    
Local cProdO	:= "" 
Local cProdD	:= ""  
Local cArmO		:= ""
Local cArmD		:= "" 
Local cQuant    := 0
Local cVldO     := ""
Local cVldD     := ""
Local cUser		:=__cUserID                                      
Local cUserCQ	:= SuperGetMV( "ES_MOVUS", .T., "000000,000132,000131,000179") //usuarios da qualidade que terao permissao para mov. armazem da qualidade 
Local cLocQua	:= SuperGetMv( "ES_MOVQUA", .T., "01,85" )                                     
Local cUserLT	:= SuperGetMV( "ES_MOVLOTE", .T., "000000,000132,000179") // Admin, Helena, Andr้a


For i := 1 to Len(aCols) 

	cProdO 		:= aCols[i][1]  // produto origem                                
	cProdD		:= aCols[i][6]  // produto destino
	cArmO		:= aCols[i][4]  // armazem origem
	cArmD		:= aCols[i][9]  // armazem destino 
	cLotO		:= aCols[i][12] // lote origem
	cVldO		:= aCols[i][14] // validade origem
	cQuant		:= aCols[i][16] // quantidade
	cLotD		:= aCols[i][20] // lote destino
	cVldD		:= aCols[i][21] // validade destino  
	
	If cProdO <> cProdD // verifica se prod origem ้ diferente do prod destino
		lRet := .F.  
		MsgAlert("Produto origem e destino estใo diferentes por favor verifique.")
	EndIf
	
	If cArmO == cArmD .AND. !cUser $ cUserLT // verifica se armazem origem ้ igual ao armazem destino
				lRet := .F.
			 	MsgAlert("Nใo permitida a troca entre armaz้ns iguais, verifique armaz้m origem e destino")     
	EndIf	                                                                                                  	 

	If cArmO == "55" .AND. !cUser $ cUserCQ  //verifica se o armazem origem ้ 55 e se o usuario tem permissao para movimenta-lo conforme parametro
			lRet := .F.      
			MsgAlert("A movimenta็ใo do armaz้m 55 ้ permitida somente pelos responsแveis da Qualidade") 
	EndIf
	
	If cArmD == "50" .AND. !cUser $ cUserCQ //verifica se o armazem destino ้ o 50 e se o usuario tem permissใo para inserir prod lแ conforme parametro
		lRet := .F.
		MsgAlert("Nใo ้ permitida a transfer๊ncia para o armaz้m 50")
	EndIf
	  
	If cArmO == "85" .AND. cArmD < "85" .AND. !cUser $ cUserLT  //verifica se o armazem origem ้ 85 e se o destino ้ menor ou igual ao 85 e se o usuario tem permissao para movimenta-lo conforme parametro
			lRet := .F.      
			MsgAlert("Usuแrio nใo possui autoriza็ใo para retirar produtos do 85 e transferir para armaz้ns menores que 85.") 
	EndIf	
	
	If !Empty(cLotD) .AND. !cUser $ cUserLT  //Verifica se o usuario tem permissao para alterar o lote
		lRet := .F.
		MsgAlert("Usuario nใo possui autoriza็ใo para alterar o lote")
	EndIf 
	
	If cVldD <> cVldO .AND. !cUser $ cUserLT  //Verifica se o usuario tem permissao para alterar a validade
		lRet := .F.
		MsgAlert("Usuario nใo possui autoriza็ใo para alterar a validade")
	EndIf
 
 
	   
    If lRet == .F.
  	 	MsgAlert("Transfer๊ncia do produto nใo permitida") 
	  Else
	  	lRet := MsgNoYes("Deseja trocar o Produto: "+CVALTOCHAR(ALLTRIM(cProdO))+" Lote: "+ALLTRIM(cLotO)+" Quantidade: "+CVALTOCHAR(cQuant)+" do Armaz้m "+CVALTOCHAR(cArmO)+" para o Armaz้m "+CVALTOCHAR(cArmD)+"?" ," Confirmar Armaz้m ")                       
    EndIf
	  

Next                  

Return lRet