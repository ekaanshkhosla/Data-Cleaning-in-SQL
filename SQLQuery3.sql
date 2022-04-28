Select * 
from Project2.dbo.NH

----------------------- Change Date format -----------------------

Select SaleDate, CONVERT(Date, SaleDate)
from Project2.dbo.NH

Update Project2.dbo.NH
SET SaleDate = CONVERT(Date, SaleDate)

Alter table Project2.dbo.NH
Add SaleDateConverted Date

Update NH
Set SaleDateConverted = CONVERT(Date, SaleDate)


----------------------- Cleaning Propert adress Data -----------------------

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NH a
Join NH b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
Set propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NH a
Join NH b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


----------------------- Breaking address into individual Columns ( Adress, city, State ) -----------------------

Select PropertyAddress 
From NH

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Adress
from NH

Alter Table NH
Add PropertySplitAddress Nvarchar(255);

Update NH
Set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter Table NH
Add PropertyCityAddress Nvarchar(255);

Update NH
Set PropertyCityAddress =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))


Select OwnerAddress 
From NH

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from NH

ALTER TABLE NH
Add OwnerSplitAddress Nvarchar(255);

Update NH
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NH
Add OwnerSplitCity Nvarchar(255);

Update NH
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NH
Add OwnerSplitState Nvarchar(255);

Update NH
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From NH

----------------------- change Y and N to YES and NO in "sold as vacant" column -----------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NH
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant = 'N' then  'No'
	 else SoldAsVacant
	 end
from NH

Update NH
Set SoldAsVacant = Case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant = 'N' then  'No'
	 else SoldAsVacant
	 end


----------------------- Remove duplicates -----------------------

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NH
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns

Select *
From NH

ALTER TABLE NH
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

