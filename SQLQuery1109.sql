create database QuanLyBanHang

create table TableFood
(
	id int identity primary key,
	name nvarchar(100) not null default N'Ban chua co ten',
	[status] nvarchar(100) not null default N'Trống'
)
GO
create table Account
(	
	UserName nvarchar(100)  primary key,
	DisplayName nvarchar(100) NOT NULL default N'Ngọc Hòa',
	[Password] nvarchar(200)  NOT NULL default 0,
	Type int NOT NULL default 0
)
go
create table FoodCategory
(	
	id int identity primary key,
	[name] nvarchar(100) default N'Chưa đặt tên'
)
go
create table Food
(
	 id int identity primary key,
	 [Name] nvarchar(100)  NOT NULL default N'Chưa đặt tên',
	 idCategory int  NOT NULL,
	 price float  NOT NULL default 0
	 foreign key (idCategory) references dbo.FoodCategory(ID)
)
go
create table Bill
(
	id int identity primary key,
	DateCheckIn date NOT NULL,
	DateCheckOut date,
	idTable int  NOT NULL,
	status int  NOT NULL
	foreign key (idTable)  references dbo.TableFood(id)
)
go
create table BillInfo
(
	id int identity primary key,
	idBill int not null,
	idFood int not null,
	count int not null default 0,
	foreign key (idBill) references dbo.Bill(id),
	foreign key (idFood) references dbo.Food(id)
)
GO

Insert into dbo.Account(UserName,DisplayName,[Password], [Type])
Values (N'K9', N'RongK9', N'1', 1)
Insert into dbo.Account(UserName,DisplayName,[Password], [Type])
Values (N'Staff', N'Staff', N'1', 0)

select * from Account
declare @i int = 0
while @i <= 10
begin
	insert dbo.TableFood ( name)values (N'Bàn '+ cast(@i as nvarchar(100)))
	set @i = @i + 1
end
select * from TableFood
			
insert into dbo.TableFood(name,status)
values (N'Bàn 1')
insert into dbo.TableFood(name,status)
values (N'Bàn 2')
insert into dbo.TableFood(name,status)
values (N'Bàn 3')
create proc USP_GetTableList
as select * from dbo.TableFood

go 
exec dbo.USP_GetTableList
select * from Bill
select * from BillInfo

insert dbo.FoodCategory(name) 
values (N'Hải Sản')
insert dbo.FoodCategory(name) 
values (N'Nông sản')
insert dbo.FoodCategory(name) 
values (N'Lâm sản')
insert dbo.FoodCategory(name) 
values (N'sai Sản')
insert dbo.FoodCategory(name) 
values (N'Nước')
--thêm món ăn
insert dbo.Food(name, idCategory, price) 
values (N'Mục một nắng nướng', 1, 12000)
insert dbo.Food(name, idCategory, price) 
values (N'Ngêu hấp', 1, 40000)
insert dbo.Food(name, idCategory, price) 
values (N'Dê nướng sữa', 2, 172000)
insert dbo.Food(name, idCategory, price) 
values (N'Heo rừng nướng', 3, 832000)
insert dbo.Food(name, idCategory, price) 
values (N'Cơm choeem', 4, 6000)
insert dbo.Food(name, idCategory, price) 
values (N'Coca Cola', 5, 12000)

insert dbo.Bill(DateCheckIn,DateCheckOut,idTable,status)
values (GETDATE(),null,1,0)

insert dbo.Bill(DateCheckIn,DateCheckOut,idTable,status)
values (GETDATE(),null,2,0)
insert dbo.Bill(DateCheckIn,DateCheckOut,idTable,status)
values (GETDATE(),GETDATE(),2,1)
 select * from BillInfo

insert dbo.BillInfo(idBill, idFood, count)
values (20,1,2)
insert dbo.BillInfo(idBill, idFood, count)
values (21,3,4)
insert dbo.BillInfo(idBill, idFood, count)
values (1,5,1)
insert dbo.BillInfo(idBill, idFood, count)
values (1,3,4)
insert dbo.BillInfo(idBill, idFood, count)
values (2,1,4)	
select * from bill


alter proc USP_InsertBill
@idTable INT
as
begin
	insert dbo.Bill
			(DateCheckIn,
			DateCheckOut,
			idTable,
			status,
			discount
			)
			VALUES (GETDATE(),
			NUll,
			@idTable,
			0,
			0
			)
END
GO
select * from Food

Alter proc USP_InserBillInfo
@idBill int, @idFood int, @count int
as
begin
	
	declare @isExitsBillInfo int
	declare @foodCount int = 1
	select @isExitsBillInfo = id, @foodCount = b.count
	from BillInfo as b 
	where idBill = @idBill and idFood = @idFood 

	if(@isExitsBillInfo > 0)
	begin
		declare @newCount int = @foodCount + @count
		if(@newCount > 0)
			update BillInfo set count = @foodCount + @count where idFood = @idFood
		else
			delete BillInfo where idBill = @idBill and idFood = idFood
	end
	else
	begin 
		insert BillInfo(idBill, idFood, count)
		values(@idBill, @idFood, @count)
	end

	insert BillInfo
			(idBill, idFood, count)
	values (@idBill, @idFood, @count)
end 
go	









go
select * from BillInfo

update dbo.Bill set status  = 1 where id = 1

