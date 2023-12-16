
-- 1. Viết đoạn code thực hiện 
-- việc chuyển đổi đầu số điện thoại di động 
-- theo quy định của bộ Thông tin và truyền thông 
-- cho một khách hàng bất kì, ví dụ với: Dương Ngọc Long
declare @phone varchar(15)
select @phone=Cust_phone from customer where Cust_name=N'Dương Ngọc Long'
print @phone

set @phone= case when @phone like '016[2,3,4,5,6,7,8,9]%' then replace(@phone,'016','03')
				when @phone like '012[0,2,6,8]%' then replace(@phone,'012','07')
				when @phone like '0121%' then replace(@phone,'0121','079')
				when @phone like '0127%' then replace(@phone,'0127','081')
				when @phone like '0129%' then replace(@phone,'0129','082')
				when @phone like '012[3,4,5]%' then replace(@phone,'012','08')
				when @phone like '018[6,8]%' then replace(@phone,'018','05')
				else replace(@phone,'0199','059')
			end 
print @phone
-- 2. Trong vòng 10 năm trở lại đây 
-- Nguyễn Lê Minh Quân 
-- có thực hiện giao dịch nào không? 
-- Nếu có, hãy trừ 50.000 phí duy trì tài khoản.

-- Cô đã chữa, nhưng cô nói chưa đúng lắm
declare @solgGD varchar(5), @sodu int
set @sodu = 
	(
	select distinct ac_balance
	from transactions
		join account on transactions.ac_no = account.Ac_no
		join customer on account.cust_id = customer.Cust_id
	where Cust_name = N'Nguyễn Lê Minh Quân' and (datediff(yy,t_date, getdate()) < 10))
set @solgGD = 
	(
	select count(t_id)
	from transactions
		join account on transactions.ac_no = account.Ac_no
		join customer on account.cust_id = customer.Cust_id
	where Cust_name = N'Nguyễn Lê Minh Quân' and (datediff(yy,t_date, getdate()) < 10)
	group by Cust_name)
if @solgGD > 0
	begin
		set @sodu -= 50000
		print N'Số giao dịch KH đã thực hiện là: ' + cast(@solgGD as varchar(20))
		print N'Số dư tài khoản sau khi bị trừ là: ' +  cast(@sodu as varchar(20))
	end
else 
	begin
		print N'KH không thực hiện giao dịch nào'
	end 
--Tài tự chữa lại
declare @bgGD table (tenKH nvarchar(20), soTK varchar(20), ac_balance int, solgGD int)
insert into @bgGD (tenKH, soTK, ac_balance, solgGD)
select 
	customer.Cust_name, 
	account.ac_no, 
	ac_balance, 
	count(t_id)
from transactions
	join account on transactions.ac_no = account.Ac_no
	join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Nguyễn Lê Minh Quân' and (datediff(yy,t_date, getdate()) < 10)
group by customer.cust_id, Cust_name, account.ac_no, ac_balance
select 	*,
		case when solgGD > 0 then ac_balance - 50000 
			else ac_balance 
		end as new_ac_balance
from @bgGD
--c2
declare @TienTrongTk int,
	@SoluongGD int
select @TienTrongTK = ac_balance,
	@SoluongGD = count(t_id)
from account join transaction on account.Ac_no = tran
--3. Trần Quang Khải thực hiện giao dịch 
-- gần đây nhất
-- vào thứ mấy? (thứ hai, thứ ba, thứ tư,…, chủ nhật)
-- và vào mùa nào (mùa xuân, mùa hạ, mùa thu, mùa đông)?
declare @dayofweek varchar(1), @season varchar(1), @thu nvarchar(20), @mua nvarchar(20)
select top 1 @dayofweek = datepart(dw, t_date), @season = datepart(q, t_date)
from transactions 	join account on transactions.ac_no = account.Ac_no	
					join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Trần Quang Khải'
order by t_date desc, t_time desc
set @thu = 
		case @dayofweek 
			when 1 then N'Chủ nhật'
			when 2 then N'Thứ hai'
			when 3 then N'Thứ ba'
			when 4 then N'Thứ tư'
			when 5 then N'Thứ năm'
			when 6 then N'Thứ sáu'
			else N'Thứ bảy'
			end
set @mua = case @season 
				when 1 then N'Mùa xuân'
				when 2 then N'Mùa hạ'
				when 3 then N'Mùa thu'
				else N'Mùa đông'
			end
print N'Trần Quang Khải' + N' thực hiện giao dịch gần đây nhất vào ' + @thu + N' và vào ' + @mua

