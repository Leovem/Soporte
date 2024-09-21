USE MASTER;
BEGIN TRY
    -- Verificar si la base de datos existe
    IF DB_ID('AirlineDB') IS NOT NULL
    BEGIN
        -- Establecer la base de datos en modo de usuario único y cerrar todas las conexiones activas
        ALTER DATABASE AirlineDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        PRINT 'Conexiones activas cerradas.';

        -- Intentar eliminar la base de datos
        DROP DATABASE AirlineDB;
        PRINT 'Base de datos AirlineDB eliminada.';
    END
END TRY
BEGIN CATCH
    -- Capturar el error y verificar si es el error 3702
    IF ERROR_NUMBER() = 3702
    BEGIN
        PRINT 'No se puede quitar la base de datos ''AirlineDB''; está en uso.';
        -- Puedes agregar lógica adicional aquí si deseas reintentar o manejar el error de otra forma
    END
    ELSE
    BEGIN
        -- Si ocurre un error diferente, mostrar el mensaje de error estándar
        PRINT 'Error al intentar eliminar la base de datos: ' + ERROR_MESSAGE();
    END
END CATCH
GO

-- Crear la base de datos si no existe
IF DB_ID('AirlineDB') IS NULL
BEGIN
    CREATE DATABASE AirlineDB;
    PRINT 'Base de datos AirlineDB creada.';
END
GO

-- Usar la base de datos recién creada
USE AirlineDB;
GO

--///////////////////////////////////////////////////
-- Creación de la tabla Plane_Model (Modelo_Avion)
IF OBJECT_ID('Plane_Model', 'U') IS NULL 
BEGIN
	CREATE TABLE Plane_Model (
		Id VARCHAR(50) PRIMARY KEY,
		Description VARCHAR(255),
		Graphic VARCHAR(255)
	);
	PRINT 'Tabla Plane_Model Creada.';
END
GO

-- Creación de la tabla Airplane (Avion)
IF OBJECT_ID('Airplane', 'U') IS NULL 
BEGIN
	CREATE TABLE Airplane (
		RegistrationNumber VARCHAR(50) PRIMARY KEY,
		BeginOfOperation DATE NOT NULL,
		Status VARCHAR(50) check (Status in ('Active', 'Maintenance')),
		PlaneModel_Id VARCHAR(50) NULL,
		FOREIGN KEY (PlaneModel_Id) REFERENCES Plane_Model(Id) ON DELETE SET NULL,
	);
	PRINT 'Tabla Airplane creada.';
END
GO
-- Índice en la columna PlaneModel_Id y Pilot_ID
CREATE INDEX IDX_Airplane_PlaneModel_Id ON Airplane(PlaneModel_Id);
GO

-- Creación de la tabla Seat (Asiento)
IF OBJECT_ID('Seat', 'U') IS NULL 
BEGIN
	CREATE TABLE Seat (
		IdSeat INT PRIMARY KEY,
		Size VARCHAR(50),
		Number VARCHAR(50),
		Location VARCHAR(255),
		PlaneModel_Id VARCHAR(50),
		FOREIGN KEY (PlaneModel_Id) REFERENCES Plane_Model(Id) ON DELETE CASCADE,
	);
	PRINT 'Tabla Seat creada.';
END
GO
-- Índice en la columna PlaneModel_Id
CREATE INDEX IDX_Seat_PlaneModel_Id ON Seat(PlaneModel_Id);
GO

--////////////////////////////////////////////
-- Creación de la tabla Country (Pais)
IF OBJECT_ID('Country', 'U') IS NULL 
BEGIN
	CREATE TABLE Country (
		IdCountry INT PRIMARY KEY,
		NameC VARCHAR(255) NOT NULL,
		Detail VARCHAR(255),
	);
	PRINT 'Tabla Country creada.';
END
GO

-- Creación de la tabla City (Ciudad)
IF OBJECT_ID('City', 'U') IS NULL 
BEGIN
	CREATE TABLE City (
		IdCity INT PRIMARY KEY,
		Name VARCHAR(255) NOT NULL,
		IdCountry INT,
		FOREIGN KEY (IdCountry) REFERENCES Country(IdCountry) ON DELETE CASCADE
	);
	PRINT 'Tabla City creada.';
END
GO
-- Índice en la columna IdCountry
CREATE INDEX IDX_City_IdCountry ON City(IdCountry);
GO

-- Creación de la tabla Airport (Aeropuerto)
IF OBJECT_ID('Airport', 'U') IS NULL 
BEGIN
	CREATE TABLE Airport (
		Name VARCHAR(255) PRIMARY KEY,
		IdCity INT,
		FOREIGN KEY (IdCity) REFERENCES City(IdCity) ON DELETE SET NULL
	);
	PRINT 'Tabla Airport creada.';
