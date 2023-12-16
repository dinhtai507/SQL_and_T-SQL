-- HÀM
-- 1. Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa nếu biết họ tên và số điện thoại. 
-- Tồn tại trả về 1, không tồn tại trả về 0

create or alter function fGetCustExists (@hoten nvarchar(30), @sdt varchar(12))
returns int
as 
begin
    declare @kq int
    if exists (select * from customer where Cust_name = @hoten and Cust_phone = @sdt)
        begin 
            set @kq = 1
        end
    else
        begin
            set @kq = 0
        end
    return @kq
end
go 

print dbo.fGetCustExists(N'Hà Công Lực', '01283388103')
go

-- 2. Tính mã giao dịch mới. 
-- Mã giao dịch tiếp theo được tính như sau: 
-- MAX(mã giao dịch đang có) + 1. 
-- Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
create or alter function fUpdateTransID()
returns varchar(12)
as
begin
    declare @maGD varchar(12), @maGDmoi varchar(12)
    set @maGD = (select max(t_id) from transactions)
    set @maGDmoi = @maGD + 1
    set @maGDmoi = replicate('0', len(@maGD) - len(@maGDmoi)) + @maGDmoi
    return @maGDmoi
end
go 

print dbo.fUpdateTransID()
go

-- 3. Tính mã tài khoản mới. (định nghĩa tương tự như câu trên)
create or alter function dbo.fUpdateAccNo()
returns varchar(12)
as
begin
    declare @soTK varchar(12), @soTKmoi varchar(12)
    set @soTK = (select max(ac_no) from account)
    set @soTKmoi = @soTK + 1 
    return @soTKmoi
end
go 

print dbo.fUpdateAccNo()
go

-- 4. Trả về tên chi nhánh ngân hàng nếu biết mã của nó.
create or alter function fGetBrName (@macn varchar(10)) 
returns nvarchar(100)  
as
begin
    declare @ten nvarchar(100)
    set @ten = (select br_name from branch where br_id = @macn)
    return @ten
end
go

print dbo.fGetBrName('VT009')
go

-- 5. Trả về tên của khách hàng nếu biết mã khách.
create or alter function fCustInfo (@makh varchar(10))
returns nvarchar(20)
begin
    declare @tenkh nvarchar(20)
    select @tenkh = cust_name from customer where Cust_id = @makh
    return @tenkh
end 
go 

print dbo.fCustInfo('000001')
go 

-- 6. Trả về số tiền có trong tài khoản nếu biết mã tài khoản.
create or alter function fGetAcBalance (@ac_no varchar(10))
returns int
as  
begin 
    declare @ac_balance int 
    select @ac_balance = ac_balance from account
    return @ac_balance
end
go

print dbo.fGetAcBalance('1000000001')
go

-- 7. Trả về số lượng khách hàng nếu biết mã chi nhánh.
create or alter function fCustCountInfo (@macn varchar(10))
returns int 
as
begin
    declare @soluongKH int, @tongtienTK money
    select @soluongKH = count(distinct customer.Cust_id), @tongtienTK = sum(ac_balance)
    from Branch 
        join customer on Branch.BR_id = customer.Br_id
        join account on customer.Cust_id = account.cust_id
    where branch.BR_id = @macn
    return @soluongKH
end
go

print dbo.fCustCountInfo('VT010')
go

-- 8. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
-- Giao dịch bất thường: 
-- giao dịch gửi diễn ra ngoài giờ hành chính, 
-- giao dịch rút diễn ra vào thời điểm 0am -> 3am

create or alter function fCheckDisnormality (@maGD varchar(10)) 
returns nvarchar(30) 
as 
begin
    declare @time time, @t_type varchar(1), @kq nvarchar(30)
    select @time = t_time, @t_type = t_type from transactions where t_id = @maGD
    if @t_type = '1'
        begin
            if (@time between '07:30:00' and '12:00:00') or (@time between '13:30:00' and '16:00:00')
                begin
                    set @kq = 'Giao dich binh thuong'
                end
            else 
                begin
                    set @kq = 'Giao dich bat thuong'
                end 
        end 
    else --t_type = 0
        begin
            if @time between '00:00:00' and '03:00:00'
                begin
                    set @kq = 'Giao dich bat thuong'
                end
            else
                begin
                    set @kq = 'Giao dich binh thuong'
                end
        end
    return @kq
