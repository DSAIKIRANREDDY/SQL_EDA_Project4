create database SQLPROJECT4;
use SQLPROJECT4;

create table mentor(
id	int,
user_id	bigint,
question_id	int,
points	int,
submitted_at	text,
username	text
);

show tables;
desc mentor;

select * from mentor limit 5;

# EDA
select count(user_id) as count from mentor;
select distinct username from mentor;
select count(distinct username) from mentor;
select distinct question_id from mentor order by question_id;
select count(distinct question_id) from mentor order by question_id;
select min(points) as min_points from mentor;
select max(points) as max_points from mentor;


# cleaning
select count(*) from mentor where id=null or 
								  user_id=null or 
                                  question_id=null or
                                  points=null or 
                                  submitted_at=null or
                                  username=null;
set SQL_SAFE_UPDATES=0;
delete from mentor where id=null or 
								  user_id=null or 
                                  question_id=null or
                                  points=null or 
                                  submitted_at=null or
                                  username=null;
set SQL_SAFE_UPDATES=1;

# ANALYSIS
	# Q1. List All Distinct Users and Their Stats
		select username, count(id) as IdsCount, round(avg(points),2) as avgPoints
		from mentor
		group by username;
    
	# Q2. Calculate the Daily Average Points for Each User
		select to_char(submitted_at,'DD-MM') as day, username, avg(points) as avgPoints
        from mentor
        group by 1,username
        order by username;
    
	# Q3. Find the Top 3 Users with the Most Correct Submissions for Each Day
		SELECT DATE_FORMAT(submitted_at, '%d-%m') AS daay,
		   username,
		   SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS submission
		FROM mentor
		GROUP BY DATE_FORMAT(submitted_at, '%d-%m'), username
        order by submission desc;

	# Q4. Find the Top 5 Users with the Highest Number of Incorrect Submissions
		SELECT 
			username,
			SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) AS incorrect_submissions,
			SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions,
			SUM(CASE WHEN points < 0 THEN points ELSE 0 END) AS incorrect_submissions_points,
			SUM(CASE WHEN points > 0 THEN points ELSE 0 END) AS correct_submissions_points_earned,
			SUM(points) AS points_earned
		FROM user_submissions
		GROUP BY 1
		ORDER BY incorrect_submissions DESC;

	# Q5. Find the Top 10 Performers for Each Week
		SELECT *  
		FROM (
			SELECT 
				EXTRACT(WEEK FROM submitted_at) AS week_no,
				username,
				SUM(points) AS total_points_earned,
				DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS rank
			FROM user_submissions
			GROUP BY 1, 2
			ORDER BY week_no, total_points_earned DESC
		)
		WHERE rank <= 10;