END
GO
-- Índice en la columna IdCity
CREATE INDEX IDX_Airport_IdCity ON Airport(IdCity);
GO

-- Creación de la tabla Airline (        )
IF OBJECT_ID('Airline', 'U') IS NULL 
BEGIN
	CREATE TABLE Airline (
		NIT INT PRIMARY KEY,
		Name VARCHAR(50),
		Acronym VARCHAR(10),
	);
	PRINT 'Tabla Airline creada.';
END
GO

-- Creación de la tabla Flight_Number (Num_Vuelo)
IF OBJECT_ID('Flight_Number', 'U') IS NULL 
BEGIN
	CREATE TABLE Flight_Number (
		IdFlightNumber INT PRIMARY KEY,
		DepartureTime DATETIME NOT NULL,
		Description VARCHAR(255),
		Type VARCHAR(50) check (Type in ('First Class','Business Class','Economy Class')),
		Start_Airport VARCHAR(255),
		Goal_Airport VARCHAR(255),
		PlaneModel_Id VARCHAR(50),
		NIT_Airline int,
		FOREIGN KEY (Start_Airport) REFERENCES Airport(Name) ON DELETE NO ACTION,
		FOREIGN KEY (Goal_Airport) REFERENCES Airport(Name) ON DELETE NO ACTION,
		FOREIGN KEY (PlaneModel_Id) REFERENCES Plane_Model(Id) ON DELETE SET NULL,
		FOREIGN KEY (NIT_Airline) REFERENCES Airline(NIT) ON DELETE NO ACTION,
	);
	PRINT 'Tabla Flight_Number creada.';
END
GO
-- Índices en las columnas Start_Airport, Goal_Airport y PlaneModel_Id
CREATE INDEX IDX_Flight_Number_Start_Airport ON Flight_Number(Start_Airport);
CREATE INDEX IDX_Flight_Number_Goal_Airport ON Flight_Number(Goal_Airport);
CREATE INDEX IDX_Flight_Number_PlaneModel_Id ON Flight_Number(PlaneModel_Id);
CREATE INDEX IDX_Flight_Number_NIT_Airline ON Flight_Number(NIT_Airline);
GO

--///////////////////////////////////////////
--/////////////////////////////////////////////////
-- Creación de la tabla Person (Persona)
IF OBJECT_ID('Person', 'U') IS NULL 
BEGIN
	CREATE TABLE Person (
		Id_Person INT PRIMARY KEY,
		Name varchar(50),
		DateOfBirth date check (DateOfBirth <= getdate()),
		Profession varchar(30),
		Id_Customer int,			--Customer
		Num_License int,			--Aircrew
		Type_Person Char(5) check (Type_Person in ('C', 'TCP', 'P')),
	);
	PRINT 'Tabla Person creada.';
END
GO

--///////////////////////////////////////////////


-- Creación de la tabla Frequent_Flyer_Card (Tarjeta_Viajero_Frecuente)
IF OBJECT_ID('Frequent_Flyer_Card', 'U') IS NULL 
BEGIN
	CREATE TABLE Frequent_Flyer_Card (
		FFC_Number NVARCHAR(50) PRIMARY KEY,
		Miles int check (Miles>=0),
		Id_Person INT,
		FOREIGN KEY (Id_Person) REFERENCES Person(Id_Person) ON DELETE CASCADE
	);
	PRINT 'Tabla Frequent_Flyer_Card creada.';
END
GO
-- Índice en la columna IdCustomer
CREATE INDEX IDX_Frequent_Flyer_Card_Id_Person ON Frequent_Flyer_Card(Id_Person);
GO

--/////////////////////////////////////////////////////
-- Creación de la tabla Pay (Pago)
IF OBJECT_ID('Pay', 'U') IS NULL 
BEGIN
	CREATE TABLE Pay (
		Cod_Pay INT PRIMARY KEY,
		Date Date check (Date <= getdate()),
		Time Time,
		Money Decimal(5,2),
		Total_Amount Decimal(5,2),
	);
	PRINT 'Tabla Pay creada.';
END
GO

-- Creación de la tabla Type_Pay (Tipo de Pago)
IF OBJECT_ID('Type_Pay', 'U') IS NULL 
BEGIN
	CREATE TABLE Type_Pay (
		ID_TP INT PRIMARY KEY,
		Idd_Cash int,							--Cash
		Card_Number varchar(30),				--Credit_Card
		Name_Bank varchar(30),
		Account_Number varchar(50),				--Bank_Transfer
		Voucher varchar(30),
		Type_Pay Char(3),
		Cod_Pay int,
		FOREIGN KEY (Cod_Pay) REFERENCES Pay(Cod_Pay) ON DELETE CASCADE,
	);
	PRINT 'Tabla Type_Pay creada.';
