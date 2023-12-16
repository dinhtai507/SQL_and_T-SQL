--1. Trả về tên chi nhánh ngân hàng nếu biết mã của nó
create or alter proc spGetBrName_292 @macn varchar(10), @ten nvarchar(100)  out 
as
begin
    set @ten = (select br_name from branch where br_id = @macn)
end
go
--
declare @ten nvarchar(100)
exec spGetBrName_292 'VT009', @ten out
print @ten
go

-- 2. Trả về tên, 
-- địa chỉ, 
-- và số điện thoại của khách hàng 
-- nếu biết mã khách
create proc spCustInfo @makh varchar(10), 
    @tenkh nvarchar(20) output, @diachi nvarchar(100) output, @sdt varchar(11) output 
as
begin
    select @tenkh = cust_name, @diachi = cust_ad, @sdt = cust_phone from customer where Cust_id = @makh
end 
go 

declare @a nvarchar(20), @b nvarchar(100), @c varchar(11)
exec spCustInfo '000001', @a output, @b output, @c output 
print @a
print @b 
print @c
go 

-- 3. In ra danh sách khách hàng của một chi nhánh cụ thể 
-- nếu biết mã chi nhánh đó
create proc spGetListCust @macn varchar(10)
as 
begin
    select cust_id, cust_name, cust_ad, br_id from customer where Br_id = @macn
end 
go 

exec spGetListCust 'VT009'
go

-- 4. Kiểm tra một khách hàng nào 
-- đã tồn tại trong hế thống CSDL của ngân hàng chưa, 
-- biết: họ tên, số điện thoại của họ. 
-- Đã tồn tại trả về 1, ngược lại trả về 0
create proc spExists @ten nvarchar(20), @sdt varchar(11), @tontai int output
as 
begin
    if exists (select * from customer where Cust_name = @ten 
                                            and Cust_phone = @sdt)
        begin
            set @tontai = 1   
        end 
    else
        begin 
            set @tontai = 0
        end 
end
go 

declare @kq int 
exec spExists N'Hà Công Lực', '01283388103', @a output
print @kq
go

-- 5. Cập nhật số tiền trong tài khoản 
-- nếu biết mã số tài khoản 
-- và số tiền mới. 
-- Thành công trả về 1, thất bại trả về 0
create proc spUpdateAmount @sotk varchar(10), @new_balance money, @kq int out
as 
begin
    update account
    set ac_balance = @new_balance where Ac_no = @sotk
    set @kq =   case when @@ROWCOUNT > 0 then 1
                    else 0
                end 
end
go

declare @result int 
exec spUpdateAmount '1000000001', 88118000, @result output
print @result
go

-- 6. Cập nhật địa chỉ của khách hàng 
-- nếu biết mã số của họ. 
-- Thành công trả về 1, thất bại trả về 0
create proc spCapnhatDiachi @makh varchar(10), @diachi nvarchar(100), @kq int out 
as
begin 
    update customer
    set cust_ad = @diachi where Cust_id = @makh
    set @kq =   case when @@ROWCOUNT > 0 then 1
                    else 0
                end

end
go

declare @result int
exec spCapnhatDiachi '000001', N'NGUYỄN TIẾN DUẨN - THÔN 3 - XÃ DHÊYANG - EAHLEO - ĐĂKLĂK', @result out
print @result
go 

-- 7. Trả về số tiền có trong tài khoản nếu biết mã tài khoản.
create proc spGetAcBalance @ac_no varchar(10), @ac_balance int output
as  
begin 
    select @ac_balance = ac_balance from account
end
go

declare @ac_balance int
exec spGetAcBalance '1000000001', @ac_balance out
print @ac_balance
go
-- 8. Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh.
create or alter proc spGetBranchInfo @macn varchar(10), @soluongKH int out, @tongtienTK money out
as 
begin
    select @soluongKH = count(distinct customer.Cust_id), @tongtienTK = sum(ac_balance)
    from Branch 
        join customer on Branch.BR_id = customer.Br_id
        join account on customer.Cust_id = account.cust_id
    where branch.BR_id = @macn
