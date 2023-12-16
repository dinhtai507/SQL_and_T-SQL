use Bank
--1. Tìm những khách hàng có địa chỉ ở Ngũ Hành Sơn – Đà nẵng--
select Cust_id, Cust_name, Cust_ad
from customer
where Cust_ad like N'%ĐÀ NẴNG%' and Cust_ad like N'%NGŨ HÀNH SƠN%'

--2. Liệt kê những chi nhánh chưa có địa chỉ--
select BR_id, BR_name, BR_ad
from Branch
where (BR_ad = '' or BR_ad is null)

--3. Liệt kê những giao dịch rút tiền bất thường (nhỏ hơn 50.000)--
select t_id, t_type, t_amount, ac_no, t_date, t_time
from transactions
where t_amount < 50000 and t_type = 0

--4. Hiển thị danh sách khách hàng có kí tự thứ 3 từ cuối lên là chữ a, u, i--
select Cust_id, Cust_name
from customer
where Cust_name like N'%[a,u,i]__'

--5. Hiển thị khách hàng có địa chỉ sống ở vùng nông thôn. 
--Với quy ước : nông thôn là vùng mà địa chỉ chứa: thôn, xã, xóm
--cột nào?--
--bảng nào?--
--điều kiện? -- địa chỉ chứa 'thôn' hoặc
			-- địa chỉ chứa 'xóm' hoặc
			-- địa chỉ chứa ' xã' nhưng không chứa 'thị xã'
			-- = so sánh toàn bộ giá trị của cột
			-- like so sánh một phần giá trị của cột
select cust_id, cust_name, Cust_ad
from customer
where Cust_ad like N'%thôn%' 
	or Cust_ad like N'%xóm%'
	or (Cust_ad like N'%xã%' and Cust_ad not like N'%thị xã%')

--6. Trong quý 1 năm 2012, hiển thị danh sách khách hàng 
--thực hiện giao dịch rút tiền tại Ngân hàng Vietcombank?--
select customer.Cust_id, Cust_name, Cust_ad, t_date,  t_type
from transactions 
inner join account on transactions.ac_no = account.Ac_no
inner join customer on account.Cust_id = customer.Cust_id
where year(t_date) = 2012 and datepart(quarter, t_date) = 1 and t_type = 0

--7. Liệt kê những giao dịch thực hiện 
--cùng giờ với giao dịch Lê Nguyễn Hoàng Văn trong năm 2016

select t_id, t_type, t_amount, t_time, t_date
from transactions
where year(t_date) = 2016 and 
	datepart(hour, t_time) in 
	(
	select datepart(hour, t_time) as hour
	from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	inner join customer on account.Cust_id = customer.Cust_id
	where Cust_name = N'Lê Nguyễn Hoàng Văn' and year(t_date) = 2016
	)

--9. Hiển thị tên, họ và tên đệm của các khách hàng (2 cột khác nhau)--
select substring(Cust_name, len(Cust_name) - charindex(' ', reverse(Cust_name)) + 1 + 1, len(Cust_name)) as "Tên",
		substring(Cust_name, 1, len(Cust_name) - charindex(' ', reverse(Cust_name)) + 1 - 1) as "Họ và tên"  
from customer

select 
	trim(
	right(Cust_name, charindex(' ', reverse(Cust_name)))
	) 'Tên', 
	trim(
	left(Cust_name, len(Cust_name) - charindex(' ', reverse(Cust_name)))
	) 'Họ và tên đệm'
from customer

--8. Liệt kê các giao dịch của chi nhánh Huế năm 2016
select t_id, t_date, t_time, BR_name
from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	inner join customer on account.Cust_id = customer.Cust_id
	inner join Branch on customer.Br_id = Branch.BR_id
where BR_name like N'%Huế%' and year(t_date) = 2016

use bank
--10. Hiển thị tên thành phố/tỉnh của khách hàng
select Cust_ad,
case
	when Cust_ad like '%-%' and Cust_ad not like '%,%' 
	then trim('-, ' from substring(Cust_ad, len(Cust_ad) - charindex('-', reverse(Cust_ad)) + 1, len(Cust_ad)))

	when Cust_ad not like '%-%' and Cust_ad like '%,%'
	then trim('-, ' from substring(Cust_ad, len(Cust_ad) - charindex(',', reverse(Cust_ad)) + 1, len(Cust_ad)))
	
end as "TP"
from customer

with tp_table as 
	(
				select cust_ad,
				trim(
					'- ' from
				substring(
					replace(Cust_ad, ',', '-'),
					len( replace(Cust_ad, ',', '-') ) - charindex('-', reverse(replace(Cust_ad, ',', '-')) ) + 1,
					len(replace(Cust_ad, ',', '-'))
					)
					) as tp
				from customer
	)
select 
	t1.tp as tp_min_length, 
	t2.tp as tp_other
from 
	tp_table t1
	left join tp_table t2 
		on t1.tp like concat('%', t2.tp, '%') and t1.tp <> t2.tp
where 
	t2.tp is null
group by 
	t1.tp, t2.tp