-- 4. Đưa ra nhận xét 
-- về nhà mạng mà 
-- Lê Anh Huy đang sử dụng? 
-- (Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)
declare @nx nvarchar(50), @cust_phone varchar(11)
select @cust_phone = Cust_phone
from customer 
where Cust_name = N'Lê Anh Huy'
set @nx = 
case 
	when 
		@cust_phone like '016[2-9]%' 
		or @cust_phone like '09[6-8]%' 
		or  @cust_phone like '03[2-9]%' 
		or @cust_phone like '086%'
		then 'Viettel'
	when @cust_phone like '012[01268]%' or @cust_phone like '07[0,6-9]%'
		then 'Mobifone'
	when @cust_phone like '012[3-9]%' or @cust_phone like '08[1-5]%'
		then'Vinaphone'
	when @cust_phone like '018[68]%' or @cust_phone like '05[68]%' 
		then 'Vietnamobile'
	else N'Khác'
end
print N'đang sử dụng ' + @nx

-- 5. Số điện thoại của Trần Quang Khải 
-- là số tiến, số lùi hay số lộn xộn. 
-- Định nghĩa: trừ 3 số đầu tiên, các số còn lại tăng dần gọi là số tiến, 
-- ví dụ: 098356789 là số tiến

-- 6. Hà Công Lực thực hiện giao dịch 
-- gần đây nhất vào buổi nào(sáng, trưa, chiều, tối, đêm)?
declare @gio int, @buoi nvarchar(15)
select top 1 @gio = datepart(hour, t_time)
from transactions
	join account on transactions.ac_no = account.Ac_no
	join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Hà Công Lực'
order by t_date desc, t_time desc
set @buoi = 
	case 
		when @gio >= 5 and @gio < 10 then N'sáng'
		when @gio >= 10 and @gio < 14 then N'trưa'
		when @gio >= 14 and @gio < 17 then N'chiều'
		when @gio >= 17 and @gio < 21 then N'tối'
		else N'đêm' 
    end 
print N'Hà Công Lực giao dịch gần đây nhất vào buổi ' + @buoi

-- 7. Chi nhánh ngân hàng 
-- mà Trương Duy Tường đang sử dụng 
-- thuộc miền nào? 
-- Gợi ý: nếu mã chi nhánh là VN -> miền nam, VT -> miền trung, VB -> miền bắc, 
-- còn lại: bị sai mã
declare @mien nvarchar(15), @br_id varchar(10)
select @br_id = branch.Br_id
from Branch join customer on Branch.BR_id = customer.Br_id
where Cust_name = N'Trương Duy Tường'
set @mien = 
	case 
		when @br_id like 'VN%' then N'miền nam'
		when @br_id like 'VT%' then N'miền trung'
		when @br_id like 'VB%' then N'miền bắc'
		else N'bị sai mã'
	end
print N'đang sử dụng chi nhánh ' + @mien

-- 8. Căn cứ vào số điện thoại của Trần Phước Đạt, 
-- hãy nhận định anh này dùng dịch vụ di động của hãng nào: Viettel, Mobi phone, Vina phone, hãng khác.
declare @nx nvarchar(50), @cust_phone varchar(11)
select @cust_phone = Cust_phone
from customer 
where Cust_name = N'Trần Phước Đạt'
set @nx = 
case 
	when 
		@cust_phone like '016[2-9]%' 
		or @cust_phone like '09[6-8]%' 
		or  @cust_phone like '03[2-9]%' 
		or @cust_phone like '086%'
		then 'Viettel'
	when @cust_phone like '012[01268]%' or @cust_phone like '07[0,6-9]%'
		then 'Mobifone'
	when @cust_phone like '012[3-9]%' or @cust_phone like '08[1-5]%'
		then'Vinaphone'
	when @cust_phone like '018[68]%' or @cust_phone like '05[68]%' 
		then 'Vietnamobile'
	else N'Khác'
end
print N'đang sử dụng ' + @nx

-- 9. Hãy nhận định Lê Anh Huy
-- ở vùng nông thôn hay thành thị. 
-- Gợi ý: nông thôn thì địa chỉ thường 
-- có chứa chữ “thôn” hoặc “xóm” hoặc “đội” hoặc “xã” hoặc “huyện”
declare @cust_ad nvarchar(50), @ret nvarchar(50)
select @cust_ad = Cust_ad
from customer 
where Cust_name = N'Lê Anh Huy'
set @ret = case 
				when @cust_ad like N'%thôn%'
					or @cust_ad like N'%xóm%'
					or @cust_ad like N'%đội%'
					or (@cust_ad like N'%xã' and @cust_ad not like '%thị xã%')
					or @cust_ad like N'%huyện%'
				then N'nông thôn'
				else N'thành thị'
			end