END
GO
-- Índice en la columna Cod_Pay
CREATE INDEX IDX_Type_Pay_Cod_Pay ON Type_Pay(Cod_Pay);
GO

-- Creación de la tabla Booking
IF OBJECT_ID('Booking', 'U') IS NULL 
BEGIN
	CREATE TABLE Booking (
		Id_Booking INT PRIMARY KEY,
		Price Decimal(5,2),
		Date Date check (Date <= getdate()),
		Time Time not null,
		State varchar(50),
		Id_Person int,
		Cod_Pay int,
		FOREIGN KEY (Id_Person) REFERENCES Person(Id_Person) ON DELETE CASCADE,
		FOREIGN KEY (Cod_Pay) REFERENCES Pay(Cod_Pay) ON DELETE CASCADE,
	);
	PRINT 'Tabla Booking creada.';
END
GO
-- Índice en la columna Id_Customer y Cod_Pay
CREATE INDEX IDX_Booking_Id_Person ON Booking(Id_Person);
CREATE INDEX IDX_Booking_Cod_Pay ON Booking(Cod_Pay);
GO

-- Creación de la tabla Ticket (Boleto)
IF OBJECT_ID('Ticket', 'U') IS NULL 
BEGIN
	CREATE TABLE Ticket (
		TicketingCode VARCHAR(50) PRIMARY KEY,
		Number VARCHAR(50),
		Id_Booking INT,
		Id_Person int,
		Cod_Pay int,
		FOREIGN KEY (Id_Booking) REFERENCES Booking(Id_Booking) ON DELETE CASCADE,
		FOREIGN KEY (Id_Person) REFERENCES Person(Id_Person) ON DELETE NO ACTION,
		FOREIGN KEY (Cod_Pay) REFERENCES Pay(Cod_Pay) ON DELETE NO ACTION,
	);
	PRINT 'Tabla Ticket creada.';
END
GO
-- Índice en la columna Id_Booking y Id_Person y Cod_Pay
CREATE INDEX IDX_Ticket_Id_Booking ON Ticket(Id_Booking);
CREATE INDEX IDX_Ticket_Id_Person ON Ticket(Id_Person);
CREATE INDEX IDX_Ticket_Cod_Pay ON Ticket(Cod_Pay);
GO

-- Creación de la tabla Document (Documento)
IF OBJECT_ID('Document', 'U') IS NULL 
BEGIN
	CREATE TABLE Document (
		Id_Document INT not null PRIMARY KEY,
		Nacionality varchar(50),
		Date_of_Birth date check (Date_of_Birth <= getdate()),
		Gender char(1) not null,
		Nro_Passport int,			--Passport
		ID_Identity_Card int,		--Identity_Card
		Tipo_Document char(5),
		TicketingCode varchar(50),
		FOREIGN KEY (TicketingCode) REFERENCES Ticket(TicketingCode) ON DELETE CASCADE,
	);
	PRINT 'Tabla Document creada.';
END
GO
-- Índice en la columna TicketingCode
CREATE INDEX IDX_Document_TicketingCode ON Document(TicketingCode);
GO

-- Creación de la tabla Flight (Vuelo)
IF OBJECT_ID('Flight', 'U') IS NULL 
BEGIN
	CREATE TABLE Flight (
		IdFlight INT PRIMARY KEY,
		BoardingTime DATETIME,
		FlightDate DATE,
		Gate VARCHAR(50),
		CheckInCounter VARCHAR(50),
		IdFlightNumber INT,
		FOREIGN KEY (IdFlightNumber) REFERENCES Flight_Number(IdFlightNumber) ON DELETE CASCADE
	);
	PRINT 'Tabla Flight creada.';
END
GO
-- Índice en la columna IdFlightNumber
CREATE INDEX IDX_Flight_IdFlightNumber ON Flight(IdFlightNumber);
GO

-- Creación de la tabla Schedule (Horario)
IF OBJECT_ID('Schedule', 'U') IS NULL 
BEGIN
	CREATE TABLE Schedule (
		Id INT PRIMARY KEY,
		Shift Varchar(30),
		Fecha DATETIME,
		Hora DATE,
		State VARCHAR(50),
		Id_Person int,
		IdFlight int,
		FOREIGN KEY (Id_Person) REFERENCES Person(Id_Person) ON DELETE CASCADE,
		FOREIGN KEY (IdFlight) REFERENCES Flight(IdFlight) ON DELETE CASCADE
	);
	PRINT 'Tabla Schedule creada.';
END
GO
-- Índice en la columna Id_Person y IdFlight
CREATE INDEX IDX_Schedule_Id_Person ON Schedule(Id_Person);
CREATE INDEX IDX_Schedule_IdFlight ON Schedule(IdFlight);
GO