end
go

declare @soluongKH int , @tongtienTK money 
exec spGetBranchInfo 'VT010', @soluongKH out, @tongtienTK out
print @soluongKH
print @tongtienTK
go

-- 9. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
-- Giao dịch bất thường: 
-- giao dịch gửi diễn ra ngoài giờ hành chính, 
-- giao dịch rút diễn ra vào thời điểm 0am -> 3am
-- if @t_type = '0' and (@time between '00:00:00' and '03:00:00')
--     set @kq = N'Bất thường' 
-- else if @t_type = '1' and ( (@time not between '07:30:00' and '11:30:00') or (@time not between '13:30:00' and '17:30:00') )
--     set @kq = N'Bất thường'
-- else 
--     set @kq = N'Bình thường'

create or alter proc spCheckDisnormality @maGD varchar(10), @kq nvarchar(30) output 
as 
begin
    declare @time time, @t_type varchar(1)
    select @time = t_time, @t_type = t_type from transactions where t_id = @maGD


    if @t_type = '1'
        begin
            if (@time between '07:30:00' and '12:00:00') or (@time between '13:30:00' and '16:00:00')
                begin
                    set @kq = 'Giao dich binh thuong'
                    return
                end
            else 
                begin
                    set @kq = 'Giao dich bat thuong'
                    return
                end 
        end 
    else --t_type = 0
        begin
            if @time between '00:00:00' and '03:00:00'
                begin
                    set @kq = 'Giao dich bat thuong'
                    return
                end
            else
                begin
                    set @kq = 'Giao dich binh thuong'
                    return
                end
        end
end
go

declare @ktr nvarchar(30)
exec spCheckDisnormality '0000000329', @ktr output
print @ktr
go

-- 10. Trả về mã giao dịch mới. 
-- Mã giao dịch tiếp theo được tính như sau: 
-- MAX(mã giao dịch đang có) + 1. 
-- Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
-- 0000000201 có chiều dài bằng 10
--c1 
create proc spUpdateTransID @newtransID varchar(12) output
as 
begin
    declare @latesttransID varchar(12)
    set @latesttransID = ( select top 1 t_id from transactions order by t_id desc )
    set @newtransID = cast( cast(@latesttransID as int) + 1 as varchar(10))
    set @newtransID = concat( replicate('0', len(@latesttransID) - len(@newtransID)), @newtransID)
end
go

declare @newtransID varchar(12) 
exec spUpdateTransID @newtransID output
print @newtransID
go 
--c2
create or alter proc spUpdateTransIDs @maGDmoi varchar(12) output
as 
begin
    declare @maGD varchar(12)
    set @maGD = (select max(t_id) from transactions)
    set @maGDmoi = @maGD + 1
    set @maGDmoi = replicate('0', len(@maGD) - len(@maGDmoi)) + @maGDmoi
end
go

declare @maGDmoi varchar(12) 
exec spUpdateTransIDs @maGDmoi output
print @maGDmoi
go 

/* 11. (Giữa kì) Thêm một bản ghi vào bảng TRANSACTIONS 
nếu biết các thông tin ngày giao dịch, thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch
Công việc cần làm bao gồm:
a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lí
b. Kiểm tra số tài khoản có tôn tại trong bảng ACCOUNT không ? Nếu không, ngừng xử lí
c. Kiểm tra loại giao dịch có phù hợp không ? Nếu không, ngừng xử lí
d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0) ? Nếu không, ngừng xử lí
e. Tính mã giao dịch mới
f. Thêm mới bản ghi vào bảng TRANSACTIONS
g. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch
*/

