#include 'protheus.ch'
#include 'parmtype.ch'
/* Andre - 28/10/2018 */
user function MA120BUT()       
	Local aRot := {}

	IF !INCLUI .AND. !ALTERA
		//aadd(aRot,{'BUDGETY',{|| U_ConhecSC7()},'Conhecimento','Conhecimento'}) 
		Aadd(aRot,{"Conhecimento",{|| MsDocument('SC7',SC7->(RecNo()), 4)}, "Conhecimento","Conhecimento"})	
	EndIF

return(aRot)