-- Creación de la tabla Available_Seat
IF OBJECT_ID('Available_Seat', 'U') IS NULL 
BEGIN
	CREATE TABLE Available_Seat (
		IdAvailableSeat INT PRIMARY KEY,
		IdFlight INT,
		IdSeat INT,
		FOREIGN KEY (IdFlight) REFERENCES Flight(IdFlight) ON DELETE CASCADE,
		FOREIGN KEY (IdSeat) REFERENCES Seat(IdSeat) ON DELETE CASCADE
	);
	PRINT 'Tabla Available_Seat creada.';
END
GO
-- Índices en las columnas IdFlight y IdSeat
CREATE INDEX IDX_Available_Seat_IdFlight ON Available_Seat(IdFlight);
CREATE INDEX IDX_Available_Seat_IdSeat ON Available_Seat(IdSeat);
GO

-- Creación de la tabla Flight_Scale (Escala de Vuelo)
IF OBJECT_ID('Flight_Scale', 'U') IS NULL 
BEGIN
	CREATE TABLE Flight_Scale (
		ID_Flight_Scale INT PRIMARY KEY,
		Country VARCHAR(50),
		City VARCHAR(50),
		DateFS Date check (DateFS <= getdate()),
		Time Time,
		Start_Airport VARCHAR(255),
		Goal_Airport VARCHAR(255),
		FOREIGN KEY (Start_Airport) REFERENCES Airport(Name) ON DELETE NO ACTION,
		FOREIGN KEY (Goal_Airport) REFERENCES Airport(Name) ON DELETE NO ACTION,
	);
	PRINT 'Tabla Flight_Scale creada.';
END
GO
-- Índice en la columna IdFlightNumber
CREATE INDEX IDX_Flight_Scale_Start_Airport ON Flight_Scale(Start_Airport);
CREATE INDEX IDX_Flight_Scale_Goal_Airport ON Flight_Scale(Goal_Airport);
GO

--////////////////////////////////////////////
-- Creación de la tabla Cheking (Comprovante)
IF OBJECT_ID('Cheking', 'U') IS NULL 
BEGIN
	CREATE TABLE Cheking (
		Cod_Cheking INT PRIMARY KEY,
		Date Date check (Date <= getdate()),
		Time time,
	);
	PRINT 'Tabla Cheking creada.';
END
GO

-- Creación de la tabla Coupon (Cupon)
IF OBJECT_ID('Coupon', 'U') IS NULL 
BEGIN
	CREATE TABLE Coupon (
		IdCoupon INT PRIMARY KEY,
		TicketingCode VARCHAR(50),
		ClassC varchar(20),
		Standby varchar(5) check (Standby in ('yes', 'not'))not null,
		MealCode VARCHAR(50),
		IdFlight INT,
		IdAvailableSeat INT,
		Cod_Cheking int,
		FOREIGN KEY (TicketingCode) REFERENCES Ticket(TicketingCode) ON DELETE CASCADE,
		FOREIGN KEY (IdFlight) REFERENCES Flight(IdFlight) ON DELETE NO ACTION,
		FOREIGN KEY (IdAvailableSeat) REFERENCES Available_Seat(IdAvailableSeat) ON DELETE NO ACTION,
		FOREIGN KEY (Cod_Cheking) REFERENCES Cheking(Cod_Cheking) ON DELETE NO ACTION
	);
	PRINT 'Tabla Coupon creada.';
END
GO
-- Índices en las columnas TicketingCode, IdFlight y IdAvailableSeat
CREATE INDEX IDX_Coupon_TicketingCode ON Coupon(TicketingCode);
CREATE INDEX IDX_Coupon_IdFlight ON Coupon(IdFlight);
CREATE INDEX IDX_Coupon_IdAvailableSeat ON Coupon(IdAvailableSeat);
CREATE INDEX IDX_Coupon_Cod_Chekingt ON Coupon(Cod_Cheking);
GO

-- Creación de la tabla Pieces_of_Luggage (Piezas de Equipaje)
IF OBJECT_ID('Pieces_of_Luggage', 'U') IS NULL 
BEGIN
	CREATE TABLE Pieces_of_Luggage (
		IdLuggage INT PRIMARY KEY,
		Number VARCHAR(50),
		Weight DECIMAL(5,2),
		IdCoupon INT,
		FOREIGN KEY (IdCoupon) REFERENCES Coupon(IdCoupon) ON DELETE CASCADE,
	);
	PRINT 'Tabla Pieces_of_Luggage creada.';
END
GO
-- Índice en la columna IdCoupon
CREATE INDEX IDX_Pieces_of_Luggage_IdCoupon ON Pieces_of_Luggage(IdCoupon);
GO


