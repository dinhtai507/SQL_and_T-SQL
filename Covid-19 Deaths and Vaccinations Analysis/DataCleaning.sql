use PortfolioProject
/*
 Cleaning Data in SQL Queries
 */

 select *
 from NashvilleHousing

 -- Standard Date Format
 select SaleDate, convert(Date, SaleDate)
 from NashvilleHousing

 update NashvilleHousing
 set SaleDate = convert(Date, SaleDate)
 
 alter table NashvilleHousing
 add SaleDateConverted Date

 update NashvilleHousing
 set SaleDateConverted = convert(Date, SaleDate)

 -- Populate Property Address data
 select *
 from NashvilleHousing
 -- where PropertyAddress is null
 order by ParcelID

 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
 from NashvilleHousing a
	join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
	join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID

select 
PropertyAddress, 
substring(PropertyAddress, 1, charindex(',',PropertyAddress) - 1)  as Address,
substring(PropertyAddress, charindex(',',PropertyAddress) + 1 , len(PropertyAddress))  as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress) + 1 , len(PropertyAddress))

select *
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

select
	parsename(replace(OwnerAddress, ',', '.'),  3),
	parsename(replace(OwnerAddress, ',', '.'),  2),
	parsename(replace(OwnerAddress, ',', '.'),  1)
from NashvilleHousing

-- OwnerSplitAddress
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)
update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),  3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)
update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'),  2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)
update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'),  1)

-- Change y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant)
from NashvilleHousing

select SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
	case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- Remove Duplicates
with RowNumCTE as (
select *,
	row_number() over (
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by UniqueID) row_num
from NashvilleHousing)
-- order by ParcelID
select *
from RowNumCTE
where row_num > 1
-- order by PropertyAddress

with RowNumCTE as (
select *,
	row_number() over (
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by UniqueID) row_num
from NashvilleHousing)
-- order by ParcelID
delete
from RowNumCTE
where row_num > 1

select *
from NashvilleHousing

-- Delete Unused Columns
select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate