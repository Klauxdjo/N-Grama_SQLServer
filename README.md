# N-Grama_SQLServer
Função T-SQL para extrair n-gramas de nível 3 até 6 a partir de uma variável texto.

Praticamente em todo trabalho de mineração de texto que envolva análise de um texto livre, como uma observação digitada pelo usuário, precisaremos extrair os n-gramas que compõem esse texto.
Para quem ainda não domina estes conceitos, n-gramas são sequências de palavras significativas de um texto, e como eu mencionei palavras significativas, já deu para perceber que algumas outras não são consideradas descartáveis, são as chamadas _Stop Words_.

Talvez um exemplo torne mais claro. Consideremos o texto abaixo:
<pre>"Ninguém podia entrar nela não, porque na casa não tinha chão..." </pre>

Neste caso, podemos considerar como descartáveis as palavras: *não* e *na*, além de outros símbolos gráficos (*,*).
O novo texto seria: 
<pre>"Ninguém podia entrar nela porque casa tinha chão..." </pre>

Poderíamos formar n-gramas de diversos níveis, por exemplo:

 Bigramas        | Trigramas            | Quadrigramas              | Nível 5
-----------------|----------------------|---------------------------|----------------------------------
 Ninguém podia   | Ninguém podia entrar | Ninguém podia entrar nela | Ninguém podia entrar nela porque
 podia entrar    | podia entrar nela    | podia entrar nela porque  | podia entrar nela porque casa
 entrar nela     | entrar nela porque   | entrar nela porque casa   | entrar nela porque casa tinha
 nela porque     | nela porque casa     | nela porque casa tinha    | nela porque casa tinha chão
 porque casa     | porque casa tinha    | porque casa tinha chão    |
 casa tinha      | casa tinha chão      |                           |
 tinha chão      |                      |                           |

Hoje temos uma excelente gama de alternativas para extrair n-gramas de um texto, desde ferramentas sem código, como por exemplo, o Rapid Miner, até bibliotecas sofisticadas que permitem fazê-lo a partir de, praticamente, qualquer linguagem (com destaque às bibliotecas em Python).
Apesar disso, pode ser interessante fazer essa extração diretamente no SQL-Server (ou, com alguma adaptação, em qualquer outro banco relacional). Com o intuito de facilitar quem quiser se aventurar por esse caminho, segue uma implementação funcional que, recebido um texto como parametro, retorna uma tabela com todos os n-gramas formados (pode-se escolher o nível do n-grama a partir de 3 até 6).

Exemplo de uso:
<pre><code>
SELECT	txt_ngrama
        ,num_nivel 
FROM dbo.fn_ngrama('Variável do tipo TEXT contendo texto livremente digitado, e que será decomposto para formar os ngramas!', 3, 6)
</code></pre>

Em um banco relacional, normalmente o texto será uma coluna nalguma tabela, então pode-se utilizar a função através de um CURSOR que recupere sequencialmente o conteúdo coluna de cada linha, ou alternativamente a função pode ser eliminada, transformando seus comandos para que acessem diretamente a tabela, tratando a coluna que contém o texto.  

## Passos realizados no código:
+ Cada caráter do texto é validado em uma lista de caracteres e traduzido de acordo com o padrão especificado, portanto se for uma letra, será convertida para maiúscula, e terá a acentuação removida;
+ Depois são descartadas as palavras de ligação (_Stop Words_);
+ O passo seguinte é registrar a palavra, numerando a sequencia em que aparece;
+ Por fim são listadas as palavras sequenciais, a partir dos parametros solicitados.

### Observações:
- Normalmente a remoção de acentos é uma boa prática, por evitar que palavras deixadas sem acento por engano, ou acentuadas de maneira incorreta, não sejam consideradas distintas, das palavras corretamente grafadas. No entanto esta atitude pode ter um efeito negativo, por exemplo, as palavras *Maçã* (fruta), *Maça* (arma) e *Maca* (de hospital), tem sentidos muito diferentes, mas a remoção dos acentos igualaria o significado de todas;
- Uma opção comum no tratamento de palavras, é aplicar a técnica de stemming, que consiste em cortar o final das palavras, para reduzir suas possíveis flexões. Particularmente não gosto muito dessa técnica para a língua portuguesa, e ela não é contemplada no algoritmo acima;
- Uma outra técnica, mais elaborada, chamada de *Lemmatização* consiste na análise morfológica da palavra, para retornar a palavra à sua forma básica. Está técnica também não foi aplica no programa.
