--СОЗДАНИЕ ТАБЛИЦ--

CREATE TABLE barbers (
                         barberId INT PRIMARY KEY AUTO_INCREMENT,
                         barberName VARCHAR(255) NOT NULL,
                         accessability BOOLEAN NOT NULL
);

CREATE TABLE clients (
                         clientId INT PRIMARY KEY AUTO_INCREMENT,
                         clientName VARCHAR(255) NOT NULL,
                         mail VARCHAR(255) NOT NULL
);

CREATE TABLE worktime (
                          workId INT PRIMARY KEY AUTO_INCREMENT,
                          barberId INT,
                          day_of_week VARCHAR(10) NOT NULL,
                          beginTime TIME NOT NULL,
                          endTime TIME NOT NULL,
                          busy BOOLEAN NOT NULL,
                          FOREIGN KEY (barberId) REFERENCES barbers(barberId)
);

CREATE TABLE records (
                         recId INT PRIMARY KEY AUTO_INCREMENT,
                         clientId INT,
                         barberId INT,
                         day_of_week VARCHAR(10) NOT NULL,
                         beginTime TIME NOT NULL,
                         endTime TIME NOT NULL,
                         FOREIGN KEY (clientId) REFERENCES clients(clientId),
                         FOREIGN KEY (barberId) REFERENCES barbers(barberId)
);

CREATE TABLE brakes (
                        brakeId INT PRIMARY KEY AUTO_INCREMENT,
                        barberId INT,
                        day_of_week VARCHAR(10) NOT NULL,
                        beginTime TIME NOT NULL,
                        endTime TIME NOT NULL,
                        FOREIGN KEY (barberId) REFERENCES barbers(barberId)
);


--ПРОЦЕДУРЫ ДЛЯ ТАБЛИЦ--

--"Получить свободные слоты":--

DELIMITER //

CREATE PROCEDURE GetAvailableSlots(IN pDayOfWeek VARCHAR(10))
BEGIN
SELECT W.beginTime, W.endTime
FROM worktime W
         LEFT JOIN records R ON W.barberId = R.barberId AND W.day_of_week = R.day_of_week
         LEFT JOIN brakes B ON W.barberId = B.barberId AND W.day_of_week = B.day_of_week
WHERE W.day_of_week = pDayOfWeek
  AND W.busy = FALSE
  AND W.beginTime >= '09:00:00' AND W.endTime <= '17:00:00'
  AND R.recId IS NULL
  AND (B.brakeId IS NULL OR (W.beginTime < B.beginTime AND W.endTime <= B.beginTime) OR (W.beginTime >= B.endTime AND W.endTime > B.endTime));
END //

DELIMITER ;



--"Записать клиента":--

DELIMITER //

CREATE PROCEDURE BookClient(IN pClientId INT, IN pBarberId INT, IN pDayOfWeek VARCHAR(10), IN pBeginTime TIME, IN pEndTime TIME)
BEGIN
    DECLARE validSlot BOOLEAN;
    SET validSlot = EXISTS (
        SELECT 1
        FROM worktime W
        LEFT JOIN brakes B ON W.barberId = B.barberId AND W.day_of_week = B.day_of_week
        WHERE W.barberId = pBarberId AND W.day_of_week = pDayOfWeek
        AND W.beginTime = pBeginTime AND W.endTime = pEndTime
        AND W.busy = FALSE
        AND W.beginTime >= '09:00:00' AND W.endTime <= '17:00:00'
        AND (B.brakeId IS NULL OR (W.beginTime < B.beginTime AND W.endTime <= B.beginTime) OR (W.beginTime >= B.endTime AND W.endTime > B.endTime))
    );

    IF validSlot THEN
        INSERT INTO records (clientId, barberId, day_of_week, beginTime, endTime)
        VALUES (pClientId, pBarberId, pDayOfWeek, pBeginTime, pEndTime);

UPDATE worktime
SET busy = TRUE
WHERE barberId = pBarberId AND day_of_week = pDayOfWeek AND beginTime = pBeginTime AND endTime = pEndTime;
END IF;
END //

DELIMITER ;



--"Завершить стрижку":--

DELIMITER //

CREATE PROCEDURE FinishHaircut(IN pBarberId INT, IN pDayOfWeek VARCHAR(10), IN pEndTime TIME)
BEGIN
UPDATE worktime
SET busy = FALSE
WHERE barberId = pBarberId AND day_of_week = pDayOfWeek AND endTime = pEndTime;
END //

DELIMITER ;


--"Получить следующий свободный слот":--

DELIMITER //

CREATE PROCEDURE GetNextAvailableSlot(IN pBarberId INT, IN pDayOfWeek VARCHAR(10))
BEGIN
SELECT W.beginTime, W.endTime
FROM worktime W
         LEFT JOIN records R ON W.barberId = R.barberId AND W.day_of_week = R.day_of_week
         LEFT JOIN brakes B ON W.barberId = B.barberId AND W.day_of_week = B.day_of_week
WHERE W.day_of_week = pDayOfWeek
  AND W.barberId = pBarberId
  AND W.busy = FALSE
  AND W.beginTime >= '09:00:00' AND W.endTime <= '17:00:00'
  AND R.recId IS NULL
  AND (B.brakeId IS NULL OR (W.beginTime < B.beginTime AND W.endTime <= B.beginTime) OR (W.beginTime >= B.endTime AND W.endTime > B.endTime))
ORDER BY W.beginTime
    LIMIT 1;
END //

DELIMITER ;



--"Получить расписание парикмахера":--

DELIMITER //

CREATE PROCEDURE GetBarberSchedule(IN pBarberId INT, IN pDayOfWeek VARCHAR(10))
BEGIN
SELECT *
FROM worktime
WHERE barberId = pBarberId AND day_of_week = pDayOfWeek;
END //

DELIMITER ;
