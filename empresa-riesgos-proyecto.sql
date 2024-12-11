-- Creación de base de datos
CREATE DATABASE EmpresaRiesgos;
GO

USE EmpresaRiesgos;
GO

-- Tabla de Empresas
CREATE TABLE Empresas (
    EmpresaID INT PRIMARY KEY IDENTITY(1,1),
    NombreEmpresa NVARCHAR(200) NOT NULL,
    SectorIndustrial NVARCHAR(100) NOT NULL,
    FechaFundacion DATE,
    PaisOrigen NVARCHAR(100),
    TipoEmpresa NVARCHAR(50),
    CapitalSocial DECIMAL(18,2),
    SitioWeb NVARCHAR(255),
    CorreoContacto NVARCHAR(255),
    EstadoActivo BIT DEFAULT 1
);

-- Tabla de Indicadores Financieros
CREATE TABLE IndicadoresFinancieros (
    IndicadorID INT PRIMARY KEY IDENTITY(1,1),
    EmpresaID INT,
    Año INT,
    Ingresos DECIMAL(18,2),
    Utilidades DECIMAL(18,2),
    EBITDA DECIMAL(18,2),
    MargenUtilidad DECIMAL(5,2),
    RentabilidadCapital DECIMAL(5,2),
    Endeudamiento DECIMAL(5,2),
    LiquidezGeneral DECIMAL(5,2),
    FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID)
);

-- Tabla de Categorías de Riesgo
CREATE TABLE CategoriaRiesgo (
    CategoriaRiesgoID INT PRIMARY KEY IDENTITY(1,1),
    NombreCategoria NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500)
);

-- Tabla de Evaluación de Riesgos
CREATE TABLE EvaluacionRiesgos (
    EvaluacionID INT PRIMARY KEY IDENTITY(1,1),
    EmpresaID INT,
    CategoriaRiesgoID INT,
    NivelRiesgo NVARCHAR(50) NOT NULL, -- Bajo, Medio, Alto, Crítico
    ProbabilidadOcurrencia DECIMAL(5,2),
    ImpactoEconomico DECIMAL(18,2),
    FechaEvaluacion DATE DEFAULT GETDATE(),
    DetallesRiesgo NVARCHAR(MAX),
    AccionesRecomendadas NVARCHAR(MAX),
    FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID),
    FOREIGN KEY (CategoriaRiesgoID) REFERENCES CategoriaRiesgo(CategoriaRiesgoID)
);

-- Tabla de Análisis de Riesgos Históricos
CREATE TABLE HistoricoRiesgos (
    HistoricoID INT PRIMARY KEY IDENTITY(1,1),
    EmpresaID INT,
    CategoriaRiesgoID INT,
    FechaIncidente DATE,
    PerdidaEconomica DECIMAL(18,2),
    Impacto NVARCHAR(500),
    AccionesCorrecticas NVARCHAR(MAX),
    FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID),
    FOREIGN KEY (CategoriaRiesgoID) REFERENCES CategoriaRiesgo(CategoriaRiesgoID)
);

-- Inserción de Categorías de Riesgo
INSERT INTO CategoriaRiesgo (NombreCategoria, Descripcion) VALUES 
('Riesgo Financiero', 'Riesgos relacionados con la situación económica y financiera'),
('Riesgo Operativo', 'Riesgos en los procesos internos y operaciones'),
('Riesgo de Mercado', 'Riesgos asociados a cambios en el mercado y la competencia'),
('Riesgo Legal', 'Riesgos por cambios regulatorios o legales'),
('Riesgo Reputacional', 'Riesgos que pueden afectar la imagen de la empresa');

-- Procedimiento para Calcular Nivel de Riesgo
CREATE PROCEDURE CalcularNivelRiesgoEmpresa
    @EmpresaID INT
AS
BEGIN
    SELECT 
        e.NombreEmpresa,
        er.NivelRiesgo,
        AVG(er.ProbabilidadOcurrencia) AS ProbabilidadPromedio,
        SUM(er.ImpactoEconomico) AS ImpactoEconomicoTotal
    FROM 
        Empresas e
    JOIN 
        EvaluacionRiesgos er ON e.EmpresaID = er.EmpresaID
    WHERE 
        e.EmpresaID = @EmpresaID
    GROUP BY 
        e.NombreEmpresa, er.NivelRiesgo
END;

-- Vista de Resumen de Riesgos
CREATE VIEW ResumenRiesgosEmpresas AS
SELECT 
    e.NombreEmpresa,
    e.SectorIndustrial,
    COUNT(er.EvaluacionID) AS CantidadRiesgos,
    SUM(CASE WHEN er.NivelRiesgo = 'Alto' THEN 1 ELSE 0 END) AS RiesgosAltos,
    AVG(er.ProbabilidadOcurrencia) AS ProbabilidadPromedioRiesgos,
    SUM(er.ImpactoEconomico) AS ImpactoEconomicoTotal
FROM 
    Empresas e
LEFT JOIN 
    EvaluacionRiesgos er ON e.EmpresaID = er.EmpresaID
GROUP BY 
    e.NombreEmpresa, e.SectorIndustrial;

-- Índices para optimización
CREATE NONCLUSTERED INDEX IDX_Empresas_Sector 
ON Empresas(SectorIndustrial);

CREATE NONCLUSTERED INDEX IDX_EvaluacionRiesgos_Nivel 
ON EvaluacionRiesgos(NivelRiesgo);
