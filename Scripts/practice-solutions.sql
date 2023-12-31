with ct as(
select "customer-id",customer_name,
sum(billing_amount) total_amt,
count(case when to_char(billing_creation_date,'yyyy')='2019' then billing_amount else null end) count_2019,
count(case when to_char(billing_creation_date,'yyyy')='2020' then billing_amount else null end)count_2020,
count(case when to_char(billing_creation_date,'yyyy')='2021' then billing_amount else null end)count_2021
from test where to_char(billing_creation_date,'yyyy') between '2019' and '2021' group by "customer-id" ,customer_name)
select customer_name , total_amt/ ((case when count_2019=0 then 1 else count_2019 end)+
(case when count_2020=0 then 1 else count_2020 end)+(case when count_2021=0 then 1 else count_2021 end))
from ct;

------------------------------------------------------------------------------------------------------------------
/*
We conduct Olympiad exam for our partner schools every year to evaluate the standard of the students. Here we have provided you with the sample data for the exam. To get a proper insight about the exam you need all the 4 tables, data for all those 4 tables are given in the csv file. 

List of tables:
1.	Student_list
2.	Student_response
3.	Correct_answers
4.	Question_paper_code

	Table 1: student_list - List of students who attended the Olympiad exam from Google Public School.
	Table 2: student_response - The Learn Basics Olympiad is an objective exam, student response for every question was recorded in this table.
o	5 options ("A', 'B', 'C, 'D' and 'E') are provided for each question
o	Out of 5 options only "A', 'B', 'C' and D' are the valid options, students can pick E' option when they think they haven't learnt the concept yet.
	Table 3: correct_answers - This table has the correct answer for all the questions in math and science.
	Table 4: question_paper_code - Since we are dealing with 3 classes and 2 subjects, we are maintaining a separate question paper code for each class and each subject.

*/

with fnl as(
with cte as (
with ct as(
select sr.*,qpc.subject,ca.correct_option  from student_response sr
join qusetion_paper_code qpc on sr.question_paper_code = qpc.paper_code
join correct_answers ca on ca.question_paper_code = sr.question_paper_code and ca.question_number = sr.question_number
)
select roll_number, count(case when option_marked=correct_option and subject = 'Math' then roll_number else null end) math_correct,
count(case when option_marked!=correct_option and option_marked!='e' and subject = 'Math' then roll_number else null end) math_wrong,
count(case when option_marked='e' and subject = 'Math' then roll_number else null end) math_yet_to_learn,
count(case when option_marked=correct_option and subject = 'Science' then roll_number else null end) science_correct,
count(case when option_marked!=correct_option and option_marked!='e' and subject = 'Science' then roll_number else null end) science_wrong,
count(case when option_marked='e' and subject = 'Science' then roll_number else null end) science_yet_to_learn
from ct group by roll_number
)
select roll_number,math_correct,math_wrong,math_yet_to_learn,(math_correct*1) as math_score,round((math_correct::decimal/(math_correct+math_wrong+math_yet_to_learn)::decimal)*100,2) math_percentage,
science_correct,science_wrong,science_yet_to_learn,(science_correct*1) as science_score, round((science_correct::decimal/(science_correct+science_wrong+science_yet_to_learn)::decimal)*100,2) science_percentage
from cte
)
select sl.*,fnl.* from student_list sl join fnl on sl.roll_number = fnl.roll_number;

/* concept used: to get count on individual subject use count opearator on the case condition and return some unique value like roll number
 * if true else return null 
 */


-----------------------------------------------------------------------------------------------

create table student_info(
	roll_number integer,
	student_name varchar,
	class integer,
	school_name varchar
)

create table student_marks(
	roll_number integer,
	subject varchar,
	marks integer
)


select sf.roll_number,sf.student_name ,sf.class,sf.school_name,
sum(sm.marks), (sum(sm.marks::numeric)/300)*100 ::numeric as percentage
from student_info sf join student_marks sm on sf.roll_number = sm.roll_number
where sf.roll_number = 10
group by  sf.roll_number,sf.student_name ,sf.class,sf.school_name;


---------------------------------------------------------------------------------------------------

/*Write a query to return the account number and the transaction date when the account balance reached 1000 
 *and only include those accounts whose current balance is >=1000
 */

with cte as(
with tx_amt as(
select account_no, transaction_date ,case when debit_credit = 'debit' then -1 * transaction_amount else transaction_amount end as trx_amt from account_balance
)
select ab.account_no,ab.transaction_date,sum(ab.trx_amt) over (partition by ab.account_no order by ab.transaction_date) as current_balance,
sum(ab.trx_amt) over (partition by ab.account_no) as final_balance
from tx_amt ab
)
select account_no, min(transaction_date) as transaction_date from cte where current_balance >= 1000 and final_balance >= 1000 group by account_no 

/* concept used: partition over account number and give order on transaction date to get current balance partition over 
 * account number to get total balance
 */

---------------------------------------------------------------------------------------------------

-- TRIGGER in postgres

CREATE TABLE COMPANY(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);

CREATE TABLE company_audit(
   EMP_ID INT NOT NULL,
   ENTRY_DATE TEXT NOT NULL
);


create or replace trigger emp_audit_trg after insert on company
for each row execute procedure auditlogfunc();

create or replace function auditlogfunc() returns trigger as $emp_audit_trg$
begin
	insert into company_audit(EMP_ID,ENTRY_DATE) values (new.id,current_date);
	return new;
end;
$emp_audit_trg$ language plpgsql;

INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY)
VALUES (1, 'Paul', 32, 'California', 20000.00 );


------------------------------------------------------------------------

/*Functions and procedure syntax postgres
 
 create or replace procedure()
language plpgsql
as $$
begin


end;
$$;


create or replace functions()
returns table () as $$ / returns integer as $column_name$
begin


end;
$$ / $column_name$
language plpgsql;
*/

-------------------------------------------------------------------------------


















