#INCLUDE "rwmake.ch"

/************************************************************************************************************
* Programa......:	CADP02
* Objetivo......: 	Cadastro de SubAtividades - Tabela P02
* Autor.........:   José Augusto P. Alves
* Data..........:   07/12/2021
* Alterado......:   
*/                  

*-------------------
User Function CADP02
*-------------------

Private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "P02"

dbSelectArea("P02")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de SubAtividades",cVldExc,cVldAlt)

Return
