use musicstore;

-- Customers per employee,
Select EmployeeId, count(customerid) as Number_of_Customers from customer left join employee on customer.supportrepid = employee.EmployeeId group by EmployeeId;

-- Average Customers per Employee?,
SELECT
  ROUND(AVG(Customer_Count), 2) AS Average_Customers_Per_Employee
FROM (
  SELECT 
    e.EmployeeId,
    COUNT(c.CustomerId) AS Customer_Count
  FROM Employee e
  LEFT JOIN Customer c ON e.EmployeeId = c.SupportRepId
  GROUP BY e.EmployeeId
) AS sub;

-- Sales personwise revenue
Select SupportRepId, concat(Employee.FirstName, " ", Employee.LastName) as Employee_Name, SUM(Total) as Total_Sales 
from Invoice 
Inner join Customer on Customer.CustomerId = Invoice.CustomerId 
Inner Join Employee on Employee.EmployeeId = Customer.SupportRepId
group by SupportRepId 
order by SUM(Total) desc;

-- Top 5 Sales Representative yearly
Select SalesYear, Representative, TotalRevenue From
(Select SupportRepId as Representative,
        year(InvoiceDate) as SalesYear,
        SUM(Total) as TotalRevenue,
        Row_Number() OVER(Partition By Year(InvoiceDate) Order By SUM(Total) Desc) As RepRank
        From
        Invoice Inner join Customer on Customer.CustomerId = Invoice.CustomerId
        Group By
        SupportRepId,
        Year(InvoiceDate)
        ) as Rep
Where
    RepRank <= 5
Order By
    SalesYear,
    TotalRevenue Desc;

-- Verify above ranking query    
Select year(InvoiceDate) as Invoice_Year, SupportRepId, SUM(Total) as Total_Sales from Invoice Inner join Customer on Customer.CustomerId = Invoice.CustomerId group by year(InvoiceDate), SupportRepId order by year(InvoiceDate), SUM(Total) desc;

-- Track wise revenue
Select invoiceline.Trackid, Track.Name, SUM(invoiceline.UnitPrice * invoiceline.Quantity) as Total_Revenue_Trackwise,
Case
	When SUM(invoiceline.UnitPrice * invoiceline.Quantity) >= 100 then "Platinum Track"
	When SUM(invoiceline.UnitPrice * invoiceline.Quantity) >= 70 and SUM(invoiceline.UnitPrice * invoiceline.Quantity) < 100 then "Gold Track" 
	When SUM(invoiceline.UnitPrice * invoiceline.Quantity) >= 40 and SUM(invoiceline.UnitPrice * invoiceline.Quantity) < 70 then "Silver Track"
	Else "Bronze Track"
End as Category
from invoiceline 
Inner Join Track on Track.TrackId = invoiceline.TrackId
group by invoiceline.Trackid
order by SUM(invoiceline.UnitPrice * invoiceline.Quantity) desc;

-- Monthly Revenue
Select year(InvoiceDate) as Rev_Year, month(InvoiceDate) as Rev_Month, SUM(Total) as Monthly_Revenue from Invoice Group By year(InvoiceDate), month(InvoiceDate) order by year(InvoiceDate), month(InvoiceDate);


Delimiter //
-- Drop Procedure Find_PlayList;

Create Procedure Find_PlayList(IN PlayList_Name NVarchar(500))
Begin
	Select track.Name as Track_Name,
	Composer,
	Playlist.Name as PlayList_Name
	from track 
	inner join playlisttrack on track.Trackid = playlisttrack.TrackId
	inner join playlist on playlisttrack.PlaylistId = playlist.PlaylistId
	where playlist.Name like concat('%', PlayList_Name, '%');
end; //

Call Find_PlayList('F');


Delimiter //
-- Drop Procedure Find_Artist;

Create Procedure Find_Artist(IN Artist_Name NVarchar(500))
Begin
	Select Artist.Name as Artist_Full_Name,
    Title as Album_Title,
	Composer as Composer,
    Track.Name as Track_Name
    from Artist
	Inner join album on Artist.ArtistId = Album.ArtistId
	Inner join Track on album.AlbumId = Track.AlbumId
    where Artist.Name like concat('%', Artist_Name, '%');
end; //

Call Find_Artist('Jonath');

-- Verify Query
Select Artist.*, Album.*, Track.*  from Artist
inner join album on Artist.ArtistId = Album.ArtistId
Inner join Track on album.AlbumId = Track.AlbumId;

-- Select Track Info with Genre and Media
Select distinct Name as Genre from Genre;
Select distinct Name as Media_Type from MediaType;

Select distinct(Count(Track.Name)) as Total_Tracks_Genrewise, Genre.Name as Genre from Track Inner Join Genre on Track.GenreId = Genre.GenreId group By Genre.GenreId;
Select distinct(Count(Track.Name)) as Total_Tracks_Mediawise, MediaType.Name as Media_Type from Track Inner Join MediaType on MediaType.MediaTypeId = Track.MediaTypeId group by MediaType.MediaTypeId;

