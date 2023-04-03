use master

if exists (select * from sys.databases where name='Session19')
drop database Session19

create database Session19

use Session19

--2: create tables

create table TypeOfProduct (
   id varchar(4) primary key,
   type_name varchar(40) not null
)



create table Product(
   id varchar(15) primary key,
   dateOfManufacturer date ,
   type_id varchar(4) foreign key references TypeOfProduct(id),
)

create table Employee (
  id int  primary key,
  firstName varchar(40) not null,
  midName varchar(40) not null,
  lastName varchar(40) not null
)

create table ResponsiveProduct(
  product_id varchar(15) foreign key references Product (id),
  emp_id int foreign key references Employee(id),
  primary key (product_id, emp_id)
)

-- 3: insert data
insert into TypeOfProduct values ( 'Z37E', 'May tinh xach tay Z37' )
insert into TypeOfProduct values ( 'Z37A', 'May tinh chinh hang Z37' )
insert into TypeOfProduct values ( 'Z20E', 'May tinh xach tay Z20' )
insert into TypeOfProduct values ( 'Z20A', 'May tinh chinh hang Z20' )


insert into Product values ('Z37 1111111', '2009-12-12', 'Z37E' )
insert into Product values ('Z37 1111118', '2009-10-12', 'Z37A' )
insert into Product values ('Z37 1111112', '2009-12-12', 'Z37E' )
insert into Product values ('Z37 1111113', '2009-10-12', 'Z37A' )
insert into Product values ('Z20 1111111', '2009-11-12', 'Z20E' )
insert into Product values ('Z20 1111119', '2008-12-12', 'Z20A' )
insert into Product values ('Z20 1111120', '2009-11-12', 'Z20E' )
insert into Product values ('Z20 1111121', '2010-12-12', 'Z20A' )
insert into Product values ('Z20 1111123', '2010-01-12', 'Z20A' )



insert into Employee values (978688, 'An', 'Van', 'Nguyen')
insert into Employee values (978680, 'Hoa', 'Van', 'Nguyen')
insert into Employee values (978666, 'Nguyen', 'Van', 'Nguyen')

insert into ResponsiveProduct values ('Z37 1111111', 978688 )
insert into ResponsiveProduct values ('Z37 1111118', 978688 )
insert into ResponsiveProduct values ('Z20 1111111', 978680 )
insert into ResponsiveProduct values ('Z20 1111119',978680 )



-- 4: 
select * from TypeOfProduct

select * from Product

select * from Employee

select * from ResponsiveProduct

--5: liệt kê danh sách loại sản phẩm theo thứ tự tăng dần của tên

select * from TypeOfProduct
order by type_name


-- liệt kê dánh sách người chịu trách nhiệm của công ty theo thứ tự tăng dần của tên
select  e.id,
        e.lastName + ' ' + e.midName + ' ' + e.firstName  as FullName, 
		r.product_id
from Employee as e
inner join ResponsiveProduct as r on r.emp_id = e.id
order by e.firstName, e.midName, e.lastName

-- liệt kê sản phẩm của loại sản phầm có mã Z37E
select * from Product
where type_id like 'Z37E'

-- liệt kê các sản phẩm của Nguyen Van An chịu trách nhiệm order by id desc
select p.* 
from Product as p
inner join ResponsiveProduct as r on r.product_id = p.id
inner join Employee as e on e.id = r.emp_id
where e.firstName like 'An' and e.midName like 'Van' and e.lastName like 'Nguyen'
order by p.id desc

--6: số sản phẩm của từng loại sản phẩm

select p.type_id,
    count (*) as NumberOfProduct
from Product as p 
group by p.type_id

-- số loại sản phẩm trung bình theo loại sản phẩm (chi xet loai san pham co trong product)
   -- so loai san pham
   select count (*) as NumberOfType
   from TypeOfProduct

   --

   select 
     avg(result.NumberOfProduct) as Average_type
   from (
       select count(type_id) as NumberOfProduct
	   from Product
	   group by type_id
	   )
    as result

-- hiển thị toàn bộ thông tin về sản phẩm và loại sản phẩm
select p.id as ProductId,
        p.type_id as TypeId,
		tp.type_name as TypeName,
		p.dateOfManufacturer
from 
Product as p
inner join TypeOfProduct as tp on tp.id = p.type_id

-- hiển thị tòa bộ thông tin về người chịu trách nhiệm, loại sản phẩm và sản phẩm

select 
     emp.id as EmployeeId,
	 emp.lastName + ' ' + emp.midName + ' ' + emp.firstName as FullName,
	 tp.id as TypeId,
	 tp.type_name as TypeName,
	 p.id as ProductId,
	 p.dateOfManufacturer

from Employee as emp
inner join ResponsiveProduct as res on res.emp_id = emp.id
inner join Product as p on p.id = res.product_id
inner join TypeOfProduct as tp on tp.id = p.type_id



--7: viết câu lệnh để update ngày sản xuất là trước hoặc bằng ngày hiện tại
update Product 
set dateOfManufacturer = convert(Date, GETDATE())

select * from Product

select convert(Date, GETDATE()) as currentTime


-- viết câu lệnh để thêm trừong Edition của product

alter table Product
add edition int check(edition > 0 )

--8: đặt index cho tên người chịu trách nhiệm

create nonclustered index IX_Employee_Name
on Employee(firstName, lastName, midName)

-- View_Product: hiểm thị thông tin: mã sản phẩm, ngày sx, loại sản phẩm
create view View_Product
as 
select p.id as ProductId,
       p.dateOfManufacturer,
	   p.type_id as TypeId,
	   tp.type_name as TypeName
