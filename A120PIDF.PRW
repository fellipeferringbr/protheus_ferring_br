#include 'protheus.ch'
/* 
Filtra as SC na inclusao do PC 
Andre Elias de Araujo  |  .And. C1_STATLIB=="3" 
*/
User Function A120PIDF()
Local cComp := GetMV("FE_IDCOMP")  
Local cFilSC1   := 'C1_FILIAL == "'+xFilial('SC1')+'".And. C1_QUJE < C1_QUANT .And. C1_TPOP<>"P" .And. C1_STATLIB=="3" .And. C1_APROV$" ,L" .And.( C1_COTACAO == "IMPORT" .Or. C1_COTACAO == "'+Space(Len(SC1->C1_COTACAO))+'" .Or. C1_COTACAO == "'+Replicate("X",Len(SC1->C1_COTACAO))+'") .And. C1_FLAGGCT <> "1"'

IF !__cUserID $ cComp
	cFilSC1 := 'C1_USER="'+__cUserID+'" .And. '+ cFilSC1
	// cFilSC1 := 'C1_USER="'+__cUserID+'" ' 
EndIF    
// Msgalert( cFilSC1 )                                           
Return ({cFilSC1})                                  