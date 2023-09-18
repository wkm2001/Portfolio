/*

Cleaning Data in SQL Queries

Skills used: Altering tables, Aggregate Functions, Converting Data Types, CTEs, Joins, Windows Functions

*/


-- Shows the data

Select *
From nashvillleDataCleaning..nashvilleHousingData


--------------------------------------------------------------------------------------------------------------------------

-- Reformats Date

Select 
	SaleDate, 
	CONVERT(Date,SaleDate)
From nashvillleDataCleaning..nashvilleHousingData


ALTER TABLE nashvillleDataCleaning..nashvilleHousingData 
ALTER COLUMN SaleDate DATE 


Update nashvillleDataCleaning..nashvilleHousingData
Set SaleDate = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Fills in Property Address data

Select *
From nashvillleDataCleaning..nashvilleHousingData
Where PropertyAddress is null
Order by ParcelID


-- Matches null entries with filled entries by ParcelID

Select 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress, 
	ISNULL(a.PropertyAddress,b.PropertyAddress) as toReplaceNull
From nashvillleDataCleaning..nashvilleHousingData a
JOIN nashvillleDataCleaning..nashvilleHousingData b
	on a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-- Fills null entries with filled entries by ParcelID

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashvillleDataCleaning..nashvilleHousingData a
JOIN nashvillleDataCleaning..nashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Splitting Address into Individual Columns (Address, City, State)
-- PropertyAddress

-- Checking that PropertyAddress is all non-null

Select PropertyAddress
From nashvillleDataCleaning..nashvilleHousingData
Where PropertyAddress is null
Order by ParcelID


-- Splits the string entries into 2 strings by ',' character

Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From nashvillleDataCleaning..nashvilleHousingData


-- Adds the columns

ALTER TABLE nashvillleDataCleaning..nashvilleHousingData 
Add 
	PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255);


-- Sets the columns

Update nashvillleDataCleaning..nashvilleHousingData 
Set	
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- Checks to make sure the table was changed correctly

Select *
From nashvillleDataCleaning..nashvilleHousingData


-- PropertyAddress

-- Shows OwnerAddress

Select OwnerAddress
From nashvillleDataCleaning..nashvilleHousingData
Order by ParcelID


-- Splits the string entries into 3 strings

Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashvillleDataCleaning..nashvilleHousingData


-- Adds the columns

ALTER TABLE nashvillleDataCleaning..nashvilleHousingData
Add 
	OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);


-- Sets the columns

Update nashvillleDataCleaning..nashvilleHousingData
Set 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Checks to make sure the table was changed correctly

Select *
From nashvillleDataCleaning..nashvilleHousingData


--------------------------------------------------------------------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "Sold as Vacant" field

-- Groups all the current data in the field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillleDataCleaning..nashvilleHousingData
Group by SoldAsVacant
Order by 2


-- Converts from bit data type to nchar data type

ALTER TABLE nashvillleDataCleaning..nashvilleHousingData
ALTER COLUMN SoldAsVacant nchar(10)


-- Uses CASE to convert to the corresponding desired data

Select 
	SoldAsVacant, 
	CASE 
		When SoldAsVacant = '1' THEN 'Yes'
		When SoldAsVacant = '0' THEN 'No'
		ELSE SoldAsVacant
	END as fixedSoldAsVacant
From nashvillleDataCleaning..nashvilleHousingData


-- Updates the column

Update nashvillleDataCleaning..nashvilleHousingData
Set 
	SoldAsVacant = 
	CASE 
		When SoldAsVacant = '1' THEN 'Yes'
		When SoldAsVacant = '0'THEN 'No'
		ELSE SoldAsVacant
	END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removes Duplicates

-- Creates CTE that assigns row number (more than 1 indicates a duplicate)

With RowNumCTE as
(
Select *,
	ROW_NUMBER() OVER 
		(
		Partition by  
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		Order by
			UniqueID
		) as row_num
From nashvillleDataCleaning..nashvilleHousingData
)
Select *
From RowNumCTE
Where row_num > 1
Order by ParcelID, PropertyAddress


-- Deletes the duplicates

With RowNumCTE as
(
Select *,
	ROW_NUMBER() OVER 
		(
		Partition by  
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		Order by
			UniqueID
		) as row_num
From nashvillleDataCleaning..nashvilleHousingData
)
Delete
From RowNumCTE
Where row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

-- Shows the table

Select *
From nashvillleDataCleaning..nashvilleHousingData


-- Deletes the (unedited) OwnerAddress, TaxDistrict, (unedited) PropertyAddress fields

ALTER TABLE nashvillleDataCleaning..nashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
