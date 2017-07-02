-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Este código T-SQL, foi escrito para o MS-SQL Server 2016
-------------------------------------------------------------------------------------------------------------------------------------------------------------

PRINT 'CRIAÇÃO DE TABELA COM PALAVRAS DESCARTÁVEIS (Stop Words) ' + CONVERT(CHAR(25), GETDATE(), 121)
--
-- A tabela poderia ser criada como uma variável "table", dentro da função, mas isso traria uma sobrecarga ao processo, que a cada execução deveria criar uma 
-- tabela e popula-la com as palavras de descarte. A criação como uma tabela natural, aumenta a performance, ao passo que a mesma já está preenchida.
CREATE TABLE tDescarte	TABLE	(txt_palavra	VARCHAR(50)
								,PRIMARY KEY (txt_palavra))
--
INSERT INTO tDescarte (txt_palavra)
VALUES	('ACASO'), ('AGORA'), ('AINDA'), ('ALEM'), ('ALGUEM'), ('ALGUM'), ('ALGUMA'), ('ALGUNS'), ('ALGUMAS'), ('ANTES'), ('APESAR'), ('APOS'), ('AQUELE'),
		('AQUELES'), ('AQUILO'), ('ASSIM'), ('AOS'), ('ATE'), ('ATRAS'), ('BAIXO'), ('BEM'), ('CASO'), ('CERTAMENTE'), ('CIMA'), ('COMECANDO'), ('COMO'), 
		('CONCLUINDO'), ('CONCLUSIVAMENTE'), ('CONFORME'), ('CONSEGUINTE'), ('CONSEQUENTE'), ('CONSEQUENTEMENTE'), ('CONSOANTE'), ('CONTANTO'), ('CONTUDO'),
		('CONTRARIAMENTE'), ('CORRETAMENTE'), ('DAI'), ('DAQUELE'), ('DAQUELES'), ('DAQUILO'), ('DAS'), ('DECERTO'), ('DEPOIS'), ('DESDE'), ('DESSA'), 
		('DESSE'), ('DESTA'), ('DESTE'), ('DISSO'), ('DOS'), ('EIS'), ('EMBORA'), ('ENFIM'), ('ENQUANTO'), ('ENTAO'), ('ENTRETANTO'), ('ESPECIFICAMENTE'), 
		('ESSA'), ('ESSE'), ('ESTA'), ('ESTE'), ('EVIDENTE'), ('EVIDENTEMENTE'), ('EXATAMENTE'), ('EXCLUSIVE'), ('FACTUALMENTE'), ('FINALIZANDO'), 
		('FINALMENTE'), ('FORA'), ('FUTURAMENTE'), ('IGUALMENTE'), ('INCLUSIVE'), ('INOBSTANTE'), ('INVES'), ('ISSO'), ('ISTO'), ('JAMAIS'), ('LOGO'), ('MAL'),
		('MAS'), ('MAIS'), ('MEIO'), ('MENOS'), ('MESMA'), ('MESMO'), ('MODO'), ('NAQUELA'), ('NAQUELAS'), ('NAQUELE'), ('NAQUELES'), ('NAQUILO'), ('NAS'), 
		('NEM'), ('NENHUM'), ('NENHUMA'), ('NINGUEM'), ('NOS'), ('OUTRO'), ('PARA'), ('PELA'), ('PELO'), ('POIS'), ('POR'), ('PORTANTO'), ('POSSIVELMENTE'), 
		('PRECISAMENTE'), ('PRIMEIRAMENTE'), ('PRIMEIRO'), ('PROVAVELMENTE'), ('QUANDO'), ('QUANTO'), ('QUE'), ('QUER'), ('SALVO'), ('SEGUNDO'), ('SEM'), 
		('SENAO'), ('SEQUER'), ('SINTETIZANDO'), ('SOB'), ('SOBRE'), ('TAL'), ('TALVEZ'), ('TAO'), ('TAMBEM'), ('TAMPOUCO'), ('TANTO'), ('TIRANTE'), 
		('TODAVIA'), ('ULTIMAMENTE'), ('ULTIMO'), ('UMA'), ('UMAS'), ('UNS'), ('VEDE'), ('VENTURA'), ('VERDADEIRAMENTE')
--
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--

