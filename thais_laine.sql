-- 1 Crie uma função para retornar o número de vendedores cadastrados 

CREATE OR REPLACE function num_vendedor() RETURNS TEXT AS
$$
begin
	return count(*) FROM vendedor;

end;
$$
language PLPGSQL 


SELECT num_vendedor();


-- 2 Elabore uma função para retornar a quantidade de pedidos que um determinado
--vendedor participou

CREATE OR REPLACE  FUNCTION qtd_pedido(qtdpedido INTEGER) RETURNS INTEGER AS $$ 

    DECLARE qtd INTEGER; 

BEGIN 

    SELECT count(num_pedido) 

        FROM pedido 

        WHERE codigo_vendedor =  qtdpedido

        INTO qtd; 

        RETURN qtd; 

END 

$$ LANGUAGE PLPGSQL; 


SELECT qtd_pedido(11); 


--3 Faça uma função que mostre os vendedores que atenderam um cliente, cujo seu
--nome é passado por parâmetro.

CREATE OR REPLACE  FUNCTION qtd_vendedor(cliente text) RETURNS table(nomeVendedor varchar) AS $$ 
BEGIN 

    return query(SELECT v.nome_vendedor

		FROM vendedor v 

		INNER JOIN pedido p ON v.codigo_vendedor = p.codigo_vendedor
		INNER JOIN cliente c ON c.codigo_cliente = p.codigo_cliente

		WHERE nome_cliente = cliente);
		RETURN;
	
END 

$$ LANGUAGE PLPGSQL; 

SELECT qtd_vendedor('Ana'); 


--4 Crie uma função que retorne todos os códigos, nomes e unidades dos produtos cadastrados



CREATE OR REPLACE FUNCTION prod_cadastrados()RETURNS TABLE (codigo INTEGER ,descricao VARCHAR ,unid CHAR) AS $$
BEGIN
	return query SELECT codigo_produto,descricao_produto,unidade FROM produto;
	
	
END;
$$ language PLPGSQL;

SELECT prod_cadastrados();


--5.  Faça  uma  função  que  mostre  o  maior,  o  menor  e  a  média  de  salário  dos 
--vendedores  que  atenderam  uma  determinada  cliente  cujo  nome  do  cliente  e 
--faixa de comissão do vendedor é passado por parâmetro. 


CREATE OR REPLACE  FUNCTION num_vendedor(clie VARCHAR, faixa CHAR)
		RETURNS TABLE (salario_max NUMERIC , salario_min NUMERIC, salario_med NUMERIC) AS $$ 
BEGIN
		return query 
		SELECT max(salario_fixo), min(salario_fixo), avg(salario_fixo)
		FROM vendedor v 
		INNER JOIN pedido p ON v.codigo_vendedor = p.codigo_vendedor
		INNER JOIN cliente c ON c.codigo_cliente = p.codigo_cliente
		WHERE c.nome_cliente = clie AND v.faixa_comissao = faixa;
    		RETURN;
END;
$$ LANGUAGE PLPGSQL; 


SELECT * FROM num_vendedor('Ana', 'C');
SELECT * FROM VENDEDOR


--6. Desenvolva uma função que mostre descrição do produto, a quantidade de
--produtos vendidos, o Preço Unitário e o total (quantidade*Preço Unitário) de
--um determinado Pedido
CREATE OR REPLACE  FUNCTION inf_produto(num INTEGER)
		RETURNS TABLE (descricao VARCHAR , quantidade NUMERIC, preco_unit NUMERIC, total NUMERIC) AS $$ 
BEGIN
		return query 
		SELECT p.descricao_produto AS " Produto ", i.quantidade AS " Quantidade ", val_unit AS "Valor Unitário", (p.val_unit * SUM(i.quantidade)) AS "Total"  FROM  produto p 
		INNER JOIN item_do_pedido i ON p.codigo_produto = i.codigo_produto
		WHERE num_pedido = num
		GROUP BY p.descricao_produto,i.quantidade, p.val_unit
		ORDER BY (p.val_unit * SUM(i.quantidade));
    		RETURN;
END;
$$ LANGUAGE PLPGSQL; 

SELECT * FROM inf_produto(121);

 --7. Desenvolva uma função que retorne a soma de uma venda de um determinado
 --pedido.

 CREATE OR REPLACE  FUNCTION soma_venda(det_pedido INTEGER)
		RETURNS TABLE (somatoria NUMERIC)  AS $$ 
BEGIN
		return query 
		SELECT SUM(quantidade) FROM item_do_pedido WHERE
		num_pedido = det_pedido;
    		RETURN;
END;
$$ LANGUAGE PLPGSQL; 


SELECT * FROM soma_venda(148);

--8.  Faça  uma  função  que  retorne  a  quantidade  de  pedidos  que  cada  vendedor 
--participou. 

 CREATE OR REPLACE  FUNCTION qtd_pedido_vendedor()
		RETURNS TABLE (total_cada_vend BIGINT) AS $$ 
BEGIN
		return query 
		SELECT count(num_pedido) AS "Quantidade de pedido de cada vendedor" FROM pedido
		GROUP BY codigo_vendedor;
    		RETURN;
END;
$$ LANGUAGE PLPGSQL; 

SELECT * FROM qtd_pedido_vendedor();


--9.  Crie uma função que retorne o código e o nome dos clientes, cujo código do 
--vendedor,  o  estado  que  reside  o  cliente  e  o  prazo  de  entrega  do  pedido  seja 
--passado por parâmetro. 

CREATE OR REPLACE  FUNCTION codi_nome(codigo INTEGER, estado CHAR, prazo INTEGER)
		RETURNS TABLE (codigo_clie INTEGER , nome VARCHAR) AS $$ 
BEGIN
		return query 
		SELECT c.codigo_cliente, c.nome_cliente
		FROM cliente c 
		INNER JOIN pedido p ON c.codigo_cliente = p.codigo_cliente
		INNER JOIN vendedor v ON p.codigo_vendedor = v.codigo_vendedor
		WHERE v.codigo_vendedor = codigo AND c.uf = estado AND prazo_entrega = prazo;
    		RETURN;
END;
$$ LANGUAGE PLPGSQL; 


SELECT * FROM codi_nome(11,'RJ',20);

--10. Desenvolva uma trigger.  

 SELECT * FROM vendedor


CREATE OR REPLACE FUNCTION inserindo_vendedor()
		RETURNS trigger AS $$
  BEGIN
		INSERT INTO vendedor (codigo_vendedor, nome_vendedor,salario_fixo,faixa_comissao) values (24, 'Mariano', 1224.00, 'A');
		RETURN NEW;
  END;
  $$ LANGUAGE plpgsql; 


 CREATE TRIGGER inserindo_cliente
  AFTER INSERT ON cliente
  FOR EACH ROW
  EXECUTE PROCEDURE inserindo_vendedor();