print N'Lê Anh Huy ở ' + @ret

-- 10. Hãy kiểm tra tài khoản của Trần Văn Thiện Thanh,
-- nếu tiền trong tài khoản của anh ta nhỏ hơn không hoặc bằng không 
-- nhưng 6 tháng gần đây 
-- không có giao dịch 
-- thì hãy đóng tài khoản bằng cách cập nhật ac_type = ‘K’
declare @ac_balance int, @soGD int
select @ac_balance = ac_balance, @soGD = count(t_id) 
from transactions
	join account on transactions.ac_no = account.Ac_no
	join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Trần Văn Thiện Thanh' 
	and datediff(month, t_date, getdate()) <= 6 
	and ac_balance <= 0
group by account.ac_no, account.ac_balance
if @soGD = 0 
	begin
		print N'Số dư tài khoản: ' + @ac_balance 
		print N'Khách hàng chưa thực hiện giao dịch trong 6 tháng vừa qua'
		update account
		set ac_type = 'K' from transactions
							join account on transactions.ac_no = account.Ac_no
							join customer on account.cust_id = customer.Cust_id
							where Cust_name = N'Trần Văn Thiện Thanh'
		print N'Tài khoản đã bị khoá'
	end 
else 
	begin
		print N'Tài khoản hoạt động bình thường'
	end

--11. Mã số giao dịch 
--gần đây nhất của Huỳnh Tấn Dũng là số chẵn hay số lẻ? 
declare @maGD int
set @maGD = (
		select top 1 t_id 
		from transactions
			join account on transactions.ac_no = account.Ac_no
			join customer on account.cust_id = customer.Cust_id
		where Cust_name = N'Huỳnh Tấn Dũng'
		order by t_date desc, t_time desc)
if @maGD % 2 = 0
begin
	print 'So chan'
end 
else 
begin
	print 'So le'
end

-- 12. Có bao nhiêu giao dịch 
-- diễn ra trong tháng 9/2016 
-- với tổng tiền mỗi loại là bao nhiêu 
-- (bao nhiêu tiền rút, bao nhiêu tiền gửi)
declare @solngGD int, @tienrut int, @tiengui int
select 
	@solngGD = count(t_id), 
	@tienrut = sum(case when t_type = 0 then t_amount else 0 end),
	@tiengui = sum(case when t_type = 1 then t_amount else 0 end)
from transactions
where year(t_date) = 2016 and month(t_date)= 9
print N'Số lượng giao dịch: ' +  cast(@solngGD as varchar(5))
print N'Tổng tiền rút: ' +  cast(@tienrut as varchar(15))
print N'Tổng tiền gửi: ' +  cast(@tiengui as varchar(15))

-- 13. Ở Hà Nội ngân hàng Vietcombank 
-- có bao nhiêu chi nhánh 
-- và có bao nhiêu khách hàng? 
-- Trả lời theo mẫu: “Ở Hà Nội, Vietcombank có … chi nhánh và có …khách hàng”

declare @br_count int, @cust_count int 
select 
	@br_count = count(distinct branch.Br_id), @cust_count = count(distinct customer.cust_id)
from Branch 
	join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
where br_name like N'%Hà Nội%' and br_name like '%Vietcombank%'
group by branch.Br_id
print N'Ở Hà Nội, Vietcombank có ' + cast(@br_count as varchar(15)) + N' chi nhánh và có ' + cast(@cust_count as varchar(15)) + N' khách hàng'
select * from branch
go 

select *
from Branch 
	join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
where br_name like N'%Hà Nội%' and br_name like '%Vietcombank%'
go
-- 14. Tài khoản có nhiều tiền nhất là của ai, 
-- số tiền hiện có trong tài khoản đó là bao nhiêu? 
-- Tài khoản này thuộc chi nhánh nào?
declare @ac_no nvarchar(10), @custname nvarchar(20), @acbalance int, @brname nvarchar(30)
select 
	top 1 @ac_no = account.ac_no, @custname = Cust_name, @acbalance = ac_balance, @brname = BR_name
from transactions 
	inner join account on transactions.ac_no = account.Ac_no
	inner join customer on account.Cust_id = customer.Cust_id
	inner join Branch on customer.Br_id = Branch.BR_id
order by ac_balance desc
print N'Tài khoản có nhiều tiền nhất là của ' + @custname
print N'Số tiền hiện có trong tài khoản đó là '+ cast(@acbalance as varchar)
print N'Tài khoản này thuộc ' + @brname

