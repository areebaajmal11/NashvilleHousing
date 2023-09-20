select * 
from dbo.NashvilleHousing

-- Standardize Date Format 

select SaleDate, CONVERT(Date, SaleDate) 
from dbo.NashvilleHousing

Update dbo.NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table dbo.NashvilleHousing
Add SaleDateConverted Date

Update dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

Select *
from dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- use alias here to update and not NashvilleHousing because that will give an error

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Property Address into Indiviual Columns (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1 ) As Address,
SUBSTRING(PropertyAddress,  Charindex(',', PropertyAddress) + 1 , LEN(PropertyAddress)) As Address
From dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1 )

Alter Table dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitCity = SUBSTRING(PropertyAddress,  Charindex(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From dbo.NashvilleHousing

--Breaking out Owner Address into Indiviual Columns (Address, City, State)

Select OwnerAddress
From dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From dbo.NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct (SoldAsVacant), COUNT (SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End



--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER By 
				 UniqueID
				 ) row_num

From dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns


Select *
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress
