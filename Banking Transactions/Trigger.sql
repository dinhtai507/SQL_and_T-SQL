-- Khi thêm mới dữ liệu vào bảng transactions hãy đảm bảo rằng, 
-- số tiền giao dịch luôn lớn hơn 0
-- xác định:
-- loại: after
-- sự kiện: insert
-- (kí sinh) bảng: transactions
create or alter trigger tInsertTrans
on transactions
after insert 
as
begin
    declare @t_amount money
    select @t_amount = t_amount from inserted

    if @t_amount > 0
        begin
            print 'Invalid amount'
            rollback 
        end 
end
go

insert into transactions
values ('12345', '0', 100, '2013-01-01', '08:00:00', '1000000041')
go 

drop trigger tInsertTrans 
go
-- Khi xoá dữ liệu trong bảng transactions, hãy cập nhật bản ghi định xoá 
-- với loại giao dịch bằng 9
-- loại: instead of
-- sự kiện: delete
-- bảng: transactions
-- create trigger tDelTran
-- on transactions
create or alter trigger tDelTrans 
on transactions
instead of delete
as 
begin
    declare @t_id varchar(10)
    -- lấy ra t_id cần xoá
    select @t_id = t_id from deleted
    -- update t_type của nó
    update transactions set t_type = 9 where t_id = @t_id
end

delete transactions where t_id = '0000000202' 
go

drop trigger tDelTrans 
go

-- Khi sửa dữ liệu bảng transactiosn hãy đảm bảo rằng: ngày giao dịch không thay đổi
create or alter trigger tAlterTrans
on transactions
for update
as 
begin
    declare @t_id varchar(10), @t_date date
    select @t_id = t_id, @t_date = t_date from inserted
    
    update transactions set t_date = @t_date where t_id = @t_id
end
go

update transactions
set t_type = 0, t_date = '00:00:00'
where t_id = '0000000202' 
go

drop trigger tAlterTrans
go

-- 2. Sau khi xoá dữ liệu trong transactions hãy tính lại số dư trong bảng:
-- a. Nếu là giao dịch rút
-- Số dư = số dư cũ + t_amount
-- b. Nếu là giao dịch gửi
-- Số dư = số dư cũ - t_amount

create or alter trigger tDelTrans
on transactions
for delete 
as 
begin
    declare @ac_no varchar(10), @t_amount money, @t_type int
    select @ac_no = ac_no, @t_amount = t_amount, @t_type = t_type from deleted

    update account
    set ac_balance = 
        case 
            when @t_type = 0 then ac_balance + @t_amount
            else ac_balance - @t_amount
        end
    where ac_no = @ac_no
end
go 

delete transactions
where t_id = '0000000346'
go
select * from transactions go
-- 0000000230	1	11090000	2015-04-13	12:41:00	1000000001
-- 0000000244	1	83905000	2011-08-21	16:33:00	1000000001
-- 0000000346	0	4189000	2014-07-10	01:34:00	1000000001
select * from account go 
-- 1000000001	88118000	1	000001
drop trigger tDelTrans
go

-- 6. Khi sửa dữ liệu trong bảng transactions hãy tính lại số dư trong bảng account
-- Số dư = số dư cũ + (t_amount mới - t_amount cũ)
create or alter trigger tUpdateTrans6
on transactions
for update 
as 
begin
    declare @ac_no varchar(10), @t_amount_moi money, @t_amount_cu money
    select @t_amount_moi = t_amount, @ac_no = ac_no from inserted
    select @t_amount_cu = t_amount from deleted

    -- select @t_amount_cu = t_amount from deleted
    -- select @t_amount_moi = t_amount from inserted
    -- select @ac_no = ac_no from inserted
    update account set ac_balance = ac_balance + (@t_amount_moi - @t_amount_cu)
    where ac_no = @ac_no
end
go

