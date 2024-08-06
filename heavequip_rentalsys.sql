-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 07, 2024 at 05:04 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `heavequip_rentalsys`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_customer` (IN `p_FirstName` VARCHAR(50), IN `p_LastName` VARCHAR(50), IN `p_CompanyName` VARCHAR(100), IN `p_Address` VARCHAR(100), IN `p_Phone` VARCHAR(50), IN `p_Email` VARCHAR(100))   BEGIN
    INSERT INTO heavequip_rentalsys.customers (FirstName, LastName, CompanyName, Address, Phone, Email)
    VALUES (p_FirstName, p_LastName, p_CompanyName, p_Address, p_Phone, p_Email);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order` (IN `p_CustomerID` INT, IN `p_EmployeeID` INT, IN `p_RentalStartDate` DATE, IN `p_RentalEndDate` DATE, IN `p_ReturnDate` DATE, IN `p_Status` TINYINT)   BEGIN
    DECLARE total_cost DECIMAL(10,2);
    
    INSERT INTO heavequip_rentalsys.orders (CustomerID, EmployeeID, RentalStartDate, RentalEndDate, ReturnDate, Status)
    VALUES (p_CustomerID, p_EmployeeID, p_RentalStartDate, p_RentalEndDate, p_ReturnDate, p_Status);
    
    SET total_cost = DATEDIFF(p_RentalEndDate, p_RentalStartDate) * 
                     (SELECT SUM(RentalRate) 
                      FROM heavequip_rentalsys.equipment 
                      WHERE EquipmentID IN (SELECT EquipmentID FROM heavequip_rentalsys.orderequipment WHERE OrderID = LAST_INSERT_ID()));
    
    UPDATE heavequip_rentalsys.orders
    SET TotalCost = total_cost
    WHERE OrderID = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_rents` ()   BEGIN
    SELECT ar.*, e.FirstName AS EmployeeFirstName, e.LastName AS EmployeeLastName, c.FirstName AS CustomerFirstName, c.LastName AS CustomerLastName
    FROM heavequip_rentalsys.active_rents ar
    JOIN heavequip_rentalsys.employees e ON ar.EmployeeID = e.EmployeeID
    JOIN heavequip_rentalsys.customers c ON ar.CustomerID = c.CustomerID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `active_rents`
-- (See below for the actual view)
--
CREATE TABLE `active_rents` (
`Customer's Name` varchar(101)
,`Employee's name in charge` varchar(101)
,`Rent Start Date` date
,`Rent End Date` date
,`Total Cost` decimal(10,2)
,`Rented Equipment` varchar(100)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `availequipments`
-- (See below for the actual view)
--
CREATE TABLE `availequipments` (
`Available Equipments` varchar(100)
,`Equipment Model` varchar(100)
,`Weekly Rate` decimal(10,2)
,`Supplier` varchar(100)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `customerrents_supplier`
-- (See below for the actual view)
--
CREATE TABLE `customerrents_supplier` (
`Customer Name` varchar(100)
,`Company` varchar(100)
,`Rented Equipment` varchar(100)
,`Supplier Company Name` varchar(100)
,`Supplier Contact Person` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `CustomerID` int(11) NOT NULL,
  `FirstName` varchar(50) DEFAULT NULL,
  `LastName` varchar(50) DEFAULT NULL,
  `CompanyName` varchar(100) DEFAULT NULL,
  `Address` varchar(100) NOT NULL,
  `Phone` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`CustomerID`, `FirstName`, `LastName`, `CompanyName`, `Address`, `Phone`, `Email`) VALUES
(1, 'Aishi', 'Terunia', 'Crystalshine inc.', 'Newberry, Michigan, United States', '(989) 555-9874', 'aishi_teru10@gmail.com'),
(2, 'Layleson', 'Law', 'Visionetworks co.', 'San Jose, California, United States', '(209) 555-4561', 'laylesonlaw@gmail.com'),
(3, 'Jayce', 'Shinyuu', 'Grand Chasm Mining Group', 'Kilkenny, Leinster, Ireland', '+353 147258', 'jayc33_cuti3@gmail.com'),
(4, 'Athena', 'Prescott', 'l\'Arène du Faux', 'Marseille, Provence-Alpes-Côte d\'Azur, France', '+33 69852147', 'Prescottathena@yahoo.com');

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `EmployeeID` int(11) NOT NULL,
  `FirstName` varchar(50) DEFAULT NULL,
  `LastName` varchar(50) DEFAULT NULL,
  `Role` varchar(50) DEFAULT NULL,
  `Address` varchar(100) NOT NULL,
  `Phone` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`EmployeeID`, `FirstName`, `LastName`, `Role`, `Address`, `Phone`, `Email`) VALUES
