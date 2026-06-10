-- saída a: quantos veículos dos grupos 2, 3 e 4 estão disponíveis para locação 
create view veiculos_234_disponiveis
as select a.grupo as grupo, 
	count(*) as qtde_disponivel
	from veiculos a 
where a.grupo in (2, 3, 4) and a.status_atual = "Disponivel" 
	group by a.grupo;

-- saída b: quais modelos tiveram o maior numero de locações nos últimos 12 meses
create view modelos_mais_locacoes
as select b.modelo as modelo_veiculo, 
	count(a.id_locacao) as locacoes_total 
	from locacoes a 
	inner join veiculos b on a.id_veiculo = b.id_veiculo 
where 
	a.data_retirada >= date_sub(curdate(), interval 12 month) 
	group by b.modelo order by count(a.id_locacao) desc;

-- saída c: quais clientes com mais de 60 anos do sexo masculino que realizaram mais contratos no ultimo ano
create view clientes_frequentes
as select
	c.nome as cliente,
	year(curdate())-year(c.data_nasc) as Idade,
	count(l.id_locacao) as alugueis
from clientes c
inner join locacoes l on l.id_cliente = c.id_cliente
where
	c.sexo = 'M'
	and year(curdate())-year(c.data_nasc) > 60
	and year(l.data_retirada) >= year(curdate())-1
group by c.id_cliente,c.nome,c.data_nasc
order by alugueis desc;

-- saída d: qual o faturamento total com locações nos anos de 2021, 2022, 2023, 2024 e 2025
create view faturamento_total
as select sum(valor_total) as soma_faturamento
	from pagamentos
where year(data_pagamento) between 2021 and 2025;

-- saida e: qual o tempo medio de permanencia (em dias) no qual os veiculos ficam locados antes da sua devolução
create view tempo_medio_locacao
as select
    round(avg(datediff(data_devolucao_real, data_retirada)),2) as tempo_medio_dias
	from locacoes
where data_devolucao_real is not null;

-- saída f: quantos e quais veículos estão com manutenção pendente ou revisão agendada nos próximos 15 dias
create view manutencoes_pendentes_proximas
as select
    v.id_veiculo,
    v.placa,
    v.modelo,
    m.tipo_manuntencao,
    m.status_manuntencao,
    m.data_proxima_revisao
	from manuntencoes m
	inner join veiculos v
    on m.id_veiculo = v.id_veiculo
where
    m.status_manuntencao = 'Pendente'
    or m.data_proxima_revisao between curdate() and date_add(curdate(), interval 15 day);
select
    count(*) as "Total de Veículos"
	from manuntencoes m
	inner join veiculos v
    on m.id_veiculo = v.id_veiculo
where
    m.status_manuntencao = 'Pendente'
    or m.data_proxima_revisao between curdate() and date_add(curdate(), interval 15 day);

-- saída g: quais locações foram devolvidas com atraso e quais multas foram aplicadas em 2025 e 2026
create view multas_aplicadas_2025_2026
as select
	a.data_retirada as retirada,
	a.data_devolucao_real as devolucao,
	a.data_devolucao_real - a.data_devolucao_prevista as atraso_dias,
	b.nome as cliente,
	b.cpf,
	c.custo_multas as multas
	from locacoes a
	inner join clientes b on a.id_cliente = b.id_cliente
	inner join pagamentos c on a.id_locacao = c.id_locacao
where
	a.status_locacao = "completa atrasada"
	and year(a.data_devolucao_real) between 2025 and 2026
order by a.data_devolucao_real;

-- saída h: qual é a quilometragem média percorrida por cada grupo de veículos durante a locação
create view km_media_grupo
as select
    distinct(a.grupo) as grupo,
    avg(b.km_final - b.km_inicial) as km_media
	from veiculos a
	inner join locacoes b on a.id_veiculo = b.id_veiculo
group by a.grupo
order by a.grupo;

-- saída i: quais filiais ou unidades possuem a maior taxa de locação de carros sedan e SUV em 2026
create view maior_locacao_suv_ou_sedan
as SELECT
f.nome AS filial_unidade,
COUNT(l.id_locacao) AS total_locacoes_sedan_suv
FROM filiais f
JOIN locacoes l ON f.id_filial = l.id_filial_retirada
JOIN veiculos v ON l.id_veiculo = v.id_veiculo
WHERE v.tipo IN ('Sedan', 'SUV') AND YEAR(l.data_retirada) = 2026
GROUP BY f.id_filial, f.nome
ORDER BY total_locacoes_sedan_suv DESC; 

-- saida j: quantos e quais clientes possuem reservas ativas e quais são veículos que estão vinculados a essas reservas?
SELECT
c.nome AS cliente_nome,
c.cpf, v.modelo AS veiculo_modelo,
v.placa, l.status_locacao,
l.data_reserva
FROM clientes c
JOIN locacoes l ON c.id_cliente = l.id_cliente
JOIN veiculos v ON l.id_veiculo = v.id_veiculo
WHERE l.status_locacao IN ('ativa', 'reservada')
ORDER BY l.data_reserva DESC; 