end
go

print dbo.fCheckDisnormality('0000000329')
go

-- THỦ TỤC + HÀM
-- 1. Trả về tên chi nhánh ngân hàng nếu biết mã của nó.
-- a. Thủ tục
create or alter proc spGetBrName @macn varchar(10), @ten nvarchar(100)  out 
as
begin
    set @ten = (select br_name from branch where br_id = @macn)
end
go

declare @ten nvarchar(100)
exec spGetBrName 'VT009', @ten out
print @ten
go
-- b. Hàm
create or alter function fGetBrName (@macn varchar(10)) 
returns nvarchar(100)  
as
begin
    declare @ten nvarchar(100)
    set @ten = (select br_name from branch where br_id = @macn)
    return @ten
end
go

print dbo.fGetBrName('VT009')
go

-- 2. Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã khách.
-- a. Thủ tục 
create or alter proc spCustInfo @makh varchar(10), 
    @tenkh nvarchar(20) output, @diachi nvarchar(100) output, @sdt varchar(11) output 
as
begin
    select @tenkh = cust_name, @diachi = cust_ad, @sdt = cust_phone from customer where Cust_id = @makh
end 
go 

declare @tenkh nvarchar(20), @diachi nvarchar(100), @sdt varchar(11)
exec spCustInfo '000001', @tenkh output, @diachi output, @sdt output 
print @tenkh
print @diachi 
print @sdt
go 

-- b. Hàm 
create or alter function fGetCustInfo (@makh varchar(12)) 
returns table
as
return (select cust_id, cust_name, cust_ad, cust_phone from customer where Cust_id = @makh)
go 

select * from dbo.fGetCustInfo('000001')
go

-- 3. In ra danh sách khách hàng của một chi nhánh cụ thể nếu biết mã chi nhánh đó.
-- a. Thủ tục
create or alter procedure spGetCustList (@macn varchar(10))
as
begin
    select Cust_name 
    from Branch 
        join customer on Branch.BR_id = customer.Br_id
        join account on customer.Cust_id = account.cust_id
    where branch.BR_id = @macn
end
go 

exec dbo.spGetCustList 'VT010'
go
-- b. Hàm
create or alter function fGetCustList (@macn varchar(10))
returns table
as
return
    select Cust_name 
    from Branch 
        join customer on Branch.BR_id = customer.Br_id
        join account on customer.Cust_id = account.cust_id
    where branch.BR_id = @macn
go 

select * from dbo.fGetCustList('VT010')
go

-- 4. Kiểm tra một khách hàng nào đó đã tồn tại trong hệ thống CSDL của ngân hàng chưa 
-- nếu biết: họ tên, số điện thoại của họ. 
-- Đã tồn tại trả về 1, ngược lại trả về 0
-- a. Thủ tục
create or alter proc spGetCustInfo292 @hoten nvarchar(30), @sdt varchar(12), @kq int output
as
begin
    if exists (select * from customer where Cust_name = @hoten and Cust_phone = @sdt)
        begin 
            set @kq = 1
        end
    else
        begin
            set @kq = 0
        end
end
go

declare @kq int
exec spGetCustInfo292 N'Hà Công Lực', '01283388103', @kq output
print @kq
go
-- b. Hàm 
create or alter function fGetCustExistsCSDL (@hoten nvarchar(30), @sdt varchar(12))
returns int
as 
begin
    declare @kq int
    if exists (select * from customer where Cust_name = @hoten and Cust_phone = @sdt)
        begin 
            set @kq = 1
        end
    else
        begin
            set @kq = 0
        end
    return @kq
end
go 

print dbo.fGetCustExistsCSDL(N'Hà Công Lực', '01283388103')
go