from Product as p 
inner join TypeOfProduct as tp on tp.id = p.type_id

select * from View_Product

-- View_Product_Employee: hiển thị mã sản phẩm, ngày sản xuất , người chịu trách nhiệm
create view View_Product_Employee
as
select 
     emp.id as EmployeeId,
	 emp.lastName + ' ' + emp.midName + ' ' + emp.firstName as FullName,
	 tp.id as TypeId,
	 tp.type_name as TypeName,
	 p.id as ProductId,
	 p.dateOfManufacturer

from Employee as emp
inner join ResponsiveProduct as res on res.emp_id = emp.id
inner join Product as p on p.id = res.product_id
inner join TypeOfProduct as tp on tp.id = p.type_id

select * from View_Product_Employee

-- View_Top_Product: hiển thị 5 sản phẩm mới nhất:
-- mã sản phẩm, loại sản phẩm, ngày sản xuất

create view View_Top_Product
as 
select top 5
       p.id as ProductId,
       p.dateOfManufacturer,
	   p.type_id as TypeId,
	   tp.type_name as TypeName
from Product as p 
inner join TypeOfProduct as tp on tp.id = p.type_id
order by p.dateOfManufacturer desc

-- SP_Insert_Type: thêm moi một loại sản phâm

create procedure SP_Insert_Type ( @id varchar(4), @name varchar(40))
as
begin
  if(@id not in (select id from TypeOfProduct))
  begin
     insert into TypeOfProduct values (@id, @name)
  end
  else
  begin
     print 'Type of products is existed.';
	 rollback transaction;
  end

end

exec SP_Insert_Type 'Z37A', 'May tinh Z37'
exec SP_Insert_Type 'Z30A', 'May tinh Z30A'

-- SP_Insert_EmployeeResponsive : thêm mới một người chịu trach nhiệm cho san pham
alter procedure SP_Insert_EmployeeResponsive
  ( @emp_id int,
     @product_id varchar(15))
as 
begin
   if(@emp_id in (select emp_id from ResponsiveProduct) 
   and @product_id in (select product_id from ResponsiveProduct) )
   begin
      print 'the employee was responsible for the product!';

	  rollback transaction;
   end

   else
   begin
     if (@emp_id in (select id from Employee) 
	 and @product_id in ( select id from Product))
	   begin
	     insert into ResponsiveProduct(emp_id, product_id) values (@emp_id, @product_id)
	   end
     else
	    begin
		 print 'The emp_id or p_id  not existed!';
		 rollback transaction;
		end
   end

end

exec SP_Insert_EmployeeResponsive 978680, 'Z20 1111111'
exec SP_Insert_EmployeeResponsive 9786, 'Z20 1111111'
exec SP_Insert_EmployeeResponsive 978680, 'Z20'

exec SP_Insert_EmployeeResponsive  978666, 'Z37 1111112'



select * from ResponsiveProduct
select * from Product
select * from Employee

-- SP_Insert_Product : thêm mới sản phẩm
create procedure SP_Insert_Product (@id int, @type_id varchar(4), @dateManu date)
as 
begin
  if(@id in ( select id from Product)) 
    begin
     print 'The product ID is exited!';
      rollback transaction;
    end
   else
   begin
     if(@type_id not in (select id from TypeOfProduct))
	 begin
	    print 'Do not finf type of Product!';
		rollback transaction;
	 end
	 else 
	 begin 
	   insert into Product(id, type_id, dateOfManufacturer) 
	   values (@id, @type_id, @dateManu)
	 end
   end
end
-- SP_Delete_Product: xóa một sản phẩm
insert into Product (id, dateOfManufacturer) values ('PDtest', '2022-10-10')
insert into Product (id, dateOfManufacturer) values ('PDtest1', '2022-10-10')
select * from Product

create or alter procedure SP_Delete_Product (@id varchar(15))
as
begin
  if(@id in (select id from Product ))
  begin
      if(@id not in (select product_id from ResponsiveProduct))
	  begin
	    if(@id in (select id from Product where Product.type_id is null))
	      delete from Product where Product.id = @id 
         else
		  begin
		   print 'Can not remove product with type not null';
		   rollback transaction;
		  end
	  end
	  else 
	  begin
	    print 'Do not delete product';
		rollback transaction;
	  end
  end
  else
  begin
     print 'Do not find product id need to remove';
	 rollback transaction;
  end
end

exec SP_Delete_Product 'Z37 1111111'

exec SP_Delete_Product 'Z20 1111123'

exec SP_Delete_Product 'PDTest'

select * from Product 
select * from ResponsiveProduct

-- SP_Delete_Products_ByType: xóa các sản phẩm của một laoị nào đó

create or alter procedure SP_Delete_Products_ByType (@typeId varchar(4))
as 
begin
   if  (@typeId not like (select type_id from Product))
   begin
      print 'Do not product has type_id!';
	  rollback transaction;
   end
   else 
   begin
        if  (select count(*) from Product  as p
		inner join ResponsiveProduct as res on res.product_id = p.id
		where p.type_id = @typeId
		group by p.id) > 0
		begin
		   print 'Can not remove product was responsive!';
		   rollback transaction;
		end
		else
		begin
		   delete from Product where type_id = @typeId;
		end    
   end
end

exec SP_Delete_Products_ByType 'Z37A'

exec SP_Delete_Products_ByType 'Z000'

select * from Product

select
count (*) as Counter
from Product  as p
		
inner join ResponsiveProduct as res on res.product_id = p.id
where p.type_id = 'Z'
group by p.id


select count (*) as Counter from Product as p 
  inner join TypeOfProduct as tp on tp.id = p.type_id
 where tp.id = 'Z'
  group by p.type_id