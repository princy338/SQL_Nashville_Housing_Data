
--Previewing the data

select * from Data_Exploration_Project.dbo.Nashville_housing_data 

--Populate Property address date

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Data_Exploration_Project.dbo.Nashville_housing_data as a
INNER JOIN Data_Exploration_Project.dbo.Nashville_housing_data as b
ON a.ParcelID = b.ParcelID 
 AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

--Updating the table with replacing property address

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Data_Exploration_Project.dbo.Nashville_housing_data as a
INNER JOIN Data_Exploration_Project.dbo.Nashville_housing_data as b
ON a.ParcelID = b.ParcelID 
 AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

-- Verifying the Propert addrress has null values in it or not 

select * from Data_Exploration_Project.dbo.Nashville_housing_data 
where PropertyAddress is not null

--Breaking out address into individual columns (Address, City, State)

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from  Data_Exploration_Project.dbo.Nashville_housing_data 

--Updating the table with splitted city and address columns 

Alter Table Data_Exploration_Project.dbo.Nashville_housing_data 
Add PropertSplitaddress nvarchar(255);

Update Data_Exploration_Project.dbo.Nashville_housing_data 
SET PropertSplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table Data_Exploration_Project.dbo.Nashville_housing_data 
Add PropertyCity nvarchar(255);

Update Data_Exploration_Project.dbo.Nashville_housing_data 
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

--Verifying the splitted columns present or not 

select * from Data_Exploration_Project.dbo.Nashville_housing_data where PropertyCity is not null

--Parsing the Owner Address
Select PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
OwnerAddress from Data_Exploration_Project.dbo.Nashville_housing_data

Alter Table Data_Exploration_Project.dbo.Nashville_housing_data 
ADD Ownersplitaddress nvarchar(255);

UPDATE Data_Exploration_Project.dbo.Nashville_housing_data 
SET Ownersplitaddress = PARSENAME(Replace(OwnerAddress,',','.'),3) 

Alter Table Data_Exploration_Project.dbo.Nashville_housing_data 
ADD Ownersplitcity nvarchar(255);

UPDATE Data_Exploration_Project.dbo.Nashville_housing_data 
SET Ownersplitcity = PARSENAME(Replace(OwnerAddress,',','.'),2) 

Alter Table Data_Exploration_Project.dbo.Nashville_housing_data 
ADD Ownersplitstate nvarchar(255);

UPDATE Data_Exploration_Project.dbo.Nashville_housing_data 
SET Ownersplitstate = PARSENAME(Replace(OwnerAddress,',','.'),1) 

--Convert 'y' to yes and 'N' to no 

SELECT distinct(SoldAsVacant),count(SoldasVacant) from Data_Exploration_Project.dbo.Nashville_housing_data
group by SoldAsVacant
order by count(SoldasVacant)

SELECT SoldAsVacant,
case 
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant ='N' then 'No'
 else SoldAsVacant
end 
from Data_Exploration_Project.dbo.Nashville_housing_data 

Update Data_Exploration_Project.dbo.Nashville_housing_data 
SET SoldAsVacant= case 
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant ='N' then 'No'
 else SoldAsVacant
end

--Remove duplicates by using CTE ,using case statements, row_number and delete command

WITH CLEAN_DATA AS(
 select *,ROW_NUMBER() over (partition by
 ParcelID,
 PropertyAddress,
 SaleDate,
 SalePrice,
 LegalReference
 order by UniqueID) row_num
from Data_Exploration_Project.dbo.Nashville_housing_data
)
select * from CLEAN_DATA
where row_num>1

  
--Delete Unused columns
select * from Data_Exploration_Project.dbo.Nashville_housing_data

ALTER TABLE Data_Exploration_Project.dbo.Nashville_housing_data
DROP COLUMN PropertyAddress,OwnerAddress

--Done the final data is as below 
select * from Data_Exploration_Project.dbo.Nashville_housing_data
order by SalePrice desc 

--(Data is from Jan 2nd 2013 to Dec 13 2019)

--Lowest saleprice is 50 whereas highest is 54278060