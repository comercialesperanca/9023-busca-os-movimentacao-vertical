unit UHistoricoAlteracoes;

interface

///  Este arquivo armazena o histórico das alterações
///  realizadas no programa Conferencia Paletizada,
///  dessa forma no código do programa podemos apenas
///  referenciar o número da alteração ou versão.
implementation
///  ///////////////////////////////////////
///
///  Versão:       1.0.0.0
///  Data:         24/02/2017
///  Programador:  Marcos Pereira
///  CR:           2061 (Melhoria do dia  24/03/2017)
///  Solicitação:  Marcos/Alexandre
///
///  -- Criar um programa que funcione como um serviço que procura por O.S. de movimentação
///     vertical na tabela 'pcmovendpend' e adiciona na tabela 'boosverticaldisponivel', para
///     que uma posterior consulta por O.S do tipo seja mais rápida, melhorando a performance
///     de rotinas que são executadas no coletor.
///   	A principío a rotina irá procura apenas por um tipo de O.S. de movimentação vertical,
///     as O.S. de recebimento, portanto é importante nessa procurá ler também a tabela
///     'Bomovrecebimento', além da tabela 'pcmovendpend', para identificar as U.M.A. que já
///     foram conferidas horizontalmente e então entender que já estão disponíveis para a
///     movimentação Vertical.
///
///  Solução
///     Na abertura do programa a consulta que segue as regras passadas na solicitação é
///     disparada e um timer que dispara ela novamente a cada três minutos, o resultado da
///     consulta é rigorosamente inserído na tabela 'BOOSVERTICALDISPONIVEL', como solicitado.
///
///  ///////////////////////////////////////
///
///  Versão:       2.0.0.0
///  Data:         19/07/2017
///  Programador:  Marcos Pereira
///  CR:           2108 (Melhoria do dia  17/07/2017)
///  Solicitação:  Marcos/Viana
///
///  -- Com base na reunião feita na sexta-feira do dia 14/07/2017, iremos iniciar o
///     projeto de convocação ativa no abastecimento. Mediante a isto, precisamos de algu-
///     mas melhorias em rotinas, sendo que a 9023 será uma delas.
///     Para esta rotina, precisamos que consiga efetuar leitura da OS 61 de abastecimento,
//      ou seja, além de inserir tipoos 98 - movimentação de armazenagem vertical, deverá
///     ler também da tabela PCMOVENDPEND a de abastecimento 61.
///     Levando em consideração a regra inicial que não poderá estar finalizada
///     (posicao <>  C)
///     Deverá inserir na tabela boosverticaldisponivel.
///
///  Solução
///    Interface:
///      - Existem duas novos campos na tela 'Recebimento' e 'Abastecimento', eles são
///        checkbox, podem ser marcados ou não, porém como padrão na abertura do programa
///        estão marcados. O que significa que a busca será feita por OSs dos dois tipos
///        Abastecimento e Recebimento, quando um deles ou os dois estiverem desmarcados
///        não será feita a busta pelo tipo de Os desmarcado.
///    Controle:
///      - No evento 'onShow' do formulário 'frmPrincipal', os componentes 'chkRecebimento'
///        e 'chkAbastecimento' têm a propriedade 'checked' ativada (true) e as procedures
///        'OSsRecebimento' e 'OSsAbastecimento' executadas caso os componentes 'checkeds'
///        estejam ativados. Mesmo sendo óbvio que estes componentes estarão ativados é
///        feita a verificação, para caso a ativação desses componentes na abertura se torne
///        um parâmetro no futuro;
///      - Na procedure executada pelo evento 'onClick' do botão 'btnIniciar', do formulário
///        'frmPrincipal', passei a verificar se os componentes 'chkRecebimento' e
///        'chkAbastecimento', estão com a propriedade 'checked' igual a true, para então
///        executar as procedures 'OSsRecebimento' e 'OSsAbastecimento', sendo que a execução
///        da procedure 'OSsAbastecimento' é algo novo, já que a mesma não existia antes;
///      - Na procedure executada pelo exento 'onTimer' do timer 'tProcesso', do formulário
///        'frmPrincipal', passei a verificar se os componentes 'chkRecebimento' e
///        'chkAbastecimento', estão com a propriedade 'checked' igual a true, para então
///        executar as procedures 'OSsRecebimento' e 'OSsAbastecimento', sendo que a execução
///        da procedure 'OSsAbastecimento' é algo novo, já que a mesma não existia antes;
///      - A procedure 'OSsAbastecimento' foi criada para executar as querys 'qryOSsAbastecimentoPreventivo'
///        e 'qryOSsAbastecimentoCorretivo', em busca de OSs de abastecimento dos tipos
///        preventivo e corretivo. Logo após a execução de cada consulta faz um loop para
///        inserir cada registro encontrado em uma tabela que mantem as OSs de movimentaçã
///        verticcal que estão disponíveis, usando as querys 'qryInsereOSVerticalPreventivo'
///        e 'qryInsereOSVerticalCorretivo'.
///    Dados:
///      - A query 'qryOSsAbastecimentoPreventivo', procura por OSs do tipo 61(Abastecimento)
///        na tabela 'pcmovendpend', que não possuam relação com alguma carga na tabela
///        'pcwms', o que indica não ser um abastecimento corretivo e sim preventivo. Essas
///        OSs não devem estar estornadas, não terem sido iniciadas e não terem sido inseridas
///        antes na tabela 'boosverticaldisponivel'. Como parâmetro é passado apenas a filial
///        e um prazo máximo de dias para a pesquisa;
///      - A query 'qryOSsAbastecimentoCorretivo', procura por OSs do tipo 61(Abastecimento)
///        na tabela 'pcmovendpend', que possuam relação com alguma carga, que já tenha
///        sido inserida em uma onda, o que indica ser uma OS de abastecimento corretivo.
///        Essas OSs não devem estar estornadas, não terem sido iniciadas e não terem sido
///        inseridas antes na tabela 'boosverticaldisponivel'. Como parâmetro é passado
///        apenas a filial e um prazo máximo de dias para a pesquisa;
///      - A query 'qryInsereOSVerticalPreventivo', insere na tabela 'BOOSVERTICALDISPONIVEL'
///        um registro com informações da OS de abastecimento, gravando no campo tipo o valor
///        61, que indica ser um abastecimento e não recebimento e no novo campo
///        'modeloabastecimento' o valor 'P', que indica ser um abastecimento preventivo;
///      - A query 'qryInsereOSVerticalCorretivo', insere na tabela 'BOOSVERTICALDISPONIVEL'
///        um registro com informações da OS de abastecimento, gravando no campo tipo o valor
///        61, que indica ser um abastecimento e não recebimento, no novo campo
///        'modeloabastecimento' o valor 'C', que indica ser um abastecimento corretivo e
///        no também campo novo 'numcar', o número do carregamento ao qual está relaciona-
///        o abastecimento.
///
///  ///  ///////////////////////////////////////
///
///  Versão:       2.0.0.1
///  Data:         19/07/2017
///  Programador:  Marcos Pereira
///  CR:           2108 (Melhoria do dia  25/07/2017)
///  Solicitação:  Viana
///
///  -- Como precisaremos colocar esta rotina em produção, antes mesmo o
///     coletor estar preparado para ler este tipo de informação, precisamos
///     que a rotina 9023, ao abrir, não faça ja uma consulta, somente quando
///     o timer acabar. Com esta melhoria, quem estiver manipulando a rotina,
///     terá tempo hábil para desmarcar as opções desejadas.
///
///  Solução
///    Controle:
///      - No evento 'onShow', do formulário 'frmPrincipal', comentei as linhas
///        de comando que validavam e executavam das procedures que fazem a procura
///        por OSs de recebimento e abastecimento 'OSsRecebimento' e 'OSsAbastecimento';
///
///  ///  ///////////////////////////////////////
///
///  Versão:       2.0.0.2
///  Data:         01/08/2017
///  Programador:  Marcos Pereira
///  CR:           2113 (Melhoria do dia  01/08/2017)
///  Solicitação:  Viana
///
///  -- O endereço capturado na OS está sendo o de destino e precisa ser o de origem,
///     ou seja, ao invéz do campo codendereco o campo codenderecoorig;
///
///  Solução
///    Controle:
///      - A função 'OSsAbastecimento', passou atribuir ao parâmetro 'CODENDERECO', das
///        querys 'qryInsereOSVerticalPreventivo' e 'qryInsereOSVerticalCorretivo' o valor
///        da coluna 'codenderecoorig', das querys 'qryOSsAbastecimentoPreventivo' e
///        'qryOSsAbastecimentoCorretivo'.
///    Dados:
///      - As querys 'qryOSsAbastecimentoPreventivo' e 'qryOSsAbastecimentoCorretivo',
///        passaram a trazer o campo 'codenderecoorig' oa invés do campo 'codendereco',
///        ambos na tabela 'pcmovendpend'.
///
///  ///  ///////////////////////////////////////
///
///  Versão:       2.0.0.3
///  Data:         31/08/2017
///  Programador:  Marcos Pereira
///  CR:           2118 (Melhoria do dia  28/08/2017)
///  Solicitação:  Viana
///
///  -- Com base na demanada de homologação da convocação ativa no abastecimento, preci-
///     samos que a rotina 9023 não leia OS's de abastecimentos cujo o destino seja o
///     flowrack. Esta necessidade surgiu, pois, o processo de execução deste setor não
///     irá trabalhar com as memsas regras que os abastecimentos normais.
///     Deverá ser seguido a seguinte regra para não buscar determinadas OS's:
///     Se o endereço de destino for ruas que estão parametrizadas como endereços de
///     flowrack e também possuem nivel 0, ou seja, se a origem for o armazém, com
///     nível 0 e o destino for flowrack, nível 0, esta OS não deverá ser populada na
///     BOOSVERTICALDISPONIVEL.
///     Select para descobrir se o endereço é flowrack.
///     ---Descobre endereços do produto
///        select codendereco from pcprodutpicking
///        where codfilial = '2'
///              and codprod = 102;
///     ---Descobre estrutura dos endereços
///        select codestrutura from pcendereco
///        where codendereco in (507811,408730);
///     ---Cadastro de estrutura
///        select * from pctipoestrutura
///     Se a estrutura do endereço for igual a 3, quer dizer que este endereço é
///     flowrack.
///
///  Solução
///    Dados:
///      - As querys 'qryOSsAbastecimentoPreventivo' e 'qryOSsAbastecimentoCorretivo' receberam
///        uma nova instrução um join que valida a estrutura do endereço de destino, que
///        verifica se o mesmo não é flowrack (estrutura 3):
///        join pcendereco enderecodestino on enderecodestino.codendereco=pcmovendpend.codendereco
///                                           and enderecodestino.codestrutura<>3
///
///  ///  ///////////////////////////////////////
///
///  Versão:       2.0.0.4
///  Data:         31/08/2017
///  Programador:  Marcos Pereira
///  CR:           2118 (Melhoria do dia  28/08/2017)
///  Solicitação:  Viana
///
///  -- A rotina 9023 puxou OS's de abastecimento flowrack. Conforme analisado por
///     Marcos, existe uma falha na logica do with de consulta das cargas com OS, cujo
///     o destino é flowrack e seu tipo é 61.
///
///  Solução
///    Dados:
///      - A query 'qryOSsAbastecimentoCorretivo', estava validando a existencia de OS
///        com endereço de destino no flowrack, apenas na subquery que validava as cargas
///        que teriam OSs de abastecimento, logo quando a carga possui também OSs de
///        abastecimento que não tem como endereço final o Flowrack, é liberada, por isso
///        foi necessário fazer uma validação por OS e não apenas por carga e isso foi
///        na query principal com o join de validação de endereço:
///                 join pcendereco on mep.codendereco=pcendereco.codendereco
///                                    and pcendereco.codestrutura<>3
///
///
/////////////////////////////////////////////
///
///  Versão:       2.0.1.0
///  Data:         13/04/2018
///  Programador:  Mayara Raphael
///  CR:           2166 (Melhoria do dia 10/04/2018 - 11:30)
///  Solicitação:  Felipe Viana
///
///
///     Felipe Viana - (10/04/2018 - 11:30)
///  -- Atualmente a rotina 9023 está parametrizada para não consultar OS's disponíveis em que
///     seu endereço de destino seja flow rack, ou seja, tipo de estrutura 3. É neste momento
///     que temos de adicionar uma exceção, onde, se o endereço de origem possuir um nível maior
///     que 0 (ZERO) e o endereço de destino for flow rack (estrutura 3), esta OS deverá ser inserida
///     na BOOSVERTICALDISPONIVEL.
///
///  Solução
///    Dados:
///      - Alterada as querys 'qryOSsAbastecimentoCorretivo' e 'qryOSsAbastecimentoPreventivo' para buscar
///        OSs destino flow rack  que o nivel de origem seja maior que 0. Comentada a linha 'and pcendereco.codestrutura<>3'
///        e adicionado no where and not (origem.nivel=0 and pcendereco.codestrutura=3).
///
end.
