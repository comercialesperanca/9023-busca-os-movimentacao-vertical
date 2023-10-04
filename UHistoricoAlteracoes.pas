unit UHistoricoAlteracoes;

interface

///  Este arquivo armazena o hist�rico das altera��es
///  realizadas no programa Conferencia Paletizada,
///  dessa forma no c�digo do programa podemos apenas
///  referenciar o n�mero da altera��o ou vers�o.
implementation
///  ///////////////////////////////////////
///
///  Vers�o:       1.0.0.0
///  Data:         24/02/2017
///  Programador:  Marcos Pereira
///  CR:           2061 (Melhoria do dia  24/03/2017)
///  Solicita��o:  Marcos/Alexandre
///
///  -- Criar um programa que funcione como um servi�o que procura por O.S. de movimenta��o
///     vertical na tabela 'pcmovendpend' e adiciona na tabela 'boosverticaldisponivel', para
///     que uma posterior consulta por O.S do tipo seja mais r�pida, melhorando a performance
///     de rotinas que s�o executadas no coletor.
///   	A princip�o a rotina ir� procura apenas por um tipo de O.S. de movimenta��o vertical,
///     as O.S. de recebimento, portanto � importante nessa procur� ler tamb�m a tabela
///     'Bomovrecebimento', al�m da tabela 'pcmovendpend', para identificar as U.M.A. que j�
///     foram conferidas horizontalmente e ent�o entender que j� est�o dispon�veis para a
///     movimenta��o Vertical.
///
///  Solu��o
///     Na abertura do programa a consulta que segue as regras passadas na solicita��o �
///     disparada e um timer que dispara ela novamente a cada tr�s minutos, o resultado da
///     consulta � rigorosamente inser�do na tabela 'BOOSVERTICALDISPONIVEL', como solicitado.
///
///  ///////////////////////////////////////
///
///  Vers�o:       2.0.0.0
///  Data:         19/07/2017
///  Programador:  Marcos Pereira
///  CR:           2108 (Melhoria do dia  17/07/2017)
///  Solicita��o:  Marcos/Viana
///
///  -- Com base na reuni�o feita na sexta-feira do dia 14/07/2017, iremos iniciar o
///     projeto de convoca��o ativa no abastecimento. Mediante a isto, precisamos de algu-
///     mas melhorias em rotinas, sendo que a 9023 ser� uma delas.
///     Para esta rotina, precisamos que consiga efetuar leitura da OS 61 de abastecimento,
//      ou seja, al�m de inserir tipoos 98 - movimenta��o de armazenagem vertical, dever�
///     ler tamb�m da tabela PCMOVENDPEND a de abastecimento 61.
///     Levando em considera��o a regra inicial que n�o poder� estar finalizada
///     (posicao <>  C)
///     Dever� inserir na tabela boosverticaldisponivel.
///
///  Solu��o
///    Interface:
///      - Existem duas novos campos na tela 'Recebimento' e 'Abastecimento', eles s�o
///        checkbox, podem ser marcados ou n�o, por�m como padr�o na abertura do programa
///        est�o marcados. O que significa que a busca ser� feita por OSs dos dois tipos
///        Abastecimento e Recebimento, quando um deles ou os dois estiverem desmarcados
///        n�o ser� feita a busta pelo tipo de Os desmarcado.
///    Controle:
///      - No evento 'onShow' do formul�rio 'frmPrincipal', os componentes 'chkRecebimento'
///        e 'chkAbastecimento' t�m a propriedade 'checked' ativada (true) e as procedures
///        'OSsRecebimento' e 'OSsAbastecimento' executadas caso os componentes 'checkeds'
///        estejam ativados. Mesmo sendo �bvio que estes componentes estar�o ativados �
///        feita a verifica��o, para caso a ativa��o desses componentes na abertura se torne
///        um par�metro no futuro;
///      - Na procedure executada pelo evento 'onClick' do bot�o 'btnIniciar', do formul�rio
///        'frmPrincipal', passei a verificar se os componentes 'chkRecebimento' e
///        'chkAbastecimento', est�o com a propriedade 'checked' igual a true, para ent�o
///        executar as procedures 'OSsRecebimento' e 'OSsAbastecimento', sendo que a execu��o
///        da procedure 'OSsAbastecimento' � algo novo, j� que a mesma n�o existia antes;
///      - Na procedure executada pelo exento 'onTimer' do timer 'tProcesso', do formul�rio
///        'frmPrincipal', passei a verificar se os componentes 'chkRecebimento' e
///        'chkAbastecimento', est�o com a propriedade 'checked' igual a true, para ent�o
///        executar as procedures 'OSsRecebimento' e 'OSsAbastecimento', sendo que a execu��o
///        da procedure 'OSsAbastecimento' � algo novo, j� que a mesma n�o existia antes;
///      - A procedure 'OSsAbastecimento' foi criada para executar as querys 'qryOSsAbastecimentoPreventivo'
///        e 'qryOSsAbastecimentoCorretivo', em busca de OSs de abastecimento dos tipos
///        preventivo e corretivo. Logo ap�s a execu��o de cada consulta faz um loop para
///        inserir cada registro encontrado em uma tabela que mantem as OSs de movimenta��
///        verticcal que est�o dispon�veis, usando as querys 'qryInsereOSVerticalPreventivo'
///        e 'qryInsereOSVerticalCorretivo'.
///    Dados:
///      - A query 'qryOSsAbastecimentoPreventivo', procura por OSs do tipo 61(Abastecimento)
///        na tabela 'pcmovendpend', que n�o possuam rela��o com alguma carga na tabela
///        'pcwms', o que indica n�o ser um abastecimento corretivo e sim preventivo. Essas
///        OSs n�o devem estar estornadas, n�o terem sido iniciadas e n�o terem sido inseridas
///        antes na tabela 'boosverticaldisponivel'. Como par�metro � passado apenas a filial
///        e um prazo m�ximo de dias para a pesquisa;
///      - A query 'qryOSsAbastecimentoCorretivo', procura por OSs do tipo 61(Abastecimento)
///        na tabela 'pcmovendpend', que possuam rela��o com alguma carga, que j� tenha
///        sido inserida em uma onda, o que indica ser uma OS de abastecimento corretivo.
///        Essas OSs n�o devem estar estornadas, n�o terem sido iniciadas e n�o terem sido
///        inseridas antes na tabela 'boosverticaldisponivel'. Como par�metro � passado
///        apenas a filial e um prazo m�ximo de dias para a pesquisa;
///      - A query 'qryInsereOSVerticalPreventivo', insere na tabela 'BOOSVERTICALDISPONIVEL'
///        um registro com informa��es da OS de abastecimento, gravando no campo tipo o valor
///        61, que indica ser um abastecimento e n�o recebimento e no novo campo
///        'modeloabastecimento' o valor 'P', que indica ser um abastecimento preventivo;
///      - A query 'qryInsereOSVerticalCorretivo', insere na tabela 'BOOSVERTICALDISPONIVEL'
///        um registro com informa��es da OS de abastecimento, gravando no campo tipo o valor
///        61, que indica ser um abastecimento e n�o recebimento, no novo campo
///        'modeloabastecimento' o valor 'C', que indica ser um abastecimento corretivo e
///        no tamb�m campo novo 'numcar', o n�mero do carregamento ao qual est� relaciona-
///        o abastecimento.
///
///  ///  ///////////////////////////////////////
///
///  Vers�o:       2.0.0.1
///  Data:         19/07/2017
///  Programador:  Marcos Pereira
///  CR:           2108 (Melhoria do dia  25/07/2017)
///  Solicita��o:  Viana
///
///  -- Como precisaremos colocar esta rotina em produ��o, antes mesmo o
///     coletor estar preparado para ler este tipo de informa��o, precisamos
///     que a rotina 9023, ao abrir, n�o fa�a ja uma consulta, somente quando
///     o timer acabar. Com esta melhoria, quem estiver manipulando a rotina,
///     ter� tempo h�bil para desmarcar as op��es desejadas.
///
///  Solu��o
///    Controle:
///      - No evento 'onShow', do formul�rio 'frmPrincipal', comentei as linhas
///        de comando que validavam e executavam das procedures que fazem a procura
///        por OSs de recebimento e abastecimento 'OSsRecebimento' e 'OSsAbastecimento';
///
///  ///  ///////////////////////////////////////
///
///  Vers�o:       2.0.0.2
///  Data:         01/08/2017
///  Programador:  Marcos Pereira
///  CR:           2113 (Melhoria do dia  01/08/2017)
///  Solicita��o:  Viana
///
///  -- O endere�o capturado na OS est� sendo o de destino e precisa ser o de origem,
///     ou seja, ao inv�z do campo codendereco o campo codenderecoorig;
///
///  Solu��o
///    Controle:
///      - A fun��o 'OSsAbastecimento', passou atribuir ao par�metro 'CODENDERECO', das
///        querys 'qryInsereOSVerticalPreventivo' e 'qryInsereOSVerticalCorretivo' o valor
///        da coluna 'codenderecoorig', das querys 'qryOSsAbastecimentoPreventivo' e
///        'qryOSsAbastecimentoCorretivo'.
///    Dados:
///      - As querys 'qryOSsAbastecimentoPreventivo' e 'qryOSsAbastecimentoCorretivo',
///        passaram a trazer o campo 'codenderecoorig' oa inv�s do campo 'codendereco',
///        ambos na tabela 'pcmovendpend'.
///
///  ///  ///////////////////////////////////////
///
///  Vers�o:       2.0.0.3
///  Data:         31/08/2017
///  Programador:  Marcos Pereira
///  CR:           2118 (Melhoria do dia  28/08/2017)
///  Solicita��o:  Viana
///
///  -- Com base na demanada de homologa��o da convoca��o ativa no abastecimento, preci-
///     samos que a rotina 9023 n�o leia OS's de abastecimentos cujo o destino seja o
///     flowrack. Esta necessidade surgiu, pois, o processo de execu��o deste setor n�o
///     ir� trabalhar com as memsas regras que os abastecimentos normais.
///     Dever� ser seguido a seguinte regra para n�o buscar determinadas OS's:
///     Se o endere�o de destino for ruas que est�o parametrizadas como endere�os de
///     flowrack e tamb�m possuem nivel 0, ou seja, se a origem for o armaz�m, com
///     n�vel 0 e o destino for flowrack, n�vel 0, esta OS n�o dever� ser populada na
///     BOOSVERTICALDISPONIVEL.
///     Select para descobrir se o endere�o � flowrack.
///     ---Descobre endere�os do produto
///        select codendereco from pcprodutpicking
///        where codfilial = '2'
///              and codprod = 102;
///     ---Descobre estrutura dos endere�os
///        select codestrutura from pcendereco
///        where codendereco in (507811,408730);
///     ---Cadastro de estrutura
///        select * from pctipoestrutura
///     Se a estrutura do endere�o for igual a 3, quer dizer que este endere�o �
///     flowrack.
///
///  Solu��o
///    Dados:
///      - As querys 'qryOSsAbastecimentoPreventivo' e 'qryOSsAbastecimentoCorretivo' receberam
///        uma nova instru��o um join que valida a estrutura do endere�o de destino, que
///        verifica se o mesmo n�o � flowrack (estrutura 3):
///        join pcendereco enderecodestino on enderecodestino.codendereco=pcmovendpend.codendereco
///                                           and enderecodestino.codestrutura<>3
///
///  ///  ///////////////////////////////////////
///
///  Vers�o:       2.0.0.4
///  Data:         31/08/2017
///  Programador:  Marcos Pereira
///  CR:           2118 (Melhoria do dia  28/08/2017)
///  Solicita��o:  Viana
///
///  -- A rotina 9023 puxou OS's de abastecimento flowrack. Conforme analisado por
///     Marcos, existe uma falha na logica do with de consulta das cargas com OS, cujo
///     o destino � flowrack e seu tipo � 61.
///
///  Solu��o
///    Dados:
///      - A query 'qryOSsAbastecimentoCorretivo', estava validando a existencia de OS
///        com endere�o de destino no flowrack, apenas na subquery que validava as cargas
///        que teriam OSs de abastecimento, logo quando a carga possui tamb�m OSs de
///        abastecimento que n�o tem como endere�o final o Flowrack, � liberada, por isso
///        foi necess�rio fazer uma valida��o por OS e n�o apenas por carga e isso foi
///        na query principal com o join de valida��o de endere�o:
///                 join pcendereco on mep.codendereco=pcendereco.codendereco
///                                    and pcendereco.codestrutura<>3
///
///
/////////////////////////////////////////////
///
///  Vers�o:       2.0.1.0
///  Data:         13/04/2018
///  Programador:  Mayara Raphael
///  CR:           2166 (Melhoria do dia 10/04/2018 - 11:30)
///  Solicita��o:  Felipe Viana
///
///
///     Felipe Viana - (10/04/2018 - 11:30)
///  -- Atualmente a rotina 9023 est� parametrizada para n�o consultar OS's dispon�veis em que
///     seu endere�o de destino seja flow rack, ou seja, tipo de estrutura 3. � neste momento
///     que temos de adicionar uma exce��o, onde, se o endere�o de origem possuir um n�vel maior
///     que 0 (ZERO) e o endere�o de destino for flow rack (estrutura 3), esta OS dever� ser inserida
///     na BOOSVERTICALDISPONIVEL.
///
///  Solu��o
///    Dados:
///      - Alterada as querys 'qryOSsAbastecimentoCorretivo' e 'qryOSsAbastecimentoPreventivo' para buscar
///        OSs destino flow rack  que o nivel de origem seja maior que 0. Comentada a linha 'and pcendereco.codestrutura<>3'
///        e adicionado no where and not (origem.nivel=0 and pcendereco.codestrutura=3).
///
end.