PRINT 'CRIAÇÃO DE FUNÇÃO (fn_ngrama: Geração de n-Gramas) ' + CONVERT(CHAR(25), GETDATE(), 121) 
GO

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Descrição:	A função foi criada para retornar n-gramas de, no mínimo, nível 3, e no máximo, nível 6 
Chamada:	dbo.fn_ngrama(<Texto>, <Menor_NGrama>, <Maior_NGrama>)
Parametros:	<Texto> - Texto livre que será decomposto em n-gramas
			<Menor_NGrama> - Quantidade mínima de palavras consideradas para formação do n-grama (no mínimo 3)
			<Maior_NGrama> - Quantidade máxima de palavras consideraras para formação do n-grama (no máximo 6)
Exemplo:	SELECT * FROM dbo.fn_ngrama('Este é um texto de teste, para verificar a funcionalidade!!, 3, 3)
---------------------------------------------------------------------------------------------------------------------------------------------------------- */
CREATE FUNCTION fn_ngrama	(@cTexto	VARCHAR(8000)
							,@nNivelMin	TINYINT			-- 3, 4, 5 ou 6 (menor ou igual a Nível Máximo)
							,@nNivelMax	TINYINT)		-- 3, 4, 5 ou 6 (maior ou igual a Nível Mínimo)
RETURNS @tNGrama TABLE	
					(num_sequencia		INT IDENTITY(1,1)
					,txt_ngrama			VARCHAR(500)
					,num_nivel			TINYINT)			-- 3..6

AS
BEGIN
	DECLARE @nTamanho		SMALLINT
			,@nPosicao		SMALLINT
			,@nSequencia	SMALLINT
			,@nIndice		SMALLINT
			,@cPalavra		VARCHAR(50)
			,@cCarater		CHAR(1)
			,@cLetras		CHAR(50)
			,@cSemAcento	CHAR(50)
	--
	DECLARE @tPalavra		TABLE	(txt_palavra	VARCHAR(50)
									,num_sequencia	SMALLINT
										,PRIMARY KEY (num_sequencia))
	--
	--
	SELECT	@nTamanho	= LEN(@cTexto)
			,@nPosicao	= 1
			,@nSequencia= 1
			,@cPalavra	= ''
			,@cLetras	='ABCDEFGHIJKLMNOPQRSTUVWXYZÂÊÎÔÛÁÉÍÓÚÃÕÀÈÌÒÙÄËÏÖÜÇÑ'
			,@cSemAcento='ABCDEFGHIJKLMNOPQRSTUVWXYZAEIOUAEIOUAOAEIOUAEIOUCN'

	-- Percorre cada posição do campo observacao
	WHILE (@nPosicao <= @nTamanho) BEGIN
		SELECT	@cCarater	= UPPER(SUBSTRING(@cTexto, @nPosicao, 1))
				,@nPosicao	= @nPosicao + 1
		--
		-- verfica se carater é uma letra ou se "quebra" a cadeia sendo analisada
		SET @nIndice = CHARINDEX(@cCarater, @cLetras, 1)
		IF @nIndice <> 0 BEGIN
			-- Letra
			SET @cPalavra = @cPalavra + SUBSTRING(@cSemAcento, @nIndice, 1)  -- remove o acento da letra
		END ELSE BEGIN
			IF LEN(@cPalavra) > 2 BEGIN    -- ignora vazios e sequencia de 2 letras
				IF NOT EXISTS (SELECT 1 FROM tDescarte  WHERE txt_palavra = @cPalavra) BEGIN
					-- Fecha palavra anterior
					INSERT INTO @tPalavra	(txt_palavra
											,num_sequencia)
					SELECT	@cPalavra
							,@nSequencia
					--
					SELECT	@nSequencia	= (@nSequencia + 1)
							,@nIndice	= 0
				END	-- IF NOT EXISTS ....
			END	-- IF LEN(@cPalavra) > 2
			--
			SET @cPalavra = ''
		END	-- @nIndice <> 0
		--
	END	-- WHILE
	--
	-- se houver ultima palavra, registra-a:
	IF LEN(@cPalavra) > 2 BEGIN  -- ignora vazios e sequencia de ate 2 letras
		IF NOT EXISTS (SELECT 1 FROM tDescarte WHERE txt_palavra = @cPalavra) BEGIN
			INSERT INTO @tPalavra	(txt_palavra
									,num_sequencia)
			SELECT	@cPalavra
					,@nSequencia
		END
	END
	--
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	IF (@nNivelMin = 3 AND @nNivelMax >= 3) BEGIN
		-- gera agrupamentos de três palavras
		INSERT INTO @tNGrama	(num_nivel
								,txt_ngrama)
		SELECT	3,
				pl1.txt_palavra +' '+ pl2.txt_palavra +' '+ pl3.txt_palavra
		FROM @tPalavra				pl1
			INNER JOIN @tPalavra	pl2	ON	pl2.num_sequencia	= (pl1.num_sequencia + 1)   -- pl2 representa a palavra seguinte a pl1
			INNER JOIN @tPalavra	pl3	ON	pl3.num_sequencia	= (pl2.num_sequencia + 1)   -- pl3 representa a palavra seguinte a pl2
	END
	--
	IF (@nNivelMin <= 4 AND @nNivelMax >= 4) BEGIN
		-- gera agrupamentos de quatro palavras
		INSERT INTO @tNGrama	(num_nivel
								,txt_ngrama)
		SELECT	4,
				pl1.txt_palavra +' '+ pl2.txt_palavra +' '+ pl3.txt_palavra +' '+ pl4.txt_palavra
		FROM @tPalavra				pl1
			INNER JOIN @tPalavra	pl2	ON	pl2.num_sequencia	= (pl1.num_sequencia + 1)   -- pl2 representa a palavra seguinte a pl1
			INNER JOIN @tPalavra	pl3	ON	pl3.num_sequencia	= (pl2.num_sequencia + 1)   -- pl3 representa a palavra seguinte a pl2
			INNER JOIN @tPalavra	pl4	ON	pl4.num_sequencia	= (pl3.num_sequencia + 1)   -- pl4 representa a palavra seguinte a pl3
	END
	--
	IF (@nNivelMin <= 5 AND @nNivelMax >= 5) BEGIN
		-- gera agrupamentos de quatro palavras
		INSERT INTO @tNGrama	(num_nivel
								,txt_ngrama)
		SELECT	5,
				pl1.txt_palavra +' '+ pl2.txt_palavra +' '+ pl3.txt_palavra +' '+ pl4.txt_palavra +' '+ pl5.txt_palavra
		FROM @tPalavra				pl1
			INNER JOIN @tPalavra	pl2	ON	pl2.num_sequencia	= (pl1.num_sequencia + 1)   -- pl2 representa a palavra seguinte a pl1
			INNER JOIN @tPalavra	pl3	ON	pl3.num_sequencia	= (pl2.num_sequencia + 1)   -- pl3 representa a palavra seguinte a pl2
			INNER JOIN @tPalavra	pl4	ON	pl4.num_sequencia	= (pl3.num_sequencia + 1)   -- pl4 representa a palavra seguinte a pl3
			INNER JOIN @tPalavra	pl5	ON	pl5.num_sequencia	= (pl4.num_sequencia + 1)   -- pl5 representa a palavra seguinte a pl4
	END
	--
	IF (@nNivelMin <= 6 AND @nNivelMax >= 6) BEGIN
		-- gera agrupamentos de quatro palavras
		INSERT INTO @tNGrama	(num_nivel
								,txt_ngrama)
		SELECT	6,
				pl1.txt_palavra +' '+ pl2.txt_palavra +' '+ pl3.txt_palavra +' '+ pl4.txt_palavra +' '+ pl5.txt_palavra +' '+ pl6.txt_palavra
		FROM @tPalavra				pl1
			INNER JOIN @tPalavra	pl2	ON	pl2.num_sequencia	= (pl1.num_sequencia + 1)   -- pl2 representa a palavra seguinte a pl1
			INNER JOIN @tPalavra	pl3	ON	pl3.num_sequencia	= (pl2.num_sequencia + 1)   -- pl3 representa a palavra seguinte a pl2
			INNER JOIN @tPalavra	pl4	ON	pl4.num_sequencia	= (pl3.num_sequencia + 1)   -- pl4 representa a palavra seguinte a pl3
			INNER JOIN @tPalavra	pl5	ON	pl5.num_sequencia	= (pl4.num_sequencia + 1)   -- pl5 representa a palavra seguinte a pl4
			INNER JOIN @tPalavra	pl5	ON	pl6.num_sequencia	= (pl5.num_sequencia + 1)   -- pl6 representa a palavra seguinte a pl5
	END
	RETURN
END
GO

