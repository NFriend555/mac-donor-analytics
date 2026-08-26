-- MAC donor analytics portfolio
-- 01_database_setup.sql
-- MySQL 8.0+
--
-- Creates the raw landing tables. Import the four source CSV files after
-- running this script, then run scripts 02-06 in numeric order.

CREATE DATABASE IF NOT EXISTS mac_portfolio;
USE mac_portfolio;

CREATE TABLE IF NOT EXISTS constituents_raw (
    Constituent_ID VARCHAR(20),
    Display_Name VARCHAR(150),
    Email VARCHAR(255),
    Phone VARCHAR(40),
    City VARCHAR(100),
    State VARCHAR(50),
    ZIP VARCHAR(20),
    Country VARCHAR(100),
    Age_Band VARCHAR(30),
    Gender VARCHAR(50),
    Sector VARCHAR(100),
    Newsletter_Opt_In VARCHAR(20),
    Date_Added VARCHAR(30),
    Acquisition_Source VARCHAR(100),
    Preferred_Contact_Method VARCHAR(100),
    Constituent_Status VARCHAR(50),
    Volunteer_Flag VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS campaigns_raw (
    Campaign_ID VARCHAR(20),
    Campaign_Name VARCHAR(150),
    Campaign_Type VARCHAR(100),
    Start_Date VARCHAR(30),
    End_Date VARCHAR(30),
    Goal VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS gifts_raw (
    Gift_ID VARCHAR(30),
    Constituent_ID VARCHAR(20),
    Gift_Date VARCHAR(30),
    Gift_Amount VARCHAR(40),
    Transaction_Type VARCHAR(50),
    Gift_Method VARCHAR(50),
    Campaign_ID VARCHAR(20),
    Campaign_Name VARCHAR(150),
    Designation VARCHAR(150),
    Gift_Status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS solicitations_raw (
    Solicitation_ID VARCHAR(30),
    Constituent_ID VARCHAR(20),
    Solicitation_Date VARCHAR(30),
    Solicitation_Channel VARCHAR(50),
    Ask_Amount VARCHAR(40),
    Response VARCHAR(50),
    Attributed_Gift_ID VARCHAR(30),
    Campaign_ID VARCHAR(20),
    Solicitor_Type VARCHAR(50)
);

-- Source files are intentionally excluded from this public repository.
-- Load them through MySQL Workbench's Table Data Import Wizard, preserving
-- the raw values as text.
