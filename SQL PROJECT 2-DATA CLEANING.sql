Select *
From PortfolioProject.dbo.NashHousing

--Standardize Date Format

Select SaleDate CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashHousing 

--Populate property address data

Select *
From PortfolioProject.dbo.NashHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashHousing a
Join PortfolioProject.dbo.NashHousing b
    on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashHousing a
JOIN PortfolioProject.dbo.NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out address into individual columns (address, city, state)


Select PropertyAddress
From PortfolioProject.dbo.NashHousing
--order by Parcel

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashHousing


ALTER TABLE NashHousing
Add PropertySplitAddress Nvarchar(255);

Update NashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashHousing
Add PropertySplitCity Nvarchar(255);

Update NashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select OwnerAddress
From PortfolioProject.dbo.NashHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashHousing



ALTER TABLE NashHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashHousing
Add OwnerSplitCity Nvarchar(255);

Update NashHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashHousing
Add OwnerSplitState Nvarchar(255);

Update NashHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.NashHousing

-- Change 1 and 0 to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashHousing
Group by SoldAsVacant
order by 2

Alter table NashHousing 
Alter column [SoldAsVacant] Varchar(50)


Select SoldAsVacant
, CASE When SoldAsVacant = '1' THEN 'Yes'
	   When SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashHousing


Update NashHousing
SET SoldAsVacant = CASE When SoldAsVacant = '1' THEN 'Yes'
	   When SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select *
From PortfolioProject.dbo.NashHousing

-- Remove Duplicates

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

From PortfolioProject.dbo.NashHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashHousing


ALTER TABLE PortfolioProject.dbo.NashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