create proc spAddNewTransRecord @t_date date, @t_time time, @ac_no varchar(10), @t_type int, @t_amount money, @check nvarchar(50) output
as 
begin
    if @t_date < cast(getdate() as date) and @t_time < cast(getdate() as time)
        begin
            if @ac_no in (select ac_no from account)
                begin
                    if @t_type in (0,1)
                        begin
                            if @t_amount > 0 
                                begin
                                    if @t_type = '1'
                                        begin
                                            update account 
                                            set ac_balance = ac_balance + @t_amount where Ac_no = @ac_no
                                        end
                                    else if @t_type = '0' and @t_amount < ( select top 1 ac_balance 
                                                                            from account join transactions on account.Ac_no = transactions.ac_no
                                                                            where account.ac_no = @ac_no
                                                                            order by ac_balance desc)
                                        begin
                                            update account 
                                            set ac_balance = ac_balance - @t_amount where Ac_no = @ac_no 
                                        end
                                    else 
                                        begin
                                            set @check = 'Do have not amount of money to withdraw'
                                            return
                                        end
                                    declare @latest_id varchar(12), @new_trans_id varchar(12)
                                    set @latest_id = (select top 1 t_id from transactions order by t_id desc)
                                    set @new_trans_id = cast( cast(@latest_id as int) + 1 as varchar(12) )
                                    set @new_trans_id = replicate('0', len(@latest_id) - @new_trans_id) + @new_trans_id
                                    insert transactions 
                                    values (@new_trans_id, @t_type, @t_amount, @t_date, @t_time, @ac_no)
                                    set @check = 'Sucess'
                                end
                            else
                                begin 
                                    set @check = 'Invalid Transaction Amount'
                                    return
                                end 
                        end
                    else 
                        begin
                            set @check = 'Invalid Transaction Type' 
                            return
                        end 
                end
            else
                begin 
                    set @check = 'Invalid Transaction ID'
                    return
                end
        end
    else   
        begin
            set @check = 'Invalid Transaction Date'
            return
        end
end
go

declare @check nvarchar(50)
exec spAddNewTransRecord '2023-03-10', '00:00:00', '1000000001', '0', 88118001, @check output
print @check
go

/* 12. Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. 
Bao gồm những công việc sau:
a.	Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
b.	Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
c.	Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
d.	Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
e.	Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có. */
create proc spAddNewAccount @cust_id varchar(12), @ac_type int, @ac_balance int, @check nvarchar(20) output
as 
begin
    if @cust_id in (select cust_id from customer)
        begin 
            if @ac_type in (0, 1)
                begin
                    if @ac_balance is null
                        begin 
                            set @ac_balance = 50000
                        end
                    else if @ac_balance < 0
                        begin
                            set @check = 'Invalid Account Balance'
                            return
                        end
                    declare @latest_ac_no varchar(12), @new_acc_no varchar(12)
                    set @latest_ac_no = (select top 1 ac_no from account order by Ac_no desc)
                    set @new_acc_no = cast( cast(@latest_ac_no as int) + 1 as varchar(12))
                    set @new_acc_no = replicate('0', len(@latest_ac_no) - len(@new_acc_no)) + @new_acc_no
                    insert account
                    values (@new_acc_no, @ac_balance, @ac_type, @cust_id)
                    set @check = 'Success'
                end 
            else 
                begin
                    set @check = 'Invalid Transaction Type'
                    return
                end 
        end
    else 
        set @check = 'Invalid Customer ID '
        return
end
go 

declare @check varchar(20)
exec spAddNewAccount '000001', '1', null, @check output
print @check
go

/* 12. Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. 
Bao gồm những công việc sau:
a.	Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
b.	Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
c.	Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
d.	Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
e.	Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có. */
-- Lúc nào sử dụng insert hay delete thì cũng cần phải kiểm tra nó có chạy được hay ko (bằng cách sử dụng @@ROWCOUNT) 

