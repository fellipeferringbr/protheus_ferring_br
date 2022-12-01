#INCLUDE "rwmake.ch"

/************************************************************************************************************
* Programa......:	CADP03
* Objetivo......: 	Cadastro de Conflitos Globais - Tabela P03
* Autor.........:   José Augusto P. Alves
* Data..........:   07/12/2021
* Alterado......:   
*/                  

*-------------------
User Function CADP03
*-------------------

Private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "P03"

dbSelectArea("P03")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Conflitos Globais",cVldExc,cVldAlt)

Return