--11. Ai là người thực hiện giao dịch 
--gửi tiền 
--vào ngày 27/09/2013, 
--họ thực hiện giao dịch đó ở chi nhánh nào,
--với lượng tiền bằng bao nhiêu
select customer.Cust_id, Cust_name, BR_name, t_amount, t_type
from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	inner join customer on account.Cust_id = customer.Cust_id
	inner join Branch on customer.Br_id = Branch.BR_id
where t_date = '2013-09-27' and t_type = 1

--12. Ông Nguyễn Lê Minh Quân đã thực hiện 
--những giao dịch nào? 
--Hãy đưa ra tên chi nhánh, 
--thời gian, 
--loại giao dịch 
--và số tiền mỗi lần giao dịch.
select t_id, Cust_name, BR_name, t_time, t_type, t_amount
from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	inner join customer on account.Cust_id = customer.Cust_id
	inner join Branch on customer.Br_id = Branch.BR_id
where Cust_name = N'Nguyễn Lê Minh Quân'

--13. Từ tháng 5 đến tháng 12 năm 2014, 
--chi nhánh Huế 
--có những khách hàng nào tới thực hiện giao dịch, 
--loại giao dịch là gì, 
--số tiền là bao nhiêu?
select t_id, BR_name, customer.Cust_id, Cust_name, t_type, t_date, t_amount
from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	inner join customer on account.Cust_id = customer.Cust_id
	inner join Branch on customer.Br_id = Branch.BR_id
where BR_name like N'%Huế%' 
and (t_date between '2014-12-05' and format(GETDATE(), 'yyyy-MM-dd'))

--14. Liệt kê những khách hàng 
--sử dụng số điện thoại của Viettel 
--và chưa thực hiện giao dịch nào
--NHÁP
select ac_no
from account c1
where not exists (select t_id
	from transactions
	where c1.ac_no = transactions.ac_no)
--
select cust_id, cust_name, Cust_phone
from customer c1
where not exists 
(
	select t_id
	from account c2, transactions c3
	where c1.Cust_id = c2.cust_id
	and c2.Ac_no = c3.ac_no
	)
and 
(
	Cust_phone LIKE '086%' OR Cust_phone LIKE '09[6,7,8]%'
	AND LEN(Cust_phone) = 10) 
	or (Cust_phone LIKE '03[2,3,4,5,6,7,8,9]%'
	AND LEN(Cust_phone) = 11
)
--
select customer.cust_id, cust_name, Cust_phone, t_id
from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	right join customer on account.cust_id = customer.Cust_id
where t_id is null 
	and
(
	Cust_phone LIKE '086%' OR Cust_phone LIKE '09[6,7,8]%'
	AND LEN(Cust_phone) = 10) 
	or (Cust_phone LIKE '03[2,3,4,5,6,7,8,9]%'
	AND LEN(Cust_phone) = 11
)

--15. Hiển thị danh sách khách hàng 
--đăng kí sử dụng dịch vụ của ngân hàng
--ở chi nhánh khác nơi ở của họ 
--(chỉ tính khác ở mức thành phố).
select Cust_id, Cust_name, Cust_ad, br_name, substring(br_name, charindex(' ', br_name) + 1, len(br_name)) 'TP of Branch'
from customer join Branch on customer.Br_id = Branch.BR_id
where cust_ad not like ('%' + substring(br_name, charindex(' ', br_name) + 1, len(br_name)) + '%')
-------Chú ý: có thể sử dụng concat('%', ..., '%')

--16. Hiển thị danh sách khách hàng 
--chưa cập nhật số điện thoại theo quy định mới của chính phủ 
--(những số điện thoại có 11 số)
select customer.Cust_id, Cust_name, Cust_phone
from customer
where len(Cust_phone) = 11

--17. Mùa xuân năm 2013, 
--có những khách hàng nào thực hiện giao dịch, 
--hiển thị loại giao dịch, lượng tiền giao dịch 
--và chi nhánh giao dịch của họ
select customer.Cust_id, Cust_name, t_type, t_amount, BR_name, t_date
from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	inner join customer on account.Cust_id = customer.Cust_id
	inner join Branch on customer.Br_id = Branch.BR_id
where datepart(quarter, t_date) = 1

--18.Hiển thị những giao dịch gửi tiền
--thực hiện vào ngày thứ 7 hoặc chủ nhật 
--(giao dịch bất thường)
--Use the day of the week and check for 1 (Sunday) or 7 (Saturday): SELECT DATEPART(DW, GETDATE()), SELECT DATENAME(DW, GETDATE())
select t_id, t_date, t_type, datename(dw, t_date) DayName
from transactions
where t_type = 1 
and datepart(dw, t_date) in (1, 7)

--19. Chi nhánh nào không có khách hàng
---c1
select BR_id, BR_name
from Branch c1
where not exists (
	select Cust_id 
	from customer c2
	where c1.BR_id = c2.Br_id 
	)
---c2
select branch.BR_id, Cust_id
from Branch
	left join customer on Branch.BR_id = customer.Br_id
where Cust_id is null

--20.Tài khoản nào chưa từng thực hiện giao dịch
---c1
select Ac_no, cust_id
from account c1
where not exists (
	select t_id
	from transactions c2
	where c1.Ac_no = c2.ac_no
	)
---c2
select account.ac_no, cust_id, t_id
from account
	left join transactions on account.Ac_no = transactions.ac_no
where t_id is null