delete dbo.BillInfo 
delete dbo.Bill
alter trigger  UTG_UpdateBillInfo
ON dbo.BillInfo FOR insert, UPDATE
as
begin
	declare @idBill int
	select @idBill = idBill from inserted
	declare @idTable int
	select @idTable = idTable from dbo.Bill where id = @idBill and status = 0
	update dbo.TableFood set status = N'Có người' where id = @idTable
END
GO

create trigger UTG_UpdateTable
on dbo.TableFood for update

as
begin
	declare @idTable int
	declare @status nvarchar(100)
	select @idTable = id, @status=inserted.status from inserted

	declare @idBill int
	select @idBill = id from dbo.Bill where idTable=@idTable and status = 0

	declare @countBillInfo int
	select @countBillInfo = count(*) from	dbo.BillInfo where idBill = @idBill
	if(@countBillInfo >0 and @status <> N'Có người')
		update dbo.TableFood set status = N'Có người' where id = @idTable
	else if(@countBillInfo <0 and @status <> N'Trống')
		update dbo.TableFood set status = N'Trống' where id = @idTable
end
go
create trigger UTG_UpdateBill
on dbo.Bill for update
as
begin
	declare @idBill int
	select @idBill = id from inserted
	declare  @idTable int
	select @idTable = idTable from dbo.Bill where id = @idBill
	declare @count int = 0
	select @count = COUNT(*) from dbo.Bill where idTable = @idTable and status = 0
	if(@count = 0)
		update dbo.TableFood set status = N'Trống' where id = @idTable
end
go
alter table dbo.Bill
add discount int 
update dbo.Bill set discount = 0
select * from Bill


declare @idBillNew int = 13

select id into IDBillInfoTable from dbo.BillInfo where idBill = @idBillNew

declare @idBillOld int = 10

update dbo.BillInfo set idBill = @idBillOld where id in (select  * from IDBillInfoTable )

alter proc USP_SwitchTable1
@idTable1 int, @idTable2 int

as begin
	declare @idFirstBill int
	declare @idSeconrdBill int

	select @idSeconrdBill = id from dbo.Bill where idTable = @idTable2  AND status = 0
	select @idFirstBill = id from dbo.Bill where idTable = @idTable1  AND status = 0

	
	print @idFirstBill
	print @idSeconrdBill
	print '--------'

	if(@idFirstBill is null)
	begin
		print '00001'
		insert dbo.Bill
				(DateCheckIn,
				DateCheckOut,idTable,
				status )
		values(GETDATE(),
					null,
					@idTable1,
					0
					)
				
		select @idFirstBill = MAX(id) from dbo.Bill where  idTable = @idTable1 and status = 0
	end
	
	print @idFirstBill
	print @idSeconrdBill
	print '--------'

	 if(@idSeconrdBill is null)
	begin
		print '00002'
		insert dbo.Bill
				(DateCheckIn,
				DateCheckOut,idTable,
				status
				)
		values(GETDATE(),
			null,
			@idTable2,
			0
			)
		select @idSeconrdBill = MAX(id) from dbo.Bill where  idTable = @idTable2 and status = 0
	end

	print @idFirstBill
	print @idSeconrdBill
	print '--------'

	select id into IDBillInfoTable from dbo.BillInfo where idBill = @idSeconrdBill
	
	update dbo.BillInfo set idBill = @idSeconrdBill where idBill = @idFirstBill
	update dbo.BillInfo set idBill = @idFirstBill where id in (select * from IDBillInfoTable)


	drop table IDBillInfoTable 
end
select * from BillInfo
 


alter table Bill add totalPrice float



select * from Bill
delete Bill
alter proc USP_GetListBillByDate
@checkIn date, @checkOut date
as
begin
	select t.name as [Tên bàn], b.totalPrice as [Tổng tiền], DateCheckIn as [Ngày vào], DateCheckOut as [Ngày ra], discount as [Giảm giá] 
	from dbo.Bill as b, dbo.TableFood as t, BillInfo as bi, Food as f
	where DateCheckIn >= @checkIn and 
	DateCheckOut <= @checkOut and b.status = 1
	and t.id = b.idTable
end
go





ALTER PROC USP_InsertBillInfo
@idBill int, @idFood int, @count int
AS
BEGIN
 DECLARE @isExitBillInfo int
 DECLARE @foodCount int = 1
 SELECT @isExitBillInfo = id_BillInfo, @foodCount = count FROM tb_BillInfo WHERE id_bill = @idBill AND id_food = @idFood
 if(@isExitBillInfo > 0)
 BEGIN
  DECLARE @newCount int = @foodcount + @count
  if(@newCount > 0)
  BEGIN
   UPDATE tb_BillInfo SET count = @newCount Where id_BillInfo = @isExitBillInfo

  END
  else
  BEGIN
   DELETE tb_BillInfo Where id_BIllInfo = @isExitBillInfo
  END
 END
 else
 BEGIN
  if(@count <= 0)
   BEGIN
   return 1;
   END
  else
   BEGIN
   INSERT INTO tb_BillInfo
   (id_bill,
   id_food,
   count)
   VALUES
   (@idBill,
   @idFood,
   @count)
   END
 END
END

Go

exec USP_SwitchTable1 @idTable1 = 6,
@idTable2 = 3