-- 15. Có bao nhiêu khách hàng ở Đà Nẵng?
declare @count_cust int
select 
	@count_cust = count(customer.cust_id)
from customer
where Cust_ad like N'%Đà Nẵng%' 
print N'Số khách hàng ở Đà Nẵng: ' + cast(@count_cust as varchar)

-- 16. Có bao nhiêu khách hàng ở Quảng Nam nhưng mở tài khoản Sài Gòn
declare @count_cus int
select @count_cus = count(customer.cust_id)
from account 
	join customer on account.Cust_id = customer.Cust_id
	join Branch on customer.Br_id = Branch.BR_id
where Cust_ad like N'%Quảng Nam%' and BR_name like N'Sài Gòn'
print N'Số khách hàng ở Quảng Nam nhưng mở tài khoản Sài Gòn: ' + cast(@count_cus as varchar)

-- 17. Ai là người thực hiện giao dịch 
-- có mã số 0000000387, 
-- thuộc chi nhánh nào? 
-- Giao dịch này thuộc loại nào?
declare @cusname nvarchar(25), @br_name nvarchar(25), @type varchar(1)
select 
	@cusname= Cust_name, @br_name = branch.BR_name, @type = t_type
from transactions 
	join account on transactions.ac_no = account.Ac_no
	join customer on account.Cust_id = customer.Cust_id
	join Branch on customer.Br_id = Branch.BR_id
where t_id = '0000000387'
print @cusname
print @br_name
print @type

-- 18. Hiển thị danh sách khách hàng gồm: 
-- họ và tên, 
-- số điện thoại, 
-- số lượng tài khoản đang có 
-- và nhận xét. Nếu < 1 tài khoản -> “Bất thường”, còn lại “Bình thường”
declare @dsKH table (hovaten nvarchar(25), custphone varchar(11), solgTK int, nxet nvarchar(15))
insert into @dsKH 
select cust_name, 
	Cust_phone, 
	count(Ac_no),
	case 
		when count(Ac_no) < 1 then N'Bất thường'
		else N'Bình thường'
	end as nxet
from account
	join customer on account.cust_id = customer.Cust_id 
group by cust_name, Cust_phone
select * from @dsKH

-- 19. Viết đoạn code 
-- nhận xét tiền trong tài khoản của ông Hà Công Lực. 
-- <100.000: ít, < 5.000.000: trung bình, còn lại: nhiều
declare @tienTK int, @nhxet nvarchar(25)
select @tienTK = ac_balance 
from transactions
	join account on transactions.ac_no = account.Ac_no
	join customer on account.cust_id = customer.Cust_id
where cust_name = N'Hà Công Lực'
set @nhxet =
	case 
		when @tienTK < 100000 then N'ít'
		when @tienTK < 5000000 then N'trung bình'
		else N'nhiều'
	end
print @nhxet

-- 20. Hiển thị danh sách các giao dịch 
-- của chi nhánh Huế với các thông tin: 
-- mã giao dịch,
-- thời gian giao dịch, 
-- số tiền giao dịch, 
-- loại giao dịch (rút/gửi), 
-- số tài khoản. 
-- Ví dụ:
-- Mã giao dịch		Thời gian GD		Số tiền GD		Loại GD		Số tài khoản
-- 00133455	 		2017-11-30 09:00	3000000			Rút			04847374948
declare @dsGD table (
	maGD varchar(20), 
	tgGD varchar(20), 
	sotienGD int, 
	loaiGD nvarchar(10), 
	soTK varchar(20))
insert into @dsGD(maGD, tgGD, sotienGD, loaiGD, soTK)
select 
	t_id, 
	format(cast(t_date as datetime) + cast(t_time as datetime), 'yyyy-MM-dd hh:mm'), 
	t_amount, 
	t_type, 
	account.ac_no
from transactions	join account on transactions.ac_no = account.Ac_no
					join customer on account.cust_id = customer.Cust_id
					join Branch on customer.Br_id = Branch.BR_id
where BR_name like N'%Huế%'
update @dsGD set loaiGD =	case loaiGD when '0' then N'Rút' 
										else N'Gửi' 
							end
select * from @dsGD

-- 21. Kiểm tra xem khách hàng 
-- Nguyễn Đức Duy có ở 
-- Quảng Nam hay không?
declare @noisong nvarchar(10)
set @noisong = (select cust_ad from customer where Cust_name = N'Nguyễn Đức Duy')
if @noisong like '%Quảng Nam%'
	begin
		print N'Có' 
	end
else 
	begin
		print N'Không' 
	end

