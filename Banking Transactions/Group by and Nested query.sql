--0. Hiển thị tên khách hàng có cùng chi nhánh với Lương Minh Hiếu
select Cust_name,Br_id
from customer
where br_id = (
	select Br_id
	from customer
	where Cust_name = N'Lương Minh Hiếu')

--1. Thống kê số lượng giao dịch, 
--tổng tiền giao dịch trong 
--từng tháng của 
--năm 2014
select month(t_date) 'month', count(t_id) 't_id_count', sum(t_amount) 'sum_t_amount'
from transactions
where year(t_date) = 2014
group by month(t_date)

--2. Thống kê tổng tiền 
--khách hàng gửi của 
--mỗi chi nhánh 
--sắp xếp theo thứ tự giảm dần của tổng tiền
select branch.Br_id, sum(t_amount) 'sum_t_amount'
from Branch
	join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
	join transactions on account.Ac_no = transactions.ac_no
where t_type = 1
group by branch.Br_id
order by sum(t_amount) desc

--3. Những chi nhánh nào thực hiện 
--nhiều giao dịch gửi tiền 
--trong tháng 12/2015 
--hơn chi nhánh Đà Nẵng
select branch.Br_id, count(t_id) 'count(t_id)'
from Branch
	join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
	join transactions on account.Ac_no = transactions.ac_no
where year(t_date) = 2015 and month(t_date) = 12 and t_type = 1
group by branch.Br_id
having count(t_id) > 
	(
		select count(t_id)
		from Branch
			join customer on Branch.BR_id = customer.Br_id
			join account on customer.Cust_id = account.cust_id
			join transactions on account.Ac_no = transactions.ac_no
		where year(t_date) = 2015 and month(t_date) = 12 and t_type = 1 and BR_name = N'Vietcombank Đà Nẵng'
		group by branch.Br_id
	)

--4. Hiển thị danh sách khách hàng 
--chưa thực hiện giao dịch nào 
--trong năm 2017
select customer.Cust_id, Cust_name, t_date, t_id
from customer 
	join account on customer.Cust_id = account.cust_id
	left join transactions on account.Ac_no = transactions.ac_no
where t_id is null and year(t_date) = 2017

--5. Tìm giao dịch gửi tiền nhiều nhất 
--trong mùa đông. 
--Nếu có thể, hãy đưa ra tên của người thực hiện giao dịch 
--và chi nhánh
select t_id, cust_name, t_amount, t_type, BR_name, t_date
from Branch
	join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
	join transactions on account.Ac_no = transactions.ac_no
where t_type = 1 and datepart(q, t_date) = 4 
	and t_amount = 
	(select max(t_amount)
	from Branch
		join customer on Branch.BR_id = customer.Br_id
		join account on customer.Cust_id = account.cust_id
		join transactions on account.Ac_no = transactions.ac_no
	where t_type = 1 and datepart(q, t_date) = 4)

-- 6. Có bao nhiêu người ở Đắc Lắk
-- sở hữu nhiều hơn một tài khoản?
select Cust_id, Cust_name, Cust_ad
from customer
where 
	Cust_id in (
		select customer.cust_id
		from customer
			join account on customer.Cust_id = account.cust_id
			
		where Cust_ad like N'%Đăk%' and Cust_ad like N'%Lăk%'
		group by customer.cust_id
		having count(customer.cust_id) > 1
		)
select count(*)
from (	select customer.cust_id
		from customer
			join account on customer.Cust_id = account.cust_id	
		where Cust_ad like N'%Đăk%' and Cust_ad like N'%Lăk%'
		group by customer.cust_id
		having count(customer.cust_id) > 1) as SoluongTK

-- 7.Cuối mỗi năm, nhiều khách hàng có xu hướng rút tiền khỏi ngân hàng 
-- để chuyển sang ngân hàng khác hoặc chuyển sang hình thức tiết kiệm khác. 
-- Hãy lọc những khách hàng 
-- có xu hướng rút tiền khỏi ngân hàng 
-- bằng cách hiển thị những người rút gần hết tiền trong tài khoản 
-- (tổng tiền rút trong tháng 12/2017 
-- nhiều hơn 100 triệu 
-- và số dư trong tài khoản còn lại <= 100.000)
-- NOTE: Cứ cột nào xuất hiện bên phải của hàm gộp thì lấy hết các cột đó cho group by
-- điều kiện : 1) thời gian = 12/2017
-- 				2) t_type = 0
-- 				3) ac_balance < 100.000
--				4) tổng tiền rút >100.000.000

