#INCLUDE "rwmake.ch"

/************************************************************************************************************
* Programa......:	CADP04
* Objetivo......: 	Cadastro de Fun??es Protheus - Tabela P04
* Autor.........:   Jos? Augusto P. Alves
* Data..........:   07/12/2021
* Alterado......:   
*/                  

*-------------------
User Function CADP04
*-------------------

Private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "P04"

dbSelectArea("P04")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Fun??es Protheus",cVldExc,cVldAlt)

Return
