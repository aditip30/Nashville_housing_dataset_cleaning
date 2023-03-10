select * from nashville_housing

-- standardize the date 


--Update Nashville_housing
SET SaleDate = CONVERT(Date , SaleDate) 

ALTER TABLE Nashville_housing 
ADD SaleDateConverted Date;

Update Nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted , convert(Date , SaleDate)
from Nashville_housing

-- Populate property Address Data
-- look at null values 
Select * 
from Nashville_housing
where PropertyAddress is null

--do a self join 
select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress) 
FROM Nashville_housing as a 
Join Nashville_housing as b 
  on a.ParcelID= b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress) 
FROM Nashville_housing as a 
Join Nashville_housing as b 
  on a.ParcelID= b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;

-- Breaking out Address into individuals columns (Address , city , state) 
select PropertyAddress 
from Nashville_housing

-- using substring and character index 

SELECT 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) - 1 ) as Address ,
SUBSTRING(PropertyAddress  , CHARINDEX(',' , PropertyAddress) + 1 , Len(PropertyAddress) ) as Address
from Nashville_housing


ALTER TABLE Nashville_housing 
ADD PropertySplitAddress Nvarchar(255)

Update Nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) - 1 ) 

ALTER TABLE Nashville_housing 
ADD PropertySplitCity Nvarchar(255) ;

Update Nashville_housing
Set PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX( ',' , PropertyAddress) + 1 , Len(PropertyAddress))

-- OwnerAddress split
SELECT PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3) as address,
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2) as city,
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1) as state
FROM Nashville_housing

ALTER TABLE Nashville_housing 
ADD OwnerSplitAddress Nvarchar(255) ;

Update Nashville_housing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',','.') , 3)

ALTER TABLE Nashville_housing 
ADD OwnerSplitCity Nvarchar(255) ;

Update Nashville_housing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',','.') , 2)

ALTER TABLE Nashville_housing 
ADD OwnerSplitState Nvarchar(255) ;

Update Nashville_housing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',','.') , 1)

--Change Y AND N to yes and no 

Select distinct(SoldAsVacant) , count(SoldAsVacant)
from Nashville_housing
group by SoldAsVacant


Select SoldAsVacant ,
CASE When SoldAsVacant  = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant 
	 END 
From Nashville_housing 

Update Nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant  = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant 
	 END 
From Nashville_housing 


-- Remove Duplicates 
WITH RowNumsCTE AS(
SELECT *, 
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
              PropertyAddress , 
			  SalePrice , 
			  SaleDate,
			  LegalReference 
			  ORDER BY 
			     UniqueID
				 ) row_nums

From Nashville_housing 
) 
DELETE 
FROM RowNumsCTE
WHERE row_nums > 1 

-- DELETE unused columns 
ALTER TABLE Nashville_housing 
DROP COLUMN OwnerAddress , TaxDistrict , PropertyAddress
ALTER TABLE Nashville_housing 
DROP COLUMN SaleDate

Select * From Nashville_housing