select customer.Cust_id, cust_name, ac_balance, sum(t_amount)
from transactions 
	join account on transactions.ac_no = account.Ac_no
	join customer on account.cust_id = customer.Cust_id
where 
	t_type = 0 and year(t_date) = 2017 and month(t_date) = 12
	and ac_balance <= 100000
group by customer.Cust_id, cust_name, ac_balance
having sum(t_amount) > 100000000
-- 8. Hãy liệt kê những tài khoản bất thường đó. 
-- Gợi ý: tài khoản bất thường là tài khoản 
-- có tổng tiền gửi – tổng tiền rút <> số tiền trong tài khoản
select account.Ac_no, ac_balance, 
sum(case when t_type = 0 then t_amount else 0 end) as total_withdraw,
sum(case when t_type = 1 then t_amount else 0 end) as total_deposit
from transactions
	join account on transactions.ac_no = account.Ac_no
group by account.Ac_no, ac_balance
having (sum(case when t_type = 1 then t_amount else 0 end) - sum(case when t_type = 0 then t_amount else 0 end)) <> ac_balance
--11. Ông Phạm Duy Khánh thuộc chi nhánh nào? 
--Từ 01/2017 đến nay ông Khánh đã thực hiện bao nhiêu giao dịch gửi tiền vào ngân hàng 
--với tổng số tiền là bao nhiêu.
select BR_name, count(t_id) as N'số lượng giao dịch', sum(t_amount) as N'Tổng số tiền'
from transactions join account on transactions.ac_no = account.Ac_no
                  join customer on account.cust_id = customer.Cust_id
                  join Branch on customer.Br_id = Branch.BR_id
where Cust_name = N'Phạm Duy Khánh'
	and t_date >= '2017-01-01'
	and t_type = 1
group by BR_name

--12.Hiển thị khách hàng 
--cùng họ với khách hàng 
--có mã số 000002
select cust_id, cust_name, left(cust_name,charindex(' ',cust_name)) AS N'Họ'
from customer
where left(cust_name,charindex(' ',cust_name)) 
	like ( 
		select left(cust_name,charindex(' ',cust_name))
		from customer
		where Cust_id = '000002'
		)
--13. Hiển thị những khách hàng 
--sống cùng tỉnh/thành phố với ông Lương Minh Hiếu

select cust_id, cust_name, cust_ad
from customer
where right(replace(cust_ad, '-', ','), charindex(',', reverse(replace(cust_ad, '-', ','))) -1) 
like 
(
    select right(replace(cust_ad, '-', ','), 
    charindex(',', reverse(replace(cust_ad, '-', ','))) -1)
    from customer
    where Cust_name = N'Lương Minh Hiếu'
	)
--10. Hiển thị những giao dịch 
--trong mùa xuân 
--của các chi nhánh miền trung. 
--Gợi ý: giả sử một năm có 4 mùa, 
--mỗi mùa kéo dài 3 tháng; 
--chi nhánh miền trung 
--có mã chi nhánh bắt đầu bằng VT
select t_id, branch.Br_id, BR_name, datepart(quarter, t_date) as Season
from Branch
	join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
	join transactions on account.Ac_no = transactions.ac_no
where datepart(quarter, t_date) = 1 and branch.Br_id like 'VT%'
-- 9.Ngân hàng cần biết những chi nhánh nào 
--có nhiều giao dịch rút tiền 
--vào buổi chiều 
--để chuẩn bị chuyển tiền tới. 
--Hãy liệt kê danh sách các chi nhánh 
--và lượng tiền rút trung bình theo ngày 
--(chỉ xét những giao dịch diễn ra trong buổi chiều), 
--sắp xếp giảm giần theo lượng tiền giao dịch. 
select day(t_date) as 'dayofweek', branch.Br_id, avg(t_amount) as 'avg(t_amount)'
from Branch
	join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
	join transactions on account.Ac_no = transactions.ac_no
where t_time between '13:00' and '18:00' and t_type = 0
group by  day(t_date), branch.Br_id
order by avg(t_amount) desc