(1, 'Chrisearl Grace', 'Cumla', 'Staff', 'Canitoan, Cagayan de Oro City.', '09876543210', 'cumlachrisearlgrace@gmail.com'),
(2, 'Michelle Mae', 'Dangazo', 'Staff', 'Consolacion, Cagayan de Oro City.', '09123456789', 'vdangazom@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `equipment`
--

CREATE TABLE `equipment` (
  `EquipmentID` int(11) NOT NULL,
  `SupplierID` int(11) DEFAULT NULL,
  `EquipmentType` varchar(100) DEFAULT NULL,
  `Model` varchar(100) DEFAULT NULL,
  `AvailabilityStatus` tinyint(1) DEFAULT NULL,
  `RentalRate` decimal(10,2) DEFAULT NULL,
  `PurchaseDate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `equipment`
--

INSERT INTO `equipment` (`EquipmentID`, `SupplierID`, `EquipmentType`, `Model`, `AvailabilityStatus`, `RentalRate`, `PurchaseDate`) VALUES
(1, 1, 'Articulated Truck', 'Volvo A40G', 1, 3900.00, '2020-03-15'),
(2, 2, 'Compactor', 'Bomag BW213DH-5', 1, 1000.00, '2018-06-05'),
(3, 2, 'Crane', 'Liebherr LTM 11200-9.1', 0, 5000.00, '2017-09-12'),
(4, 3, 'Dozer', 'Caterpillar D8T', 0, 3500.00, '2018-12-02'),
(5, 3, 'Dump Truck', 'Caterpillar 797F', 0, 2400.00, '2021-03-22'),
(6, 1, 'Excavator', 'Komatsu PC210LC-11', 1, 2100.00, '2020-01-27'),
(7, 3, 'Grader', 'Caterpillar 140M3', 1, 3500.00, '2018-02-03'),
(8, 3, 'Scraper', 'Caterpillar 637K', 1, 7000.00, '2019-09-08'),
(9, 1, 'Trailer', 'Fontaine Magnitude 55MX', 0, 600.00, '2020-07-30'),
(10, 2, 'Loader', 'John Deere 644K', 1, 1000.00, '2020-04-09');

-- --------------------------------------------------------

--
-- Table structure for table `orderequipment`
--

CREATE TABLE `orderequipment` (
  `OrderID` int(11) NOT NULL,
  `EquipmentID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orderequipment`
--

INSERT INTO `orderequipment` (`OrderID`, `EquipmentID`) VALUES
(1, 1),
(2, 3),
(3, 5),
(4, 4),
(5, 9);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `OrderID` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `EmployeeID` int(11) DEFAULT NULL,
  `RentalStartDate` date DEFAULT NULL,
  `RentalEndDate` date DEFAULT NULL,
  `TotalCost` decimal(10,2) DEFAULT NULL,
  `ReturnDate` date NOT NULL,
  `Status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`OrderID`, `CustomerID`, `EmployeeID`, `RentalStartDate`, `RentalEndDate`, `TotalCost`, `ReturnDate`, `Status`) VALUES
(1, 1, 2, '2024-06-01', '2024-06-29', 15600.00, '2024-06-28', 0),
(2, 2, 2, '2024-07-29', '2024-08-12', 10000.00, '0000-00-00', 1),
(3, 2, 2, '2024-07-29', '2024-08-12', 4800.00, '0000-00-00', 1),
(4, 3, 1, '2024-07-11', '2024-07-25', 7000.00, '0000-00-00', 1),
(5, 4, 1, '2024-06-02', '2024-08-04', 5400.00, '0000-00-00', 1);

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `after_order_insert` AFTER INSERT ON `orders` FOR EACH ROW BEGIN
    DECLARE equipment_id INT;
    DECLARE done INT DEFAULT 0;
    DECLARE equipment_cursor CURSOR FOR 
        SELECT EquipmentID FROM heavequip_rentalsys.orderequipment WHERE OrderID = NEW.OrderID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN equipment_cursor;

    read_loop: LOOP
        FETCH equipment_cursor INTO equipment_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        UPDATE heavequip_rentalsys.equipment
        SET AvailabilityStatus = 0
        WHERE EquipmentID = equipment_id;
    END LOOP;

    CLOSE equipment_cursor;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_order_insert` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    DECLARE equipment_cost DECIMAL(10,2) DEFAULT 0;

    -- Calculate the total rental cost of all equipment in the order
    SELECT SUM(e.RentalRate) INTO equipment_cost
    FROM heavequip_rentalsys.equipment e
    INNER JOIN heavequip_rentalsys.orderequipment oe ON e.EquipmentID = oe.EquipmentID
    WHERE oe.OrderID = NEW.OrderID;

    -- Calculate the total cost based on rental period and equipment cost
    SET NEW.TotalCost = DATEDIFF(NEW.RentalEndDate, NEW.RentalStartDate) * equipment_cost;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `rentals_date`
-- (See below for the actual view)
--
CREATE TABLE `rentals_date` (
`Customer name` varchar(101)
,`Company name` varchar(100)
,`Rented Equipment` varchar(100)
,`Rented Date` date
,`Due Date` date
,`Employee in charge` varchar(101)
);

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `ReportID` int(11) NOT NULL,
  `ReportType` varchar(50) DEFAULT NULL,
  `GeneratedDate` date DEFAULT NULL,
  `Content` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`ReportID`, `ReportType`, `GeneratedDate`, `Content`) VALUES
(1, 'Supplier Offer', '2021-05-05', '\"Ashton Graceworth, a contact person from Gracethorne Manor, contacted our company and offered their heavy equipment. The contract has been finalized, we now await the arrival of the agreed-upon equipment.\"'),
(2, 'Supplier offer', '2021-06-05', '\"Aira Chandelle, a contact person from Avonnia Harbor, contacted our company and offered their heavy equipment. According to her, their company heard that we plan on purchasing equipment from Gracethorne Manor, and they also saw the opportunity to present their equipment.\"'),
(3, 'Contacting another supplier', '2021-06-15', '\"We decided to reach out and contact Wraith Garden Obelisk since their company is well-known for selling heavy equipment. We made the deal happen and now we have another supplier alongside Gracethorne Manor and Avonnia Harbor.\"'),
(4, 'Equipments Arrival', '2021-08-05', '\"The heavy equipments we were waiting to arrive has finally been delivered today. These equipments are from Gracethorne Manor, the following equipments are Articulated Truck, Excavator, and Trailer.\"'),
(5, 'Equipments Arrival', '2024-08-08', '\"The heavy equipments we were waiting to arrive has finally been delivered today. These equipments are from Avonnia Harbor, the following equipments are Compactor, Crane, and Loader.\"'),
(6, 'Equipments Arrival', '2024-09-01', '\"The heavy equipments we were waiting to arrive has finally been delivered today. These equipments are from Wraith Graden Obelisk, the following equipments are Dozer, Dump Truck, Grader, and Scraper.\"'),
(7, 'Customer Registration', '2023-06-09', '\"Aishi Terunia and Jayce Shinyuu registered as customers.\"'),
(8, 'Customer Registration', '2023-09-10', '\"Layleson Law registered as a customer.\"'),
(9, 'Customer Registration', '2022-06-10', '\"Athena Prescott registered as a customer.\"'),
(10, 'Rental Report', '2024-06-01', '\"Aishi Terunia rented an Articulated Truck for 4 weeks starting from June 01, 2024, due to June 29, 2024. The total cost was 15,600.00 USD.\"'),
(11, 'Rental Report', '2024-06-28', '\"Aishi Terunia returned the Articulated Truck on June 28, 2024.\"'),
(12, 'Rental Report', '2024-07-29', '\"Layleson Law rented a Crane and Dump Truck for 2 weeks starting from July 29, 2024, due to August 12, 2024. The total cost was 14,800.00 USD.\"'),
(13, 'Rental Report', '2024-07-11', '\"Jayce Shinyuu rented a Dozer for 2 weeks starting from July 11, 2024, due to July 25, 2024. The total cost was 7,000.00 USD.\"'),
(14, 'Rental Report', '2024-06-02', '\"Athena Prescott rented a Trailer for 9 weeks starting from June 02, 2024, due to August 04, 2024. The total cost was 5,400.00 USD.\"');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `RoleID` int(11) NOT NULL,
  `RoleName` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `SupplierID` int(11) NOT NULL,
  `SupplierName` varchar(100) DEFAULT NULL,
  `ContactPerson` varchar(100) DEFAULT NULL,
  `Phone` varchar(50) NOT NULL,
  `Email` varchar(50) NOT NULL,
  `Address` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`SupplierID`, `SupplierName`, `ContactPerson`, `Phone`, `Email`, `Address`) VALUES
(1, 'Gracethorne Manor', 'Ashton Graceworth', '+46 84319576', 'graceworthA@gmail.com', 'Gothenburg, Sweden'),
(2, 'Avonnia Harbor', 'Aira Chandelle', '+39 75321598', 'aira_chandelle@gmail.com', 'Venice, Veneto region, Italy'),
(3, 'Wraith Garden Obelisk', 'Alistair/Angelica Tayloure', '(949) 555 8426', 'tayloure_aa@gmail.com', 'Los Angeles, California, United States');

-- --------------------------------------------------------

--
-- Table structure for table `userroles`
--

CREATE TABLE `userroles` (
  `UserID` int(11) NOT NULL,
  `RoleID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(50) NOT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `active_rents`
--
DROP TABLE IF EXISTS `active_rents`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `active_rents`  AS SELECT concat(`customers`.`FirstName`,' ',`customers`.`LastName`) AS `Customer's Name`, concat(`employees`.`FirstName`,' ',`employees`.`LastName`) AS `Employee's name in charge`, `orders`.`RentalStartDate` AS `Rent Start Date`, `orders`.`RentalEndDate` AS `Rent End Date`, `orders`.`TotalCost` AS `Total Cost`, `equipment`.`EquipmentType` AS `Rented Equipment` FROM ((((`orderequipment` join `orders` on(`orders`.`OrderID` = `orderequipment`.`OrderID`)) join `equipment` on(`equipment`.`EquipmentID` = `orderequipment`.`EquipmentID`)) join `customers` on(`customers`.`CustomerID` = `orders`.`CustomerID`)) join `employees` on(`employees`.`EmployeeID` = `orders`.`EmployeeID`)) WHERE `orders`.`Status` = 1 ORDER BY `orders`.`OrderID` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `availequipments`
--
DROP TABLE IF EXISTS `availequipments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `availequipments`  AS SELECT `equipment`.`EquipmentType` AS `Available Equipments`, `equipment`.`Model` AS `Equipment Model`, `equipment`.`RentalRate` AS `Weekly Rate`, `suppliers`.`SupplierName` AS `Supplier` FROM (`equipment` join `suppliers` on(`suppliers`.`SupplierID` = `equipment`.`SupplierID`)) WHERE `equipment`.`AvailabilityStatus` = 1 ORDER BY `equipment`.`EquipmentType` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `customerrents_supplier`
--
DROP TABLE IF EXISTS `customerrents_supplier`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `customerrents_supplier`  AS SELECT concat(`customers`.`FirstName`,`customers`.`LastName`) AS `Customer Name`, `customers`.`CompanyName` AS `Company`, `equipment`.`EquipmentType` AS `Rented Equipment`, `suppliers`.`SupplierName` AS `Supplier Company Name`, `suppliers`.`ContactPerson` AS `Supplier Contact Person` FROM ((((`orderequipment` join `orders` on(`orders`.`OrderID` = `orderequipment`.`OrderID`)) join `customers` on(`customers`.`CustomerID` = `orders`.`CustomerID`)) join `equipment` on(`equipment`.`EquipmentID` = `orderequipment`.`EquipmentID`)) join `suppliers` on(`suppliers`.`SupplierID` = `equipment`.`SupplierID`)) ;

-- --------------------------------------------------------

--
-- Structure for view `rentals_date`
--
DROP TABLE IF EXISTS `rentals_date`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rentals_date`  AS SELECT concat(`customers`.`FirstName`,' ',`customers`.`LastName`) AS `Customer name`, `customers`.`CompanyName` AS `Company name`, `equipment`.`EquipmentType` AS `Rented Equipment`, `orders`.`RentalStartDate` AS `Rented Date`, `orders`.`RentalEndDate` AS `Due Date`, concat(`employees`.`FirstName`,' ',`employees`.`LastName`) AS `Employee in charge` FROM ((((`orderequipment` join `orders` on(`orders`.`OrderID` = `orderequipment`.`OrderID`)) join `equipment` on(`equipment`.`EquipmentID` = `orderequipment`.`EquipmentID`)) join `customers` on(`customers`.`CustomerID` = `orders`.`CustomerID`)) join `employees` on(`employees`.`EmployeeID` = `orders`.`EmployeeID`)) ORDER BY `orders`.`OrderID` ASC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`CustomerID`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`EmployeeID`);