-- Creación de la tabla Reschedule
IF OBJECT_ID('Reschedule', 'U') IS NULL 
BEGIN
	CREATE TABLE Reschedule (
		Id_Reschedule INT PRIMARY KEY,
		Price int,
		Date Date check (Date <= getdate()),
		Time Time,
		Id_Booking int,
		FOREIGN KEY (Id_Booking) REFERENCES Booking(Id_Booking) ON DELETE CASCADE,
	);
	PRINT 'Tabla Reschedule creada.';
END
GO
-- Índice en la columna Id_Booking
CREATE INDEX IDX_Reschedule_Id_Booking ON Reschedule(Id_Booking);
GO

-- Creación de la tabla Canceled
IF OBJECT_ID('Canceled', 'U') IS NULL 
BEGIN
	CREATE TABLE Canceled (
		Id_Canceled INT PRIMARY KEY,
		Date Date check (Date <= getdate()),
		Time Time,
		Price Decimal(5,2),
		Id_Booking int,
		FOREIGN KEY (Id_Booking) REFERENCES Booking(Id_Booking) ON DELETE CASCADE,
	);
	PRINT 'Tabla Canceled creada.';
END
GO
-- Índice en la columna Id_Booking
CREATE INDEX IDX_Canceled_Id_Booking ON Canceled(Id_Booking);
GO

-- Creación de la tabla Fine
IF OBJECT_ID('Fine', 'U') IS NULL 
BEGIN
	CREATE TABLE Fine (
		Id_Fine INT PRIMARY KEY,
		Date Date check (Date <= getdate()),
		Time Time,
		Price int,
		Statu varchar(20),
		Detail varchar(20),
		Id_Canceled int,
		FOREIGN KEY (Id_Canceled) REFERENCES Canceled(Id_Canceled) ON DELETE CASCADE,
	);
	PRINT 'Tabla Fine creada.';
END
GO
-- Índice en la columna Id_Canceled
CREATE INDEX IDX_Fine_Id_Canceled ON Fine(Id_Canceled);
GO

-----------------------POBALCION--------------
create procedure  poblar
as
begin


-- Población de la tabla Plane_Model
BULK INSERT Plane_Model
FROM
 'D:\SDD\Plane_Model.txt'
WITH(
FIELDTERMINATOR ='	',
ROWTERMINATOR ='\n',
FIRSTROW=2
)


-- Población de la tabla Airplane
BULK INSERT Airplane
FROM
 'D:\SDD\Airplane.txt'
WITH(
FIELDTERMINATOR ='	',
ROWTERMINATOR ='\n',
FIRSTROW=2
)

-- Población de la tabla Seat
BULK INSERT seat
FROM
 'D:\SDD\seat.txt'
WITH(
FIELDTERMINATOR =',',
ROWTERMINATOR ='\n',
FIRSTROW=2
)

-- Población de la tabla Country
INSERT INTO Country (IdCountry, NameC) VALUES (1, 'Argentina');
INSERT INTO Country (IdCountry, NameC) VALUES (2, 'Brasil');
INSERT INTO Country (IdCountry, NameC) VALUES (3, 'Canadá');
INSERT INTO Country (IdCountry, NameC) VALUES (4, 'China');
INSERT INTO Country (IdCountry, NameC) VALUES (5, 'Francia');
INSERT INTO Country (IdCountry, NameC) VALUES (6, 'Alemania');
INSERT INTO Country (IdCountry, NameC) VALUES (7, 'India');
INSERT INTO Country (IdCountry, NameC) VALUES (8, 'Italia');
INSERT INTO Country (IdCountry, NameC) VALUES (9, 'Japón');
INSERT INTO Country (IdCountry, NameC) VALUES (10, 'México');
INSERT INTO Country (IdCountry, NameC) VALUES (11, 'España');
INSERT INTO Country (IdCountry, NameC) VALUES (12, 'Estados Unidos');
INSERT INTO Country (IdCountry, NameC) VALUES (13, 'Reino Unido');
INSERT INTO Country (IdCountry, NameC) VALUES (14, 'Australia');
INSERT INTO Country (IdCountry, NameC) VALUES (15, 'Sudáfrica');

-- Población de la tabla City
INSERT INTO City (IdCity, Name, IdCountry) VALUES (1, 'Buenos Aires', 1);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (2, 'Córdoba', 1);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (3, 'Rosario', 1);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (4, 'São Paulo', 2);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (5, 'Río de Janeiro', 2);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (6, 'Brasilia', 2);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (7, 'Toronto', 3);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (8, 'Vancouver', 3);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (9, 'Montreal', 3);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (10, 'Beijing', 4);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (11, 'Shanghái', 4);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (12, 'Guangzhou', 4);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (13, 'París', 5);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (14, 'Marsella', 5);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (15, 'Lyon', 5);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (16, 'Berlín', 6);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (17, 'Hamburgo', 6);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (18, 'Múnich', 6);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (19, 'Nueva Delhi', 7);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (20, 'Bombay', 7);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (21, 'Bangalore', 7);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (22, 'Roma', 8);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (23, 'Milán', 8);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (24, 'Venecia', 8);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (25, 'Tokio', 9);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (26, 'Osaka', 9);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (27, 'Kioto', 9);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (28, 'Ciudad de México', 10);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (29, 'Guadalajara', 10);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (30, 'Monterrey', 10);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (31, 'Madrid', 11);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (32, 'Barcelona', 11);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (33, 'Valencia', 11);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (34, 'Nueva York', 12);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (35, 'Los Ángeles', 12);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (36, 'Chicago', 12);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (37, 'Londres', 13);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (38, 'Manchester', 13);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (39, 'Birmingham', 13);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (40, 'Sídney', 14);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (41, 'Melbourne', 14);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (42, 'Brisbane', 14);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (43, 'Ciudad del Cabo', 15);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (44, 'Johannesburgo', 15);
INSERT INTO City (IdCity, Name, IdCountry) VALUES (45, 'Durban', 15);
-- Población de la tabla Airport
INSERT INTO Airport (Name, IdCity) VALUES ('JFK International', 1);
INSERT INTO Airport (Name, IdCity) VALUES ('Toronto Pearson', 2);
INSERT INTO Airport (Name, IdCity) VALUES ('Benito Juárez', 3);
INSERT INTO Airport (Name, IdCity) VALUES ('LAX', 4);
INSERT INTO Airport (Name, IdCity) VALUES ('Vancouver International', 5); 
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Ministro Pistarini', 1);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeroparque Jorge Newbery', 1);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Ingeniero Ambrosio Taravella', 2);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Rosario Islas Malvinas', 3);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de São Paulo-Guarulhos', 4);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Congonhas', 4);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Galeão', 5);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Brasilia', 6);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Toronto Pearson', 7);
INSERT INTO Airport (Name, IdCity) VALUES ('Billy Bishop Toronto City Airport', 7);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Vancouver', 8);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Pierre Elliott Trudeau', 9);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Pekín', 10);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Pekín-Daxing', 10);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Shanghái Pudong', 11);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Shanghái Hongqiao', 11);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Cantón-Baiyun', 12);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Charles de Gaulle', 13);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de París-Orly', 13);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Marsella-Provenza', 14);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Lyon-Saint Exupéry', 15);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Berlín-Brandeburgo', 16);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Hamburgo', 17);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Múnich', 18);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Indira Gandhi', 19);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Chhatrapati Shivaji', 20);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Kempegowda', 21);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Leonardo da Vinci', 22);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Roma Ciampino', 22);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Milán-Malpensa', 23);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Marco Polo', 24);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Narita', 25);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Haneda', 25);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Kansai', 26);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Itami', 27);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de la Ciudad de México', 28);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional Felipe Ángeles', 28);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Guadalajara', 29);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Monterrey', 30);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Madrid-Barajas', 31);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Barcelona-El Prat', 32);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional John F. Kennedy', 34);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto LaGuardia', 34);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Los Ángeles', 35);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional O\"Hare"', 36);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Londres-Heathrow', 37);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Londres-Gatwick', 37);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Manchester', 38);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Birmingham', 39);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Sídney', 40);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Melbourne', 41);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto de Brisbane', 42);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional de Ciudad del Cabo', 43);
INSERT INTO Airport (Name, IdCity) VALUES ('Aeropuerto Internacional OR Tambo', 44);

-- Población de la tabla Airline
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001001, 'American Airlines', 'AA');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001002, 'Delta Air Lines', 'DAL');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001003, 'United Airlines', 'UA');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001004, 'Southwest Airlines', 'SWA');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001005, 'Lufthansa', 'LH');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001006, 'Air France', 'AF');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001007, 'British Airways', 'BA');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001008, 'Qantas Airways', 'QF');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001009, 'Emirates', 'EK');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001010, 'Singapore Airlines', 'SQ');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001011, 'Turkish Airlines', 'TK');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001012, 'Cathay Pacific', 'CX');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001013, 'Etihad Airways', 'EY');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001014, 'KLM Royal Dutch Airlines', 'KL');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001015, 'Japan Airlines', 'JL');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001016, 'Qatar Airways', 'QR');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001017, 'Air Canada', 'AC');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001018, 'Aeroflot Russian Airlines', 'SU');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001019, 'Korean Air', 'KE');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001020, 'China Southern Airlines', 'CZ');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001021, 'Alitalia', 'AZ');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001022, 'LATAM Airlines', 'LA');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001023, 'Avianca', 'AV');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001024, 'Iberia', 'IB');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001025, 'Air India', 'AI');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001026, 'Finnair', 'AY');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001027, 'Swiss International Air Lines', 'LX');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001028, 'Aegean Airlines', 'A3');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001029, 'Virgin Atlantic', 'VS');
INSERT INTO Airline (NIT, Name, Acronym) VALUES (1001030, 'Saudia', 'SV');