-- 6. Cập nhật địa chỉ của khách hàng nếu biết mã số của họ. 
-- Thành công trả về 1, thất bại trả về 0
-- a. Thủ tục 
create proc spCapnhatDiachi6 @makh varchar(10), @diachi nvarchar(100), @kq int out 
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
exec spCapnhatDiachi6 '000001', N'NGUYỄN TIẾN DUẨN - THÔN 3 - XÃ DHÊYANG - EAHLEO - ĐĂKLĂK', @result out
print @result
go 

-- b. Hàm (Không có)

-- 7. Trả về số tiền có trong tài khoản nếu biết mã tài khoản.
-- a. Thủ tục
create proc spGetAcBalance7 @ac_no varchar(10), @ac_balance int output
as  
begin 
    select @ac_balance = ac_balance from account
end
go

declare @ac_balance int
exec spGetAcBalance7 '1000000001', @ac_balance out
print @ac_balance
go

-- b. Hàm
create or alter function fGetAcBalance (@ac_no varchar(10))
returns int
as
begin
    declare @ac_balance int
    select @ac_balance = ac_balance from account
    return @ac_balance 
end
go

print dbo.fGetAcBalance('1000000001')
go
-- 8. Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh.
-- a. Thủ tục
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

-- b. Hàm
create or alter function fGetBranchInfo (@macn varchar(10))
returns table
as 
return
    select count(distinct customer.Cust_id) as SoluongKH, sum(ac_balance) as TongTienTK
    from Branch 
        join customer on Branch.BR_id = customer.Br_id
        join account on customer.Cust_id = account.cust_id
    where branch.BR_id = @macn
go

select * from dbo.fGetBranchInfo('VT010')
go
-- 9. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
-- Giao dịch bất thường: 
-- giao dịch gửi diễn ra ngoài giờ hành chính, 
-- giao dịch rút diễn ra vào thời điểm 0am -> 3am
-- a. Thủ tục
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

-- b. Hàm
create or alter function fCheckAbnormality (@maGD varchar(10))
returns nvarchar(30)
as 
begin
    declare @time time, @t_type varchar(1), @kq nvarchar(30)
    select @time = t_time, @t_type = t_type from transactions where t_id = @maGD

    if @t_type = '1'
        begin
            if (@time between '07:30:00' and '12:00:00') or (@time between '13:30:00' and '16:00:00')
                begin
                    set @kq = 'Giao dich binh thuong'
                end
            else 
                begin
                    set @kq = 'Giao dich bat thuong'
                end 
        end 
    else --t_type = 0
        begin
            if @time between '00:00:00' and '03:00:00'
                begin
                    set @kq = 'Giao dich bat thuong'
                end
            else
                begin
                    set @kq = 'Giao dich binh thuong'
                end
        end
    return @kq 
end
go

print dbo.fCheckAbnormality('0000000329')
go

-- 10. Trả về mã giao dịch mới. 
-- Mã giao dịch tiếp theo được tính như sau: 
-- MAX(mã giao dịch đang có) + 1. 
-- Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
-- a. Thủ tục
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
-- b. Hàm
create or alter function fUpdateTransID()
returns varchar(12)
as
begin
    declare @maGD varchar(12), @maGDmoi varchar(12)
    set @maGD = (select max(t_id) from transactions)
    set @maGDmoi = @maGD + 1
    set @maGDmoi = replicate('0', len(@maGD) - len(@maGDmoi)) + @maGDmoi
    return @maGDmoi
end
go 

print dbo.fUpdateTransID()
go

/* 11.	Thêm một bản ghi vào bảng TRANSACTIONS nếu biết các thông tin ngày giao dịch, thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm:
a.	Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý
b.	Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý
c.	Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý
d.	Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
e.	Tính mã giao dịch mới
f.	Thêm mới bản ghi vào bảng TRANSACTIONS
g.	Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch */

-- A. Thủ tục
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
        set @ac_balance_new = (select ac_balance from account where ac_no = @stk) + @sotien
    end
    else if @loaiGD = 0 and @sotien <= (select ac_balance from account where ac_no = @stk)
        begin
            set @ac_balance_new = (select ac_balance from account where ac_no = @stk) - @sotien
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
    set ac_balance = @ac_balance_new where ac_no = @stk 