begin tran
-- Lưu trạng thái hiện tại của dữ liệu trong bảng 'transactions'
select * from transactions where t_id = '0000000346'
select * from account
-- Thực hiện thao tác UPDATE với dữ liệu mới
update transactions set t_amount = 0 where t_id = '0000000346'
-- Lưu trạng thái của dữ liệu sau khi UPDATE
select * from transactions where t_id = '0000000346'
select * from account
-- Nếu kết quả không như mong đợi, hoặc muốn phục hồi lại dữ liệu ban đầu, sử dụng ROLLBACK để quay trở lại trạng thái ban đầu
rollback tran
-- Kiểm tra lại dữ liệu sau khi ROLLBACK
select * from transactions where t_id = '0000000346'
select * from account

-- begin tran
-- update transactions
-- set t_amount = 0 
-- where t_id = '0000000346'
-- rollback tran
select * from transactions go
-- 0000000230	1	11090000	2015-04-13	12:41:00	1000000001
-- 0000000244	1	83905000	2011-08-21	16:33:00	1000000001
-- 0000000346	0	4189000	2014-07-10	01:34:00	1000000001
select * from account go 
-- 1000000001	88118000	1	000001

-- 7. Giống câu 2

-- 4. Khi xóa dữ liệu trong bảng account, 
-- hãy thực hiện thao tác cập nhật trạng thái tài khoản là 9 (không dùng nữa) thay vì xóa.
create or alter trigger tDelAccount
on account
instead of delete 
as 
begin
    declare @ac_no varchar(10)
    select @ac_no = ac_no from deleted

    update account 
    set ac_type = 9 
    where ac_no = @ac_no
end
go

begin tran
-- Trạng thái dữ liệu hiện tại của account trước event
select * from account where ac_no = '1000000001'
-- Xảy ra event
delete account
where ac_no = '1000000001'
-- Trạng thái dữ liệu hiện tại của account sau event
select * from account where ac_no = '1000000001'
-- Trả về lại trạng thái như cũ
rollback tran
select * from account where ac_no = '1000000001'
go

-- 1. Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
-- a. Kiểm tra trạng thái tài khoản của giao dịch hiện hành. 
-- Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện.
-- Ngược lại:  
--      i.   Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
--      ii.  Nếu là giao dịch rút: số dư = số dư – tiền rút. 
--      Nếu số dư sau khi thực hiện giao dịch < 50.000 
--      thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
create or alter trigger tInsertTrans
on transactions
for insert
as
begin 
    declare @ac_no varchar(10), @ac_type int, @t_type int, @t_amount money
    select 
        @ac_no = inserted.ac_no, 
        @ac_type = ac_type,
        @t_type = t_type, 
        @t_amount = t_amount
    from inserted
        join account on inserted.ac_no = account.Ac_no

    if @ac_type = 9
        begin 
            print N'tài khoản đã bị xoá'
            rollback
        end
    else
        begin
            if @t_type = 1
                begin
                    update account set ac_balance = ac_balance + @t_amount where Ac_no = @ac_no
                end
            else
                begin
                    update account set ac_balance = ac_balance - @t_amount where Ac_no = @ac_no
                    declare @ac_balance money
                    select @ac_balance = ac_balance from account where ac_no = @ac_no
                    if @ac_balance < 50000
                        begin
                            print N'Không đủ tiền'
                            rollback
                        end
                end
        end
end
go

begin tran
-- Trước event
select * from transactions where ac_no = '1000000027'
select * from account where ac_no = '1000000027'
-- Xảy ra event
insert into transactions
values ('12345', 0, 3632000, '2013-01-01', '08:00:00', '1000000027')
go
-- Sau event
select * from transactions where ac_no = '1000000027'
select * from account where ac_no = '1000000027'
rollback tran
go
-- 1000000027	3672000	0	000027

-- 5. Giống câu 1

-- 3. Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự.
create or alter trigger tUpdateCustomer
on customer
for update
as
begin
    declare @cust_name nvarchar(30)
    select @cust_name = Cust_name from inserted
    if len(@cust_name) < 5
        begin
            print N'Tên khách hàng không hợp lệ'
            rollback
        end
end
go

begin tran
-- Trước event
select * from customer
-- Xảy ra event
update customer
set Cust_name = 'Grand Wade'
where Cust_id = '000001'
-- Sau event
select * from customer
rollback
go