--
-- Indexes for table `equipment`
--
ALTER TABLE `equipment`
  ADD PRIMARY KEY (`EquipmentID`),
  ADD KEY `SupplierID` (`SupplierID`);

--
-- Indexes for table `orderequipment`
--
ALTER TABLE `orderequipment`
  ADD PRIMARY KEY (`OrderID`,`EquipmentID`),
  ADD KEY `EquipmentID` (`EquipmentID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`OrderID`),
  ADD KEY `CustomerID` (`CustomerID`),
  ADD KEY `EmployeeID` (`EmployeeID`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`ReportID`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`RoleID`),
  ADD UNIQUE KEY `RoleName` (`RoleName`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`SupplierID`);

--
-- Indexes for table `userroles`
--
ALTER TABLE `userroles`
  ADD PRIMARY KEY (`UserID`,`RoleID`),
  ADD KEY `RoleID` (`RoleID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `CustomerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `EmployeeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `equipment`
--
ALTER TABLE `equipment`
  MODIFY `EquipmentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `OrderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `ReportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `RoleID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `SupplierID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `equipment`
--
ALTER TABLE `equipment`
  ADD CONSTRAINT `equipment_ibfk_1` FOREIGN KEY (`SupplierID`) REFERENCES `suppliers` (`SupplierID`);

--
-- Constraints for table `orderequipment`
--
ALTER TABLE `orderequipment`
  ADD CONSTRAINT `orderequipment_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`),
  ADD CONSTRAINT `orderequipment_ibfk_2` FOREIGN KEY (`EquipmentID`) REFERENCES `equipment` (`EquipmentID`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`EmployeeID`) REFERENCES `employees` (`EmployeeID`);

--
-- Constraints for table `userroles`
--
ALTER TABLE `userroles`
  ADD CONSTRAINT `userroles_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`),
  ADD CONSTRAINT `userroles_ibfk_2` FOREIGN KEY (`RoleID`) REFERENCES `roles` (`RoleID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