end
go 

declare @kq nvarchar(50)
exec spInsertTran '2023-03-10', '00:00:00', '1000000001', '1', 88118000, @kq output
print @kq
go
-- B. Hàm
create or alter function fInsertTran    
                            (@ngayGD date,
                            @thoigian time,
                            @stk varchar(12),
                            @loaiGD int,
                            @sotien money)
returns int
as
begin
    declare @kq int
    -- a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không
    if @ngayGD > getdate() and @thoigian > cast(getdate() as time)
    begin 
        set @kq = 0
    end 

    -- b. Kiểm tra số tài khoản có tôn tại trong bảng ACCOUNT không ?
    if not exists (select ac_no from account where Ac_no = @stk)
    begin
        set @kq = 0
    end

    -- c. Kiểm tra loại giao dịch có phù hợp không ?
    if @loaiGD not in (0,1)
    begin
        set @kq = 0
    end

    -- d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0) ?
    if @sotien <= 0
        begin
            set @kq = 0
        end

    declare @ac_balance_new money 
    if @loaiGD = 1
        begin
            set @ac_balance_new = (select ac_balance from account where ac_no = @stk) + @sotien
            set @kq = 1
        end
    else if @loaiGD = 0 and @sotien <= (select ac_balance from account where ac_no = @stk)
        begin
            set @ac_balance_new = (select ac_balance from account where ac_no = @stk) - @sotien
            set @kq = 1
        end
    else
        begin
            set @kq = 0 
        end

    return @kq
end
go 

print dbo.fInsertTran('2023-03-10', '00:00:00', '1000000001', '0', 88118000)
go 

-- 12. Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. Bao gồm những công việc sau:
-- a. Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
-- b. Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
-- c. Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
-- d. Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
-- e. Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có.

-- A. Thủ tục
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

-- B. Hàm
create or alter function fCau12 (@maKH varchar(12), @loaiTK int, @sotienTK money)
returns int 
as 
begin 
    declare @kq int
    --a. Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa?
    if not exists (select cust_id from customer where cust_id = @maKH)
        begin
            set @kq = 0
        end
    --b. Kiểm tra loại tài khoản có hợp lệ không?
    if @loaiTK not in (0, 1)
        begin
            set @kq = 0
        end
    
    --c. Kiểm tra số tiền có hợp lệ không?
    if @sotienTK is null 
        begin
            set @sotienTK = 50000
            set @kq = 1
        end
    else if @sotienTK < 0
        begin  
            set @kq = 0
        end
    else 
        begin 
            set @kq = 1
        end
    return @kq
end
go

print dbo.fCau12('000001','1', null)
go

-- 13. Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa 
-- nếu biết họ tên và số điện thoại. 
-- Tồn tại trả về 1, không tồn tại trả về 0
-- a. Thủ tục
create or alter proc spGetCustInfo13 @hoten nvarchar(30), @sdt varchar(12), @kq int output
as
begin
    if exists (select * from customer where Cust_name = @hoten and Cust_phone = @sdt)
        begin 
            set @kq = 1
        end
    else
        begin
            set @kq = 0
        end
end
go

declare @kq int
exec spGetCustInfo13 N'Hà Công Lực', '01283388103', @kq output
print @kq
go 
-- b. Hàm
create or alter function fGetCustExists13 (@hoten nvarchar(30), @sdt varchar(12))
returns int
as 
begin
    declare @kq int
    if exists (select * from customer where Cust_name = @hoten and Cust_phone = @sdt)
        begin 
            set @kq = 1
        end
    else
        begin
            set @kq = 0
        end
    return @kq
end
go 

print dbo.fGetCustExists13(N'Hà Công Lực', '01283388103')
go

-- 14. Tính mã giao dịch mới. 
-- Mã giao dịch tiếp theo được tính như sau: 
-- MAX(mã giao dịch đang có) + 1. 
-- Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
-- a. Thủ tục
create or alter proc spUpdateTransIDs14 @maGDmoi varchar(12) output
as 
begin
    declare @maGD varchar(12)
    set @maGD = (select max(t_id) from transactions)
    set @maGDmoi = @maGD + 1
    set @maGDmoi = replicate('0', len(@maGD) - len(@maGDmoi)) + @maGDmoi
