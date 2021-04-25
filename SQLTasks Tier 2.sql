/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do.*/

Code:
SELECT name AS facility_name
FROM Facility
WHERE membercost > 0;

Output:
facility_name:
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court


/* Q2: How many facilities do not charge a fee to members? */

Code:
SELECT COUNT(name)
FROM Facilities
WHERE membercost = 0;

Output: 4


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

Code:
SELECT facid, name AS facility_name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < monthlymaintenance * .20
AND membercost >0

Output (only listed facility_name): 
facility_name:
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

Code:
SELECT name
FROM Facilities
WHERE facid IN ( 1, 5 )

Output (only name listed):
Massage Room 2
Tennis Court


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

Code: 
SELECT name AS facility_name, monthlymaintenance,
CASE
    WHEN monthlymaintenance > 100 THEN 'expensive'
    ELSE 'cheap' END AS cost
FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

Code:
SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX( joindate )
    FROM Members )
    
Output: Darren Smith

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Code:
SELECT DISTINCT CONCAT( m.firstname, ' ', m.surname ) AS member_name, f.name, m.memid
FROM Bookings AS b
    INNER JOIN Facilities AS f ON b.facid = f.facid
    INNER JOIN Members AS m ON b.memid = m.memid
WHERE f.name LIKE '%Tennis Court%' AND m.memid <>0


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name AS facility_name, CONCAT(firstname, ' ', surname ) AS member_name,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots 
ELSE membercost * slots END AS cost
FROM Members AS m
INNER JOIN Bookings AS b
ON m.memid = b.memid
INNER JOIN Facilities AS f
ON b.facid = f.facid
WHERE starttime LIKE '2012-09-14%'
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30
ORDER BY cost DESC;



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT name AS facility_name, CONCAT(firstname, ' ', surname ) AS member_name, cost
FROM (SELECT firstname, surname, name,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots 
      ELSE membercost * slots 
      END AS cost,starttime
		FROM Members AS m
		INNER JOIN Bookings AS b
		ON m.memid = b.memid
		INNER JOIN Facilities AS f
		ON b.facid = f.facid) AS inner_table
WHERE starttime LIKE '2012-09-14%' AND cost > 30
ORDER BY cost DESC;


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name, revenue
FROM
(SELECT name,
SUM(CASE WHEN memid = 0 THEN guestcost * slots 
ELSE membercost * slots END) AS revenue
FROM Bookings as b 
INNER JOIN Facilities as f
ON b.facid = f.facid
GROUP BY name) AS inner_table
WHERE revenue < 1000
ORDER BY revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT concat(m.firstname,' ',m.surname) as Recommended_By,
concat(rcmd.firstname,' ',rcmd.surname) as Member
FROM Members as m
INNER JOIN Members AS rcmd 
ON rcmd.recommendedby = m.memid
WHERE m.memid > 0 
ORDER BY m.surname,m.firstname,rcmd.surname,rcmd.surname


/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name,concat(m.firstname,' ',m.surname) as Member, COUNT(f.name) AS bookings
FROM Members AS m
INNER JOIN Bookings AS b
ON b.memid = m.memid
INNER JOIN Facilities AS f 
ON f.facid = b.facid
WHERE m.memid>0
GROUP BY f.name,concat(m.firstname,' ',m.surname)
ORDER BY f.name,m.surname,m.firstname 


/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name,concat(m.firstname,' ',m.surname) as member_name,
COUNT(f.name) AS bookings,

SUM(CASE WHEN MONTH(starttime) = 1 THEN 1 ELSE 0 END) AS January,
SUM(CASE WHEN MONTH(starttime) = 2 THEN 1 ELSE 0 END) AS February,
SUM(CASE WHEN MONTH(starttime) = 3 THEN 1 ELSE 0 END) AS March,
SUM(CASE WHEN MONTH(starttime) = 4 THEN 1 ELSE 0 END) AS April,
SUM(CASE WHEN MONTH(starttime) = 5 THEN 1 ELSE 0 END) AS May,
SUM(CASE WHEN MONTH(starttime) = 6 THEN 1 ELSE 0 END) AS June,
SUM(CASE WHEN MONTH(starttime) = 7 THEN 1 ELSE 0 END) AS July,
SUM(CASE WHEN MONTH(starttime) = 8 THEN 1 ELSE 0 END) AS August,
SUM(CASE WHEN MONTH(starttime) = 9 THEN 1 ELSE 0 END) AS September,
SUM(CASE WHEN MONTH(starttime) = 10 THEN 1 ELSE 0 END) AS October,
SUM(CASE WHEN MONTH(starttime) = 11 THEN 1 ELSE 0 END) AS November,
SUM(CASE WHEN MONTH(starttime) = 12 THEN 1 ELSE 0 END) AS December

FROM Members AS m
inner join Bookings AS b 
ON b.memid = m.memid
INNER JOIN Facilities AS f 
ON f.facid = b.facid
WHERE m.memid>0 

GROUP BY f.name,concat(m.firstname,' ',m.surname)
ORDER BY f.name,m.surname,m.firstname 