-- 22. Điều tra số tiền 
-- trong tài khoản ông Lê Quang Phong 
-- có hợp lệ hay không? 
-- (Hợp lệ: tổng tiền gửi – tổng tiền rút = số tiền hiện có trong tài khoản). 
-- Nếu hợp lệ, đưa ra thông báo “Hợp lệ”, 
-- ngược lại hãy cập nhật lại tài khoản sao cho số tiền trong tài khoản khớp với tổng số tiền đã giao dịch 
-- (ac_balance = sum(tổng tiền gửi) – sum(tổng tiền rút)
declare @bangGD table (ac_no varchar(10), ac_balance int, tiengui int, tienrut int, ghichu nvarchar(20))
insert into @bangGD(ac_no, ac_balance, tiengui, tienrut, ghichu)
select 
	account.Ac_no,
	ac_balance,  
	sum(case when t_type = 1 then t_amount else 0 end) as deposit,
	sum(case when t_type = 0 then t_amount else 0 end) as withdraw,
	case 
		when sum(case when t_type = 1 then t_amount else 0 end) - sum(case when t_type = 0 then t_amount else 0 end) <> ac_balance 
		then N'Không hợp lệ'
		else N'Hợp lệ'
	end
from transactions	join account on transactions.ac_no = account.Ac_no
					join customer on account.cust_id = customer.Cust_id
where cust_name = N'Lê Quang Phong'
group by account.Ac_no, ac_balance
select * from @bangGD
update @bangGD
set ac_balance = tiengui - tienrut, ghichu = N'Hợp lệ'
	where ghichu = N'Không hợp lệ'
select * from @bangGD

-- 23. Chi nhánh Đà Nẵng 
-- có giao dịch 
-- gửi tiền nào 
-- diễn ra vào ngày chủ nhật hay không? 
-- Nếu có, hãy hiển thị số lần giao dịch, 
-- nếu không, hãy đưa ra thông báo “không có”
declare @soluongGD int
select @soluongGD = count(t_id)
from transactions	join account on transactions.ac_no = account.Ac_no
					join customer on account.cust_id = customer.Cust_id
					join Branch on customer.Br_id = Branch.BR_id
where BR_name like '%Đà Nẵng%' and datepart(dw, t_date) = 1 and t_type = 1
if @soluongGD > 0 
	print @soluongGD
else 
	print N'Không có'

-- 24. Kiểm tra xem khu vực miền bắc 
-- có nhiều phòng giao dịch 
-- hơn khu vực miền trung ko? 
-- Miền bắc có mã bắt đầu bằng VB, miền trung có mã bắt đầu bằng VT
declare @solgMB int, @solgMT int
select @solgMB = count(BR_id) 
from Branch
where br_id like 'VB%'
select @solgMT = count(BR_id) 
from Branch
where br_id like 'VT%'
if @solgMB > @solgMT
	begin print N'Miền bắc có nhiều phòng giao dịch hơn khu vực miền trung' end
else if @solgMB < @solgMT 
	begin print N'Miền bắc có ít phòng giao dịch hơn khu vực miền trung' end
else 
	begin print N'Miền bắc có số phòng giao dịch bằng khu vực miền trung' end

-- Vòng Lặp
-- 1. In ra dãy số lẻ từ 1 – n, với n là giá trị tự chọn
declare @i int, @n int
set @i = 1 
set @n = 100
while @i < @n
begin
	if @i % 2 <> 0
	begin
		print @i
		set @i += 1
	end
	else
	begin
		set @i += 1 
	end 
end
-- 2. In ra dãy số chẵn từ 0 – n, với n là giá trị tự chọn
declare @i int, @n int
set @i = 1 
set @n = 100
while @i < @n
begin
	if @i % 2 = 0
	begin
		print @i
		set @i += 1
	end
	else
	begin
		set @i += 1 
	end 
end
-- 3. In ra 100 số đầu tiền trong dãy số Fibonaci
declare 
	@n int = 100,
	@count int = 0,
	@f1 int = 0,
	@f2 int = 1,
	@fn int = 1
while @count < @n
	begin
		print @fn
		set @fn = @f1 + @f2
		set @f1 = @f2
		set @f2 = @fn
		set @count += 1
	end
-- 4. In ra tam giác sao: 1 tam giác vuông, 1 tam tam giác cân như ví dụ dưới đây:
-- *
-- **
-- ***
-- ****
-- *****
declare @star varchar(20), @count int
set @star = '*'
set @count = 1
while @count < 6
	begin
		print @star
		set @star += '*'
		set @count += 1
	end

-- 5. In bảng cửu chương