end
go

declare @maGDmoi varchar(12) 
exec spUpdateTransIDs14 @maGDmoi output
print @maGDmoi
go 
-- b. Hàm
create or alter function fUpdateTransID14()
returns varchar(12)
as
begin
    declare @maGD varchar(12), @maGDmoi varchar(12)
    set @maGD = (select max(t_id) from transactions)
    set @maGDmoi = @maGD + 1
    set @maGDmoi = replicate('0', len(@maGD) - len(@maGDmoi)) + @maGDmoi
    return @maGDmoi
end
go

print dbo.fUpdateTransID14()
go

-- 15. Tính mã tài khoản mới. 
-- (định nghĩa tương tự như câu trên) 
-- a. Thủ tục
create or alter proc spUpdateAccNo @soTKmoi varchar(12) output
as
begin
    declare @soTK varchar(12)
    set @soTK = (select max(ac_no) from account)
    set @soTKmoi = @soTK + 1 
end
go

declare @soTKmoi varchar(12)
exec spUpdateAccNo @soTKmoi output
print @soTKmoi
go

-- b. Hàm
create or alter function fUpdateAccNo()
returns varchar(12)
as
begin
    declare @soTK varchar(12), @soTKmoi varchar(12)
    set @soTK = (select max(ac_no) from account)
    set @soTKmoi = @soTK + 1 
    return @soTKmoi
end
go 

print dbo.fUpdateAccNo()
go

-- 16. Trả về tên chi nhánh ngân hàng nếu biết mã của nó.
-- a. Thủ tục
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

-- b. Hàm 
create or alter function fGetBrName (@macn varchar(10)) 
returns nvarchar(100)  
as
begin
    declare @ten nvarchar(100)
    set @ten = (select br_name from branch where br_id = @macn)
    return @ten
end
go

print dbo.fGetBrName('VT009')
go

-- 17. Trả về tên của khách hàng nếu biết mã khách.
-- a. Thủ tục
create or alter proc spCustInfo17 @makh varchar(10), @tenkh nvarchar(20) output
as
begin
    select @tenkh = cust_name from customer where Cust_id = @makh
end 
go 

declare @tenkh nvarchar(20), @diachi nvarchar(100), @sdt varchar(11)
exec spCustInfo17 '000001', @tenkh output
print @tenkh
go 

-- b. Hàm
-- c1
create or alter function fCustInfo17 (@makh varchar(10))
returns nvarchar(20)
begin
    declare @tenkh nvarchar(20)
    select @tenkh = cust_name from customer where Cust_id = @makh
    return @tenkh
end 
go 

print dbo.fCustInfo17('000001')
go 
-- c2
create or alter function fGetCustInfo17 (@makh varchar(12)) 
returns table
as
return (select cust_name from customer where Cust_id = @makh)
go 

select * from dbo.fGetCustInfo17('000001')
go

-- 19. Trả về số lượng khách hàng nếu biết mã chi nhánh
-- a. Thủ tục
create or alter proc spGetBranchInfo19 @macn varchar(10), @soluongKH int out
as 
begin
    select @soluongKH = count(distinct customer.Cust_id)
    from Branch 
        join customer on Branch.BR_id = customer.Br_id
        join account on customer.Cust_id = account.cust_id
    where branch.BR_id = @macn
end
go

declare @soluongKH int , @tongtienTK money 
exec spGetBranchInfo19 'VT010', @soluongKH out
print @soluongKH
go
-- b. Hàm
create or alter function fCustCountInfo19 (@macn varchar(10))
returns int 
as
begin
    declare @soluongKH int 
    select @soluongKH = count(distinct customer.Cust_id) 
    from Branch 
        join customer on Branch.BR_id = customer.Br_id
        join account on customer.Cust_id = account.cust_id
    where branch.BR_id = @macn
    return @soluongKH
