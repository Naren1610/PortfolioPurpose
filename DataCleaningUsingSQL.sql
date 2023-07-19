-- Cleaning data set using SQL querires

select * from NashvilleHousingData
--------------------------------------------------

--- Standardizing date format

SELECT column_name,data_type FROM
INFORMATION_SCHEMA.COLUMNS WHERE
table_name = 'NashvilleHousingData';

-- SaleDate is in datetime format; Coverting it to date
Alter table NashvilleHousingData
add SaleDateConverted date

Update NashvilleHousingData
set SaleDateConverted=cast(SaleDate as date)

Select * from NashvilleHousingData
-------------------------------------------------------------

--- working on Property address(removing null values)

select PropertyAddress from NashvilleHousingData

Select * from NashvilleHousingData where PropertyAddress is null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------

---Splitting the Address columns (address,city,state)

select PropertyAddress from NashvilleHousingData

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from NashvilleHousingData

Alter table NashvilleHousingData
add PropertySplitAddress nvarchar(255)


Update NashvilleHousingData
set PropertySplitAddress=
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter table NashvilleHousingData
add PropertySplitCity nvarchar(20)


Update NashvilleHousingData
set PropertySplitCity=
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

----Splitting address using PARSENAME function
select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousingData


Alter table NashvilleHousingData
add OwnerSplitAddress nvarchar(255)


Update NashvilleHousingData
set OwnerSplitAddress=
PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousingData
add OwnerSplitCity nvarchar(255)


Update NashvilleHousingData
set OwnerSplitCity=
PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousingData
add OwnerSplitState nvarchar(20)


Update NashvilleHousingData
set OwnerSplitState=
PARSENAME(replace(OwnerAddress,',','.'),1)

-------------------------------------------------------------------

-- Changing Y & N to Yes & No. Trying to generalize the category

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousingData
group by SoldAsVacant

select SoldAsVacant,
Case when SoldAsVacant='Y' then 'Yes'	
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousingData

Update NashvilleHousingData
set SoldAsVacant=
Case when SoldAsVacant='Y' then 'Yes'	
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end

--------------------------------------------------------------------
---Removing Duplicates

With DuplicatesCTE AS(
select *,
ROW_NUMBER() over(
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by
UniqueID
) row_num
from NashvilleHousingData
)
delete from DuplicatesCTE
where row_num>1

-------------------------------------------------------------
---- deleting unused columns(It not adviced to delete data from the data set, we should maintain a backup always before data manipulation)

Alter table NashvilleHousingData
drop column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict




