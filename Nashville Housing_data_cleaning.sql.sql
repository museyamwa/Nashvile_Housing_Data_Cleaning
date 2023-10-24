/*

Cleaning Data in SQL Queries

*/
USE portfolioproject;

Select *
From nashvillehousing;

desc nashvillehousing;

--------------------------------------------------------------------------------------------------------------------------

# Standardize Date Format


ALTER TABLE NashvilleHousing
add SaleDateConverted date;


Update NashvilleHousing
SET SaleDateConverted = cast(saledate as date);

--------------------------------------------------------------------------------------------------------------------------

# Populate Property Address data

Select *
From nashvillehousing
Where PropertyAddress IS NULL
order by ParcelID;


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a 
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress IS NULL;


Update nashvillehousing a 
JOIN nashvillehousing b
on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
SET a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
Where a.PropertyAddress IS NULL; 

--------------------------------------------------------------------------------------------------------------------------

# Breaking out Property Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing;
/*Where PropertyAddress =0;
order by ParcelID;*/

SELECT
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
From NashvilleHousing;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(','IN PropertyAddress) -1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(','IN PropertyAddress) + 1 , LENGTH(PropertyAddress));


Select *
From NashvilleHousing;


# Breaking out Owner Address into Individual Columns (Address, City, State)

Select OwnerAddress
From NashvilleHousing;


SELECT 
    SUBSTRING(OwnerAddress,
        1,
        POSITION(',' IN OwnerAddress) - 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1) AS Address,
    SUBSTRING(OwnerAddress,
        - 2,
        POSITION(',' IN OwnerAddress) - 1) AS Address
FROM
    nashvillehousing;


ALTER TABLE nashvillehousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE nashvillehousing 
SET 
    OwnerSplitAddress = SUBSTRING(OwnerAddress,
        1,
        POSITION(',' IN OwnerAddress) - 1);
        
        

ALTER TABLE nashvillehousing
ADD OwnerSplitCity nvarchar(255);

UPDATE nashvillehousing 
SET 
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);
            
            

ALTER TABLE nashvillehousing
ADD OwnerSplitState nvarchar(255);

UPDATE nashvillehousing 
SET 
    OwnerSplitState = SUBSTRING(OwnerAddress,
        - 2,
        POSITION(',' IN OwnerAddress) - 1);

SELECT *
FROM nashvillehousing;


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct SoldAsVacant, Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;


Select SoldAsVacant,
 CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 
From NashvilleHousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	row_number() OVER (
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                UniqueID
                ) row_num
FROM nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS(
SELECT *,
	row_number() OVER (
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                UniqueID
                ) row_num
FROM nashvillehousing
)
DELETE 
FROM nashvillehousing using nashvillehousing join RowNumCTE on nashvillehousing.PropertyAddress = RowNumCTE.PropertyAddress
WHERE row_num > 1;

SELECT *
FROM nashvillehousing;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing;


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDateConverted;



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
