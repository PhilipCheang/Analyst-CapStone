/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
FROM [project].[dbo].[NashvilleHousing]


-----------------------------------------------------------------------------

--Standardize Date Format

  Select saleDateConverted, CONVERT(Date,SaleDate)
  From project.dbo.NashvilleHousing

  Update NashvilleHousing
  SET SaleDate = CONVERT(Date,SaleDate)

  ALTER TABLE NashvilleHousing
  add SaleDateConverted Date;

    Update NashvilleHousing
  SET SaleDateConverted = CONVERT(Date,SaleDate)

  ------------------------------------------------------------------------

  -- Populate Property Address data

SELECT *
FROM Project.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID.


--Locate any null value in address column 
SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project.dbo.NashvilleHousing a
JOIN Project.dbo.NashvilleHousing b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project.dbo.NashvilleHousing a
Join Project.dbo.NashvilleHousing b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


----------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)

SELECT *
FROM Project.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--order by ParcelID.

-- when you put a minus 1 it will remove the comma
-- plus 1 get rid of comma at nashville
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address    

FROM Project.dbo.NashvilleHousing



  ALTER TABLE NashvilleHousing
  add PropertySplitAddress Nvarchar(255);

    Update NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


    ALTER TABLE NashvilleHousing
  add PropertySplitCity Nvarchar(255);

    Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

  SELECT *
  FROM Project.dbo.NashvilleHousing

-- BREAK down adddress, city, state
  SELECT OwnerAddress
  FROM Project.dbo.NashvilleHousing

  SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
  ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
  ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
   FROM Project.dbo.NashvilleHousing
   
   -----------------------------------------------------------------------------------

--add column ownersplitaddress, city, and state
  ALTER TABLE NashvilleHousing
  add OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


    ALTER TABLE NashvilleHousing
  add OwnerSplitCity Nvarchar(255);

    Update NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
  
  
  ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

 Update NashvilleHousing
  SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

  --------------------------------------------------------------------------------------

  --Change y and n to Yes and No in "Sold as Vacant" field

  SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
  FROM Project.dbo.NashvilleHousing
  GROUP BY SoldAsVacant
  ORDER BY 2


  Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
	From Project.dbo.NashvilleHousing

	Update NashvilleHousing
	SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

	
----------------------------------------------------------------------------------------	
	--Remove Duplicates PLUS CHECK IF DUPLICATE ARE GONE, REPLACE select * with DELETE to remove duplicate
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num


From Project.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
From Project.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------

	--Remove Duplicates PLUS CHECK IF DUPLICATE ARE GONE, REPLACE select * with DELETE to remove duplicate
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num


From Project.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



--------------------------------------------------------------

--Delete unused columns
SELECT *
From Project.dbo.NashvilleHousing

ALTER TABLE Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

