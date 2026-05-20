SELECT * FROM dbo.ProductionHall ph
INNER JOIN dbo.Machinery m  ON ph.ProductionHallId = m.ProductionHallId
ORDER BY ph.ProductionHallId, m.MachineryId;

-- To export to XML
SELECT * FROM dbo.ProductionHall ph
INNER JOIN dbo.Machinery m  ON ph.ProductionHallId = m.ProductionHallId
ORDER BY ph.ProductionHallId, m.MachineryId;
FOR XML PATH('ProductionHall')