-- Población de la tabla Flight_Number
BULK INSERT Flight_Number
FROM
 'D:\SDD\Flight_Number.txt'
WITH(
FIELDTERMINATOR =',',
ROWTERMINATOR ='\n',
FIRSTROW=2
)



-- Poblacion de la tabla Person
/*
INSERT INTO Person (Id_Person, Name, DateOfBirth, Profession, Id_Customer, Num_License, Type_Person) VALUES (7,'Paola','1980-04-23','Copiloto',0,103,'CP');
INSERT INTO Person (Id_Person, Name, DateOfBirth, Profession, Id_Customer, Num_License, Type_Person) VALUES (8,'Demian','1980-04-23','Azafata',0,201,'TCP');
INSERT INTO Person (Id_Person, Name, DateOfBirth, Profession, Id_Customer, Num_License, Type_Person) VALUES (14,'Will Smith','1992-08-14','Cliente',2,0,'C');
*/

BULK INSERT Person
FROM
 'D:\SDD\Person.txt'
WITH(
FIELDTERMINATOR ='	',
ROWTERMINATOR ='\n',
FIRSTROW=2
)


-- Población de la tabla Frequent_Flyer_Card
/*
INSERT INTO Frequent_Flyer_Card (FFC_Number, Miles, Id_Person) VALUES ('FF12345', 15000, 1);
INSERT INTO Frequent_Flyer_Card (FFC_Number, Miles, Id_Person) VALUES ('FF67890', 23000, 2);
INSERT INTO Frequent_Flyer_Card (FFC_Number, Miles, Id_Person) VALUES ('FF54321', 12000, 3);
INSERT INTO Frequent_Flyer_Card (FFC_Number, Miles, Id_Person) VALUES ('FF74841', 14500, 4);
INSERT INTO Frequent_Flyer_Card (FFC_Number, Miles, Id_Person) VALUES ('FF15241', 13000, 5);
INSERT INTO Frequent_Flyer_Card (FFC_Number, Miles, Id_Person) VALUES ('FF76428', 12080, 6);
*/

-- Poblacion de la tabla Pay
/*
INSERT INTO Pay (Cod_Pay, Date, Time,Money, Total_Amount, Idd_Cash, Card_Number, Name_Bank, Account_Number, Voucher, Type_Pay)
VALUES (1, '2022-05-15', '10:00:00', 250.00, 250.00, 250.00, 'Ninguno', 'Ninguno', 'Ninguno', 'Sin Detalle', 'C');
INSERT INTO Pay (Cod_Pay, Date, Time,Money, Total_Amount, Idd_Cash, Card_Number, Name_Bank, Account_Number, Voucher, Type_Pay)
VALUES (2, '2022-04-15', '12:00:00', 300.00, 300.00, 0.00, '1234006', 'BNB', 'Ninguno', 'Sin Detalle', 'CC');
INSERT INTO Pay (Cod_Pay, Date, Time,Money, Total_Amount, Idd_Cash, Card_Number, Name_Bank, Account_Number, Voucher, Type_Pay) 
VALUES (3, '2022-07-15', '15:00:00', 330.00, 330.00, 0.00, '1234007', 'BCP', 'Ninguno', 'Sin Detalle', 'CC');
INSERT INTO Pay (Cod_Pay, Date, Time,Money, Total_Amount, Idd_Cash, Card_Number, Name_Bank, Account_Number, Voucher, Type_Pay)
VALUES (4, '2021-01-10', '16:30:00', 380.00, 380.00, 0.00, '1234008', 'MSC', 'Ninguno', 'Sin Detalle', 'CC');
INSERT INTO Pay (Cod_Pay, Date, Time,Money, Total_Amount, Idd_Cash, Card_Number, Name_Bank, Account_Number, Voucher, Type_Pay)
VALUES (5, '2024-08-20', '09:30:00', 230.00, 230.00, 0.00, 'Ninguno', 'Ninguno', '60001', 'Trans. realizada', 'BT');
INSERT INTO Pay (Cod_Pay, Date, Time,Money, Total_Amount, Idd_Cash, Card_Number, Name_Bank, Account_Number, Voucher, Type_Pay)
VALUES (6, '2024-07-15', '21:30:00', 400.00, 400.00, 0.00, 'Ninguno', 'Ninguno', '60002', 'Trans. realizada', 'BT');
*/

