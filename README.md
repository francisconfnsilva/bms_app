# Boat Management System ⚓

A full-stack information system designed for maritime fleet management, logistics, and trip scheduling. This project demonstrates the complete lifecycle of a database application, from conceptual modeling to a functional Python/SQL interface.

## Project Overview

The development of this system followed a rigorous three-stage process:

1.  **Requirement Analysis & Schema Design:** We began by analyzing strict user requirements to build a relational schema capable of handling complex entity associations (e.g., Sailors, Boats, Reserves, and Trips). 
    *> Note: The raw requirement documents are omitted from this repository for privacy reasons.*

2.  **Conceptual Modeling (ERD):** We designed a comprehensive Entity-Relationship Diagram (ERD) to visualize the data constraints and relationships.
    * **See the design:** You can find the full ERD and project cover in `cover.pdf`.

3.  **Implementation (SQL & Python):** We implemented the database using strict SQL constraints (3NF) and developed a Graphic User Interface (GUI) using Python to allow users to interact with the database securely.

## Repository Structure

The project is organized into two development phases:

* **[`schema`](./schema)**
    * Contains the SQL source code for creating the schema.
    * Includes data population scripts and complex SQL queries for reporting.
    
* **[web`](./web)**
    * **`web/`**: The Python application code and HTML templates for the user interface.
    * **`ICs.sql`**: Integrity Constraints (Triggers) to prevent invalid data states.
    * **`view.sql`**: Database views for analytics.

## Methods

* **Database:** SQL (PostgreSQL)
* **Backend:** Python
* **Frontend:** HTML / CSS
* **Concepts:** ACID Transactions, 3rd Normal Form (3NF), Stored Procedures, SQL Injection Prevention.

---
*Disclaimer: This project is for portfolio and educational purposes.*
