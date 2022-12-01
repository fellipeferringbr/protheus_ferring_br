#include 'protheus.ch'
#INCLUDE 'rwmake.ch'
#include 'TOPCONN.CH'


/*/{Protheus.doc} MTA103MNU
//Ponto de Entrada para manipulação do Menu - Documento de Entrada
@type function
@version 2.0 / FERRING
@return Nil
/*/

User Function MTA103MNU			
aAdd(aRotina,{ "Imprimir NCC     ", "U_RComR010", 0 , 2, 0, .F.}) // Cleyton Leal   - 24/02/2014
aAdd(aRotina,{ "Rejeita Pre-Nota ", "U_FCOMA001('D')", 0 , 2, 0, .F.}) // Luiz Junior QS - 28/01/2020
//Aadd(aRotina,{"Complementos","a910Compl",0,4,0,NIL})
Return 