-- Población de la tabla Booking
/*
INSERT INTO Booking (Id_Booking, Price, Date, Time, State, Id_Person, Cod_Pay) VALUES (101, 400.00, '2024-09-15','20:30:00','Disponible',1,1);
INSERT INTO Booking (Id_Booking, Price, Date, Time, State, Id_Person, Cod_Pay) VALUES (102, 300.00, '2024-05-01','20:30:00','Reservado',2,2);
INSERT INTO Booking (Id_Booking, Price, Date, Time, State, Id_Person, Cod_Pay) VALUES (103, 850.00, '2024-06-15','15:00:00','Disponible',3,3);
*/

-- Población de la tabla Ticket
/*INSERT INTO Ticket (TicketingCode, Number, Id_Booking, Id_Person, Cod_Pay) VALUES ('TCKT001', '0001', 101,1,1);
INSERT INTO Ticket (TicketingCode, Number, Id_Booking, Id_Person, Cod_Pay) VALUES ('TCKT002', '0002', 102,2,2);
INSERT INTO Ticket (TicketingCode, Number, Id_Booking, Id_Person, Cod_Pay) VALUES ('TCKT003', '0003', 103,3,3);            
*/
-- Poblacion de la tabla Document



-- Población de la tabla Flight
BULK INSERT Flight
FROM
 'D:\SDD\Flight.txt'
WITH(
FIELDTERMINATOR =',',
ROWTERMINATOR ='\n',
FIRSTROW=2
)

-- Población de la tabla Available_Seat
/*
INSERT INTO Available_Seat (IdAvailableSeat, IdFlight, IdSeat) VALUES (1, 1, 1);
INSERT INTO Available_Seat (IdAvailableSeat, IdFlight, IdSeat) VALUES (2, 2, 2);
INSERT INTO Available_Seat (IdAvailableSeat, IdFlight, IdSeat) VALUES (3, 3, 3);
*/

-- Población de la tabla Flight_Scale



-- Población de la tabla Coupon
/*
INSERT INTO Coupon (IdCoupon, TicketingCode, ClassC, Standby, MealCode, IdFlight, IdAvailableSeat) 
VALUES (1, 'TCKT001', 'A', 'not', 'Veg', 1, 1);
INSERT INTO Coupon (IdCoupon, TicketingCode, ClassC, Standby, MealCode, IdFlight, IdAvailableSeat) 
VALUES (2, 'TCKT002', 'B', 'not', 'Non-Veg', 2, 2);
INSERT INTO Coupon (IdCoupon, TicketingCode, ClassC, Standby, MealCode, IdFlight, IdAvailableSeat) 
VALUES (3, 'TCKT003', 'C', 'yes', 'Veg', 3, 3);
*/

-- Población de la tabla Pieces_of_Luggage
/*
INSERT INTO Pieces_of_Luggage (IdLuggage, Number, Weight, IdCoupon) VALUES (1, 'L001', 23.5, 1);
INSERT INTO Pieces_of_Luggage (IdLuggage, Number, Weight, IdCoupon) VALUES (2, 'L002', 25.0, 2);
INSERT INTO Pieces_of_Luggage (IdLuggage, Number, Weight, IdCoupon) VALUES (3, 'L003', 22.3, 3);
*/


-- Población de la tabla Reschedule

-- Población de la tabla Canceled

-- Población de la tabla Fine

end
GO

EXECUTE poblar 

----------------------llamada--
-- Seleccionar todos los registros de la tabla Customer


-- Seleccionar todos los registros de la tabla Frequent_Flyer_Card
SELECT * FROM Frequent_Flyer_Card;

-- Seleccionar todos los registros de la tabla Person
SELECT * FROM Person;




-- Seleccionar todos los registros de la tabla Pay
SELECT * FROM Pay;



-- Seleccionar todos los registros de la tabla Ticket
SELECT * FROM Ticket;

-- Seleccionar todos los registros de la tabla Plane_Model
SELECT * FROM Plane_Model;

-- Seleccionar todos los registros de la tabla Airplane
SELECT * FROM Airplane;

-- Seleccionar todos los registros de la tabla Seat
SELECT * FROM Seat;

-- Seleccionar todos los registros de la tabla Country
SELECT * FROM Country;

-- Seleccionar todos los registros de la tabla City
SELECT * FROM City;

-- Seleccionar todos los registros de la tabla Airport
SELECT * FROM Airport;

-- Seleccionar todos los registros de la tabla Flight_Number
SELECT * FROM Flight_Number;

-- Seleccionar todos los registros de la tabla Flight
SELECT * FROM Flight;

-- Seleccionar todos los registros de la tabla Available_Seat
SELECT * FROM Available_Seat;

-- Seleccionar todos los registros de la tabla Coupon
SELECT * FROM Coupon;

-- Seleccionar todos los registros de la tabla Pieces_of_Luggage
SELECT * FROM Pieces_of_Luggage;
GO

