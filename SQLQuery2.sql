
--overviewing the Data

select * 
from [housing data cleaning]..NashvilleHousing

-- standardize Data Format

Select SaleDateConverted, convert(date,saledate)
from [housing data cleaning]..NashvilleHousing


ALTER TABLE NashvilleHousing
add SaleDateConverted Date


update NashvilleHousing
set SaleDateConverted = convert(Date,Saledate)


-- Populate Property Address data


select PropertyAddress
from [housing data cleaning]..NashvilleHousing
where PropertyAddress is null


select *
from [housing data cleaning]..NashvilleHousing


select [UniqueID ], ParcelID, PropertyAddress
from [housing data cleaning]..NashvilleHousing
where PropertyAddress is null


select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
from [housing data cleaning]..NashvilleHousing a
join [housing data cleaning]..NashvilleHousing b
on a.ParcelID = b.ParcelID
where a.[UniqueID ]<>b.[UniqueID ] and a.PropertyAddress is null


 select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [housing data cleaning]..NashvilleHousing a
join [housing data cleaning]..NashvilleHousing b
on a.ParcelID = b.ParcelID
where a.[UniqueID ]<>b.[UniqueID ] and a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [housing data cleaning]..NashvilleHousing a
join [housing data cleaning]..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null


--Breaking out Address into Individual Column (Address, City, State)

select PropertyAddress
from [housing data cleaning]..NashvilleHousing



select 
SUBSTRING(PropertyAddress,1,charindex(',', PropertyAddress)-1)
from [housing data cleaning]..NashvilleHousing



select 
SUBSTRING(PropertyAddress,charindex(',', PropertyAddress)+1,LEN(PropertyAddress))
from [housing data cleaning]..NashvilleHousing



Alter table [housing data cleaning]..NashvilleHousing
add PropertySplitAddress nvarchar (255) 
  
update [housing data cleaning]..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',', PropertyAddress)-1)



Alter table [housing data cleaning]..NashvilleHousing
add PropertySplitCity nvarchar (255) 

update [housing data cleaning]..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',', PropertyAddress)+1,LEN(PropertyAddress))



select OwnerAddress
from [housing data cleaning]..NashvilleHousing



select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [housing data cleaning]..NashvilleHousing


Alter table [housing data cleaning]..NashvilleHousing
add OwnerSplitAddress nvarchar (255) 

update [housing data cleaning]..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter table [housing data cleaning]..NashvilleHousing
add OwnerSplitCity nvarchar (255) 

update [housing data cleaning]..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)



Alter table [housing data cleaning]..NashvilleHousing
add OwnerSplitState nvarchar (255) 

update [housing data cleaning]..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select *
from [housing data cleaning]..NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" Field

select distinct(Soldasvacant), COUNT(Soldasvacant)
from [housing data cleaning]..NashvilleHousing
group by Soldasvacant
order by 2


select SoldAsVacant
,case when SoldAsVacant = 'y' then 'Yes'
     when SoldAsVacant = 'n' then 'No'
	 end
from [housing data cleaning]..NashvilleHousing
where SoldAsVacant in ('n','y')

update [housing data cleaning]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'y' then 'Yes'
     when SoldAsVacant = 'n' then 'No'
	 end

	
	
--Removes Duplicates

select *
from [housing data cleaning]..NashvilleHousing


with RowNumCTE as(
select *,
  row_number() over (
  Partition by ParcelID,
  PropertyAddress,
  SaleDate,
  SalePrice
  order by UniqueID) as RowNum
  from [housing data cleaning]..NashvilleHousing
  order by rowNum desc
  )
  delete
  From RowNumCTE
  where RowNum >1



  --Delete unused columns

  
select *
from [housing data cleaning]..NashvilleHousing


Alter Table [housing data cleaning]..NashvilleHousing
Drop Column owneraddress, taxdistrict, propertyaddress

Alter Table [housing data cleaning]..NashvilleHousing
Drop Column saledate