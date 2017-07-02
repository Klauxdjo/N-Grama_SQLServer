# N-Grama_SQLServer
Função T-SQL para extrair n-gramas de nível 3 até 6 a partir de um campo texto

Hoje temos uma excelente gama de alternativas para extrair n-gramas de um texto, desde ferramentas sem código, como por exemplo, o Rapid Miner, até bibliotecas sofisticadas que permitem fazê-lo a partir de, praticamente, qualquer linguagem (com destaque às bibliotecas em Python).
Apesar disso, pode ser interessante fazer essa extração diretamente no SQL-Server (ou, com alguma adaptação, em qualquer outro banco relacional). Com o intuito de facilitar quem quiser se aventurar por esse caminho, segue uma implementação funcional que, recebido um texto como parametro, retorna uma tabela com todos os n-gramas formados (pode-se escolher o nível do n-grama a partir de 3 até 6).

Exemplo de uso:
<pre><code>
SELECT	txt_ngrama
        ,num_nivel 
FROM dbo.fn_ngrama('Variável do tipo TEXT contendo texto livremente digitado, e que será decomposto para formar os ngramas!', 3, 6)
</code></pre>
