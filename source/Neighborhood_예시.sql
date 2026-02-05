SELECT * FROM train;

# [MADE IN AI]
SELECT @global_avg := AVG(saleprice) FROM train;
WITH stats AS ( 
  SELECT Neighborhood, AVG(saleprice) avg_price 
  FROM train GROUP BY Neighborhood 
)
SELECT 
  Neighborhood, 
  ROUND(avg_price,-1) 평균가, 
  ROUND(avg_price - g.global_avg, 0) as 평균_차이, 
  CONCAT(ROUND(100*(avg_price/g.global_avg-1)-1),'%') 프리미엄율, 
  # (윈도우 함수 행의 백분위 수를 계산)
  ROUND(100 - PERCENT_RANK() OVER (ORDER BY avg_price DESC) * 100) as 지역_프리미엄_점수
  # (윈도우 함수)
  , NTILE(4) OVER(ORDER BY avg_price DESC) 사분위 
# stats -> WITH stats
FROM stats, (SELECT AVG(avg_price) global_avg FROM stats) g;

WITH neighborhood_stats AS (
  SELECT 
    h.Id,
    h.Neighborhood,
    h.saleprice,
    h.OverallQual,
    h.GarageArea,
    h.TotalBsmtSF,
    -- 동네 평균 (다른 윈도우)
    AVG(h.saleprice) OVER (PARTITION BY h.Neighborhood) as 동네평균,
    -- 전체 백분위 (다른 윈도우)
    PERCENT_RANK() OVER (ORDER BY h.saleprice) * 100 as 전체백분위
  FROM train h
)
SELECT * FROM neighborhood_stats;