end
go

print dbo.fCustCountInfo19('VT010')
go

-- 20. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
-- Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am -> 3am
-- a. Thủ tục
create or alter proc spCheckDisnormality20 @maGD varchar(10), @kq nvarchar(30) output 
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
exec spCheckDisnormality20 '0000000329', @ktr output
print @ktr
go

-- b. Hàm
create or alter function fCheckAbnormality20 (@maGD varchar(10))
returns nvarchar(30)
as 
begin
    declare @time time, @t_type varchar(1), @kq nvarchar(30)
    select @time = t_time, @t_type = t_type from transactions where t_id = @maGD

    if @t_type = '1'
        begin
            if (@time between '07:30:00' and '12:00:00') or (@time between '13:30:00' and '16:00:00')
                begin
                    set @kq = 'Giao dich binh thuong'
                end
            else 
                begin
                    set @kq = 'Giao dich bat thuong'
                end 
        end 
    else --t_type = 0
        begin
            if @time between '00:00:00' and '03:00:00'
                begin
                    set @kq = 'Giao dich bat thuong'
                end
            else
                begin
                    set @kq = 'Giao dich binh thuong'
                end
        end
    return @kq 
end
go

print dbo.fCheckAbnormality20('0000000329')
go
-- 21. Sinh mã khách hàng tự động. 
-- Module này có chức năng tạo và trả về mã khách hàng mới 
-- bằng cách lấy MAX(mã khách hàng cũ) + 1.
select * from customer go
create or alter proc spUpdateCustIDs21 @maKHmoi varchar(12) output
as 
begin
    declare @maKH varchar(12)
    set @maKH = (select max(Cust_id) from customer)
    set @maKHmoi = @maKH + 1
    set @maKHmoi = replicate('0', len(@maKH) - len(@maKHmoi)) + @maKHmoi
end
go

declare @maKHmoi varchar(12) 
exec spUpdateCustIDs21 @maKHmoi output
print @maKHmoi
go 
-- b. Hàm
create or alter function fUpdateTransID14()
returns varchar(12)
as
begin
    declare @maKH varchar(12), @maKHmoi varchar(12)
    set @maKH = (select max(Cust_id) from customer)
    set @maKHmoi = @maKH + 1
    set @maKHmoi = replicate('0', len(@maKH) - len(@maKHmoi)) + @maKHmoi
    return @maKHmoi
end
go

print dbo.fUpdateTransID14()
go


-- 22. Sinh mã chi nhánh tự động. Sơ đồ thuật toán của module được mô tả như sau:
-- a. Thủ tục 
create or alter procedure spCreateBrID @mavung varchar(12), @maCNmoi varchar(12) output 
as 
begin
    declare @maCN varchar(12)
    if exists (select br_id from branch where BR_id like '%' + @mavung + '%')
        begin
            set @maCN = (select max(br_id) from Branch where BR_id like '%' + @mavung + '%')
            set @maCNmoi = replace(@maCN, @mavung, '') + 1
            set @maCNmoi = @mavung + ( replicate('0', 3 - len(@maCNmoi)) + @maCNmoi )
            return
        end
    else   
        begin
            set @maCNmoi = @mavung + '001'
            return
        end
end
go

declare @maCNmoi varchar(12)
exec dbo.spCreateBrID 'VN', @maCNmoi output
print @maCNmoi
go

-- b. Hàm
create or alter function fCreateBrID (@mavung varchar(12)) 
returns varchar(12)
as 
begin
    declare @maCNmoi varchar(12), @maCN varchar(12)
    if exists (select br_id from branch where BR_id like '%' + @mavung + '%')
        begin
            set @maCN = (select max(br_id) from Branch where BR_id like '%' + @mavung + '%')
            set @maCNmoi = replace(@maCN, @mavung, '') + 1
            set @maCNmoi = @mavung + ( replicate('0', 3 - len(@maCNmoi)) + @maCNmoi ) 
        end
    else   
        begin
            set @maCNmoi = @mavung + '001'
        end
    return  @maCNmoi
end
go

print dbo.fCreateBrID('VN')