-- 9. Khi tác động đến bảng account (thêm, sửa, xóa), 
-- hãy kiểm tra loại tài khoản. 
-- Nếu ac_type = 9 (đã bị xóa) 
-- thì đưa ra thông báo ‘tài khoản đã bị xóa’ 
-- và hủy các thao tác vừa thực hiện.
create or alter trigger tImpactAccount
on account
for insert, delete, update
as
begin
    if exists (select Ac_no from inserted where ac_type = 9)
        begin
            print N'Tài khoản đã bị xoá'
            rollback
        end
    else if exists (select Ac_no from deleted where ac_type = 9)
        begin
            print N'Tài khoản đã bị xoá'
            rollback
        end
    else if exists (select Ac_no from account where ac_type = 9)
        begin
            print N'Tài khoản đã bị xoá'
            rollback
        end
end
go

select * from account
go
use Bank
go

-- Thay đổi ac_type thành 9 trước khi test
-- update account 
-- set ac_type = 9
-- where Ac_no = '1000000001'

--- INSERT
begin tran
-- Trước Event
select * from account
-- Event
insert into account 
values ('12345', 100000, 0, '000001')
--Sau Event
select * from account
rollback
go

--- DELETE
begin tran
-- Trước Event
select * from account
-- Event
delete transactions 
where ac_no = '1000000001'
delete account 
where ac_no = '1000000001'
/* Lưu ý: theo sơ đồ, transactions sẽ là bảng chính (chứa khoá ngoại FK_ac_no), tham chiếu đến bảng phụ (chứa khoá chính PK_ac_no)
nên khi xoá ac_no, ta phải xoá từ bảng chính -> bảng phụ. */
--Sau Event
select * from account
rollback
go

--- UPDATE
begin tran
-- Trước Event
select * from account
-- Event
update account 
set ac_balance = 0
where Ac_no = '1000000001'
--Sau Event
select * from account
rollback
go

-- 10. Khi thêm mới dữ liệu vào bảng customer, 
-- kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng 
-- thì đưa ra thông báo ‘đã tồn tại khách hàng’ 
-- và hủy toàn bộ thao tác.

create or alter trigger tInsertCustomer
on Customer
after insert
as
begin
    declare @hoten nvarchar(30), @sdt varchar(12)
    select @hoten = Cust_name, @sdt = Cust_phone from inserted
    if (select count(*) from customer where Cust_name = @hoten and Cust_phone = @sdt) > 1
        begin
            print N'Đã tồn tại khách hàng'
            rollback
        end
end
go

begin tran
-- Trước event
select * from customer 
-- Event
insert into customer
values ('123452', N'Nguyễn Đình Tài', '01283388103', N'NGUYỄN TIẾN DUẨN - THÔN 3 - XÃ DHÊYANG - EAHLEO - ĐĂKLĂK', 'VT009')
go
-- Sau event
select * from customer
rollback
go

-- 11.	Khi thêm mới dữ liệu vào bảng account, 
-- hãy kiển tra mã khách hàng. 
-- Nếu mã khách hàng chưa tồn tại trong bảng customer 
-- thì đưa ra thông báo ‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’
-- và hủy toàn bộ thao tác. 

create or alter trigger tInsertAccount
on account 
instead of insert
as
begin
    declare @maKH varchar(10)
    select @maKH = cust_id from inserted
    if not exists (select * from customer where Cust_id = @maKH)
        begin
            print N'Khách hàng chưa tồn tại, hãy tạo mới khách hàng trước'
            rollback
        end
    else 
        begin
            insert into account (Ac_no, ac_balance, ac_type, cust_id)
            select Ac_no, ac_balance, ac_type, cust_id from inserted
        end
end
go

drop trigger tInsertAccount
go

begin tran
-- Trước event
select * from account
go 
-- Event
insert into account
values ('1000400001', 10000, 1, '000501')
go
-- Sau event
select * from account
go
rollback

select * from transactions
select * from account
select * from customer