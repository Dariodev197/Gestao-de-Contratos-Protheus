#include 'totvs.ch'

/*/{Protheus.doc} U_GTCA001
    (CADSTRO DE TIPOS DE CONTRATOS (MVC MODELO 1)
    @type  Function
    @author Dario Leandro
    @since 04/02/2026
    
    /*/
Function U_GCTA001

    local nOpcPad      := 4

    Private cCadastro  := 'Cadastro de Tipos De Contratos'
    Private aRotina    := {}
    
    aadd(aRotina,{"Pesquisar" ,  "axPesqui",0,1})
    aadd(aRotina,{"Visualizar",  "axVisual",0,2})
    aadd(aRotina,{"Incluir"   ,  "axInclui",0,3})
    aadd(aRotina,{"Alterar"   ,  "axAltera",0,4})
    aadd(aRotina,{"Excluir"   ,  "axDeleta",0,5})

    dbSelectArea("Z50")
    dbSetOrder(1)

    mBrowse(,,,,alias(),,,,,nOpcPad)
    
Return 