Select Track.Name as Track_Name, Composer, Genre.Name as Genre, MediaType.Name as Media_Type from Track
Inner Join Genre on Genre.GenreId = Track.GenreId
Inner Join MediaType on MediaType.MediaTypeId = Track.MediaTypeId
Order By Media_Type, Genre;

Update Invoice
Set InvoiceDate = '2023-07-06 00:00:00' where InvoiceId='6';

Use musicstore;
Create View SalesPersonwise_Revenue as
Select SupportRepId, concat(Employee.FirstName, " ", Employee.LastName) as Employee_Name, SUM(Total) as Total_Sales 
from Invoice 
Inner join Customer on Customer.CustomerId = Invoice.CustomerId 
Inner Join Employee on Employee.EmployeeId = Customer.SupportRepId
group by SupportRepId 
order by SUM(Total) desc;

-- Customers per employee,
Create View Customers_per_Employee as 
Select EmployeeId, Concat(Employee.FirstName, " ", employee.LastName) as Emp_Name, count(customerid) as Number_of_Customers from customer left join employee on customer.supportrepid = employee.EmployeeId group by EmployeeId;

-- Average Customers per Employee?,
Create View Avg_Customer_per_Employee as 
SELECT
  ROUND(AVG(Customer_Count), 2) AS Average_Customers_Per_Employee
FROM (
  SELECT 
    e.EmployeeId,
    COUNT(c.CustomerId) AS Customer_Count
  FROM Employee e
  LEFT JOIN Customer c ON e.EmployeeId = c.SupportRepId
  GROUP BY e.EmployeeId
) AS sub;

-- Top 5 Sales Representative yearly
Create view Top_5_Sales_Representative_yearly as
Select SalesYear, Representative, Rep_Name, TotalRevenue From
(Select SupportRepId as Representative,
		concat(Employee.FirstName, " ", Employee.LastName) as Rep_Name,
        year(InvoiceDate) as SalesYear,
        SUM(Total) as TotalRevenue,
        Row_Number() OVER(Partition By Year(InvoiceDate) Order By SUM(Total) Desc) As RepRank
        From
        Invoice Inner join Customer on Customer.CustomerId = Invoice.CustomerId
        Inner Join Employee on Employee.EmployeeId = Customer.SupportRepId
        Group By
        SupportRepId,
        concat(Employee.FirstName, " ", Employee.LastName),
        Year(InvoiceDate)
        ) as Rep
Where
    RepRank <= 5
Order By
    SalesYear,
    TotalRevenue Desc;
    
-- Track wise revenue
Create view Track_wise_revenue as 
Select invoiceline.Trackid, Track.Name, SUM(invoiceline.UnitPrice * invoiceline.Quantity) as Total_Revenue_Trackwise,
Case
	When SUM(invoiceline.UnitPrice * invoiceline.Quantity) >= 100 then "Platinum Track"
	When SUM(invoiceline.UnitPrice * invoiceline.Quantity) >= 70 and SUM(invoiceline.UnitPrice * invoiceline.Quantity) < 100 then "Gold Track" 
	When SUM(invoiceline.UnitPrice * invoiceline.Quantity) >= 40 and SUM(invoiceline.UnitPrice * invoiceline.Quantity) < 70 then "Silver Track"
	Else "Bronze Track"
End as Category
from invoiceline
Inner Join Track on Track.TrackId = invoiceline.TrackId
group by invoiceline.Trackid
order by SUM(invoiceline.UnitPrice * invoiceline.Quantity) desc;

-- Monthly Revenue 
Create view Monthly_Revenue as 
Select year(InvoiceDate) as Rev_Year, InvoiceDate as Rev_Month, SUM(Total) as Monthly_Revenue from Invoice Group By year(InvoiceDate), Rev_Month order by Rev_Year, Rev_Month;

-- Genre_View
create view Genre_View as 
Select distinct(Count(Track.Name)) as Total_Tracks_Genrewise, Genre.Name as Genre from Track Inner Join Genre on Track.GenreId = Genre.GenreId group By Genre.GenreId;
-- Media_View
Create view Media_View as 
Select distinct(Count(Track.Name)) as Total_Tracks_Mediawise, MediaType.Name as Media_Type from Track Inner Join MediaType on MediaType.MediaTypeId = Track.MediaTypeId group by MediaType.MediaTypeId;

-- Genre_Media_View
Create View Genre_Media_View as 
Select Track.Name as Track_Name, Composer, Genre.Name as Genre, MediaType.Name as Media_Type from Track
Inner Join Genre on Genre.GenreId = Track.GenreId
Inner Join MediaType on MediaType.MediaTypeId = Track.MediaTypeId
Order By Media_Type, Genre;
    