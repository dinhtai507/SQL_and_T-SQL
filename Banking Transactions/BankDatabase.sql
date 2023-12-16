create database MIDTERM
go
use MIDTERM
go
create table Accounts(
	AcName nvarchar(100),
	Email	varchar(100),
	Phone	varchar(20),
	Avatar	varchar(max),
	primary key (Email)
)
go
create table Feeds(
	FID bigint,
	FDate date,
	FTime time,
	FLocation nvarchar(100),
	Content nvarchar(1000),
	LikeNo int,
	ShareNo int,
	CommentNo int,
	Email varchar(100),
	primary key (FID),
	foreign key (Email) references Accounts
)

go
create table Comments(
	FID bigint,
	CID varchar(10),
	CDate date,
	CTime time,
	Content nvarchar(1000),
	CommenterID varchar(100),
	primary key(FID, CID), 
	foreign key (FID) references Feeds,
	foreign key (CommenterID) references Accounts
)

--
insert into accounts values(N'Khá Bảnh', 'khabanh@gmail.com',null, null)
insert into accounts values(N'Kiều Cô Nương', 'kieuconuong@gmail.com','098765356', null)
insert into accounts values(N'Tuấn Chipi', 'tuanchipi@gmail.com',null, '\Images\tuanchipi.jpg')
insert into accounts values(N'Heo Còi QN', 'heocoi@gmail.com',null, null)

go

insert into feeds values(1,'2019-04-08','13:59',N'Đà Nẵng, Việt Nam',N'Thay vì viết bậy, vứt rác thì có vẻ đây là hành động lên án văn mình nhất 👍👍 Giờ in áo bán có ai muốn mua không? 🤔🤔',10,1,1,'khabanh@gmail.com')
insert into feeds values(2,'2019-04-08','14:00',null, N'🎶Chương trình "Dạ hội khiêu vũ The Vow - Lovely Night 2019" đã chính thức khép lại. Kết thúc chuỗi tháng ngày cùng nhau luyện tập miệt mài.',88,0,2,'khabanh@gmail.com')

go

insert into comments values(1,'11','2019-04-08','14:20','Oh, cool','heocoi@gmail.com')
insert into comments values(2,'21','2019-04-08','15:20','Sexy team :)','kieuconuong@gmail.com')
insert into comments values(2,'22','2019-04-09','15:20',' ui khoa mình nay hoành tránh quá 😍😍😍','heocoi@gmail.com')


