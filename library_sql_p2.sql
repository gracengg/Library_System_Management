SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status

--Project Tasks
--CRUD Operations
--Q1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books

--Q2. Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'

--Q3. Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121'

--Q4. Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

--Q5. List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_member_id,
COUNT(*) as total_issued
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 1 DESC

--Creating table
--Q6. Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cn
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title
SELECT * FROM book_issued_cnt

--Data Analysis & Finding
--Q7. Retrieve All Books in a Specific Category
SELECT DISTINCT category,
book_title
FROM books 
GROUP BY 1,2
ORDER BY 1 

--Q8. Find Total Rental Income by Category
SELECT category, SUM(rental_price) as total_rent_income
FROM books
GROUP BY 1
ORDER BY 2

--Q9. List Members Who Registered in the Last 180 Days
SELECT *
FROM members
WHERE reg_date = current_date - INTERVAL'180 days'

--Q10. List Employees with Their Branch Manager's Name and their branch details
SELECT e.emp_id, e.emp_name, b.*
FROM employees as e
JOIN branch as b
USING(branch_id)

--Q11. Create a Table of Books with Rental Price Above a Certain Threshold
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price>=7.00

--Q12. Retrieve the List of Books Not Yet Returned
SELECT ist.issued_id, ist.issued_book_name, 
	   ret.return_date, ret.return_id
FROM issued_status as ist
LEFT JOIN return_status as ret
USING(issued_id)
WHERE ret.return_id IS NULL

--Q13. Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT ist.issued_member_id, 
	   ist.issued_date,
	   m.member_name,
	   b.book_title	   
FROM issued_status as ist
LEFT JOIN members as m ON(ist.issued_member_id = m.member_id)
LEFT JOIN books as b ON(ist.issued_book_isbn = b.isbn)
LEFT JOIN return_status as rs USING(issued_id)
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date)>30

--Q14. Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
CREATE TABLE branch_reports AS 
SELECT br.branch_id, 
	   COUNT(ist.issued_id) as total_issued_books,
	   COUNT(rs.return_id) as total_return_books,
	   SUM(b.rental_price) as total_rent_income
FROM issued_status as ist
JOIN employees as e ON(ist.issued_emp_id = e.emp_id)
JOIN branch as br USING(branch_id)
JOIN books as b ON(ist.issued_book_isbn = b.isbn)
LEFT JOIN return_status as rs USING(issued_id)
GROUP BY 1
SELECT * FROM branch_reports

--Q15. CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members AS 
SELECT * FROM members
WHERE member_id in (SELECT DISTINCT issued_member_id FROM issued_status  
					WHERE issued_date >= CURRENT_DATE - INTERVAL'2'MONTH)
SELECT * FROM active_members