create or alter proc spCau12 @maKH varchar(12), @loaiTK int, @sotienTK money, @kq int output
as 
begin 
    --a. Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa?
    if not exists (select cust_id from customer where cust_id = @maKH)
        begin
            set @kq = 0
            return
        end
    --b. Kiểm tra loại tài khoản có hợp lệ không?
    if @loaiTK not in (0, 1)
        begin
            set @kq = 0
            return
        end
    
    --c. Kiểm tra số tiền có hợp lệ không?
    if @sotienTK is null 
        begin
            set @sotienTK = 50000
        end
    else if @sotienTK < 0
        begin  
            set @kq = 0 
            return
        end

    -- d. Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
    -- nghĩa là else if @sotienTK >= 0 
    declare @soTK varchar(12), @soTKmoi varchar(12)
    set @soTK = (select max(ac_no) from account)
    set @soTKmoi = @soTK + 1 

    -- e. Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có. */
    -- Lúc nào sử dụng insert hay delete thì cũng cần phải kiểm tra nó có chạy được hay ko (bằng cách sử dụng @@ROWCOUNT) 
    insert account
    values(@soTKmoi, @sotienTK, @loaiTK, @maKH)
    if @@ROWCOUNT > 0
        begin 
            set @kq = 1 -- thanh cong
        end
    else
        begin 
            set @kq = 0
        end
end
go 

declare @kq int
exec spCau12 '000001', '1', null, @kq output
print @kq
go

/* 11. (Giữa kì) Thêm một bản ghi vào bảng TRANSACTIONS nếu biết
các thông tin ngày giao dịch, thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch
Công việc cần làm bao gồm:
a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lí
b. Kiểm tra số tài khoản có tôn tại trong bảng ACCOUNT không ? Nếu không, ngừng xử lí
c. Kiểm tra loại giao dịch có phù hợp không ? Nếu không, ngừng xử lí
d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0) ? Nếu không, ngừng xử lí
e. Tính mã giao dịch mới
f. Thêm mới bản ghi vào bảng TRANSACTIONS
g. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch
*/
create or alter proc spInsertTran    @ngayGD date,
                            @thoigian time,
                            @stk varchar(12),
                            @loaiGD int,
                            @sotien money,
                            @kq int out
as
begin
    -- a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không
    if @ngayGD > getdate() and @thoigian > cast(getdate() as time)
    begin 
        set @kq = 0
        return 
    end 

    -- b. Kiểm tra số tài khoản có tôn tại trong bảng ACCOUNT không ?
    if not exists (select ac_no from account where Ac_no = @stk)
    begin
        set @kq = 0
        return
    end

    -- c. Kiểm tra loại giao dịch có phù hợp không ?
    if @loaiGD not in (0,1)
    begin
        set @kq = 0
        return
    end

    -- d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0) ?
    if @sotien <= 0
    begin
        set @kq = 0
        return 
    end 

    declare @ac_balance_new money 
    if @loaiGD = 1
    begin
        set @ac_balance_new = ac_balance + @sotien
    end
    else if @loaiGD = 0 and @sotien < (select ac_balance from account where ac_no = @stk)
        begin
            set @ac_balance_new = ac_balance - @sotien
        end
    else
        begin
            set @kq = 0 
            return
        end

    -- e. Tính mã giao dịch mới
    declare @maGD varchar(12), @maGDmoi varchar(12)
    set @maGD = (select max(t_id) from transactions)
    set @maGDmoi = @maGD + 1
    set @maGDmoi = replicate('0', len(@maGD) - len(@maGDmoi)) + @maGDmoi

    -- f. Thêm mới bản ghi vào bảng TRANSACTIONS
    insert transactions
    values (@maGDmoi, @loaiGD, @sotien, @ngayGD, @thoigian, @stk)
    if @@ROWCOUNT > 0
        begin 
            set @kq = 1 -- thanh cong
        end
    else 
        begin
            set @kq = 0
        end
    -- g. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch
    update account
    set ac_balance = @ac_balance_new
end
go 

declare @kq nvarchar(50)
exec spInsertTran '2023-03-10', '00:00:00', '1000000001', '0', 88118000, @kq output
print @kq
go

select * from transactions go
select * from account go