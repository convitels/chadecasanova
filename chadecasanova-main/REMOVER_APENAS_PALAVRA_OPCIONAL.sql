-- Remove apenas a palavra "(opcional)" dos três nomes solicitados.
-- Não exclui presentes nem altera links, categoria ou reservas.
UPDATE public.gifts
SET name = trim(regexp_replace(name, '\s*\(opcional\)', '', 'gi'))
WHERE name ~* '^(Aspirador de pó|Ferro de passar roupa|Tábua de passar roupa)\s*\(opcional\)$';
